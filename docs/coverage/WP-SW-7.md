# WP-SW-7 coverage — ground software (Meridian Operations Suite)

File: `model/69-ground-software.sysml` (`TethysGroundSoftware`, mission tier). Backbone edits in
`model/50-ground.sysml` (`GroundSoftwareComponent`; `MeridianOperationsCentre`,
`MeridianFlightDynamics`, `MeridianScienceDataSystem` gain component parts that 69 retypes),
`model/53-operations.sysml` (`StationPass::producedBy`, `DailyPassPlan::producedBy`) and
`model/23-verification.sysml` (`TestBedSet` definition behind the `testBeds` part, so 69 can
retype its four test beds). Runs recorded with the pinned OpenSysML `5cd37f288`
(`runs/tool-version.txt`); every command below is a `run` line in `scripts/runs.sh` and its output
is in `runs/<name>.txt`. Findings and probes: `docs/findings/WP-SW-7.md` (F-SW701 to F-SW704),
`model/probes/F-SW701-quantity-typed-argument-bounds.sysml`,
`model/probes/F-SW702-rate-times-duration-capacity.sysml`,
`model/probes/F-SW703-succession-to-calc-usage.sysml`,
`model/probes/F-SW704-satisfy-reads-calc-result.sysml`.

Result key as in `WP-J.md`: **sat**, **sat (finding)**, **partial**, **open**.

## Scope rows

| Row | File : element | Proving command | Result |
| --- | --- | --- | --- |
| SW-050 command generation from the dictionary, argument validation, criticality, two-person rule | `69` : `CommandBuilder` (Meridian Forge) with `calc def ValidateCommand` over `TethysFlightDictionary::flightDictionary` (`commandMnemonics`, `CommandDefinition::allowedModes`, `hazardous`, `CommandArgument::minimum/maximum`); five planted `CommandRequest`s (`thrustArcRequest` accepted, `thrustArcInCoast` mode refused, `resetOneApproval` awaiting the second approval, `resetBadKey` out of range, `misspelledRequest` unknown opcode); `verdictsAsPlanted`, `assert constraint acceptsTheNominalRequest` | `sw-ground-structure` (the five `…Verdict.verdict` lines) | sat (finding F-SW701: the thrust-arc range check uses the `Real` `throttle` argument, not the `DurationValue` `duration`) |
| SW-051 command validation against flight rules and mode, uplink blocked | `69` : `ValidateCommand::modeAllowed` (dictionary `allowedModes`); `FlightRuleChecker` (Meridian Warden) releases a `LoadSequence` only on `SequenceVerdict::cleared`; `requirement <'GS-002'> sequenceClearance` | `sw-ground-sequencer-check` (`released`, `loadsAccepted`) | sat |
| SW-052 sequencing: checker, uplink product generation | `69` : `PlannedSequence` (the `OnBoardSequence` id and the planned flight state), `GroundSequenceCheck` (`LoadPlannedSequence`, `calc CheckFlightRules` FR-001…FR-004 + flight mode, `decide` → `clear`/`refuse`), `UplinkProduct`; nominal `thrustArcInCoast` cleared, `thrustArcDuringRelay` refused "FR-001 thrust during a relay pass" | `sw-ground-sequencer-check` | sat (finding F-SW703: the rule calc sits outside the succession chain) |
| SW-053 telemetry processing: decommutation by dictionary, EU conversion | `69` : `TelemetryServer` (Meridian Lantern) `DecommutatePacket` over `PacketDefinition::fieldCount/layoutConsistent`, `EngineeringUnits`, `frameLength` from TI-021, `allPacketsDecommutate = flightDictionary.packetsSumToLength`, `EngineeringTelemetry` product | `sw-ground-structure` (`dictionaryPacketCount`, `dictionaryPointCount`, `allPacketsDecommutate`, `frameLength`) | sat |
| SW-054 alarms and limit monitoring, acknowledgement | `69` : `CheckLimits` against the dictionary `FdirLimitTable` (`busVoltageAlarm` nominal, `lowBatteryAlarm` violation, `floorViolationRaised`), `state def AlarmLifecycle` (`AlarmRaised`/`AlarmAcknowledge`/`AlarmCleared`), `AlarmRecord`; `requirement <'GS-003'>` | `sw-ground-structure` (`…Alarm.severity`), `requirements-satisfy` (`GS-001`…`GS-004` hold) | sat (finding F-SW704: the requirements read wrapping attributes) |
| SW-055 trending, consumables, predictions | `69` : `TrendProduct`, `xenonTrend` through `TethysOperations::LinearTrend`, `TelemetryServer::trends` port | `sw-ground-structure` (`xenonTrend.projected`) | sat |
| SW-056 flight dynamics: OD, ephemerides, manoeuvre design, ΔV accounting | `69` : `FlightDynamicsTool` (Meridian Sextant) `OrbitDetermination` (`argentOd.positionUncertainty`), `ManoeuvreDesign` (`returnArc.arcDuration`, `.xenon`), `Ephemeris`, `DeltaVLedger`, `OrbitSolution`/`ManeuverPlan` ports | `sw-ground-structure` | sat |
| SW-057 pass planning: visibility, allocation, link mode per pass | `69` : `PassPlanner` (Meridian Almanac) `StationVisible` (Caldera sees the tug, Tableland does not), `PlannedDailyPassPlan :> DailyPassPlan` with `producedBy` bound to the planner and its `StationPass`es, rate set per mode | `sw-ground-structure` (`…SeesTheTug.visible`, `plannedDay.imageryFits`) | sat |
| SW-058 link budget in operations: rate selection per pass | `69` : `PassVolume` over `TethysSoftwareIcds::LinkRateSet` (`proximityRates`, `coastRates` from TI-021), `imageryFits`; `requirement <'GS-004'>` | `sw-ground-structure` (`calderaVolume.volumeBits`, `imageryFits`) | sat (finding F-SW702: computed on the numeric values) |
| SW-059 data archive and distribution: levels, retention, access | `69` : `DataArchive` (Meridian Vault) `RetentionRule` per `ProductLevel`, `distributedLevels`, `ArchiveRecord` ingest/distribution ports | `sw-ground-structure` (`distributedLevels`) | sat |
| SW-060 anomaly response: lifecycle, procedures, decision authority | `69` : `AnomalyTracker` (Meridian Ledger) `state def AnomalyLifecycle` (`AnomalyTriaged`/`AnomalyAssigned`/`AnomalyDispositioned`), `AnomalyReport`, `AnomalyDisposition`, `DecisionAuthority`, `TethysOperations::ContingencyProcedure` reuse | `sw-ground-structure` (`-instantiate` of the suite) | sat |
| SW-061 proximity-operations and capture planning tools | `69` : `ProximityPlanner` (Meridian Compass) `RelativeNavigationProduct`, keep-out check against `approachKeepOut.keepOutRadius`, `GoNoGoChecklist` (`checklist.go`), `CaptureReadinessPackage` | `sw-ground-structure` (`checklist.go`) | sat |
| SW-062 simulators and test beds, fidelity levels | `69` : `Simulator :> GroundSoftwareComponent, TestBed`, `FlightSoftwareInTheLoopSimulator` (Meridian Anvil, drives `ArgentFlightSoftware` through TI-021), `HardwareInTheLoopTestBed` (Meridian Capstan), `DynamicsSimulator` (Meridian Orrery), `CaptureRigController`; `SimulatedTestBedSet :> TestBedSet` retypes `flatsat`, `captureRig`, `dynamicsSimulator`, `trajectoryTool` | `sw-ground-structure` (`simulatorCount`, `productNames`) | sat |
| SW-065 interfaces to ground elements: station↔MOC, MOC↔FDF, SDS↔archive | `69` : `SuitePacketGateway :> MeridianPacketGateway`, `interface def GroundPacketRelay`, `SoftwareOperationsCentre`/`SoftwareFlightDynamics`/`SoftwareScienceDataSystem` connect the suite's `ProductPort`s to the 50 `toFlightDynamics`/`toScience`/`fromOperations` ports; `MeridianOperationsSuite::spaceLink : SpaceLinkProfileIcd` (TI-021) | `sw-ground-structure` | sat |
| SW-067 operations roles mapped to software functions | `69` : use cases `BuildAndUplinkCommand` (ACE + approver), `PlanAndClearSequence` (sequence engineer), `MonitorAndRespond` (ACE + flight director), `DetermineOrbitAndDesignArc` (navigator), `DispositionAnomaly` (anomaly board), `DirectTheFlight` including them; `SoftwareOperationsCentre::ace : OperationsRole`; `DecisionAuthority` on `AnomalyReport` | OpenSysML strict + pilot | sat |

## Backbone changes

| File | Change | Why |
| --- | --- | --- |
| `50` | `part def GroundSoftwareComponent` (`productName`, `version`); `MeridianOperationsCentre` gains `commandBuilder`, `sequencer`, `telemetryServer`, `passPlanner`, `anomalyTracker`, `proximityPlanner`; `MeridianFlightDynamics` gains `flightDynamicsTool`; `MeridianScienceDataSystem` gains `dataArchive` — all typed `GroundSoftwareComponent` | The pilot standalone validator resolves references only to earlier files, so 50 cannot import 69; 69's `SoftwareOperationsCentre :> MeridianOperationsCentre` retypes each slot (`part :>> commandBuilder : CommandBuilder` …) |
| `53` | `StationPass::producedBy : GroundSoftwareComponent[0..1]`, `DailyPassPlan::producedBy : GroundSoftwareComponent[0..1]` | 69's `PlannedDailyPassPlan` binds both to the pass planner |
| `23` | `part def TestBedSet` holding the four test beds; `part testBeds : TestBedSet` keeps the name and the parts | 69's `SimulatedTestBedSet :> TestBedSet` retypes `flatsat`, `captureRig`, `dynamicsSimulator`, `trajectoryTool` by the simulator definitions |

## Runs added

| Run | Command | Shows |
| --- | --- | --- |
| `sw-ground-structure` | `-instantiate TethysGroundSoftware::meridianOperationsSuite` + `-e` counts and verdicts | 12 components and their product names, the command verdicts, dictionary packet/point counts, alarms, trend, OD and manoeuvre results, visibility, pass volume, archive levels, go/no-go |
| `sw-ground-sequencer-check` | `-instantiate …::nominalUplink -action "…FlightRuleChecker::check …nominalUplink.checker" -advance 10`, then the same on `relayConflictUplink` | nominal: `verdict = cleared`, `released = 1`, flight `loadsAccepted = 1`; relay conflict: `verdict = refused`, `reason = "FR-001 thrust during a relay pass"`, `released = 0`, `loadsAccepted = 0` |

## Integration asks

- WP-SW-5 (67): `GS-001`…`GS-004` are local requirements of 69; the TM- tier should derive them (or absorb them) when it lands.
- WP-SW-4 (66): the ground segment of the end-to-end command and telemetry timing budgets now has named components (`FlightRuleChecker`, `TelemetryServer`, `SuitePacketGateway`) to hang its latency figures on.
- The sequence engineer's `PlannedSequence` carries the planned flight state as scalars; when the on-board sequence definitions in 61 carry mode and thrust flags, bind those instead.
