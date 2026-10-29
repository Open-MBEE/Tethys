"""``TethysGroundSoftware::TelemetryServer`` (Meridian Lantern): synchronises the transfer frames the
gateway forwards, decommutates every dictionary packet by its ``PacketDefinition`` layout
(``argent_tables.packets``), converts to engineering units, checks the dictionary limits and the
FDIR limit table (``argent_tables.parameters.LIMIT_TABLE``), raises alarms through
``AlarmLifecycle`` and trends the resource points with ``LinearTrend``.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from argent_tables import ground, interfaces, packets, parameters, telemetry
from argent_tables.ground import AlarmSeverity

from .. import ccsds
from ..statemachine import TableStateMachine

MODEL_PART = "TethysGroundSoftware::meridianOperationsSuite.moc.telemetryServer"
MODEL_DEFINITION = "TethysGroundSoftware::TelemetryServer"
FRAME_LENGTH_B = float(interfaces.ICD_PARAMETERS_BY_NAME[("SpaceLinkProfileIcd", "transferFrameLength")].value)
FRAME_HEADER_B = float(interfaces.ICD_PARAMETERS_BY_NAME[("SpaceLinkProfileIcd", "frameHeaderLength")].value)
FRAME_TRAILER_B = float(interfaces.ICD_PARAMETERS_BY_NAME[("SpaceLinkProfileIcd", "frameTrailerLength")].value)
LIMIT_TABLE = {row.name: row.value for row in parameters.LIMIT_TABLE}


def check_limits(value: float, low_limit: float, high_limit: float, warning_band: float) -> AlarmSeverity:
    """``TethysGroundSoftware::CheckLimits``: a violation outside the limits, a warning inside the band."""
    if value < low_limit or value > high_limit:
        return AlarmSeverity.VIOLATION
    if value < low_limit + warning_band or value > high_limit - warning_band:
        return AlarmSeverity.WARNING
    return AlarmSeverity.NOMINAL


def linear_trend(current: float, rate_per_day: float, days: float) -> float:
    """``TethysOperations::LinearTrend``: ``current + ratePerDay * days``."""
    return current + rate_per_day * days


def dictionary_severity(point: telemetry.TelemetryPoint, value: float) -> AlarmSeverity:
    """The dictionary's four limits as ``CheckLimits`` inputs: red limits bound the violation, the
    yellow-to-red distance is the warning band."""
    if point.red_low is None or point.red_high is None:
        return AlarmSeverity.NOMINAL
    band_low = (point.yellow_low - point.red_low) if point.yellow_low is not None else 0.0
    band_high = (point.red_high - point.yellow_high) if point.yellow_high is not None else 0.0
    sev = check_limits(value, point.red_low, point.red_high, 0.0)
    if sev is AlarmSeverity.NOMINAL and (value < point.red_low + band_low or value > point.red_high - band_high):
        return AlarmSeverity.WARNING
    return sev


@dataclass(frozen=True)
class AlarmRecord:
    """``TethysGroundSoftware::AlarmRecord``."""

    mnemonic: str
    value: float
    severity: AlarmSeverity
    acknowledged: bool = False


@dataclass(frozen=True)
class TrendProduct:
    """``TethysGroundSoftware::TrendProduct``."""

    mnemonic: str
    projected: float
    horizon_days: float


@dataclass(frozen=True)
class EngineeringTelemetry:
    """``TethysGroundSoftware::EngineeringTelemetry``: the points of one packet in engineering units."""

    packet: str
    time_s: float
    values: dict[str, float]

    @property
    def point_count(self) -> int:
        return len(self.values)


@dataclass
class TelemetryServer:
    """Meridian Lantern."""

    alarms: dict[str, TableStateMachine] = field(default_factory=dict)
    records: list[AlarmRecord] = field(default_factory=list)
    latest: dict[str, float] = field(default_factory=dict)
    model = ground.COMPONENTS_BY_PATH["moc.telemetryServer"]

    @property
    def product_name(self) -> str:
        return self.model.product_name

    dictionary_packet_count = packets.PACKET_COUNT
    dictionary_point_count = telemetry.TELEMETRY_POINT_COUNT
    housekeeping_point_count = telemetry.HOUSEKEEPING_POINT_COUNT
    frame_length_b = FRAME_LENGTH_B
    limit_table = LIMIT_TABLE

    @property
    def all_packets_decommutate(self) -> bool:
        """``flightDictionary.packetsSumToLength``: every packet's layout is consistent."""
        return all(ccsds.layout_consistent(p) for p in packets.PACKETS)

    def decommutate(self, data: bytes) -> EngineeringTelemetry:
        """One packet's engineering telemetry, every point limit-checked."""
        decoded = ccsds.decode(data)
        values = {}
        for mnemonic, raw in decoded.raw.items():
            point = telemetry.TELEMETRY_BY_MNEMONIC[mnemonic]
            scale, offset = ccsds.calibration(point)
            value = ccsds.engineering_units(raw, scale, offset)
            values[mnemonic] = value
            self.latest[mnemonic] = value
            self.observe(point, value)
        return EngineeringTelemetry(decoded.packet.mnemonic, decoded.time_code.seconds, values)

    def frames(self, frame: bytes) -> list[EngineeringTelemetry]:
        """Synchronise one MLS-2 transfer frame: packets fill the data field between the frame header
        and trailer; idle fill (APID 2047) ends the frame."""
        if len(frame) != int(FRAME_LENGTH_B):
            raise ccsds.LayoutError(f"frame of {len(frame)} octets, the profile says {FRAME_LENGTH_B:.0f}")
        body = frame[int(FRAME_HEADER_B): len(frame) - int(FRAME_TRAILER_B)]
        out, pos = [], 0
        while pos + ccsds.PRIMARY_HEADER_BITS // 8 <= len(body):
            header = ccsds.PrimaryHeader.unpack(body[pos:])
            if header.apid == 0x7FF:
                break
            length = header.data_length + 1 + ccsds.PRIMARY_HEADER_BITS // 8
            out.append(self.decommutate(body[pos: pos + length]))
            pos += length
        return out

    def observe(self, point: telemetry.TelemetryPoint, value: float) -> AlarmSeverity:
        severity = dictionary_severity(point, value)
        machine = self.alarms.setdefault(point.mnemonic, TableStateMachine(ground.ALARM_LIFECYCLE))
        if severity is AlarmSeverity.VIOLATION:
            if machine.state_name == "quiet":
                machine.accept("AlarmRaised")
            self.records.append(AlarmRecord(point.mnemonic, value, severity))
        elif machine.state_name in ("raised", "acknowledged"):
            machine.accept("AlarmCleared")
        return severity

    def acknowledge(self, mnemonic: str) -> None:
        self.alarms[mnemonic].accept("AlarmAcknowledge")

    def alarm_state(self, mnemonic: str) -> str:
        machine = self.alarms.get(mnemonic)
        return machine.state_name if machine else "quiet"

    def battery_alarm(self, fraction: float, warning_band: float = 0.05) -> AlarmSeverity:
        """``lowBatteryAlarm``: the state-of-charge fraction against the FDIR limit table's
        ``batteryLowFraction`` (TM-005: the ground alarms above the on-board trip)."""
        return check_limits(fraction, LIMIT_TABLE["batteryLowFraction"], 1.0, warning_band)

    def trend(self, mnemonic: str, current: float, rate_per_day: float, days: float) -> TrendProduct:
        return TrendProduct(mnemonic, linear_trend(current, rate_per_day, days), days)

    def trends(self, days: float, rates_per_day: dict[str, float]) -> list[TrendProduct]:
        """TM-006: every housekeeping point is trended from its latest value; a point without a rate is
        projected flat."""
        return [self.trend(p.mnemonic, self.latest.get(p.mnemonic, 0.0), rates_per_day.get(p.mnemonic, 0.0), days)
                for p in telemetry.TELEMETRY_POINTS if p.kind == "housekeeping"]
