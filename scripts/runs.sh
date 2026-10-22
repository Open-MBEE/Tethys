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
if [ "$mode" = record ]; then rm -rf runs; cp -r "$out" runs; else diff -ru runs "$out"; fi
