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
# Analyses, trades, Monte Carlo, dynamics (TethysAnalyses, TethysTrades, TethysMonteCarlo,
# TethysDynamics, TethysAnalysesTooling). `runt` drops the wall-time column of sweep and run
# tables so the output pins; the external tool manifest must live outside the working tree.
runt() { name=$1; shift; "$@" 2>&1 | sed -E -e 's/ *\| *time$//' -e 's/\+-+$//' -e 's/ *\| *[0-9.]+(ms|µs|ns|s)$//' > "$out/$name.txt" || echo "exit $?" >> "$out/$name.txt"; }
TOOLS="${TMPDIR:-/tmp}/tethys-tools"; rm -rf "$TOOLS"; cp -r scripts/tools/thrust-arc "$TOOLS"
run analyses-transfer $SYSML -analysis TethysAnalyses::transferSmall -analysis TethysAnalyses::transferNominal -analysis TethysAnalyses::transferLarge -analysis TethysAnalyses::verifyDurationNominal -analysis TethysAnalyses::verifyDurationLarge $MODEL
run analyses-capture $SYSML -analysis TethysAnalyses::captureNominal -analysis TethysAnalyses::captureLarge -analysis TethysAnalyses::captureFastSpin $MODEL
run analyses-external-tool env OPENSYSML_TOOLS="$TOOLS" $SYSML -analysis TethysAnalyses::externalTransfer -record-run TethysAnalyses::externalTransfer -record-run TethysAnalyses::transferNominal $MODEL
runt analyses-sweep $SYSML -analysis TethysAnalyses::transferNominal -sweep "outboundDeltaVMPerS=1500.0..3000.0:500.0" $MODEL
run trades $SYSML -analysis TethysTrades::arrayPowerTrade -analysis TethysTrades::specificImpulseTrade -analysis TethysTrades::departureTrade -analysis TethysTrades::destinationOrbitTrade -analysis TethysTrades::captureMechanismTrade $MODEL
runt trades-sweep $SYSML -analysis TethysTrades::arrayPowerTrade -sweep "costPenaltyDaysPerUnit=0.0..10.0:2.5" $MODEL
runt montecarlo-return $SYSML -analysis TethysMonteCarlo::returnDispersion -sweep "bodyMassKg=215000.0..644000.0" -samples 100 -seed 7 $MODEL
runt montecarlo-capture $SYSML -analysis TethysMonteCarlo::captureDispersion -sweep "diameterM=5.4..8.2" -sweep "rotationPeriodS=120.0..600.0" -samples 100 -seed 7 $MODEL
runt montecarlo-missed-thrust $SYSML -analysis TethysMonteCarlo::missedThrustDispersion -sweep "coastDaysPerEvent=2.0..30.0" -sweep "safeModeEvents=0.0..12.0" -samples 100 -seed 7 $MODEL
runt montecarlo-insertion $SYSML -analysis TethysMonteCarlo::insertionDispersion -sweep "vInfinityKmPerS=0.5..1.5" -sweep "insertionErrorMPerS=0.0..20.0" -samples 100 -seed 7 $MODEL
run dynamics-tables $SYSML -calc "TethysDynamics::ArrayDegradationAt(900.0)" -calc "TethysDynamics::ArrayDegradationAt(3000.0)" -calc "TethysDynamics::SolarFluxFromTable(1.034)" -calc "TethysDynamics::SolarFluxFromTable(1.1393)" -analysis TethysDynamics::arrayPowerAtAphelionEnd $MODEL
runt dynamics-array-sweep $SYSML -analysis TethysDynamics::arrayPowerAtAphelionEnd -sweep "missionDay=0.0..2200.0:550.0" $MODEL
run dynamics-standard $SYSML -action TethysDynamics::droRevolution -action TethysDynamics::firstThrustArc -action TethysDynamics::despinNominal -analysis TethysDynamics::droStability $MODEL
runt tooling-montecarlo $SYSML -analysis TethysAnalysesTooling::returnOverTargetCases -runs 200 -seed 7 $MODEL
runt tooling-montecarlo-continuous $SYSML -analysis TethysAnalysesTooling::returnOverContinuousMass -runs 200 -seed 7 $MODEL
runt tooling-montecarlo-min $SYSML -analysis TethysAnalysesTooling::returnOverContinuousMass -draws min -runs 1 $MODEL
runt tooling-montecarlo-max $SYSML -analysis TethysAnalysesTooling::returnOverContinuousMass -draws max -runs 1 $MODEL
run tooling-dynamics $SYSML -action TethysAnalysesTooling::droRevolutionRk4 -action TethysAnalysesTooling::firstThrustArcRk4 $MODEL
run probe-F-F01 $SYSML -action TethysDynamicsIntegratorProbe::droRevolutionRk4 $MODEL model/probes/F-F01-state-space-integrator.sysml
run probe-F-F02 $SYSML -analysis TethysVariantSubjectProbe::viaVariant -analysis TethysVariantSubjectProbe::viaConfiguration -analysis TethysVariantSubjectProbe::viaPlainPart $MODEL model/probes/F-F02-variant-as-subject.sysml
run probe-F-F03 $SYSML -analysis TethysMetadataInBodyProbe::inline -analysis TethysMetadataInBodyProbe::outside $MODEL model/probes/F-F03-metadata-in-analysis-body.sysml
run probe-F-F05 $SYSML -action NestedStateSpaceProbe::fall -analysis NestedStateSpaceProbe::drop model/probes/F-F05-nested-state-space-action.sysml
run probe-F-F04 $SYSML -calc "TethysAmbiguousMinProbe::Smaller(2.0, 3.0)" -calc "TethysAmbiguousMinProbe::Larger(2.0, 3.0)" model/probes/F-F04-ambiguous-min.sysml
run probe-F-F06 env OPENSYSML_TOOLS="$TOOLS" $SYSML -analysis TethysToolMultiplicityProbe::unmultipliedTransfer $MODEL model/probes/F-F06-tool-output-multiplicity.sysml
if [ "$mode" = record ]; then rm -rf runs; cp -r "$out" runs; else diff -ru runs "$out"; fi
