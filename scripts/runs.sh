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
# WP-E — sequence (model/61-sequence.sysml): phase plan, dated schedule, and the mission action run to completion for the small, nominal and large target cases (2 200 d = 190 080 000 s).
run sequence-phase-plan $SYSML -quiet -instantiate TethysSequence::nominalPhasePlan -e "TethysSequence::nominalPhasePlan.phases.phase" -e "TethysSequence::nominalPhasePlan.phases.plannedDuration" -e "TethysSequence::nominalPhasePlan.plannedTotal" $MODEL
run sequence-schedule $SYSML -quiet -instantiate TethysSequence::baselineSchedule -e "TethysSequence::baselineSchedule.events.eventName" -e "TethysSequence::baselineSchedule.events.dayAfterLaunch" $MODEL
run sequence-small-target $SYSML -quiet -instantiate TethysSequence::smallTargetCampaign -action "TethysSequence::FlightCampaign::mission TethysSequence::smallTargetCampaign" -advance 190080000 $MODEL
run sequence-nominal $SYSML -quiet -instantiate TethysSequence::nominalCampaign -action "TethysSequence::FlightCampaign::mission TethysSequence::nominalCampaign" -advance 190080000 $MODEL
run sequence-large-target $SYSML -quiet -instantiate TethysSequence::largeTargetCampaign -action "TethysSequence::FlightCampaign::mission TethysSequence::largeTargetCampaign" -advance 190080000 $MODEL
run sequence-nominal-trace $SYSML -quiet -instantiate TethysSequence::nominalCampaign -action "TethysSequence::FlightCampaign::mission TethysSequence::nominalCampaign" -advance 190080000 -trace $MODEL
# WP-E — FDIR (model/62-fdir.sysml): the supervisor and the mode machine under three fault-injection campaigns (compressed day clock), and the inhibit chain under the schedule checker and the SMT engine.
run fdir-command-loss-expired $SYSML -quiet -instantiate TethysFdir::commandLossScenario -state TethysFdir::commandLossScenario.tug.fdir -advance 1555200 $MODEL
run fdir-command-loss-modes-safe $SYSML -quiet -instantiate TethysFdir::commandLossScenario -state TethysFdir::commandLossScenario.tug.modes -advance 1555200 $MODEL
run fdir-command-loss-recovered $SYSML -quiet -instantiate TethysFdir::commandLossScenario -state TethysFdir::commandLossScenario.tug.modes -advance 2160000 $MODEL
run fdir-thruster-restarting $SYSML -quiet -instantiate TethysFdir::thrusterFaultScenario -state TethysFdir::thrusterFaultScenario.tug.fdir -advance 876960 -trace $MODEL
run fdir-thruster-on-spare $SYSML -quiet -instantiate TethysFdir::thrusterFaultScenario -state TethysFdir::thrusterFaultScenario.tug.fdir -advance 1900800 $MODEL
run fdir-thruster-ppu-cross-strapped $SYSML -quiet -instantiate TethysFdir::thrusterFaultScenario -state TethysFdir::thrusterFaultScenario.tug.fdir -advance 2332800 $MODEL
run fdir-thruster-string-lost $SYSML -quiet -instantiate TethysFdir::thrusterFaultScenario -state TethysFdir::thrusterFaultScenario.tug.fdir -advance 2764800 $MODEL
run fdir-thruster-modes-safe $SYSML -quiet -instantiate TethysFdir::thrusterFaultScenario -state TethysFdir::thrusterFaultScenario.tug.modes -advance 2764800 $MODEL
run fdir-earth-impact-nominal-return $SYSML -quiet -instantiate TethysFdir::earthImpactScenario -state TethysFdir::earthImpactScenario.tug.modes -advance 2160000 $MODEL
run fdir-earth-impact-aborted $SYSML -quiet -instantiate TethysFdir::earthImpactScenario -state TethysFdir::earthImpactScenario.tug.fdir -advance 2592000 $MODEL
run fdir-earth-impact-abort-hold $SYSML -quiet -instantiate TethysFdir::earthImpactScenario -state TethysFdir::earthImpactScenario.tug.modes -advance 2592000 $MODEL
run fdir-inhibit-chain-held $SYSML -quiet -instantiate TethysFdir::inhibitedChain -action "TethysFdir::InhibitChain::cinch TethysFdir::inhibitedChain" $MODEL
run fdir-inhibit-chain-check $SYSML -quiet -engine check -instantiate TethysFdir::armedChain -action "TethysFdir::InhibitChain::cinch TethysFdir::armedChain" -check-property TethysFdir::InhibitChain::noFireWithoutInhibitsRemoved $MODEL
run fdir-inhibit-chain-smt $SYSML -quiet -engine smt -instantiate TethysFdir::armedChain -action "TethysFdir::InhibitChain::cinch TethysFdir::armedChain" -check-input armCommanded -check-input groundEnable -check-input inCaptureMode -check-property TethysFdir::InhibitChain::noFireWithoutInhibitsRemoved $MODEL
if [ "$mode" = record ]; then rm -rf runs; cp -r "$out" runs; else diff -ru runs "$out"; fi
