"""Meridian Warden (TethysGroundSoftware::FlightRuleChecker) against runs/sw-ground-sequencer-check.txt
and the model's CheckFlightRules through the client. Rows: TM-003 sequenceClearance, FR-001 … FR-004."""

import re

import pytest
from conftest import run_text

from argent_tables import ground, parameters
from meridian.warden.checker import PlannedSequence, SequenceVerdict, UplinkExchange, check_flight_rules

EXCHANGES = {"nominalUplink": "thrustArcInCoast", "relayConflictUplink": "thrustArcDuringRelay"}


def planned_from_model(bridge, name: str) -> PlannedSequence:
    base = f"TethysGroundSoftware::{name}"
    q = lambda attr: bridge.eval(f"{base}.{attr}")  # noqa: E731
    from meridian.modelbridge import magnitude
    return PlannedSequence(int(q("sequenceId")), str(q("plannedMode")).rsplit("::", 1)[-1], bool(q("thrusting")), bool(q("relayPassActive")),
                           float(magnitude(bridge.eval(f"{base}.rangeToTarget / 1 [m]", context="TethysGroundSoftware"))), bool(q("approachAuthorised")),
                           float(magnitude(bridge.eval(f"{base}.sunAngle / 1 ['°']", context="TethysGroundSoftware"))), bool(q("coverOpen")), float(q("stateOfCharge")))


def pinned(exchange: str) -> dict[str, str]:
    """The pinned run's verdict, reason, released and loadsAccepted for one exchange."""
    text = run_text("sw-ground-sequencer-check")
    out = {}
    for key in ("check.verdict", "check.reason", "checker.released", "flight.loadsAccepted"):
        m = re.search(rf"TethysGroundSoftware::{exchange}\.(?:checker\.)?{re.escape(key)}\n\s*= (.*)", text)
        assert m, f"{exchange}.{key} not in the pinned run"
        out[key] = m.group(1).strip()
    return out


@pytest.mark.parametrize("exchange", sorted(EXCHANGES))
def test_exchange_matches_the_pinned_run(bridge, exchange):
    candidate = planned_from_model(bridge, EXCHANGES[exchange])
    ex = UplinkExchange()
    result = ex.run(candidate)
    want = pinned(exchange)
    assert result.verdict.name.lower() == want["check.verdict"].rsplit("::", 1)[-1].lower()
    assert result.reason == want["check.reason"].strip('"')
    assert ex.checker.released == int(want["checker.released"])
    assert ex.flight.loads_accepted == int(want["flight.loadsAccepted"])


@pytest.mark.parametrize("exchange", sorted(EXCHANGES))
def test_rules_agree_with_the_model_calc(bridge, exchange):
    """CheckFlightRules invoked through the client with the checker's own limits."""
    c = planned_from_model(bridge, EXCHANGES[exchange])
    rules, flight_mode = check_flight_rules(c)
    lim = ground.CHECK_LIMITS
    call = (f"CheckFlightRules({str(c.thrusting).lower()}, {str(c.relay_pass_active).lower()}, {c.range_to_target_m!r} [m], {str(c.approach_authorised).lower()}, "
            f"{c.sun_angle_deg!r} ['°'], {str(c.cover_open).lower()}, {c.state_of_charge!r}, TugMode::{c.planned_mode}, "
            f"{lim['keepOutRadius'].value!r} [m], {lim['exclusionHalfAngle'].value!r} ['°'], {lim['stateOfChargeFloor'].value!r})")
    assert bridge.eval(call, context="TethysGroundSoftware")[0] == (all(rules.values()) and flight_mode)


def test_rules_come_from_the_model_table():
    assert [r.id for r in ground.FLIGHT_RULES] == ["FR-001", "FR-002", "FR-003", "FR-004"]
    assert ground.FLIGHT_RULES_BY_ID["FR-002"].parameters[0].value == ground.CHECK_LIMITS["keepOutRadius"].value == 500.0
    assert [s.sequence_id for s in ground.ON_BOARD_SEQUENCES] == list(ground.STORED_SEQUENCES)


def test_each_rule_refuses_with_its_own_reason():
    base = PlannedSequence(1, "thrust", True, False, 1.0e9, False, 90.0, False, 0.95)
    cases = {"FR-001": base.__class__(**{**base.__dict__, "relay_pass_active": True}),
             "FR-002": base.__class__(**{**base.__dict__, "range_to_target_m": 100.0}),
             "FR-003": base.__class__(**{**base.__dict__, "sun_angle_deg": 10.0, "cover_open": True}),
             "FR-004": base.__class__(**{**base.__dict__, "state_of_charge": 0.3})}
    for k, (rule, c) in enumerate(cases.items()):
        r = UplinkExchange().run(c)
        assert r.verdict is SequenceVerdict.REFUSED and r.reason == ground.CHECK_REASONS[k] and r.reason.startswith(rule)
    r = UplinkExchange().run(PlannedSequence(1, "launch", False, False, 1e9, False, 90.0, False, 0.95))
    assert r.reason == "planned mode is not a flight mode"
    r = UplinkExchange().run(PlannedSequence(9, "thrust", False, False, 1e9, False, 90.0, False, 0.95))
    assert r.reason == "sequence not stored on board"


def test_tm003_floor_no_lower_than_the_on_board_trip():
    """TM-003 sequenceClearance: the ground's state-of-charge floor is at or above the FDIR trip."""
    trip = next(r.value for r in parameters.LIMIT_TABLE if r.name == "batteryLowFraction")
    assert ground.CHECK_LIMITS["stateOfChargeFloor"].value >= trip
