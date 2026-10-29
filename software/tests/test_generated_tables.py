"""Cross-check the generated Python tables against the model's pinned runs.

The figures under ``runs/`` are what the pinned OpenSysML evaluated on the model; the generated
tables must agree with every one of them that they restate.
"""

import pathlib
import re
import subprocess
import sys

import pytest

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "software" / "generated" / "python"))

import argent_tables as tables  # noqa: E402
from argent_tables import commands, enums, events, interfaces, modes, packets, parameters, schedule, state_machines, telemetry  # noqa: E402


def run_values(name):
    """The ``= value`` lines of a pinned run, in order."""
    text = (ROOT / "runs" / f"{name}.txt").read_text(encoding="utf-8")
    return [line.split("=", 1)[1].strip() for line in text.splitlines() if line.strip().startswith("=")]


def number(text):
    return float(re.match(r"[-+0-9.e]+", text).group(0))


@pytest.fixture(scope="module")
def dictionary_counts():
    return run_values("sw-dictionary-counts")


def test_dictionary_counts_match_pinned_run(dictionary_counts):
    v = dictionary_counts
    assert int(v[0]) == len(commands.COMMANDS) == commands.COMMAND_COUNT == 344
    assert int(v[1]) == commands.HAZARDOUS_COMMAND_COUNT == sum(c.hazardous for c in commands.COMMANDS)
    assert int(v[2]) == len(telemetry.TELEMETRY_POINTS) == 961
    assert int(v[3]) == telemetry.HOUSEKEEPING_POINT_COUNT == sum(t.kind == "housekeeping" for t in telemetry.TELEMETRY_POINTS)
    assert int(v[4]) == len(events.EVENTS) == 181
    assert int(v[5]) == events.FAULT_EVENT_COUNT == sum(e.fdir_relevant for e in events.EVENTS)
    assert int(v[6]) == len(packets.PACKETS) == 51
    assert int(v[7]) == len([p for p in parameters.PARAMETERS if p.table_id == 1])
    assert int(v[8]) == len(parameters.LIMIT_TABLE)


def test_dictionary_invariants_match_pinned_verdicts(dictionary_counts):
    assert dictionary_counts[9:] == ["true"] * 11
    opcodes = [c.opcode for c in commands.COMMANDS]
    assert opcodes == sorted(opcodes) and len(set(opcodes)) == len(opcodes)
    assert len({c.mnemonic for c in commands.COMMANDS}) == len(commands.COMMANDS)
    apids = [p.apid for p in packets.PACKETS]
    assert len(set(apids)) == len(apids)
    assert all(16 <= a <= 2047 for a in apids)
    ids = [e.id for e in events.EVENTS]
    assert ids == sorted(ids) and len(set(ids)) == len(ids)
    for p in packets.PACKETS:
        assert p.header_bits + sum(f.width_bits for f in p.fields) == p.length_octets * 8
        assert len(p.fields) == len({f.point for f in p.fields})
    assert all(c.allowed_modes for c in commands.COMMANDS)
    assert all(t.source for t in telemetry.TELEMETRY_POINTS)
    assert all(p.minimum <= p.value <= p.maximum for p in parameters.PARAMETERS)
    limit_names = {l.name for l in parameters.LIMIT_TABLE}
    assert {m.name for m in parameters.MONITOR_LIMITS if m.limit_set == "TethysFdir::cruiseLimits"} == limit_names
    abort = commands.COMMANDS_BY_MNEMONIC["FDR_ABORT_TO_RETREAT"]
    assert abort.hazardous and abort.two_step


def test_time_code_and_header_match_pinned_run():
    v = run_values("sw-dictionary-time-code")
    hk = packets.PACKETS_BY_APID[16]
    assert int(v[0]) == hk.header_bits
    assert int(v[2]) == hk.length_octets
    assert int(v[4]) == packets.TIME_CODE["coarseWidth"] + packets.TIME_CODE["fineWidth"]
    assert number(v[5]) == packets.TIME_CODE["fineResolution"]
    assert int(v[6]) == sum(packets.PRIMARY_HEADER.values()) == 48
    assert number(v[7]) == number(v[8]) == [l for l in parameters.LIMIT_TABLE if l.name == "commandLossTimeout"][0].value


def test_timing_matches_pinned_run():
    v = run_values("sw-timing-budgets")
    assert int(v[0]) == len(schedule.SCHEDULED_TASKS) == 22
    assert number(v[1]) == schedule.MINOR_FRAME_PERIOD_S
    assert number(v[15]) == sum(s.slots_per_frame for s in schedule.BUS_STREAMS)
    assert number(v[16]) == sum(s.slots_per_frame for s in schedule.BUS_STREAMS) / schedule.BUS_FRAME_SLOTS
    by_mode = re.findall(r"[-0-9.e]+", v[21])
    assert [int(float(x)) for x in by_mode] == [l.slots_used for l in schedule.BUS_MODE_LOADS]
    assert [r.rate_hz for r in schedule.RATE_GROUPS] == [16.0, 8.0, 2.0, 1.0]
    assert sum(p.window_s for p in schedule.PARTITIONS) == schedule.MAJOR_FRAME_PERIOD_S == 1.0
    assert schedule.MINOR_FRAMES_PER_MAJOR_FRAME == 8
    for t in schedule.SCHEDULED_TASKS:
        assert t.wcet_s <= t.deadline_s <= t.period_s
        assert t.firing_frames


def test_requirement_counts_match_pinned_run():
    v = run_values("sw-requirements-counts")
    assert number(v[2]) == [a for a in modes.APPLICATIONS if a.name == "fdir"][0].rate_hz
    assert number(v[3]) == [t for t in schedule.SCHEDULED_TASKS if t.name == "fdirTask"][0].period_s
    assert number(v[4]) == sum(s.slots_per_frame for s in schedule.BUS_STREAMS)
    assert int(number(v[5])) == schedule.BUS_FRAME_SLOTS == 64


def test_enums():
    assert len(enums.TugMode) == 16 and enums.TugMode.SAFE == 14
    assert len(enums.Opcode) == 344 and enums.Opcode.CDH_NOOP == 257
    assert len(enums.EventId) == 181 and len(enums.ParameterId) == 48
    assert [m.name.lower().replace("_", "") for m in enums.TugMode] == [r.mode.lower() for r in modes.MODE_TABLE]
    assert len(enums.InspectorMode) == 7
    assert set(enums.FaultResponse.__members__) == {"RETRY", "SWITCHOVER", "LOAD_SHED", "SAFE_MODE", "ABORT_RETURN"}
    assert len(enums.ApidClass) == 6 == len(packets.APID_BASES)


def test_mode_table_and_rate_sets():
    assert len(modes.MODE_TABLE) == 16
    assert {r.mode for r in telemetry.MODE_RATE_SETS} == {r.mode for r in modes.MODE_TABLE}
    safe = telemetry.RATE_SET_BY_MODE["safe"]
    assert safe.downlink_bit_s == 2000.0 and safe.housekeeping_period_s == 60.0
    assert telemetry.sample_rate_hz(telemetry.TELEMETRY_BY_MNEMONIC["CDH_T_BOARD_01"], "safe") == pytest.approx(1 / 60)
    capture = [a for a in modes.APPLICATIONS if a.name == "captureControl"][0]
    assert capture.active_modes == ("proximityOperations", "capture", "despin")  # the one Application that restricts activeModes
    assert all(len(a.active_modes) == 15 for a in modes.APPLICATIONS if a.name != "captureControl")  # allFlightModes
    assert "captureControl" not in modes.MODE_ROWS_BY_NAME["safe"].active_applications
    assert "fdir" in modes.MODE_ROWS_BY_NAME["safe"].active_applications
    assert len(modes.APPLICATIONS) == 12


def test_state_machines():
    names = [m.name for m in state_machines.STATE_MACHINES]
    assert names == ["SepStringController", "PowerManager", "ThermalController", "TelecomManager", "InspectorHandler",
                     "CaptureController", "RedundancyManager", "BootUpdateManager", "TugModes", "ModeManagementDispatcher",
                     "FdirSupervisor", "FdirResponseRelay"]
    for m in state_machines.STATE_MACHINES:
        ids = {s.qualified_name for s in m.states}
        guards = {g.id for g in m.guards}
        effects = {e.id for e in m.effects}
        for t in m.transitions:
            assert t.source in ids
            assert t.target == "done" or t.target in ids
            assert t.guard is None or t.guard in guards
            assert t.effect is None or t.effect in effects
        for s in m.states:
            assert s.leaf or s.initial_substate in ids
    tug = state_machines.STATE_MACHINES_BY_NAME["TugModes"]
    tug_states = {s.name for s in tug.states}
    assert {"coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust",
            "droHold", "dockedPassive", "disposal", "safe", "abortHold"} <= tug_states
    assert {s.name for s in tug.states if s.parent is None} == {"flightMode", "sepString", "telecom", "attitudeControl", "captureMechanism"}
    fdir = state_machines.STATE_MACHINES_BY_NAME["FdirSupervisor"]
    assert {s.name for s in fdir.states if s.parent is None} == {"commandLossTimer", "thrusterHealth", "ppuHealth", "powerHealth", "attitudeHealth", "earthImpactExclusion"}
    assert any("limits.commandLossTimeout" in (t.timed or "") for t in fdir.transitions)


def test_interfaces():
    assert [m.apid for m in interfaces.MESSAGES] == list(range(16, 28))
    assert all(len(t.ends) in (3, 4) for t in interfaces.TOPICS)
    bus = interfaces.ICD_PARAMETERS_BY_NAME
    assert bus[("OnBoardBusProtocolIcd", "designation")].value == "AABP-1"
    assert bus[("OnBoardBusProtocolIcd", "scheduleSlotCount")].value == schedule.BUS_FRAME_SLOTS
    assert bus[("OnBoardBusProtocolIcd", "checksumWidth")].value == 16
    assert bus[("OnBoardBusProtocolIcd", "retryLimit")].value == 2
    assert bus[("SpaceLinkProfileIcd", "designation")].value == "MLS-2"
    assert len(interfaces.REGISTER_MAPS) == 2
    for m in interfaces.REGISTER_MAPS:
        regs = [r for r in interfaces.REGISTERS if r.map == m.name]
        assert len(regs) == m.register_count
        assert all(r.address < m.address_limit and r.width_bits == m.data_width_bits for r in regs)


def test_c_selftest_binary_when_built():
    exe = ROOT / "build" / "software" / "selftest"
    if not exe.exists():
        pytest.skip("C self-test not built; make software-selftest builds it")
    out = subprocess.run([str(exe)], check=True, capture_output=True, text=True).stdout
    assert out.startswith("selftest: ok")


def test_package_metadata():
    assert tables.MODEL_TOOL_VERSION == "5cd37f2"
    assert tables.MODEL_TOOL_COMMIT == "5cd37f288fef171d62737d6045f4caff772b6014"
    assert tables.GENERATOR_VERSION
