"""``TethysGroundSoftware::CommandBuilder`` (Meridian Forge): every command is built from the flight
dictionary (``argent_tables.commands``) and validated as ``ValidateCommand`` does, in its order —
mnemonic known, argument in range, mode allowed, approvals sufficient — before it is packed as a
command packet for the uplink queue. Hazardous commands wait for a second signature.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from argent_tables import commands, enums, packets
from argent_tables.ground import COMPONENTS_BY_PATH, CommandVerdict, DecisionAuthority

from .. import ccsds

MODEL_PART = "TethysGroundSoftware::meridianOperationsSuite.moc.commandBuilder"
MODEL_DEFINITION = "TethysGroundSoftware::CommandBuilder"
REQUIRED_APPROVALS = 2


@dataclass(frozen=True)
class CommandRequest:
    """``TethysGroundSoftware::CommandRequest``: a command as the operator builds it."""

    mnemonic: str
    argument_value: float
    mode_at_execution: str
    approvals: int = 0
    argument: str | None = None


@dataclass(frozen=True)
class Validation:
    """The outcome of ``ValidateCommand``: the verdict and each check behind it."""

    request: CommandRequest
    verdict: CommandVerdict
    opcode_known: bool
    argument_in_range: bool
    mode_allowed: bool
    approvals_sufficient: bool
    command: commands.Command | None = None


@dataclass
class CommandBuilder:
    """Meridian Forge. Table-driven: the dictionary is ``argent_tables.commands``; the verdict order is
    the model's ``ValidateCommand``."""

    second_approver: DecisionAuthority = DecisionAuthority.MISSION_MANAGER
    uplink_queue: list[bytes] = field(default_factory=list)
    model = COMPONENTS_BY_PATH["moc.commandBuilder"]

    @property
    def product_name(self) -> str:
        return self.model.product_name

    @property
    def dictionary_command_count(self) -> int:
        return commands.COMMAND_COUNT

    @property
    def hazardous_command_count(self) -> int:
        return commands.HAZARDOUS_COMMAND_COUNT

    @staticmethod
    def argument_definition(command: commands.Command, name: str | None) -> commands.CommandArgument | None:
        if name is None:
            return command.arguments[-1] if command.arguments else None
        return next((a for a in command.arguments if a.name == name), None)

    def validate(self, request: CommandRequest) -> Validation:
        """``ValidateCommand`` over the dictionary row the mnemonic names."""
        command = commands.COMMANDS_BY_MNEMONIC.get(request.mnemonic)
        opcode_known = command is not None
        argument = self.argument_definition(command, request.argument) if command else None
        if argument is None:
            argument_in_range = command is not None and not command.arguments
        else:
            lo = argument.minimum if argument.minimum is not None else float("-inf")
            hi = argument.maximum if argument.maximum is not None else float("inf")
            argument_in_range = lo <= request.argument_value <= hi
        mode_allowed = command is not None and request.mode_at_execution in command.allowed_modes
        approvals_sufficient = command is not None and (not command.hazardous or request.approvals >= REQUIRED_APPROVALS)
        if not opcode_known:
            verdict = CommandVerdict.UNKNOWN_OPCODE
        elif not argument_in_range:
            verdict = CommandVerdict.ARGUMENT_OUT_OF_RANGE
        elif not mode_allowed:
            verdict = CommandVerdict.MODE_NOT_ALLOWED
        elif not approvals_sufficient:
            verdict = CommandVerdict.AWAITING_SECOND_APPROVAL
        else:
            verdict = CommandVerdict.ACCEPTED
        return Validation(request, verdict, opcode_known, argument_in_range, mode_allowed, approvals_sufficient, command)

    def build(self, request: CommandRequest, sequence_count: int = 0) -> bytes:
        """The command packet of an accepted request: a CCSDS command packet whose data field is the
        opcode (16 bits) followed by the arguments at their dictionary widths; refused requests raise."""
        validation = self.validate(request)
        if validation.verdict is not CommandVerdict.ACCEPTED:
            raise PermissionError(f"{request.mnemonic}: {validation.verdict.name}")
        packet = pack_command(validation.command, {(request.argument or validation.command.arguments[-1].name if validation.command.arguments else ""): request.argument_value}, sequence_count)
        self.uplink_queue.append(packet)
        return packet


def pack_command(command: commands.Command, values: dict[str, float], sequence_count: int = 0) -> bytes:
    """A command packet from a dictionary row: primary header (type 1, no secondary header), then
    the 16-bit opcode and the arguments in dictionary order at their widths."""
    width = 16 + command.argument_bits
    data_octets = (width + 7) // 8
    buf = bytearray(ccsds.PRIMARY_HEADER_BITS // 8 + data_octets)
    header = ccsds.PrimaryHeader(apid=command.apid, sequence_count=sequence_count, data_length=data_octets - 1,
                                 packet_type=ccsds.COMMAND_TYPE, secondary_header=False)
    buf[: ccsds.PRIMARY_HEADER_BITS // 8] = header.pack()
    offset = ccsds.PRIMARY_HEADER_BITS
    ccsds._put(buf, offset, 16, command.opcode)
    offset += 16
    for a in command.arguments:
        value = values.get(a.name, a.minimum or 0.0)
        raw = argument_raw(a, value)
        ccsds._put(buf, offset, a.width_bits, raw)
        offset += a.width_bits
    return bytes(buf)


def argument_raw(argument: commands.CommandArgument, value: float) -> int:
    """An argument's raw count: integers as they are, reals scaled over the dictionary range."""
    full = (1 << argument.width_bits) - 1
    if argument.value_type.endswith(("Natural", "Integer", "Boolean")) or argument.minimum is None or argument.maximum is None:
        return min(full, max(0, int(round(value))))
    span = argument.maximum - argument.minimum
    return min(full, max(0, int(round((value - argument.minimum) / span * full)))) if span > 0 else 0


def opcode_of(packet: bytes) -> int:
    return ccsds._get(packet, ccsds.PRIMARY_HEADER_BITS, 16)


__all__ = ["CommandBuilder", "CommandRequest", "CommandVerdict", "Validation", "pack_command", "argument_raw", "opcode_of", "enums", "packets"]
