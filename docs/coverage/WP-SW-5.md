# WP-SW-5 — software requirements tier (`model/67-software-requirements.sysml`, `model/67-software-requirements-tooling.sysml`)

Package `TethysSoftwareRequirements` (mission tier) and `TethysSoftwareRequirementsTooling` (tool tier,
the only software-requirements file that references an OpenSysML library package, `DocumentQueries`).
Two requirement definitions and 52 requirement usages: 40 flight rows `TF-` (`FlightSoftwareRequirement`)
and 12 ground rows `TM-` (`GroundSoftwareRequirement`), both `:> TethysRequirementsL2::SoftwareRequirement`
with `tier = RequirementTier::software`. Every row carries a `doc` with its rationale, a measurable
`require constraint` over backbone values, at least one `#derivation` source among the TS-/TA-/TC-/TG-
rows of 21/22, the FR-00x flight rules and TG-010 of 53, the budget rows TS-142…TS-144 of 32 and
GS-001…GS-004 of 69, and at least one `satisfy … by` a software element of 63/64/65/66/69. The
verdicts are the pinned `-satisfy` runs; two rows fail by design (below).

## Published contract (WP-SW-8 verifies these; ids and names are fixed)

`TethysSoftwareRequirements::FlightSoftwareRequirement`, `::GroundSoftwareRequirement`, and the 52 rows
of the table: `TF-001 commandIngest` … `TF-028 boardSupportWatchdog`, `TF-030 cdhApplication` …
`TF-041 parameterBootUpdateApplication` (one per application of 63, in the order of
`ArgentFlightSoftware`), `TM-001 commandValidation` … `TM-012 simulatorFidelity`. The tool-tier queries
`SoftwareRequirementRows`, `UnderivedSoftwareRequirements`, `UnsatisfiedSoftwareRequirements`,
`FlightSoftwareElements`, `GroundSoftwareElements`, `UncoveredFlightSoftware`, `UncoveredGroundSoftware`,
`SoftwareRequirementMatrix` and the document `SoftwareRequirementsDocument`.

## Where the ground rows are satisfied, and why

The pilot resolves a file only against earlier-numbered files (F-T08 in `docs/findings/WP-SW-4.md`), so
`67` cannot name anything in `68-software-icds` or `69-ground-software`. Consequently:

- the TM rows' subjects are typed by `TethysMeridian::GroundSoftwareComponent` (50) and their constraints
  read the backbone the suite reads (the flight dictionary flags of 64, the FR-00x values and TG-010 of 53,
  the TG- rows of 22, the data budget of 32, the Meridian staffing of 50, the test beds of 23);
- the `satisfy TM-… by meridianOperationsSuite.…` statements and the four `#derivation` connections from
  `GS-001…GS-004` live in `67-software-requirements-tooling.sysml`, which the batch pilot loads after 69;
- the MLS-2 / AABP-1 figures the TF rows bind to (rate sets, housekeeping periods, time-correlation period,
  acknowledgement timeout) and the Vault retention are typed into the rows and asserted equal to 68/69 in
  `runs/sw-requirements-icd-figures.txt` (nine `-e` equalities, all `true`), the F-T08 pattern.

## Rows

| Row | Name | File:element | Derived from | Satisfied by (file) | Proving command | Result |
| --- | --- | --- | --- | --- | --- | --- |
| TF-001 | `commandIngest` | `model/67-software-requirements.sysml:commandIngest` | TG-010 dictionaryConsistent, TS-021 commandLatency | `argentSoftware.cdh.software.commandIngest` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-002 | `hazardousTwoStep` | `model/67-software-requirements.sysml:hazardousTwoStep` | TG-010 dictionaryConsistent, FR-001 noThrustDuringRelay | `argentSoftware.cdh.software.commandIngest` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-003 | `telemetryRatesByMode` | `model/67-software-requirements.sysml:telemetryRatesByMode` | TS-007 deepSpaceLink, TS-020 groundCoverage | `argentSoftware.cdh.software.telecom` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-004 | `eventLogging` | `model/67-software-requirements.sysml:eventLogging` | TS-013 autonomousSurvival, TA-010 faultDetectionLatency | `argentSoftware.cdh.software.events` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-005 | `parameterTables` | `model/67-software-requirements.sysml:parameterTables` | TG-010 dictionaryConsistent, TC-005 fdirTaskPeriod | `argentSoftware.cdh.software.tables` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-006 | `timeCorrelation` | `model/67-software-requirements.sysml:timeCorrelation` | TS-007 deepSpaceLink, TG-003 rangingAccuracy | `argentSoftware.cdh.software.time` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-007 | `imageIntegrity` | `model/67-software-requirements.sysml:imageIntegrity` | TS-013 autonomousSurvival | `argentSoftware.cdh.software.bootUpdate` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-008 | `bootFallback` | `model/67-software-requirements.sysml:bootFallback` | TS-013 autonomousSurvival | `softwareNominalFlight.tug.cdh.software.parameterBootUpdate` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-009 | `partitionIsolation` | `model/67-software-requirements.sysml:partitionIsolation` | TS-015 faultResponse, TS-142 processorBudgetCloses | `argentSoftware.cdh.software.executive` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-010 | `processorMemoryReserve` | `model/67-software-requirements.sysml:processorMemoryReserve` | TS-142 processorBudgetCloses | `softwareProcessorBudget` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-011 | `busReserve` | `model/67-software-requirements.sysml:busReserve` | TS-143 busBudgetCloses | `softwareBusBudget` (67) | `runs/sw-requirements-satisfy.txt` | **fails** (36 of 64 slots used, 32 allowed at the policy reserve; maintainer-owned) |
| TF-012 | `busReserveCoast` | `model/67-software-requirements.sysml:busReserveCoast` | TS-143 busBudgetCloses | `softwareBusBudgetCoast` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-013 | `faultDetectionChain` | `model/67-software-requirements.sysml:faultDetectionChain` | TA-010 faultDetectionLatency, TS-144 latencyBudgetCloses | `argentLatency.faultDetection` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-014 | `safeConfigurationLatency` | `model/67-software-requirements.sysml:safeConfigurationLatency` | TS-015 faultResponse, TS-144 latencyBudgetCloses | `argentLatency.safeConfiguration` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-015 | `fdirTaskRate` | `model/67-software-requirements.sysml:fdirTaskRate` | TC-005 fdirTaskPeriod | `argentTiming.platformSchedule.fdirTask` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-016 | `commandDispatchLatency` | `model/67-software-requirements.sysml:commandDispatchLatency` | TS-021 commandLatency, TS-144 latencyBudgetCloses | `argentLatency.commandDispatch` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-017 | `telemetrySampleLatency` | `model/67-software-requirements.sysml:telemetrySampleLatency` | TS-007 deepSpaceLink, TS-144 latencyBudgetCloses | `argentLatency.telemetrySample` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-018 | `safeModeEntry` | `model/67-software-requirements.sysml:safeModeEntry` | TS-013 autonomousSurvival, TS-015 faultResponse | `argentSoftware.cdh.software.modeManagement` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-019 | `modeTransitions` | `model/67-software-requirements.sysml:modeTransitions` | TS-013 autonomousSurvival | `argentSoftware.cdh.software.modeManagement` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-020 | `sequencingEngine` | `model/67-software-requirements.sysml:sequencingEngine` | TS-021 commandLatency, FR-001 noThrustDuringRelay, FR-004 batteryDepthOfDischarge | `argentSoftware.cdh.software.autonomy` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-021 | `redundancyManagement` | `model/67-software-requirements.sysml:redundancyManagement` | TS-013 autonomousSurvival | `argentSoftware.cdh` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-022 | `heartbeatFailover` | `model/67-software-requirements.sysml:heartbeatFailover` | TS-013 autonomousSurvival, TS-015 faultResponse | `softwareNominalFlight.tug.cdh` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-023 | `busMessaging` | `model/67-software-requirements.sysml:busMessaging` | TS-143 busBudgetCloses | `argentSoftware.cdh.software.softwareBus` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-024 | `dataStoreRetention` | `model/67-software-requirements.sysml:dataStoreRetention` | TS-007 deepSpaceLink, TS-013 autonomousSurvival | `argentSoftware.cdh.software.dataStore` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-025 | `telemetryOutput` | `model/67-software-requirements.sysml:telemetryOutput` | TG-010 dictionaryConsistent, TS-007 deepSpaceLink | `argentSoftware.cdh.software.telemetryOutput` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-026 | `housekeepingSampling` | `model/67-software-requirements.sysml:housekeepingSampling` | TS-007 deepSpaceLink | `argentSoftware.cdh.software.housekeeping` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-027 | `schedulerCapacity` | `model/67-software-requirements.sysml:schedulerCapacity` | TS-021 commandLatency | `argentSoftware.cdh.software.scheduler` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-028 | `boardSupportWatchdog` | `model/67-software-requirements.sysml:boardSupportWatchdog` | TS-013 autonomousSurvival, TS-015 faultResponse | `argentSoftware.cdh.software.boardSupport` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-030 | `cdhApplication` | `model/67-software-requirements.sysml:cdhApplication` | TS-013 autonomousSurvival | `argentSoftware.cdh.software.cdh` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-031 | `gncApplication` | `model/67-software-requirements.sysml:gncApplication` | TS-015 faultResponse | `argentSoftware.cdh.software.gnc` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-032 | `sepControlApplication` | `model/67-software-requirements.sysml:sepControlApplication` | FR-001 noThrustDuringRelay | `argentSoftware.cdh.software.sepControl` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-033 | `powerManagementApplication` | `model/67-software-requirements.sysml:powerManagementApplication` | FR-004 batteryDepthOfDischarge | `argentSoftware.cdh.software.powerManagement` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-034 | `thermalControlApplication` | `model/67-software-requirements.sysml:thermalControlApplication` | TS-013 autonomousSurvival | `argentSoftware.cdh.software.thermalControl` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-035 | `telecomApplication` | `model/67-software-requirements.sysml:telecomApplication` | TS-007 deepSpaceLink | `argentSoftware.cdh.software.telecom` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-036 | `inspectorHandlingApplication` | `model/67-software-requirements.sysml:inspectorHandlingApplication` | TS-014 proximityContactEnvironment | `argentSoftware.cdh.software.inspectorHandling` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-037 | `captureControlApplication` | `model/67-software-requirements.sysml:captureControlApplication` | TS-015 faultResponse, TS-014 proximityContactEnvironment | `argentSoftware.cdh.software.captureControl` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-038 | `autonomyApplication` | `model/67-software-requirements.sysml:autonomyApplication` | TS-021 commandLatency | `argentSoftware.cdh.software.autonomy` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-039 | `fdirApplication` | `model/67-software-requirements.sysml:fdirApplication` | TA-010 faultDetectionLatency, TC-005 fdirTaskPeriod | `argentSoftware.cdh.software.fdir` (67) | `runs/sw-requirements-satisfy.txt` | **fails** (`fdir.rate` is the `Application` default 1 Hz; TC-005 needs ≥ 10 Hz; see Open rows) |
| TF-040 | `modeManagementApplication` | `model/67-software-requirements.sysml:modeManagementApplication` | TS-015 faultResponse | `argentSoftware.cdh.software.modeManagement` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TF-041 | `parameterBootUpdateApplication` | `model/67-software-requirements.sysml:parameterBootUpdateApplication` | TS-013 autonomousSurvival | `argentSoftware.cdh.software.parameterBootUpdate` (67) | `runs/sw-requirements-satisfy.txt` | holds |
| TM-001 | `commandValidation` | `model/67-software-requirements.sysml:commandValidation` | TG-010 dictionaryConsistent, TS-021 commandLatency, GS-001 commandValidation | `meridianOperationsSuite.moc.commandBuilder` (tooling) | `runs/sw-requirements-ground-satisfy.txt` | holds |
| TM-002 | `hazardousApproval` | `model/67-software-requirements.sysml:hazardousApproval` | FR-001 noThrustDuringRelay, TS-022 operatorWorkload, GS-001 commandValidation | `meridianOperationsSuite.moc.commandBuilder` (tooling) | `runs/sw-requirements-ground-satisfy.txt` | holds |
| TM-003 | `sequenceClearance` | `model/67-software-requirements.sysml:sequenceClearance` | TS-021 commandLatency, FR-001 noThrustDuringRelay, FR-004 batteryDepthOfDischarge, TG-005 sequenceTurnaround, GS-002 sequenceClearance | `meridianOperationsSuite.moc.sequencer` (tooling) | `runs/sw-requirements-ground-satisfy.txt` | holds |
| TM-004 | `telemetryDecommutation` | `model/67-software-requirements.sysml:telemetryDecommutation` | TG-010 dictionaryConsistent, GS-003 dictionaryDrivenTelemetry | `meridianOperationsSuite.moc.telemetryServer` (tooling) | `runs/sw-requirements-ground-satisfy.txt` | holds |
| TM-005 | `limitAlarming` | `model/67-software-requirements.sysml:limitAlarming` | FR-004 batteryDepthOfDischarge, TG-006 monitoringAutomation, GS-003 dictionaryDrivenTelemetry | `meridianOperationsSuite.moc.telemetryServer` (tooling) | `runs/sw-requirements-ground-satisfy.txt` | holds |
| TM-006 | `trendingAutomation` | `model/67-software-requirements.sysml:trendingAutomation` | TG-006 monitoringAutomation, TS-022 operatorWorkload | `meridianOperationsSuite.moc.telemetryServer` (tooling) | `runs/sw-requirements-ground-satisfy.txt` | holds |
| TM-007 | `flightDynamicsProducts` | `model/67-software-requirements.sysml:flightDynamicsProducts` | TS-013 autonomousSurvival, TG-003 rangingAccuracy, TG-004 impactScreening | `meridianOperationsSuite.fdf.flightDynamicsTool` (tooling) | `runs/sw-requirements-ground-satisfy.txt` | holds |
| TM-008 | `passPlanningVolume` | `model/67-software-requirements.sysml:passPlanningVolume` | TS-007 deepSpaceLink, TS-020 groundCoverage, GS-004 plannedPassesFitTheLink | `meridianOperationsSuite.moc.passPlanner` (tooling) | `runs/sw-requirements-ground-satisfy.txt` | holds |
| TM-009 | `archiveRetention` | `model/67-software-requirements.sysml:archiveRetention` | TG-007 scienceArchive | `meridianOperationsSuite.sds.dataArchive` (tooling) | `runs/sw-requirements-ground-satisfy.txt` | holds |
| TM-010 | `anomalyDisposition` | `model/67-software-requirements.sysml:anomalyDisposition` | TS-022 operatorWorkload, TG-020 operationsReadiness | `meridianOperationsSuite.moc.anomalyTracker` (tooling) | `runs/sw-requirements-ground-satisfy.txt` | holds |
| TM-011 | `proximityGoNoGo` | `model/67-software-requirements.sysml:proximityGoNoGo` | FR-002 approachKeepOut, FR-003 sunExclusion, TS-014 proximityContactEnvironment | `meridianOperationsSuite.moc.proximityPlanner` (tooling) | `runs/sw-requirements-ground-satisfy.txt` | holds |
| TM-012 | `simulatorFidelity` | `model/67-software-requirements.sysml:simulatorFidelity` | TS-017 captureQualification | `meridianOperationsSuite.testBeds.flatsat` (tooling); `meridianOperationsSuite.testBeds.trajectoryTool` (tooling); `meridianOperationsSuite.testBeds.dynamicsSimulator` (tooling); `meridianOperationsSuite.testBeds.captureRig` (tooling) | `runs/sw-requirements-ground-satisfy.txt` | holds |

`satisfy` statements: 55 (40 flight in 67, 15 ground in 67-tooling; `TM-012` is satisfied by each of the
four simulators, `TF-003`/`TF-035` and `TF-018`/`TF-019`/`TF-040` share a satisfier).

## Open rows (verdicts that fail, by design — maintainer decisions)

| Row | Verdict | Why | Decision needed |
| --- | --- | --- | --- |
| TF-011 `busReserve` | `✗ satisfy busReserve by softwareBusBudget fails` | `TethysFlightTiming::argentBus` uses 36 of 64 AABP-1 slots in proximity operations, capture and despin; the active software margin policy row (`activeSoftwarePolicy.busReserve`) allows 32. Recorded open in WP-SW-4; neither the schedule nor the policy was resized. | Resize the bus schedule, split the streams across frames, or relax the policy row. |
| TF-039 `fdirApplication` | `✗ satisfy fdirApplication by argentSoftware.cdh.software.fdir fails` | `FdirApplication` (63) does not redefine `Application::rate`, so the FDIR application declares the default 1 Hz while TC-005 bounds the fault-protection period at 0.1 s (≥ 10 Hz). The schedule hosts the task at 16 Hz (TF-015 holds, `hostedAtRequiredRate` is true because 16 Hz ≥ 1 Hz), so the declared rate, not the schedule, is what is inconsistent with TC-005. | Set `FdirApplication::rate` (63, WP-SW-1) to the required rate (e.g. 16 Hz, the hosting rate group) so `hostedAtRequiredRate` actually constrains the schedule; or accept the schedule as the measure and let this row read the task. |

## Coverage queries (`runs/sw-requirements-coverage.txt`)

| Query | Rows | Meaning |
| --- | --- | --- |
| `UnderivedSoftwareRequirements` | 0 | every TF-/TM- row has ≥ 1 incoming derivation |
| `UnsatisfiedSoftwareRequirements` | 0 | every TF-/TM- row has ≥ 1 incoming satisfaction (ground ones from the tooling package) |
| `UncoveredFlightSoftware` | 0 | every part owned by `ArgentFlightSoftware` (executive, bus, 9 core services, 12 applications, board support; the `…OnBus` connections, `components`, `flightImage`, `safeImage` excluded) satisfies ≥ 1 row |
| `UncoveredGroundSoftware` | 0 | every `GroundSoftwareComponent`-typed part the suite redefines (the 12 of `MeridianOperationsSuite::components`) satisfies ≥ 1 row; `gateway` (a `MeridianPacketGateway`) and the operations roles are not software components |
| `SoftwareRequirementMatrix` | 52 | id, name, method, level, direct derivation sources, satisfiers, satisfier count |

## Backbone changes

| File | Change | Why |
| --- | --- | --- |
| `model/04-requirements.sysml` | `RequirementTier::software` literal | the software tier (scope review 7.8) |
| `model/04-requirements.sysml` | `VerificationLevel::software` literal | TF-/TM- rows are verified at software level, below `subsystem` |
| `model/04-requirements.sysml` | `SystemRequirement::tier` written `default =` instead of `=` | OpenSysML strict refuses a redefinition that overrides an `=`-bound value (F-SW502); `FlightSoftwareRequirement`/`GroundSoftwareRequirement` redefine it to `software` |

No other file of the backbone, of 63–66 or of 68/69 was edited; GS-001…GS-004 stay where they are and
become derivation sources.

## Runs (`scripts/runs.sh`, pinned under `runs/sw-requirements-*.txt`)

| Run | Command | Pins |
| --- | --- | --- |
| `sw-requirements-counts` | `-instantiate argentSoftware`, `-instantiate meridianOperationsSuite`, counts and the two open-row figures | 23 flight components, 12 ground components, `fdir.rate` 1 Hz, `fdirTask.period` 0.0625 s, bus 36 / 64 / reserve 0.5 |
| `sw-requirements-matrix` | `-run-query SoftwareRequirementMatrix` | 52 rows |
| `sw-requirements-coverage` | the four gate queries | 0, 0, 0, 0 rows |
| `sw-requirements-satisfy` | `-satisfy=TethysSoftwareRequirements` | 40 verdicts: 38 hold, TF-011 and TF-039 fail |
| `sw-requirements-ground-satisfy` | `-satisfy=TethysSoftwareRequirementsTooling` | 15 verdicts, all hold |
| `sw-requirements-document` | `-render-document SoftwareRequirementsDocument` | the software requirements document (matrix + four gate tables) |
| `sw-requirements-icd-figures` | nine `-e` equalities against 68/69 | all `true` |
| `sw-requirements-probe-verdicts-depth` | the F-SW503 probe | eight-level root answers, ten-level root refused |

## Boundary measured (OpenSysML `5cd37f2`, pilot 2026-08 / 0.62.0, 4 vCPU VM)

| Measure | Value |
| --- | --- |
| Requirement definitions / usages added | 2 / 52 (plus 55 `satisfy`, 29 `#derivation` connections) |
| `-validate -strict -warnings-as-errors` (60 files) | 5.5 s, 0 diagnostics |
| `-self-check-package TethysHouseRules` | 73 858 elements, 639 984 checks, 0 violations (base: 72 638 elements, 625 618 checks) |
| `make pilot-mission` | 2 m 44 s, exit 0; 4 advisory warnings on `require budget.x;` lines (F-B03) |
| `make pilot-all` | 2 m 41 s, exit 0 |
| `-satisfy=TethysSoftwareRequirements` / `…Tooling` | 7.1 s / 5.7 s |
| `-render-document SoftwareRequirementsDocument` | 8.3 s |

## Findings

`docs/findings/WP-SW-5.md`: F-SW501 (pilot file order places the ground satisfactions in the tool tier,
consequence of F-T08), F-SW502 (`=`-bound value cannot be redefined in OpenSysML strict; pilot silent),
F-SW503 (`DocumentQueries::Verdicts` refuses a root nested deeper than eight part levels, so the document
carries no verdict table), F-SW505 (pilot operand-order warning on constraint references). Known findings
cited rather than rediscovered: F-T08, F-B03, F-SW704.
