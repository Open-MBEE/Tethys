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
run as-built-individuals $SYSML -e "TethysAsBuilt::argentFM.identity.serialNumber" -e "TethysAsBuilt::argentFM.sep.identity.serialNumber" -e "TethysAsBuilt::wrenFM.identity.serialNumber" -e "TethysAsBuilt::argentFM.massDeviation" -e "TethysAsBuilt::wrenFM.massDeviation" -e "TethysAsBuilt::amaranthFM.massEstimateRatio" -e "TethysAsBuilt::asBuiltBaseline.tugState.dryMass" $MODEL
run as-built-satisfy $SYSML -satisfy $MODEL
run as-built-integration $SYSML -action TethysAsBuilt::integration $MODEL
run import-dry-run $SYSML -import data/argent-telemetry.csv -import data/amaranth-ephemeris.json -import-map data/amaranth-ephemeris.map.json -import data/as-built-masses.txt -import-format tsv -import-as values -import-dry-run $MODEL
run import-repl sh -c "printf '%s\n' '%import data/argent-telemetry.csv' '%import data/amaranth-ephemeris.json map data/amaranth-ephemeris.map.json' '%calc TethysImportedData::xenonUsedOutbound' '%calc TethysImportedData::xenonUsedReturn' '%eval TethysImportedData::amaranthTracked.approachEpoch3.ephemeris.earthRange' | $SYSML $MODEL"
run disposal-requirements $SYSML -requirement TethysDisposal::heliocentricDisposal -requirement TethysDisposal::disposalPropellantReserve -requirement TethysDisposal::passivation -requirement TethysDisposal::separationSafety $MODEL
run disposal-sequence $SYSML -action TethysDisposal::disposal $MODEL
run disposal-states $SYSML -instantiate TethysDisposal::argentAtEndOfLife -state "TethysDisposal::TugEndOfLife argentAtEndOfLife" -advance 10 $MODEL
if [ "$mode" = record ]; then rm -rf runs; cp -r "$out" runs; else diff -ru runs "$out"; fi
