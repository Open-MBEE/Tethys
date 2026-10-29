"""Meridian Lantern (TethysGroundSoftware::TelemetryServer) against runs/sw-ground-structure.txt, the
golden packet fixtures and the model's CheckLimits/EngineeringUnits/LinearTrend through the client.
Rows: TM-004 telemetryDecommutation, TM-005 limitAlarming, TM-006 trendingAutomation."""

from conftest import literal, number

from argent_tables import packets, telemetry
from meridian import ccsds, fixtures
from meridian.lantern.server import AlarmSeverity, TelemetryServer, check_limits, linear_trend
from meridian.modelbridge import magnitude
from meridian.simulators import TelemetryStream

S = "TethysGroundSoftware::meridianOperationsSuite.moc.telemetryServer"


def test_counts_and_frame_length(structure):
    tm = TelemetryServer()
    assert tm.dictionary_packet_count == int(number(structure[f"{S}.dictionaryPacketCount"]))
    assert tm.dictionary_point_count == int(number(structure[f"{S}.dictionaryPointCount"]))
    assert tm.frame_length_b == number(structure[f"{S}.frameLength"])
    assert tm.all_packets_decommutate is (structure[f"{S}.allPacketsDecommutate"] == "true")


def test_all_packets_decommutate_from_the_fixtures():
    """allPacketsDecommutate / TM-004: every one of the 51 dictionary packets decodes to its fields."""
    tm = TelemetryServer()
    seen = set()
    for row in fixtures.read()["packets"]:
        eng = tm.decommutate(bytes.fromhex(row["hex"]))
        assert eng.packet == row["mnemonic"] and eng.point_count == len(packets.PACKETS_BY_APID[row["apid"]].fields)
        assert eng.values == {k: float(v) for k, v in row["engineering"].items()}
        seen.add(row["apid"])
    assert len(seen) == packets.PACKET_COUNT == 51
    apids = [p.apid for p in packets.PACKETS]
    assert len(set(apids)) == len(apids) and max(apids) < 1 << packets.PRIMARY_HEADER["apidWidth"]
    assert all(t.source for t in telemetry.TELEMETRY_POINTS)


def test_bus_voltage_and_low_battery_alarms(structure, bridge):
    """busVoltageAlarm nominal, lowBatteryAlarm violation, as the model's sample inputs give them."""
    raw, scale, offset = (int(bridge.eval(f"{S}.busVoltageSample.rawCount", subject="TethysGroundSoftware::meridianOperationsSuite")),
                          float(bridge.eval(f"{S}.busVoltageSample.scale", subject="TethysGroundSoftware::meridianOperationsSuite")),
                          float(bridge.eval(f"{S}.busVoltageSample.offset", subject="TethysGroundSoftware::meridianOperationsSuite")))
    value = ccsds.engineering_units(raw, scale, offset)
    lo, hi, band = (float(bridge.eval(f"{S}.busVoltageAlarm.{n}", subject="TethysGroundSoftware::meridianOperationsSuite")) for n in ("lowLimit", "highLimit", "warningBand"))
    assert check_limits(value, lo, hi, band).name.lower() == literal(structure[f"{S}.busVoltageAlarm.severity"])
    fraction = float(bridge.eval(f"{S}.lowBatteryAlarm.value", subject="TethysGroundSoftware::meridianOperationsSuite"))
    assert TelemetryServer().battery_alarm(fraction).name.lower() == literal(structure[f"{S}.lowBatteryAlarm.severity"])
    model = bridge.eval(f"CheckLimits({fraction!r}, flightDictionary.limitTable.batteryLowFraction, 1.0, 0.05)", context="TethysGroundSoftware")
    assert str(model[0].name).rsplit("::", 1)[-1] == literal(structure[f"{S}.lowBatteryAlarm.severity"])


def test_tm005_ground_alarm_leads_the_on_board_trip():
    """TM-005 limitAlarming: the limit table's batteryLowFraction is below the FR-004 floor, so the
    violation is raised before the flight software acts."""
    from argent_tables import ground
    tm = TelemetryServer()
    assert tm.limit_table["batteryLowFraction"] < ground.CHECK_LIMITS["stateOfChargeFloor"].value
    assert tm.battery_alarm(tm.limit_table["batteryLowFraction"] + 0.01) is AlarmSeverity.WARNING
    assert tm.battery_alarm(0.5) is AlarmSeverity.NOMINAL


def test_xenon_trend(structure, bridge):
    cur, rate, days = (float(bridge.eval(f"{S}.xenonTrend.{n}", subject="TethysGroundSoftware::meridianOperationsSuite")) for n in ("current", "ratePerDay", "days"))
    projected = TelemetryServer().trend("SEP_XENON_REMAINING", cur, rate, days).projected
    assert projected == number(structure[f"{S}.xenonTrend.projected"]) == linear_trend(cur, rate, days)
    assert float(magnitude(bridge.eval(f"LinearTrend({cur!r}, {rate!r}, {days!r})", context="TethysGroundSoftware"))) == projected


def test_tm006_every_housekeeping_point_is_trended():
    tm = TelemetryServer()
    for _, p in TelemetryStream("coast", 1.0).packets():
        tm.decommutate(p)
    trends = tm.trends(30.0, {})
    assert len(trends) == telemetry.HOUSEKEEPING_POINT_COUNT == 320


def test_alarm_lifecycle_runs_from_the_table():
    tm = TelemetryServer()
    point = telemetry.TELEMETRY_BY_MNEMONIC["EPS_BATT_CELL_V_01"]
    assert tm.observe(point, point.red_low - 1.0) is AlarmSeverity.VIOLATION and tm.alarm_state(point.mnemonic) == "raised"
    tm.acknowledge(point.mnemonic)
    assert tm.alarm_state(point.mnemonic) == "acknowledged"
    assert tm.observe(point, (point.red_low + point.red_high) / 2) is AlarmSeverity.NOMINAL and tm.alarm_state(point.mnemonic) == "quiet"


def test_frame_synchronisation():
    tm = TelemetryServer()
    body = b"".join(p for _, p in TelemetryStream("safe", 1.0).packets()[:3])
    frame = bytes(int(tm.frame_length_b))
    idle = ccsds.PrimaryHeader(apid=0x7FF, sequence_count=0, data_length=0, secondary_header=False).pack()
    inner = body + idle
    frame = frame[:6] + inner + frame[6 + len(inner):]
    assert len(frame) == 1115 and len(tm.frames(frame)) == 3
