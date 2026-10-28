package TethysAllocations {
    doc /* Allocations for the Tethys mission: the functional architecture (the mission functions
         * as an action decomposition), their allocation to the components of the tug, the
         * inspector, the launch and the ground segment with the standard Allocations library,
         * the allocation of the mission requirements to the components that carry them, the
         * sourcing (make, buy, heritage) and software-hosting records that ride on the
         * allocations, and the allocation matrix view. The coverage queries that list
         * unallocated functions and requirements need a document-query library and live in
         * the tool-tier file model/87-allocations-tooling.sysml. */

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
    private import TethysFlightSoftware::*;
    private import TethysTugStructure::FlightComputer;
    private import TethysTugStructure::argentDesign;

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
        action routeCommandsAndTelemetry : SoftwareFunction {
            doc /* Route telecommands to their owners and packetise telemetry for the downlink. */
            attribute :>> description = "route commands and telemetry";
        }
        action controlThrustArc : SoftwareFunction {
            doc /* Start, throttle and stop the thrusters through a thrust arc. */
            attribute :>> description = "control thrust arc";
        }
        action manageBatteryAndLoads : SoftwareFunction {
            doc /* Keep the battery within its state-of-charge limits and shed loads below the threshold. */
            attribute :>> description = "manage battery and loads";
        }
        action regulateHeaterZones : SoftwareFunction {
            doc /* Hold every heater zone at its set point. */
            attribute :>> description = "regulate heater zones";
        }
        action manageSpaceLink : SoftwareFunction {
            doc /* Configure the transponder and run the frame layer of the space link. */
            attribute :>> description = "manage space link";
        }
        action relayInspector : SoftwareFunction {
            doc /* Check out, release, relay commands and telemetry for, and retire the inspector. */
            attribute :>> description = "relay inspector";
        }
        action controlCaptureSequence : SoftwareFunction {
            doc /* Run the enclosure, cinch and despin sequence behind the inhibit chain (TH-003). */
            attribute :>> description = "control capture sequence";
        }
        action executeOnBoardSequences : SoftwareFunction {
            doc /* Run the on-board sequences the ground loads. */
            attribute :>> description = "execute on-board sequences";
        }
        action detectAndRecoverFaults : SoftwareFunction {
            doc /* Detect, isolate and recover faults at system level; call safe mode when recovery is exhausted. */
            attribute :>> description = "detect and recover faults";
        }
        action manageModes : SoftwareFunction {
            doc /* Run the mode machine: mode transitions on command and event, safe-mode entry and exit. */
            attribute :>> description = "manage modes";
        }
        action manageParametersAndImages : SoftwareFunction {
            doc /* Load and dump parameter tables, receive software images and select the boot slot. */
            attribute :>> description = "manage parameters and images";
        }
    }

    // ---------------------------------------------------------------- allocation definitions

    allocation def FunctionAllocation {
        doc /* Allocation of a mission function to the component that performs it. */
        end :>> source : Action;
        end :>> target : Part;
    }

    allocation def SoftwareDeployment {
        doc /* The deployment of the flight software: a software function onto the application
             * that realises it, an application onto the partition that hosts it, a partition
             * onto the computer that runs it. The three steps are its specialisations. */
    }
    allocation def SoftwareHosting :> SoftwareDeployment {
        doc /* A software function realised by one application. */
        end :>> source : SoftwareFunction;
        end :>> target : Application;
    }
    allocation def ApplicationDeployment :> SoftwareDeployment {
        doc /* An application hosted in one partition of the executive. */
        end :>> source : Application;
        end :>> target : Partition;
    }
    allocation def PartitionPlacement :> SoftwareDeployment {
        doc /* A partition placed on a flight computer; every partition is placed on both. */
        end :>> source : Partition;
        end :>> target : FlightComputer;
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
        doc /* Every leaf of missionFunctions allocated to exactly one component;
             * TethysAllocationQueries::UnallocatedFunctions must return no rows. */
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
        allocation routing : FunctionAllocation allocate missionFunctions.routeCommandsAndTelemetry to argent.cdh;
        allocation thrustArc : FunctionAllocation allocate missionFunctions.controlThrustArc to argent.sep;
        allocation battery : FunctionAllocation allocate missionFunctions.manageBatteryAndLoads to argent.eps;
        allocation heaters : FunctionAllocation allocate missionFunctions.regulateHeaterZones to argent.thermal;
        allocation spaceLink : FunctionAllocation allocate missionFunctions.manageSpaceLink to argent.telecom;
        allocation inspectorRelay : FunctionAllocation allocate missionFunctions.relayInspector to argent.cdh;
        allocation captureSequence : FunctionAllocation allocate missionFunctions.controlCaptureSequence to argent.captureSystem;
        allocation sequences : FunctionAllocation allocate missionFunctions.executeOnBoardSequences to argent.cdh;
        allocation faults : FunctionAllocation allocate missionFunctions.detectAndRecoverFaults to argent.cdh;
        allocation modes : FunctionAllocation allocate missionFunctions.manageModes to argent.cdh;
        allocation parameters : FunctionAllocation allocate missionFunctions.manageParametersAndImages to argent.cdh;
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

    part softwareDeployment {
        doc /* The deployment of the flight software of Argent: every software function to its
             * application, every application to its partition, every partition to the prime
             * and the redundant flight computer. The queries of TethysAllocationQueries prove
             * no function, application or partition is left out. */
        ref part avionics : CdhWithSoftware = argentSoftware.cdh;
        ref part fsw : ArgentFlightSoftware = argentSoftware.cdh.software;
        allocation hostRelativeState : SoftwareHosting allocate missionFunctions.estimateRelativeState to fsw.gnc;
        allocation hostFinalTargeting : SoftwareHosting allocate missionFunctions.planFinalTargeting to fsw.gnc;
        allocation hostAbort : SoftwareHosting allocate missionFunctions.abortCapture to fsw.autonomy;
        allocation hostRouting : SoftwareHosting allocate missionFunctions.routeCommandsAndTelemetry to fsw.cdh;
        allocation hostThrustArc : SoftwareHosting allocate missionFunctions.controlThrustArc to fsw.sepControl;
        allocation hostBattery : SoftwareHosting allocate missionFunctions.manageBatteryAndLoads to fsw.powerManagement;
        allocation hostHeaters : SoftwareHosting allocate missionFunctions.regulateHeaterZones to fsw.thermalControl;
        allocation hostSpaceLink : SoftwareHosting allocate missionFunctions.manageSpaceLink to fsw.telecom;
        allocation hostInspector : SoftwareHosting allocate missionFunctions.relayInspector to fsw.inspectorHandling;
        allocation hostCapture : SoftwareHosting allocate missionFunctions.controlCaptureSequence to fsw.captureControl;
        allocation hostSequences : SoftwareHosting allocate missionFunctions.executeOnBoardSequences to fsw.autonomy;
        allocation hostFaults : SoftwareHosting allocate missionFunctions.detectAndRecoverFaults to fsw.fdir;
        allocation hostModes : SoftwareHosting allocate missionFunctions.manageModes to fsw.modeManagement;
        allocation hostParameters : SoftwareHosting allocate missionFunctions.manageParametersAndImages to fsw.parameterBootUpdate;
        allocation deployCdh : ApplicationDeployment allocate fsw.cdh to fsw.executive.platformPartition;
        allocation deployFdir : ApplicationDeployment allocate fsw.fdir to fsw.executive.platformPartition;
        allocation deployModeManagement : ApplicationDeployment allocate fsw.modeManagement to fsw.executive.platformPartition;
        allocation deployParameterBootUpdate : ApplicationDeployment allocate fsw.parameterBootUpdate to fsw.executive.platformPartition;
        allocation deployGnc : ApplicationDeployment allocate fsw.gnc to fsw.executive.gncPartition;
        allocation deploySepControl : ApplicationDeployment allocate fsw.sepControl to fsw.executive.subsystemPartition;
        allocation deployPowerManagement : ApplicationDeployment allocate fsw.powerManagement to fsw.executive.subsystemPartition;
        allocation deployThermalControl : ApplicationDeployment allocate fsw.thermalControl to fsw.executive.subsystemPartition;
        allocation deployTelecom : ApplicationDeployment allocate fsw.telecom to fsw.executive.subsystemPartition;
        allocation deployAutonomy : ApplicationDeployment allocate fsw.autonomy to fsw.executive.autonomyPartition;
        allocation deployCaptureControl : ApplicationDeployment allocate fsw.captureControl to fsw.executive.autonomyPartition;
        allocation deployInspectorHandling : ApplicationDeployment allocate fsw.inspectorHandling to fsw.executive.payloadPartition;
        allocation placePlatformPartitionOnPrime : PartitionPlacement allocate fsw.executive.platformPartition to avionics.prime;
        allocation placePlatformPartitionOnRedundant : PartitionPlacement allocate fsw.executive.platformPartition to avionics.redundant;
        allocation placeGncPartitionOnPrime : PartitionPlacement allocate fsw.executive.gncPartition to avionics.prime;
        allocation placeGncPartitionOnRedundant : PartitionPlacement allocate fsw.executive.gncPartition to avionics.redundant;
        allocation placeSubsystemPartitionOnPrime : PartitionPlacement allocate fsw.executive.subsystemPartition to avionics.prime;
        allocation placeSubsystemPartitionOnRedundant : PartitionPlacement allocate fsw.executive.subsystemPartition to avionics.redundant;
        allocation placeAutonomyPartitionOnPrime : PartitionPlacement allocate fsw.executive.autonomyPartition to avionics.prime;
        allocation placeAutonomyPartitionOnRedundant : PartitionPlacement allocate fsw.executive.autonomyPartition to avionics.redundant;
        allocation placePayloadPartitionOnPrime : PartitionPlacement allocate fsw.executive.payloadPartition to avionics.prime;
        allocation placePayloadPartitionOnRedundant : PartitionPlacement allocate fsw.executive.payloadPartition to avionics.redundant;
    }

    view def AllocationMatrixView :> GridView {
        doc /* The allocation matrix: one row per allocated function or requirement, one column
             * per component. */
        filter @SysML::AllocationUsage;
    }

    view functionAllocationMatrix : AllocationMatrixView {
        doc /* Function → component matrix. */
        expose functionAllocations::*;
    }

    view softwareDeploymentMatrix : AllocationMatrixView {
        doc /* Software function → application → partition → computer matrix. */
        expose softwareDeployment::*;
    }
    view requirementAllocationMatrix : AllocationMatrixView {
        doc /* Requirement → component matrix. */
        expose requirementAllocations::*;
    }
}
