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
# WP-E — modes (model/60-modes.sysml): the mode machines under the nominal and large-target campaigns; clock in seconds (1 d = 86 400 s).
run modes-table $SYSML -quiet -instantiate TethysModes::argentModeTable -e "TethysModes::argentModeTable.rows.mode" -e "TethysModes::argentModeTable.rows.busLoad" -e "TethysModes::argentModeTable.rows.sepThrusting" -e "TethysModes::argentModeTable.rows.highVoltageBusOn" $MODEL
run modes-tug-early-ops $SYSML -quiet -instantiate TethysModes::nominalFlight -state TethysModes::nominalFlight.tug -advance 17280 -trace $MODEL
run modes-tug-thrust-arc $SYSML -quiet -instantiate TethysModes::nominalFlight -state TethysModes::nominalFlight.tug -advance 2678400 $MODEL
run modes-tug-proximity-ops $SYSML -quiet -instantiate TethysModes::nominalFlight -state TethysModes::nominalFlight.tug -advance 38016000 $MODEL
run modes-tug-full-flight $SYSML -quiet -instantiate TethysModes::nominalFlight -state TethysModes::nominalFlight.tug -advance 129600000 $MODEL
run modes-tug-large-target $SYSML -quiet -instantiate TethysModes::largeTargetFlight -state TethysModes::largeTargetFlight.tug -advance 129600000 $MODEL
run modes-inspector-imaging $SYSML -quiet -instantiate TethysModes::nominalFlight -state TethysModes::nominalFlight.inspector -advance 38102400 $MODEL
run modes-inspector-retired $SYSML -quiet -instantiate TethysModes::nominalFlight -state TethysModes::nominalFlight.inspector -advance 129600000 $MODEL
if [ "$mode" = record ]; then rm -rf runs; cp -r "$out" runs; else diff -ru runs "$out"; fi
