"""Meridian Sextant (TethysGroundSoftware::FlightDynamicsTool): every calculation through the pinned
client against the pinned sysml-grpc, compared with runs/sw-ground-structure.txt; the invocation
time is recorded in build/software/ground-model-timings.txt. Row: TM-007 flightDynamicsProducts."""

import time

from conftest import number

from meridian.sextant.tool import FlightDynamicsTool

S = "TethysGroundSoftware::meridianOperationsSuite.fdf.flightDynamicsTool"


def test_orbit_determination_and_return_arc_via_the_model(structure, bridge):
    tool = FlightDynamicsTool(bridge)
    t0 = time.monotonic()
    od = tool.orbit_determination(4.5, 21)
    ledger = tool.manoeuvre_design(1800.0, 1.4e6, 2.75e4, 4.0e-5)
    elapsed = time.monotonic() - t0
    assert abs(od - number(structure[f"{S}.argentOd.positionUncertainty"])) < 1e-12
    assert ledger.arc_duration_s == number(structure[f"{S}.returnArc.arcDuration"])
    assert abs(ledger.xenon_committed_kg - number(structure[f"{S}.returnArc.xenon"])) < 1e-6
    assert tool.argent_od() == od and tool.return_arc() == (ledger.arc_duration_s, ledger.xenon_committed_kg)
    print(f"\nsextant: two model calculations in {elapsed:.3f} s")
    assert elapsed < 30.0


def test_tm007_od_arc_within_autonomy(bridge):
    from meridian.modelbridge import magnitude
    arc = float(magnitude(bridge.eval(f"{S}.odArcLength / 1 [d]", context="TethysGroundSoftware", subject="TethysGroundSoftware::meridianOperationsSuite")))
    autonomy = float(magnitude(bridge.eval("TethysRequirementsL2::autonomousSurvival.autonomyDuration / 1 [d]", context="TethysGroundSoftware")))
    assert arc <= autonomy
