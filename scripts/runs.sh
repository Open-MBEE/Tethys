#!/bin/sh
# Run every documented command over the model; `record` writes runs/, `check` diffs against it.
set -eu
mode=${1:-check}
SYSML=${SYSML:-build/opensysml/sysml}
MODEL=$(ls model/*.sysml | sort | tr '\n' ' ')
out=build/runs; rm -rf "$out"; mkdir -p "$out"
run() { name=$1; shift; "$@" > "$out/$name.txt" 2>&1 || echo "exit $?" >> "$out/$name.txt"; }
run validate $SYSML -validate $MODEL
run house-rules $SYSML -validate -self-check-package TethysHouseRules $MODEL
run instantiate-system $SYSML -instantiate TethysSystem::tethysSystem $MODEL
run environment-calcs $SYSML -calc "TethysEnvironment::SolarFlux(1.034)" -calc "TethysEnvironment::SolarFlux(1.003)" -calc "TethysEnvironment::CircularSpeed(398600.4418, 6578.137)" -calc "TethysEnvironment::EscapeSpeed(398600.4418, 6578.137)" -calc "TethysEnvironment::OrbitalPeriod(1.32712440018e11, 154.68e6)" -calc "TethysEnvironment::OneWayLightTime(60.0e6)" -calc "TethysEnvironment::SphereMass(6.8, 2200.0)" -calc "TethysEnvironment::SepThrust(40000.0, 2900.0, 0.65)" -calc "TethysEnvironment::NaturalLog(2.0)" -calc "TethysEnvironment::RocketEquationDeltaV(2900.0, 12600.0, 6000.0)" $MODEL
# Work packages append their commands here; keep one `run <name> …` per line.
run wpc-inspector-calcs $SYSML -calc "TethysInspectorDetail::ForcedMotionDeltaVPerOrbit(50.0, 7200.0)" -calc "TethysInspectorDetail::CampaignDeltaV(12.0, 0.274, 5.0e-8, 7.0e5)" -calc "TethysInspectorDetail::ColdGasDeltaV(65.0, 24.0, 1.6)" $MODEL
run wpc-capture-calcs $SYSML -calc "TethysCaptureSystem::SphereMomentOfInertia(362.0e3, 6.8)" -calc "TethysCaptureSystem::AngularMomentum(1.674e6, 252.0)" -calc "TethysCaptureSystem::EquatorialSurfaceSpeed(6.8, 252.0)" -calc "TethysCaptureSystem::DespinDuration(4.17e4, 120.0)" -calc "TethysCaptureSystem::DespinPropellant(4.17e4, 3.0, 220.0)" -calc "TethysCaptureSystem::ContactForce(362.0e3, 0.10, 0.5)" -calc "TethysCaptureSystem::ContactForce(1000.0e3, 0.10, 0.5)" -calc "TethysCaptureSystem::MinimumRotationPeriod(6.0e4, 1000.0e3, 10.0)" -calc "TethysCaptureSystem::MinimumRotationPeriod(6.0e4, 362.0e3, 6.8)" $MODEL
run wpc-target-cases $SYSML -calc "TethysCaptureSystem::SphereMomentOfInertia(181.0e3, 5.4)" -calc "TethysCaptureSystem::SphereMomentOfInertia(1010.0e3, 8.2)" -calc "TethysCaptureSystem::AngularMomentum(5.278e5, 252.0)" -calc "TethysCaptureSystem::AngularMomentum(1.674e6, 252.0)" -calc "TethysCaptureSystem::AngularMomentum(6.791e6, 252.0)" -calc "TethysCaptureSystem::AngularMomentum(1.674e6, 120.0)" -calc "TethysCaptureSystem::DespinPropellant(1.316e4, 3.0, 220.0)" -calc "TethysCaptureSystem::DespinPropellant(4.17e4, 3.0, 220.0)" -calc "TethysCaptureSystem::DespinPropellant(1.693e5, 3.0, 220.0)" -calc "TethysCaptureSystem::DespinPropellant(8.76e4, 3.0, 220.0)" -calc "TethysCaptureSystem::EquatorialSurfaceSpeed(6.8, 120.0)" $MODEL
run wpc-envelope-cases $SYSML -constraint TethysCaptureSystem::smallTargetCase::fits -constraint TethysCaptureSystem::nominalTargetCase::fits -constraint TethysCaptureSystem::largeTargetCase::fits -constraint TethysCaptureSystem::fastSpinTargetCase::fits -constraint TethysCaptureSystem::tumblingTargetCase::fits $MODEL
run wpc-requirements $SYSML -requirement TethysInspectorDetail::circumnavigationDeltaV -requirement TethysCaptureSystem::contactSpeed -requirement TethysCaptureSystem::despinTorque -requirement TethysProximityOps::retreatRange $MODEL
run wpc-individuals $SYSML -instantiate TethysInspectorDetail::wrenFM -instantiate TethysProximityOps::amaranthFM -instantiate TethysProximityOps::proxStackFM $MODEL
run wpc-prox-ops-modes $SYSML -instantiate TethysProximityOps::proximityOperations -state "TethysProximityOps::ProximityOpsModes TethysProximityOps::proximityOperations" -advance 10000 $MODEL
run wpc-capture-sequence $SYSML -instantiate TethysProximityOps::captureOperation -action "TethysProximityOps::CaptureSequence TethysProximityOps::captureOperation" -advance 10000 $MODEL
if [ "$mode" = record ]; then rm -rf runs; cp -r "$out" runs; else diff -ru runs "$out"; fi
