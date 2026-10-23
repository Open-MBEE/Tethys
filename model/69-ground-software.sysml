// Mission tier: the ground software of the Meridian network — the fictional Meridian Operations
// Suite. Its components retype the GroundSoftwareComponent parts of the operations centre, the
// flight-dynamics facility and the science data system (50), read the flight dictionary (64) and
// the MLS-2 link profile (68), produce the pass plans of the operations model (53), check the
// on-board sequences (61) against the flight rules before uplink, and type the simulators and
// test beds of the verification programme (23). Standard libraries only; the product names are
// fictional, and CCSDS Space Packets and XTCE are the only real standards cited.
package TethysGroundSoftware {
    doc /* The Meridian Operations Suite: command builder, sequencer and flight-rule checker,
         * telemetry server, flight dynamics, pass planner, archive, anomaly tracker, proximity
         * planning and the simulators, each a software component with ports and interfaces,
         * with the ground-to-flight exchange through the TI-021 link profile and the packet
         * gateway. The sequencer is executable: it loads a planned sequence, checks it
         * against FR-001 to FR-004 and either clears it into an uplink product or refuses
         * it with the rule it broke. Sends and accepts use the forms the pinned toolchain
         * executes (see docs/findings/WP-SW-3.md): parts perform actions that send to a
         * named peer part; no state-definition port sends are used. */
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SequenceFunctions::*;
    private import ControlFunctions::*;
    private import TethysGround::*;
    private import TethysMeridian::*;
    private import TethysIcds::*;
    private import TethysOperations::*;
    private import TethysTugStructure::TugMode;
    private import TethysTugStructure::allFlightModes;
    private import TethysTugStructure::thrustingModes;
    private import TethysFlightDictionary::Opcode;
    private import TethysFlightDictionary::CommandDefinition;
    private import TethysFlightDictionary::CommandArgument;
    private import TethysFlightDictionary::CommandCriticality;
    private import TethysFlightDictionary::PacketDefinition;
    private import TethysFlightDictionary::FdirLimitTable;
    private import TethysFlightDictionary::flightDictionary;
    private import TethysFlightDictionary::sepStartThrustArc;
    private import TethysFlightDictionary::cdhResetProcessor;
    private import TethysFlightDictionary::cdhNoop;
    private import TethysSoftwareIcds::LinkRateSet;
    private import TethysSoftwareIcds::SpaceLinkProfileIcd;
    private import TethysSoftwareIcds::MeridianPacketGateway;
    private import TethysSoftwareIcds::argentSoftwareIcds;
    private import TethysFlightSoftware::ArgentFlightSoftware;
    private import TethysSequence::OnBoardSequence;
    private import TethysVerification::TestBed;
    private import TethysVerification::TestBedSet;
    private import TethysRequirements::Verification;
    private import TethysRequirements::VerificationLevel;
    private import TethysRequirements::VerificationStage;
    private import VerificationCases::VerificationMethodKind;

    // ---- 1. Vocabulary ------------------------------------------------------------------------
    enum def CommandVerdict {
        doc /* What the command builder says of a command request: accepted, or the first
             * check it failed — opcode not in the dictionary, argument out of range, tug mode
             * not among the command's allowed modes, or a hazardous command still waiting
             * for its second approval. */
        enum accepted;
        enum unknownOpcode;
        enum argumentOutOfRange;
        enum modeNotAllowed;
        enum awaitingSecondApproval;
    }
    enum def SequenceVerdict {
        doc /* The flight-rule checker's verdict on a planned sequence. */
        enum pending;
        enum cleared;
        enum refused;
    }
    enum def AlarmSeverity {
        doc /* Alarm severity of a telemetry sample against its limits: within limits, a
             * warning band near a limit, or a limit violation. */
        enum nominal;
        enum warning;
        enum violation;
    }
    enum def AnomalyDisposition {
        doc /* How the anomaly board closes an anomaly: explained with no action, a procedure
             * change, a parameter or table change, or a software fix. */
        enum explained;
        enum procedureChange;
        enum parameterChange;
        enum softwareFix;
    }
    enum def DecisionAuthority {
        doc /* Who may approve a step: the flight director on console, the anomaly board, or
             * the mission manager for a hazardous command's second signature. */
        enum flightDirector;
        enum anomalyBoard;
        enum missionManager;
    }

    // ---- 2. Products the suite produces beside those of TethysMeridian ----------------------
    attribute def CommandRequest {
        doc /* A command as an operator builds it: the mnemonic chosen from the dictionary, one
             * argument value against the argument's range, the tug mode it is meant for and
             * the number of approvals it has collected. */
        attribute mnemonic : String;
        attribute argumentValue : Real;
        attribute modeAtExecution : TugMode;
        attribute approvals : Natural;
    }
    attribute def PlannedSequence {
        doc /* A sequence as the sequence engineer plans it: which on-board sequence it loads
             * and the flight state it is planned into — thrusting, relay pass, range to the
             * target, approach authorisation, imager cover, sun angle and battery state. */
        attribute sequenceId : Natural;
        attribute plannedMode : TugMode;
        attribute thrusting : Boolean;
        attribute relayPassActive : Boolean;
        attribute rangeToTarget : LengthValue;
        attribute approachAuthorised : Boolean;
        attribute sunAngle : AngularMeasureValue;
        attribute coverOpen : Boolean;
        attribute stateOfCharge : Real;
    }
    item def UplinkProduct :> DataProduct {
        doc /* A cleared sequence load ready for the uplink queue: the sequence number, the
             * dictionary issue it was checked against and its checksum. */
        attribute sequenceId : Natural;
        attribute dictionaryCommandCount : Natural;
        attribute checksum : Natural;
    }
    item def EngineeringTelemetry :> DecodedTelemetry {
        doc /* Decommutated and calibrated telemetry: the points of one packet in engineering
             * units, with the dictionary issue they were decoded with. */
        attribute pointCount : Natural;
        attribute dictionaryPacketCount : Natural;
    }
    item def AlarmRecord :> DataProduct {
        doc /* One alarm the telemetry server raised: the point, its value and severity. */
        attribute mnemonic : String;
        attribute value : Real;
        attribute severity : AlarmSeverity;
        attribute acknowledged : Boolean;
    }
    item def TrendProduct :> DataProduct {
        doc /* A trended point projected to a horizon. */
        attribute mnemonic : String;
        attribute projected : Real;
        attribute horizonDays : Real;
    }
    item def Ephemeris :> DataProduct {
        doc /* A predicted ephemeris of Argent or of Amaranth: epoch, span and step. */
        attribute span : DurationValue;
        attribute step : DurationValue;
        attribute positionUncertainty : LengthValue;
    }
    item def DeltaVLedger :> DataProduct {
        doc /* The running delta-v and xenon account the flight dynamics tool keeps. */
        attribute deltaVPlanned : SpeedValue;
        attribute deltaVExecuted : SpeedValue;
        attribute xenonCommitted : MassValue;
    }
    item def AnomalyReport :> DataProduct {
        doc /* An anomaly as tracked from the event that opened it to the board's disposition. */
        attribute anomalyId : Natural;
        attribute triggerMnemonic : String;
        attribute disposition : AnomalyDisposition;
        attribute authority : DecisionAuthority;
    }
    item def GoNoGoChecklist :> DataProduct {
        doc /* The proximity-operations go/no-go checklist the flight director signs. */
        attribute itemsTotal : Natural;
        attribute itemsGo : Natural;
        attribute go : Boolean = itemsGo == itemsTotal;
    }

    // ---- 3. The command builder --------------------------------------------------------------
    calc def ValidateCommand {
        doc /* The command builder's checks in the order the builder applies them: the mnemonic
             * is in the dictionary, the argument is inside the dictionary range, the planned
             * mode is one of the command's allowed modes, and a hazardous command has its two
             * approvals (CommandCriticality: critical and hazardous commands are two-step). */
        in request : CommandRequest;
        in command : CommandDefinition;
        in argument : CommandArgument;
        attribute opcodeKnown : Boolean = flightDictionary.commandMnemonics->includes(request.mnemonic);
        attribute argumentInRange : Boolean = argument.minimum <= request.argumentValue and request.argumentValue <= argument.maximum;
        attribute modeAllowed : Boolean = command.allowedModes->includes(request.modeAtExecution);
        attribute approvalsSufficient : Boolean = not command.hazardous or request.approvals >= 2;
        return verdict : CommandVerdict = if not opcodeKnown ? CommandVerdict::unknownOpcode
            else if not argumentInRange ? CommandVerdict::argumentOutOfRange
            else if not modeAllowed ? CommandVerdict::modeNotAllowed
            else if not approvalsSufficient ? CommandVerdict::awaitingSecondApproval
            else CommandVerdict::accepted;
    }
    part def CommandBuilder :> GroundSoftwareComponent {
        doc /* Meridian Forge, the command builder: every command is built from the flight
             * dictionary and validated by ValidateCommand before it is packed as a CommandPacket
             * for the uplink queue; hazardous commands wait for a second signature. */
        attribute :>> productName = "Meridian Forge";
        attribute :>> version = "3.2";
        attribute dictionaryCommandCount : Natural = flightDictionary.commandCount;
        attribute hazardousCommandCount : Natural = flightDictionary.hazardousCommandCount;
        attribute secondApprover : DecisionAuthority = DecisionAuthority::missionManager;
        port uplinkQueue : ~PacketPort;
        attribute thrustArcRequest : CommandRequest {
            :>> mnemonic = "SEP_START_THRUST_ARC"; :>> argumentValue = 0.8; :>> modeAtExecution = TugMode::thrust; :>> approvals = 2;
        }
        attribute thrustArcInCoastRequest : CommandRequest {
            :>> mnemonic = "SEP_START_THRUST_ARC"; :>> argumentValue = 0.8; :>> modeAtExecution = TugMode::coast; :>> approvals = 2;
        }
        attribute resetWithOneApproval : CommandRequest {
            :>> mnemonic = "CDH_RESET_PROCESSOR"; :>> argumentValue = 4660.0; :>> modeAtExecution = TugMode::coast; :>> approvals = 1;
        }
        attribute resetKeyOutOfRange : CommandRequest {
            :>> mnemonic = "CDH_RESET_PROCESSOR"; :>> argumentValue = 70000.0; :>> modeAtExecution = TugMode::coast; :>> approvals = 2;
        }
        attribute misspelledRequest : CommandRequest {
            :>> mnemonic = "SEP_START_THRUST"; :>> argumentValue = 0.8; :>> modeAtExecution = TugMode::thrust; :>> approvals = 2;
        }
        calc thrustArcVerdict : ValidateCommand { in request = thrustArcRequest; in command = sepStartThrustArc; in argument = sepStartThrustArc.throttle; }
        calc thrustArcInCoastVerdict : ValidateCommand { in request = thrustArcInCoastRequest; in command = sepStartThrustArc; in argument = sepStartThrustArc.throttle; }
        calc resetOneApprovalVerdict : ValidateCommand { in request = resetWithOneApproval; in command = cdhResetProcessor; in argument = cdhResetProcessor.confirmKey; }
        calc resetKeyVerdict : ValidateCommand { in request = resetKeyOutOfRange; in command = cdhResetProcessor; in argument = cdhResetProcessor.confirmKey; }
        calc misspelledVerdict : ValidateCommand { in request = misspelledRequest; in command = sepStartThrustArc; in argument = sepStartThrustArc.throttle; }
        attribute verdictsAsPlanted : Boolean =
            thrustArcVerdict.verdict == CommandVerdict::accepted
                and thrustArcInCoastVerdict.verdict == CommandVerdict::modeNotAllowed
                and resetOneApprovalVerdict.verdict == CommandVerdict::awaitingSecondApproval
                and resetKeyVerdict.verdict == CommandVerdict::argumentOutOfRange
                and misspelledVerdict.verdict == CommandVerdict::unknownOpcode;
        assert constraint acceptsTheNominalRequest {
            doc /* The nominal thrust-arc request is accepted and every planted fault is caught. */
            verdictsAsPlanted
        }
    }

    // ---- 4. The telemetry server: frame sync, decommutation, limits, trending ----------------
    calc def DecommutatePacket {
        doc /* Decommutation of one dictionary packet: the field offsets and widths of the
             * PacketDefinition are the packet's layout, so a packet decommutates when its
             * layout is consistent, and it yields one point per field. */
        in packet : PacketDefinition;
        attribute layoutConsistent : Boolean = packet.layoutConsistent;
        return points : Natural = if layoutConsistent ? packet.fieldCount else 0;
    }
    calc def EngineeringUnits {
        doc /* Raw count to engineering value by the point's linear calibration. */
        in rawCount : Natural;
        in scale : Real;
        in offset : Real;
        return value : Real = rawCount * scale + offset;
    }
    calc def CheckLimits {
        doc /* A sample against its low and high limits with a warning band inside them. */
        in value : Real;
        in lowLimit : Real;
        in highLimit : Real;
        in warningBand : Real;
        return severity : AlarmSeverity = if value < lowLimit or value > highLimit ? AlarmSeverity::violation
            else if value < lowLimit + warningBand or value > highLimit - warningBand ? AlarmSeverity::warning
            else AlarmSeverity::nominal;
    }
    state def AlarmLifecycle {
        doc /* The life of one alarm on the ACE's console: raised by a limit violation, standing
             * until acknowledged, cleared when the point returns inside its limits. */
        entry; then quiet;
        state quiet;
        state raised;
        state acknowledged;
        transition first quiet accept AlarmRaised then raised;
        transition first raised accept AlarmAcknowledge then acknowledged;
        transition first acknowledged accept AlarmCleared then quiet;
        transition first raised accept AlarmCleared then quiet;
    }
    item def AlarmRaised {
        doc /* A limit violation on a monitored point. */
        attribute mnemonic : String;
    }
    item def AlarmAcknowledge {
        doc /* The console operator's acknowledgement of a standing alarm. */
    }
    item def AlarmCleared {
        doc /* The point is back inside its limits. */
    }
    part def TelemetryServer :> GroundSoftwareComponent {
        doc /* Meridian Lantern, the telemetry server: synchronises the transfer frames the
             * gateway forwards, decommutates every dictionary packet by its PacketDefinition
             * layout, converts to engineering units, checks the dictionary limits and the FDIR
             * limit table, raises alarms and trends the resource points. */
        attribute :>> productName = "Meridian Lantern";
        attribute :>> version = "5.0";
        port frames : ~PacketPort;
        port products : ProductPort;
        attribute dictionaryPacketCount : Natural = flightDictionary.packetCount;
        attribute dictionaryPointCount : Natural = flightDictionary.telemetryPointCount;
        attribute housekeepingPointCount : Natural = flightDictionary.housekeepingPointCount;
        attribute limitTable : FdirLimitTable = flightDictionary.limitTable;
        attribute frameLength : StorageCapacityValue = argentSoftwareIcds.spaceLinkProfile.transferFrameLength;
        attribute allPacketsDecommutate : Boolean = flightDictionary.packetsSumToLength;
        calc busVoltageSample : EngineeringUnits { in rawCount = 2048; in scale = 0.0146; in offset = 0.0; }
        calc busVoltageAlarm : CheckLimits { in value = busVoltageSample.value; in lowLimit = 24.0; in highLimit = 34.0; in warningBand = 1.0; }
        calc lowBatteryAlarm : CheckLimits { in value = 0.12; in lowLimit = limitTable.batteryLowFraction; in highLimit = 1.0; in warningBand = 0.05; }
        attribute floorViolationRaised : Boolean = lowBatteryAlarm.severity == AlarmSeverity::violation;
        calc xenonTrend : LinearTrend { in current = 1950.0; in ratePerDay = -3.8; in days = 30.0; }
        exhibit state alarms : AlarmLifecycle;
        assert constraint alarmsAgainstTheDictionary {
            doc /* The nominal bus voltage is quiet and a battery below the FDIR floor is a violation. */
            busVoltageAlarm.severity == AlarmSeverity::nominal and lowBatteryAlarm.severity == AlarmSeverity::violation
        }
    }

    // ---- 5. Flight dynamics ------------------------------------------------------------------
    calc def OrbitDetermination {
        doc /* Orbit determination from a tracking arc: the position uncertainty falls with the
             * square root of the number of passes in the arc from the single-pass figure. */
        in singlePassUncertainty : LengthValue;
        in passesInArc : Natural;
        return positionUncertainty : LengthValue = singlePassUncertainty / RealFunctions::sqrt(passesInArc);
    }
    calc def ManoeuvreDesign {
        doc /* A low-thrust arc from its delta-v: the xenon it needs at the string's effective
             * exhaust velocity (first-order, mass ratio near one) and the arc length at the
             * string's acceleration. */
        in deltaV : SpeedValue;
        in stackMass : MassValue;
        in exhaustVelocity : SpeedValue;
        in acceleration : AccelerationValue;
        attribute xenon : MassValue = stackMass * (deltaV / exhaustVelocity);
        return arcDuration : DurationValue = deltaV / acceleration;
    }
    part def FlightDynamicsTool :> GroundSoftwareComponent {
        doc /* Meridian Sextant, the flight dynamics tool: orbit determination of Argent and of
             * Amaranth from the stations' tracking data, low-thrust arc and DRO insertion design,
             * ephemeris products for the stations and the pass planner, and the delta-v ledger. */
        attribute :>> productName = "Meridian Sextant";
        attribute :>> version = "2.7";
        port tracking : ProductPort;
        port solutions : ProductPort;
        attribute odArcLength : DurationValue = 7.0 [d];
        attribute passesPerArc : Natural = 21;
        calc argentOd : OrbitDetermination { in singlePassUncertainty = 4.5 [km]; in passesInArc = passesPerArc; }
        calc returnArc : ManoeuvreDesign { in deltaV = 1800.0 ['m/s']; in stackMass = 1.4e6 [kg]; in exhaustVelocity = 2.75e4 ['m/s']; in acceleration = 4.0e-5 ['m/s²']; }
        item argentEphemeris : Ephemeris {
            :>> level = ProductLevel::l1; :>> volume = 2.0e8 [B]; :>> span = 30.0 [d]; :>> step = 60.0 [s];
            :>> positionUncertainty = argentOd.positionUncertainty;
        }
        item ledger : DeltaVLedger {
            :>> level = ProductLevel::l2; :>> volume = 1.0e6 [B];
            :>> deltaVPlanned = 1800.0 ['m/s']; :>> deltaVExecuted = 0.0 ['m/s']; :>> xenonCommitted = returnArc.xenon;
        }
        assert constraint arcWithinTheXenonLoad {
            doc /* The return arc's xenon stays inside the tug's propellant load. */
            returnArc.xenon <= 9.0e4 [kg] and argentOd.positionUncertainty < 4.5 [km]
        }
    }

    // ---- 6. The pass planner -----------------------------------------------------------------
    calc def StationVisible {
        doc /* A station sees the tug when the tug's sub-point longitude is within the station's
             * visibility half-width of the station longitude (a deep-space target is above the
             * mask for close to a third of a day from each of three stations). */
        in stationLongitude : AngularMeasureValue;
        in subPointLongitude : AngularMeasureValue;
        in halfWidth : AngularMeasureValue;
        return visible : Boolean = stationLongitude - halfWidth <= subPointLongitude and subPointLongitude <= stationLongitude + halfWidth;
    }
    calc def PassVolume {
        doc /* The data a pass returns at a rate set's downlink rate, after lock-up, in bits.
             * Computed on the numeric values: the pinned runtime multiplies bit/s by s to a
             * plain number, not to a storage capacity (docs/findings/WP-SW-7.md). */
        in rateSet : LinkRateSet;
        in passDurationHours : Real;
        in lockUpSeconds : Real;
        return volumeBits : Real = rateSet.downlinkRate.num * (passDurationHours * 3600.0 - lockUpSeconds);
    }
    occurrence def PlannedDailyPassPlan :> DailyPassPlan {
        doc /* A day the planner produced: the baseline three-pass day with the planner named
             * as producer and the rate set of the planned mode on every pass. */
        attribute rateSet : LinkRateSet;
        attribute lockUp : DurationValue = 300.0 [s];
        calc calderaVolume : PassVolume { in rateSet = PlannedDailyPassPlan::rateSet; in passDurationHours = calderaPass.passDuration.num; in lockUpSeconds = PlannedDailyPassPlan::lockUp.num; }
        attribute imageryFits : Boolean = imageryDownlink.volume.num <= calderaVolume.volumeBits;
    }
    part def PassPlanner :> GroundSoftwareComponent {
        doc /* Meridian Almanac, the pass planner: from the stations' visibility of the tug and
             * the MLS-2 rate set of the planned mode it allocates the day's passes, resolves the
             * conflicts between the three stations and the relay windows, and writes the
             * DailyPassPlan the operations model flies. */
        attribute :>> productName = "Meridian Almanac";
        attribute :>> version = "1.9";
        port ephemerides : ProductPort;
        port plans : ProductPort;
        attribute visibilityHalfWidth : AngularMeasureValue = 65.0 ['°'];
        attribute proximityRates : LinkRateSet = argentSoftwareIcds.spaceLinkProfile.proximityOperationsRates;
        attribute coastRates : LinkRateSet = argentSoftwareIcds.spaceLinkProfile.coastRates;
        calc calderaSeesTheTug : StationVisible { in stationLongitude = meridian.caldera.longitude; in subPointLongitude = -40.0 ['°']; in halfWidth = visibilityHalfWidth; }
        calc tablelandSeesTheTug : StationVisible { in stationLongitude = meridian.tableland.longitude; in subPointLongitude = -40.0 ['°']; in halfWidth = visibilityHalfWidth; }
        occurrence plannedDay : PlannedDailyPassPlan {
            :>> rateSet = PassPlanner::proximityRates;
        }
        assert constraint oneStationAtATime {
            doc /* At the planned sub-point exactly one of the two neighbouring stations is up,
                 * and the imagery downlink fits the proximity-operations rate over a pass. */
            calderaSeesTheTug.visible and not tablelandSeesTheTug.visible and plannedDay.imageryFits
        }
    }

    // ---- 7. Archive and distribution ----------------------------------------------------------
    attribute def RetentionRule {
        doc /* How long a product level is kept online and whether it is distributed outside the
             * operations team. */
        attribute level : ProductLevel;
        attribute retention : DurationValue;
        attribute distributed : Boolean;
    }
    part def DataArchive :> GroundSoftwareComponent {
        doc /* Meridian Vault, the archive: catalogues every product level with a checksum,
             * keeps each by its retention rule and distributes the released levels. */
        attribute :>> productName = "Meridian Vault";
        attribute :>> version = "4.1";
        port ingest : ProductPort;
        port distribution : ProductPort;
        attribute l0Rule : RetentionRule { :>> level = ProductLevel::l0; :>> retention = 3650.0 [d]; :>> distributed = false; }
        attribute l1Rule : RetentionRule { :>> level = ProductLevel::l1; :>> retention = 3650.0 [d]; :>> distributed = true; }
        attribute l2Rule : RetentionRule { :>> level = ProductLevel::l2; :>> retention = 3650.0 [d]; :>> distributed = true; }
        attribute l3Rule : RetentionRule { :>> level = ProductLevel::l3; :>> retention = 3650.0 [d]; :>> distributed = true; }
        attribute rules : RetentionRule[4] = (l0Rule, l1Rule, l2Rule, l3Rule);
        attribute checksumWidth : Natural = 32;
        attribute catalogued : Natural = 0;
        attribute distributedLevels : Natural = size(rules->select { in r : RetentionRule; r.distributed });
        assert constraint rawFramesStayInHouse {
            doc /* Raw frames are kept but never distributed; every released level has a rule. */
            distributedLevels == 3 and size(rules) == 4
        }
    }

    // ---- 8. The anomaly tracker ----------------------------------------------------------------
    state def AnomalyLifecycle {
        doc /* The life of an anomaly: opened from an alarm or an event, triaged on console
             * against the contingency procedures, investigated by the subsystem engineer, then
             * dispositioned by the anomaly board. */
        entry; then opened;
        state opened;
        state triaged;
        state investigating;
        state closed;
        transition first opened accept AnomalyTriaged then triaged;
        transition first triaged accept AnomalyAssigned then investigating;
        transition first investigating accept AnomalyDispositioned then closed;
    }
    item def AnomalyTriaged {
        doc /* The console has matched the anomaly to a contingency procedure or to none. */
        attribute procedure : String;
    }
    item def AnomalyAssigned {
        doc /* The anomaly is assigned to a subsystem engineer. */
    }
    item def AnomalyDispositioned {
        doc /* The board's disposition. */
        attribute disposition : AnomalyDisposition;
    }
    part def AnomalyTracker :> GroundSoftwareComponent {
        doc /* Meridian Ledger, the anomaly tracker: every alarm or fault event the telemetry
             * server raises opens an anomaly, the console answers it with the contingency
             * procedures of the operations model, and the anomaly board dispositions it. */
        attribute :>> productName = "Meridian Ledger";
        attribute :>> version = "2.3";
        port alarms : ProductPort;
        port reports : ProductPort;
        attribute faultEventCount : Natural = flightDictionary.faultEventCount;
        attribute safeModeRecoveryAuthority : DecisionAuthority = DecisionAuthority::flightDirector;
        exhibit state lifecycle : AnomalyLifecycle;
        item thrusterDropout : AnomalyReport {
            :>> level = ProductLevel::l1; :>> volume = 5.0e5 [B];
            :>> anomalyId = 1; :>> triggerMnemonic = thrusterFailureResponse.triggerMnemonic;
            :>> disposition = AnomalyDisposition::procedureChange; :>> authority = DecisionAuthority::anomalyBoard;
        }
    }

    // ---- 9. Proximity-operations and capture planning ----------------------------------------
    attribute def RelativeNavigationProduct {
        doc /* The relative state of the tug to Amaranth the planner works from. */
        attribute range : LengthValue;
        attribute rangeRate : SpeedValue;
        attribute rangeUncertainty : LengthValue;
    }
    part def ProximityPlanner :> GroundSoftwareComponent {
        doc /* Meridian Compass, the proximity-operations planner: relative navigation products,
             * the keep-out check of FR-002 on every planned approach, the go/no-go checklist and
             * the abort criteria the capture sequence is uplinked with. */
        attribute :>> productName = "Meridian Compass";
        attribute :>> version = "1.4";
        port navigation : ProductPort;
        port plans : ProductPort;
        attribute keepOutRadius : LengthValue = approachKeepOut.keepOutRadius;
        attribute standoff : RelativeNavigationProduct { :>> range = 2000.0 [m]; :>> rangeRate = 0.0 ['m/s']; :>> rangeUncertainty = 5.0 [m]; }
        attribute finalApproach : RelativeNavigationProduct { :>> range = 50.0 [m]; :>> rangeRate = -0.05 ['m/s']; :>> rangeUncertainty = 0.5 [m]; }
        attribute abortRangeRate : SpeedValue = -0.2 ['m/s'];
        attribute abortRangeUncertainty : LengthValue = 2.0 [m];
        item checklist : GoNoGoChecklist { :>> level = ProductLevel::l3; :>> volume = 2.0e5 [B]; :>> itemsTotal = 12; :>> itemsGo = 12; }
        assert constraint standoffKeepOut : ApproachKeepOut {
            doc /* The standoff is outside the keep-out sphere with no authorisation. */
            in :>> rangeToTarget = standoff.range; in :>> keepOutRadius = ProximityPlanner::keepOutRadius; in :>> approachAuthorised = false;
        }
        assert constraint authorisedApproach : ApproachKeepOut {
            doc /* The final approach is inside the sphere only because a capture sequence authorises it. */
            in :>> rangeToTarget = finalApproach.range; in :>> keepOutRadius = ProximityPlanner::keepOutRadius; in :>> approachAuthorised = checklist.go;
        }
        assert constraint abortCriteriaHold {
            doc /* The planned approach stays inside the abort criteria. */
            finalApproach.rangeRate > abortRangeRate and finalApproach.rangeUncertainty < abortRangeUncertainty
        }
    }

    // ---- 10. Simulators and test beds ---------------------------------------------------------
    part def Simulator :> TestBed, GroundSoftwareComponent {
        doc /* A test bed run by Meridian Operations Suite software: the suite's own components
             * drive it through the same packet interface as the flight system. */
        attribute flightSoftwareInTheLoop : Boolean;
        attribute hardwareInTheLoop : Boolean;
        port packets : PacketPort;
    }
    part def FlightSoftwareInTheLoopSimulator :> Simulator {
        doc /* Meridian Mirror: the flight software image running on an emulated flight computer
             * with simulated dynamics, used for sequence and procedure validation. */
        attribute :>> productName = "Meridian Mirror";
        attribute :>> version = "6.1";
        attribute :>> flightSoftwareInTheLoop = true;
        attribute :>> hardwareInTheLoop = false;
    }
    part def HardwareInTheLoopTestBed :> Simulator {
        doc /* Meridian Anvil: the flatsat's engineering-model avionics with the flight software,
             * driven by the suite. */
        attribute :>> productName = "Meridian Anvil";
        attribute :>> version = "2.0";
        attribute :>> flightSoftwareInTheLoop = true;
        attribute :>> hardwareInTheLoop = true;
    }
    part def DynamicsSimulator :> Simulator {
        doc /* Meridian Orrery: the six-degree-of-freedom proximity-operations simulator with the
             * GNC flight code in the loop. */
        attribute :>> productName = "Meridian Orrery";
        attribute :>> version = "3.3";
        attribute :>> flightSoftwareInTheLoop = true;
        attribute :>> hardwareInTheLoop = false;
    }
    part def CaptureRigController :> Simulator {
        doc /* Meridian Capstan: the capture rig's control and data software. */
        attribute :>> productName = "Meridian Capstan";
        attribute :>> version = "1.2";
        attribute :>> flightSoftwareInTheLoop = false;
        attribute :>> hardwareInTheLoop = true;
    }
    part def SimulatedTestBedSet :> TestBedSet {
        doc /* The programme's test beds, each typed by the software that runs it. */
        part :>> flatsat : HardwareInTheLoopTestBed;
        part :>> captureRig : CaptureRigController;
        part :>> dynamicsSimulator : DynamicsSimulator;
        part :>> trajectoryTool : FlightSoftwareInTheLoopSimulator;
    }

    // ---- 11. The sequencer and flight-rule checker (executable) -------------------------------
    action def LoadPlannedSequence {
        doc /* The planned sequence is one the tug stores on board. */
        in sequenceId : Natural;
        in storedSequences : Natural[*];
        out loaded : Boolean = storedSequences->includes(sequenceId);
    }
    calc def CheckFlightRules {
        doc /* The flight rules of the operations model applied to the planned flight state:
             * FR-001 no thrust during a relay pass (NoThrustDuringRelay), FR-002 the keep-out
             * sphere unless the approach is authorised (ApproachKeepOut), FR-003 the sun
             * exclusion with the cover open (SunExclusion), FR-004 the battery floor
             * (BatteryDepthOfDischarge), and the planned mode is a flight mode. The first rule
             * broken names the refusal. The inputs are the scalar fields of the planned
             * sequence, the form the pinned runtime evaluates (docs/findings/WP-SW-7.md). */
        in thrusting : Boolean;
        in relayPassActive : Boolean;
        in rangeToTarget : LengthValue;
        in approachAuthorised : Boolean;
        in sunAngle : AngularMeasureValue;
        in coverOpen : Boolean;
        in stateOfCharge : Real;
        in plannedMode : TugMode;
        in keepOutRadius : LengthValue;
        in exclusionHalfAngle : AngularMeasureValue;
        in stateOfChargeFloor : Real;
        attribute noThrustDuringRelay : Boolean = not (thrusting and relayPassActive);
        attribute keepOutKept : Boolean = rangeToTarget >= keepOutRadius or approachAuthorised;
        attribute sunExclusionKept : Boolean = sunAngle >= exclusionHalfAngle or not coverOpen;
        attribute batteryFloorKept : Boolean = stateOfCharge >= stateOfChargeFloor;
        attribute modeIsFlightMode : Boolean = allFlightModes->includes(plannedMode);
        return allPassed : Boolean = noThrustDuringRelay and keepOutKept and sunExclusionKept and batteryFloorKept and modeIsFlightMode;
        attribute violated : String = if not noThrustDuringRelay ? "FR-001 thrust during a relay pass"
            else if not keepOutKept ? "FR-002 inside the keep-out sphere without authorisation"
            else if not sunExclusionKept ? "FR-003 sun inside the exclusion cone with the cover open"
            else if not batteryFloorKept ? "FR-004 battery below the depth-of-discharge floor"
            else if not modeIsFlightMode ? "planned mode is not a flight mode"
            else "none";
    }
    action def GroundSequenceCheck {
        doc /* The checker's run on one planned sequence: load it, check the flight rules, then
             * clear it or refuse it with the rule it broke. */
        in candidate : PlannedSequence;
        in stored : Natural[*];
        attribute verdict : SequenceVerdict := SequenceVerdict::pending;
        attribute reason : String := "not checked";
        calc rules : CheckFlightRules {
            in thrusting = candidate.thrusting;
            in relayPassActive = candidate.relayPassActive;
            in rangeToTarget = candidate.rangeToTarget;
            in approachAuthorised = candidate.approachAuthorised;
            in sunAngle = candidate.sunAngle;
            in coverOpen = candidate.coverOpen;
            in stateOfCharge = candidate.stateOfCharge;
            in plannedMode = candidate.plannedMode;
            in keepOutRadius = approachKeepOut.keepOutRadius;
            in exclusionHalfAngle = 30.0 ['°'];
            in stateOfChargeFloor = batteryDepthOfDischarge.stateOfChargeFloor;
        }
        action load : LoadPlannedSequence { in sequenceId = candidate.sequenceId; in storedSequences = stored; }
        then decide;
            if load.loaded and rules.allPassed then clear;
            else refuse;
        action clear {
            doc /* Cleared: the sequence goes to the uplink queue. */
            assign verdict := SequenceVerdict::cleared;
            then assign reason := "cleared for uplink";
        }
        then done;
        action refuse {
            doc /* Refused: the first broken rule, or the sequence is not stored on board. */
            assign verdict := SequenceVerdict::refused;
            then assign reason := if load.loaded ? rules.violated else "sequence not stored on board";
        }
        then done;
    }
    part def FlightRuleChecker :> GroundSoftwareComponent {
        doc /* Meridian Warden, the sequencer and flight-rule checker: every planned sequence is
             * loaded, checked against FR-001 to FR-004 and either released to the uplink queue
             * as a LoadSequence command or refused. The release is a send from this part's own
             * port inside its performed action, the form the pinned runtime routes. */
        attribute :>> productName = "Meridian Warden";
        attribute :>> version = "2.5";
        port uplinkQueue : ~PacketPort;
        attribute storedSequences : Natural[6] = (1, 2, 3, 4, 5, 6);
        attribute plannedSequence : PlannedSequence default = thrustArcInCoast;
        attribute released : Natural := 0;
        perform action check : GroundSequenceCheck { in candidate = plannedSequence; in stored = storedSequences; }
        then perform action release {
            doc /* Release a cleared sequence as a LoadSequence command; hold a refused one. */
            first start;
            then decide;
                if check.verdict == SequenceVerdict::cleared then uplink;
                else hold;
            action uplink {
                send new LoadSequence(sequenceId = plannedSequence.sequenceId) via uplinkQueue;
                then assign released := released + 1;
            }
            then done;
            action hold {
                doc /* The refused sequence stays with the sequence engineer. */
            }
            then done;
        }
    }
    part def SequenceStoreStandIn {
        doc /* The flight side of the exchange for the ground runs: the on-board sequence store
             * accepting LoadSequence commands through the packet port of the space link, counting
             * the loads it accepts. */
        port packets : PacketPort;
        attribute loadsAccepted : Natural := 0;
        exhibit state store {
            entry; then idle;
            state idle;
            transition first idle accept LoadSequence via packets do assign loadsAccepted := loadsAccepted + 1 then idle;
        }
    }
    part def UplinkExchange {
        doc /* The ground-to-flight exchange under check: the checker's uplink queue to the
             * flight packet port through the TI-021 link profile. */
        part checker : FlightRuleChecker;
        part flight : SequenceStoreStandIn;
        interface link : SpaceLinkProfileIcd connect flight.packets to checker.uplinkQueue;
    }
    attribute thrustArcInCoast : PlannedSequence {
        doc /* The nominal case: the thrust-arc sequence planned into a coast day with no relay
             * pass, far from the target, cover closed, battery full. */
        :>> sequenceId = 1; :>> plannedMode = TugMode::thrust; :>> thrusting = true; :>> relayPassActive = false;
        :>> rangeToTarget = 1.0e6 [km]; :>> approachAuthorised = false; :>> sunAngle = 90.0 ['°']; :>> coverOpen = false; :>> stateOfCharge = 0.95;
    }
    attribute thrustArcDuringRelay : PlannedSequence {
        doc /* The refused case: the same thrust-arc sequence planned into a relay pass at the
             * standoff — FR-001. */
        :>> sequenceId = 1; :>> plannedMode = TugMode::proximityOperations; :>> thrusting = true; :>> relayPassActive = true;
        :>> rangeToTarget = 2.0 [km]; :>> approachAuthorised = false; :>> sunAngle = 90.0 ['°']; :>> coverOpen = false; :>> stateOfCharge = 0.95;
    }
    part nominalUplink : UplinkExchange {
        doc /* The nominal sequence is cleared and one load reaches the flight side. */
        part :>> checker { attribute :>> plannedSequence = thrustArcInCoast; }
    }
    part relayConflictUplink : UplinkExchange {
        doc /* The thrust-during-relay sequence is refused under FR-001 and nothing is sent. */
        part :>> checker { attribute :>> plannedSequence = thrustArcDuringRelay; }
    }

    // ---- 12. The suite over the ground segment and the ground-to-flight interfaces -----------
    part def SuitePacketGateway :> MeridianPacketGateway {
        doc /* The packet gateway with its operations-centre side: frames from the stations
             * become packets on `toSuite`, commands from the suite become frames. */
        port toSuite : PacketPort;
    }
    interface def GroundPacketRelay {
        doc /* The packet relay inside the operations centre, from the gateway to a suite
             * component: telemetry packets forward, command packets back. */
        end gateway : PacketPort;
        end suite : ~PacketPort;
        flow of TelemetryPacket from gateway.telemetry to suite.telemetry;
        flow of CommandPacket from suite.command to gateway.command;
    }
    part def SoftwareOperationsCentre :> MeridianOperationsCentre {
        doc /* The operations centre with its parts typed by the suite, the ACE console
             * position, the packet gateway and the relays between them. */
        part :>> commandBuilder : CommandBuilder;
        part :>> sequencer : FlightRuleChecker;
        part :>> telemetryServer : TelemetryServer;
        part :>> passPlanner : PassPlanner;
        part :>> anomalyTracker : AnomalyTracker;
        part :>> proximityPlanner : ProximityPlanner;
        part ace : OperationsRole {
            attribute :>> title = "ACE, real-time command and telemetry console";
            attribute :>> shiftLength = 8.0 [h];
            attribute :>> positionsPerShift = 1;
        }
        part gateway : SuitePacketGateway;
        interface telemetryRelay : GroundPacketRelay connect gateway.toSuite to telemetryServer.frames;
        interface commandRelay : GroundPacketRelay connect gateway.toSuite to commandBuilder.uplinkQueue;
        interface sequenceRelay : GroundPacketRelay connect gateway.toSuite to sequencer.uplinkQueue;
        connect telemetryServer.products to anomalyTracker.alarms;
        connect passPlanner.plans to toFlightDynamics;
        connect proximityPlanner.plans to toScience;
    }
    part def SoftwareFlightDynamics :> MeridianFlightDynamics {
        doc /* The flight-dynamics facility with its tool typed by the suite. */
        part :>> flightDynamicsTool : FlightDynamicsTool;
        connect fromOperations to flightDynamicsTool.tracking;
        connect flightDynamicsTool.solutions to toScience;
    }
    part def SoftwareScienceDataSystem :> MeridianScienceDataSystem {
        doc /* The science data system with its archive typed by the suite. */
        part :>> dataArchive : DataArchive;
        connect fromOperations to dataArchive.ingest;
        connect dataArchive.distribution to archive;
    }
    part def MeridianOperationsSuite {
        doc /* The Meridian Operations Suite deployed over the ground segment, with the flight
             * software it talks to through the TI-021 link profile and the test beds it drives. */
        part moc : SoftwareOperationsCentre;
        part fdf : SoftwareFlightDynamics;
        part sds : SoftwareScienceDataSystem;
        part testBeds : SimulatedTestBedSet;
        part software : ArgentFlightSoftware;
        interface spaceLink : SpaceLinkProfileIcd connect software.telecom.spaceLink to moc.gateway.packets;
        interface flatsatLink : SpaceLinkProfileIcd connect testBeds.flatsat.packets to moc.gateway.packets;
        connect moc.toFlightDynamics to fdf.fromOperations;
        connect moc.toScience to sds.fromOperations;
        connect fdf.toScience to sds.fromFlightDynamics;
        ref components : GroundSoftwareComponent[12] = (
            moc.commandBuilder, moc.sequencer, moc.telemetryServer, moc.passPlanner, moc.anomalyTracker, moc.proximityPlanner,
            fdf.flightDynamicsTool, sds.dataArchive,
            testBeds.flatsat, testBeds.captureRig, testBeds.dynamicsSimulator, testBeds.trajectoryTool
        );
        attribute componentCount : Natural = size(components);
        attribute productNames : String[*] = components.productName;
        attribute simulatorCount : Natural = size(testBeds.flatsat.productName) + size(testBeds.captureRig.productName)
            + size(testBeds.dynamicsSimulator.productName) + size(testBeds.trajectoryTool.productName);
    }
    part meridianOperationsSuite : MeridianOperationsSuite {
        doc /* The suite as deployed for Tethys. */
    }

    // ---- 13. Use cases per operations role ----------------------------------------------------
    use case def BuildAndUplinkCommand {
        doc /* The ACE builds a command in the command builder, the builder validates it against
             * the dictionary, a hazardous command collects the mission manager's second
             * signature, and the command goes to the uplink queue. */
        subject suite : MeridianOperationsSuite;
        actor ace : OperationsRole;
        actor approver : OperationsRole;
    }
    use case def PlanAndClearSequence {
        doc /* The sequence engineer plans an on-board sequence into the flight state, the
             * checker clears or refuses it, and a cleared sequence is released as a load. */
        subject suite : MeridianOperationsSuite;
        actor sequenceEngineer : OperationsRole;
    }
    use case def MonitorAndRespond {
        doc /* The ACE watches the telemetry server's alarms and trends, acknowledges alarms and
             * opens anomalies; the flight director authorises contingency procedures. */
        subject suite : MeridianOperationsSuite;
        actor ace : OperationsRole;
        actor flightDirector : OperationsRole;
    }
    use case def DetermineOrbitAndDesignArc {
        doc /* The navigator runs orbit determination on the arc, designs the next thrust arc,
             * and publishes ephemerides to the stations and the pass planner. */
        subject suite : MeridianOperationsSuite;
        actor navigator : OperationsRole;
    }
    use case def DispositionAnomaly {
        doc /* The anomaly board reviews an investigated anomaly and dispositions it. */
        subject suite : MeridianOperationsSuite;
        actor anomalyBoard : OperationsRole;
    }
    use case def DirectTheFlight {
        doc /* The flight director's shift: monitoring, sequence clearance and the go/no-go for
             * proximity operations, including the role use cases. */
        subject suite : MeridianOperationsSuite;
        actor flightDirector : OperationsRole;
        include use case monitor : MonitorAndRespond;
        include use case clearance : PlanAndClearSequence;
        include use case commands : BuildAndUplinkCommand;
        include use case navigation : DetermineOrbitAndDesignArc;
        include use case board : DispositionAnomaly;
    }
    use case directTheFlight : DirectTheFlight {
        doc /* The flight director's shift over the deployed suite. */
    }

    // ---- 14. Ground software requirements ------------------------------------------------------
    requirement <'GS-001'> commandValidation {
        doc /* The command builder accepts only commands whose mnemonic is in the flight
             * dictionary, whose argument is inside the dictionary range and whose planned mode
             * is an allowed mode, and holds hazardous commands for a second approval. */
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        subject builder : CommandBuilder;
        require constraint {
            doc /* The planted requests get the verdicts the rule names. */
            builder.verdictsAsPlanted
        }
    }
    requirement <'GS-002'> sequenceClearance {
        doc /* No on-board sequence is uplinked before the checker has cleared it against
             * FR-001 to FR-004; a refused sequence is not released. */
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        subject exchange : UplinkExchange;
        require constraint {
            doc /* A released load implies a cleared verdict. */
            exchange.checker.released == 0 or exchange.checker.check.verdict == SequenceVerdict::cleared
        }
    }
    requirement <'GS-003'> dictionaryDrivenTelemetry {
        doc /* The telemetry server decommutates every packet by its dictionary layout and
             * checks limits from the dictionary and the FDIR limit table. */
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        subject server : TelemetryServer;
        require constraint {
            doc /* Every dictionary packet decommutates and the FDIR floor raises a violation. */
            server.allPacketsDecommutate and server.floorViolationRaised
        }
    }
    requirement <'GS-004'> plannedPassesFitTheLink {
        doc /* A pass plan the planner produces carries its downlinks at the MLS-2 rate set of
             * the planned mode. */
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        subject planner : PassPlanner;
        require constraint {
            doc /* The imagery downlink fits the planned pass. */
            planner.plannedDay.imageryFits
        }
    }
    satisfy commandValidation by meridianOperationsSuite.moc.commandBuilder {
        doc /* Meridian Forge satisfies the command validation requirement. */
    }
    satisfy sequenceClearance by nominalUplink {
        doc /* The nominal exchange satisfies sequence clearance. */
    }
    satisfy dictionaryDrivenTelemetry by meridianOperationsSuite.moc.telemetryServer {
        doc /* Meridian Lantern satisfies the dictionary-driven telemetry requirement. */
    }
    satisfy plannedPassesFitTheLink by meridianOperationsSuite.moc.passPlanner {
        doc /* Meridian Almanac satisfies the pass-plan requirement. */
    }
}
