# WP-SW-1 coverage — flight software architecture and its deployment

Files: `model/63-flight-software.sysml` (`TethysFlightSoftware`, mission tier); backbone
additions in `model/10-system.sysml`, `model/31-tug-structure.sysml`,
`model/87-allocations.sysml` (`TethysAllocations`), `model/87-allocations-tooling.sysml`
(`TethysAllocationQueries`) and `model/99-house-rules.sysml`. Runs recorded with the pinned
OpenSysML `5cd37f288` (`runs/tool-version.txt`); every command below is a `run` line in
`scripts/runs.sh` and its output is in `runs/<name>.txt`. No OpenSysML or pilot defect was hit
in this package, so there is no `docs/findings/WP-SW-1.md` and no probe.

Result key as in `WP-J.md`: **sat**, **sat (finding)**, **partial**, **open**.

## Scope rows

| Row | File : element | Proving command | Result |
| --- | --- | --- | --- |
| SW-001 board support package | `63` : `BoardSupportPackage` (`watchdogPeriod`, `scrubPeriod`, `bootRomSize`, `deviceBus : DataBusPort`, four `DeviceDriver` parts for the bus controller, remote interface unit, mass memory and transponder); `SoftwareComponent` (`layer`, `codeSize`, `dataSize`, `processorLoadMips`, `criticality`, `bus : BusPort`); `SoftwareLayer` | `validate`, `sw-fsw-structure` | sat |
| SW-002 real-time executive | `63` : `KestrelExecutive` (`majorFramePeriod`, `minorFramePeriod`, `minorFramesPerMajorFrame`, `partitionPolicy`/`taskPolicy : SchedulingPolicy`, `heapAfterInitialisation`, `scheduledWindows`, `partitionMemory`; asserted `framesDivide`, `windowsFitMajorFrame`, `staticMemoryOnly`); `SchedulerService` (`maximumTasks`, `tickPeriod`) | `validate`, `sw-fsw-structure` (`scheduledWindows` = `majorFramePeriod` = 1.0 s) | sat |
| SW-006 file and data management | `63` : `DataStoreService` (`capacity` bound to `argentDesign.cdh.storageCapacity`, `downlinkQueues`, `defaultRetention`, asserted `capacityWithinMassMemory`); `DataProduct` (`priority`, `retention`); `ProductPort`; `flow of DataProduct` from `gnc` and `inspectorHandling` into `dataStore` | `validate`, `sw-fsw-structure` (`dataStore.capacity` = 4.0e12 B) | sat |
| SW-012 partitioning / fault containment | `63` : `Partition` (`windowDuration`, `memoryBudget`, `criticality`, `restartable`); five partitions of `ArgentFlightSoftware::executive`; `87` : `ApplicationDeployment` (every application in exactly one partition), `KestrelExecutive::windowsFitMajorFrame`, `ArgentFlightSoftware::partitionsWithinBudgetedMemory` | `sw-deployment-queries` (`UnallocatedApplications` 0 rows, `AllocatedApplications` 12 rows), `sw-deployment-matrix` | sat |
| SW-014 redundancy management | `31` : `FlightComputer::crossStrap`, `imageSlots`; `63` : `LoadedFlightComputer::image`, `CdhWithSoftware::prime`/`redundant` (same `flightImage`, `connect prime.crossStrap to redundant.crossStrap`, `bind prime.bus = busController`); `87` : `PartitionPlacement` on both computers | `sw-fsw-structure` (`prime.image.designation` = `redundant.image.designation`), `sw-deployment-queries` (`AllocatedPartitions` 5 rows) | partial — the fail-over state machine belongs to the application behaviour package |
| SW-036 software-to-processor allocation | `87` : `SoftwareDeployment` and its three steps `SoftwareHosting` (function → application), `ApplicationDeployment` (application → partition), `PartitionPlacement` (partition → computer); `softwareDeployment` (14 + 12 + 10 allocations); `softwareDeploymentMatrix`; `87-tooling` : `UnallocatedApplications`, `AllocatedApplications`, `UnallocatedPartitions`, `AllocatedPartitions` | `sw-deployment-queries` (all `Unallocated*` 0 rows, `UnallocatedFunctions` still 0 rows), `sw-deployment-matrix` | sat |

## Backbone rows

| Row | File : element | Proving command | Result |
| --- | --- | --- | --- |
| SW-241 flight software attached to C&DH | `05` cannot import `63` (a lower-numbered file does not resolve a higher-numbered package on the pilot), so `63` specialises instead: `CdhWithSoftware :> ArgentAvionics` (which is `CommandAndDataHandling` in `31`) owns `software : ArgentFlightSoftware`; `SoftwareTug :> ArgentTug` redefines `cdh : CdhWithSoftware`; `argentSoftware : SoftwareTug` | `validate`, `pilot-mission` | sat |
| SW-245 `FlightComputer` image and bus ports | `31` : `FlightComputer::imageSlots`, `bus : DataBusPort`, `crossStrap : DataBusPort`; `63` : `LoadedFlightComputer::image : SoftwareImage`. `RemoteInterfaceUnit` register-map attributes were not needed by this package | `validate`, `instantiate-system` | sat |
| SW-252 `SoftwareDeployment` and new leaves | `87` : `SoftwareDeployment`, `SoftwareHosting`, `ApplicationDeployment`, `PartitionPlacement`; eleven new `SoftwareFunction` leaves under `missionFunctions` (`routeCommandsAndTelemetry`, `controlThrustArc`, `manageBatteryAndLoads`, `regulateHeaterZones`, `manageSpaceLink`, `relayInspector`, `controlCaptureSequence`, `executeOnBoardSequences`, `detectAndRecoverFaults`, `manageModes`, `manageParametersAndImages`) each hosted by one application; the three existing leaves (`estimateRelativeState`, `planFinalTargeting`, `abortCapture`) hosted too | `sw-deployment-matrix`, `allocations-queries` (`UnallocatedFunctions` 0 rows) | sat |
| SW-254 every application allocated | `99` : `allocationUsageIsTyped` (every allocation usage carries an allocation def, so the chain is explicit); `87-tooling` : `UnallocatedApplications`, `UnallocatedPartitions` pinned at 0 rows beside `UnallocatedFunctions` | `house-rules` (0 violations), `sw-deployment-queries` | sat |
| SW-255 documentation | this file, `docs/coverage-matrix.md` § 7, `README.md` layout table | — | sat |

Binding of the software into the system (`10`): `TethysFlightSegment::tug` now reads
`default = argent` so that `63` can redefine it — `SoftwareFlightSegment :> TethysFlightSegment`
binds `tug = argentSoftware`, and `tethysSoftwareSystem : TethysMission::Mission` carries that
flight segment with the class, duration, launch and ground segments of `tethysSystem`.
`tethysSystem` itself is unchanged (`instantiate-system` did not move). `tethysSoftwareSystem`
does not subset `tethysSystem`: a second subsetter gives the singleton two values and every
`satisfy … by tethysSystem.flight` stops evaluating.

## Software backbone contract

Qualified names the later software packages reuse. Nothing in this list is renamed or re-typed
by a later package; additions go in that package's own file and specialise or allocate to these.

### Layers and components

- `TethysFlightSoftware::SoftwareLayer` (`boardSupport`, `executive`, `coreService`, `application`),
  `SchedulingPolicy` (`cyclicFixedWindows`, `fixedPriorityPreemptive`), `SoftwareCriticality`
  (`safetyCritical`, `missionCritical`, `nonCritical`).
- `TethysFlightSoftware::SoftwareComponent` — base of every layer; attributes `layer`, `codeSize`,
  `dataSize`, `processorLoadMips`, `criticality`; port `bus : BusPort`.
- `TethysFlightSoftware::BoardSupportPackage`, `DeviceDriver`, `KestrelExecutive`, `Partition`,
  `CoreService`, `Application`, `SoftwareImage`.
- Core services: `TethysFlightSoftware::TimeService`, `EventService`, `TableService`,
  `DataStoreService`, `CommandIngestService`, `TelemetryOutputService`, `HousekeepingService`,
  `SchedulerService`, `BootUpdateService`.
- Applications: `TethysFlightSoftware::CdhApplication`, `GncApplication`, `SepControlApplication`,
  `PowerManagementApplication`, `ThermalControlApplication`, `TelecomApplication`,
  `InspectorHandlingApplication`, `CaptureControlApplication`, `AutonomyApplication`,
  `FdirApplication`, `ModeManagementApplication`, `ParameterBootUpdateApplication`.
  Every application inherits `rate`, `priority`, `activeModes : TugMode[*]`, `products :
  ProductPort`, `events : ~EventPort` and `bus : BusPort`.

### Items and ports

- Items: `TethysFlightSoftware::BusMessage` (`:> TethysIcds::SpacePacket`), `TimeTick`,
  `SoftwareEvent` (`:> TethysModes::OnBoardEvent`), `ParameterTable`, `DataProduct`, `ImageSegment`.
- Ports: `TethysFlightSoftware::BusPort` (`publish`/`subscribe : BusMessage`), `TimePort`,
  `EventPort` (`raised : SoftwareEvent`), `TablePort`, `ProductPort`, `CommandIngestPort`,
  `TelemetryOutputPort`, `FaultPort`, `UpdatePort`; the flight ends of the ICDs stay
  `TethysIcds::PacketPort` (TI-010, on `TelecomApplication::spaceLink`) and
  `TethysInterfaces::DataBusPort` (TI-013, on `BoardSupportPackage::deviceBus`,
  `CdhApplication::dataBus`, `FlightComputer::bus`/`crossStrap`).
- Bus: `TethysFlightSoftware::SoftwareBus` (`designation` "AABP-1", `maximumMessageLength`,
  `topicCount`, `queueDepth`, `hub : ~BusPort`) and `BusAttachment` (interface def, component
  `bus` to bus `hub`).

### The Argent instance

- `TethysFlightSoftware::ArgentFlightSoftware` with parts `boardSupport`, `executive`, `softwareBus`,
  `time`, `events`, `tables`, `dataStore`, `commandIngest`, `telemetryOutput`, `housekeeping`,
  `scheduler`, `bootUpdate`, `cdh`, `gnc`, `sepControl`, `powerManagement`, `thermalControl`,
  `telecom`, `inspectorHandling`, `captureControl`, `autonomy`, `fdir`, `modeManagement`,
  `parameterBootUpdate`, `components` (all 23), `flightImage`, `safeImage`.
- Partitions: `TethysFlightSoftware::ArgentFlightSoftware::executive::platformPartition`,
  `gncPartition`, `subsystemPartition`, `autonomyPartition`, `payloadPartition`.
- Computers: `TethysFlightSoftware::CdhWithSoftware::prime`, `redundant`
  (`LoadedFlightComputer :> TethysTugStructure::FlightComputer`, `image : SoftwareImage`);
  the tug `TethysFlightSoftware::argentSoftware : SoftwareTug`; the system
  `TethysFlightSoftware::tethysSoftwareSystem` (`flight : SoftwareFlightSegment`).

### Deployment

- `TethysAllocations::SoftwareDeployment` and its steps `SoftwareHosting` (`SoftwareFunction` →
  `Application`), `ApplicationDeployment` (`Application` → `Partition`), `PartitionPlacement`
  (`Partition` → `FlightComputer`); the usage `TethysAllocations::softwareDeployment`; the view
  `TethysAllocations::softwareDeploymentMatrix`; the queries
  `TethysAllocationQueries::UnallocatedApplications`, `AllocatedApplications`,
  `UnallocatedPartitions`, `AllocatedPartitions`; the rule
  `TethysHouseRules::allocationUsageIsTyped`.

### What each later package may add

- WP-SW-2 (dictionary, packets): `item def`s specialising `BusMessage`, `TelemetryPacket` and
  `CommandPacket` with field layouts, and `attribute`s on the applications' existing ports; no new
  port defs on `Application`, the bus stays `SoftwareBus`.
- WP-SW-3 (application state machines): `state def`s exhibited by the twelve applications (and the
  redundancy fail-over of `CdhWithSoftware`), driven by `SoftwareEvent` on `events` and by
  `TethysModes::TugModes`; applications are specialised, never replaced.
- WP-SW-4 (timing budgets): rate, deadline, worst-case execution time and bus-load attributes bound
  on `KestrelExecutive`, the partitions and the applications, summed against `scheduledWindows`,
  `budgetedLoadMips` and `TethysBudgets::ProcessorBudget`; the five partitions and their windows
  are the baseline it refines.
- WP-SW-6 (software ICDs): `interface def`s between application ports over `BusAttachment`, and the
  software side of TI-003, TI-010 and TI-013 on `TelecomApplication::spaceLink`,
  `BoardSupportPackage::deviceBus` and `CdhApplication::dataBus`; the ports themselves stay typed as
  above.
- WP-SW-7 (ground software): a ground-side counterpart that connects to `TelecomApplication::spaceLink`
  through `TethysIcds::PacketPort` and reuses `ParameterTable`, `ImageSegment` and `DataProduct`;
  nothing on the flight side moves.
