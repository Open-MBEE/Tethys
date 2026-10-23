"""``TethysGroundSoftware::FlightRuleChecker`` (Meridian Warden): every planned sequence is loaded
against the on-board sequence store, checked against the flight rules FR-001 to FR-004 of
``TethysOperations`` and either released to the uplink queue as a ``LoadSequence`` or refused with
the model's reason (``GroundSequenceCheck``).

The rules are the generated ``argent_tables.ground.FLIGHT_RULES`` rows — each rule's constraint
expression is evaluated over the planned flight state — and the checker's constants
(``STORED_SEQUENCES``, ``CHECK_LIMITS``, ``FLIGHT_MODES``, ``CHECK_REASONS``) are the model's.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from argent_tables import ground
from argent_tables.ground import SequenceVerdict

from .. import ccsds

MODEL_PART = "TethysGroundSoftware::meridianOperationsSuite.moc.sequencer"
MODEL_DEFINITION = "TethysGroundSoftware::FlightRuleChecker"
LOAD_SEQUENCE_APID = 1
LOAD_SEQUENCE_SEQUENCE_ID_BITS = 16


@dataclass(frozen=True)
class PlannedSequence:
    """``TethysGroundSoftware::PlannedSequence``: the sequence and the flight state it is planned into."""

    sequence_id: int
    planned_mode: str
    thrusting: bool
    relay_pass_active: bool
    range_to_target_m: float
    approach_authorised: bool
    sun_angle_deg: float
    cover_open: bool
    state_of_charge: float


@dataclass(frozen=True)
class SequenceCheck:
    """The result of ``GroundSequenceCheck``: verdict, reason and every rule's own outcome."""

    verdict: SequenceVerdict
    reason: str
    loaded: bool
    rules: dict[str, bool]
    mode_is_flight_mode: bool


def _evaluate(expression: str, bindings: dict) -> bool:
    """Evaluate a flight-rule constraint body (``not (a and b)``, ``x >= y or z``) over bindings.
    The grammar is the subset the model's constraint definitions use: names, numbers, comparisons,
    ``and``/``or``/``not`` and parentheses — evaluated without ``eval``."""
    import ast

    tree = ast.parse(expression, mode="eval")

    def value(node):
        if isinstance(node, ast.Expression):
            return value(node.body)
        if isinstance(node, ast.Name):
            return bindings[node.id]
        if isinstance(node, ast.Constant):
            return node.value
        if isinstance(node, ast.UnaryOp) and isinstance(node.op, ast.Not):
            return not value(node.operand)
        if isinstance(node, ast.UnaryOp) and isinstance(node.op, ast.USub):
            return -value(node.operand)
        if isinstance(node, ast.BoolOp):
            vals = [value(v) for v in node.values]
            return all(vals) if isinstance(node.op, ast.And) else any(vals)
        if isinstance(node, ast.Compare):
            left = value(node.left)
            for op, comp in zip(node.ops, node.comparators):
                right = value(comp)
                ok = {ast.GtE: left >= right, ast.LtE: left <= right, ast.Gt: left > right, ast.Lt: left < right,
                      ast.Eq: left == right, ast.NotEq: left != right}[type(op)]
                if not ok:
                    return False
                left = right
            return True
        raise ValueError(f"unsupported construct in rule expression: {ast.dump(node)}")

    return bool(value(tree))


def check_flight_rules(candidate: PlannedSequence) -> tuple[dict[str, bool], bool]:
    """``CheckFlightRules``: each FR- rule's constraint over the planned state, and whether the planned
    mode is a flight mode. The limits are the checker's (``CHECK_LIMITS``), not the rules' own text."""
    limits = {k: q.value for k, q in ground.CHECK_LIMITS.items()}
    bindings = {
        "thrusting": candidate.thrusting, "relayActive": candidate.relay_pass_active, "relayPassActive": candidate.relay_pass_active,
        "rangeToTarget": candidate.range_to_target_m, "keepOutRadius": limits["keepOutRadius"], "approachAuthorised": candidate.approach_authorised,
        "sunAngle": candidate.sun_angle_deg, "exclusionHalfAngle": limits["exclusionHalfAngle"], "coverOpen": candidate.cover_open,
        "stateOfCharge": candidate.state_of_charge, "stateOfChargeFloor": limits["stateOfChargeFloor"],
    }
    results = {}
    for rule in ground.FLIGHT_RULES:
        expression = rule.expression
        for p in rule.parameters:
            if p.name in limits:
                bindings[p.name] = limits[p.name]
        if rule.id == "FR-004":
            expression = "stateOfCharge >= stateOfChargeFloor"
        results[rule.id] = _evaluate(expression, bindings)
    return results, candidate.planned_mode in ground.FLIGHT_MODES


def ground_sequence_check(candidate: PlannedSequence, stored: tuple[int, ...] = ground.STORED_SEQUENCES) -> SequenceCheck:
    """``GroundSequenceCheck``: load, check the rules, clear or refuse with the first violated rule's reason."""
    loaded = candidate.sequence_id in stored
    rules, flight_mode = check_flight_rules(candidate)
    all_passed = all(rules.values()) and flight_mode
    if loaded and all_passed:
        return SequenceCheck(SequenceVerdict.CLEARED, "cleared for uplink", loaded, rules, flight_mode)
    if not loaded:
        return SequenceCheck(SequenceVerdict.REFUSED, "sequence not stored on board", loaded, rules, flight_mode)
    for k, rule in enumerate(ground.FLIGHT_RULES):
        if not rules[rule.id]:
            return SequenceCheck(SequenceVerdict.REFUSED, ground.CHECK_REASONS[k], loaded, rules, flight_mode)
    return SequenceCheck(SequenceVerdict.REFUSED, ground.CHECK_REASONS[len(ground.FLIGHT_RULES)], loaded, rules, flight_mode)


def load_sequence_packet(sequence_id: int, sequence_count: int = 0) -> bytes:
    """The ``LoadSequence`` command the checker sends via its uplink queue."""
    data_octets = LOAD_SEQUENCE_SEQUENCE_ID_BITS // 8
    buf = bytearray(ccsds.PRIMARY_HEADER_BITS // 8 + data_octets)
    buf[: ccsds.PRIMARY_HEADER_BITS // 8] = ccsds.PrimaryHeader(apid=LOAD_SEQUENCE_APID, sequence_count=sequence_count, data_length=data_octets - 1,
                                                                packet_type=ccsds.COMMAND_TYPE, secondary_header=False).pack()
    ccsds._put(buf, ccsds.PRIMARY_HEADER_BITS, LOAD_SEQUENCE_SEQUENCE_ID_BITS, sequence_id)
    return bytes(buf)


@dataclass
class FlightRuleChecker:
    """Meridian Warden: ``check`` then ``release`` — a cleared sequence is sent as ``LoadSequence`` and
    ``released`` counts it; a refused one is held."""

    stored_sequences: tuple[int, ...] = ground.STORED_SEQUENCES
    uplink_queue: list[bytes] = field(default_factory=list)
    released: int = 0
    last_check: SequenceCheck | None = None
    model = ground.COMPONENTS_BY_PATH["moc.sequencer"]

    @property
    def product_name(self) -> str:
        return self.model.product_name

    def check(self, candidate: PlannedSequence) -> SequenceCheck:
        self.last_check = ground_sequence_check(candidate, self.stored_sequences)
        return self.last_check

    def release(self, candidate: PlannedSequence) -> SequenceCheck:
        result = self.check(candidate)
        if result.verdict is SequenceVerdict.CLEARED:
            self.uplink_queue.append(load_sequence_packet(candidate.sequence_id, self.released))
            self.released += 1
        return result


@dataclass
class SequenceStoreStandIn:
    """``TethysGroundSoftware::SequenceStoreStandIn``: the flight side of the exchange, counting the
    ``LoadSequence`` commands it accepts."""

    loads_accepted: int = 0

    def accept(self, packet: bytes) -> bool:
        header = ccsds.PrimaryHeader.unpack(packet)
        if header.packet_type == ccsds.COMMAND_TYPE and header.apid == LOAD_SEQUENCE_APID:
            self.loads_accepted += 1
            return True
        return False


@dataclass
class UplinkExchange:
    """``TethysGroundSoftware::UplinkExchange``: the checker's uplink queue to the flight stand-in."""

    checker: FlightRuleChecker = field(default_factory=FlightRuleChecker)
    flight: SequenceStoreStandIn = field(default_factory=SequenceStoreStandIn)

    def run(self, candidate: PlannedSequence) -> SequenceCheck:
        result = self.checker.release(candidate)
        for packet in self.checker.uplink_queue:
            self.flight.accept(packet)
        self.checker.uplink_queue.clear()
        return result
