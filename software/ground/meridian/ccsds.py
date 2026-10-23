"""CCSDS Space Packets as the flight dictionary lays them out (``TethysFlightDictionary``).

The byte layout of every packet is determined by the generated tables alone: the primary header
widths (``packets.PRIMARY_HEADER``), the time-code secondary header (``packets.TIME_CODE``) and
each field's order, offset and width (``Packet.fields``). Field values are unsigned integers of
the field's width, most significant bit first, packed contiguously from ``offset_bits``.
"""

from __future__ import annotations

from dataclasses import dataclass

from argent_tables import packets, telemetry

HEADER = packets.PRIMARY_HEADER
PRIMARY_HEADER_BITS = sum(HEADER.values())
TIME_CODE_BITS = packets.TIME_CODE["coarseWidth"] + packets.TIME_CODE["fineWidth"]
PACKET_VERSION = 0
TELEMETRY_TYPE = 0
COMMAND_TYPE = 1
SEQUENCE_FLAGS_UNSEGMENTED = 3


class LayoutError(ValueError):
    """A packet whose dictionary layout does not add up, or bytes that do not fit it."""


def _put(buf: bytearray, offset: int, width: int, value: int) -> None:
    if value < 0 or value >= 1 << width:
        raise ValueError(f"value {value} does not fit {width} bits")
    for k in range(width):
        bit = (value >> (width - 1 - k)) & 1
        pos = offset + k
        if bit:
            buf[pos >> 3] |= 0x80 >> (pos & 7)
        else:
            buf[pos >> 3] &= ~(0x80 >> (pos & 7)) & 0xFF


def _get(data: bytes, offset: int, width: int) -> int:
    value = 0
    for k in range(width):
        pos = offset + k
        value = (value << 1) | ((data[pos >> 3] >> (7 - (pos & 7))) & 1)
    return value


@dataclass(frozen=True)
class PrimaryHeader:
    """The six-octet primary header of CCSDS Space Packet Protocol, widths from the model."""

    apid: int
    sequence_count: int
    data_length: int
    version: int = PACKET_VERSION
    packet_type: int = TELEMETRY_TYPE
    secondary_header: bool = True
    sequence_flags: int = SEQUENCE_FLAGS_UNSEGMENTED

    def pack(self) -> bytes:
        buf = bytearray(PRIMARY_HEADER_BITS // 8)
        offset = 0
        for name, value in (("versionWidth", self.version), ("typeWidth", self.packet_type),
                            ("secondaryHeaderFlagWidth", int(self.secondary_header)), ("apidWidth", self.apid),
                            ("sequenceFlagsWidth", self.sequence_flags), ("sequenceCountWidth", self.sequence_count),
                            ("dataLengthWidth", self.data_length)):
            _put(buf, offset, HEADER[name], value)
            offset += HEADER[name]
        return bytes(buf)

    @classmethod
    def unpack(cls, data: bytes) -> "PrimaryHeader":
        if len(data) < PRIMARY_HEADER_BITS // 8:
            raise LayoutError("short primary header")
        values, offset = {}, 0
        for name in ("versionWidth", "typeWidth", "secondaryHeaderFlagWidth", "apidWidth", "sequenceFlagsWidth",
                     "sequenceCountWidth", "dataLengthWidth"):
            values[name] = _get(data, offset, HEADER[name])
            offset += HEADER[name]
        return cls(apid=values["apidWidth"], sequence_count=values["sequenceCountWidth"], data_length=values["dataLengthWidth"],
                   version=values["versionWidth"], packet_type=values["typeWidth"],
                   secondary_header=bool(values["secondaryHeaderFlagWidth"]), sequence_flags=values["sequenceFlagsWidth"])


@dataclass(frozen=True)
class TimeCode:
    """The unsegmented time code of ``TethysFlightDictionary::TethysTimeCode``: coarse seconds and a
    binary fraction since the dictionary epoch."""

    coarse: int
    fine: int = 0

    @property
    def seconds(self) -> float:
        return self.coarse + self.fine * packets.TIME_CODE["fineResolution"]

    @classmethod
    def from_seconds(cls, seconds: float) -> "TimeCode":
        coarse = int(seconds)
        fine = int(round((seconds - coarse) / packets.TIME_CODE["fineResolution"])) % (1 << packets.TIME_CODE["fineWidth"])
        return cls(coarse, fine)


def layout_consistent(packet: packets.Packet) -> bool:
    """``PacketDefinition::layoutConsistent``: header plus payload bits equal the length in octets,
    fields are contiguous from the header in order."""
    expected = packet.header_bits
    for f in sorted(packet.fields, key=lambda x: x.order):
        if f.offset_bits != expected:
            return False
        expected += f.width_bits
    return expected == packet.length_octets * 8 and packet.header_bits == PRIMARY_HEADER_BITS + TIME_CODE_BITS


def encode(packet: packets.Packet, raw: dict[str, int], time_code: TimeCode, sequence_count: int = 0) -> bytes:
    """One packet's bytes from raw field values keyed by point mnemonic."""
    if not layout_consistent(packet):
        raise LayoutError(f"{packet.mnemonic}: layout inconsistent with its length")
    buf = bytearray(packet.length_octets)
    header = PrimaryHeader(apid=packet.apid, sequence_count=sequence_count, data_length=packet.length_octets - PRIMARY_HEADER_BITS // 8 - 1)
    buf[: PRIMARY_HEADER_BITS // 8] = header.pack()
    _put(buf, PRIMARY_HEADER_BITS, packets.TIME_CODE["coarseWidth"], time_code.coarse)
    _put(buf, PRIMARY_HEADER_BITS + packets.TIME_CODE["coarseWidth"], packets.TIME_CODE["fineWidth"], time_code.fine)
    for f in packet.fields:
        _put(buf, f.offset_bits, f.width_bits, raw.get(f.point, 0))
    return bytes(buf)


@dataclass(frozen=True)
class DecodedPacket:
    packet: packets.Packet
    header: PrimaryHeader
    time_code: TimeCode
    raw: dict[str, int]


def decode(data: bytes) -> DecodedPacket:
    """Decommutate one packet by its APID: the dictionary packet it is, its time and raw fields."""
    header = PrimaryHeader.unpack(data)
    packet = packets.PACKETS_BY_APID.get(header.apid)
    if packet is None:
        raise LayoutError(f"APID {header.apid} is not a dictionary packet")
    if len(data) != packet.length_octets:
        raise LayoutError(f"{packet.mnemonic}: {len(data)} octets, dictionary says {packet.length_octets}")
    if header.data_length != packet.length_octets - PRIMARY_HEADER_BITS // 8 - 1:
        raise LayoutError(f"{packet.mnemonic}: header length field disagrees with the dictionary")
    tc = TimeCode(_get(data, PRIMARY_HEADER_BITS, packets.TIME_CODE["coarseWidth"]),
                  _get(data, PRIMARY_HEADER_BITS + packets.TIME_CODE["coarseWidth"], packets.TIME_CODE["fineWidth"]))
    raw = {f.point: _get(data, f.offset_bits, f.width_bits) for f in packet.fields}
    return DecodedPacket(packet, header, tc, raw)


def calibration(point: telemetry.TelemetryPoint) -> tuple[float, float]:
    """``(scale, offset)`` of ``EngineeringUnits`` for a point: the red limits span the raw range
    (``red_low`` at raw 0, ``red_high`` at the width's maximum); a point without both limits is
    carried as its raw count."""
    if point.red_low is None or point.red_high is None or point.red_high <= point.red_low:
        return 1.0, 0.0
    full = (1 << point.width_bits) - 1
    return (point.red_high - point.red_low) / full, point.red_low


def engineering_units(raw: int, scale: float, offset: float) -> float:
    """``TethysGroundSoftware::EngineeringUnits``: ``rawCount * scale + offset``."""
    return raw * scale + offset


def raw_count(point: telemetry.TelemetryPoint, value: float) -> int:
    scale, offset = calibration(point)
    full = (1 << point.width_bits) - 1
    return min(full, max(0, int(round((value - offset) / scale))))
