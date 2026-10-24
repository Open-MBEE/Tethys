// Mission tier: the executable behaviour of the Argent flight software applications — one state
// machine per application that has modes, the sequencing engine as action definitions, the FDIR
// supervisor exhibited by the FDIR application, and the scenarios that drive them with the same
// event scripts as the system-level modes and FDIR runs.
package TethysFlightBehaviour {
    doc /* Behaviour of the flight software of TethysFlightSoftware: what each application does
         * with the commands and events the backbone delivers. Each application part exhibits one
         * state machine bound to the application's ports; the mode manager realises TugModes and
         * dispatches application commands to the other applications over the software's command
         * links; the FDIR application exhibits the system supervisor itself, so the fault
         * scenarios of TethysFdir drive the software machine unchanged. Sends from a state
         * machine leave through the exhibiting application's own port (an inline state usage),
         * the one route the pinned toolchain executes; the receiving machines are state
         * definitions whose port the application binds explicitly. */
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SequenceFunctions::includes;
    private import TethysTugStructure::TugMode;
    private import TethysTugStructure::allFlightModes;
    private import TethysModes::*;
    private import TethysFdir::*;
    private import TethysFlightSoftware::*;
    private import TethysSequence::OnBoardSequence;

    // ---- 1. Application command and event vocabulary ------------------------------------
    item def ApplicationCommand :> OnBoardEvent {
        doc /* A command one application issues to another over the software's command links.
             * Defined here until the flight dictionary exists; each literal command below is to
             * be redefined from TethysFlightDictionary at integration. */
    }
    item def SepStandby :> ApplicationCommand {
        doc /* Bring the SEP string to standby: high-voltage bus on, no thrust. To be redefined
             * from TethysFlightDictionary. */
    }
    item def SepThrust :> ApplicationCommand {
        doc /* Start a thrust arc on the operating thruster set. To be redefined from
             * TethysFlightDictionary. */
    }
    item def SepOff :> ApplicationCommand {
        doc /* Thrusters and high-voltage bus off. To be redefined from TethysFlightDictionary. */
    }
    item def HighGainSelect :> ApplicationCommand {
        doc /* Select the high-gain antenna and the nominal telemetry rate. To be redefined from
             * TethysFlightDictionary. */
    }
    item def LowGainSelect :> ApplicationCommand {
        doc /* Select the low-gain antenna and the safe telemetry rate. To be redefined from
             * TethysFlightDictionary. */
    }
    item def RelayEnable :> ApplicationCommand {
        doc /* Enable the proximity relay link to Wren. To be redefined from
             * TethysFlightDictionary. */
    }
    item def RelayDisable :> ApplicationCommand {
        doc /* Disable the proximity relay link. To be redefined from TethysFlightDictionary. */
    }
    item def PassStart :> ApplicationCommand {
        doc /* A Meridian pass begins: the transponder is locked. To be redefined from
             * TethysFlightDictionary. */
    }
    item def PassEnd :> ApplicationCommand {
        doc /* The pass ends. To be redefined from TethysFlightDictionary. */
    }
    enum def LoadShedTier {
        doc /* The load-shedding tiers of the power manager, lightest first. */
        none;
        tierOne;
        tierTwo;
        survival;
    }
    item def LoadShed :> ApplicationCommand {
        doc /* Shed loads down to the survival set. To be redefined from TethysFlightDictionary. */
    }
    item def LoadRestore :> ApplicationCommand {
        doc /* Restore the loads of the current mode. To be redefined from
             * TethysFlightDictionary. */
    }
    item def BatteryStateOfCharge :> ApplicationCommand {
        doc /* The battery state of charge the power units report, as a fraction. To be
             * redefined from TethysFlightDictionary. */
        attribute fraction : Real;
    }
    item def TemperatureReport :> ApplicationCommand {
        doc /* One heater zone's temperature as its sensor reports it. To be redefined from
             * TethysFlightDictionary. */
        attribute zone : Natural;
        attribute temperature : TemperatureValue;
    }
    item def CaptureArm :> ApplicationCommand {
        doc /* Arm the capture mechanism: the first of the three cinch inhibits. To be redefined
             * from TethysFlightDictionary. */
    }
    item def GroundEnable :> ApplicationCommand {
        doc /* The ground enable for the cinch: the second inhibit. To be redefined from
             * TethysFlightDictionary. */
    }
    item def CaptureDisarm :> ApplicationCommand {
        doc /* Disarm the capture mechanism and clear every inhibit. To be redefined from
             * TethysFlightDictionary. */
    }
    item def ContactDetected :> ApplicationCommand {
        doc /* The contact sensors report the body against the mechanism. To be redefined from
             * TethysFlightDictionary. */
        attribute force : ForceValue;
    }
    item def SequenceStart :> ApplicationCommand {
        doc /* Start a stored sequence by number. To be redefined from TethysFlightDictionary. */
        attribute sequenceId : Natural;
    }
    item def SequenceAbort :> ApplicationCommand {
        doc /* Abort the running sequence. To be redefined from TethysFlightDictionary. */
    }
    item def Heartbeat :> ApplicationCommand {
        doc /* The active flight computer's heartbeat on the cross-strap. To be redefined from
             * TethysFlightDictionary. */
        attribute computer : Natural;
    }
    item def SwitchToRedundant :> ApplicationCommand {
        doc /* Commanded switch-over to the redundant flight computer. To be redefined from
             * TethysFlightDictionary. */
    }
    item def ImageVerify :> ApplicationCommand {
        doc /* The boot/update service reports the image's check value as good. To be redefined
             * from TethysFlightDictionary. */
    }
    item def ImageActivate :> ApplicationCommand {
        doc /* Activate the uploaded image on the next boot. To be redefined from
             * TethysFlightDictionary. */
    }
    item def ImageRollback :> ApplicationCommand {
        doc /* Roll back to the primary image. To be redefined from TethysFlightDictionary. */
    }
    item def RebootCommand :> ApplicationCommand {
        doc /* Reboot the flight computer. To be redefined from TethysFlightDictionary. */
    }
    item def ApplicationReport :> SoftwareEvent {
        doc /* The event report an application emits on its event port: which application and
             * what it did, at subsystem level and not a fault. */
        attribute :>> level = FdirLevel::subsystem;
        attribute :>> isFault = false;
        attribute application : String;
        attribute report : String;
    }
    enum def ImageSlot {
        doc /* The image slots of a flight computer's non-volatile store. */
        primary;
        backup;
        safe;
    }

    // ---- 2. Software links the backbone did not need yet -------------------------------
    interface def EventLink {
        doc /* Carries event reports from an application to the event service. */
        end port source : ~EventPort;
        end port sink : EventPort;
        flow source.raised to sink.raised;
    }
    interface def FaultLink {
        doc /* Carries fault events to the redundancy manager. */
        end port source : ~FaultPort;
        end port sink : FaultPort;
        flow source.fault to sink.fault;
    }
    interface def UpdateLink {
        doc /* Carries image segments to the boot/update application. */
        end port source : ~UpdatePort;
        end port sink : UpdatePort;
        flow source.segment to sink.segment;
    }

    // ---- 3. Application state machines ------------------------------------------------------
    state def SepStringController {
        doc /* The SEP string as the propulsion application drives it: off, standby with the
             * high-voltage bus on, thrusting, and a timed restart after a flameout. */
        port command : CommandPort;
        attribute restartDelay : DurationValue = 2.0 [h];
        attribute arcsStarted : Natural = 0;
        attribute restarts : Natural = 0;
        entry; then off;
        state off;
        state standby;
        state thrusting {
            entry assign arcsStarted := arcsStarted + 1;
        }
        state restarting {
            entry assign restarts := restarts + 1;
        }
        transition first off accept SepStandby via command then standby;
        transition first standby accept SepThrust via command then thrusting;
        transition first thrusting accept SepStandby via command then standby;
        transition first thrusting accept ThrusterFlameout via command then restarting;
        transition first restarting accept after restartDelay then thrusting;
        transition first standby accept SepOff via command then off;
        transition first thrusting accept SepOff via command then off;
        transition first restarting accept SepOff via command then off;
    }
    state def PowerManager {
        doc /* Battery charge control as load-shedding tiers: the state of charge the power
             * units report drops the manager through the tiers and recovery restores the
             * nominal set; a shed command from the mode manager goes straight to survival. The
             * load-shed fraction is the supervisor's battery threshold. */
        port command : CommandPort;
        attribute limits : MonitorLimits = cruiseLimits;
        attribute tierOneFraction : Real = 0.45;
        attribute restoreFraction : Real = 0.60;
        attribute tier : LoadShedTier = LoadShedTier::none;
        attribute shedEvents : Natural = 0;
        entry; then nominal;
        state nominal {
            entry assign tier := LoadShedTier::none;
        }
        state tierOne {
            entry action shedOne { assign tier := LoadShedTier::tierOne; then assign shedEvents := shedEvents + 1; }
        }
        state tierTwo {
            entry action shedTwo { assign tier := LoadShedTier::tierTwo; then assign shedEvents := shedEvents + 1; }
        }
        state survival {
            entry action shedAll { assign tier := LoadShedTier::survival; then assign shedEvents := shedEvents + 1; }
        }
        transition first nominal accept b : BatteryStateOfCharge via command
            if b.fraction < tierOneFraction and b.fraction >= limits.batteryLowFraction then tierOne;
        transition first nominal accept b : BatteryStateOfCharge via command
            if b.fraction < limits.batteryLowFraction then tierTwo;
        transition first tierOne accept b : BatteryStateOfCharge via command
            if b.fraction < limits.batteryLowFraction then tierTwo;
        transition first tierOne accept b : BatteryStateOfCharge via command
            if b.fraction >= restoreFraction then nominal;
        transition first tierTwo accept b : BatteryStateOfCharge via command
            if b.fraction >= restoreFraction then nominal;
        transition first nominal accept LoadShed via command then survival;
        transition first tierOne accept LoadShed via command then survival;
        transition first tierTwo accept LoadShed via command then survival;
        transition first survival accept LoadRestore via command then nominal;
    }
    state def ThermalController parallel {
        doc /* One heater zone's control loop beside its set-point selection: the operational
             * set-point in every operating mode, the survival set-point when loads are shed;
             * the heater switches on below the set-point less the hysteresis band and off above
             * it. */
        port command : CommandPort;
        attribute operationalSetpoint : TemperatureValue = 293.15 [K];
        attribute survivalSetpoint : TemperatureValue = 263.15 [K];
        attribute hysteresis : TemperatureValue = 2.0 [K];
        attribute setpoint : TemperatureValue = 293.15 [K];
        attribute heaterCycles : Natural = 0;
        state setpointSelection {
            entry; then operational;
            state operational {
                entry assign setpoint := operationalSetpoint;
            }
            state survival {
                entry assign setpoint := survivalSetpoint;
            }
            transition first operational accept LoadShed via command then survival;
            transition first survival accept LoadRestore via command then operational;
        }
        state heaterLoop {
            entry; then heaterOff;
            state heaterOff;
            state heaterOn {
                entry assign heaterCycles := heaterCycles + 1;
            }
            transition first heaterOff accept t : TemperatureReport via command
                if t.temperature < setpoint - hysteresis then heaterOn;
            transition first heaterOn accept t : TemperatureReport via command
                if t.temperature > setpoint + hysteresis then heaterOff;
        }
    }
    state def TelecomManager {
        doc /* Antenna and rate management: low-gain at the safe rate, high-gain between and
             * during Meridian passes, the proximity relay to Wren, and a pass that ends by
             * command or after its planned duration. */
        port command : CommandPort;
        attribute passDuration : DurationValue = 8.0 [h];
        attribute passes : Natural = 0;
        attribute safeRateEntries : Natural = 0;
        entry; then safeRate;
        state safeRate {
            entry assign safeRateEntries := safeRateEntries + 1;
        }
        state highGainIdle;
        state pass {
            entry assign passes := passes + 1;
        }
        state relaying;
        transition first safeRate accept HighGainSelect via command then highGainIdle;
        transition first highGainIdle accept PassStart via command then pass;
        transition first pass accept PassEnd via command then highGainIdle;
        transition first pass accept after passDuration then highGainIdle;
        transition first highGainIdle accept RelayEnable via command then relaying;
        transition first relaying accept RelayDisable via command then highGainIdle;
        transition first highGainIdle accept LowGainSelect via command then safeRate;
        transition first pass accept LowGainSelect via command then safeRate;
        transition first relaying accept LowGainSelect via command then safeRate;
    }
    state def InspectorHandler {
        doc /* Wren's handling from the tug's side: checkout in the cradle, release once checked
             * out, imaging campaigns relayed to the ground, retirement. */
        port command : CommandPort;
        attribute checkoutDuration : DurationValue = 4.0 [h];
        attribute checkedOut : Boolean = false;
        attribute imagingCampaigns : Natural = 0;
        entry; then stowed;
        state stowed;
        state checkout {
            exit assign checkedOut := true;
        }
        state released;
        state relayingImagery {
            entry assign imagingCampaigns := imagingCampaigns + 1;
        }
        state retired;
        transition first stowed accept InspectorCheckoutGo via command then checkout;
        transition first checkout accept after checkoutDuration then stowed;
        transition first stowed accept InspectorReleaseGo via command if checkedOut then released;
        transition first released accept InspectorImagingGo via command then relayingImagery;
        transition first relayingImagery accept after 8.0 [h] then released;
        transition first released accept InspectorRetireGo via command then retired;
        transition first relayingImagery accept InspectorRetireGo via command then retired;
    }
    state def CaptureController {
        doc /* The capture controller realising TethysProximityOps::CaptureSequence in software:
             * characterising until armed, committed on CaptureGo, waiting for contact, the cinch
             * through the three-inhibit gate of TethysFdir::ArmAndFireCaptureCinch, despin to
             * its duration. The inhibits are the controller's own attributes, written by the
             * transitions that arm, enable and commit, so `noFireWithoutInhibits` is a property
             * of the machine the checker can explore. */
        port command : CommandPort;
        attribute despinDuration : DurationValue = 2.0 [h];
        attribute armCommanded : Boolean = false;
        attribute groundEnable : Boolean = false;
        attribute inCaptureMode : Boolean = false;
        attribute fired : Boolean = false;
        attribute cinchAttempts : Natural = 0;
        entry; then characterising;
        state characterising;
        state armed;
        state committed;
        state cinching {
            entry action cinchFire {
                assign cinchAttempts := cinchAttempts + 1;
                then action fire : ArmAndFireCaptureCinch {
                    in armCommanded = CaptureController::armCommanded;
                    in groundEnable = CaptureController::groundEnable;
                    in inCaptureMode = CaptureController::inCaptureMode;
                }
                then assign fired := fire.fired;
            }
        }
        state inhibited;
        state despinning;
        state captured;
        assert constraint noFireWithoutInhibits : NoFireWithoutInhibitsRemoved {
            in fired = CaptureController::fired;
            in armCommanded = CaptureController::armCommanded;
            in groundEnable = CaptureController::groundEnable;
            in inCaptureMode = CaptureController::inCaptureMode;
        }
        transition first characterising accept CaptureArm via command do assign armCommanded := true then armed;
        transition first armed accept GroundEnable via command do assign groundEnable := true then armed;
        transition first armed accept CaptureGo via command do assign inCaptureMode := true then committed;
        transition first characterising accept GroundEnable via command do assign groundEnable := true then characterising;
        transition first characterising accept ContactDetected via command then cinching;
        transition first armed accept ContactDetected via command then cinching;
        transition first committed accept ContactDetected via command then cinching;
        transition first cinching if fired then despinning;
        transition first cinching if not fired then inhibited;
        transition first despinning accept after despinDuration then captured;
        transition first inhibited accept CaptureDisarm via command do action clear {
            assign armCommanded := false; then assign groundEnable := false; then assign inCaptureMode := false; } then characterising;
        transition first armed accept CaptureDisarm via command do action clearArmed {
            assign armCommanded := false; then assign groundEnable := false; then assign inCaptureMode := false; } then characterising;
        transition first committed accept CaptureDisarm via command do action clearCommitted {
            assign armCommanded := false; then assign groundEnable := false; then assign inCaptureMode := false; } then characterising;
    }
    state def RedundancyManager {
        doc /* Fail-over between the prime and redundant flight computers: the active computer's
             * heartbeat re-arms a timer, and a processor reset, a commanded switch or a missed
             * heartbeat hands over to the other computer after the switch-over time; a second
             * computer lost leaves the subsystem on whichever computer still runs. */
        port faults : FaultPort;
        port command : CommandPort;
        attribute heartbeatTimeout : DurationValue = 60.0 [s];
        attribute switchoverDuration : DurationValue = 30.0 [s];
        attribute switchovers : Natural = 0;
        attribute primeHealthy : Boolean = true;
        attribute redundantHealthy : Boolean = true;
        entry; then primeActive;
        state primeActive;
        state switchingToRedundant {
            entry assign switchovers := switchovers + 1;
        }
        state redundantActive;
        state switchingToPrime {
            entry assign switchovers := switchovers + 1;
        }
        state lastComputer;
        transition first primeActive accept Heartbeat via command then primeActive;
        transition first primeActive accept ProcessorReset via faults do assign primeHealthy := false then switchingToRedundant;
        transition first primeActive accept SwitchToRedundant via command then switchingToRedundant;
        transition first primeActive accept after heartbeatTimeout do assign primeHealthy := false then switchingToRedundant;
        transition first switchingToRedundant accept after switchoverDuration then redundantActive;
        transition first redundantActive accept Heartbeat via command then redundantActive;
        transition first redundantActive accept ProcessorReset via faults if primeHealthy
            do assign redundantHealthy := false then switchingToPrime;
        transition first redundantActive accept ProcessorReset via faults if not primeHealthy
            do assign redundantHealthy := false then lastComputer;
        transition first redundantActive accept after heartbeatTimeout if primeHealthy
            do assign redundantHealthy := false then switchingToPrime;
        transition first redundantActive accept after heartbeatTimeout if not primeHealthy
            do assign redundantHealthy := false then lastComputer;
        transition first switchingToPrime accept after switchoverDuration then primeActive;
    }
    state def BootUpdateManager {
        doc /* Boot and software update: the boot ROM loads the active slot's image, runs it once
             * its check value is reported good and falls back to the safe image when the load
             * times out; while running, uplinked segments fill the inactive slot, a verified
             * upload is activated by a reboot, and a roll-back returns to the primary image. */
        port update : UpdatePort;
        port command : CommandPort;
        attribute bootTimeout : DurationValue = 120.0 [s];
        attribute activeSlot : ImageSlot = ImageSlot::primary;
        attribute boots : Natural = 0;
        attribute fallbacks : Natural = 0;
        attribute segmentsReceived : Natural = 0;
        attribute uploadVerified : Boolean = false;
        entry; then bootRom;
        state bootRom {
            entry assign boots := boots + 1;
        }
        state loadingImage;
        state running;
        state safeImage {
            entry action fallBack { assign activeSlot := ImageSlot::safe; then assign fallbacks := fallbacks + 1; }
        }
        state receivingUpdate;
        state uploadVerifiedIdle;
        transition first bootRom accept after 5.0 [s] then loadingImage;
        transition first loadingImage accept ImageVerify via command then running;
        transition first loadingImage accept after bootTimeout then safeImage;
        transition first running accept ImageSegment via update do assign segmentsReceived := segmentsReceived + 1 then receivingUpdate;
        transition first receivingUpdate accept ImageSegment via update do assign segmentsReceived := segmentsReceived + 1 then receivingUpdate;
        transition first receivingUpdate accept ImageVerify via command do assign uploadVerified := true then uploadVerifiedIdle;
        transition first uploadVerifiedIdle accept ImageActivate via command do assign activeSlot := ImageSlot::backup then bootRom;
        transition first running accept RebootCommand via command then bootRom;
        transition first safeImage accept ImageRollback via command do assign activeSlot := ImageSlot::primary then bootRom;
        transition first safeImage accept RebootCommand via command then bootRom;
    }

    // ---- 4. The sequencing engine ----------------------------------------------------------
    // The sequences it loads are TethysSequence::OnBoardSequence and its specialisations.
    action def LoadSequence {
        doc /* Load a stored sequence by number: it loads when the store holds it. */
        in sequenceId : Natural;
        in storedSequences : Natural[*];
        out loaded : Boolean = storedSequences->includes(sequenceId);
    }
    action def CheckConstraints {
        doc /* The pre-dispatch constraint check: the vehicle is in a mode the sequence allows
             * and the power margin is not negative. */
        in mode : TugMode;
        in allowedModes : TugMode[*];
        in powerMarginFraction : Real;
        out passed : Boolean = allowedModes->includes(mode) and powerMarginFraction >= 0.0;
    }
    action def DispatchTimeTagged {
        doc /* Hold the first step until its time tag, then release it. */
        in releaseDelay : DurationValue;
        out dispatched : Boolean = false;
        first start;
        then action waitForTag accept after releaseDelay;
        then assign dispatched := true;
        then done;
    }
    action def AbortSequence {
        doc /* Abort: mark the sequence aborted with the reason the engine gives. */
        in reason : String;
        out aborted : Boolean = false;
        out abortReason : String = "";
        first start;
        then assign aborted := true;
        then assign abortReason := reason;
        then done;
    }
    action def SequenceRun {
        doc /* One pass of the sequencing engine: load one of the stored sequences (the
             * TethysSequence::OnBoardSequence numbers 1 to 6), check constraints, then dispatch
             * the first time-tagged step or abort. */
        in sequenceId : Natural;
        in mode : TugMode;
        in releaseDelay : DurationValue;
        attribute storedSequences : Natural[*] = (1, 2, 3, 4, 5, 6);
        attribute allowedModes : TugMode[*] = allFlightModes;
        out outcome : String = "";
        first start;
        then action load : LoadSequence {
            in sequenceId = SequenceRun::sequenceId;
            in storedSequences = SequenceRun::storedSequences;
        }
        then action check : CheckConstraints {
            in mode = SequenceRun::mode;
            in allowedModes = SequenceRun::allowedModes;
            in powerMarginFraction = 0.1;
        }
        then decide;
            if load.loaded and check.passed then dispatch;
            else abort;
        action dispatch : DispatchTimeTagged {
            in releaseDelay = SequenceRun::releaseDelay;
        }
        then assign outcome := "dispatched";
        then done;
        action abort : AbortSequence {
            in reason = "sequence not stored or constraints failed";
        }
        then assign outcome := abort.abortReason;
        then done;
    }

    // ---- 5. The applications with their machines --------------------------------------------
    part def SepControlSoftware :> SepControlApplication {
        doc /* The propulsion application exhibiting the SEP string controller. */
        port command : CommandPort;
        exhibit state controller : SepStringController;
        bind controller.command = command;
    }
    part def PowerManagementSoftware :> PowerManagementApplication {
        doc /* The power application exhibiting the load-shedding power manager. */
        port command : CommandPort;
        exhibit state manager : PowerManager;
        bind manager.command = command;
    }
    part def ThermalControlSoftware :> ThermalControlApplication {
        doc /* The thermal application exhibiting one heater zone's control loop. */
        port command : CommandPort;
        exhibit state controller : ThermalController;
        bind controller.command = command;
    }
    part def TelecomSoftware :> TelecomApplication {
        doc /* The telecom application exhibiting the antenna and rate manager. */
        port command : CommandPort;
        exhibit state manager : TelecomManager;
        bind manager.command = command;
    }
    part def InspectorHandlingSoftware :> InspectorHandlingApplication {
        doc /* The inspector application exhibiting Wren's handling machine. */
        port command : CommandPort;
        exhibit state handler : InspectorHandler;
        bind handler.command = command;
    }
    part def CaptureControlSoftware :> CaptureControlApplication {
        doc /* The capture application exhibiting the capture controller; the controller's
             * inhibits are the software interlocks of the inhibit chain. */
        port command : CommandPort;
        exhibit state controller : CaptureController;
        bind controller.command = command;
    }
    part def AutonomySoftware :> AutonomyApplication {
        doc /* The autonomy application running the sequencing engine. */
        port command : CommandPort;
        perform action engine : SequenceRun {
            in sequenceId = 2;
            in mode = TugMode::coast;
            in releaseDelay = 600.0 [s];
        }
    }
    part def FdirSoftware :> FdirApplication {
        doc /* The FDIR application exhibiting the system supervisor: the monitor regions of
             * TethysFdir::FdirSupervisor run in software against the limit table the
             * application holds (to be read from TethysFlightDictionary at integration). */
        port command : CommandPort;
        port supervisorRequests : ~CommandPort;
        attribute limitTable : MonitorLimits = cruiseLimits;
        exhibit state supervisor : FdirSupervisor {
            attribute :>> limits = limitTable;
        }
        bind supervisor.command = command;
        exhibit state responseRelay {
            doc /* The supervisor raises its requests on the application itself; the relay
                 * forwards each one to the mode manager over the request link. */
            attribute relayed : Natural = 0;
            entry; then relaying;
            state relaying;
            transition first relaying accept r : SafeModeRequest do action relaySafeMode {
                send new SafeModeRequest(reason = r.reason) via supervisorRequests;
                then assign relayed := relayed + 1;
            } then relaying;
            transition first relaying accept a : AbortReturn do action relayAbort {
                send new AbortReturn(reason = a.reason) via supervisorRequests;
                then assign relayed := relayed + 1;
            } then relaying;
        }
    }
    part def ParameterBootUpdateSoftware :> ParameterBootUpdateApplication {
        doc /* The boot/update application exhibiting the boot and update manager. */
        port command : CommandPort;
        exhibit state manager : BootUpdateManager;
        bind manager.update = update;
        bind manager.command = command;
    }
    part def ModeManagementSoftware :> ModeManagementApplication {
        doc /* The mode manager: TugModes exhibited as the software mode machine on `command`,
             * beside the dispatcher that turns each mode command it receives on `dispatch`
             * (the command ingest's second copy of the uplink) into the application commands
             * the mode's SubsystemConfiguration row implies and reports each dispatch on the
             * event port. FDIR requests arrive on `fdirRequests`; the dispatcher raises them on
             * the application for the mode machine and sheds the applications. */
        port dispatch : CommandPort;
        port fdirRequests : CommandPort;
        port sepCommands : ~CommandPort;
        port telecomCommands : ~CommandPort;
        port powerCommands : ~CommandPort;
        port thermalCommands : ~CommandPort;
        port captureCommands : ~CommandPort;
        port inspectorCommands : ~CommandPort;
        port autonomyCommands : ~CommandPort;
        exhibit state modes : TugModes;
        bind modes.command = command;
        exhibit state dispatcher {
            attribute dispatched : Natural = 0;
            entry; then dispatching;
            state dispatching;
            transition first dispatching accept ArraysDeployed via dispatch do action earlyOperations {
                send new SepStandby() via sepCommands;
                then send new HighGainSelect() via telecomCommands;
                then send new LoadRestore() via powerCommands;
                then send new ApplicationReport(application = "ModeManagementApplication", report = "early operations") via events;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept ThrustArcGo via dispatch do action thrustArc {
                send new SepThrust() via sepCommands;
                then send new LowGainSelect() via telecomCommands;
                then send new ApplicationReport(application = "ModeManagementApplication", report = "thrust arc") via events;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept ThrustArcEnd via dispatch do action coast {
                send new SepStandby() via sepCommands;
                then send new HighGainSelect() via telecomCommands;
                then send new ApplicationReport(application = "ModeManagementApplication", report = "coast") via events;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept ProximityOperationsGo via dispatch do action approach {
                send new SepThrust() via sepCommands;
                then send new ApplicationReport(application = "ModeManagementApplication", report = "approach") via events;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept RangeUpdate via dispatch do action proximityOperations {
                send new SepStandby() via sepCommands;
                then send new RelayEnable() via telecomCommands;
                then send new ApplicationReport(application = "ModeManagementApplication", report = "proximity operations") via events;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept CaptureGo via dispatch do action capture {
                send new CaptureArm() via captureCommands;
                then send new SequenceStart(sequenceId = 3) via autonomyCommands;
                then send new ApplicationReport(application = "ModeManagementApplication", report = "capture") via events;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept CaptureComplete via dispatch do action despin {
                send new CaptureDisarm() via captureCommands;
                then send new RelayDisable() via telecomCommands;
                then send new ApplicationReport(application = "ModeManagementApplication", report = "despin") via events;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept ReturnThrustGo via dispatch do action stackThrust {
                send new SepThrust() via sepCommands;
                then send new LowGainSelect() via telecomCommands;
                then send new ApplicationReport(application = "ModeManagementApplication", report = "stack thrust") via events;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept DockingGo via dispatch do action docking {
                send new RelayEnable() via telecomCommands;
                then send new ApplicationReport(application = "ModeManagementApplication", report = "docking") via events;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept DisposalGo via dispatch do action disposal {
                send new SepThrust() via sepCommands;
                then send new RelayDisable() via telecomCommands;
                then send new ApplicationReport(application = "ModeManagementApplication", report = "disposal") via events;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept InspectorCheckoutGo via dispatch do action inspectorCheckout {
                send new InspectorCheckoutGo() via inspectorCommands;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept InspectorReleaseGo via dispatch do action inspectorRelease {
                send new InspectorReleaseGo() via inspectorCommands;
                then send new RelayEnable() via telecomCommands;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept InspectorRetireGo via dispatch do action inspectorRetire {
                send new InspectorRetireGo() via inspectorCommands;
                then send new RelayDisable() via telecomCommands;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept r : SafeModeRequest via fdirRequests do action safe {
                send new SafeModeRequest(reason = r.reason);
                then send new SepOff() via sepCommands;
                then send new LowGainSelect() via telecomCommands;
                then send new LoadShed() via powerCommands;
                then send new LoadShed() via thermalCommands;
                then send new CaptureDisarm() via captureCommands;
                then send new SequenceAbort() via autonomyCommands;
                then send new ApplicationReport(application = "ModeManagementApplication", report = "safe mode") via events;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept SafeModeExit via dispatch do action recover {
                send new SepStandby() via sepCommands;
                then send new HighGainSelect() via telecomCommands;
                then send new LoadRestore() via powerCommands;
                then send new LoadRestore() via thermalCommands;
                then send new ApplicationReport(application = "ModeManagementApplication", report = "safe mode exit") via events;
                then assign dispatched := dispatched + 1;
            } then dispatching;
            transition first dispatching accept a : AbortReturn via fdirRequests do action abortHold {
                send new AbortReturn(reason = a.reason);
                then send new SepOff() via sepCommands;
                then send new HighGainSelect() via telecomCommands;
                then send new SequenceAbort() via autonomyCommands;
                then send new ApplicationReport(application = "ModeManagementApplication", report = "abort hold") via events;
                then assign dispatched := dispatched + 1;
            } then dispatching;
        }
    }

    // ---- 6. The software product, computer and tug with behaviour ------------------------
    part def BehaviouralFlightSoftware :> ArgentFlightSoftware {
        doc /* Argent's flight software with every application exhibiting its machine, the mode
             * manager's command links to the applications it commands, and the applications'
             * event reports flowing to the event service. */
        part :>> sepControl : SepControlSoftware;
        part :>> powerManagement : PowerManagementSoftware;
        part :>> thermalControl : ThermalControlSoftware;
        part :>> telecom : TelecomSoftware;
        part :>> inspectorHandling : InspectorHandlingSoftware;
        part :>> captureControl : CaptureControlSoftware;
        part :>> autonomy : AutonomySoftware;
        part :>> fdir : FdirSoftware;
        part :>> modeManagement : ModeManagementSoftware;
        part :>> parameterBootUpdate : ParameterBootUpdateSoftware;
        interface sepCommandLink : CommandLink connect modeManagement.sepCommands to sepControl.command;
        interface telecomCommandLink : CommandLink connect modeManagement.telecomCommands to telecom.command;
        interface powerCommandLink : CommandLink connect modeManagement.powerCommands to powerManagement.command;
        interface thermalCommandLink : CommandLink connect modeManagement.thermalCommands to thermalControl.command;
        interface captureCommandLink : CommandLink connect modeManagement.captureCommands to captureControl.command;
        interface inspectorCommandLink : CommandLink connect modeManagement.inspectorCommands to inspectorHandling.command;
        interface autonomyCommandLink : CommandLink connect modeManagement.autonomyCommands to autonomy.command;
        interface fdirRequests : CommandLink connect fdir.supervisorRequests to modeManagement.fdirRequests;
        interface modeManagementEvents : EventLink connect modeManagement.events to events.events;
    }
    part def BehaviouralCdh :> CdhWithSoftware {
        doc /* The command and data handling subsystem running the behavioural software, with
             * the redundancy manager exhibited by the subsystem that owns both computers. */
        part :>> software : BehaviouralFlightSoftware;
        port faults : FaultPort;
        port command : CommandPort;
        exhibit state redundancy : RedundancyManager;
        bind redundancy.faults = faults;
        bind redundancy.command = command;
    }
    part def BehaviouralTug :> FdirTug, SoftwareTug {
        doc /* Argent with its system-level mode machine and FDIR supervisor beside the flight
             * software that realises them. */
        part :>> cdh : BehaviouralCdh;
    }

    // ---- 7. Scenarios: the same event scripts drive the software machines -----------------
    part def SoftwareFlightScenario {
        doc /* A behavioural tug and an inspector under one operations centre: the uplink
             * reaches the tug's command port and the software's mode manager and FDIR
             * application, so one campaign drives the system machines and the software. */
        part tug : BehaviouralTug;
        part inspector : ModedInspector;
        part operations : OperationsCentre;
        interface tugLink : CommandLink connect operations.tugUplink to tug.command;
        interface inspectorLink : CommandLink connect operations.inspectorUplink to inspector.command;
        interface modeManagerLink : CommandLink connect operations.tugUplink to tug.cdh.software.modeManagement.command;
        interface dispatchLink : CommandLink connect operations.tugUplink to tug.cdh.software.modeManagement.dispatch;
        interface fdirLink : CommandLink connect operations.tugUplink to tug.cdh.software.fdir.command;
    }
    part softwareNominalFlight : SoftwareFlightScenario {
        doc /* The nominal campaign of TethysModes against the nominal target estimate. */
        part :>> operations { attribute :>> target = nominalTarget; }
    }
    part def SoftwareFaultScenario {
        doc /* A behavioural tug under one fault injector whose uplink reaches the tug and the
             * software's mode manager, FDIR and propulsion applications. */
        part tug : BehaviouralTug;
        part injector : FaultInjector;
        interface link : CommandLink connect injector.uplink to tug.command;
        interface modeManagerLink : CommandLink connect injector.uplink to tug.cdh.software.modeManagement.command;
        interface dispatchLink : CommandLink connect injector.uplink to tug.cdh.software.modeManagement.dispatch;
        interface fdirLink : CommandLink connect injector.uplink to tug.cdh.software.fdir.command;
        interface sepLink : CommandLink connect injector.uplink to tug.cdh.software.sepControl.command;
    }
    part softwareCommandLoss : SoftwareFaultScenario {
        doc /* The command-loss scenario of TethysFdir on the software. */
        part :>> injector : CommandLossInjector;
    }
    part softwareThrusterFault : SoftwareFaultScenario {
        doc /* The thruster-fault scenario of TethysFdir on the software. */
        part :>> injector : ThrusterFaultInjector;
    }
    part def CaptureConductor {
        doc /* A test conductor on the capture controller's command port. */
        port uplink : ~CommandPort;
    }
    part def NominalCaptureConductor :> CaptureConductor {
        doc /* Arms, enables and commits the capture controller, then reports contact. */
        perform action script {
            first start;
            then action toArm accept after 60.0 [s];
            then action arm send new CaptureArm() via uplink;
            then action toEnable accept after 60.0 [s];
            then action enable send new GroundEnable() via uplink;
            then action toCommit accept after 60.0 [s];
            then action commit send new CaptureGo(estimatedMass = 4.0e5 [kg], estimatedDiameter = 6.0 [m]) via uplink;
            then action toContact accept after 3600.0 [s];
            then action contact send new ContactDetected(force = 1200.0 [N]) via uplink;
            then done;
        }
    }
    part def PrematureContactConductor :> CaptureConductor {
        doc /* Reports contact before the ground enable: the cinch must hold. */
        perform action script {
            first start;
            then action toArm accept after 60.0 [s];
            then action arm send new CaptureArm() via uplink;
            then action toContact accept after 60.0 [s];
            then action contact send new ContactDetected(force = 1200.0 [N]) via uplink;
            then done;
        }
    }
    part def CaptureScenario {
        doc /* The capture application under one conductor. */
        part captureControl : CaptureControlSoftware;
        part conductor : CaptureConductor;
        interface link : CommandLink connect conductor.uplink to captureControl.command;
    }
    part captureNominal : CaptureScenario {
        doc /* Arm, enable, commit, contact: the cinch fires and the despin runs. */
        part :>> conductor : NominalCaptureConductor;
    }
    part capturePrematureContact : CaptureScenario {
        doc /* Contact before the ground enable: the cinch is inhibited. */
        part :>> conductor : PrematureContactConductor;
    }
    part def BootConductor {
        doc /* A test conductor booting the computer, uploading an image in three segments,
             * verifying and activating it, then rebooting into a load that times out. */
        port update : ~UpdatePort;
        port uplink : ~CommandPort;
        perform action script {
            first start;
            then action toVerify accept after 30.0 [s];
            then action bootVerify send new ImageVerify() via uplink;
            then action toUpload accept after 600.0 [s];
            then action segmentOne send new ImageSegment(offset = 0.0 [B], length = 4.0e6 [B]) via update;
            then action toSegmentTwo accept after 60.0 [s];
            then action segmentTwo send new ImageSegment(offset = 4.0e6 [B], length = 4.0e6 [B]) via update;
            then action toSegmentThree accept after 60.0 [s];
            then action segmentThree send new ImageSegment(offset = 8.0e6 [B], length = 4.0e6 [B]) via update;
            then action toUploadVerify accept after 60.0 [s];
            then action uploadVerify send new ImageVerify() via uplink;
            then action toActivate accept after 60.0 [s];
            then action activate send new ImageActivate() via uplink;
            then action badLoad accept after 600.0 [s];
            then action rollback send new ImageRollback() via uplink;
            then action toFinalVerify accept after 30.0 [s];
            then action finalVerify send new ImageVerify() via uplink;
            then done;
        }
    }
    part bootScenario {
        doc /* The boot/update application under the boot conductor. */
        part bootUpdate : ParameterBootUpdateSoftware;
        part conductor : BootConductor;
        interface updateLink : UpdateLink connect conductor.update to bootUpdate.update;
        interface commandLink : CommandLink connect conductor.uplink to bootUpdate.command;
    }
    part def FailoverConductor {
        doc /* A test conductor keeping the prime computer's heartbeat, resetting it, then
             * letting the redundant computer's heartbeat lapse. */
        port faults : ~FaultPort;
        port uplink : ~CommandPort;
        perform action script {
            first start;
            then action toFirstBeat accept after 30.0 [s];
            then action firstBeat send new Heartbeat(computer = 1) via uplink;
            then action toSecondBeat accept after 30.0 [s];
            then action secondBeat send new Heartbeat(computer = 1) via uplink;
            then action toReset accept after 30.0 [s];
            then action reset send new ProcessorReset(level = FdirLevel::system) via faults;
            then action toRedundantBeat accept after 60.0 [s];
            then action redundantBeat send new Heartbeat(computer = 2) via uplink;
            then action silence accept after 300.0 [s];
            then done;
        }
    }
    part failoverScenario {
        doc /* The command and data handling subsystem under the fail-over conductor. */
        part cdh : BehaviouralCdh;
        part conductor : FailoverConductor;
        interface faultLink : FaultLink connect conductor.faults to cdh.faults;
        interface commandLink : CommandLink connect conductor.uplink to cdh.command;
    }
}
