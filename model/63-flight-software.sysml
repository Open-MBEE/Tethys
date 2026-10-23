// Flight software architecture. The layered software of Argent — board support, the
// Kestrel-class time- and space-partitioned executive, the core services, the twelve
// applications and the AABP-1 software bus — its partitions, its images, and its placement on
// the prime and redundant flight computers of TethysTugStructure. Function-to-application and
// application-to-partition-to-computer deployment is allocated in TethysAllocations.
package TethysFlightSoftware {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SequenceFunctions::*;
    private import QuantityCalculations::sum;
    private import TethysInterfaces::DataBusPort;
    private import TethysTug::*;
    private import TethysTugStructure::*;
    private import TethysIcds::SpacePacket;
    private import TethysIcds::TelemetryPacket;
    private import TethysIcds::CommandPacket;
    private import TethysIcds::PacketPort;
    private import TethysModes::CommandPort;
    private import TethysModes::OnBoardEvent;
    private import TethysFdir::FdirLevel;
    private import TethysFdir::FaultResponse;
    private import TethysFdir::FaultEvent;
    private import TethysFdir::InhibitChain;
    private import TethysMission::Mission;
    private import TethysSystem::TethysFlightSegment;
    private import TethysSystem::TethysLaunchSegment;
    private import TethysSystem::TethysGroundSegment;
    private import TethysSystem::tethysSystem;

    // ---- 1. Vocabulary -------------------------------------------------------------------------
    enum def SoftwareLayer {
        doc /* The four layers of the flight software, bottom up: the board support package
             * that owns the hardware, the executive that owns time and memory, the core
             * services every application uses, and the applications themselves. */
        boardSupport; executive; coreService; application;
    }
    enum def SchedulingPolicy {
        doc /* How processor time is handed out: fixed windows in a repeating major frame
             * between partitions, fixed-priority pre-emption between the tasks inside one. */
        cyclicFixedWindows; fixedPriorityPreemptive;
    }
    enum def SoftwareCriticality {
        doc /* The criticality class of a software component: safety-critical when its failure
             * can lead to a hazard of the hazard log, mission-critical when it can lose the
             * mission, non-critical otherwise. */
        safetyCritical; missionCritical; nonCritical;
    }

    // ---- 2. Items the software exchanges -------------------------------------------------------
    item def BusMessage :> SpacePacket {
        doc /* A message on the AABP-1 software bus: a space packet whose application id is
             * the topic, published by one component and delivered to every subscriber. */
        attribute period : DurationValue;
    }
    item def TimeTick {
        doc /* The executive's time reference as the time service publishes it. */
        attribute missionElapsedTime : DurationValue;
    }
    item def SoftwareEvent :> OnBoardEvent {
        doc /* An event raised by a software component: where it was detected and whether the
             * event service forwards it to the fault application. */
        attribute level : FdirLevel;
        attribute isFault : Boolean;
    }
    item def ParameterTable {
        doc /* A table of parameters: a numbered block the table service loads, validates and
             * hands to the application that owns it. */
        attribute tableId : Natural;
        attribute size : StorageCapacityValue;
    }
    item def DataProduct {
        doc /* A file in the data store: its size, the downlink queue it joins and how long the
             * store keeps it after downlink. */
        attribute size : StorageCapacityValue;
        attribute downlinkPriority : Natural;
        attribute retention : DurationValue;
    }
    item def ImageSegment {
        doc /* One uplinked segment of a software image, written to an inactive image slot. */
        attribute offset : StorageCapacityValue;
        attribute length : StorageCapacityValue;
    }

    // ---- 3. Ports and the software bus ---------------------------------------------------------
    port def BusPort {
        doc /* A node on the AABP-1 software bus: messages published out, subscriptions in. */
        out item publish : BusMessage;
        in item subscribe : BusMessage;
    }
    port def TimePort {
        doc /* The time service's output: the executive's time reference. */
        out item tick : TimeTick;
    }
    port def EventPort {
        doc /* The event service's input: events raised by any component. */
        in item raised : SoftwareEvent;
    }
    port def TablePort {
        doc /* Parameter tables loaded into, or dumped from, the component that owns them. */
        inout item table : ParameterTable;
    }
    port def ProductPort {
        doc /* Data products on their way into the data store. */
        out item product : DataProduct;
    }
    port def CommandIngestPort {
        doc /* Telecommand packets entering the software from the space link. */
        in item command : CommandPacket;
    }
    port def TelemetryOutputPort {
        doc /* Telemetry packets leaving the software for the space link. */
        out item telemetry : TelemetryPacket;
    }
    port def FaultPort {
        doc /* Fault events entering the fault application. */
        in item fault : FaultEvent;
    }
    port def UpdatePort {
        doc /* Image segments entering the boot and update service. */
        in item segment : ImageSegment;
    }

    part def SoftwareBus {
        doc /* The AABP-1 software bus: the publish-subscribe message bus of the flight
             * software. Every component attaches through one BusPort; the bus carries
             * messages no longer than the on-board data bus packet, so a message crosses to a
             * remote terminal unchanged. */
        attribute designation : String = "AABP-1";
        attribute maximumMessageLength : StorageCapacityValue = 1024.0 [B];
        attribute topicCount : Natural = 256;
        attribute queueDepth : Natural = 16;
        port hub : ~BusPort;
    }
    interface def BusAttachment {
        doc /* The attachment of one software component to the software bus. */
        end port node : BusPort;
        end port bus : ~BusPort;
        flow of BusMessage from node.publish to bus.publish;
        flow of BusMessage from bus.subscribe to node.subscribe;
    }

    // ---- 4. Components: the common shape and the four layers -----------------------------------
    part def SoftwareComponent {
        doc /* A software component of any layer: its code and data footprint, its share of
             * the processor load the processor budget carries, its criticality class and its
             * attachment to the software bus. */
        attribute layer : SoftwareLayer;
        attribute codeSize : StorageCapacityValue;
        attribute dataSize : StorageCapacityValue;
        attribute processorLoadMips : Real;
        attribute criticality : SoftwareCriticality default = SoftwareCriticality::missionCritical;
        port bus : BusPort;
    }

    part def DeviceDriver {
        doc /* A driver of the board support package for one device on the flight computer or
             * on the on-board data bus. */
        attribute device : String;
    }
    part def BoardSupportPackage :> SoftwareComponent {
        doc /* The board support package: processor start-up, the memory map, the watchdog,
             * the boot read-only memory, error-correcting memory scrubbing and the drivers for
             * the bus controller, the remote interface units, the mass memories and the
             * transponder. Its data bus port is the software's end of the on-board data bus. */
        attribute :>> layer = SoftwareLayer::boardSupport;
        attribute :>> codeSize = 1.2e6 [B];
        attribute :>> dataSize = 4.0e6 [B];
        attribute :>> processorLoadMips = 30.0;
        attribute :>> criticality = SoftwareCriticality::safetyCritical;
        attribute watchdogPeriod : DurationValue = 2.0 [s];
        attribute scrubPeriod : DurationValue = 60.0 [s];
        attribute bootRomSize : StorageCapacityValue = 5.12e5 [B];
        port deviceBus : DataBusPort;
        part busControllerDriver : DeviceDriver { attribute :>> device = "bus controller"; }
        part remoteInterfaceUnitDriver : DeviceDriver { attribute :>> device = "remote interface unit"; }
        part massMemoryDriver : DeviceDriver { attribute :>> device = "mass memory"; }
        part transponderDriver : DeviceDriver { attribute :>> device = "transponder"; }
    }

    part def Partition {
        doc /* A time and space partition of the executive: a fixed window in every major frame
             * and a fixed memory region no other partition can address. A partition restarts
             * on its own when one of its applications faults, unless it is the platform
             * partition, whose fault resets the computer. */
        attribute windowDuration : DurationValue;
        attribute memoryBudget : StorageCapacityValue;
        attribute criticality : SoftwareCriticality;
        attribute restartable : Boolean default = true;
    }
    part def KestrelExecutive :> SoftwareComponent {
        doc /* The Kestrel-class executive: a time- and space-partitioned kernel that runs the
             * partitions in fixed windows of a major frame, pre-empts by fixed priority inside
             * a partition, and allocates no memory after initialisation. The minor frame is
             * the polling period of the on-board data bus. */
        attribute :>> layer = SoftwareLayer::executive;
        attribute :>> codeSize = 0.8e6 [B];
        attribute :>> dataSize = 2.0e6 [B];
        attribute :>> processorLoadMips = 40.0;
        attribute :>> criticality = SoftwareCriticality::safetyCritical;
        attribute majorFramePeriod : DurationValue = 1.0 [s];
        attribute minorFramePeriod : DurationValue = 0.125 [s];
        attribute minorFramesPerMajorFrame : Natural = 8;
        attribute partitionPolicy : SchedulingPolicy = SchedulingPolicy::cyclicFixedWindows;
        attribute taskPolicy : SchedulingPolicy = SchedulingPolicy::fixedPriorityPreemptive;
        attribute heapAfterInitialisation : Boolean = false;
        attribute scheduledWindows : DurationValue;
        attribute partitionMemory : StorageCapacityValue;
        assert constraint framesDivide { majorFramePeriod == minorFramePeriod * minorFramesPerMajorFrame }
        assert constraint windowsFitMajorFrame { scheduledWindows <= majorFramePeriod }
        assert constraint staticMemoryOnly { not heapAfterInitialisation }
    }

    part def CoreService :> SoftwareComponent {
        doc /* A core service: a component every application uses, resident in the platform
             * partition. */
        attribute :>> layer = SoftwareLayer::coreService;
        attribute :>> codeSize default = 0.3e6 [B];
        attribute :>> dataSize default = 1.0e6 [B];
        attribute :>> processorLoadMips default = 8.0;
    }
    part def TimeService :> CoreService {
        doc /* Keeps mission elapsed time from the oscillator and the ground time correlation
             * and publishes the tick every minor frame. */
        attribute resolution : DurationValue = 1.0e-6 [s];
        port time : TimePort;
    }
    part def EventService :> CoreService {
        doc /* Collects the events every component raises, logs them and forwards faults to
             * the fault application. */
        attribute logDepth : Natural = 4096;
        port events : EventPort;
    }
    part def TableService :> CoreService {
        doc /* Loads, validates, dumps and hands out the parameter tables. */
        attribute tableCount : Natural = 64;
        port tables : TablePort;
    }
    part def DataStoreService :> CoreService {
        doc /* The file and data store over the mass memories: products in priority downlink
             * queues, kept for the retention period after downlink. Its capacity is the
             * storage of the avionics it runs on. */
        attribute :>> dataSize = 8.0e6 [B];
        attribute capacity : StorageCapacityValue = argentDesign.cdh.storageCapacity;
        attribute downlinkQueues : Natural = 4;
        attribute defaultRetention : DurationValue = 1209600.0 [s];
        port products : ~ProductPort;
        assert constraint capacityWithinMassMemory { capacity <= argentDesign.cdh.storageCapacity }
    }
    part def CommandIngestService :> CoreService {
        doc /* Accepts telecommand packets from the space link, checks and acknowledges them,
             * and publishes each to the application that owns its application id. */
        attribute maximumPacketLength : StorageCapacityValue = 65542.0 [B];
        port uplink : CommandIngestPort;
    }
    part def TelemetryOutputService :> CoreService {
        doc /* Builds the downlink from the telemetry packets the applications publish, in
             * real time and from the data store. */
        port downlink : TelemetryOutputPort;
    }
    part def HousekeepingService :> CoreService {
        doc /* Samples every component's housekeeping each major frame into the housekeeping
             * packet of the space-ground packet interface. */
        attribute samplingPeriod : DurationValue = 1.0 [s];
        attribute housekeepingApid : Natural = 1;
    }
    part def SchedulerService :> CoreService {
        doc /* Runs the time-tagged and relative-time command schedule the ground loads. */
        attribute scheduleSlots : Natural = 2048;
        port schedule : TablePort;
    }
    part def BootUpdateService :> CoreService {
        doc /* Boots the computer from the selected image slot, receives image segments into
             * the inactive slot, checks them and swaps slots on command. */
        attribute imageSlots : Natural = 2;
        port update : UpdatePort;
    }

    part def Application :> SoftwareComponent {
        doc /* A flight software application: the rate it runs at, its priority within its
             * partition, and the flight modes in which it is active. */
        attribute :>> layer = SoftwareLayer::application;
        attribute :>> codeSize default = 1.0e6 [B];
        attribute :>> dataSize default = 4.0e6 [B];
        attribute :>> processorLoadMips default = 20.0;
        attribute rate : FrequencyValue default = 1.0 [Hz];
        attribute priority : Natural default = 10;
        attribute activeModes : TugMode[*] default = allFlightModes;
        port products : ProductPort;
        port events : ~EventPort;
    }
    part def CdhApplication :> Application {
        doc /* Command and data handling: routes the telecommands the command ingest service
             * accepts, packetises the telemetry and drives the on-board data bus through the
             * board support package. */
        attribute :>> processorLoadMips = 35.0;
        attribute :>> priority = 2;
        port routedCommands : CommandIngestPort;
        port packets : TelemetryOutputPort;
        port dataBus : DataBusPort;
    }
    part def GncApplication :> Application {
        doc /* Guidance, navigation and control: attitude determination and control, relative
             * state estimation and the final-targeting burn, safety-critical because the
             * targeting burn is the Earth-impact control of the hazard log. */
        attribute :>> codeSize = 2.5e6 [B];
        attribute :>> dataSize = 12.0e6 [B];
        attribute :>> processorLoadMips = 90.0;
        attribute :>> criticality = SoftwareCriticality::safetyCritical;
        attribute :>> rate = 16.0 [Hz];
        attribute :>> priority = 3;
        port sensorsAndActuators : DataBusPort;
    }
    part def SepControlApplication :> Application {
        doc /* Solar electric propulsion control: thruster start, throttle and stop, power
             * processing unit management and the thrust-arc sequence. */
        attribute :>> processorLoadMips = 25.0;
        attribute :>> priority = 5;
        attribute thrusterStrings : Natural = 4;
        port thrusters : DataBusPort;
    }
    part def PowerManagementApplication :> Application {
        doc /* Power management: battery state of charge, array regulation and load shedding
             * below the battery threshold the fault application sets. */
        attribute :>> processorLoadMips = 15.0;
        attribute :>> priority = 4;
        port powerUnits : DataBusPort;
    }
    part def ThermalControlApplication :> Application {
        doc /* Thermal control: heater zones against their set points from the thermistors the
             * remote interface units gather. */
        attribute :>> processorLoadMips = 10.0;
        attribute :>> priority = 8;
        attribute heaterZones : Natural = 24;
        port heaters : DataBusPort;
    }
    part def TelecomApplication :> Application {
        doc /* Telecommunications: transponder configuration, rate and band selection and the
             * frame layer under the space-ground packet interface, whose flight side is this
             * application's space link port. */
        attribute :>> processorLoadMips = 20.0;
        attribute :>> priority = 6;
        port transponder : DataBusPort;
        port spaceLink : PacketPort;
    }
    part def InspectorHandlingApplication :> Application {
        doc /* Inspector handling: checkout, release, the proximity relay of the inspector's
             * commands and telemetry, and retirement. */
        attribute :>> processorLoadMips = 15.0;
        attribute :>> priority = 9;
        port inspectorCommands : ~CommandPort;
        port relay : DataBusPort;
    }
    part def CaptureControlApplication :> Application {
        doc /* Capture system control: the enclosure sequence, the cinch inhibit chain and the
             * despin, safety-critical because the cinch is the hazardous function of the
             * inhibit chain. */
        attribute :>> processorLoadMips = 30.0;
        attribute :>> criticality = SoftwareCriticality::safetyCritical;
        attribute :>> rate = 16.0 [Hz];
        attribute :>> priority = 7;
        attribute :>> activeModes = (TugMode::proximityOperations, TugMode::capture, TugMode::despin);
        ref part inhibitChain : InhibitChain;
        port mechanisms : DataBusPort;
    }
    part def AutonomyApplication :> Application {
        doc /* The autonomy and sequencing engine: runs the on-board sequences the ground
             * loads as tables and the autonomous abort-to-hold-point sequence. */
        attribute :>> codeSize = 1.5e6 [B];
        attribute :>> processorLoadMips = 25.0;
        attribute :>> criticality = SoftwareCriticality::safetyCritical;
        attribute :>> priority = 11;
        attribute concurrentSequences : Natural = 8;
        port sequences : TablePort;
    }
    part def FdirApplication :> Application {
        doc /* Fault detection, isolation and recovery: the system-level supervisor of the FDIR
             * model realised in software, taking the fault events the event service forwards
             * and issuing the responses of the fault vocabulary. */
        attribute :>> processorLoadMips = 20.0;
        attribute :>> criticality = SoftwareCriticality::safetyCritical;
        attribute :>> priority = 1;
        attribute :>> rate = 16.0 [Hz];
        attribute level : FdirLevel = FdirLevel::system;
        attribute responses : FaultResponse[*] = (FaultResponse::retry, FaultResponse::switchover,
            FaultResponse::loadShed, FaultResponse::safeMode, FaultResponse::abortReturn);
        port faults : FaultPort;
    }
    part def ModeManagementApplication :> Application {
        doc /* Mode and safe-mode management: the tug mode machine realised in software, taking
             * ground commands and on-board events on the command port and holding the current
             * mode every other application reads. */
        attribute :>> processorLoadMips = 10.0;
        attribute :>> criticality = SoftwareCriticality::safetyCritical;
        attribute :>> priority = 1;
        attribute initialMode : TugMode = TugMode::launch;
        attribute safeMode : TugMode = TugMode::safe;
        port command : CommandPort;
    }
    part def ParameterBootUpdateApplication :> Application {
        doc /* Parameter, boot and image update management: the ground's view of the table
             * service and the boot and update service — table loads and dumps, image uplink
             * and slot selection. */
        attribute :>> processorLoadMips = 5.0;
        attribute :>> priority = 12;
        port tables : TablePort;
        port update : UpdatePort;
    }

    // ---- 5. Images -----------------------------------------------------------------------------
    part def SoftwareImage {
        doc /* A loadable software image: the components it contains, its size and the
             * checksum the boot and update service checks before a slot swap. */
        attribute version : String;
        attribute imageSize : StorageCapacityValue;
        attribute checksumAlgorithm : String = "CRC-32";
        ref part contents : SoftwareComponent[*];
    }

    // ---- 6. The flight software of Argent ------------------------------------------------------
    part def ArgentFlightSoftware {
        doc /* The flight software of Argent as one product: the four layers, the software bus
             * they attach to, the partitions of the executive, and the two images built from
             * the components. Its load and footprint are checked against the figures the
             * processor budget carries for the flight computer. */
        part boardSupport : BoardSupportPackage;
        part executive : KestrelExecutive {
            part platformPartition : Partition {
                attribute :>> windowDuration = 0.250 [s];
                attribute :>> memoryBudget = 2.56e8 [B];
                attribute :>> criticality = SoftwareCriticality::safetyCritical;
                attribute :>> restartable = false;
            }
            part gncPartition : Partition {
                attribute :>> windowDuration = 0.250 [s];
                attribute :>> memoryBudget = 2.56e8 [B];
                attribute :>> criticality = SoftwareCriticality::safetyCritical;
            }
            part subsystemPartition : Partition {
                attribute :>> windowDuration = 0.250 [s];
                attribute :>> memoryBudget = 2.56e8 [B];
                attribute :>> criticality = SoftwareCriticality::missionCritical;
            }
            part autonomyPartition : Partition {
                attribute :>> windowDuration = 0.125 [s];
                attribute :>> memoryBudget = 1.28e8 [B];
                attribute :>> criticality = SoftwareCriticality::safetyCritical;
            }
            part payloadPartition : Partition {
                attribute :>> windowDuration = 0.125 [s];
                attribute :>> memoryBudget = 1.28e8 [B];
                attribute :>> criticality = SoftwareCriticality::nonCritical;
            }
            attribute :>> scheduledWindows = platformPartition.windowDuration
                + gncPartition.windowDuration + subsystemPartition.windowDuration
                + autonomyPartition.windowDuration + payloadPartition.windowDuration;
            attribute :>> partitionMemory = platformPartition.memoryBudget
                + gncPartition.memoryBudget + subsystemPartition.memoryBudget
                + autonomyPartition.memoryBudget + payloadPartition.memoryBudget;
        }
        part softwareBus : SoftwareBus;

        part time : TimeService;
        part events : EventService;
        part tables : TableService;
        part dataStore : DataStoreService;
        part commandIngest : CommandIngestService;
        part telemetryOutput : TelemetryOutputService;
        part housekeeping : HousekeepingService;
        part scheduler : SchedulerService;
        part bootUpdate : BootUpdateService;

        part cdh : CdhApplication;
        part gnc : GncApplication;
        part sepControl : SepControlApplication;
        part powerManagement : PowerManagementApplication;
        part thermalControl : ThermalControlApplication;
        part telecom : TelecomApplication;
        part inspectorHandling : InspectorHandlingApplication;
        part captureControl : CaptureControlApplication;
        part autonomy : AutonomyApplication;
        part fdir : FdirApplication;
        part modeManagement : ModeManagementApplication;
        part parameterBootUpdate : ParameterBootUpdateApplication;

        part components : SoftwareComponent[23] = (boardSupport, executive,
            time, events, tables, dataStore, commandIngest, telemetryOutput, housekeeping,
            scheduler, bootUpdate,
            cdh, gnc, sepControl, powerManagement, thermalControl, telecom, inspectorHandling,
            captureControl, autonomy, fdir, modeManagement, parameterBootUpdate);

        attribute processorLoadMips : Real = RealFunctions::sum(components.processorLoadMips);
        attribute codeSize : StorageCapacityValue = sum(components.codeSize);
        attribute dataSize : StorageCapacityValue = sum(components.dataSize);
        attribute budgetedLoadMips : Real = head(argentDesign.cdh.flightComputers.processorLoadMips);
        attribute budgetedMemory : StorageCapacityValue = head(argentDesign.cdh.flightComputers.memoryAllocated);
        assert constraint loadWithinBudgetedLoad { processorLoadMips <= budgetedLoadMips }
        assert constraint footprintWithinBudgetedMemory { codeSize + dataSize <= budgetedMemory }
        assert constraint partitionsWithinBudgetedMemory { executive.partitionMemory <= budgetedMemory }

        part flightImage : SoftwareImage {
            doc /* The full image: every component. */
            attribute :>> version = "1.0";
            attribute :>> imageSize = codeSize;
            ref part :>> contents = components;
        }
        part safeImage : SoftwareImage {
            doc /* The safe-mode image: the platform and the applications that keep the tug
                 * power-positive, thermally safe and in contact with the ground. */
            attribute :>> version = "1.0-safe";
            attribute :>> imageSize = sum(contents.codeSize);
            ref part :>> contents = (boardSupport, executive, time, events, tables, dataStore,
                commandIngest, telemetryOutput, housekeeping, scheduler, bootUpdate, cdh,
                powerManagement, thermalControl, telecom, fdir, modeManagement, parameterBootUpdate);
        }

        // the space link: telecommands in through command ingest, telemetry out through
        // telemetry output, over the flight side of the packet interface
        flow of CommandPacket from telecom.spaceLink.command to commandIngest.uplink.command;
        flow of CommandPacket from commandIngest.uplink.command to cdh.routedCommands.command;
        flow of TelemetryPacket from cdh.packets.telemetry to telemetryOutput.downlink.telemetry;
        flow of TelemetryPacket from telemetryOutput.downlink.telemetry to telecom.spaceLink.telemetry;
        // products into the data store; events into the event service; faults onward
        flow of DataProduct from gnc.products.product to dataStore.products.product;
        flow of DataProduct from inspectorHandling.products.product to dataStore.products.product;
        flow of SoftwareEvent from gnc.events.raised to events.events.raised;
        // the on-board data bus is driven through the board support package
        bind cdh.dataBus = boardSupport.deviceBus;

        interface boardSupportOnBus : BusAttachment connect boardSupport.bus to softwareBus.hub;
        interface executiveOnBus : BusAttachment connect executive.bus to softwareBus.hub;
        interface timeOnBus : BusAttachment connect time.bus to softwareBus.hub;
        interface eventsOnBus : BusAttachment connect events.bus to softwareBus.hub;
        interface tablesOnBus : BusAttachment connect tables.bus to softwareBus.hub;
        interface dataStoreOnBus : BusAttachment connect dataStore.bus to softwareBus.hub;
        interface commandIngestOnBus : BusAttachment connect commandIngest.bus to softwareBus.hub;
        interface telemetryOutputOnBus : BusAttachment connect telemetryOutput.bus to softwareBus.hub;
        interface housekeepingOnBus : BusAttachment connect housekeeping.bus to softwareBus.hub;
        interface schedulerOnBus : BusAttachment connect scheduler.bus to softwareBus.hub;
        interface bootUpdateOnBus : BusAttachment connect bootUpdate.bus to softwareBus.hub;
        interface cdhOnBus : BusAttachment connect cdh.bus to softwareBus.hub;
        interface gncOnBus : BusAttachment connect gnc.bus to softwareBus.hub;
        interface sepControlOnBus : BusAttachment connect sepControl.bus to softwareBus.hub;
        interface powerManagementOnBus : BusAttachment connect powerManagement.bus to softwareBus.hub;
        interface thermalControlOnBus : BusAttachment connect thermalControl.bus to softwareBus.hub;
        interface telecomOnBus : BusAttachment connect telecom.bus to softwareBus.hub;
        interface inspectorHandlingOnBus : BusAttachment connect inspectorHandling.bus to softwareBus.hub;
        interface captureControlOnBus : BusAttachment connect captureControl.bus to softwareBus.hub;
        interface autonomyOnBus : BusAttachment connect autonomy.bus to softwareBus.hub;
        interface fdirOnBus : BusAttachment connect fdir.bus to softwareBus.hub;
        interface modeManagementOnBus : BusAttachment connect modeManagement.bus to softwareBus.hub;
        interface parameterBootUpdateOnBus : BusAttachment connect parameterBootUpdate.bus to softwareBus.hub;
    }

    // ---- 7. Placement on the avionics --------------------------------------------------------
    part def LoadedFlightComputer :> FlightComputer {
        doc /* A flight computer with the software image loaded in its active slot. */
        part image : SoftwareImage;
    }
    part def CdhWithSoftware :> ArgentAvionics {
        doc /* The command and data handling subsystem with its flight software: the same
             * image in the prime and the redundant computer, cross-strapped so that the
             * redundant one takes over on a watchdog trip; the prime computer's data bus port
             * is the subsystem's bus controller. */
        part :>> flightComputers : LoadedFlightComputer[2];
        part prime : LoadedFlightComputer[1] :> flightComputers {
            part :>> image = software.flightImage;
        }
        part redundant : LoadedFlightComputer[1] :> flightComputers {
            part :>> image = software.flightImage;
        }
        part software : ArgentFlightSoftware;
        connect prime.crossStrap to redundant.crossStrap;
        bind prime.bus = busController;
    }
    part def SoftwareTug :> ArgentTug {
        doc /* Argent with the flight software in its command and data handling subsystem. */
        part :>> cdh : CdhWithSoftware;
    }
    part argentSoftware : SoftwareTug {
        doc /* The Phase B design of Argent with its flight software loaded. */
    }
    part def SoftwareFlightSegment :> TethysFlightSegment {
        doc /* The flight segment whose tug carries the flight software. */
        part :>> tug : SoftwareTug = argentSoftware;
    }
    part tethysSoftwareSystem : Mission {
        doc /* The Tethys Retrieval mission with the flight software in place on the tug: the
             * same class, duration, launch and ground segments as tethysSystem, and a flight
             * segment whose tug is argentSoftware. The interfaces between the segments stay
             * those stated on tethysSystem. */
        attribute :>> missionClass = tethysSystem.missionClass;
        attribute :>> nominalDuration = tethysSystem.nominalDuration;
        part flight : SoftwareFlightSegment;
        part launch : TethysLaunchSegment = tethysSystem.launch;
        part ground : TethysGroundSegment = tethysSystem.ground;
    }
}
