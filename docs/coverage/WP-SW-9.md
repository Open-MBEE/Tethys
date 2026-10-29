# WP-SW-9 — software architecture document set and the deferred cross-model integration

Files: `model/94-software-documents.sysml` (mission tier, `TethysSoftwareDocuments`: the document
register), `model/94-software-documents-tooling.sysml` (tool tier, `TethysSoftwareDocumentsTooling`:
the queries and the documents), plus the integration edits listed below. Tool: OpenSysML `5cd37f2`,
pilot 2026-08 / 0.62.0.

## Scope

Eight document kinds rendered from the model, two of them as twelve volumes each (31 volumes;
33 rendered documents counting the two family covers), one Markdown run pinned per
document plus the existing whole-set runs; the four Meridian test beds subset the programme's
test-bed set; `verify` links from the TF-/TM- rows to the cases that cover them. No committed rendered
output under `docs/`: the repository's convention is the pinned `runs/` output, and that is the record.

## Documents → sections → source packages and queries

| Document (definition) | Sections | Source packages | Queries |
| --- | --- | --- | --- |
| Index (`SoftwareDocumentIndex`) | register | TethysSoftwareDocuments | `DocumentRecords` |
| Architecture description (`SoftwareArchitectureDescription`) | context (flight components, Meridian components); decomposition (applications with rate/priority/active modes, executive partitions, avionics with software); deployment and allocation; timing (rate groups, scheduled tasks with period/WCET/deadline/utilisation/modes); budgets (modes closed in, budget verdicts) | TethysFlightSoftware, TethysFlightTiming, TethysGroundSoftware, TethysAllocations | `FlightComponents` (over `TethysSoftwareRequirementsTooling::FlightSoftwareElements`), `GroundComponents`, `FlightApplications`, `Partitions`, `NamedParts`, `Deployment`, `RateGroups`, `ScheduledTasks`, `ModeDemands`, `BudgetVerdicts` (`Verdicts` over the seven budget parts) |
| Requirements specification (`SoftwareRequirementsSpecification :> SoftwareRequirementsDocument`) | inherited: rows with derivation sources and satisfiers, coverage gates; added: verification cross-reference (verified by, unverified, system cases covering software rows) | TethysSoftwareRequirements, TethysSoftwareAssurance, TethysVerification | inherited `SoftwareRequirementMatrix` and gates; `SoftwareRequirementVerification`, `UnverifiedSoftwareRequirements`, `SystemCasesCoveringSoftware` |
| Flight application design descriptions (`FlightApplicationDesignDescription`, 12 volumes `<App>DesignDescription`) | purpose (definition, behavioural specialisation); ports; state machine (exhibited machines, states); parameter table; rate/WCET/deadline; commands, telemetry, events, packets owned; requirements satisfied; assurance classification | TethysFlightSoftware, TethysFlightBehaviour, TethysModes, TethysFdir, TethysFlightTiming, TethysFlightDictionary, TethysSoftwareRequirements, TethysSoftwareAssurance | `Purpose`, `NamedPorts`, `NamedStates`, `ParameterRows`, `TaskOf`, `CommandsOf`, `TelemetryOf`, `EventsOf`, `PacketsOf`, `Satisfied`, `Classification` |
| Meridian component design descriptions (`GroundComponentDesignDescription`, 12 volumes) | purpose; ports; figures and tables (attributes, parts); test bed (simulators only); requirements satisfied; assurance classification | TethysGroundSoftware, TethysVerification, TethysSoftwareRequirements, TethysSoftwareAssurance | `Purpose`, `NamedPorts`, `NamedAttributes`, `NamedParts`, `Satisfied`, `Classification` |
| Interface control volume (`SoftwareInterfaceControlVolume`) | scope with `Ref` links to the five software ICD documents and the system ICD register; message catalogue (messages, topics); space link rate sets; register maps (thermal/propulsion, mechanism) | TethysSoftwareIcds, TethysIcds | `TethysSoftwareIcdDocuments::Messages`, `Topics`, `RateSets`, `Registers` (reused, not re-declared) |
| Flight dictionary volume (`FlightDictionaryVolume :> FlightDictionaryDocument`) | inherited: commands, telemetry, events, packets, packet layouts; added: twelve parameter tables, fault-protection limit tables | TethysFlightDictionary, TethysFdir | inherited dictionary queries; `ParameterRows`, `FdirLimits` |
| Test plan (`SoftwareTestPlan :> SoftwareVcrmDocument`) | inherited: VCRM, function coverage, uncovered, passed; added: test beds (programme set, simulators), assurance plan (levels, refs to the assurance report and FMECA), requirement cross-reference (verified by, unverified, system cases, ref to the V&V matrix) | TethysSoftwareAssurance, TethysVerification, TethysGroundSoftware, TethysSoftwareRequirements | inherited `SoftwareVcrm` etc.; `ProgrammeTestBeds`, `SimulatedTestBeds`, `AssurancePlanLevels`, `SoftwareRequirementVerification`, `UnverifiedSoftwareRequirements`, `SystemCasesCoveringSoftware` |
| Operations handbook (`SoftwareOperationsHandbook`) | flight modes (modes, configuration per mode); on-board sequences; fault protection (events, supervisor monitors, limit tables); flight rules and procedures; Meridian command workflow (uplink exchange, command requests, telemetry alarms); pass planning (planner figures, consoles and roles) | TethysModes, TethysSequence, TethysFdir, TethysOperations, TethysGroundSoftware, TethysFlightDictionary | `FlightModes`, `ModeConfigurations`, `OnBoardSequences`, `FaultEvents`, `NamedStates`, `FdirLimits`, `OperationsRequirements`, `Procedures`, `NamedParts`, `CommandRequests`, `TelemetryAlarms`, `PassPlannerFigures` |

Composition rules the tool imposes (findings F-SW901…903): a document cannot nest another
document, so a volume either specialises one base document (requirements specification,
dictionary volume, test plan) or refers to other documents with `Ref` runs and reuses their query
definitions (interface control volume); a query argument binds a literal only, so each design
description is its own definition.

What stays visible, as the model gives it: `BudgetVerdicts` prints `busCloses … violated` and
`satisfy busReserve by softwareBusBudget … violated` (TF-011, 36 of 64 slots against 32 at 50 %
reserve) next to `busReserveCoast … holds`; `AssurancePlanLevels` prints level A `5 / 4 / false`
(independent verification in progress, SA-001/SA-002 open); the planned cases keep `planned` in
the inherited VCRM. No budget, policy or status value was changed.

## Register

`TethysSoftwareDocuments::softwareDocumentSet` carries nine `DocumentRecord`s (id, title, version,
status, render target, volumes, source packages). All are `draft` at version `0.1`:
`documentCount = 9`, `volumeCount = 31`, `releasedCount = 0` (run `sw-doc-register`). The status is
read by the index, never asserted by it.

## Integration (a): one test-bed set

`TethysGroundSoftware::MeridianOperationsSuite::testBeds` now reads
`part testBeds : SimulatedTestBedSet :> TethysVerification::testBeds;` — the suite's test beds
subset the programme's set, so `TethysVerification::testBeds` and the Meridian simulators are one
set of four (`flatsat`, `captureRig`, `dynamicsSimulator`, `trajectoryTool`), each retyped by its
simulator product (`SimulatedTestBedSet` already redefined the four). The file stays
pilot-portable (both validators accept subsetting a package-level part from a part definition;
redefining it at package level is rejected by both, `redefinition-package-level`). The test plan
prints the set from both ends (`ProgrammeTestBeds`, `SimulatedTestBeds`); run `sw-doc-test-beds`
reads the product name and fidelity through the suite.

## Integration (b): verify links from the TF-/TM- rows

Rule (model-derived, no hand mapping): a case verifies a software row when the row derives from a
system row the case verifies (`#derivation` connections of 67 composed with the `verify` members of
the case).

- In `model/88-software-assurance.sysml`, 15 of the 16 `SoftwareVerificationCase` definitions
  gained `verify TethysSoftwareRequirements::<row>` members in their objectives: 74 links over 41
  usages (the planned usages keep their links and print `?` / `planned` in the satisfy runs — the
  intended unevaluated state). `RelativeStateEstimationTest`, `ThermalControlTest`,
  `InspectorRelayTest` and `HazardousCommandInhibitTest` verify system rows no software row derives
  from and gained none. `GroundCommandTwoStepTest` does not carry TM-003 (`sequenceClearance`) because
  it already verifies the system row of the same name (F-SW902).
- In `model/94-software-documents.sysml` (mission tier), eight usages subset the system cases whose verified
  rows have derived software rows (`captureEnvelopeTestSoftware`, `contactSpeedTestSoftware`,
  `linkBudgetTestSoftware`, `faultResponseTestSoftware`, `autonomyTestSoftware`,
  `deflectionAnalysisSoftware`, `groundReadinessDemoSoftware`, `groundProceduresDemoSoftware`):
  57 links. They live in 94 rather than in 23 because 23 precedes 67 in the pilot's file order and
  cannot name TF-/TM- rows; not in 67 because `SoftwareRequirementRows` reads every requirement
  usage under that package (the objectives would appear as rows); not in 88 so the 41-row VCRM of
  `SoftwareVcrmDocument` keeps its row count.
- Reachable from both ends: `SoftwareRequirementVerification` (incoming from each row) and the
  inherited `SoftwareVcrm` (outgoing from each case). Rows without a case: TF-010, TF-011, TF-012,
  TF-023 — they derive only from `processorBudgetCloses`, `busBudgetCloses` and the bus messaging
  rows, which no verification case verifies; they are printed by `UnverifiedSoftwareRequirements`
  and run `sw-doc-unverified`, not closed.

## Backbone edits

| File | Element | Before → after |
| --- | --- | --- |
| `model/23-verification.sysml` | — | no edit: the shared set is reached by subsetting from 69 (file order forbids 23 naming 69 or 67) |
| `model/85-safety.sysml` | — | no edit: 85 owns no verification case and no test bed |

Software-package edits outside 94: `69-ground-software.sysml` (`testBeds` subsets
`TethysVerification::testBeds`), `88-software-assurance.sysml` (74 `verify` members),
`64-flight-dictionary-tooling.sysml`, `67-software-requirements-tooling.sysml`,
`88-software-assurance-tooling.sysml` (`title` declared `default =` so the volumes can retitle).

## Runs added (`scripts/runs.sh`, pinned under `runs/sw-doc-*.txt`)

`sw-doc-register`, `sw-doc-test-beds`, `sw-doc-verify-links`, `sw-doc-unverified`,
`sw-doc-system-cases`, `sw-doc-budget-verdicts`; one `-render-document` run per document:
`sw-doc-index`, `sw-doc-architecture-description`, `sw-doc-requirements-specification`,
`sw-doc-icd-volume`, `sw-doc-dictionary-volume`, `sw-doc-test-plan`, `sw-doc-operations-handbook`,
`sw-doc-sdd-flight-<App>` (12), `sw-doc-sdd-ground-<Component>` (12); the probes
`sw-doc-probe-query-binding`, `sw-doc-probe-query-binding-literal`, `sw-doc-probe-same-named-verify`,
`sw-doc-probe-inherited-order`. The whole set is rendered by the existing `render-documents-md` /
`render-documents-html` runs.

## Measurements (OpenSysML `5cd37f2`, whole model loaded per render, 4 vCPU VM)

<!-- measurements:start -->
Each render loads the 63 model files and renders one document (`-render-document … -quiet
model/*.sysml`); times are one wall-clock measurement each, so the first row includes a cold cache.
No document approaches the 60 s / 5 MB boundary: the largest is the dictionary volume (173 KB, the
inherited dictionary tables), the slowest single render 14 s; the whole set of 63 documents
renders in 18.5 s and 720 KB.

| Document | Render time (s) | Size (bytes) |
| --- | --- | --- |
| `SoftwareDocumentIndex` | 14.02 | 2502 |
| `SoftwareArchitectureDescription` | 7.36 | 18909 |
| `SoftwareRequirementsSpecification` | 6.38 | 16752 |
| `SoftwareInterfaceControlVolume` | 5.58 | 12464 |
| `FlightDictionaryVolume` | 6.28 | 172789 |
| `SoftwareTestPlan` | 5.19 | 20670 |
| `SoftwareOperationsHandbook` | 4.47 | 12816 |
| `CdhDesignDescription` | 7.10 | 11081 |
| `GncDesignDescription` | 5.50 | 13063 |
| `SepControlDesignDescription` | 6.82 | 10598 |
| `PowerManagementDesignDescription` | 11.55 | 17565 |
| `ThermalControlDesignDescription` | 12.36 | 26139 |
| `TelecomDesignDescription` | 8.88 | 8470 |
| `InspectorHandlingDesignDescription` | 7.14 | 8054 |
| `CaptureControlDesignDescription` | 7.81 | 10124 |
| `AutonomyDesignDescription` | 8.73 | 9537 |
| `FdirDesignDescription` | 7.20 | 15741 |
| `ModeManagementDesignDescription` | 8.65 | 7998 |
| `ParameterBootUpdateDesignDescription` | 10.52 | 9464 |
| `CommandBuilderDesignDescription` | 8.78 | 2005 |
| `SequencerDesignDescription` | 8.98 | 1637 |
| `TelemetryServerDesignDescription` | 13.63 | 1941 |
| `PassPlannerDesignDescription` | 12.89 | 1650 |
| `AnomalyTrackerDesignDescription` | 10.94 | 1531 |
| `ProximityPlannerDesignDescription` | 8.89 | 1734 |
| `FlightDynamicsToolDesignDescription` | 7.87 | 1566 |
| `DataArchiveDesignDescription` | 6.71 | 1703 |
| `FlatsatDesignDescription` | 8.39 | 1546 |
| `CaptureRigDesignDescription` | 9.07 | 1476 |
| `DynamicsSimulatorDesignDescription` | 12.07 | 1531 |
| `TrajectoryToolDesignDescription` | 11.36 | 1674 |
| whole set (`-render-documents`, 63 files) | 18.50 | 719971 |
<!-- measurements:end -->

## Shared runs moved by this package

<!-- shared-runs:start -->
`make runs` re-records every run; the diff against the previous pin falls into these categories
(exact counts in the pull request body):

- loaded-file list and package ticks only: every run that prints `loaded N files` or the `✓ package`
  list gains the two 94 files and the two new packages (the large majority of the modified runs).
- element-id and count shifts: `house-rules` (elements and checks; still 0 violations),
  `list-views` and `render-documents-md` / `render-documents-html` / `render-all` (33 new documents),
  `sw-requirements-counts` and similar count runs (new packages ticked).
- new verify links and verdicts: `requirements-satisfy`, `as-built-satisfy`, `sw-requirements-satisfy`,
  `sw-assurance-release-gate`, `sw-assurance-vcrm`, `sw-assurance-vcrm-document` and the VCRM/matrix
  renders list the software rows each case now verifies; the planned usages print `?` with
  `unbound parameter` — the intended unevaluated state, unchanged in meaning.
- rendered-document anchors: documents another document now refers to with `Ref` gain
  `<a id="…"></a>` anchors (`IcdRegisterDocument`, the five software ICD documents,
  `SoftwareAssuranceReport`, `SoftwareFmecaDocument`, `VvReport`) and their HTML tables gain `id`
  attributes.
- new runs: the `sw-doc-*` runs and the 33 new files under `runs/documents/` and
  `runs/documents-html/`.
<!-- shared-runs:end -->

## Maintainer decisions

1. The derivation rule links some cases to many rows (`autonomousSurvival` fans out to 13 TF rows,
   so `CaptureAbortTest`, `ModeManagementTest`, `AutonomyTest` carry 13–14 links each). Pruning to a
   narrower rule (for example intersecting with the hosting application of the case's verified
   function) is a design choice this package did not take.
2. TF-010/011/012/023 have no verifying case; a bus- and processor-budget analysis case would close
   that gap and is not written here.
3. If the system-case links should live in 23 itself, the file order (23 before 67) must change.
4. The eight register records are `draft 0.1`; the status/version values are the only figures in
   this package that are not derived from other model elements.
