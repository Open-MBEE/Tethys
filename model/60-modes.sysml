// WP-E — spacecraft modes. The command vocabulary (ground telecommands and on-board events),
// the mode × subsystem configuration table, the tug mode machine with its subsystem regions,
// the inspector mode machine, and the nominal-flight scenario the pinned runs execute.
// TethysSequence (61) performs the phases as actions; TethysFdir (62) adds the fault monitors
// that raise SafeModeRequest and the hazardous-function inhibits.
package TethysModes {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysInterfaces::*;
    private import TethysTug::Tug;
    private import TethysInspector::Inspector;
    private import TethysTarget::targetCases;
    private import TethysBudgets::CaptureCommitEnvelope;
    private import TethysBudgets::captureCommitEnvelope;

    // ---- 1. Command and event vocabulary ------------------------------------------------
    item def GroundCommand :> Telecommand {
        doc /* A mode-changing telecommand uplinked through Meridian; every mode transition the
             * ground owns is triggered by exactly one specialisation of this item. */
    }
    item def ThrustArcGo :> GroundCommand {
        doc /* Start a thrust arc with the sequenced attitude profile and the arc's planned
             * length; the tug returns to coast on ThrustArcEnd or when the arc's timer expires. */
        attribute plannedDuration : DurationValue;
    }
    item def ThrustArcEnd :> GroundCommand {
        doc /* End the current thrust arc and coast (navigation cut-off or optical-navigation
             * campaign). */
    }
    item def ProximityOperationsGo :> GroundCommand {
        doc /* Begin the approach from the far-field hold: the ground has delivered the
             * approach ephemeris and the optical-navigation solution is converged. */
    }
    item def CaptureGo :> GroundCommand {
        doc /* Commit to capture with the characterised target estimate; the mode machine
             * refuses it when the estimate exceeds the capture-commit envelope (the bag and the
             * return propellant, TethysBudgets::captureCommitEnvelope). */
        attribute estimatedMass : MassValue;
        attribute estimatedDiameter : LengthValue;
    }
    item def ReturnThrustGo :> GroundCommand {
        doc /* Start a return thrust arc with the stacked configuration's control gains. */
        attribute plannedDuration : DurationValue;
    }
    item def DroHoldGo :> GroundCommand {
        doc /* Confirm DRO insertion and enter the station-keeping hold. */
    }
    item def DockingGo :> GroundCommand {
        doc /* Make the stack passive for a visiting-vehicle docking. */
    }
    item def DisposalGo :> GroundCommand {
        doc /* Separate the tug from the target and start the disposal burn. */
    }
    item def SafeModeExit :> GroundCommand {
        doc /* Ground recovery from safe mode after the fault has been isolated. */
    }
    item def InspectorCheckoutGo :> GroundCommand {
        doc /* Power the stowed inspector from the umbilical and run its checkout. */
    }
    item def InspectorReleaseGo :> GroundCommand {
        doc /* Release Wren from the dispenser (only accepted after a passed checkout). */
    }
    item def InspectorImagingGo :> GroundCommand {
        doc /* Start a circumnavigation imaging pass. */
        attribute passDuration : DurationValue;
    }
    item def InspectorRetireGo :> GroundCommand {
        doc /* Retire the inspector to its disposal trajectory after characterisation. */
    }

    item def OnBoardEvent {
        doc /* An event the flight software raises itself (a sensed condition, a completed
             * sequence); the mode machines accept it exactly as a ground command. */
    }
    item def SeparationConfirmed :> OnBoardEvent {
        doc /* Launcher separation switches have opened. */
    }
    item def ArraysDeployed :> OnBoardEvent {
        doc /* Both solar-array wings latched. */
    }
    item def RangeUpdate :> OnBoardEvent {
        doc /* A relative-navigation update: range to the target. */
        attribute range : LengthValue;
    }
    item def CaptureComplete :> OnBoardEvent {
        doc /* Capture bag cinched and load path confirmed. */
    }
    item def DespinComplete :> OnBoardEvent {
        doc /* Stack rate below the control threshold after despin. */
    }
    item def SafeModeRequest :> OnBoardEvent {
        doc /* A fault response raised on board (TethysFdir) demanding safe mode. */
        attribute reason : String;
    }
    item def AbortReturn :> OnBoardEvent {
        doc /* The Earth-impact exclusion monitor (TethysFdir) has found the return trajectory
             * outside its corridor: thrust is inhibited and the stack is retargeted away
             * from Earth; only a ground SafeModeExit after a replanned trajectory recovers. */
        attribute reason : String;
    }
    item def CollisionRisk :> OnBoardEvent {
        doc /* The inspector's proximity sensing predicts a conjunction with the target or
             * the tug closer than the keep-out sphere. */
        attribute predictedMiss : LengthValue;
    }

    port def CommandPort {
        doc /* The receiving end of a command path: telecommands from Meridian through the
             * deep-space link, inspector commands through the tug's proximity relay. */
        in item command : GroundCommand;
        in item onBoardEvent : OnBoardEvent;
    }
    interface def CommandLink {
        doc /* Carries commands and injected events from an operations centre to a vehicle. */
        end port groundSide : ~CommandPort;
        end port vehicleSide : CommandPort;
        flow groundSide.command to vehicleSide.command;
        flow groundSide.onBoardEvent to vehicleSide.onBoardEvent;
    }

    // ---- 2. Modes and the mode × subsystem configuration table --------------------------
    enum def TugMode {
        doc /* The tug's flight modes. Free-flight modes before capture, stacked modes after
             * it, and safe mode reachable from every operating mode. */
        launch; coast; thrust; approach; proximityOperations; retreat; capture;
        despin; stackCoast; stackThrust; droHold; dockedPassive; disposal; safe; abortHold;
    }
    attribute def SubsystemConfiguration {
        doc /* One row of the mode × subsystem matrix: what each subsystem does in a mode and
             * the bus load it draws. */
        attribute mode : TugMode;
        attribute sepThrusting : Boolean;
        attribute highVoltageBusOn : Boolean;
        attribute highGainAntennaOn : Boolean;
        attribute proximityLinkOn : Boolean;
        attribute wheelControl : Boolean;
        attribute captureSystemArmed : Boolean;
        attribute sensorsOn : Boolean;
        attribute busLoad : PowerValue;
    }
    part def TugModeTable {
        doc /* The mode × subsystem configuration matrix of the Argent tug. */
        attribute launch : SubsystemConfiguration {
            :>> mode = TugMode::launch; :>> sepThrusting = false; :>> highVoltageBusOn = false;
            :>> highGainAntennaOn = false; :>> proximityLinkOn = false; :>> wheelControl = false;
            :>> captureSystemArmed = false; :>> sensorsOn = false; :>> busLoad = 0.9 [kW];
        }
        attribute coast : SubsystemConfiguration {
            :>> mode = TugMode::coast; :>> sepThrusting = false; :>> highVoltageBusOn = false;
            :>> highGainAntennaOn = true; :>> proximityLinkOn = false; :>> wheelControl = true;
            :>> captureSystemArmed = false; :>> sensorsOn = false; :>> busLoad = 1.6 [kW];
        }
        attribute thrust : SubsystemConfiguration {
            :>> mode = TugMode::thrust; :>> sepThrusting = true; :>> highVoltageBusOn = true;
            :>> highGainAntennaOn = false; :>> proximityLinkOn = false; :>> wheelControl = true;
            :>> captureSystemArmed = false; :>> sensorsOn = false; :>> busLoad = 41.5 [kW];
        }
        attribute approach : SubsystemConfiguration {
            :>> mode = TugMode::approach; :>> sepThrusting = true; :>> highVoltageBusOn = true;
            :>> highGainAntennaOn = true; :>> proximityLinkOn = false; :>> wheelControl = true;
            :>> captureSystemArmed = false; :>> sensorsOn = true; :>> busLoad = 42.3 [kW];
        }
        attribute proximityOperations : SubsystemConfiguration {
            :>> mode = TugMode::proximityOperations; :>> sepThrusting = false; :>> highVoltageBusOn = false;
            :>> highGainAntennaOn = true; :>> proximityLinkOn = true; :>> wheelControl = false;
            :>> captureSystemArmed = false; :>> sensorsOn = true; :>> busLoad = 2.4 [kW];
        }
        attribute retreat : SubsystemConfiguration {
            :>> mode = TugMode::retreat; :>> sepThrusting = false; :>> highVoltageBusOn = false;
            :>> highGainAntennaOn = true; :>> proximityLinkOn = true; :>> wheelControl = false;
            :>> captureSystemArmed = false; :>> sensorsOn = true; :>> busLoad = 2.2 [kW];
        }
        attribute capture : SubsystemConfiguration {
            :>> mode = TugMode::capture; :>> sepThrusting = false; :>> highVoltageBusOn = false;
            :>> highGainAntennaOn = false; :>> proximityLinkOn = true; :>> wheelControl = false;
            :>> captureSystemArmed = true; :>> sensorsOn = true; :>> busLoad = 2.9 [kW];
        }
        attribute despin : SubsystemConfiguration {
            :>> mode = TugMode::despin; :>> sepThrusting = false; :>> highVoltageBusOn = false;
            :>> highGainAntennaOn = false; :>> proximityLinkOn = false; :>> wheelControl = false;
            :>> captureSystemArmed = false; :>> sensorsOn = false; :>> busLoad = 2.0 [kW];
        }
        attribute stackCoast : SubsystemConfiguration {
            :>> mode = TugMode::stackCoast; :>> sepThrusting = false; :>> highVoltageBusOn = false;
            :>> highGainAntennaOn = true; :>> proximityLinkOn = false; :>> wheelControl = true;
            :>> captureSystemArmed = false; :>> sensorsOn = false; :>> busLoad = 1.7 [kW];
        }
        attribute stackThrust : SubsystemConfiguration {
            :>> mode = TugMode::stackThrust; :>> sepThrusting = true; :>> highVoltageBusOn = true;
            :>> highGainAntennaOn = false; :>> proximityLinkOn = false; :>> wheelControl = true;
            :>> captureSystemArmed = false; :>> sensorsOn = false; :>> busLoad = 41.6 [kW];
        }
        attribute droHold : SubsystemConfiguration {
            :>> mode = TugMode::droHold; :>> sepThrusting = false; :>> highVoltageBusOn = false;
            :>> highGainAntennaOn = true; :>> proximityLinkOn = false; :>> wheelControl = true;
            :>> captureSystemArmed = false; :>> sensorsOn = false; :>> busLoad = 1.5 [kW];
        }
        attribute dockedPassive : SubsystemConfiguration {
            :>> mode = TugMode::dockedPassive; :>> sepThrusting = false; :>> highVoltageBusOn = false;
            :>> highGainAntennaOn = true; :>> proximityLinkOn = true; :>> wheelControl = false;
            :>> captureSystemArmed = false; :>> sensorsOn = false; :>> busLoad = 1.3 [kW];
        }
        attribute disposal : SubsystemConfiguration {
            :>> mode = TugMode::disposal; :>> sepThrusting = true; :>> highVoltageBusOn = true;
            :>> highGainAntennaOn = false; :>> proximityLinkOn = false; :>> wheelControl = true;
            :>> captureSystemArmed = false; :>> sensorsOn = false; :>> busLoad = 41.5 [kW];
        }
        attribute safe : SubsystemConfiguration {
            :>> mode = TugMode::safe; :>> sepThrusting = false; :>> highVoltageBusOn = false;
            :>> highGainAntennaOn = false; :>> proximityLinkOn = false; :>> wheelControl = false;
            :>> captureSystemArmed = false; :>> sensorsOn = false; :>> busLoad = 1.1 [kW];
        }
        attribute abortHold : SubsystemConfiguration {
            :>> mode = TugMode::abortHold; :>> sepThrusting = false; :>> highVoltageBusOn = false;
            :>> highGainAntennaOn = true; :>> proximityLinkOn = false; :>> wheelControl = true;
            :>> captureSystemArmed = false; :>> sensorsOn = false; :>> busLoad = 1.6 [kW];
        }
        attribute rows : SubsystemConfiguration[15] = (launch, coast, thrust, approach,
            proximityOperations, retreat, capture, despin, stackCoast, stackThrust, droHold,
            dockedPassive, disposal, safe, abortHold);
        assert constraint safeModeShedsLoads {
            doc /* Safe mode draws no more than any operating mode and keeps the high-voltage
                 * bus, the capture system and the thrusters off. */
            safe.busLoad <= coast.busLoad and not safe.highVoltageBusOn
                and not safe.captureSystemArmed and not safe.sepThrusting
        }
        assert constraint thrustNeedsHighVoltage {
            doc /* Every row that thrusts has the high-voltage bus on. */
            (thrust.sepThrusting implies thrust.highVoltageBusOn)
                and (approach.sepThrusting implies approach.highVoltageBusOn)
                and (stackThrust.sepThrusting implies stackThrust.highVoltageBusOn)
                and (disposal.sepThrusting implies disposal.highVoltageBusOn)
        }
    }
    part argentModeTable : TugModeTable {
        doc /* The configuration matrix as baselined for Argent. */
    }

    // ---- 3. Tug mode machine with subsystem regions -------------------------------------
    state def TugModes parallel {
        doc /* The Argent mode machine. Region `flightMode` is the mode of the vehicle as a
             * whole — free-flight modes before capture, stacked modes after, safe mode from
             * any operating mode and recovery back to the right family; the other regions are
             * the subsystem machines that follow the same commands (SEP string, telecom,
             * attitude control, capture mechanism). Every command arrives on `command`, the
             * exhibiting tug's port of the same name being the connected end; SafeModeRequest
             * and AbortReturn are raised on board (TethysFdir) and accepted from the tug
             * itself, not from the port. */
        port command : CommandPort;
        attribute envelope : CaptureCommitEnvelope {
            :>> maximumBodyMass = captureCommitEnvelope.maximumBodyMass;
            :>> maximumBodyDiameter = captureCommitEnvelope.maximumBodyDiameter;
        }
        attribute rendezvousRange : LengthValue = 50.0 [km];
        attribute arraysDeploymentTimeout : DurationValue = 2.0 [h];
        attribute disposalBurnDuration : DurationValue = 30.0 [d];
        attribute captured : Boolean = false;
        attribute thrustArcsStarted : Natural = 0;
        attribute safeModeEntries : Natural = 0;
        attribute sunPointingCycles : Natural = 0;
        attribute abortEntries : Natural = 0;
        attribute lastSafeModeReason : String = "";

        state flightMode {
            entry; then launch;

            state launch {
                doc /* From lift-off to the end of early operations: separation, array
                     * deployment, sun acquisition. */
                entry; then onLauncher;
                state onLauncher;
                state deploying;
                transition first onLauncher accept SeparationConfirmed via command then deploying;
                transition first deploying accept ArraysDeployed via command then done;
                transition first deploying accept after arraysDeploymentTimeout then done;
            }
            state freeFlight {
                doc /* Modes before capture. Entered at coast; re-entered at coast after a
                     * safe-mode recovery. */
                entry; then coast;
                state coast;
                state thrust {
                    entry assign thrustArcsStarted := thrustArcsStarted + 1;
                }
                state approach;
                state proximityOperations;
                state retreat;
                state capture;
                transition first coast accept ThrustArcGo via command then thrust;
                transition first thrust accept ThrustArcEnd via command then coast;
                transition first coast accept ProximityOperationsGo via command then approach;
                transition first approach accept u : RangeUpdate via command if u.range <= rendezvousRange then proximityOperations;
                transition first proximityOperations accept go : CaptureGo via command
                    if go.estimatedMass <= envelope.maximumBodyMass and go.estimatedDiameter <= envelope.maximumBodyDiameter
                    then capture;
                transition first proximityOperations accept go : CaptureGo via command
                    if go.estimatedMass > envelope.maximumBodyMass or go.estimatedDiameter > envelope.maximumBodyDiameter
                    then retreat;
                transition first retreat accept ProximityOperationsGo via command then proximityOperations;
                transition first capture accept CaptureComplete via command do assign captured := true then done;
            }
            state stacked {
                doc /* Modes with the target captured: despin, return thrust and coast, DRO
                     * hold, visiting-vehicle docking, disposal. Re-entered at stackCoast after
                     * a safe-mode recovery. */
                entry; then despin;
                state despin;
                state stackCoast;
                state stackThrust {
                    entry assign thrustArcsStarted := thrustArcsStarted + 1;
                }
                state droHold;
                state dockedPassive;
                state disposal;
                transition first despin accept DespinComplete via command then stackCoast;
                transition first stackCoast accept ReturnThrustGo via command then stackThrust;
                transition first stackThrust accept ThrustArcEnd via command then stackCoast;
                transition first stackCoast accept DroHoldGo via command then droHold;
                transition first droHold accept DockingGo via command then dockedPassive;
                transition first dockedPassive accept DisposalGo via command then disposal;
                transition first disposal accept after disposalBurnDuration then done;
            }
            state safe {
                doc /* Sun-pointed, low-gain, thrusters and high-voltage bus off, waiting for
                     * ground recovery; while in safe mode the sun-pointing hold is re-acquired
                     * every hour (the `do` behaviour). */
                entry assign safeModeEntries := safeModeEntries + 1;
                do action sunPointingHold {
                    first start;
                    then action reacquire accept after 1.0 [h];
                    then assign sunPointingCycles := sunPointingCycles + 1;
                    then done;
                }
            }
            state abortHold {
                doc /* Return aborted by the Earth-impact exclusion monitor: thrust inhibited,
                     * attitude held, high-gain link up, waiting for a replanned trajectory. */
                entry assign abortEntries := abortEntries + 1;
            }
            transition first launch then freeFlight;
            transition first freeFlight if captured then stacked;
            transition first stacked then done;
            transition first launch accept r : SafeModeRequest do assign lastSafeModeReason := r.reason then safe;
            transition first freeFlight accept r : SafeModeRequest do assign lastSafeModeReason := r.reason then safe;
            transition first stacked accept r : SafeModeRequest do assign lastSafeModeReason := r.reason then safe;
            transition first safe accept SafeModeExit via command if not captured then freeFlight;
            transition first safe accept SafeModeExit via command if captured then stacked;
            transition first stacked accept a : AbortReturn do assign lastSafeModeReason := a.reason then abortHold;
            transition first abortHold accept SafeModeExit via command then stacked;
        }

        state sepString {
            doc /* The solar-electric propulsion string: off until commissioning, standby
                 * between arcs, thrusting during one and during the approach until the
                 * rendezvous range update; off in safe mode. */
            entry; then off;
            state off;
            state standby;
            state thrusting;
            transition first off accept ArraysDeployed via command then standby;
            transition first standby accept ThrustArcGo via command then thrusting;
            transition first standby accept ProximityOperationsGo via command then thrusting;
            transition first thrusting accept RangeUpdate via command then standby;
            transition first standby accept ReturnThrustGo via command then thrusting;
            transition first standby accept DisposalGo via command then thrusting;
            transition first thrusting accept ThrustArcEnd via command then standby;
            transition first standby accept SafeModeRequest then off;
            transition first thrusting accept SafeModeRequest then off;
            transition first thrusting accept AbortReturn then off;
            transition first off accept SafeModeExit via command then standby;
        }

        state telecom {
            doc /* Deep-space link: low-gain omni from launch and in safe mode, high-gain
                 * when pointed; the proximity relay is on with the inspector in flight. */
            entry; then lowGain;
            state lowGain;
            state highGain;
            state relaying;
            transition first lowGain accept ArraysDeployed via command then highGain;
            transition first highGain accept InspectorReleaseGo via command then relaying;
            transition first relaying accept InspectorRetireGo via command then highGain;
            transition first highGain accept SafeModeRequest then lowGain;
            transition first relaying accept SafeModeRequest then lowGain;
            transition first lowGain accept SafeModeExit via command then highGain;
        }

        state attitudeControl {
            doc /* Reaction wheels for cruise and thrust; hydrazine thrusters for proximity
                 * operations, capture and despin, and for the sun-pointed safe mode. */
            entry; then thrusters;
            state thrusters;
            state wheels;
            transition first thrusters accept ArraysDeployed via command then wheels;
            transition first wheels accept ProximityOperationsGo via command then thrusters;
            transition first thrusters accept DespinComplete via command then wheels;
            transition first wheels accept DockingGo via command then thrusters;
            transition first thrusters accept DisposalGo via command then wheels;
            transition first wheels accept SafeModeRequest then thrusters;
            transition first thrusters accept SafeModeExit via command then wheels;
        }

        state captureMechanism {
            doc /* Capture bag: stowed until CaptureGo, deployed during capture, cinched on
                 * completion, released at disposal. */
            entry; then stowed;
            state stowed;
            state deployed;
            state cinched;
            state released;
            transition first stowed accept CaptureGo via command then deployed;
            transition first deployed accept CaptureComplete via command then cinched;
            transition first cinched accept DisposalGo via command then released;
        }
    }

    // ---- 4. Inspector mode machine ------------------------------------------------------
    state def InspectorModes {
        doc /* Wren's modes: stowed on the tug's dispenser (umbilical power) through checkout,
             * free flight after release, imaging passes, a retreat on collision risk, safe
             * mode, and retirement. Commands reach it through the tug's proximity relay on
             * `command`. */
        port command : CommandPort;
        attribute keepOutRadius : LengthValue = 200.0 [m];
        attribute checkoutDuration : DurationValue = 4.0 [h];
        attribute retreatDuration : DurationValue = 6.0 [h];
        attribute checkedOut : Boolean = false;
        attribute imagingPasses : Natural = 0;

        entry; then stowed;
        state stowed;
        state checkout {
            exit assign checkedOut := true;
        }
        state freeFlight {
            entry; then stationKeeping;
            state stationKeeping;
            state imaging {
                entry assign imagingPasses := imagingPasses + 1;
            }
            state retreat;
            transition first stationKeeping accept InspectorImagingGo via command then imaging;
            transition first imaging accept after 8.0 [h] then stationKeeping;
            transition first stationKeeping accept c : CollisionRisk via command if c.predictedMiss < keepOutRadius then retreat;
            transition first imaging accept c : CollisionRisk via command if c.predictedMiss < keepOutRadius then retreat;
            transition first retreat accept after retreatDuration then stationKeeping;
        }
        state safe;
        state retired;

        transition first stowed accept InspectorCheckoutGo via command then checkout;
        transition first checkout accept after checkoutDuration then stowed;
        transition first stowed accept InspectorReleaseGo via command if checkedOut then freeFlight;
        transition first freeFlight accept SafeModeRequest then safe;
        transition first safe accept SafeModeExit via command then freeFlight;
        transition first freeFlight accept InspectorRetireGo via command then retired;
        transition first retired then done;
    }

    // ---- 5. Vehicles that exhibit the machines, and the nominal-flight scenario ---------
    part def ModedTug :> Tug {
        doc /* The Argent tug with its mode machine; `command` is the tug end of the uplink. */
        port command : CommandPort;
        exhibit state modes : TugModes;
    }
    part def ModedInspector :> Inspector {
        doc /* The Wren inspector with its mode machine; `command` is the relay end. */
        port command : CommandPort;
        exhibit state modes : InspectorModes;
    }

    attribute def TargetEstimate {
        doc /* A characterised target estimate as delivered to CaptureGo: the mass and diameter
             * of one case of the target-case table (TethysTarget::targetCases). */
        attribute estimatedDiameter : LengthValue;
        attribute estimatedMass : MassValue;
    }
    attribute smallTarget : TargetEstimate {
        doc /* The small design case: 5.7 m, about 213 t. */
        :>> estimatedDiameter = targetCases.small.meanDiameter;
        :>> estimatedMass = targetCases.small.mass;
    }
    attribute nominalTarget : TargetEstimate {
        doc /* The nominal case: Amaranth as catalogued, 6.8 m and 362 t. */
        :>> estimatedDiameter = targetCases.nominal.meanDiameter;
        :>> estimatedMass = targetCases.nominal.mass;
    }
    attribute largeTarget : TargetEstimate {
        doc /* The large design case: 7.6 m, about 506 t — inside the commit envelope, so the
             * mode machine accepts CaptureGo. */
        :>> estimatedDiameter = targetCases.large.meanDiameter;
        :>> estimatedMass = targetCases.large.mass;
    }
    attribute denseTarget : TargetEstimate {
        doc /* The densest knowledge bound: 6.8 m, about 576 t — inside the bag but over the
             * return envelope, so the mode machine refuses CaptureGo and retreats. */
        :>> estimatedDiameter = targetCases.densest.meanDiameter;
        :>> estimatedMass = targetCases.densest.mass;
    }

    part def OperationsCentre {
        doc /* The Meridian operations centre as a command source: its campaign is the
             * sequence of telecommands and (for the executed scenario) the on-board events
             * it expects, on a compressed clock in days. */
        port tugUplink : ~CommandPort;
        port inspectorUplink : ~CommandPort;
        attribute target : TargetEstimate;
        attribute envelope : CaptureCommitEnvelope {
            :>> maximumBodyMass = captureCommitEnvelope.maximumBodyMass;
            :>> maximumBodyDiameter = captureCommitEnvelope.maximumBodyDiameter;
        }

        perform action nominalCampaign {
            doc /* Launch, commissioning, two outbound arcs, approach and rendezvous, inspector
                 * checkout, release and one imaging pass, capture commit with the configured
                 * target estimate — then, if the estimate is inside the envelope, despin, one
                 * return arc, DRO hold, docking and disposal; otherwise a retreat hold. */
            first start;
            then action toSeparation accept after 0.05 [d];
            then action separation send new SeparationConfirmed() via tugUplink;
            then action toDeployment accept after 0.05 [d];
            then action deployment send new ArraysDeployed() via tugUplink;
            then action commissioning accept after 30.0 [d];
            then action arc1 send new ThrustArcGo(plannedDuration = 200.0 [d]) via tugUplink;
            then action arc1Run accept after 200.0 [d];
            then action arc1End send new ThrustArcEnd() via tugUplink;
            then action opNav accept after 20.0 [d];
            then action arc2 send new ThrustArcGo(plannedDuration = 150.0 [d]) via tugUplink;
            then action arc2Run accept after 150.0 [d];
            then action arc2End send new ThrustArcEnd() via tugUplink;
            then action farFieldHold accept after 10.0 [d];
            then action approachGo send new ProximityOperationsGo() via tugUplink;
            then action approachRun accept after 25.0 [d];
            then action rendezvous send new RangeUpdate(range = 20.0 [km]) via tugUplink;
            then action inspectorCheckout send new InspectorCheckoutGo() via inspectorUplink;
            then action checkoutRun accept after 1.0 [d];
            then action inspectorRelease send new InspectorReleaseGo() via inspectorUplink;
            then action relayOn send new InspectorReleaseGo() via tugUplink;
            then action imaging send new InspectorImagingGo(passDuration = 8.0 [h]) via inspectorUplink;
            then action characterisation accept after 14.0 [d];
            then action inspectorRetire send new InspectorRetireGo() via inspectorUplink;
            then action relayOff send new InspectorRetireGo() via tugUplink;
            then action captureCommit send new CaptureGo(estimatedMass = target.estimatedMass, estimatedDiameter = target.estimatedDiameter) via tugUplink;
            then decide captureOutcome;
                if target.estimatedMass > envelope.maximumBodyMass or target.estimatedDiameter > envelope.maximumBodyDiameter then retreatHold;
                else captureRun;
            action retreatHold {
                doc /* The tug refused the commit and retreated: hold at the retreat range and
                     * wait for a replan; the campaign ends here. */
            }
            then done;
            action captureRun accept after 3.0 [d];
            then action captureDone send new CaptureComplete() via tugUplink;
            then action despinRun accept after 10.0 [d];
            then action despinDone send new DespinComplete() via tugUplink;
            then action returnArc send new ReturnThrustGo(plannedDuration = 400.0 [d]) via tugUplink;
            then action returnArcRun accept after 400.0 [d];
            then action returnArcEnd send new ThrustArcEnd() via tugUplink;
            then action lunarAssistAndInsertion accept after 60.0 [d];
            then action droHold send new DroHoldGo() via tugUplink;
            then action checkout accept after 30.0 [d];
            then action docking send new DockingGo() via tugUplink;
            then action utilisation accept after 180.0 [d];
            then action disposal send new DisposalGo() via tugUplink;
            then done;
        }
    }

    part def FlightScenario {
        doc /* A tug and an inspector under one operations centre; the pinned runs execute
             * the centre's campaign against the mode machines. */
        part tug : ModedTug;
        part inspector : ModedInspector;
        part operations : OperationsCentre;
        interface tugLink : CommandLink connect operations.tugUplink to tug.command;
        interface inspectorLink : CommandLink connect operations.inspectorUplink to inspector.command;
    }
    part nominalFlight : FlightScenario {
        doc /* The nominal campaign against the nominal target estimate: capture is accepted. */
        part :>> operations { attribute :>> target = nominalTarget; }
    }
    part denseTargetFlight : FlightScenario {
        doc /* The same campaign against the densest target estimate: CaptureGo is refused on
             * the return envelope and the tug retreats; the stacked modes are never entered. */
        part :>> operations { attribute :>> target = denseTarget; }
    }
}
