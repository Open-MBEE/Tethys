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
run wpd-icd-matrix $SYSML -render "#matrix:TethysIcds::icdSystem" $MODEL
run wpd-ground-matrix $SYSML -render "#matrix:TethysMeridian::MeridianNetwork" $MODEL
run wpd-decibels $SYSML -calc "TethysLinkBudgets::Log10(1000.0)" -calc "TethysLinkBudgets::DecibelsFromRatio(2.0)" -calc "TethysLinkBudgets::RatioFromDecibels(30.0)" -calc "TethysLinkBudgets::FreeSpaceLossDb(60.0e9, 8.445e9)" -calc "TethysLinkBudgets::DishGainDbi(32.0, 8.445e9, 0.6)" -calc "TethysLinkBudgets::DishGainDbi(2.4, 32.05e9, 0.6)" -calc "TethysLinkBudgets::GainToNoiseTemperatureDbPerK(66.823, 25.0)" $MODEL
run wpd-link-margins $SYSML -calc "TethysLinkBudgets::MarginReport(TethysLinkBudgets::xDownlinkAtMaximumRange)" -calc "TethysLinkBudgets::MarginReport(TethysLinkBudgets::xUplinkAtMaximumRange)" -calc "TethysLinkBudgets::MarginReport(TethysLinkBudgets::kaDownlinkAtTargetRange)" -calc "TethysLinkBudgets::MarginReport(TethysLinkBudgets::xDownlinkInDro)" -calc "TethysLinkBudgets::MarginReport(TethysLinkBudgets::proximityReturnLink)" $MODEL
run wpd-link-satisfy $SYSML -satisfy=TethysLinkBudgets $MODEL
run wpd-relay-load $SYSML -calc "TethysLinkBudgets::CharacterisationDataVolume(4.0, 0.005, 40.0, 12.0)" -calc "TethysLinkBudgets::CharacterisationDataVolume(6.8, 0.005, 40.0, 12.0)" -calc "TethysLinkBudgets::CharacterisationDataVolume(9.5, 0.005, 40.0, 12.0)" -calc "TethysLinkBudgets::RelayDaysRequired(965097263.18, 1.0e6, 3240.0)" -calc "TethysLinkBudgets::RelayDaysRequired(2789131090.60, 1.0e6, 3240.0)" -calc "TethysLinkBudgets::RelayDaysRequired(5443751750.14, 1.0e6, 3240.0)" $MODEL
run wpd-operations-satisfy $SYSML -satisfy=TethysOperations $MODEL
run wpd-thrust-arc-procedure $SYSML -instantiate TethysOperations::scenario -action "TethysOperations::OperationsScenario::moc::thrustArcProcedure scenario.moc" -advance 10 -render-run sequence=- $MODEL
run wpd-flight-rules $SYSML -engine check -action TethysOperations::RelayThenThrustProcedure -check-property TethysOperations::RelayThenThrustProcedure::noThrustDuringRelay -check-property TethysOperations::RelayThenThrustProcedure::batteryFloor $MODEL
run wpd-icd-register-document $SYSML -render-document TethysIcdDocuments::IcdRegisterDocument $MODEL
run wpd-space-ground-icd-document $SYSML -render-document TethysIcdDocuments::SpaceGroundIcdDocument $MODEL
run wpd-operations-timeline $SYSML -instantiate TethysOperations::opsTimeline -state "TethysOperations::OperationsTimeline::day TethysOperations::opsTimeline" -advance 50000 -render-run timeline=- $MODEL
if [ "$mode" = record ]; then rm -rf runs; cp -r "$out" runs; else diff -ru runs "$out"; fi
