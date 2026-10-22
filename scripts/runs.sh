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
# WP-H views, documents and layout (model/90-92). Documents embed a positioned view drawn by the `dot` on PATH (graphviz 2.43).
run list-views $SYSML -list all -quiet $MODEL
run render-all $SYSML -render-all "$out/views" -quiet $MODEL
run render-segment-interfaces-dot $SYSML -render TethysViews::segmentInterfaces -render-form dot -quiet $MODEL
run render-mass-budget-csv $SYSML -render TethysViews::massBudget -render-form csv -quiet $MODEL
run render-documents-md $SYSML -render-documents "$out/documents" -quiet $MODEL
run render-documents-html $SYSML -render-documents "$out/documents-html" -doc-form html -quiet $MODEL
run tool-version $SYSML -version
run document-queries $SYSML -run-query TethysDocuments::MissionRequirements -run-query TethysDocuments::InterfaceEnds -run-query TethysDocuments::FlightPhases -run-query TethysDocuments::Risks -quiet $MODEL
if [ "$mode" = record ]; then rm -rf runs; cp -r "$out" runs; else diff -ru runs "$out"; fi
