package TethysAllocations {
    doc /* Allocations for the Tethys mission: the functional architecture (the mission functions
         * as an action decomposition), their allocation to the components of the tug, the
         * inspector, the launch and the ground segment with the standard Allocations library,
         * the allocation of the mission requirements to the components that carry them, the
         * sourcing (make, buy, heritage) and software-hosting records that ride on the
         * allocations, and the allocation matrix view. The coverage query that lists
         * unallocated functions needs the DocumentQueries library and lives in
         * model/probes/F-005-allocation-queries.sysml (docs/findings.md F-005). */

    private import ScalarValues::*;
    private import Actions::*;
    private import Parts::*;
    private import Requirements::*;
    private import StandardViewDefinitions::*;
    private import TethysTug::*;
    private import TethysInspector::*;
    private import TethysLaunch::*;
    private import TethysGround::*;
    private import TethysSystem::*;
    private import TethysRequirements::*;

    // ---------------------------------------------------------------- functional architecture

    action def MissionFunction {
        doc /* A mission function: something the system must do, independent of which component
             * does it. The allocations below bind each function to a component. */
        attribute description : String;
    }

    action def SoftwareFunction :> MissionFunction {
        doc /* A mission function realised in software, hosted on a processing component. */
    }

    action missionFunctions {
        doc /* The functional decomposition of the mission; the leaf actions are the units of
             * allocation. */

        action carryLoads : MissionFunction {
            doc /* Carry launch and capture loads between the launcher adapter and the bag. */
            attribute :>> description = "carry launch and capture loads";
        }
        action rejectHeat : MissionFunction {
            doc /* Keep every component within its temperature limits. */
            attribute :>> description = "reject waste heat";
        }
        action generateElectricalPower : MissionFunction {
            doc /* Generate 48 kW at 1 AU from the solar arrays. */
            attribute :>> description = "generate electrical power";
        }
        action storeAndDistributePower : MissionFunction {
            doc /* Store energy for eclipse and distribute regulated power. */
            attribute :>> description = "store and distribute power";
        }
        action produceHeliocentricThrust : MissionFunction {
            doc /* Produce the low-thrust Δv of the outbound and return cruises. */
            attribute :>> description = "produce heliocentric thrust";
        }
        action controlAttitude : MissionFunction {
            doc /* Hold and slew the attitude of the tug and the captured stack. */
            attribute :>> description = "control attitude";
        }
        action performProximityManoeuvres : MissionFunction {
            doc /* Translate relative to the target during approach and capture. */
            attribute :>> description = "perform proximity manoeuvres";
        }
        action estimateRelativeState : SoftwareFunction {
            doc /* Estimate the relative position and velocity to the target. */
            attribute :>> description = "estimate relative state";
        }
        action planFinalTargeting : SoftwareFunction {
            doc /* Compute the lunar gravity-assist targeting burn (safety-critical, TH-001). */
            attribute :>> description = "plan final targeting";
        }
        action abortCapture : SoftwareFunction {
            doc /* Return autonomously to the hold point before capture commit (TH-002). */
            attribute :>> description = "abort capture";
        }
        action characteriseTarget : MissionFunction {
            doc /* Measure the target's size, shape, spin and mass from the tug. */
            attribute :>> description = "characterise target";
        }
        action surveyTargetUpClose : MissionFunction {
            doc /* Image the target at close range before capture commit. */
            attribute :>> description = "survey target up close";
        }
        action encloseTarget : MissionFunction {
            doc /* Enclose and rigidise the target in the capture bag. */
            attribute :>> description = "enclose target";
        }
        action despinCapturedBody : MissionFunction {
            doc /* Remove the spin of the captured stack. */
            attribute :>> description = "despin captured body";
        }
        action communicateWithGround : MissionFunction {
            doc /* Carry telemetry, telecommands and radiometric tracking. */
            attribute :>> description = "communicate with ground";
        }
        action handleCommandsAndData : MissionFunction {
            doc /* Execute commands, run the flight software and store data. */
            attribute :>> description = "handle commands and data";
        }
        action deliverToEscape : MissionFunction {
            doc /* Deliver the stack to the Earth-escape trajectory. */
            attribute :>> description = "deliver to escape";
        }
        action trackAndCommand : MissionFunction {
            doc /* Track the spacecraft and uplink its commands from the ground. */
            attribute :>> description = "track and command";
        }
        action determineOrbit : MissionFunction {
            doc /* Determine the heliocentric and relative orbits and plan manoeuvres. */
            attribute :>> description = "determine orbit";
        }
        action operateMission : MissionFunction {
            doc /* Plan and conduct operations; hold the ground authority over critical burns. */
            attribute :>> description = "operate mission";
        }
        action archiveScienceData : MissionFunction {
            doc /* Archive and distribute characterisation and utilisation data. */
            attribute :>> description = "archive science data";
        }
    }

    // ---------------------------------------------------------------- allocation definitions

    allocation def FunctionAllocation {
        doc /* Allocation of a mission function to the component that performs it. */
        end :>> source : Action;
        end :>> target : Part;
    }

    allocation def RequirementAllocation {
        doc /* Allocation of a requirement to the component responsible for meeting it. */
        end :>> source : RequirementCheck;
        end :>> target : Part;
    }

    enum def SourcingKind {
        doc /* How a component is sourced. */
        make; buy; heritage;
    }

    metadata def Sourcing {
        doc /* Make / buy / heritage decision recorded on an allocation target, with the source
             * of a heritage or bought unit. */
        attribute kind : SourcingKind;
        attribute source : String;
    }

    // ---------------------------------------------------------------- function → component

    part functionAllocations {
        doc /* Every leaf of missionFunctions allocated to exactly one component; the query in
             * the F-005 probe must return no rows. */
        allocation loads : FunctionAllocation allocate missionFunctions.carryLoads to argent.structure;
        allocation heat : FunctionAllocation allocate missionFunctions.rejectHeat to argent.thermal;
        allocation generation : FunctionAllocation allocate missionFunctions.generateElectricalPower to argent.eps;
        allocation distribution : FunctionAllocation allocate missionFunctions.storeAndDistributePower to argent.eps;
        allocation thrust : FunctionAllocation allocate missionFunctions.produceHeliocentricThrust to argent.sep;
        allocation attitude : FunctionAllocation allocate missionFunctions.controlAttitude to argent.gnc;
        allocation proximity : FunctionAllocation allocate missionFunctions.performProximityManoeuvres to argent.rcs;
        allocation relativeState : FunctionAllocation allocate missionFunctions.estimateRelativeState to argent.gnc;
        allocation finalTargeting : FunctionAllocation allocate missionFunctions.planFinalTargeting to argent.gnc;
        allocation abort : FunctionAllocation allocate missionFunctions.abortCapture to argent.cdh;
        allocation characterisation : FunctionAllocation allocate missionFunctions.characteriseTarget to argent.sensors;
        allocation survey : FunctionAllocation allocate missionFunctions.surveyTargetUpClose to wren.payload;
        allocation enclose : FunctionAllocation allocate missionFunctions.encloseTarget to argent.captureSystem;
        allocation despin : FunctionAllocation allocate missionFunctions.despinCapturedBody to argent.rcs;
        allocation communications : FunctionAllocation allocate missionFunctions.communicateWithGround to argent.telecom;
        allocation commandsAndData : FunctionAllocation allocate missionFunctions.handleCommandsAndData to argent.cdh;
        allocation escape : FunctionAllocation allocate missionFunctions.deliverToEscape to arcturus5H;
        allocation tracking : FunctionAllocation allocate missionFunctions.trackAndCommand to tethysSystem.ground.network.stations;
        allocation orbitDetermination : FunctionAllocation allocate missionFunctions.determineOrbit to tethysSystem.ground.network.fdf;
        allocation operations : FunctionAllocation allocate missionFunctions.operateMission to tethysSystem.ground.network.moc;
        allocation archive : FunctionAllocation allocate missionFunctions.archiveScienceData to tethysSystem.ground.network.sds;
    }

    // ---------------------------------------------------------------- requirement → component

    part requirementAllocations {
        doc /* The mission requirements allocated to the components that carry them. */
        allocation retrievalToCapture : RequirementAllocation allocate retrieval to argent.captureSystem;
        allocation retrievalToSep : RequirementAllocation allocate retrieval to argent.sep;
        allocation durationToSep : RequirementAllocation allocate missionDuration to argent.sep;
        allocation durationToEps : RequirementAllocation allocate missionDuration to argent.eps;
        allocation characterisationToSensors : RequirementAllocation allocate characterisation to argent.sensors;
        allocation characterisationToInspector : RequirementAllocation allocate characterisation to wren;
        allocation launchToStructure : RequirementAllocation allocate launchCompatibility to argent.structure;
        allocation launchToVehicle : RequirementAllocation allocate launchCompatibility to arcturus5H;
        allocation groundToTelecom : RequirementAllocation allocate groundCompatibility to argent.telecom;
        allocation groundToNetwork : RequirementAllocation allocate groundCompatibility to tethysSystem.ground.network;
        allocation safetyToGnc : RequirementAllocation allocate cislunarSafety to argent.gnc;
        allocation safetyToFdf : RequirementAllocation allocate cislunarSafety to tethysSystem.ground.network.fdf;
        allocation classToTug : RequirementAllocation allocate missionClass to argent;
        allocation deflectionToSep : RequirementAllocation allocate deflectionDemonstration to argent.sep;
        allocation utilisationToCapture : RequirementAllocation allocate utilisationAccess to argent.captureSystem;
    }

    // ---------------------------------------------------------------- sourcing and hosting (SE-084, SE-088)

    part sourcingRecord {
        doc /* Make / buy / heritage decisions for the allocation targets of the tug. */
        ref part structure :>> argent.structure {
            @Sourcing { kind = SourcingKind::make; source = "project-built primary structure"; }
        }
        ref part eps :>> argent.eps {
            @Sourcing { kind = SourcingKind::heritage; source = "Corvid-2 array and power regulation"; }
        }
        ref part sep :>> argent.sep {
            @Sourcing { kind = SourcingKind::buy; source = "qualified 12 kW Hall thruster strings"; }
        }
        ref part cdh :>> argent.cdh {
            @Sourcing { kind = SourcingKind::heritage; source = "Harrier avionics"; }
        }
        ref part captureSystem :>> argent.captureSystem {
            @Sourcing { kind = SourcingKind::make; source = "new development, see TK-006"; }
        }
    }

    part softwareHosting {
        doc /* The software functions and the processing component that hosts each; the flight
             * software architecture package refines this into partitions. */
        attribute hostOfRelativeState : String = "GNC processor";
        attribute hostOfFinalTargeting : String = "GNC processor";
        attribute hostOfAbort : String = "command and data handling processor";
        attribute safetyCriticalSoftwareFunctions : Natural = 2;
    }

    // ---------------------------------------------------------------- views

    view def AllocationMatrixView :> GridView {
        doc /* The allocation matrix: one row per allocated function or requirement, one column
             * per component. */
        filter @SysML::AllocationUsage;
    }

    view functionAllocationMatrix : AllocationMatrixView {
        doc /* Function → component matrix. */
        expose functionAllocations::*;
    }

    view requirementAllocationMatrix : AllocationMatrixView {
        doc /* Requirement → component matrix. */
        expose requirementAllocations::*;
    }
}
