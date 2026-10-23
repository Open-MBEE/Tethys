"""``TethysGroundSoftware::FlightSoftwareInTheLoopSimulator`` (Meridian Mirror): the flight image on an
emulated flight computer. Here the simulated flight side is table-driven: it publishes every
dictionary packet at the per-mode rate set (``telemetry.sample_rate_hz``), accepts command packets
against the dictionary and the on-board sequence store, and keeps the mode the mode table allows.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from argent_tables import commands, ground, modes, packets, telemetry

from .. import ccsds
from ..forge.builder import opcode_of
from ..warden.checker import LOAD_SEQUENCE_APID
from .base import Simulator

MODEL_DEFINITION = "TethysGroundSoftware::FlightSoftwareInTheLoopSimulator"


def raw_pattern(point: telemetry.TelemetryPoint, order: int, seconds: float) -> int:
    """A deterministic raw count for a point: mid-range plus a slow ramp, so every packet decodes to
    in-limit engineering values and two beds agree byte for byte."""
    full = (1 << point.width_bits) - 1
    return (full // 2 + point.id * 7 + order * 13 + int(seconds)) % (full + 1)


@dataclass
class TelemetryStream:
    """The packets a mode produces over a span, each at its dictionary or housekeeping rate."""

    mode: str
    span_s: float
    start_s: float = 0.0

    def packets(self) -> list[tuple[float, bytes]]:
        out, counts = [], {}
        for p in packets.PACKETS:
            if modes.MODE_ROWS_BY_NAME[self.mode].rate_set is None:
                continue
            rate = telemetry.sample_rate_hz(telemetry.TELEMETRY_BY_MNEMONIC[p.fields[0].point], self.mode) if p.fields else p.rate_hz
            if not rate:
                continue
            t = self.start_s
            while t < self.start_s + self.span_s:
                raw = {f.point: raw_pattern(telemetry.TELEMETRY_BY_MNEMONIC[f.point], f.order, t) for f in p.fields}
                n = counts.get(p.apid, 0)
                out.append((t, ccsds.encode(p, raw, ccsds.TimeCode.from_seconds(t), n % (1 << packets.PRIMARY_HEADER["sequenceCountWidth"]))))
                counts[p.apid] = n + 1
                t += 1.0 / rate
        out.sort(key=lambda x: x[0])
        return out


@dataclass
class FlightSoftwareInTheLoopSimulator(Simulator):
    """Meridian Mirror."""

    path: str = "testBeds.trajectoryTool"
    mode: str = "coast"
    stored_sequences: tuple[int, ...] = ground.STORED_SEQUENCES
    loads_accepted: int = 0
    commands_accepted: list[int] = field(default_factory=list)
    commands_rejected: list[int] = field(default_factory=list)

    def stream(self, span_s: float) -> TelemetryStream:
        return TelemetryStream(self.mode, span_s)

    def accept(self, packet: bytes) -> bool:
        """The flight side's own refusal (TF-001 repeats TM-001): opcode known, mode allowed."""
        header = ccsds.PrimaryHeader.unpack(packet)
        if header.packet_type != ccsds.COMMAND_TYPE:
            return False
        if header.apid == LOAD_SEQUENCE_APID:
            self.loads_accepted += 1
            return True
        opcode = opcode_of(packet)
        command = commands.COMMANDS_BY_OPCODE.get(opcode)
        if command is None or self.mode not in command.allowed_modes:
            self.commands_rejected.append(opcode)
            return False
        self.commands_accepted.append(opcode)
        return True
