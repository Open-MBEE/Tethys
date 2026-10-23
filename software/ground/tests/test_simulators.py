"""The four simulators (TethysGroundSoftware::SimulatedTestBedSet) and the golden packet fixtures.
Rows: TM-012 simulatorFidelity; VCRM groundTwoStepIntegration (GroundCommandTwoStepTest)."""

import json

from argent_tables import ground, telemetry
from meridian import fixtures
from meridian.forge.builder import CommandBuilder, CommandRequest, CommandVerdict
from meridian.simulators import CaptureRigController, DynamicsSimulator, FlightSoftwareInTheLoopSimulator, HardwareInTheLoopTestBed, TelemetryStream
from meridian.warden.checker import PlannedSequence, SequenceVerdict, UplinkExchange


def test_simulators_are_the_model_test_beds():
    beds = [HardwareInTheLoopTestBed(), CaptureRigController(), DynamicsSimulator(), FlightSoftwareInTheLoopSimulator()]
    rows = [c for c in ground.GROUND_COMPONENTS if c.simulator]
    assert [b.product_name for b in beds] == [r.product_name for r in rows] == ["Meridian Anvil", "Meridian Capstan", "Meridian Orrery", "Meridian Mirror"]
    assert [(b.flight_software_in_the_loop, b.hardware_in_the_loop) for b in beds] == [(r.flight_software_in_the_loop, r.hardware_in_the_loop) for r in rows]


def test_stream_follows_the_per_mode_rate_set():
    for mode in ("safe", "proximityOperations"):
        period = telemetry.RATE_SET_BY_MODE[mode].housekeeping_period_s
        stream = TelemetryStream(mode, 2 * period).packets()
        hk = [t for t, p in stream if p[0:2] == bytes([0x08 | (16 >> 8), 16])]
        assert len(hk) == 2, mode
    assert len(TelemetryStream("safe", 60.0).packets()) < len(TelemetryStream("proximityOperations", 60.0).packets())


def test_ground_two_step_integration():
    """GroundCommandTwoStepTest: the refusal on a rule violation and the second approval both observed
    with the flight-software-in-the-loop simulator as the flight side."""
    from argent_tables import commands
    mirror = FlightSoftwareInTheLoopSimulator(mode="proximityOperations")
    refused = UplinkExchange().run(PlannedSequence(1, "proximityOperations", True, True, 2000.0, False, 90.0, False, 0.95))
    hazardous = next(c for c in commands.COMMANDS if c.hazardous and "proximityOperations" in c.allowed_modes)
    arg = hazardous.arguments[-1] if hazardous.arguments else None
    held = CommandBuilder().validate(CommandRequest(hazardous.mnemonic, arg.minimum if arg and arg.minimum is not None else 0.0, "proximityOperations", 1, arg.name if arg else None)).verdict
    assert refused.verdict is SequenceVerdict.REFUSED and held is CommandVerdict.AWAITING_SECOND_APPROVAL
    forge = CommandBuilder()
    assert mirror.accept(forge.build(CommandRequest("CDH_NOOP", 0.0, "proximityOperations", 0)))
    assert mirror.accept(forge.build(CommandRequest("CDH_RESET_PROCESSOR", 1.0, "coast", 2, "confirmKey"))) is False
    assert mirror.commands_accepted and mirror.commands_rejected


def test_orrery_and_capstan():
    orrery = DynamicsSimulator()
    orrery.command_rate(-0.05)
    product = orrery.step(600.0)
    assert product.range_m == 2000.0 - 30.0 and product.range_rate_m_s == -0.05
    rig = CaptureRigController()
    hazardous = next(c for c in __import__("argent_tables").commands.COMMANDS if c.hazardous and c.application == "captureControl")
    assert not rig.command(hazardous.mnemonic, 1) and rig.command(hazardous.mnemonic, 2)


def test_anvil_registers():
    from argent_tables import interfaces
    anvil = HardwareInTheLoopTestBed()
    reg = next(r for r in interfaces.REGISTERS if r.access.lower() != "read")
    anvil.write(reg.map, reg.address, 1)
    assert anvil.read(reg.map, reg.address) == 1


def test_fixtures_are_current():
    """The committed golden fixtures are what the tables produce today (drift check)."""
    assert json.loads(json.dumps(fixtures.build(), sort_keys=True)) == fixtures.read()
