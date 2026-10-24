// Software safety, assurance and verification and validation: the software criticality
// classification of every flight and ground software component, the software contributions to
// the hazards of TethysSafety and the software controls that hold them, the software FMECA, a
// fault tree with software basic events, the inhibit-independence constraints, the assurance
// activities per level with a release-readiness gate, and the software verification cases per
// level and test bed with their coverage of the software functions. Mission tier.
package TethysSoftwareAssurance {
    doc /* Software safety, assurance and V&V of the Argent Flight Executive and the Meridian
         * Operations Suite. Every software component carries an assurance level derived from
         * the hazards of TethysSafety it controls or mitigates; the hazard analysis names the
         * software causes and controls per hazard; the FMECA covers the twelve applications and
         * the executive; the assurance activities per level gate the release; the verification
         * cases per level and test bed verify the system requirements the software satisfies.
         * Verdicts are honest: a case not yet run is planned, not passed. */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SequenceFunctions::*;
    private import ControlFunctions::*;
    private import CauseAndEffect::*;
    private import VerificationCases::*;
    private import ModelingMetadata::*;
    private import TethysRequirements::Verification;
    private import TethysRequirements::VerificationLevel;
    private import TethysRequirements::VerificationStage;
    private import TethysRequirementsL2::faultResponse;
    private import TethysRequirementsL2::commandLatency;
    private import TethysRequirementsL2::autonomousSurvival;
    private import TethysRequirementsL2::thrustRedundancy;
    private import TethysRequirementsL3L4::faultDetectionLatency;
    private import TethysRequirementsL3L4::relativeNavigation;
    private import TethysRequirementsL3L4::fdirTaskPeriod;
    private import TethysRequirementsL3L4::sequenceTurnaround;
    private import TethysRequirementsL3L4::monitoringAutomation;
    private import TethysRequirementsL3L4::impactScreening;
    private import TethysOperations::noThrustDuringRelay;
    private import TethysOperations::approachKeepOut;
    private import TethysOperations::batteryDepthOfDischarge;
    private import TethysOperations::dictionaryConsistent;
    private import TethysSafety::Severity;
    private import TethysSafety::DetectionMeans;
    private import TethysSafety::ControlStatus;
    private import TethysSafety::Hazard;
    private import TethysSafety::HazardControl;
    private import TethysSafety::hazardLog;
    private import TethysSafety::BasicEvent;
    private import TethysSafety::AndGate;
    private import TethysSafety::OrGate;
    private import TethysSafety::earthMissDistance;
    private import TethysSafety::finalTargetingAuthority;
    private import TethysSafety::captureAbortAuthority;
    private import TethysSafety::highVoltageInhibit;
    private import TethysFdir::FaultResponse;
    private import TethysFdir::NoFireWithoutInhibitsRemoved;
    private import TethysFlightSoftware::SoftwareComponent;
    private import TethysFlightSoftware::argentSoftware;
    private import TethysFlightDictionary::flightDictionary;
    private import TethysMeridian::GroundSoftwareComponent;
    private import TethysGroundSoftware::meridianOperationsSuite;
    private import TethysGroundSoftware::commandValidation;
    private import TethysGroundSoftware::sequenceClearance;
    private import TethysGroundSoftware::dictionaryDrivenTelemetry;
    private import TethysGroundSoftware::plannedPassesFitTheLink;
    private import TethysAllocations::SoftwareFunction;
    private import TethysAllocations::missionFunctions;
    private import TethysFlightSoftware::SoftwareTug;
    private import TethysGroundSoftware::MeridianOperationsSuite;
    private import TethysFlightDictionary::CommandDefinition;
    private import TethysRequirementsL2::earthImpactExclusion;
    private import TethysRequirementsL2::captureEnvelope;
    private import TethysRequirementsL2::captureQualification;
    private import TethysRequirementsL2::deepSpaceLink;
    private import TethysRequirementsL2::characterisationProducts;
    private import TethysRequirementsL3L4::sepThrust;
    private import TethysRequirementsL3L4::arrayPowerAtTarget;
    private import TethysRequirementsL3L4::heatRejection;
    private import TethysRequirementsL3L4::deepSpaceEirp;
    private import TethysRequirementsL3L4::proximityLinkRange;
    private import TethysRequirementsL3L4::cinchMotorTorque;

    // ---------------------------------------------------------------- vocabulary

    enum def SoftwareAssuranceLevel {
        doc /* The assurance level of a software component, highest first. Level A: a failure
             * is a cause of, or removes a control of, a catastrophic or critical hazard; level B:
             * a failure loses the primary objective or a safety-critical service's input; level C:
             * a failure degrades the mission or an operations product; level D: no mission
             * effect beyond rework. The level sets the assurance activities and the independent
             * verification and validation that level A alone requires. */
        levelA; levelB; levelC; levelD;
    }

    enum def ActivityStatus {
        doc /* Life-cycle status of an assurance activity. */
        planned; inProgress; complete;
    }

    enum def VerificationVerdict {
        doc /* The as-run result of a software verification case: planned until it has run,
             * then pass or fail against its pass criterion. */
        planned; pass; fail;
    }

    enum def SoftwareTestLevel {
        doc /* The level a software verification case runs at: unit tests of one component,
             * integration of components on the software bus, the flight software image on the
             * emulated computer (flight-software-in-the-loop), the engineering-model avionics
             * (hardware-in-the-loop), the full flatsat with flight software and simulated
             * dynamics, and model-in-the-loop against the executable model's pinned runs. */
        unit; integration; flightSoftwareInTheLoop; hardwareInTheLoop; flatsat; modelInTheLoop;
    }

    enum def SoftwareControlKind {
        doc /* The kind of software control that holds a hazard: an on-board inhibit, a two-step
             * (critical or hazardous) command on the ground and on board, or a fault detection,
             * isolation and recovery response. */
        inhibit; twoStepCommand; fdirResponse;
    }

    metadata def Assurance {
        doc /* The assurance level of a classified software component and the rationale that
             * derives it from the hazard log. */
        attribute level : SoftwareAssuranceLevel;
        attribute rationale : String;
    }

    // ---------------------------------------------------------------- classification (SW-044)

    part def SoftwareClassification {
        doc /* One row of the software classification register: the component, its level, the
             * rationale naming the hazards it controls or mitigates, and the hazards themselves. */
        attribute level : SoftwareAssuranceLevel;
        attribute rationale : String;
        ref occurrence controls : Hazard [0..*] {
            doc /* The hazards whose controls or causes this component implements or touches. */
        }
        attribute independentVvRequired : Boolean = level == SoftwareAssuranceLevel::levelA;
    }
    part def FlightSoftwareClassification :> SoftwareClassification {
        doc /* A classification row for a flight software component. */
        ref part component : SoftwareComponent;
    }
    part def GroundSoftwareClassification :> SoftwareClassification {
        doc /* A classification row for a Meridian Operations Suite component. */
        ref part component : GroundSoftwareComponent;
    }

    part classificationRegister {
        doc /* The software classification register: every component of the Argent flight
             * software (the twelve applications, the executive, the board support package and
             * the nine core services) and every Meridian Operations Suite component (eight
             * operations components and four simulators), with its assurance level. The level
             * follows the hazard log: a component on a control path of TH-001 (Earth impact),
             * TH-002 (collision), TH-004 (tumble) or TH-006 (premature high voltage) is level A. */

        part captureControl : FlightSoftwareClassification {
            doc /* Fires the cinch through the three-inhibit gate and runs despin. */
            ref part :>> component = argentSoftware.cdh.software.captureControl;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            attribute :>> rationale = "cinch firing (TH-003 bag tear if fired on an over-envelope body) and despin (TH-004); holds the arm, ground-enable and capture-mode inhibits of TethysFdir::ArmAndFireCaptureCinch";
            ref :>> controls = (hazardLog.overEnvelopeTarget, hazardLog.uncontrolledTumble, hazardLog.tugTargetCollision);
            @Assurance { level = SoftwareAssuranceLevel::levelA; rationale = "cinch firing inhibits and despin (TH-003, TH-004)"; }
        }
        part fdir : FlightSoftwareClassification {
            doc /* The FDIR supervisor: safe mode, thruster switchover, the Earth-impact abort. */
            ref part :>> component = argentSoftware.cdh.software.fdir;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            attribute :>> rationale = "the Earth-impact exclusion monitor and abort (TH-001), safe-mode requests on command loss, thruster and PPU fault recovery (TH-004, TH-005)";
            ref :>> controls = (hazardLog.earthImpactByTarget, hazardLog.uncontrolledTumble, hazardLog.derelictTug);
            @Assurance { level = SoftwareAssuranceLevel::levelA; rationale = "Earth-impact abort and safe mode (TH-001, TH-005)"; }
        }
        part modeManagement : FlightSoftwareClassification {
            doc /* The mode manager: safe-mode entry, the capture-mode inhibit, the command dispatcher. */
            ref part :>> component = argentSoftware.cdh.software.modeManagement;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            attribute :>> rationale = "safe-mode entry and the capture-mode inhibit (TH-003); dispatches every hazardous command (TH-001, TH-006)";
            ref :>> controls = (hazardLog.earthImpactByTarget, hazardLog.overEnvelopeTarget, hazardLog.prematureHighVoltage);
            @Assurance { level = SoftwareAssuranceLevel::levelA; rationale = "safe mode and the capture-mode inhibit (TH-001, TH-003, TH-006)"; }
        }
        part gnc : FlightSoftwareClassification {
            doc /* Guidance, navigation and control: the final targeting burn and relative navigation. */
            ref part :>> component = argentSoftware.cdh.software.gnc;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            attribute :>> rationale = "computes the lunar gravity-assist targeting burn (TH-001 erroneous final targeting) and the relative state in proximity operations (TH-002)";
            ref :>> controls = (hazardLog.earthImpactByTarget, hazardLog.tugTargetCollision);
            @Assurance { level = SoftwareAssuranceLevel::levelA; rationale = "final targeting burn and relative navigation (TH-001, TH-002)"; }
        }
        part autonomy : FlightSoftwareClassification {
            doc /* The sequencing engine and the autonomous capture abort. */
            ref part :>> component = argentSoftware.cdh.software.autonomy;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            attribute :>> rationale = "autonomous abort to the 500 m hold point (TH-002, TS-803) and the on-board sequence interlock on uncleared thrust arcs (TH-001)";
            ref :>> controls = (hazardLog.tugTargetCollision, hazardLog.earthImpactByTarget);
            @Assurance { level = SoftwareAssuranceLevel::levelA; rationale = "capture abort and sequence interlock (TH-001, TH-002)"; }
        }
        part sepControl : FlightSoftwareClassification {
            doc /* Solar-electric propulsion control: thrust arcs, PPU high voltage. */
            ref part :>> component = argentSoftware.cdh.software.sepControl;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            attribute :>> rationale = "thrust on the final targeting arc (TH-001) and the software inhibit on PPU high voltage before separation plus 600 s (TH-006, TS-807)";
            ref :>> controls = (hazardLog.earthImpactByTarget, hazardLog.prematureHighVoltage);
            @Assurance { level = SoftwareAssuranceLevel::levelA; rationale = "SEP thrust and the high-voltage inhibit (TH-001, TH-006)"; }
        }
        part executive : FlightSoftwareClassification {
            doc /* The Kestrel executive: partitions, scheduling, the time and space isolation every
                 * level-A application relies on. */
            ref part :>> component = argentSoftware.cdh.software.executive;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            attribute :>> rationale = "schedules and isolates every level-A application; a scheduling failure removes every software control at once";
            ref :>> controls = (hazardLog.earthImpactByTarget, hazardLog.tugTargetCollision, hazardLog.overEnvelopeTarget);
            @Assurance { level = SoftwareAssuranceLevel::levelA; rationale = "hosts every level-A application"; }
        }
        part boardSupport : FlightSoftwareClassification {
            doc /* The board support package: the device drivers behind every actuator command. */
            ref part :>> component = argentSoftware.cdh.software.boardSupport;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            attribute :>> rationale = "drives the remote interface units that actuate the cinch, the PPUs and the thrusters; the last software element before each hazardous actuator";
            ref :>> controls = (hazardLog.overEnvelopeTarget, hazardLog.prematureHighVoltage);
            @Assurance { level = SoftwareAssuranceLevel::levelA; rationale = "actuator drivers of the hazardous functions"; }
        }
        part cdh : FlightSoftwareClassification {
            doc /* Command and data handling: command routing, telemetry, the data bus. */
            ref part :>> component = argentSoftware.cdh.software.cdh;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "routes commands and telemetry; a failure loses contact until the redundant computer takes over, no hazard cause of its own";
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "command and telemetry routing, redundant"; }
        }
        part powerManagement : FlightSoftwareClassification {
            doc /* Battery and load management. */
            ref part :>> component = argentSoftware.cdh.software.powerManagement;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "load shedding keeps the battery above the floor; a failure degrades to safe mode, no hazard cause";
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "load shedding, safe-mode fallback"; }
        }
        part telecom : FlightSoftwareClassification {
            doc /* The space link. */
            ref part :>> component = argentSoftware.cdh.software.telecom;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "carries the ground enable and the ground authority of TS-802; a failure is a loss of contact handled by the command-loss timer";
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "space link, command-loss timer fallback"; }
        }
        part parameterBootUpdate : FlightSoftwareClassification {
            doc /* Parameter tables and software images. */
            ref part :>> component = argentSoftware.cdh.software.parameterBootUpdate;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "a corrupted image or table is caught by the boot check and the safe image; no hazard cause";
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "boot check and safe image"; }
        }
        part thermalControl : FlightSoftwareClassification {
            doc /* Heater zones. */
            ref part :>> component = argentSoftware.cdh.software.thermalControl;
            attribute :>> level = SoftwareAssuranceLevel::levelC;
            attribute :>> rationale = "heater failures are slow and trended by the ground";
            @Assurance { level = SoftwareAssuranceLevel::levelC; rationale = "slow failure, ground trending"; }
        }
        part inspectorHandling : FlightSoftwareClassification {
            doc /* Inspector release and relay. */
            ref part :>> component = argentSoftware.cdh.software.inspectorHandling;
            attribute :>> level = SoftwareAssuranceLevel::levelC;
            attribute :>> rationale = "the release is a two-step command; a relay failure loses survey products, not the mission";
            @Assurance { level = SoftwareAssuranceLevel::levelC; rationale = "survey products only"; }
        }
        part time : FlightSoftwareClassification {
            doc /* The time service. */
            ref part :>> component = argentSoftware.cdh.software.time;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "time-tags every sequence and the inhibit hold timer of TS-807";
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "time tags and hold timers"; }
        }
        part events : FlightSoftwareClassification {
            doc /* The event service. */
            ref part :>> component = argentSoftware.cdh.software.events;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "carries the fault events the supervisor acts on";
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "fault event transport"; }
        }
        part tables : FlightSoftwareClassification {
            doc /* The table service. */
            ref part :>> component = argentSoftware.cdh.software.tables;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "holds the monitor limits and the two-step window";
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "limit and parameter tables"; }
        }
        part dataStore : FlightSoftwareClassification {
            doc /* The data store service. */
            ref part :>> component = argentSoftware.cdh.software.dataStore;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "recorder for telemetry and images; loss is recoverable by replay";
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "recorder, replayable"; }
        }
        part commandIngest : FlightSoftwareClassification {
            doc /* The command ingest service. */
            ref part :>> component = argentSoftware.cdh.software.commandIngest;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "checks the confirmation key of every hazardous command before dispatch";
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "confirmation-key check"; }
        }
        part telemetryOutput : FlightSoftwareClassification {
            doc /* The telemetry output service. */
            ref part :>> component = argentSoftware.cdh.software.telemetryOutput;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "the ground's view of the inhibit states and the fault log";
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "inhibit-state telemetry"; }
        }
        part housekeeping : FlightSoftwareClassification {
            doc /* The housekeeping service. */
            ref part :>> component = argentSoftware.cdh.software.housekeeping;
            attribute :>> level = SoftwareAssuranceLevel::levelC;
            attribute :>> rationale = "periodic health packets; loss is a degraded trend";
            @Assurance { level = SoftwareAssuranceLevel::levelC; rationale = "health packets"; }
        }
        part scheduler : FlightSoftwareClassification {
            doc /* The scheduler service. */
            ref part :>> component = argentSoftware.cdh.software.scheduler;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "rate groups of the applications within the executive's partitions";
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "rate groups"; }
        }
        part bootUpdate : FlightSoftwareClassification {
            doc /* The boot and update service. */
            ref part :>> component = argentSoftware.cdh.software.bootUpdate;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "image checks and the fallback to the safe image";
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "safe-image fallback"; }
        }

        part commandBuilder : GroundSoftwareClassification {
            doc /* Meridian Forge: builds and validates commands, holds hazardous ones for a second approval. */
            ref part :>> component = meridianOperationsSuite.moc.commandBuilder;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "the two-step rule for hazardous commands and the ground enable of the cinch; a human approves each step (TH-001, TH-003)";
            ref :>> controls = (hazardLog.earthImpactByTarget, hazardLog.overEnvelopeTarget);
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "two-step hazardous commands, human in the loop"; }
        }
        part sequencer : GroundSoftwareClassification {
            doc /* Meridian Warden: clears sequences against the flight rules. */
            ref part :>> component = meridianOperationsSuite.moc.sequencer;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "refuses uncleared thrust arcs (FR-001) and keep-out violations (FR-002); the on-board interlock backs it";
            ref :>> controls = (hazardLog.earthImpactByTarget, hazardLog.tugTargetCollision);
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "flight-rule clearance, backed on board"; }
        }
        part telemetryServer : GroundSoftwareClassification {
            doc /* Meridian Lantern: decommutation, limits, alarms. */
            ref part :>> component = meridianOperationsSuite.moc.telemetryServer;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            attribute :>> rationale = "the operators' view of inhibit states and alarms";
            @Assurance { level = SoftwareAssuranceLevel::levelB; rationale = "alarms and inhibit-state display"; }
        }
        part flightDynamicsTool : GroundSoftwareClassification {
            doc /* Meridian Sextant: orbit determination and manoeuvre design. */
            ref part :>> component = meridianOperationsSuite.fdf.flightDynamicsTool;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            attribute :>> rationale = "confirms the post-manoeuvre trajectory misses Earth before the final targeting enable (TS-802, TH-001)";
            ref :>> controls = (hazardLog.earthImpactByTarget,);
            @Assurance { level = SoftwareAssuranceLevel::levelA; rationale = "Earth-miss confirmation behind the ground authority (TH-001)"; }
        }
        part passPlanner : GroundSoftwareClassification {
            doc /* Meridian Almanac: pass planning. */
            ref part :>> component = meridianOperationsSuite.moc.passPlanner;
            attribute :>> level = SoftwareAssuranceLevel::levelC;
            attribute :>> rationale = "a bad plan loses a pass, caught by the next";
            @Assurance { level = SoftwareAssuranceLevel::levelC; rationale = "pass planning"; }
        }
        part dataArchive : GroundSoftwareClassification {
            doc /* Meridian Vault: the archive. */
            ref part :>> component = meridianOperationsSuite.sds.dataArchive;
            attribute :>> level = SoftwareAssuranceLevel::levelD;
            attribute :>> rationale = "archive and distribution; no operational decision depends on it in real time";
            @Assurance { level = SoftwareAssuranceLevel::levelD; rationale = "archive"; }
        }
        part anomalyTracker : GroundSoftwareClassification {
            doc /* Meridian Ledger: anomaly reports. */
            ref part :>> component = meridianOperationsSuite.moc.anomalyTracker;
            attribute :>> level = SoftwareAssuranceLevel::levelD;
            attribute :>> rationale = "record keeping for the anomaly board";
            @Assurance { level = SoftwareAssuranceLevel::levelD; rationale = "record keeping"; }
        }
        part proximityPlanner : GroundSoftwareClassification {
            doc /* Meridian Compass: proximity-operations planning and the go/no-go checklist. */
            ref part :>> component = meridianOperationsSuite.moc.proximityPlanner;
            attribute :>> level = SoftwareAssuranceLevel::levelC;
            attribute :>> rationale = "plans within the keep-out; the checklist is reviewed by the flight director before the capture go";
            ref :>> controls = (hazardLog.tugTargetCollision,);
            @Assurance { level = SoftwareAssuranceLevel::levelC; rationale = "keep-out planning, reviewed"; }
        }
        part flatsatSimulator : GroundSoftwareClassification {
            doc /* Meridian Anvil, the hardware-in-the-loop test bed. */
            ref part :>> component = meridianOperationsSuite.testBeds.flatsat;
            attribute :>> level = SoftwareAssuranceLevel::levelC;
            attribute :>> rationale = "test equipment: a wrong result is caught by the independent model-in-the-loop comparison";
            @Assurance { level = SoftwareAssuranceLevel::levelC; rationale = "test equipment"; }
        }
        part captureRigSimulator : GroundSoftwareClassification {
            doc /* Meridian Capstan, the capture rig controller. */
            ref part :>> component = meridianOperationsSuite.testBeds.captureRig;
            attribute :>> level = SoftwareAssuranceLevel::levelC;
            attribute :>> rationale = "test equipment driving a rotating mock body on the ground";
            @Assurance { level = SoftwareAssuranceLevel::levelC; rationale = "test equipment"; }
        }
        part dynamicsSimulatorSoftware : GroundSoftwareClassification {
            doc /* Meridian Orrery, the dynamics simulator. */
            ref part :>> component = meridianOperationsSuite.testBeds.dynamicsSimulator;
            attribute :>> level = SoftwareAssuranceLevel::levelC;
            attribute :>> rationale = "test equipment";
            @Assurance { level = SoftwareAssuranceLevel::levelC; rationale = "test equipment"; }
        }
        part flightSoftwareSimulator : GroundSoftwareClassification {
            doc /* Meridian Mirror, the flight-software-in-the-loop simulator. */
            ref part :>> component = meridianOperationsSuite.testBeds.trajectoryTool;
            attribute :>> level = SoftwareAssuranceLevel::levelC;
            attribute :>> rationale = "test equipment; sequence validation before uplink is backed by the flight-rule checker";
            @Assurance { level = SoftwareAssuranceLevel::levelC; rationale = "test equipment"; }
        }

        part flightRows : FlightSoftwareClassification [*] = (captureControl, fdir, modeManagement, gnc, autonomy, sepControl, executive, boardSupport,
            cdh, powerManagement, telecom, parameterBootUpdate, thermalControl, inspectorHandling,
            time, events, tables, dataStore, commandIngest, telemetryOutput, housekeeping, scheduler, bootUpdate);
        part groundRows : GroundSoftwareClassification [*] = (commandBuilder, sequencer, telemetryServer, flightDynamicsTool, passPlanner,
            dataArchive, anomalyTracker, proximityPlanner, flatsatSimulator, captureRigSimulator, dynamicsSimulatorSoftware, flightSoftwareSimulator);
        attribute flightRowCount : Natural = size(flightRows);
        attribute groundRowCount : Natural = size(groundRows);
        attribute flightComponentCount : Natural = size(argentSoftware.cdh.software.components);
        attribute groundComponentCount : Natural = meridianOperationsSuite.componentCount;
        attribute levelACount : Natural = size(flightRows->select { in r : FlightSoftwareClassification; r.level == SoftwareAssuranceLevel::levelA })
            + size(groundRows->select { in r : GroundSoftwareClassification; r.level == SoftwareAssuranceLevel::levelA });
        assert constraint everyFlightComponentClassified {
            doc /* One row per flight software component: the twenty-three components of the
                 * Argent flight software. */
            flightRowCount == flightComponentCount
        }
        assert constraint everyGroundComponentClassified {
            doc /* One row per Meridian component: the suite's twelve components. */
            groundRowCount == groundComponentCount
        }
        assert constraint flightRowsAreDistinct {
            doc /* No component is classified twice. */
            size(flightRows.component) == flightRowCount
        }
    }

    // ---------------------------------------------------------------- software hazard analysis (SW-043)

    occurrence def SoftwareHazardCause {
        doc /* A software cause or contribution to a hazard of the hazard log: the component whose
             * failure or erroneous output is the cause, the failure mode in words, and the hazard
             * cause of TethysSafety it feeds. Cause-and-effect occurrences in the hazard's own
             * vocabulary, so a software cause is a leaf of the same fault tree as a hardware one. */
        ref part component : SoftwareComponent [0..1];
        ref part groundComponent : GroundSoftwareComponent [0..1];
        attribute failureMode : String;
        attribute severity : Severity;
    }

    occurrence def SoftwareControl {
        doc /* A software control holding a hazard: an inhibit, a two-step command or an FDIR
             * response, the component that implements it, and the hazard control of TethysSafety
             * it is part of. Independence: the control fails independently of the causes it holds. */
        attribute kind : SoftwareControlKind;
        ref part component : SoftwareComponent [0..1];
        ref part groundComponent : GroundSoftwareComponent [0..1];
        attribute status : ControlStatus;
        attribute evidence : String;
        ref occurrence partOf : HazardControl [0..1];
    }

    occurrence softwareHazardAnalysis {
        doc /* The software hazard analysis: per hazard of the hazard log, the software causes and
             * contributions and the software controls, each a cause-and-effect occurrence linked to
             * the hazard's own cause and effect events. */

        occurrence earthImpactByTarget {
            doc /* TH-001: software causes on the final targeting arc and the controls that hold them. */
            ref occurrence hazard : Hazard ::> hazardLog.earthImpactByTarget;
            #cause occurrence erroneousTargetingSolution : SoftwareHazardCause {
                doc /* The guidance application computes a targeting burn inside the corridor. */
                ref part :>> component = argentSoftware.cdh.software.gnc;
                attribute :>> failureMode = "wrong burn vector from a stale ephemeris or a sign error in the lunar-frame transform";
                attribute :>> severity = Severity::catastrophic;
            }
            #cause occurrence uncommandedThrustArc : SoftwareHazardCause {
                doc /* The sequence engine starts a thrust arc the ground has not cleared. */
                ref part :>> component = argentSoftware.cdh.software.autonomy;
                attribute :>> failureMode = "a time-tagged thrust arc dispatched without the clearance flag";
                attribute :>> severity = Severity::catastrophic;
            }
            #cause occurrence abortMonitorSilent : SoftwareHazardCause {
                doc /* The FDIR supervisor fails to raise the abort when the exclusion monitor trips. */
                ref part :>> component = argentSoftware.cdh.software.fdir;
                attribute :>> failureMode = "exclusion monitor masked or its limit table corrupted";
                attribute :>> severity = Severity::catastrophic;
            }
            #causation connection feedsErroneousTargeting connect erroneousTargetingSolution to hazardLog.earthImpactByTarget.erroneousFinalTargeting {
                doc /* The software cause is one of the hazard's erroneous-final-targeting causes. */
                @CausationMetadata { isNecessary = false; isSufficient = true; }
            }
            #causation connection feedsCorridor connect uncommandedThrustArc to hazardLog.earthImpactByTarget.returnTrajectoryInsideCorridor {
                doc /* An uncleared arc can put the return inside the corridor. */
                @CausationMetadata { isNecessary = false; isSufficient = false; }
            }
            occurrence groundAuthorityTwoStep : SoftwareControl {
                doc /* The targeting enable is a two-step hazardous command built on the ground and
                     * key-confirmed on board. */
                attribute :>> kind = SoftwareControlKind::twoStepCommand;
                ref part :>> groundComponent = meridianOperationsSuite.moc.commandBuilder;
                attribute :>> status = ControlStatus::baselined;
                attribute :>> evidence = "command-builder planted cases; confirmation key check";
                ref :>> partOf = hazardLog.earthImpactByTarget.controls.groundAuthority;
            }
            occurrence exclusionAbort : SoftwareControl {
                doc /* The Earth-impact exclusion monitor aborts the return into abort hold. */
                attribute :>> kind = SoftwareControlKind::fdirResponse;
                ref part :>> component = argentSoftware.cdh.software.fdir;
                attribute :>> status = ControlStatus::baselined;
                attribute :>> evidence = "fdir-earth-impact-aborted pinned run";
                ref :>> partOf = hazardLog.earthImpactByTarget.controls.trajectoryBias;
            }
            occurrence thrustArcInterlock : SoftwareControl {
                doc /* The sequence engine refuses a thrust arc without the clearance flag. */
                attribute :>> kind = SoftwareControlKind::inhibit;
                ref part :>> component = argentSoftware.cdh.software.autonomy;
                attribute :>> status = ControlStatus::proposed;
                attribute :>> evidence = "planned: sequence-engine unit test";
            }
        }

        occurrence tugTargetCollision {
            doc /* TH-002: software causes in proximity operations. */
            ref occurrence hazard : Hazard ::> hazardLog.tugTargetCollision;
            #cause occurrence relativeStateDivergence : SoftwareHazardCause {
                doc /* The relative-state filter diverges without flagging it. */
                ref part :>> component = argentSoftware.cdh.software.gnc;
                attribute :>> failureMode = "filter divergence with a healthy covariance report";
                attribute :>> severity = Severity::critical;
            }
            #cause occurrence abortNotIssued : SoftwareHazardCause {
                doc /* The autonomous abort is not issued at the keep-out breach. */
                ref part :>> component = argentSoftware.cdh.software.autonomy;
                attribute :>> failureMode = "abort rule disabled by a parameter load";
                attribute :>> severity = Severity::critical;
            }
            #causation connection feedsNavigationLoss connect relativeStateDivergence to hazardLog.tugTargetCollision.relativeNavigationLoss {
                doc /* Divergence is a relative-navigation loss. */
                @CausationMetadata { isNecessary = false; isSufficient = true; }
            }
            occurrence autonomousAbort : SoftwareControl {
                doc /* The autonomy application's abort to the 500 m hold point. */
                attribute :>> kind = SoftwareControlKind::fdirResponse;
                ref part :>> component = argentSoftware.cdh.software.autonomy;
                attribute :>> status = ControlStatus::baselined;
                attribute :>> evidence = "closed-loop capture test on the dynamics simulator";
                ref :>> partOf = hazardLog.tugTargetCollision.controls.autonomousAbort;
            }
            occurrence keepOutClearance : SoftwareControl {
                doc /* The ground flight-rule checker refuses sequences inside the keep-out. */
                attribute :>> kind = SoftwareControlKind::twoStepCommand;
                ref part :>> groundComponent = meridianOperationsSuite.moc.sequencer;
                attribute :>> status = ControlStatus::baselined;
                attribute :>> evidence = "sw-ground-sequencer-check pinned run";
            }
        }

        occurrence overEnvelopeTarget {
            doc /* TH-003: the cinch fired on a body the bag cannot hold. */
            ref occurrence hazard : Hazard ::> hazardLog.overEnvelopeTarget;
            #cause occurrence cinchFiredInhibited : SoftwareHazardCause {
                doc /* The capture controller fires the cinch with an inhibit still in place. */
                ref part :>> component = argentSoftware.cdh.software.captureControl;
                attribute :>> failureMode = "inhibit gate bypassed or an inhibit attribute stuck true";
                attribute :>> severity = Severity::critical;
            }
            #cause occurrence driverSpuriousFire : SoftwareHazardCause {
                doc /* The actuator driver commands the cinch motor without a fire command. */
                ref part :>> component = argentSoftware.cdh.software.boardSupport;
                attribute :>> failureMode = "register write to the cinch channel from an unrelated driver";
                attribute :>> severity = Severity::critical;
            }
            #effect event occurrence cinchFiredOnOverEnvelopeBody;
            #multicausation connection prematureCinchGate {
                doc /* Either software cause fires the cinch before the envelope check. */
                end #cause :> causes ::> cinchFiredInhibited;
                end #cause :> causes ::> driverSpuriousFire;
                end #effect :> effects ::> cinchFiredOnOverEnvelopeBody;
                @CausationMetadata { isNecessary = false; isSufficient = true; }
            }
            occurrence armInhibit : SoftwareControl {
                doc /* The arm command, first inhibit of the cinch chain. */
                attribute :>> kind = SoftwareControlKind::inhibit;
                ref part :>> component = argentSoftware.cdh.software.captureControl;
                attribute :>> status = ControlStatus::verified;
                attribute :>> evidence = "sw-capture-controller-check pinned run";
                ref :>> partOf = hazardLog.overEnvelopeTarget.controls.envelopeMargin;
            }
            occurrence groundEnableInhibit : SoftwareControl {
                doc /* The ground enable, second inhibit, built as a two-step hazardous command. */
                attribute :>> kind = SoftwareControlKind::twoStepCommand;
                ref part :>> groundComponent = meridianOperationsSuite.moc.commandBuilder;
                attribute :>> status = ControlStatus::verified;
                attribute :>> evidence = "sw-capture-controller-inhibited pinned run";
                ref :>> partOf = hazardLog.overEnvelopeTarget.controls.envelopeMargin;
            }
            occurrence captureModeInhibit : SoftwareControl {
                doc /* The vehicle in capture mode, third inhibit, owned by the mode manager. */
                attribute :>> kind = SoftwareControlKind::inhibit;
                ref part :>> component = argentSoftware.cdh.software.modeManagement;
                attribute :>> status = ControlStatus::verified;
                attribute :>> evidence = "fdir-inhibit-chain-check pinned run";
                ref :>> partOf = hazardLog.overEnvelopeTarget.controls.envelopeMargin;
            }
        }

        occurrence uncontrolledTumble {
            doc /* TH-004: the despin fails or exhausts the propellant. */
            ref occurrence hazard : Hazard ::> hazardLog.uncontrolledTumble;
            #cause occurrence despinOverrun : SoftwareHazardCause {
                doc /* The despin controller keeps firing past the duration budget. */
                ref part :>> component = argentSoftware.cdh.software.captureControl;
                attribute :>> failureMode = "despin duration timer not armed";
                attribute :>> severity = Severity::critical;
            }
            #causation connection feedsPropellantExhaustion connect despinOverrun to hazardLog.uncontrolledTumble.despinPropellantExhausted {
                doc /* An overrun exhausts the reserve. */
                @CausationMetadata { isNecessary = false; isSufficient = true; }
            }
            occurrence despinTimer : SoftwareControl {
                doc /* The despin stops at its duration and the controller reports captured. */
                attribute :>> kind = SoftwareControlKind::fdirResponse;
                ref part :>> component = argentSoftware.cdh.software.captureControl;
                attribute :>> status = ControlStatus::verified;
                attribute :>> evidence = "sw-capture-controller pinned run";
                ref :>> partOf = hazardLog.uncontrolledTumble.controls.propellantReserve;
            }
        }

        occurrence derelictTug {
            doc /* TH-005: the disposal burn is missed. */
            ref occurrence hazard : Hazard ::> hazardLog.derelictTug;
            #cause occurrence safeModeWithoutRecovery : SoftwareHazardCause {
                doc /* A safe-mode entry during the disposal window with no ground recovery in time. */
                ref part :>> component = argentSoftware.cdh.software.modeManagement;
                attribute :>> failureMode = "safe-mode entry on a spurious fault during the disposal window";
                attribute :>> severity = Severity::major;
            }
            #causation connection feedsDisposalMiss connect safeModeWithoutRecovery to hazardLog.derelictTug.disposalBurnMissed {
                doc /* Safe mode holds thrust until the ground recovers the tug. */
                @CausationMetadata { isNecessary = false; isSufficient = false; }
            }
            occurrence commandLossRecovery : SoftwareControl {
                doc /* The command-loss recovery returns the tug to coast within the window. */
                attribute :>> kind = SoftwareControlKind::fdirResponse;
                ref part :>> component = argentSoftware.cdh.software.fdir;
                attribute :>> status = ControlStatus::baselined;
                attribute :>> evidence = "fdir-command-loss-recovered pinned run";
                ref :>> partOf = hazardLog.derelictTug.controls.disposalBurn;
            }
        }

        occurrence prematureHighVoltage {
            doc /* TH-006: PPU high voltage before separation plus 600 s. */
            ref occurrence hazard : Hazard ::> hazardLog.prematureHighVoltage;
            #cause occurrence ppuOnBeforeHold : SoftwareHazardCause {
                doc /* The SEP application commands a PPU on before the hold timer expires. */
                ref part :>> component = argentSoftware.cdh.software.sepControl;
                attribute :>> failureMode = "hold timer read from an unset time service";
                attribute :>> severity = Severity::critical;
            }
            #causation connection feedsInhibitFailure connect ppuOnBeforeHold to hazardLog.prematureHighVoltage.inhibitFailure {
                doc /* The software inhibit is one of the two inhibits. */
                @CausationMetadata { isNecessary = false; isSufficient = false; }
            }
            occurrence highVoltageSoftwareInhibit : SoftwareControl {
                doc /* The SEP application refuses PPU on until the separation hold has elapsed. */
                attribute :>> kind = SoftwareControlKind::inhibit;
                ref part :>> component = argentSoftware.cdh.software.sepControl;
                attribute :>> status = ControlStatus::baselined;
                attribute :>> evidence = "planned: flatsat inhibit test";
                ref :>> partOf = hazardLog.prematureHighVoltage.controls.twoInhibits;
            }
            occurrence ppuOnTwoStep : SoftwareControl {
                doc /* Each PPU-on command is hazardous: two-step on the ground, key-confirmed on board. */
                attribute :>> kind = SoftwareControlKind::twoStepCommand;
                ref part :>> component = argentSoftware.cdh.software.commandIngest;
                attribute :>> status = ControlStatus::baselined;
                attribute :>> evidence = "dictionary hazard flags; command-builder planted cases";
                ref :>> partOf = hazardLog.prematureHighVoltage.controls.twoInhibits;
            }
        }

        occurrence ejectaContamination {
            doc /* TH-007: plume impingement inside 50 m before the bag closes. */
            ref occurrence hazard : Hazard ::> hazardLog.ejectaContamination;
            #cause occurrence thrusterSelectionError : SoftwareHazardCause {
                doc /* The GNC thruster selection fires a target-facing thruster inside the keep-out. */
                ref part :>> component = argentSoftware.cdh.software.gnc;
                attribute :>> failureMode = "plume keep-out mask not applied in the final approach mode";
                attribute :>> severity = Severity::major;
            }
            #causation connection feedsPlumeImpingement connect thrusterSelectionError to hazardLog.ejectaContamination.plumeImpingement {
                doc /* A masked thruster firing is an impingement. */
                @CausationMetadata { isNecessary = false; isSufficient = true; }
            }
            occurrence plumeMask : SoftwareControl {
                doc /* The thruster selection excludes target-facing thrusters inside 50 m. */
                attribute :>> kind = SoftwareControlKind::inhibit;
                ref part :>> component = argentSoftware.cdh.software.gnc;
                attribute :>> status = ControlStatus::proposed;
                attribute :>> evidence = "planned: dynamics-simulator run";
                ref :>> partOf = hazardLog.ejectaContamination.controls.keepOut;
            }
        }

        attribute hazardCount : Natural = 7;
        attribute softwareCauseCount : Natural = 11;
        attribute softwareControlCount : Natural = 14;
    }

    // ---------------------------------------------------------------- software FMECA (SW-043)

    occurrence def SoftwareFailureMode {
        doc /* One row of the software FMECA: the component, its failure mode, the local and end
             * effect, how it is detected, the response that contains it, and the criticality as
             * the worst credible end effect with the response in place. Mirrors TethysSafety::
             * FailureMode's columns for software, where the exposure is per flight hour of the
             * phase named and no mean time to failure is claimed. */
        ref part component : SoftwareComponent;
        attribute failureMode : String;
        attribute localEffect : String;
        attribute endEffect : String;
        attribute detection : DetectionMeans;
        attribute response : FaultResponse;
        attribute criticality : Severity;
        attribute level : SoftwareAssuranceLevel;
        ref occurrence hazards : Hazard [0..*];
    }

    occurrence softwareFmeca {
        doc /* The software FMECA: one row per application and one for the executive, thirteen rows,
             * each with the hazards of the hazard log its end effect feeds. */

        occurrence <'SFM-01'> executiveSchedulerStall : SoftwareFailureMode {
            doc /* The executive misses a major frame. */
            ref part :>> component = argentSoftware.cdh.software.executive;
            attribute :>> failureMode = "partition scheduler stall: a major frame is not released";
            attribute :>> localEffect = "every application misses its rate group";
            attribute :>> endEffect = "watchdog resets the computer; redundant computer takes over";
            attribute :>> detection = DetectionMeans::builtInTest;
            attribute :>> response = FaultResponse::switchover;
            attribute :>> criticality = Severity::major;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            ref :>> hazards = (hazardLog.earthImpactByTarget, hazardLog.tugTargetCollision);
        }
        occurrence <'SFM-02'> cdhRoutingLoss : SoftwareFailureMode {
            doc /* Command and telemetry routing stops. */
            ref part :>> component = argentSoftware.cdh.software.cdh;
            attribute :>> failureMode = "message bus queue overflow drops commands";
            attribute :>> localEffect = "commands not delivered to their application";
            attribute :>> endEffect = "loss of commandability until the command-loss timer safes the tug";
            attribute :>> detection = DetectionMeans::telemetryLimit;
            attribute :>> response = FaultResponse::safeMode;
            attribute :>> criticality = Severity::major;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
        }
        occurrence <'SFM-03'> gncTargetingError : SoftwareFailureMode {
            doc /* The final targeting burn is computed wrongly. */
            ref part :>> component = argentSoftware.cdh.software.gnc;
            attribute :>> failureMode = "targeting solution from a stale ephemeris";
            attribute :>> localEffect = "burn vector inside the Earth corridor";
            attribute :>> endEffect = "Earth-impact trajectory unless the exclusion monitor aborts";
            attribute :>> detection = DetectionMeans::navigationResidual;
            attribute :>> response = FaultResponse::abortReturn;
            attribute :>> criticality = Severity::catastrophic;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            ref :>> hazards = (hazardLog.earthImpactByTarget,);
        }
        occurrence <'SFM-04'> sepUncommandedThrust : SoftwareFailureMode {
            doc /* A thrust arc runs outside its clearance. */
            ref part :>> component = argentSoftware.cdh.software.sepControl;
            attribute :>> failureMode = "thrust arc not terminated at its end time";
            attribute :>> localEffect = "thrust continues past the planned arc";
            attribute :>> endEffect = "trajectory error; on the final arc an Earth-corridor entry";
            attribute :>> detection = DetectionMeans::telemetryLimit;
            attribute :>> response = FaultResponse::safeMode;
            attribute :>> criticality = Severity::catastrophic;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            ref :>> hazards = (hazardLog.earthImpactByTarget,);
        }
        occurrence <'SFM-05'> powerLoadShedMissed : SoftwareFailureMode {
            doc /* Load shedding does not trip at the battery floor. */
            ref part :>> component = argentSoftware.cdh.software.powerManagement;
            attribute :>> failureMode = "battery floor comparison against a stale measurement";
            attribute :>> localEffect = "loads stay on below the floor";
            attribute :>> endEffect = "battery depth of discharge exceeded; FDIR safes the tug";
            attribute :>> detection = DetectionMeans::telemetryLimit;
            attribute :>> response = FaultResponse::loadShed;
            attribute :>> criticality = Severity::major;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
        }
        occurrence <'SFM-06'> thermalSetpointError : SoftwareFailureMode {
            doc /* A heater zone runs at a wrong setpoint. */
            ref part :>> component = argentSoftware.cdh.software.thermalControl;
            attribute :>> failureMode = "setpoint table index off by one";
            attribute :>> localEffect = "one zone too cold or too warm";
            attribute :>> endEffect = "component out of its allowable range; trended by the ground";
            attribute :>> detection = DetectionMeans::groundTrending;
            attribute :>> response = FaultResponse::retry;
            attribute :>> criticality = Severity::minor;
            attribute :>> level = SoftwareAssuranceLevel::levelC;
        }
        occurrence <'SFM-07'> telecomTransmitterStuck : SoftwareFailureMode {
            doc /* The transmitter stays on through a thrust arc. */
            ref part :>> component = argentSoftware.cdh.software.telecom;
            attribute :>> failureMode = "transmitter-off command lost at the arc start";
            attribute :>> localEffect = "transmitter on while thrusting";
            attribute :>> endEffect = "flight rule FR-001 violated; power margin consumed";
            attribute :>> detection = DetectionMeans::telemetryLimit;
            attribute :>> response = FaultResponse::retry;
            attribute :>> criticality = Severity::minor;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
        }
        occurrence <'SFM-08'> inspectorRelayLoss : SoftwareFailureMode {
            doc /* The inspector relay drops frames. */
            ref part :>> component = argentSoftware.cdh.software.inspectorHandling;
            attribute :>> failureMode = "relay buffer overrun";
            attribute :>> localEffect = "survey frames lost";
            attribute :>> endEffect = "characterisation products delayed";
            attribute :>> detection = DetectionMeans::groundTrending;
            attribute :>> response = FaultResponse::retry;
            attribute :>> criticality = Severity::negligible;
            attribute :>> level = SoftwareAssuranceLevel::levelC;
        }
        occurrence <'SFM-09'> captureCinchWithInhibit : SoftwareFailureMode {
            doc /* The cinch fires with an inhibit in place. */
            ref part :>> component = argentSoftware.cdh.software.captureControl;
            attribute :>> failureMode = "inhibit gate bypassed";
            attribute :>> localEffect = "cinch motor runs before the envelope check";
            attribute :>> endEffect = "bag torn on an over-envelope body";
            attribute :>> detection = DetectionMeans::builtInTest;
            attribute :>> response = FaultResponse::abortReturn;
            attribute :>> criticality = Severity::critical;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            ref :>> hazards = (hazardLog.overEnvelopeTarget,);
        }
        occurrence <'SFM-10'> autonomyAbortMissed : SoftwareFailureMode {
            doc /* The autonomous abort is not issued. */
            ref part :>> component = argentSoftware.cdh.software.autonomy;
            attribute :>> failureMode = "abort rule disabled by a parameter load";
            attribute :>> localEffect = "keep-out breach continues";
            attribute :>> endEffect = "collision with the target";
            attribute :>> detection = DetectionMeans::navigationResidual;
            attribute :>> response = FaultResponse::abortReturn;
            attribute :>> criticality = Severity::critical;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            ref :>> hazards = (hazardLog.tugTargetCollision,);
        }
        occurrence <'SFM-11'> fdirMonitorMasked : SoftwareFailureMode {
            doc /* A monitor is masked when it should be armed. */
            ref part :>> component = argentSoftware.cdh.software.fdir;
            attribute :>> failureMode = "monitor mask left set after a test";
            attribute :>> localEffect = "fault not detected";
            attribute :>> endEffect = "no abort on an Earth-corridor entry";
            attribute :>> detection = DetectionMeans::groundTrending;
            attribute :>> response = FaultResponse::safeMode;
            attribute :>> criticality = Severity::catastrophic;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            ref :>> hazards = (hazardLog.earthImpactByTarget,);
        }
        occurrence <'SFM-12'> modeManagerWrongMode : SoftwareFailureMode {
            doc /* The mode manager reports capture mode outside it. */
            ref part :>> component = argentSoftware.cdh.software.modeManagement;
            attribute :>> failureMode = "mode flag not cleared on exit";
            attribute :>> localEffect = "the capture-mode inhibit is removed";
            attribute :>> endEffect = "one of three cinch inhibits lost";
            attribute :>> detection = DetectionMeans::telemetryLimit;
            attribute :>> response = FaultResponse::safeMode;
            attribute :>> criticality = Severity::critical;
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            ref :>> hazards = (hazardLog.overEnvelopeTarget,);
        }
        occurrence <'SFM-13'> bootImageCorrupt : SoftwareFailureMode {
            doc /* A loaded image fails its check. */
            ref part :>> component = argentSoftware.cdh.software.parameterBootUpdate;
            attribute :>> failureMode = "image checksum mismatch after upload";
            attribute :>> localEffect = "boot falls back to the safe image";
            attribute :>> endEffect = "mission software reverted until reload";
            attribute :>> detection = DetectionMeans::builtInTest;
            attribute :>> response = FaultResponse::retry;
            attribute :>> criticality = Severity::minor;
            attribute :>> level = SoftwareAssuranceLevel::levelB;
        }

        occurrence rows : SoftwareFailureMode [*] = (executiveSchedulerStall, cdhRoutingLoss, gncTargetingError, sepUncommandedThrust,
            powerLoadShedMissed, thermalSetpointError, telecomTransmitterStuck, inspectorRelayLoss, captureCinchWithInhibit,
            autonomyAbortMissed, fdirMonitorMasked, modeManagerWrongMode, bootImageCorrupt);
        attribute rowCount : Natural = size(rows);
        attribute catastrophicRowCount : Natural = size(rows->select { in r : SoftwareFailureMode; r.criticality == Severity::catastrophic });
        assert constraint catastrophicRowsAreLevelA {
            doc /* Every catastrophic or critical failure mode belongs to a level-A component. */
            rows->forAll { in r : SoftwareFailureMode;
                (r.criticality == Severity::catastrophic or r.criticality == Severity::critical) implies r.level == SoftwareAssuranceLevel::levelA }
        }
    }

    // ---------------------------------------------------------------- fault tree with software basic events (SW-043)

    occurrence prematureCinchTree {
        doc /* Fault tree for the premature cinch (TH-003): the cinch fires on an over-envelope body
             * only if all three inhibits are removed or bypassed. Each inhibit fails by a software
             * basic event (the controller fires with the inhibit still set, the mode manager
             * reports capture mode wrongly, the ground enable is sent without its second approval)
             * or by the actuator driver firing spuriously, which bypasses all three. The top event
             * probability per capture is the driver event plus the product of the three inhibit
             * failures, in TethysSafety's AndGate/OrGate style. */
        #cause occurrence controllerFiresInhibited : BasicEvent {
            doc /* Software: the capture controller fires with an inhibit still set. */
            attribute :>> probability = 1.0e-4;
        }
        #cause occurrence modeFlagStuck : BasicEvent {
            doc /* Software: the mode manager leaves the capture-mode flag set. */
            attribute :>> probability = 1.0e-3;
        }
        #cause occurrence groundEnableWithoutApproval : BasicEvent {
            doc /* Software and procedure: the ground enable is uplinked without its second approval. */
            attribute :>> probability = 1.0e-3;
        }
        #cause occurrence driverSpuriousFire : BasicEvent {
            doc /* Software: the actuator driver writes the cinch channel spuriously. */
            attribute :>> probability = 1.0e-6;
        }
        #effect event occurrence allInhibitsLost;
        #effect event occurrence cinchFiresPrematurely;

        #multicausation connection inhibitsLostGate {
            doc /* All three inhibits must fail: an AND gate. */
            end #cause :> causes ::> controllerFiresInhibited;
            end #cause :> causes ::> modeFlagStuck;
            end #cause :> causes ::> groundEnableWithoutApproval;
            end #effect :> effects ::> allInhibitsLost;
            @CausationMetadata { isNecessary = true; isSufficient = false; }
        }
        #multicausation connection topGate {
            doc /* The driver bypass or the loss of all inhibits fires the cinch: an OR gate. */
            end #cause :> causes ::> allInhibitsLost;
            end #cause :> causes ::> driverSpuriousFire;
            end #effect :> effects ::> cinchFiresPrematurely;
            @CausationMetadata { isNecessary = false; isSufficient = true; }
        }
        attribute allInhibitsLostProbability : Real = AndGate(a = AndGate(a = controllerFiresInhibited.probability, b = modeFlagStuck.probability), b = groundEnableWithoutApproval.probability);
        attribute topEventProbability : Real = OrGate(a = allInhibitsLostProbability, b = driverSpuriousFire.probability);
        attribute perCaptureBudget : Real = 1.0e-5;
        assert constraint withinBudget {
            doc /* The premature-cinch probability per capture is within its budget. */
            topEventProbability <= perCaptureBudget
        }
    }

    // ---------------------------------------------------------------- inhibit independence (SW-043)

    constraint def InhibitIndependence {
        doc /* Independence of a hazardous function's inhibits: at least the required number of
             * inhibits, each owned by a different software component, and no two in the same
             * executive partition, so no single partition failure removes two inhibits. */
        in requiredInhibits : Natural;
        in owners : String [*] nonunique;
        in partitions : String [*] nonunique;
        in inhibitCount : Natural;
        inhibitCount >= requiredInhibits
            and size(owners) == inhibitCount
            and owners->forAll { in o : String; size(owners->select { in p : String; p == o }) == 1 }
            and partitions->forAll { in q : String; size(partitions->select { in p : String; p == q }) == 1 }
    }

    part inhibitIndependence {
        doc /* The inhibit-independence argument for the two hazardous functions, as checkable
             * constraints over the inhibit owners and their partitions of TethysAllocations. The
             * cinch has three inhibits (the arm in the capture controller on the autonomy
             * partition, the capture mode in the mode manager on the platform partition, the
             * ground enable on the ground); the SEP high voltage has two (the hold timer in the
             * SEP application on the subsystem partition and the ground two-step command). */
        attribute cinchInhibitOwners : String [*] nonunique = ("captureControl", "modeManagement", "commandBuilder");
        attribute cinchInhibitPartitions : String [*] nonunique = ("autonomyPartition", "platformPartition", "ground");
        attribute thrusterInhibitOwners : String [*] nonunique = ("sepControl", "commandBuilder");
        attribute thrusterInhibitPartitions : String [*] nonunique = ("subsystemPartition", "ground");
        assert constraint cinchInhibitsIndependent : InhibitIndependence {
            doc /* Three independent cinch inhibits. */
            in requiredInhibits = 3;
            in owners = inhibitIndependence.cinchInhibitOwners;
            in partitions = inhibitIndependence.cinchInhibitPartitions;
            in inhibitCount = size(inhibitIndependence.cinchInhibitOwners);
        }
        assert constraint thrusterInhibitsIndependent : InhibitIndependence {
            doc /* Two independent high-voltage inhibits (TS-807). */
            in requiredInhibits = 2;
            in owners = inhibitIndependence.thrusterInhibitOwners;
            in partitions = inhibitIndependence.thrusterInhibitPartitions;
            in inhibitCount = size(inhibitIndependence.thrusterInhibitOwners);
        }
        attribute cinchChainFiresOnlyWhenArmed : Boolean = TethysFdir::armedChain.cinch.fired and not TethysFdir::inhibitedChain.cinch.fired;
    }

    // ---------------------------------------------------------------- assurance activities and the release gate (SW-045)

    action def AssuranceActivity {
        doc /* An assurance activity applied to the software of one assurance level: its status
             * and whether it is performed by a team independent of the developers. The release
             * gate requires every level-A activity complete. */
        attribute level : SoftwareAssuranceLevel;
        attribute status : ActivityStatus default = ActivityStatus::planned;
        attribute independent : Boolean default = false;
        attribute evidence : String default = "";
        attribute complete : Boolean = status == ActivityStatus::complete;
    }
    action def CodingStandardCompliance :> AssuranceActivity {
        doc /* Coding to the project standard, checked by the compiler's strict profile and a
             * style checker on every build. */
    }
    action def StaticAnalysis :> AssuranceActivity {
        doc /* Static analysis for undefined behaviour, data races between partitions and
             * worst-case stack depth; level A adds abstract-interpretation proofs of no run-time error. */
    }
    action def PeerReview :> AssuranceActivity {
        doc /* Design and code review by a second engineer; level A requires a reviewer outside
             * the developing team. */
    }
    action def UnitTestWithCoverage :> AssuranceActivity {
        doc /* Unit tests with structural coverage: statement for level C, branch for level B,
             * modified condition/decision for level A. */
        attribute coverageTarget : Real;
    }
    action def IndependentVerificationAndValidation :> AssuranceActivity {
        doc /* Independent verification and validation of the requirements, design and tests by
             * an organisation outside the software project, required for level A only. */
        attribute :>> independent = true;
    }

    part def LevelAssurancePlan {
        doc /* The assurance activities of one level. */
        attribute level : SoftwareAssuranceLevel;
        action coding : CodingStandardCompliance { attribute :>> level = LevelAssurancePlan::level; }
        action staticAnalysis : StaticAnalysis { attribute :>> level = LevelAssurancePlan::level; }
        action review : PeerReview { attribute :>> level = LevelAssurancePlan::level; }
        action unitTest : UnitTestWithCoverage { attribute :>> level = LevelAssurancePlan::level; }
        action independentVv : IndependentVerificationAndValidation [0..1] { attribute :>> level = LevelAssurancePlan::level; }
        attribute activityCount : Natural = 4 + size(independentVv);
        attribute completeCount : Natural = size(coding.complete->select { in c : Boolean; c }) + size(staticAnalysis.complete->select { in c : Boolean; c })
            + size(review.complete->select { in c : Boolean; c }) + size(unitTest.complete->select { in c : Boolean; c })
            + size(independentVv.complete->select { in c : Boolean; c });
        attribute allComplete : Boolean = completeCount == activityCount;
    }

    part assurancePlan {
        doc /* The assurance plan per level. Status as of the phase-6 baseline: coding and static
             * analysis complete for every level; reviews complete for levels A and B; unit tests
             * complete for level A and B; the level-A independent V&V in progress, so the release
             * gate is open. */
        part levelA : LevelAssurancePlan {
            doc /* Level A: every activity plus independent V&V. */
            attribute :>> level = SoftwareAssuranceLevel::levelA;
            action :>> coding { attribute :>> status = ActivityStatus::complete; attribute :>> evidence = "strict build profile on every build"; }
            action :>> staticAnalysis { attribute :>> status = ActivityStatus::complete; attribute :>> evidence = "no-run-time-error proof of the inhibit chain and the mode manager"; }
            action :>> review { attribute :>> status = ActivityStatus::complete; attribute :>> independent = true; attribute :>> evidence = "cross-team review record"; }
            action :>> unitTest { attribute :>> status = ActivityStatus::complete; attribute :>> coverageTarget = 1.0; attribute :>> evidence = "modified condition/decision coverage 100 percent"; }
            action :>> independentVv [1] { attribute :>> status = ActivityStatus::inProgress; attribute :>> evidence = "independent V&V of the capture controller and FDIR in progress"; }
        }
        part levelB : LevelAssurancePlan {
            doc /* Level B: no independent V&V. */
            attribute :>> level = SoftwareAssuranceLevel::levelB;
            action :>> coding { attribute :>> status = ActivityStatus::complete; }
            action :>> staticAnalysis { attribute :>> status = ActivityStatus::complete; }
            action :>> review { attribute :>> status = ActivityStatus::complete; }
            action :>> unitTest { attribute :>> status = ActivityStatus::complete; attribute :>> coverageTarget = 0.9; }
            action :>> independentVv [0];
        }
        part levelC : LevelAssurancePlan {
            doc /* Level C: statement coverage, review in progress. */
            attribute :>> level = SoftwareAssuranceLevel::levelC;
            action :>> coding { attribute :>> status = ActivityStatus::complete; }
            action :>> staticAnalysis { attribute :>> status = ActivityStatus::complete; }
            action :>> review { attribute :>> status = ActivityStatus::inProgress; }
            action :>> unitTest { attribute :>> status = ActivityStatus::planned; attribute :>> coverageTarget = 0.8; }
            action :>> independentVv [0];
        }
        part levelD : LevelAssurancePlan {
            doc /* Level D: coding standard and review only; analysis and tests at the team's discretion. */
            attribute :>> level = SoftwareAssuranceLevel::levelD;
            action :>> coding { attribute :>> status = ActivityStatus::complete; }
            action :>> staticAnalysis { attribute :>> status = ActivityStatus::planned; }
            action :>> review { attribute :>> status = ActivityStatus::planned; }
            action :>> unitTest { attribute :>> status = ActivityStatus::planned; attribute :>> coverageTarget = 0.5; }
            action :>> independentVv [0];
        }
        attribute levelAComplete : Boolean = levelA.allComplete;
        attribute levelAIndependentVvPlanned : Boolean = size(levelA.independentVv) == 1;
        attribute activityCount : Natural = levelA.activityCount + levelB.activityCount + levelC.activityCount + levelD.activityCount;
        attribute completeCount : Natural = levelA.completeCount + levelB.completeCount + levelC.completeCount + levelD.completeCount;
    }

    requirement def ReleaseReadinessGate {
        doc /* The flight software release gate: every level-A assurance activity, including the
             * independent V&V, is complete. */
        subject plan : LevelAssurancePlan;
        require constraint { plan.allComplete }
        require constraint { size(plan.independentVv) == 1 }
    }
    requirement <'SA-001'> releaseReadiness : ReleaseReadinessGate {
        doc /* Release readiness of the Argent flight software: the level-A plan complete with its
             * independent V&V. Open at this baseline: the independent V&V is in progress. */
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
    }
    requirement <'SA-002'> levelAHasIndependentVv : ReleaseReadinessGate {
        doc /* Every level-A classification row requires independent V&V and the plan provides it. */
        require constraint { classificationRegister.captureControl.independentVvRequired and assurancePlan.levelAIndependentVvPlanned }
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
    }

    // ---------------------------------------------------------------- software verification cases (SW-046)

    metadata def SoftwareVerification {
        doc /* The software verification record of a case: the test level it runs at, the test bed,
             * its as-run verdict (planned until the case has run, then pass or fail against its
             * pass criterion) and the evidence, a pinned run or a test report. Metadata rather
             * than case attributes so a planned case with unbound measurements is still readable. */
        attribute level : SoftwareTestLevel;
        attribute testBed : String;
        attribute verdict : VerificationVerdict;
        attribute evidence : String;
    }

    verification def SoftwareVerificationCase {
        doc /* A software verification case: the software functions of TethysAllocations it
             * exercises, by subsetting so the coverage query finds them. The subclasses add the
             * subject, the measured inputs and the pass criterion in TethysVerification's style;
             * the objective names the system rows the software satisfies; the usage carries its
             * SoftwareVerification record. */
        ref action verifiedFunctions : SoftwareFunction [0..*];
    }

    verification def RelativeStateEstimationTest :> SoftwareVerificationCase {
        doc /* Relative-state estimation against truth from the dynamics simulator. */
        subject fsw : SoftwareTug;
        in attribute measuredPositionError : LengthValue;
        objective { doc /* Position error within the navigation requirement. */ verify relativeNavigation { doc /* Verified by this case. */ } }
        PassIf(measuredPositionError <= 0.1 [m])
    }
    verification def FinalTargetingTest :> SoftwareVerificationCase {
        doc /* The final targeting burn stays outside the Earth corridor, or the exclusion monitor aborts it. */
        subject fsw : SoftwareTug;
        in attribute abortRaisedInsideCorridor : Boolean;
        objective { doc /* An in-corridor solution is aborted before the burn. */
            verify earthImpactExclusion { doc /* Verified by this case. */ }
            verify impactScreening { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::flightDynamicsProducts { doc /* Verified by this case. */ }
        }
        PassIf(abortRaisedInsideCorridor)
    }
    verification def CaptureAbortTest :> SoftwareVerificationCase {
        doc /* Autonomous abort of the approach on a keep-out breach and the on-board sequence store. */
        subject fsw : SoftwareTug;
        in attribute abortIssuedOnBreach : Boolean;
        in attribute storedSequenceCount : Natural;
        objective { doc /* The abort fires and the sequence store holds the six rehearsed sequences. */
            verify approachKeepOut { doc /* Verified by this case. */ }
            verify autonomousSurvival { doc /* Verified by this case. */ }
            verify sequenceClearance { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::eventLogging { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::imageIntegrity { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::bootFallback { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::safeModeEntry { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::modeTransitions { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::redundancyManagement { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::heartbeatFailover { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::dataStoreRetention { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::boardSupportWatchdog { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::cdhApplication { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::thermalControlApplication { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::parameterBootUpdateApplication { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::flightDynamicsProducts { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::proximityGoNoGo { doc /* Verified by this case. */ }
        }
        PassIf(abortIssuedOnBreach and storedSequenceCount >= 6)
    }
    verification def CommandRoutingTest :> SoftwareVerificationCase {
        doc /* Command and telemetry routing through the message bus, including the computer failover. */
        subject fsw : SoftwareTug;
        in attribute measuredFailover : DurationValue;
        objective { doc /* Routing resumes on the redundant computer within the command-latency budget. */
            verify commandLatency { doc /* Verified by this case. */ }
            verify dictionaryDrivenTelemetry { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::commandIngest { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::commandDispatchLatency { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::sequencingEngine { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::schedulerCapacity { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::autonomyApplication { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::commandValidation { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::sequenceClearance { doc /* Verified by this case. */ }
        }
        PassIf(measuredFailover <= 600 [s])
    }
    verification def ThrustArcControlTest :> SoftwareVerificationCase {
        doc /* Thrust-arc control: arc start and stop, string loss handled by restart or spare, no thrust during a relay pass. */
        subject fsw : SoftwareTug;
        in attribute stringLossHandled : Boolean;
        in attribute thrustHeldDuringRelay : Boolean;
        objective { doc /* The arc continues on the spare string and the relay rule holds. */
            verify sepThrust { doc /* Verified by this case. */ }
            verify thrustRedundancy { doc /* Verified by this case. */ }
            verify noThrustDuringRelay { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::hazardousTwoStep { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::sequencingEngine { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::sepControlApplication { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::hazardousApproval { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::sequenceClearance { doc /* Verified by this case. */ }
        }
        PassIf(stringLossHandled and thrustHeldDuringRelay)
    }
    verification def PowerManagementTest :> SoftwareVerificationCase {
        doc /* Battery management and load shedding at the depth-of-discharge floor. */
        subject fsw : SoftwareTug;
        in attribute loadShedTrippedAtFloor : Boolean;
        objective { doc /* The shed trips at the floor with the array sized for the target distance. */
            verify batteryDepthOfDischarge { doc /* Verified by this case. */ }
            verify arrayPowerAtTarget { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::sequencingEngine { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::powerManagementApplication { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::sequenceClearance { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::limitAlarming { doc /* Verified by this case. */ }
        }
        PassIf(loadShedTrippedAtFloor)
    }
    verification def ThermalControlTest :> SoftwareVerificationCase {
        doc /* Heater-zone regulation within the allowable ranges. */
        subject fsw : SoftwareTug;
        in attribute zonesWithinRange : Boolean;
        objective { doc /* Every zone within range through the hot and cold cases. */ verify heatRejection { doc /* Verified by this case. */ } }
        PassIf(zonesWithinRange)
    }
    verification def SpaceLinkTest :> SoftwareVerificationCase {
        doc /* Space-link management through a pass: acquisition, rate change and loss. */
        subject fsw : SoftwareTug;
        in attribute linkHeldThroughPass : Boolean;
        objective { doc /* The link is held through the pass at the planned rate. */
            verify deepSpaceLink { doc /* Verified by this case. */ }
            verify deepSpaceEirp { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::telemetryRatesByMode { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::timeCorrelation { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::telemetrySampleLatency { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::dataStoreRetention { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::telemetryOutput { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::housekeepingSampling { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::telecomApplication { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::passPlanningVolume { doc /* Verified by this case. */ }
        }
        PassIf(linkHeldThroughPass)
    }
    verification def InspectorRelayTest :> SoftwareVerificationCase {
        doc /* Relay of the inspector's survey frames without loss. */
        subject fsw : SoftwareTug;
        in attribute framesRelayedWithoutLoss : Boolean;
        objective { doc /* Every frame of the survey relayed. */
            verify characterisationProducts { doc /* Verified by this case. */ }
            verify proximityLinkRange { doc /* Verified by this case. */ } }
        PassIf(framesRelayedWithoutLoss)
    }
    verification def CaptureSequenceTest :> SoftwareVerificationCase {
        doc /* The capture sequence: fires when armed with every inhibit removed, holds otherwise. */
        subject fsw : SoftwareTug;
        in attribute firedWhenArmed : Boolean;
        in attribute heldWhenInhibited : Boolean;
        objective { doc /* No fire without the inhibits removed; fire when they are. */
            verify captureEnvelope { doc /* Verified by this case. */ }
            verify captureQualification { doc /* Verified by this case. */ }
            verify cinchMotorTorque { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::simulatorFidelity { doc /* Verified by this case. */ }
        }
        PassIf(firedWhenArmed and heldWhenInhibited)
    }
    verification def FaultDetectionTest :> SoftwareVerificationCase {
        doc /* Fault detection, isolation and recovery: detection latency and the safe configuration. */
        subject fsw : SoftwareTug;
        in attribute measuredDetection : DurationValue;
        in attribute safeConfigurationReached : Boolean;
        objective { doc /* Detection within 0.5 s and the safe configuration reached. */
            verify faultResponse { doc /* Verified by this case. */ }
            verify faultDetectionLatency { doc /* Verified by this case. */ }
            verify fdirTaskPeriod { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::eventLogging { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::parameterTables { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::partitionIsolation { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::faultDetectionChain { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::safeConfigurationLatency { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::fdirTaskRate { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::safeModeEntry { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::heartbeatFailover { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::boardSupportWatchdog { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::gncApplication { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::captureControlApplication { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::fdirApplication { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::modeManagementApplication { doc /* Verified by this case. */ }
        }
        PassIf(measuredDetection <= 0.5 [s] and safeConfigurationReached)
    }
    verification def ModeManagementTest :> SoftwareVerificationCase {
        doc /* Mode management: the mode sequence of a flight and the safe-mode entry and recovery. */
        subject fsw : SoftwareTug;
        in attribute observedFinalMode : String;
        in attribute expectedFinalMode : String;
        objective { doc /* The final mode of the scenario is the expected one. */ verify autonomousSurvival { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::eventLogging { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::imageIntegrity { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::bootFallback { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::safeModeEntry { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::modeTransitions { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::redundancyManagement { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::heartbeatFailover { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::dataStoreRetention { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::boardSupportWatchdog { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::cdhApplication { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::thermalControlApplication { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::parameterBootUpdateApplication { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::flightDynamicsProducts { doc /* Verified by this case. */ }
        }
        PassIf(observedFinalMode == expectedFinalMode)
    }
    verification def BootAndParameterTest :> SoftwareVerificationCase {
        doc /* Boot from the committed image, parameter table activation and the image update. */
        subject fsw : SoftwareTug;
        in attribute bootedFromCommittedImage : Boolean;
        objective { doc /* The committed image boots; a corrupt upload falls back. */ verify dictionaryConsistent { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::commandIngest { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::hazardousTwoStep { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::parameterTables { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::telemetryOutput { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::commandValidation { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::telemetryDecommutation { doc /* Verified by this case. */ }
        }
        PassIf(bootedFromCommittedImage)
    }
    verification def HazardousCommandInhibitTest :> SoftwareVerificationCase {
        doc /* Every hazardous command of the flight dictionary has an inhibit test: the capture
             * inhibit chain, the high-voltage hold, or the two-step confirm key. */
        subject fsw : SoftwareTug;
        in attribute hazardousCommandCount : Natural;
        in attribute inhibitTestedCount : Natural;
        objective { doc /* Tested hazardous commands equal the dictionary's hazardous commands. */
            verify commandValidation { doc /* Verified by this case. */ }
            verify highVoltageInhibit { doc /* Verified by this case. */ } }
        PassIf(inhibitTestedCount == hazardousCommandCount)
    }
    verification def GroundCommandTwoStepTest :> SoftwareVerificationCase {
        doc /* The ground two-step: a hazardous command needs its second approval and a sequence
             * violating a flight rule is refused by the checker. */
        subject suite : MeridianOperationsSuite;
        in attribute sequenceRefusedOnRuleViolation : Boolean;
        in attribute secondApprovalRequired : Boolean;
        objective { doc /* Refusal and the second approval both observed. */
            verify commandValidation { doc /* Verified by this case. */ }
            verify sequenceClearance { doc /* Verified by this case. */ }
            verify sequenceTurnaround { doc /* Verified by this case. */ }
        }
        PassIf(sequenceRefusedOnRuleViolation and secondApprovalRequired)
    }
    verification def PassPlanningTest :> SoftwareVerificationCase {
        doc /* Pass planning against the link budget and the monitoring automation. */
        subject suite : MeridianOperationsSuite;
        in attribute plannedPassesFit : Boolean;
        objective { doc /* Every planned pass fits the link. */
            verify plannedPassesFitTheLink { doc /* Verified by this case. */ }
            verify monitoringAutomation { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::limitAlarming { doc /* Verified by this case. */ }
            verify TethysSoftwareRequirements::trendingAutomation { doc /* Verified by this case. */ }
        }
        PassIf(plannedPassesFit)
    }

    // ---- the cases: planned at unit, integration, flight-software-in-the-loop, hardware-in-the-loop
    //      and flatsat level; model-in-the-loop cases are run against the pinned runs and pass or fail.

    verification relativeStateUnit : RelativeStateEstimationTest {
        doc /* Unit tests of the estimator on recorded truth. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.estimateRelativeState;
        @SoftwareVerification { level = SoftwareTestLevel::unit; testBed = "developer workstation"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
    }
    verification relativeStateDynamics : RelativeStateEstimationTest {
        doc /* The estimator in the six-degree-of-freedom dynamics simulator. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.estimateRelativeState;
        @SoftwareVerification { level = SoftwareTestLevel::integration; testBed = "dynamicsSimulator"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
    }
    verification finalTargetingUnit : FinalTargetingTest {
        doc /* Unit tests of the targeting solver against corridor cases. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.planFinalTargeting;
        @SoftwareVerification { level = SoftwareTestLevel::unit; testBed = "developer workstation"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
    }
    verification finalTargetingFlightSoftwareInTheLoop : FinalTargetingTest {
        doc /* The flight image on the emulated computer against the trajectory tool. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.planFinalTargeting;
        @SoftwareVerification { level = SoftwareTestLevel::flightSoftwareInTheLoop; testBed = "trajectoryTool"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
    }
    verification finalTargetingModel : FinalTargetingTest {
        doc /* Model-in-the-loop: the Earth-impact scenario of TethysFdir aborts the in-corridor return. */
        subject fsw = argentSoftware;
        in abortRaisedInsideCorridor = true;
        ref :>> verifiedFunctions :> missionFunctions.planFinalTargeting;
        @SoftwareVerification { level = SoftwareTestLevel::modelInTheLoop; testBed = "executable model"; verdict = VerificationVerdict::pass; evidence = "fdir-earth-impact-aborted, fdir-earth-impact-abort-hold pinned runs"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification captureAbortUnit : CaptureAbortTest {
        doc /* Unit tests of the abort rules. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.abortCapture;
        @SoftwareVerification { level = SoftwareTestLevel::unit; testBed = "developer workstation"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
    }
    verification captureAbortFlatsat : CaptureAbortTest {
        doc /* The abort on the flatsat with injected keep-out breaches. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.abortCapture;
        @SoftwareVerification { level = SoftwareTestLevel::flatsat; testBed = "flatsat"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification captureAbortModel : CaptureAbortTest {
        doc /* Model-in-the-loop: the autonomy engine's sequence store and abort of TethysFlightBehaviour. */
        subject fsw = argentSoftware;
        in abortIssuedOnBreach = true; in storedSequenceCount = 6;
        ref :>> verifiedFunctions :> missionFunctions.executeOnBoardSequences;
        @SoftwareVerification { level = SoftwareTestLevel::modelInTheLoop; testBed = "executable model"; verdict = VerificationVerdict::pass; evidence = "sw-autonomy-engine pinned run: storedSequences 1 to 6"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification commandRoutingIntegration : CommandRoutingTest {
        doc /* Routing between the applications on the software bus. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.routeCommandsAndTelemetry;
        @SoftwareVerification { level = SoftwareTestLevel::integration; testBed = "software integration bench"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
    }
    verification commandRoutingHardwareInTheLoop : CommandRoutingTest {
        doc /* The failover on the engineering-model avionics. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.routeCommandsAndTelemetry;
        @SoftwareVerification { level = SoftwareTestLevel::hardwareInTheLoop; testBed = "flatsat"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification commandRoutingModel : CommandRoutingTest {
        doc /* Model-in-the-loop: the computer failover scenario of TethysFlightBehaviour. */
        subject fsw = argentSoftware;
        in measuredFailover = 600 [s];
        ref :>> verifiedFunctions :> missionFunctions.routeCommandsAndTelemetry;
        @SoftwareVerification { level = SoftwareTestLevel::modelInTheLoop; testBed = "executable model"; verdict = VerificationVerdict::pass; evidence = "sw-failover pinned run, advanced 600 s"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification thrustArcUnit : ThrustArcControlTest {
        doc /* Unit tests of the arc controller. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.controlThrustArc;
        @SoftwareVerification { level = SoftwareTestLevel::unit; testBed = "developer workstation"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
    }
    verification thrustArcFlightSoftwareInTheLoop : ThrustArcControlTest {
        doc /* The arc controller on the emulated computer with simulated strings. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.controlThrustArc;
        @SoftwareVerification { level = SoftwareTestLevel::flightSoftwareInTheLoop; testBed = "trajectoryTool"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
    }
    verification thrustArcModel : ThrustArcControlTest {
        doc /* Model-in-the-loop: the thruster-fault scenarios and the relay-then-thrust rule check. */
        subject fsw = argentSoftware;
        in stringLossHandled = true; in thrustHeldDuringRelay = true;
        ref :>> verifiedFunctions :> missionFunctions.controlThrustArc;
        @SoftwareVerification { level = SoftwareTestLevel::modelInTheLoop; testBed = "executable model"; verdict = VerificationVerdict::pass; evidence = "sw-sep-string-restarting, fdir-thruster-string-lost, wpd-flight-rules pinned runs"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification powerManagementUnit : PowerManagementTest {
        doc /* Unit tests of the load-shed logic. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.manageBatteryAndLoads;
        @SoftwareVerification { level = SoftwareTestLevel::unit; testBed = "developer workstation"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
    }
    verification powerManagementFlatsat : PowerManagementTest {
        doc /* Load shedding on the flatsat with a battery simulator. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.manageBatteryAndLoads;
        @SoftwareVerification { level = SoftwareTestLevel::flatsat; testBed = "flatsat"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification thermalControlUnit : ThermalControlTest {
        doc /* Unit tests of the zone controller. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.regulateHeaterZones;
        @SoftwareVerification { level = SoftwareTestLevel::unit; testBed = "developer workstation"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
    }
    verification thermalControlFlatsat : ThermalControlTest {
        doc /* Zone control on the flatsat through the thermal balance cases. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.regulateHeaterZones;
        @SoftwareVerification { level = SoftwareTestLevel::flatsat; testBed = "flatsat"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification spaceLinkUnit : SpaceLinkTest {
        doc /* Unit tests of the link manager. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.manageSpaceLink;
        @SoftwareVerification { level = SoftwareTestLevel::unit; testBed = "developer workstation"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
    }
    verification spaceLinkHardwareInTheLoop : SpaceLinkTest {
        doc /* A pass through the engineering-model transponder. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.manageSpaceLink;
        @SoftwareVerification { level = SoftwareTestLevel::hardwareInTheLoop; testBed = "flatsat"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification inspectorRelayUnit : InspectorRelayTest {
        doc /* Unit tests of the relay buffer. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.relayInspector;
        @SoftwareVerification { level = SoftwareTestLevel::unit; testBed = "developer workstation"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
    }
    verification inspectorRelayIntegration : InspectorRelayTest {
        doc /* Relay of a recorded survey on the integration bench. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.relayInspector;
        @SoftwareVerification { level = SoftwareTestLevel::integration; testBed = "software integration bench"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
    }
    verification captureSequenceUnit : CaptureSequenceTest {
        doc /* Unit tests of the inhibit gate: every combination of the three inhibits. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.controlCaptureSequence;
        @SoftwareVerification { level = SoftwareTestLevel::unit; testBed = "developer workstation"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
    }
    verification captureSequenceFlightSoftwareInTheLoop : CaptureSequenceTest {
        doc /* The controller on the emulated computer against the capture rig controller. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.controlCaptureSequence;
        @SoftwareVerification { level = SoftwareTestLevel::flightSoftwareInTheLoop; testBed = "captureRig"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
    }
    verification captureSequenceHardwareInTheLoop : CaptureSequenceTest {
        doc /* The cinch on the capture rig with the flight controller in the loop. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.controlCaptureSequence;
        @SoftwareVerification { level = SoftwareTestLevel::hardwareInTheLoop; testBed = "captureRig"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification captureSequenceModel : CaptureSequenceTest {
        doc /* Model-in-the-loop: the inhibit chain of TethysFdir fires when armed and holds when
             * inhibited; the capture controller's no-fire property holds exhaustively. */
        subject fsw = argentSoftware;
        in firedWhenArmed = TethysFdir::armedChain.cinch.fired;
        in heldWhenInhibited = not TethysFdir::inhibitedChain.cinch.fired;
        ref :>> verifiedFunctions :> missionFunctions.controlCaptureSequence;
        @SoftwareVerification { level = SoftwareTestLevel::modelInTheLoop; testBed = "executable model"; verdict = VerificationVerdict::pass; evidence = "fdir-inhibit-chain-check, fdir-inhibit-chain-held, sw-capture-controller-check, sw-capture-controller-check-inhibited pinned runs"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification faultDetectionUnit : FaultDetectionTest {
        doc /* Unit tests of every monitor and response table entry. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.detectAndRecoverFaults;
        @SoftwareVerification { level = SoftwareTestLevel::unit; testBed = "developer workstation"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
    }
    verification faultDetectionFlightSoftwareInTheLoop : FaultDetectionTest {
        doc /* Injected faults on the emulated computer. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.detectAndRecoverFaults;
        @SoftwareVerification { level = SoftwareTestLevel::flightSoftwareInTheLoop; testBed = "trajectoryTool"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
    }
    verification faultDetectionFlatsat : FaultDetectionTest {
        doc /* Injected thrust-vector and contact faults on the flatsat, timed. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.detectAndRecoverFaults;
        @SoftwareVerification { level = SoftwareTestLevel::flatsat; testBed = "flatsat"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification faultDetectionModel : FaultDetectionTest {
        doc /* Model-in-the-loop: the command-loss and thruster-fault scenarios of TethysFdir and
             * TethysFlightBehaviour reach safe mode and the restart. Detection is one supervisor
             * period of 0.1 s in the model. */
        subject fsw = argentSoftware;
        in measuredDetection = 0.1 [s]; in safeConfigurationReached = true;
        ref :>> verifiedFunctions :> missionFunctions.detectAndRecoverFaults;
        @SoftwareVerification { level = SoftwareTestLevel::modelInTheLoop; testBed = "executable model"; verdict = VerificationVerdict::pass; evidence = "fdir-command-loss-expired, fdir-command-loss-modes-safe, sw-fdir-command-loss-expired, sw-fdir-thruster-restarting pinned runs"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification modeManagementUnit : ModeManagementTest {
        doc /* Unit tests of every transition of the mode table. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.manageModes;
        @SoftwareVerification { level = SoftwareTestLevel::unit; testBed = "developer workstation"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
    }
    verification modeManagementFlatsat : ModeManagementTest {
        doc /* The mode sequence of a flight on the flatsat. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.manageModes;
        @SoftwareVerification { level = SoftwareTestLevel::flatsat; testBed = "flatsat"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification modeManagementModel : ModeManagementTest {
        doc /* Model-in-the-loop: the mode manager of TethysFlightBehaviour through the full flight
             * and the command-loss safe-mode entry and recovery. */
        subject fsw = argentSoftware;
        in observedFinalMode = "safe"; in expectedFinalMode = "safe";
        ref :>> verifiedFunctions :> missionFunctions.manageModes;
        @SoftwareVerification { level = SoftwareTestLevel::modelInTheLoop; testBed = "executable model"; verdict = VerificationVerdict::pass; evidence = "sw-mode-manager-safe, sw-mode-manager-recovered, sw-mode-manager-full-flight, modes-tug-full-flight pinned runs"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification bootAndParameterUnit : BootAndParameterTest {
        doc /* Unit tests of the image check and table activation. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.manageParametersAndImages;
        @SoftwareVerification { level = SoftwareTestLevel::unit; testBed = "developer workstation"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
    }
    verification bootAndParameterHardwareInTheLoop : BootAndParameterTest {
        doc /* Boot and update on the engineering-model computer. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.manageParametersAndImages;
        @SoftwareVerification { level = SoftwareTestLevel::hardwareInTheLoop; testBed = "flatsat"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification bootAndParameterModel : BootAndParameterTest {
        doc /* Model-in-the-loop: the boot scenario of TethysFlightBehaviour. */
        subject fsw = argentSoftware;
        in bootedFromCommittedImage = true;
        ref :>> verifiedFunctions :> missionFunctions.manageParametersAndImages;
        @SoftwareVerification { level = SoftwareTestLevel::modelInTheLoop; testBed = "executable model"; verdict = VerificationVerdict::pass; evidence = "sw-boot, sw-boot-sequence pinned runs"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification hazardousCommandInhibitModel : HazardousCommandInhibitTest {
        doc /* Model-in-the-loop: every hazardous command of the dictionary is in the inhibit test
             * register below. */
        subject fsw = argentSoftware;
        in hazardousCommandCount = flightDictionary.hazardousCommandCount;
        in inhibitTestedCount = hazardousCommandInhibitRegister.testedCount;
        ref :>> verifiedFunctions :> missionFunctions.routeCommandsAndTelemetry;
        @SoftwareVerification { level = SoftwareTestLevel::modelInTheLoop; testBed = "executable model"; verdict = VerificationVerdict::pass; evidence = "sw-assurance-coverage pinned run"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification hazardousCommandInhibitFlatsat : HazardousCommandInhibitTest {
        doc /* Every hazardous command sent to the flatsat with an inhibit in place; none acts. */
        subject fsw = argentSoftware;
        ref :>> verifiedFunctions :> missionFunctions.routeCommandsAndTelemetry;
        @SoftwareVerification { level = SoftwareTestLevel::flatsat; testBed = "flatsat"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification groundTwoStepModel : GroundCommandTwoStepTest {
        doc /* Model-in-the-loop: the flight-rule checker refuses the sequence that thrusts during a
             * relay pass; the command builder's two approvals for a hazardous command. */
        subject suite = meridianOperationsSuite;
        in sequenceRefusedOnRuleViolation = true; in secondApprovalRequired = true;
        @SoftwareVerification { level = SoftwareTestLevel::modelInTheLoop; testBed = "executable model"; verdict = VerificationVerdict::pass; evidence = "sw-ground-sequencer-check pinned run: verdict refused, reason FR-001"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification groundTwoStepIntegration : GroundCommandTwoStepTest {
        doc /* The command builder and checker against the flight-software-in-the-loop simulator. */
        subject suite = meridianOperationsSuite;
        @SoftwareVerification { level = SoftwareTestLevel::flightSoftwareInTheLoop; testBed = "trajectoryTool"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    verification passPlanningIntegration : PassPlanningTest {
        doc /* The pass planner against the link budget tool. */
        subject suite = meridianOperationsSuite;
        @SoftwareVerification { level = SoftwareTestLevel::integration; testBed = "operations centre integration"; verdict = VerificationVerdict::planned; evidence = "not yet run"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }

    // ---------------------------------------------------------------- hazardous-command inhibit register and coverage (SW-047)

    part hazardousCommandInhibitRegister {
        doc /* Every hazardous command of the flight dictionary and the inhibit test that covers it:
             * the capture commands by the three-inhibit chain, the SEP and RCS commands by the
             * high-voltage and thruster-enable holds, every other hazardous command by the two-step
             * confirm key of the command builder. */
        ref item captureChainTested : CommandDefinition [*] = (
            TethysFlightDictionary::capArmCapture, TethysFlightDictionary::capDeployBag, TethysFlightDictionary::capCloseBag,
            TethysFlightDictionary::capCinchBag, TethysFlightDictionary::capStartDespin, TethysFlightDictionary::capLatchBody,
            TethysFlightDictionary::capReleaseBody, TethysFlightDictionary::capAbortCapture,
            TethysFlightDictionary::capPetalOpen1, TethysFlightDictionary::capPetalClose1, TethysFlightDictionary::capPetalOpen2, TethysFlightDictionary::capPetalClose2,
            TethysFlightDictionary::capPetalOpen3, TethysFlightDictionary::capPetalClose3, TethysFlightDictionary::capPetalOpen4, TethysFlightDictionary::capPetalClose4);
        ref item thrusterHoldTested : CommandDefinition [*] = (
            TethysFlightDictionary::sepStartThrustArc, TethysFlightDictionary::sepPrimeFeed, TethysFlightDictionary::sepVentFeed,
            TethysFlightDictionary::sepThrusterRestart, TethysFlightDictionary::sepOpenLatchValve,
            TethysFlightDictionary::sepPpuOn1, TethysFlightDictionary::sepPpuOn2, TethysFlightDictionary::sepPpuOn3,
            TethysFlightDictionary::gncDesaturateWheels, TethysFlightDictionary::gncEnableRcsControl, TethysFlightDictionary::gncStartTcm,
            TethysFlightDictionary::gncRcsThrusterEnable01, TethysFlightDictionary::gncRcsThrusterEnable02, TethysFlightDictionary::gncRcsThrusterEnable03,
            TethysFlightDictionary::gncRcsThrusterEnable04, TethysFlightDictionary::gncRcsThrusterEnable05, TethysFlightDictionary::gncRcsThrusterEnable06,
            TethysFlightDictionary::gncRcsThrusterEnable07, TethysFlightDictionary::gncRcsThrusterEnable08);
        ref item twoStepTested : CommandDefinition [*] = (
            TethysFlightDictionary::cdhResetProcessor, TethysFlightDictionary::cdhLoadMemory, TethysFlightDictionary::thmDisableAllHeaters,
            TethysFlightDictionary::comTransmitterOn, TethysFlightDictionary::insArmRelease, TethysFlightDictionary::insReleaseInspector,
            TethysFlightDictionary::insRetireInspector, TethysFlightDictionary::fdrDisableMonitor, TethysFlightDictionary::fdrMaskResponse,
            TethysFlightDictionary::fdrForceSafeMode, TethysFlightDictionary::fdrAbortToRetreat, TethysFlightDictionary::modSetMode,
            TethysFlightDictionary::pbuActivateTable, TethysFlightDictionary::pbuStartBootUpdate, TethysFlightDictionary::pbuSelectBootImage,
            TethysFlightDictionary::pbuCommitBootImage);
        attribute testedCount : Natural = size(captureChainTested) + size(thrusterHoldTested) + size(twoStepTested);
        attribute allTestedAreHazardous : Boolean = captureChainTested->forAll { in c : CommandDefinition; c.hazardous }
            and thrusterHoldTested->forAll { in c : CommandDefinition; c.hazardous }
            and twoStepTested->forAll { in c : CommandDefinition; c.hazardous };
        assert constraint everyHazardousCommandHasAnInhibitTest {
            doc /* The tested set is exactly the dictionary's hazardous set. */
            testedCount == flightDictionary.hazardousCommandCount and allTestedAreHazardous
        }
    }

    part releaseGateSatisfaction {
        doc /* The satisfaction assertions -satisfy evaluates: the level-A plan against the release
             * gate. Open at this baseline. */
        satisfy releaseReadiness by assurancePlan.levelA { doc /* The level-A assurance plan. */ }
        satisfy levelAHasIndependentVv by assurancePlan.levelA { doc /* The level-A assurance plan. */ }
    }
}
