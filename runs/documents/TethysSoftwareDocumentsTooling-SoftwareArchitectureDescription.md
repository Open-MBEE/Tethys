# Argent flight software and Meridian Operations Suite architecture description

The architecture of the Argent flight software (Kestrel executive, core services, twelve applications, two flight computers, the AABP-1 bus) and of the Meridian Operations Suite, as TethysFlightSoftware, TethysFlightTiming, TethysGroundSoftware and TethysAllocations define it. Every table is a query over those packages; the budget verdicts are the model's own.

## Context

*Flight software components: layer, processor load, code and data size, criticality*

| name | type | layer | processorLoadMips | codeSize | dataSize | criticality |
| --- | --- | --- | --- | --- | --- | --- |
| boardSupport | TethysFlightSoftware::BoardSupportPackage | boardSupport | 30 | 1200000 \[B\] | 4000000 \[B\] | safetyCritical |
| executive | TethysFlightSoftware::KestrelExecutive | executive | 40 | 800000 \[B\] | 2000000 \[B\] | safetyCritical |
| softwareBus | TethysFlightSoftware::SoftwareBus |  |  |  |  |  |
| time | TethysFlightSoftware::TimeService | coreService | 8 | 300000 \[B\] | 1000000 \[B\] | missionCritical |
| events | TethysFlightSoftware::EventService | coreService | 8 | 300000 \[B\] | 1000000 \[B\] | missionCritical |
| tables | TethysFlightSoftware::TableService | coreService | 8 | 300000 \[B\] | 1000000 \[B\] | missionCritical |
| dataStore | TethysFlightSoftware::DataStoreService | coreService | 8 | 300000 \[B\] | 8000000 \[B\] | missionCritical |
| commandIngest | TethysFlightSoftware::CommandIngestService | coreService | 8 | 300000 \[B\] | 1000000 \[B\] | missionCritical |
| telemetryOutput | TethysFlightSoftware::TelemetryOutputService | coreService | 8 | 300000 \[B\] | 1000000 \[B\] | missionCritical |
| housekeeping | TethysFlightSoftware::HousekeepingService | coreService | 8 | 300000 \[B\] | 1000000 \[B\] | missionCritical |
| scheduler | TethysFlightSoftware::SchedulerService | coreService | 8 | 300000 \[B\] | 1000000 \[B\] | missionCritical |
| bootUpdate | TethysFlightSoftware::BootUpdateService | coreService | 8 | 300000 \[B\] | 1000000 \[B\] | missionCritical |
| cdh | TethysFlightSoftware::CdhApplication | application | 35 | 1000000 \[B\] | 4000000 \[B\] | missionCritical |
| gnc | TethysFlightSoftware::GncApplication | application | 90 | 2500000 \[B\] | 12000000 \[B\] | safetyCritical |
| sepControl | TethysFlightSoftware::SepControlApplication | application | 25 | 1000000 \[B\] | 4000000 \[B\] | missionCritical |
| powerManagement | TethysFlightSoftware::PowerManagementApplication | application | 15 | 1000000 \[B\] | 4000000 \[B\] | missionCritical |
| thermalControl | TethysFlightSoftware::ThermalControlApplication | application | 10 | 1000000 \[B\] | 4000000 \[B\] | missionCritical |
| telecom | TethysFlightSoftware::TelecomApplication | application | 20 | 1000000 \[B\] | 4000000 \[B\] | missionCritical |
| inspectorHandling | TethysFlightSoftware::InspectorHandlingApplication | application | 15 | 1000000 \[B\] | 4000000 \[B\] | missionCritical |
| captureControl | TethysFlightSoftware::CaptureControlApplication | application | 30 | 1000000 \[B\] | 4000000 \[B\] | safetyCritical |
| autonomy | TethysFlightSoftware::AutonomyApplication | application | 25 | 1500000 \[B\] | 4000000 \[B\] | safetyCritical |
| fdir | TethysFlightSoftware::FdirApplication | application | 20 | 1000000 \[B\] | 4000000 \[B\] | safetyCritical |
| modeManagement | TethysFlightSoftware::ModeManagementApplication | application | 10 | 1000000 \[B\] | 4000000 \[B\] | safetyCritical |
| parameterBootUpdate | TethysFlightSoftware::ParameterBootUpdateApplication | application | 5 | 1000000 \[B\] | 4000000 \[B\] | missionCritical |

*Meridian Operations Suite components: product and version*

| name | type | productName | version | documentation |
| --- | --- | --- | --- | --- |
| commandBuilder | TethysGroundSoftware::CommandBuilder | Meridian Forge | 3.2 |  |
| sequencer | TethysGroundSoftware::FlightRuleChecker | Meridian Warden | 2.5 |  |
| telemetryServer | TethysGroundSoftware::TelemetryServer | Meridian Lantern | 5.0 |  |
| passPlanner | TethysGroundSoftware::PassPlanner | Meridian Almanac | 1.9 |  |
| anomalyTracker | TethysGroundSoftware::AnomalyTracker | Meridian Ledger | 2.3 |  |
| proximityPlanner | TethysGroundSoftware::ProximityPlanner | Meridian Compass | 1.4 |  |
| ace | TethysMeridian::OperationsRole |  |  |  |
| gateway | TethysGroundSoftware::SuitePacketGateway |  |  |  |
| telemetryRelay | TethysGroundSoftware::GroundPacketRelay |  |  |  |
| commandRelay | TethysGroundSoftware::GroundPacketRelay |  |  |  |
| sequenceRelay | TethysGroundSoftware::GroundPacketRelay |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
| flightDynamicsTool | TethysGroundSoftware::FlightDynamicsTool | Meridian Sextant | 2.7 |  |
|  |  |  |  |  |
|  |  |  |  |  |
| dataArchive | TethysGroundSoftware::DataArchive | Meridian Vault | 4.1 |  |
|  |  |  |  |  |
|  |  |  |  |  |
| flatsat | TethysGroundSoftware::HardwareInTheLoopTestBed | Meridian Anvil | 2.0 |  |
| captureRig | TethysGroundSoftware::CaptureRigController | Meridian Capstan | 1.2 |  |
| dynamicsSimulator | TethysGroundSoftware::DynamicsSimulator | Meridian Orrery | 3.3 |  |
| trajectoryTool | TethysGroundSoftware::FlightSoftwareInTheLoopSimulator | Meridian Mirror | 6.1 |  |

## Decomposition

*Applications: rate, priority and active modes*

| name | type | rate | priority | activeModes |
| --- | --- | --- | --- | --- |
| cdh | TethysFlightSoftware::CdhApplication | 1 \[Hz\] | 2 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| gnc | TethysFlightSoftware::GncApplication | 16 \[Hz\] | 3 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| sepControl | TethysFlightSoftware::SepControlApplication | 1 \[Hz\] | 5 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| powerManagement | TethysFlightSoftware::PowerManagementApplication | 1 \[Hz\] | 4 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| thermalControl | TethysFlightSoftware::ThermalControlApplication | 1 \[Hz\] | 8 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| telecom | TethysFlightSoftware::TelecomApplication | 1 \[Hz\] | 6 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| inspectorHandling | TethysFlightSoftware::InspectorHandlingApplication | 1 \[Hz\] | 9 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| captureControl | TethysFlightSoftware::CaptureControlApplication | 16 \[Hz\] | 7 | proximityOperations, capture, despin |
| autonomy | TethysFlightSoftware::AutonomyApplication | 1 \[Hz\] | 11 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| fdir | TethysFlightSoftware::FdirApplication | 16 \[Hz\] | 1 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| modeManagement | TethysFlightSoftware::ModeManagementApplication | 1 \[Hz\] | 1 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| parameterBootUpdate | TethysFlightSoftware::ParameterBootUpdateApplication | 1 \[Hz\] | 12 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |

*Executive partitions: window, memory region, criticality, restart policy*

| name | windowDuration | memoryBudget | criticality | restartable |
| --- | --- | --- | --- | --- |
| platformPartition | 0.25 \[s\] | 256000000 \[B\] | safetyCritical | false |
| gncPartition | 0.25 \[s\] | 256000000 \[B\] | safetyCritical | true |
| subsystemPartition | 0.25 \[s\] | 256000000 \[B\] | missionCritical | true |
| autonomyPartition | 0.125 \[s\] | 128000000 \[B\] | safetyCritical | true |
| payloadPartition | 0.125 \[s\] | 128000000 \[B\] | nonCritical | true |

*Avionics with software: the two flight computers and their images*

| name | type | documentation |
| --- | --- | --- |
| flightComputers | TethysFlightSoftware::LoadedFlightComputer |  |
| prime | TethysFlightSoftware::LoadedFlightComputer |  |
| redundant | TethysFlightSoftware::LoadedFlightComputer |  |
| software | TethysFlightSoftware::ArgentFlightSoftware |  |
|  |  |  |

## Deployment and allocation

*Function hosting, application deployment and partition placement*

| name | type | documentation |
| --- | --- | --- |
| hostRelativeState | TethysAllocations::SoftwareHosting |  |
| hostFinalTargeting | TethysAllocations::SoftwareHosting |  |
| hostAbort | TethysAllocations::SoftwareHosting |  |
| hostRouting | TethysAllocations::SoftwareHosting |  |
| hostThrustArc | TethysAllocations::SoftwareHosting |  |
| hostBattery | TethysAllocations::SoftwareHosting |  |
| hostHeaters | TethysAllocations::SoftwareHosting |  |
| hostSpaceLink | TethysAllocations::SoftwareHosting |  |
| hostInspector | TethysAllocations::SoftwareHosting |  |
| hostCapture | TethysAllocations::SoftwareHosting |  |
| hostSequences | TethysAllocations::SoftwareHosting |  |
| hostFaults | TethysAllocations::SoftwareHosting |  |
| hostModes | TethysAllocations::SoftwareHosting |  |
| hostParameters | TethysAllocations::SoftwareHosting |  |
| deployCdh | TethysAllocations::ApplicationDeployment |  |
| deployFdir | TethysAllocations::ApplicationDeployment |  |
| deployModeManagement | TethysAllocations::ApplicationDeployment |  |
| deployParameterBootUpdate | TethysAllocations::ApplicationDeployment |  |
| deployGnc | TethysAllocations::ApplicationDeployment |  |
| deploySepControl | TethysAllocations::ApplicationDeployment |  |
| deployPowerManagement | TethysAllocations::ApplicationDeployment |  |
| deployThermalControl | TethysAllocations::ApplicationDeployment |  |
| deployTelecom | TethysAllocations::ApplicationDeployment |  |
| deployAutonomy | TethysAllocations::ApplicationDeployment |  |
| deployCaptureControl | TethysAllocations::ApplicationDeployment |  |
| deployInspectorHandling | TethysAllocations::ApplicationDeployment |  |
| placePlatformPartitionOnPrime | TethysAllocations::PartitionPlacement |  |
| placePlatformPartitionOnRedundant | TethysAllocations::PartitionPlacement |  |
| placeGncPartitionOnPrime | TethysAllocations::PartitionPlacement |  |
| placeGncPartitionOnRedundant | TethysAllocations::PartitionPlacement |  |
| placeSubsystemPartitionOnPrime | TethysAllocations::PartitionPlacement |  |
| placeSubsystemPartitionOnRedundant | TethysAllocations::PartitionPlacement |  |
| placeAutonomyPartitionOnPrime | TethysAllocations::PartitionPlacement |  |
| placeAutonomyPartitionOnRedundant | TethysAllocations::PartitionPlacement |  |
| placePayloadPartitionOnPrime | TethysAllocations::PartitionPlacement |  |
| placePayloadPartitionOnRedundant | TethysAllocations::PartitionPlacement |  |

## Timing and scheduling

*Rate groups*

| name | rate | period | activationsPerMajorFrame |
| --- | --- | --- | --- |
| rg16 | 16 \[Hz\] | 0.0625 \[s\] | 16 |
| rg8 | 8 \[Hz\] | 0.125 \[s\] | 8 |
| rg2 | 2 \[Hz\] | 0.5 \[s\] | 2 |
| rg1 | 1 \[Hz\] | 1 \[s\] | 1 |

*Scheduled tasks: period, worst-case execution time, deadline, utilisation, active modes*

| name | period | wcet | deadline | utilisation | activeModes |
| --- | --- | --- | --- | --- | --- |
| boardSupportTask | 0.0625 \[s\] | 0.001 \[s\] | 0.0625 \[s\] | 0.016 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| schedulerTask | 0.0625 \[s\] | 0.001 \[s\] | 0.0625 \[s\] | 0.016 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| fdirTask | 0.0625 \[s\] | 0.003 \[s\] | 0.0625 \[s\] | 0.048 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| modeManagementTask | 0.125 \[s\] | 0.003 \[s\] | 0.125 \[s\] | 0.024 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| cdhTask | 0.125 \[s\] | 0.004 \[s\] | 0.125 \[s\] | 0.032 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| commandIngestTask | 0.125 \[s\] | 0.002 \[s\] | 0.125 \[s\] | 0.016 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| telemetryOutputTask | 0.125 \[s\] | 0.003 \[s\] | 0.125 \[s\] | 0.024 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| telecomTask | 0.125 \[s\] | 0.005 \[s\] | 0.125 \[s\] | 0.04 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| housekeepingTask | 1 \[s\] | 0.003 \[s\] | 1 \[s\] | 0.003 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| timeTask | 1 \[s\] | 0.001 \[s\] | 1 \[s\] | 0.001 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| eventTask | 1 \[s\] | 0.001 \[s\] | 1 \[s\] | 0.001 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| tableTask | 1 \[s\] | 0.001 \[s\] | 1 \[s\] | 0.001 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| dataStoreTask | 1 \[s\] | 0.002 \[s\] | 1 \[s\] | 0.002 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| bootUpdateTask | 1 \[s\] | 0.001 \[s\] | 1 \[s\] | 0.001 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| parameterBootUpdateTask | 1 \[s\] | 0.004 \[s\] | 1 \[s\] | 0.004 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| gncTask | 0.0625 \[s\] | 0.012 \[s\] | 0.0625 \[s\] | 0.192 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| sepControlTask | 0.125 \[s\] | 0.005 \[s\] | 0.125 \[s\] | 0.04 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| powerManagementTask | 0.125 \[s\] | 0.005 \[s\] | 0.125 \[s\] | 0.04 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| thermalControlTask | 0.5 \[s\] | 0.006 \[s\] | 0.5 \[s\] | 0.012 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| autonomyTask | 0.125 \[s\] | 0.01 \[s\] | 0.125 \[s\] | 0.08 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |
| captureControlTask | 0.0625 \[s\] | 0.006 \[s\] | 0.0625 \[s\] | 0.096 | proximityOperations, capture, despin |
| inspectorHandlingTask | 0.5 \[s\] | 0.003 \[s\] | 0.5 \[s\] | 0.006 | earlyOperations, thrust, approach, stackThrust, disposal, coast, stackCoast, dockedPassive, proximityOperations, retreat, capture, despin, droHold, safe, abortHold |

## Processor, memory and bus budgets

*Modes the budgets are closed in*

| name | mode | documentation |
| --- | --- | --- |
| demandCoast | coast |  |
| demandThrust | thrust |  |
| demandCapture | capture |  |
| demandSafe | safe |  |

*Budget verdicts as the model evaluates them*

| path | kind | name | verdict |
| --- | --- | --- | --- |
| TethysFlightTiming::softwareProcessorBudget | constraint | processorCloses | holds |
| TethysFlightTiming::softwareProcessorBudget | constraint | memoryCloses | holds |
| TethysFlightTiming::softwareProcessorBudget | satisfaction |  | holds |
| TethysFlightTiming::softwareProcessorBudget | satisfaction |  | holds |
| TethysFlightTiming::softwareBusBudget | constraint | busCloses | violated |
| TethysFlightTiming::softwareBusBudget | satisfaction |  | violated |
| TethysFlightTiming::softwareBusBudget | satisfaction |  | violated |
| TethysFlightTiming::softwareBusBudgetCoast | constraint | busCloses | holds |
| TethysFlightTiming::softwareBusBudgetCoast | satisfaction |  | holds |
| TethysFlightTiming::softwareBusBudgetCoast | satisfaction |  | holds |
| TethysFlightTiming::faultDetectionBudget | constraint | latencyCloses | holds |
| TethysFlightTiming::faultDetectionBudget | satisfaction |  | holds |
| TethysFlightTiming::safeConfigurationBudget | constraint | latencyCloses | holds |
| TethysFlightTiming::safeConfigurationBudget | satisfaction |  | holds |
| TethysFlightTiming::commandDispatchBudget | constraint | latencyCloses | holds |
| TethysFlightTiming::commandDispatchBudget | satisfaction |  | holds |
| TethysFlightTiming::telemetrySampleBudget | constraint | latencyCloses | holds |
| TethysFlightTiming::telemetrySampleBudget | satisfaction |  | holds |
