// Operations products: the command and telemetry dictionary, the flight software's command
// executive, the procedures the operations centre runs against it, the flight rules they obey,
// the pass schedule, the weekly operations timeline, the contingency procedures, readiness
// criteria, health trending, orbit-determination products and the extended-mission replan.
package TethysOperations {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysInterfaces::*;
    private import TethysRequirements::*;
    private import TethysMeridian::*;
    private import TethysIcds::*;
    private import TethysLinkBudgets::LinkBudget;
    private import VerificationCases::VerificationMethodKind;
    private import TethysTugStructure::TugMode;

    // ---- command and telemetry dictionary ---------------------------------------------------
    enum def ApidClass {
        doc /* The application process classes the packet ids are assigned to. */
        enum housekeeping;
        enum guidance;
        enum propulsion;
        enum capture;
        enum relay;
        enum imaging;
    }

    attribute def ApidTable {
        doc /* The application ids assigned to each class; the dictionary check demands they
             * are distinct and in the 11-bit range. */
        attribute housekeeping : Natural = 1;
        attribute guidance : Natural = 2;
        attribute propulsion : Natural = 3;
        attribute capture : Natural = 4;
        attribute relay : Natural = 5;
        attribute imaging : Natural = 6;
    }

    item def Command :> CommandPacket {
        doc /* A command in the dictionary: its opcode and the class it is addressed to. */
        attribute apidClass : ApidClass;
    }
    item def SetMode :> Command {
        doc /* Transition the tug to a commanded mode. */
        attribute :>> opcode = "SET_MODE";
        attribute :>> apidClass = ApidClass::housekeeping;
        attribute mode : TugMode;
    }
    item def StartThrustArc :> Command {
        doc /* Begin a thrust arc of the given duration at the given throttle. */
        attribute :>> opcode = "START_THRUST_ARC";
        attribute :>> apidClass = ApidClass::propulsion;
        attribute arcDuration : DurationValue;
        attribute throttle : Real;
        attribute throttleMinimum : Real = 0.3;
        attribute throttleMaximum : Real = 1.0;
        attribute arcDurationMaximum : DurationValue = 72.0 [h];
        assert constraint throttleInRange { throttle >= throttleMinimum and throttle <= throttleMaximum }
        assert constraint durationInRange { arcDuration <= arcDurationMaximum }
    }
    item def StopThrust :> Command {
        doc /* End the current thrust arc. */
        attribute :>> opcode = "STOP_THRUST";
        attribute :>> apidClass = ApidClass::propulsion;
    }
    item def ReleaseInspector :> Command {
        doc /* Fire the dispenser release. */
        attribute :>> opcode = "RELEASE_INSPECTOR";
        attribute :>> apidClass = ApidClass::relay;
    }
    item def EnableRelay :> Command {
        doc /* Power the proximity link and start forwarding Wren's data. */
        attribute :>> opcode = "ENABLE_RELAY";
        attribute :>> apidClass = ApidClass::relay;
    }
    item def DisableRelay :> Command {
        doc /* Stop the proximity link. */
        attribute :>> opcode = "DISABLE_RELAY";
        attribute :>> apidClass = ApidClass::relay;
    }
    item def AbortToRetreat :> Command {
        doc /* Abort proximity operations and retreat along the sun line at the given speed. */
        attribute :>> opcode = "ABORT_TO_RETREAT";
        attribute :>> apidClass = ApidClass::guidance;
        attribute retreatSpeed : SpeedValue;
        attribute retreatSpeedMinimum : SpeedValue = 0.05 ['m/s'];
        attribute retreatSpeedMaximum : SpeedValue = 0.3 ['m/s'];
        assert constraint speedInRange { retreatSpeed >= retreatSpeedMinimum and retreatSpeed <= retreatSpeedMaximum }
    }
    item def LoadSequence :> Command {
        doc /* Load an on-board sequence by its id. */
        attribute :>> opcode = "LOAD_SEQUENCE";
        attribute :>> apidClass = ApidClass::housekeeping;
        attribute sequenceId : Natural;
    }

    item def TelemetryPoint {
        doc /* One telemetry mnemonic with the class of packet that carries it. */
        attribute mnemonic : String;
        attribute apidClass : ApidClass;
    }
    item def BatteryStateOfCharge :> TelemetryPoint {
        doc /* Battery state of charge as a fraction; the low limit is the 40 % floor of flight
             * rule FR-004. */
        attribute :>> mnemonic = "EPS_BATT_SOC";
        attribute :>> apidClass = ApidClass::housekeeping;
        attribute value : Real;
        attribute lowLimit : Real = 0.4;
        attribute highLimit : Real = 1.0;
        assert constraint limitsOrdered { lowLimit < highLimit }
    }
    item def BusVoltage :> TelemetryPoint {
        doc /* Regulated bus voltage against the ICD-011 band. */
        attribute :>> mnemonic = "EPS_BUS_V";
        attribute :>> apidClass = ApidClass::housekeeping;
        attribute value : ElectricPotentialValue;
        attribute lowLimit : ElectricPotentialValue = 27.0 [V];
        attribute highLimit : ElectricPotentialValue = 29.0 [V];
        assert constraint limitsOrdered { lowLimit < highLimit }
    }
    item def XenonRemaining :> TelemetryPoint {
        doc /* Xenon remaining from the tank pressure and temperature. */
        attribute :>> mnemonic = "SEP_XE_MASS";
        attribute :>> apidClass = ApidClass::propulsion;
        attribute value : MassValue;
        attribute lowLimit : MassValue = 300.0 [kg];
        attribute highLimit : MassValue = 6600.0 [kg];
        assert constraint limitsOrdered { lowLimit < highLimit }
    }
    item def ThrusterDischargeCurrent :> TelemetryPoint {
        doc /* Discharge current of the operating thrusters. */
        attribute :>> mnemonic = "SEP_DISCHARGE_I";
        attribute :>> apidClass = ApidClass::propulsion;
        attribute value : ElectricCurrentValue;
        attribute lowLimit : ElectricCurrentValue = 0.0 [A];
        attribute highLimit : ElectricCurrentValue = 45.0 [A];
        assert constraint limitsOrdered { lowLimit < highLimit }
    }
    item def RangeToTarget :> TelemetryPoint {
        doc /* Relative-navigation range to the target. */
        attribute :>> mnemonic = "GNC_TGT_RANGE";
        attribute :>> apidClass = ApidClass::guidance;
        attribute value : LengthValue;
        attribute lowLimit : LengthValue = 0.0 [m];
        attribute highLimit : LengthValue = 50.0 [km];
        assert constraint limitsOrdered { lowLimit < highLimit }
    }
    item def RelayLinkMargin :> TelemetryPoint {
        doc /* Measured proximity link margin, a level in dB (see TethysLinkBudgets). */
        attribute :>> mnemonic = "RELAY_MARGIN_DB";
        attribute :>> apidClass = ApidClass::relay;
        attribute valueDb : Real;
        attribute lowLimitDb : Real = 3.0;
        attribute highLimitDb : Real = 40.0;
        assert constraint limitsOrdered { lowLimitDb < highLimitDb }
    }
    item def CommandAcknowledge :> TelemetryPoint {
        doc /* The acknowledgement the executive returns for each accepted command. */
        attribute :>> mnemonic = "CDH_CMD_ACK";
        attribute :>> apidClass = ApidClass::housekeeping;
        attribute acceptedOpcode : String;
    }

    item def HousekeepingPacket :> TelemetryPacket {
        doc /* The housekeeping packet: power, bus and acknowledgement points. */
        item batterySoc : BatteryStateOfCharge;
        item busVoltage : BusVoltage;
        item acknowledge : CommandAcknowledge;
    }
    item def PropulsionPacket :> TelemetryPacket {
        doc /* The propulsion packet: xenon and thruster points. */
        item xenon : XenonRemaining;
        item dischargeCurrent : ThrusterDischargeCurrent;
    }

    part def Dictionary {
        doc /* The dictionary as a whole, with the consistency checks run over it. */
        attribute apids : ApidTable;
        attribute apidMaximum : Natural = 2047;
        attribute commandCount : Natural = 8;
        attribute telemetryPointCount : Natural = 7;
    }
    part dictionary : Dictionary {
        doc /* The Tethys dictionary at its current issue. */
    }

    requirement <'TG-010'> dictionaryConsistent : SystemRequirement {
        doc /* The dictionary shall assign distinct application ids within the 11-bit range and
             * every telemetry point shall carry ordered limits. */
        subject d : Dictionary;
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        require constraint distinctApids {
            d.apids.housekeeping != d.apids.guidance and d.apids.housekeeping != d.apids.propulsion
                and d.apids.housekeeping != d.apids.capture and d.apids.housekeeping != d.apids.relay
                and d.apids.housekeeping != d.apids.imaging and d.apids.guidance != d.apids.propulsion
                and d.apids.guidance != d.apids.capture and d.apids.guidance != d.apids.relay
                and d.apids.guidance != d.apids.imaging and d.apids.propulsion != d.apids.capture
                and d.apids.propulsion != d.apids.relay and d.apids.propulsion != d.apids.imaging
                and d.apids.capture != d.apids.relay and d.apids.capture != d.apids.imaging
                and d.apids.relay != d.apids.imaging
        }
        require constraint apidsInRange { d.apids.imaging <= d.apidMaximum }
    }
    satisfy dictionaryConsistent by dictionary { doc /* The current dictionary passes its checks. */ }

    // ---- flight rules ------------------------------------------------------------------------
    constraint def NoThrustDuringRelay {
        doc /* FR-001: the SEP thrusters are off whenever the proximity link is active, so the
             * plume never crosses Wren and the relay antenna is never blocked by the array slew. */
        in thrusting : Boolean;
        in relayActive : Boolean;
        not (thrusting and relayActive)
    }
    constraint def ApproachKeepOut {
        doc /* FR-002: the tug stays outside the keep-out sphere unless the approach is
             * authorised by a loaded capture sequence. */
        in rangeToTarget : LengthValue;
        in keepOutRadius : LengthValue;
        in approachAuthorised : Boolean;
        rangeToTarget >= keepOutRadius or approachAuthorised
    }
    constraint def SunExclusion {
        doc /* FR-003: the characterisation imager boresight stays outside the sun exclusion
             * cone while its cover is open. */
        in sunAngle : AngularMeasureValue;
        in exclusionHalfAngle : AngularMeasureValue;
        in coverOpen : Boolean;
        sunAngle >= exclusionHalfAngle or not coverOpen
    }
    constraint def BatteryDepthOfDischarge {
        doc /* FR-004: battery state of charge never below 40 % (60 % depth of discharge). */
        in stateOfCharge : Real;
        stateOfCharge >= 0.4
    }

    requirement <'FR-001'> noThrustDuringRelay : SystemRequirement {
        doc /* The flight system shall not thrust while the proximity link is active. */
        attribute thrusting : Boolean;
        attribute relayActive : Boolean;
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        require constraint : NoThrustDuringRelay { in :>> thrusting = noThrustDuringRelay::thrusting; in :>> relayActive = noThrustDuringRelay::relayActive; }
    }
    requirement <'FR-002'> approachKeepOut : SystemRequirement {
        doc /* The tug shall remain outside the 500 m keep-out sphere until a capture sequence
             * is loaded and authorised. */
        attribute keepOutRadius : LengthValue = 500.0 [m];
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
    }
    requirement <'FR-003'> sunExclusion : SystemRequirement {
        doc /* The imager boresight shall stay more than 25° from the Sun while its cover is open. */
        attribute exclusionHalfAngle : AngularMeasureValue = 25.0 ['°'];
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::subsystem; stage = VerificationStage::preLaunch; }
    }
    requirement <'FR-004'> batteryDepthOfDischarge : SystemRequirement {
        doc /* Battery state of charge shall not fall below 40 % in any planned activity. */
        attribute stateOfChargeFloor : Real = 0.4;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
    }

    // ---- the command executive and the procedures ----------------------------------------------
    part def OperationsCentreConsole {
        doc /* The operations centre as the procedures see it: what it last received. */
        attribute lastAcknowledgedOpcode : String := "";
        attribute acknowledgementsReceived : Natural := 0;
    }

    part def CommandedTug {
        doc /* The tug as the executive sees it: mode, thrust and relay state. */
        attribute mode : TugMode := TugMode::coast;
        attribute thrusting : Boolean := false;
        attribute relayActive : Boolean := false;
        attribute commandsAccepted : Natural := 0;
    }

    part def OperationsScenario {
        doc /* The operations centre commanding the tug: the thrust-arc procedure on the ground
             * and the command executive on board, exchanging commands and acknowledgements. */
        part moc : OperationsCentreConsole {
            perform action thrustArcProcedure {
                doc /* Procedure OPS-012: stop any relay, enter thrust mode, start a 48 h arc at
                     * 90 % throttle, and confirm each step by its acknowledgement. */
                action disableRelay send new DisableRelay(apid = 5, sequenceCount = 1, length = 16.0 [B]) to tug;
                then action ackRelay accept a1 : CommandAcknowledge;
                then action setThrustMode send new SetMode(apid = 1, sequenceCount = 2, length = 17.0 [B], mode = TugMode::thrust) to tug;
                then action ackMode accept a2 : CommandAcknowledge;
                then action startArc send new StartThrustArc(apid = 3, sequenceCount = 3, length = 24.0 [B], arcDuration = 48.0 [h], throttle = 0.9) to tug;
                then action ackArc accept a3 : CommandAcknowledge;
                then action record assign acknowledgementsReceived := 3;
                then action noteOpcode assign lastAcknowledgedOpcode := ackArc.a3.acceptedOpcode;
            }
        }
        part tug : CommandedTug {
            perform action commandExecutive {
                doc /* The on-board executive for this procedure: accepts each dictionary
                     * command in turn, applies it and acknowledges it. */
                action takeDisable accept c1 : DisableRelay;
                then action applyDisable assign relayActive := false;
                then action ackDisable send new CommandAcknowledge(acceptedOpcode = "DISABLE_RELAY") to moc;
                then action takeMode accept c2 : SetMode;
                then action applyMode assign mode := takeMode.c2.mode;
                then action ackMode send new CommandAcknowledge(acceptedOpcode = "SET_MODE") to moc;
                then action takeArc accept c3 : StartThrustArc;
                then action applyArc assign thrusting := true;
                then action count assign commandsAccepted := 3;
                then action ackArc send new CommandAcknowledge(acceptedOpcode = "START_THRUST_ARC") to moc;
            }
        }
    }
    part scenario : OperationsScenario {
        doc /* The scenario the thrust-arc procedure is run in. */
    }

    action def CommandExecutiveCoverage {
        doc /* Every dictionary command is accepted by at least one executive behaviour: this
             * action lists the acceptances the flight software offers. */
        action acceptSetMode accept SetMode;
        action acceptStartThrustArc accept StartThrustArc;
        action acceptStopThrust accept StopThrust;
        action acceptReleaseInspector accept ReleaseInspector;
        action acceptEnableRelay accept EnableRelay;
        action acceptDisableRelay accept DisableRelay;
        action acceptAbortToRetreat accept AbortToRetreat;
        action acceptLoadSequence accept LoadSequence;
    }

    action def RelayThenThrustProcedure {
        doc /* Procedure OPS-014: a relay session followed by a thrust arc, with the FR-001 and
             * FR-004 rules asserted at every step so a schedule that violates them is found. */
        attribute thrusting : Boolean := false;
        attribute relayActive : Boolean := false;
        attribute stateOfCharge : Real := 0.95;
        action enableRelay assign relayActive := true;
        then action relaySession assign stateOfCharge := 0.7;
        then action disableRelay assign relayActive := false;
        then action startArc assign thrusting := true;
        then action arc assign stateOfCharge := 0.55;
        then action stopArc assign thrusting := false;
        assert constraint noThrustDuringRelay : NoThrustDuringRelay {
            in :>> thrusting = RelayThenThrustProcedure::thrusting;
            in :>> relayActive = RelayThenThrustProcedure::relayActive;
        }
        assert constraint batteryFloor : BatteryDepthOfDischarge {
            in :>> stateOfCharge = RelayThenThrustProcedure::stateOfCharge;
        }
    }

    // ---- pass schedule -------------------------------------------------------------------------
    occurrence def StationPass {
        doc /* One tracking pass: the station, when it starts, how long it lasts and the band. */
        ref station : MeridianStation;
        attribute startTime : TimeValue;
        attribute passDuration : DurationValue;
        attribute band : RfBand;
        attribute maximumElevation : AngularMeasureValue;
    }

    action def DownlinkActivity {
        doc /* A downlink activity allocated to a pass: what it returns and how much. */
        attribute volume : StorageCapacityValue;
    }
    action def TrackingActivity {
        doc /* Two-way Doppler and ranging over a pass for orbit determination. */
        attribute trackingDuration : DurationValue;
    }

    allocation def ActivityToPass {
        doc /* An activity carried by a pass. */
        end activity : DownlinkActivity;
        end pass : StationPass;
    }

    occurrence def DailyPassPlan {
        doc /* One day of the characterisation phase: three passes, one per station, 8 h each
             * so the tug is tracked continuously, with the downlinks and tracking they carry. */
        occurrence calderaPass : StationPass {
            ref :>> station = meridian.caldera;
            attribute :>> startTime = 0.0 [s];
            attribute :>> passDuration = 8.0 [h];
            attribute :>> band = RfBand::kaBand;
            attribute :>> maximumElevation = 62.0 ['°'];
        }
        occurrence tablelandPass : StationPass {
            ref :>> station = meridian.tableland;
            attribute :>> startTime = 28800.0 [s];
            attribute :>> passDuration = 8.0 [h];
            attribute :>> band = RfBand::xBand;
            attribute :>> maximumElevation = 48.0 ['°'];
        }
        occurrence saltmarshPass : StationPass {
            ref :>> station = meridian.saltmarsh;
            attribute :>> startTime = 57600.0 [s];
            attribute :>> passDuration = 8.0 [h];
            attribute :>> band = RfBand::kaBand;
            attribute :>> maximumElevation = 71.0 ['°'];
        }
        first calderaPass then tablelandPass;
        first tablelandPass then saltmarshPass;

        perform action imageryDownlink : DownlinkActivity { attribute :>> volume = 11.5e9 [bit]; }
        perform action housekeepingDownlink : DownlinkActivity { attribute :>> volume = 0.58e9 [bit]; }
        perform action radarDownlink : DownlinkActivity { attribute :>> volume = 11.5e9 [bit]; }
        perform action tracking : TrackingActivity { attribute :>> trackingDuration = 6.0 [h]; }
        allocation imageryToCaldera : ActivityToPass allocate imageryDownlink to calderaPass;
        allocation housekeepingToTableland : ActivityToPass allocate housekeepingDownlink to tablelandPass;
        allocation radarToSaltmarsh : ActivityToPass allocate radarDownlink to saltmarshPass;
        allocate tracking to tablelandPass;
    }
    occurrence dailyPassPlan : DailyPassPlan {
        doc /* The daily plan as flown through characterisation. */
    }

    // ---- the operations timeline ----------------------------------------------------------------
    part def OperationsTimeline {
        doc /* One characterisation day as a timeline: the exclusive activities are the states of
             * one machine, so none of them overlaps; the relay window and the thrust arc are
             * never both active, which is how FR-001 is kept by construction. */
        attribute relayHours : Real := 0.0;
        exhibit state day {
            entry; then morningPass;
            state morningPass;
            transition first morningPass accept after 7200 [s] then relayWindow;
            state relayWindow {
                entry action tally assign relayHours := relayHours + 2.0;
            }
            transition first relayWindow accept after 7200 [s] then middayPass;
            state middayPass;
            transition first middayPass accept after 10800 [s] then coastAndTrack;
            state coastAndTrack;
            transition first coastAndTrack accept after 7200 [s] then thrustArc;
            state thrustArc;
            transition first thrustArc accept after 14400 [s] then eveningPass;
            state eveningPass;
        }
    }
    part opsTimeline : OperationsTimeline {
        doc /* The timeline instance the run is recorded on. */
    }

    // ---- contingency procedures -------------------------------------------------------------------
    action def ContingencyProcedure {
        doc /* A ground response to a credible failure mode: the triggering telemetry, the
             * failure mode from the domain list it answers, and the commands it sends. */
        attribute failureMode : String;
        attribute triggerMnemonic : String;
        attribute responseTime : DurationValue;
    }
    action thrusterFailureResponse : ContingencyProcedure {
        doc /* CON-001: a thruster drops out of discharge; stop thrust, swap to the spare string
             * and replan the arc. */
        attribute :>> failureMode = "SEP thruster or power-processing unit failure";
        attribute :>> triggerMnemonic = "SEP_DISCHARGE_I";
        attribute :>> responseTime = 24.0 [h];
        action stop send new StopThrust(apid = 3, sequenceCount = 10, length = 16.0 [B]) to scenario.tug;
        then action replan send new LoadSequence(apid = 1, sequenceCount = 11, length = 20.0 [B], sequenceId = 412) to scenario.tug;
    }
    action relayLossResponse : ContingencyProcedure {
        doc /* CON-002: the proximity link margin drops below its low limit; disable the relay
             * and hold station until Wren is recovered or declared lost. */
        attribute :>> failureMode = "Proximity link loss or inspector loss";
        attribute :>> triggerMnemonic = "RELAY_MARGIN_DB";
        attribute :>> responseTime = 2.0 [h];
        action disable send new DisableRelay(apid = 5, sequenceCount = 12, length = 16.0 [B]) to scenario.tug;
    }
    action captureAbortResponse : ContingencyProcedure {
        doc /* CON-003: contact loads or spin out of the ICD-005 envelope during capture; abort
             * to a 0.1 m/s retreat and safe mode. */
        attribute :>> failureMode = "Capture mechanism jam or body breakup";
        attribute :>> triggerMnemonic = "GNC_TGT_RANGE";
        attribute :>> responseTime = 0.25 [h];
        action retreat send new AbortToRetreat(apid = 2, sequenceCount = 13, length = 24.0 [B], retreatSpeed = 0.1 ['m/s']) to scenario.tug;
        then action safe send new SetMode(apid = 1, sequenceCount = 14, length = 17.0 [B], mode = TugMode::safe) to scenario.tug;
    }
    action stationOutageResponse : ContingencyProcedure {
        doc /* CON-004: a Meridian station is lost for a day; the plan is rebuilt on the other
             * two with the housekeeping downlink kept and imagery deferred. */
        attribute :>> failureMode = "Ground station outage";
        attribute :>> triggerMnemonic = "EPS_BUS_V";
        attribute :>> responseTime = 4.0 [h];
    }
    action batteryLowResponse : ContingencyProcedure {
        doc /* CON-005: state of charge trending to the FR-004 floor; shed the imager and relay
             * loads and stop thrust until the arrays are back on the Sun. */
        attribute :>> failureMode = "Battery degradation or array pointing loss";
        attribute :>> triggerMnemonic = "EPS_BATT_SOC";
        attribute :>> responseTime = 1.0 [h];
        action shed send new DisableRelay(apid = 5, sequenceCount = 15, length = 16.0 [B]) to scenario.tug;
        then action stop send new StopThrust(apid = 3, sequenceCount = 16, length = 16.0 [B]) to scenario.tug;
    }

    // ---- operations readiness -----------------------------------------------------------------------
    part def OperationsReadinessStatus {
        doc /* What the operations readiness review counts. */
        attribute stationsCommitted : Natural;
        attribute proceduresValidated : Natural;
        attribute proceduresTotal : Natural;
        attribute rehearsalsComplete : Natural;
        attribute contingenciesRehearsed : Natural;
        attribute contingenciesTotal : Natural;
        attribute staffedPositions : Natural;
        attribute requiredPositions : Natural;
    }
    part orrStatus : OperationsReadinessStatus {
        doc /* The readiness status as presented at the review. */
        attribute :>> stationsCommitted = 3;
        attribute :>> proceduresValidated = 42;
        attribute :>> proceduresTotal = 42;
        attribute :>> rehearsalsComplete = 3;
        attribute :>> contingenciesRehearsed = 5;
        attribute :>> contingenciesTotal = 5;
        attribute :>> staffedPositions = 27;
        attribute :>> requiredPositions = 27;
    }
    requirement <'TG-020'> operationsReadiness : SystemRequirement {
        doc /* Operations shall be declared ready only with three stations committed, every
             * procedure validated on the flatsat, at least two end-to-end rehearsals flown,
             * every contingency procedure rehearsed and every position staffed. */
        subject status : OperationsReadinessStatus;
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::mission; stage = VerificationStage::preLaunch; }
        require constraint { status.stationsCommitted >= 3 }
        require constraint { status.proceduresValidated == status.proceduresTotal }
        require constraint { status.rehearsalsComplete >= 2 }
        require constraint { status.contingenciesRehearsed == status.contingenciesTotal }
        require constraint { status.staffedPositions >= status.requiredPositions }
    }
    satisfy operationsReadiness by orrStatus { doc /* The presented status meets every criterion. */ }

    // ---- health trending and resource margins -----------------------------------------------------------
    calc def LinearTrend {
        doc /* A value extrapolated linearly from its current value and rate of change. */
        in current : Real;
        in ratePerDay : Real;
        in days : Real;
        return projected : Real = current + ratePerDay * days;
    }
    part def ResourceTrend {
        doc /* A consumable or degrading resource: where it is, how fast it moves and where it
             * must still be at the end of the nominal mission. */
        attribute resourceName : String;
        attribute current : Real;
        attribute ratePerDay : Real;
        attribute daysRemaining : Real;
        attribute floor : Real;
        attribute projected : Real = LinearTrend(current, ratePerDay, daysRemaining);
        attribute margin : Real = projected - floor;
    }
    part xenonTrend : ResourceTrend {
        doc /* Xenon in kg at the start of the return cruise, read from the propellant book
             * (TethysBudgets::propellantBudget) so the trend and the budget cannot disagree:
             * aboard is the usable load less the outbound and rendezvous arcs with their
             * missed-thrust allowance spent (about 5 112 kg, the budget's case); the rate is the
             * SEP string's mass flow at aphelion while thrusting (about 5.2 kg a day); the days to
             * go are the thrusting days the nominal case's return and insertion arcs need with
             * the same allowance (about 550, not the calendar length of the cruise, which is
             * mostly coast); the floor is the 300 kg reserve. The projection is then the budget's
             * usable load less its nominal-case xenon, above the floor. */
        attribute returnArcsXenon : MassValue = TethysBudgets::propellantBudget.xenonNominal
            - (TethysBudgets::propellantBudget.outboundAlone + TethysBudgets::propellantBudget.rendezvousAlone)
                * (1.0 + TethysMission::transferBook.missedThrustMargin) {
            doc /* Xenon the return and insertion arcs take for the nominal case, with the
                 * missed-thrust allowance: the mission's xenon less the arcs already flown. */
        }
        attribute :>> resourceName = "xenon (kg)";
        attribute :>> current = (TethysBudgets::propellantBudget.usable
            - (TethysBudgets::propellantBudget.outboundAlone + TethysBudgets::propellantBudget.rendezvousAlone)
                * (1.0 + TethysMission::transferBook.missedThrustMargin)) / (1 [kg]);
        attribute :>> ratePerDay = -(TethysBudgets::propellantBudget.massFlowAtAphelion / (1 ['kg⋅s⁻¹'])) * 86400.0;
        attribute :>> daysRemaining = (returnArcsXenon / (1 [kg])) / (-ratePerDay);
        attribute :>> floor = 300.0;
    }
    part batteryCapacityTrend : ResourceTrend {
        doc /* Battery capacity as a fraction of beginning of life, fading 0.00002 a day, against
             * the 0.8 floor the eclipse budget needs. */
        attribute :>> resourceName = "battery capacity (fraction)";
        attribute :>> current = 0.94;
        attribute :>> ratePerDay = -0.00002;
        attribute :>> daysRemaining = 1500.0;
        attribute :>> floor = 0.8;
    }
    requirement <'TG-021'> resourceMarginPositive : SystemRequirement {
        doc /* Every trended resource shall project above its floor at the end of the nominal
             * mission. */
        subject trend : ResourceTrend;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::inFlight; }
        require constraint { trend.margin >= 0.0 }
    }
    satisfy resourceMarginPositive by xenonTrend { doc /* Xenon projects above its reserve. */ }
    satisfy resourceMarginPositive by batteryCapacityTrend { doc /* Battery capacity projects above its floor. */ }

    // ---- orbit determination and manoeuvre products ----------------------------------------------------
    part def NavigationProducts {
        doc /* What flight dynamics delivers each week in cruise: the tug and target solutions
             * and the next arc. */
        item tugSolution : OrbitSolution {
            attribute :>> positionUncertainty = 2.0 [km];
            attribute :>> velocityUncertainty = 0.002 ['m/s'];
            attribute :>> arcLength = 7.0 [d];
            attribute :>> volume = 2.0e6 [B];
        }
        item targetSolution : OrbitSolution {
            attribute :>> positionUncertainty = 150.0 [km];
            attribute :>> velocityUncertainty = 0.05 ['m/s'];
            attribute :>> arcLength = 180.0 [d];
            attribute :>> volume = 2.0e6 [B];
        }
        item nextArc : ManeuverPlan {
            attribute :>> deltaV = 24.0 ['m/s'];
            attribute :>> arcDuration = 48.0 [h];
            attribute :>> xenonUsed = 10.4 [kg];
            attribute :>> volume = 0.5e6 [B];
        }
    }
    part weeklyNavigation : NavigationProducts {
        doc /* The weekly navigation delivery in outbound cruise. */
    }

    // ---- extended mission ----------------------------------------------------------------------------------
    part def ExtendedMissionProposal {
        doc /* The replan for an extended mission in the DRO: what is left, what it costs a day
             * and how long it buys. */
        attribute xenonAvailable : MassValue;
        attribute xenonAvailableKg : Real;
        attribute stationKeepingPerDayKg : Real;
        attribute hydrazineAvailable : MassValue;
        attribute requestedExtension : DurationValue;
        attribute requestedExtensionDays : Real;
        attribute xenonNeededKg : Real = stationKeepingPerDayKg * requestedExtensionDays;
        attribute passesPerWeek : Natural;
    }
    part extendedMission : ExtendedMissionProposal {
        doc /* A two-year extension at one pass a week with 450 kg of xenon left. */
        attribute :>> xenonAvailable = 450.0 [kg];
        attribute :>> xenonAvailableKg = 450.0;
        attribute :>> stationKeepingPerDayKg = 0.15;
        attribute :>> hydrazineAvailable = 60.0 [kg];
        attribute :>> requestedExtension = 730.0 [d];
        attribute :>> requestedExtensionDays = 730.0;
        attribute :>> passesPerWeek = 1;
    }
    requirement <'TG-022'> extendedMissionAffordable : SystemRequirement {
        doc /* An extended mission shall be proposed only if the xenon left covers its station
             * keeping with the reserve intact. */
        subject proposal : ExtendedMissionProposal;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        require constraint { proposal.xenonNeededKg <= proposal.xenonAvailableKg - 300.0 }
    }
    satisfy extendedMissionAffordable by extendedMission { doc /* The two-year proposal fits the xenon left. */ }
}
