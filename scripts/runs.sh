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
run safety-fj01-probe $SYSML -instantiate 'F-J01-multicausation-ends'::tree model/probes/F-J01-multicausation-ends.sysml
run risk-constraints $SYSML -constraint TethysRisk::riskRegister::noUnownedRedRisk -constraint TethysRisk::burnDown::registerBurningDown -constraint TethysRisk::burnDown::earthImpactBurningDown -constraint TethysRisk::marginIndicators::xenonFlagMatchesRegister -constraint TethysRisk::technologyPlan::fallbackHoldsNominalTarget $MODEL
run risk-calcs $SYSML -calc "TethysRisk::Score(TethysRisk::Likelihood::moderate, TethysRisk::Consequence::catastrophic)" -calc "TethysRisk::Score(TethysRisk::Likelihood::low, TethysRisk::Consequence::catastrophic)" -calc "TethysRisk::Score(TethysRisk::Likelihood::veryLow, TethysRisk::Consequence::catastrophic)" -calc "TethysRisk::Score(TethysRisk::Likelihood::high, TethysRisk::Consequence::major)" -calc "TethysRisk::Score(TethysRisk::Likelihood::moderate, TethysRisk::Consequence::major)" -calc "TethysRisk::RatingOf(TethysRisk::Likelihood::veryLow, TethysRisk::Consequence::catastrophic)" -calc "TethysRisk::RatingOf(TethysRisk::Likelihood::moderate, TethysRisk::Consequence::catastrophic)" -calc "TethysRisk::RatingOf(TethysRisk::Likelihood::moderate, TethysRisk::Consequence::major)" -calc "TethysRisk::RatingOf(TethysRisk::Likelihood::low, TethysRisk::Consequence::moderate)" -calc "TethysRisk::RatingOf(TethysRisk::Likelihood::veryHigh, TethysRisk::Consequence::negligible)" -calc "TethysRisk::ToLevel(4)" $MODEL
run risk-instantiate $SYSML -instantiate TethysRisk::riskRegister -instantiate TethysRisk::marginIndicators -instantiate TethysRisk::lessonsLearned $MODEL
run risk-register-view $SYSML -render TethysRisk::riskRegisterView -render-form csv $MODEL
run risk-fj02-probe $SYSML -constraint "'F-J02-snapshot-inherited-values'::reader::snapshotProduct" model/probes/F-J02-snapshot-inherited-values.sysml
run allocations-queries $SYSML -run-query "TethysAllocationQueries::UnallocatedFunctions root=TethysAllocations::missionFunctions" -run-query "TethysAllocationQueries::UnallocatedRequirements root=TethysRequirements" -run-query "TethysAllocationQueries::UnallocatedFunctions root=TethysRisk::riskRegister" -run-query "TethysAllocationQueries::AllocationTargets origin=TethysAllocations::missionFunctions::produceHeliocentricThrust" -run-query "TethysAllocationQueries::AllocationTargets origin=TethysRequirements::cislunarSafety" $MODEL
run allocations-matrix $SYSML -render TethysAllocations::functionAllocationMatrix -render-form csv $MODEL
run allocations-requirement-matrix $SYSML -render TethysAllocations::requirementAllocationMatrix -render-form csv $MODEL
run allocations-instantiate $SYSML -instantiate TethysAllocations::missionFunctions -instantiate TethysAllocations::sourcingRecord $MODEL
if [ "$mode" = record ]; then rm -rf runs; cp -r "$out" runs; else diff -ru runs "$out"; fi
