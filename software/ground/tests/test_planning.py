"""Meridian Almanac, Vault, Compass and Ledger against runs/sw-ground-structure.txt and the model.
Rows: TM-008 passPlanningVolume, TM-009 archiveRetention, TM-010 anomalyDisposition, TM-011 proximityGoNoGo,
TF-011 busReserve, TS-123 powerBudgetCloses, SA-001/SA-002 releaseReadiness."""

from conftest import number

from argent_tables import ground
from meridian.almanac.planner import PassPlanner
from meridian.compass.planner import ProximityPlanner, RelativeNavigationProduct
from meridian.ledger.tracker import AnomalyDisposition, AnomalyTracker, DecisionAuthority
from meridian.modelbridge import magnitude
from meridian.vault.archive import DataArchive

M = "TethysGroundSoftware::meridianOperationsSuite"
SUBJ = {"subject": M}


def test_almanac_visibility_and_volume(structure, bridge):
    planner = PassPlanner()
    sub = float(magnitude(bridge.eval(f"{M}.moc.passPlanner.calderaSeesTheTug.subPointLongitude / 1 ['°']", context="TethysGroundSoftware", **SUBJ)))
    assert planner.sees("caldera", sub) is (structure[f"{M}.moc.passPlanner.calderaSeesTheTug.visible"] == "[true]")
    assert planner.sees("tableland", sub) is (structure[f"{M}.moc.passPlanner.tablelandSeesTheTug.visible"] == "[true]")
    day = planner.plan_day()
    assert day.volume("calderaPass") == number(structure[f"{M}.moc.passPlanner.plannedDay.calderaVolume.volumeBits"])
    assert day.imagery_fits is (structure[f"{M}.moc.passPlanner.plannedDay.imageryFits"] == "true")
    assert bridge.eval(f"StationVisible(meridian.caldera.longitude, {sub!r} ['°'], {planner.visibility_half_width_deg!r} ['°'])", context="TethysGroundSoftware")[0] is True
    assert float(magnitude(bridge.eval("PassVolume(argentSoftwareIcds.spaceLinkProfile.proximityOperationsRates, 8.0, 300.0)", context="TethysGroundSoftware"))) == day.volume("calderaPass")


def test_tm008_daily_volume_downlinks_within_the_plan():
    day = PassPlanner().plan_day()
    assert all(p.fits for p in day.passes) and sum(p.allocated_bits for p in day.passes) <= sum(p.volume_bits for p in day.passes)


def test_vault_distributed_levels_and_retention(structure):
    vault = DataArchive()
    assert vault.distributed_levels == int(number(structure[f"{M}.sds.dataArchive.distributedLevels"]))
    assert len(vault.rules) == 4 and not next(r for r in vault.rules if r.level == "l0").distributed
    entry = vault.ingest("frames", "l0", b"\x00" * 1115)
    assert not entry.distributed and entry.retention_days == 3650.0 and vault.verify(entry, b"\x00" * 1115) and vault.checksum_width == 32


def test_compass_checklist_go(structure):
    compass = ProximityPlanner()
    ck = compass.checklist(RelativeNavigationProduct.from_table("standoff"), RelativeNavigationProduct.from_table("finalApproach"), True)
    assert ck.items_total == ground.CHECKLIST_ITEMS_TOTAL == 12 and ck.items_go == ground.CHECKLIST_ITEMS_GO
    assert ck.go is (structure[f"{M}.moc.proximityPlanner.checklist.go"] == "true")
    assert compass.keep_out_kept(RelativeNavigationProduct.from_table("standoff"), False)
    assert not compass.keep_out_kept(RelativeNavigationProduct.from_table("finalApproach"), False)
    assert compass.abort_criteria_hold(RelativeNavigationProduct.from_table("finalApproach"))


def test_tm011_keep_out_against_ranging_and_release_gate_item(bridge):
    """TM-011 proximityGoNoGo: keep-out radius ≥ 100 × ranging accuracy, exclusion half-angle > 0; and the
    open release gate shows as a no-go item when it is asked for."""
    ranging = float(magnitude(bridge.eval("TethysStakeholders::missionMeasures.rangingAccuracy / 1 [m]", context="TethysGroundSoftware")))
    assert ProximityPlanner().keep_out_radius_m >= 100.0 * ranging
    assert ground.CHECK_LIMITS["exclusionHalfAngle"].value > 0
    open_gate = not bool(bridge.eval("TethysSoftwareAssurance::assurancePlan.levelA.allComplete"))
    ck = ProximityPlanner().checklist(RelativeNavigationProduct.from_table("standoff"), RelativeNavigationProduct.from_table("finalApproach"), True, release_gate_open=open_gate)
    assert open_gate and not ck.go and ck.items_total == 13


def test_ledger_surfaces_the_programme_gates_as_modelled(bridge):
    """TF-011 (36 of 64 slots vs 32), the thrusting power margin (≈ 11.9 % vs 15 %) and SA-001/SA-002
    (level-A independent V&V in progress) are open/failing exactly as the model evaluates them."""
    bus = AnomalyTracker.bus_reserve_gate()
    assert bus.status == "violated" and "36 of 64" in bus.detail and bool(bridge.eval("TethysFlightTiming::softwareBusBudget.busCloses")) is False
    margin = float(bridge.eval("TethysBudgets::powerBudget.thrustingMargin"))
    policy = float(bridge.eval("TethysMarginPolicy::activePolicy.systemMargin"))
    power = AnomalyTracker.power_margin_gate(margin, policy)
    assert power.status == "violated" and 0.11 < margin < 0.13 and policy == 0.15
    release = AnomalyTracker.release_gate(bool(bridge.eval("TethysSoftwareAssurance::assurancePlan.levelA.allComplete")),
                                          str(bridge.eval("TethysSoftwareAssurance::assurancePlan.levelA.independentVv.status")).rsplit("::", 1)[-1])
    assert release.status == "open" and "inProgress" in release.detail


def test_tm010_safe_mode_recovery_needs_the_flight_director(bridge):
    tracker = AnomalyTracker()
    assert tracker.fault_event_count == 65
    trigger = bridge.eval("TethysOperations::thrusterFailureResponse.triggerMnemonic")
    a = tracker.open(trigger, safe_mode_recovery=True)
    tracker.triage(a, "CON-001")
    tracker.assign(a)
    assert not tracker.disposition(a, AnomalyDisposition.PROCEDURE_CHANGE, DecisionAuthority.ANOMALY_BOARD) and a.state == "investigating"
    assert tracker.disposition(a, AnomalyDisposition.PROCEDURE_CHANGE, DecisionAuthority.FLIGHT_DIRECTOR) and a.state == "closed"
    assert a.trigger_mnemonic == "SEP_DISCHARGE_I"
