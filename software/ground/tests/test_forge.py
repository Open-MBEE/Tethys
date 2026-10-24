"""Meridian Forge (TethysGroundSoftware::CommandBuilder) against runs/sw-ground-structure.txt and the
model's ValidateCommand through the pinned client. Rows: TM-001 commandValidation, TM-002 hazardousApproval."""

import pytest
from conftest import literal, number

from argent_tables import commands
from meridian.forge.builder import CommandBuilder, CommandRequest, CommandVerdict, opcode_of

S = "TethysGroundSoftware::meridianOperationsSuite.moc.commandBuilder"
REQUESTS = {  # the model's planted requests (CommandBuilder::*Request) and the verdict calc each feeds
    "thrustArcVerdict": ("thrustArcRequest", "sepStartThrustArc", "throttle"),
    "thrustArcInCoastVerdict": ("thrustArcInCoastRequest", "sepStartThrustArc", "throttle"),
    "resetOneApprovalVerdict": ("resetWithOneApproval", "cdhResetProcessor", "confirmKey"),
    "resetKeyVerdict": ("resetKeyOutOfRange", "cdhResetProcessor", "confirmKey"),
    "misspelledVerdict": ("misspelledRequest", "sepStartThrustArc", "throttle"),
}


def request_from_model(bridge, name: str, argument: str) -> CommandRequest:
    base = f"TethysGroundSoftware::CommandBuilder::{name}"
    return CommandRequest(bridge.eval(f"{base}.mnemonic"), float(bridge.eval(f"{base}.argumentValue")),
                          str(bridge.eval(f"{base}.modeAtExecution")).rsplit("::", 1)[-1], int(bridge.eval(f"{base}.approvals")), argument)


@pytest.mark.parametrize("calc", sorted(REQUESTS))
def test_verdicts_as_planted(structure, bridge, calc):
    """Each pinned verdict (runs/sw-ground-structure.txt) for the model's own request inputs; the
    model's ValidateCommand, invoked through the client, is the second oracle."""
    request_name, command, argument = REQUESTS[calc]
    request = request_from_model(bridge, request_name, argument)
    verdict = CommandBuilder().validate(request).verdict
    assert verdict is CommandVerdict[_upper(literal(structure[f"{S}.{calc}.verdict"]))]
    model = bridge.eval(f"ValidateCommand(CommandBuilder::{request_name}, {command}, {command}.{argument})", context="TethysGroundSoftware")
    assert _upper(str(model[0].name).rsplit("::", 1)[-1]) == verdict.name


def _upper(camel: str) -> str:
    import re
    return re.sub(r"(?<=[a-z0-9])(?=[A-Z])", "_", camel).upper()


def test_dictionary_counts(structure):
    forge = CommandBuilder()
    assert forge.dictionary_command_count == int(number(structure[f"{S}.dictionaryCommandCount"]))
    assert forge.hazardous_command_count == commands.HAZARDOUS_COMMAND_COUNT == 51


def test_tm001_every_dictionary_command_has_a_mode_precondition_and_unique_opcode():
    """TM-001 commandValidation: the refusal is only as good as the dictionary's properties."""
    opcodes = [c.opcode for c in commands.COMMANDS]
    assert len(set(opcodes)) == len(opcodes)
    assert len({c.mnemonic for c in commands.COMMANDS}) == len(opcodes)
    assert all(c.allowed_modes for c in commands.COMMANDS)
    assert all(a.minimum is None or a.maximum is None or a.minimum <= a.maximum for c in commands.COMMANDS for a in c.arguments)


def test_tm002_every_hazardous_command_waits_for_the_second_approval():
    """TM-002 hazardousApproval: one approval holds every dictionary-hazardous command."""
    forge = CommandBuilder()
    held = 0
    for c in commands.COMMANDS:
        if not c.hazardous:
            continue
        arg = c.arguments[-1] if c.arguments else None
        value = arg.minimum if arg and arg.minimum is not None else 0.0
        v = forge.validate(CommandRequest(c.mnemonic, value, c.allowed_modes[0], 1, arg.name if arg else None)).verdict
        assert v is CommandVerdict.AWAITING_SECOND_APPROVAL, c.mnemonic
        held += 1
    assert held == commands.HAZARDOUS_COMMAND_COUNT


def test_build_packs_the_opcode_and_queues_it():
    forge = CommandBuilder()
    packet = forge.build(CommandRequest("CDH_NOOP", 0.0, "coast", 0))
    assert opcode_of(packet) == commands.COMMANDS_BY_MNEMONIC["CDH_NOOP"].opcode
    assert forge.uplink_queue == [packet]
    with pytest.raises(PermissionError):
        forge.build(CommandRequest("CDH_RESET_PROCESSOR", 1.0, "coast", 1, "confirmKey"))
