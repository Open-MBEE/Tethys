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
run requirements-satisfy $SYSML -satisfy $MODEL
run tpm-margins $SYSML -instantiate TethysStakeholders::technicalPerformanceMeasures -validate=TethysStakeholders::technicalPerformanceMeasures $MODEL
run verification-cases $SYSML -analysis TethysVerification::captureEnvelopeTest -analysis TethysVerification::contactSpeedTest -analysis TethysVerification::sepHotFireTest -analysis TethysVerification::linkBudgetTest -analysis TethysVerification::faultResponseTest -analysis TethysVerification::autonomyTest -analysis TethysVerification::inspectorAcceptanceTest -analysis TethysVerification::separationTest -analysis TethysVerification::proximityNavigationTest -analysis TethysVerification::thermalBalanceTest -analysis TethysVerification::cinchMotorTest -analysis TethysVerification::propellantAnalysis -analysis TethysVerification::despinAnalysis -analysis TethysVerification::powerAnalysis -analysis TethysVerification::massBudgetAnalysis -analysis TethysVerification::returnSafetyAnalysis -analysis TethysVerification::deliveryAnalysis -analysis TethysVerification::characterisationAnalysis -analysis TethysVerification::deflectionAnalysis -analysis TethysVerification::dockingLoadsAnalysis -analysis TethysVerification::thrustModelValidation -analysis TethysVerification::redundancyInspection -analysis TethysVerification::documentInspection -analysis TethysVerification::groundInspection -analysis TethysVerification::groundReadinessDemo -analysis TethysVerification::sepCommissioning -analysis TethysVerification::inspectorCommissioning -analysis TethysVerification::dockingDemo -analysis TethysVerification::missionValidation -analysis TethysVerification::successCriteriaValidation -analysis TethysVerification::groundProceduresDemo -analysis TethysVerification::interfaceBaselineInspection -analysis TethysVerification::conOpsValidation $MODEL
run unverified-requirements $SYSML -run-query "TethysVerificationTooling::UnverifiedRequirements" $MODEL
run vv-matrix-l2 $SYSML -run-query "TethysVerificationTooling::VvMatrix root=TethysRequirementsL2" $MODEL
run vv-report $SYSML -render-document TethysVerificationTooling::VvReport $MODEL
run test-campaign $SYSML -action TethysVerification::runCampaign $MODEL
# WP-B — Argent tug structure and engineering budgets (one expression per process: F-B01 in docs/findings/WP-B.md)
run wpb-margin-policy $SYSML -calc "TethysMarginPolicy::ContingencyFor(TethysMarginPolicy::Maturity::modified, TethysMarginPolicy::activePolicy)" -calc "TethysMarginPolicy::WithContingency(100.0, TethysMarginPolicy::Maturity::newDesign, TethysMarginPolicy::activePolicy)" -calc "TethysMarginPolicy::MarginFraction(12.0, 10.0)" -constraint "TethysMarginPolicy::ClosesWithMargin(1200.0, 1000.0, TethysMarginPolicy::activePolicy)" $MODEL
run wpb-margin-policy-alone $SYSML -calc "TethysMarginPolicy::ContingencyFor(TethysMarginPolicy::Maturity::modified, TethysMarginPolicy::activePolicy)" model/30-margin-policy.sysml
run wpb-tug-dry-mass $SYSML -e "TethysTugStructure::argentDesign.dryMassEstimate" $MODEL
run wpb-tug-dry-mass-allocated $SYSML -e "TethysTugStructure::argentDesign.dryMassAllocated" $MODEL
run wpb-tug-sep-mass $SYSML -e "TethysTugStructure::argentDesign.sep.mass" $MODEL
run wpb-unit-power-safe $SYSML -e "TethysTugStructure::UnitsPowerInMode(TethysTugStructure::argentDesign.cdh.flightComputers, TethysTugStructure::TugMode::safe)" $MODEL
run wpb-unit-power-thrusting $SYSML -e "TethysTugStructure::UnitsPowerInMode(TethysTugStructure::argentDesign.sep.thrusters, TethysTugStructure::TugMode::thrusting)" $MODEL
run wpb-power-budget-safe $SYSML -e "TethysBudgets::powerBudget.demandSafe" $MODEL
run wpb-mass-budget $SYSML -e "TethysBudgets::massBudget.launchMass" $MODEL
run wpb-xenon-large $SYSML -e "TethysBudgets::propellantBudget.xenonLarge" $MODEL
run wpb-sep-thrust-aphelion $SYSML -e "TethysBudgets::propellantBudget.thrustAtAphelion" $MODEL
run wpb-thrusting-time-large $SYSML -e "TethysBudgets::propellantBudget.thrustingTimeLarge" $MODEL
run wpb-hydrazine-large $SYSML -e "TethysBudgets::hydrazineBudget.demandLarge" $MODEL
run wpb-data-daily $SYSML -e "TethysBudgets::dataBudget.dailyGenerated" $MODEL
run wpb-pointing-antenna $SYSML -e "TethysBudgets::pointingBudget.antennaPointingErrorDegrees" $MODEL
run wpb-radiator-capacity $SYSML -e "TethysBudgets::thermalBudget.radiatorCapacity" $MODEL
run wpb-reliability $SYSML -e "TethysBudgets::reliabilityBudget.missionReliability" $MODEL
run wpb-budgets-satisfy $SYSML -satisfy $MODEL
if [ "$mode" = record ]; then rm -rf runs; cp -r "$out" runs; else diff -ru runs "$out"; fi
