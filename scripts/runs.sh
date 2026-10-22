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
run safety-constraints $SYSML -constraint TethysSafety::earthImpactTree::earthImpactExcluded -constraint TethysSafety::reliabilityBudget::reliabilityAllocationMet -constraint TethysSafety::envelopeCases::largeCaseFits -constraint TethysSafety::endOfLifeSafety::disposalPropellantSufficient -constraint TethysSafety::groundSafetyData::twoInhibits $MODEL
run safety-calcs $SYSML -calc "TethysSafety::EnvelopeMargin(10.0, 5.0)" -calc "TethysSafety::EnvelopeMargin(10.0, 6.8)" -calc "TethysSafety::EnvelopeMargin(10.0, 7.7)" -calc "TethysSafety::Exp(-0.5)" -calc "TethysSafety::Reliability(10.0)" -calc "TethysSafety::FailureProbability(10.0)" -calc "TethysSafety::KOutOfNReliability3of4(0.876)" -calc "TethysSafety::AndGate(1.0e-3, 1.0e-3)" -calc "TethysSafety::OrGate(2.0e-3, 1.0e-6)" -calc "TethysSafety::AndGate(2.0e-2, 2.001e-3)" $MODEL
run safety-instantiate $SYSML -instantiate TethysSafety::fmeca -instantiate TethysSafety::lossOfCaptureTree -instantiate TethysSafety::reliabilityBudget -instantiate TethysSafety::hazardLog $MODEL
run safety-f003-probe $SYSML -instantiate 'F-003-multicausation-ends'::tree model/probes/F-003-multicausation-ends.sysml
if [ "$mode" = record ]; then rm -rf runs; cp -r "$out" runs; else diff -ru runs "$out"; fi
