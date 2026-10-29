# WP-SW-8 coverage — software safety, assurance and V&V

Files: `model/88-software-assurance.sysml` (`TethysSoftwareAssurance`, mission tier, standalone on
the pinned pilot) and `model/88-software-assurance-tooling.sysml` (`TethysSoftwareAssuranceTooling`,
tool tier, the `DocumentQueries` queries and documents). No backbone file is edited: the software
causes, controls and the fault tree bind into `TethysSafety` by `#cause`/`#effect` occurrences and
`connect` links to the hazards' own cause events, so `85` did not need a software cause type.
Runs recorded with the pinned OpenSysML `5cd37f288` (`runs/tool-version.txt`); every command below
is a `run` line in `scripts/runs.sh` and its output is in `runs/<name>.txt`. Findings and probes:
`docs/findings/WP-SW-8.md` (F-SW801, F-SW802),
`model/probes/F-SW801-reference-subsetting-value.sysml`,
`model/probes/F-SW802-verification-usage-as-value.sysml`. The fault-tree gate diagnostic under
`-instantiate` is the already-recorded F-J01 (`docs/findings/WP-J.md`), so the fault-tree run reads
its probabilities with `-e` alone.

Verdicts are honest: 10 of the 41 verification cases pass, all of them model-in-the-loop cases
whose measurements are the pinned runs they name; the 31 unit, integration, flight-software-in-
the-loop, hardware-in-the-loop and flatsat cases are `planned` with their measured inputs unbound.
The release-readiness gate SA-001/SA-002 is **open** (`violated`) because the level-A independent
V&V is `inProgress`; that is the intended state of this baseline, not a defect.

## Scope rows

| Row | File : element | Proving command | Result |
| --- | --- | --- | --- |
| SW-044 software criticality / assurance levels with required V&V per class | `88` : `enum def SoftwareAssuranceLevel` (A–D), `metadata def Assurance`, `part def SoftwareClassification` / `FlightSoftwareClassification` / `GroundSoftwareClassification` (`independentVvRequired = level == levelA`), `part classificationRegister` — 23 flight rows (board support, Kestrel executive, 9 services, 12 applications) and 12 Meridian rows, each with a rationale naming the hazards of `TethysSafety::hazardLog` it controls or causes; `assert constraint flightRowsAreDistinct`, `groundRowsCoverTheSuite` | `sw-assurance-classification-counts` (`flightRowCount 23 == flightComponentCount 23`, `groundRowCount 12 == groundComponentCount 12`, `levelACount 9`); `sw-assurance-classification` (35 rows, `name/level/rationale`); `sw-assurance-unclassified` (0 rows, the gate) | sat |
| SW-043 software safety: hazard → software control → inhibit, criticality, independent monitors | `88` : `occurrence def SoftwareHazardCause` / `SoftwareControl` (`SoftwareControlKind` inhibit / twoStepCommand / fdirResponse), `occurrence softwareHazardAnalysis` — 11 software causes connected to the seven hazards' cause events (`hazardLog.earthImpactByTarget.erroneousFinalTargeting`, `…tugTargetCollision.relativeNavigationLoss`, …) and 14 controls naming the component, the `TethysSafety::HazardControl` they are part of and their evidence (65 `noFireWithoutInhibits`, 64/69 two-step approvals, 62 `FaultResponse`s); `occurrence prematureCinchTree` (four software `BasicEvent`s, `#multicausation` gates in 85's style, `topEventProbability` vs `perCaptureBudget`); `constraint def InhibitIndependence` and `part inhibitIndependence` (three capture inhibits, two thruster inhibits, distinct owners and partitions, `cinchChainFiresOnlyWhenArmed` from 62's `armedChain`/`inhibitedChain`) | `sw-assurance-hazard-analysis` (`hazardCount 7`, `softwareCauseCount 11`, `softwareControlCount 14`); `sw-assurance-fault-tree` (`allInhibitsLostProbability 1.0e-10`, `topEventProbability 1.0001e-6`, `perCaptureBudget 1.0e-5`); `sw-assurance-fault-tree-events` (9 events); `sw-assurance-inhibit-independence` (`cinchChainFiresOnlyWhenArmed true`); the SMT record stays `runs/fdir-inhibit-chain-smt.txt` (constraint not encoded — not a proof, see WP-SW-3) | sat |
| SW-043 (cont.) software FMECA | `88` : `occurrence def SoftwareFailureMode` (component, failure mode, local/end effect, `DetectionMeans`, `FaultResponse`, `Severity`, level, hazards), `occurrence softwareFmeca` SFM-01…SFM-13 (executive + twelve applications), `assert constraint catastrophicRowsAreLevelA` | `sw-assurance-fmeca` (13 rows), `sw-assurance-fmeca-counts` (`rowCount 13`, `catastrophicRowCount 3`), `sw-assurance-fmeca-document` (`SoftwareFmecaDocument`, FMECA + fault-tree tables) | sat |
| SW-044 (cont.) assurance activities and release gate | `88` : `action def AssuranceActivity` (`ActivityStatus` planned / inProgress / complete, `independent`, `evidence`), `CodingStandardCompliance`, `StaticAnalysis`, `PeerReview`, `UnitTestWithCoverage`, `IndependentVerificationAndValidation`; `part def LevelAssurancePlan`, `part assurancePlan` (levels A–D, 17 activities, 11 complete; level A 4 of 5, the independent V&V `inProgress`); `requirement def ReleaseReadinessGate`, `requirement <'SA-001'> releaseReadiness`, `<'SA-002'> levelAHasIndependentVv`, `part releaseGateSatisfaction` (`satisfy … by assurancePlan.levelA`) | `sw-assurance-plan` (`levelA.activityCount 5`, `levelA.completeCount 4`, `levelAComplete false`, `levelAIndependentVvPlanned true`, `activityCount 17`, `completeCount 11`); `sw-assurance-release-gate` (`-satisfy=TethysSoftwareAssurance`: SA-001 and SA-002 `violated`, `plan.allComplete` false — the gate is open by design); `sw-assurance-release-report` (`SoftwareAssuranceReport`) | sat (gate open) |
| SW-045 software V&V levels: unit, integration, FSW-in-the-loop, HIL, flatsat, model-in-the-loop | `88` : `enum def SoftwareTestLevel`, `VerificationVerdict` (planned / pass / fail), `metadata def SoftwareVerification` (level, testBed, verdict, evidence), `verification def SoftwareVerificationCase` (`verifiedFunctions : SoftwareFunction`) and 16 subclasses in 23's style (subject, measured inputs, `objective { verify … }`, `PassIf`), 41 `verification` usages with `@SoftwareVerification` and `@Verification { method; level; stage }`, one function per usage by subsetting (`ref :>> verifiedFunctions :> missionFunctions.<f>`); the model-in-the-loop cases bind their measurements to the pinned runs (`fdir-earth-impact-*`, `sw-autonomy-engine`, `sw-failover`, `sw-sep-string-restarting`, `sw-capture-controller-check*`, `fdir-inhibit-chain-held`, `sw-fdir-command-loss-expired`, `sw-mode-manager-*`, `sw-boot*`, `sw-ground-sequencer-check`, `wpd-flight-rules`) | `sw-assurance-model-cases` (10 `-analysis` cases, all `verdict: pass`, `standing: holds`); `sw-assurance-vcrm` (41 rows: level, test bed, verdict, evidence, method, `verifies` list, `rows` count); `sw-assurance-passed` (10 rows, all `modelInTheLoop`); `sw-assurance-vcrm-document` (`SoftwareVcrmDocument`: VCRM, function coverage, uncovered, passed) | sat |
| SW-045 (cont.) coverage: every software function has a case; every hazardous command has an inhibit test | `88-tooling` : `SoftwareFunctions` (usages typed `TethysAllocations::SoftwareFunction` outside the assurance package and the `SoftwareHosting` end), `SoftwareFunctionCoverage` (`verifiedBy` list and `cases` count through incoming subsetting, `hostedOn` through allocation), `UncoveredSoftwareFunctions` (incoming subsetting absent); `88` : `part hazardousCommandInhibitRegister` (the 51 `hazardous` mnemonics of `flightDictionary` in three chains, `testedCount`, `allTestedAreHazardous`), `verification hazardousCommandInhibitModel` (`inhibitTestedCount == hazardousCommandCount`) | `sw-assurance-coverage` (14 rows, every `cases ≥ 1`); `sw-assurance-uncovered` (0 rows, the gate); `sw-assurance-inhibit-coverage` (`testedCount 51`, `allTestedAreHazardous true`, `flightDictionary.hazardousCommandCount 51`) | sat |
| SW-080 software safety analysis report (WP-SW-9 row) | `88-tooling` : `SoftwareAssuranceReport` (classification register, unclassified gate, release-gate rows) and `SoftwareFmecaDocument` render the hazards/controls/criticality content; the SMT record embedding stays with WP-SW-9's `AnalysisRecords` | `sw-assurance-release-report`, `sw-assurance-fmeca-document` | partial (WP-SW-9 owns the report shell) |
| SW-244 software verification cases in 23 typed by 69's test beds | placed in `88` rather than `23` (no backbone edit): `SoftwareVerification::testBed` names the 69 simulators ("Meridian Mirror" FSW-in-the-loop, "Meridian Anvil" HIL, flatsat, "Meridian Orrery" dynamics); the integration step may retype the test beds to `TethysVerification::testBeds` | `sw-assurance-vcrm` (`testBed` column) | sat (in 88) |
| SW-251 software hazards/controls, `SoftwareClass`, `Assurance` metadata in 85/86 | placed in `88` (no backbone edit): `Assurance` metadata and the classes live in `TethysSoftwareAssurance`, bound to `TethysSafety` by `connect` to the hazards' cause events and `partOf : HazardControl` references; software risks are not added to 86 (86's register already carries the software-development risk rows) | `sw-assurance-hazard-analysis`, `sw-assurance-classification` | sat (in 88) |

## Backbone changes

None. `85` did not need a software hazard cause type: `SoftwareHazardCause` is an `occurrence def`
whose usages are `#cause` occurrences connected (`connect … to hazardLog.<hazard>.<causeEvent>`)
to the cause events each hazard already declares, and `SoftwareControl::partOf` references the
existing `HazardControl` usages. `67` is untouched and no TF-/TM- id is referenced; the cases verify
the system rows (TS-/TA-/TC-/TG- in 21/22, FR-00x in 53, GS-00x in 69).

## Measurements

| Table / command | Rows | Time (pinned tool, this VM) |
| --- | --- | --- |
| `SoftwareFmecaRows` (`-run-query`) | 13 | 12.2 s cold cache, ~4 s warm |
| `SoftwareVcrm` (`-run-query`, 41 cases × 8 columns) | 41 | ~4.5 s |
| `SoftwareFunctionCoverage` / `UncoveredSoftwareFunctions` | 14 / 0 | ~4.5 s each |
| `ClassificationRows` / `UnclassifiedSoftwareRows` | 35 / 0 | ~5 s each |
| `SoftwareFmecaDocument` (`-render-document`) | 162 lines | 4.1 s |
| `SoftwareVcrmDocument` (`-render-document`) | 249 lines | 4.4 s |
| `SoftwareAssuranceReport` (`-render-document`) | 180 lines | 4.2 s |
| `-satisfy=TethysSoftwareAssurance` (2 satisfy assertions over the 17-activity plan) | 2 | 4.8 s |
| `-analysis` of the 10 model-in-the-loop cases | 10 | one process, ~6 s |

Boundary: at these sizes every query, document and `-satisfy` evaluation is dominated by the
~4 s load of the 60-file model; row count does not show. `-engine check` is not applied to the
assurance tables (they are registers, not state machines): the inhibit property is checked
exhaustively in the existing `sw-capture-controller-check*` and `fdir-inhibit-chain-check` runs,
which the model-in-the-loop cases cite as evidence. The scaling limit met is semantic, not
performance: a verification usage with an unbound `in` cannot be read at all (F-SW802), which is
why the per-case level/verdict/evidence live in `SoftwareVerification` metadata and the counts come
from the queries rather than from a model-side register.

## Runs added

`sw-assurance-classification`, `sw-assurance-unclassified`, `sw-assurance-classification-counts`,
`sw-assurance-hazard-analysis`, `sw-assurance-fmeca`, `sw-assurance-fmeca-counts`,
`sw-assurance-fmeca-document`, `sw-assurance-fault-tree`, `sw-assurance-fault-tree-events`,
`sw-assurance-inhibit-independence`, `sw-assurance-inhibit-coverage`, `sw-assurance-plan`,
`sw-assurance-release-gate`, `sw-assurance-release-report`, `sw-assurance-coverage`,
`sw-assurance-uncovered`, `sw-assurance-vcrm`, `sw-assurance-passed`, `sw-assurance-vcrm-document`,
`sw-assurance-model-cases`, `sw-assurance-probe-reference-subsetting`, `sw-assurance-probe-case-value`.

## Integration asks

- WP-SW-5's TF-/TM- rows: add `verify` links from the 41 cases' objectives once 67 is on the
  same base; the cases already verify the system rows the software satisfies.
- The planned cases become `pass`/`fail` only by binding their measured inputs to a test report
  and changing `SoftwareVerification::verdict`; nothing else in the model should move.
- The release gate opens when `assurancePlan.levelA.independentVv.status` is set `complete` with
  its evidence — a maintainer decision, not a model fix.

## Shared runs moved by this package

`make runs` re-records 163 existing runs; by category:

- **File-set lines (151 runs).** `loaded 58 files` → `loaded 60 files` and the two new
  `✓ package TethysSoftwareAssurance` / `✓ package TethysSoftwareAssuranceTooling` validation lines.
  Nothing else in those runs changes.
- **Instance-id shifts (3 runs).** The whole-model `-satisfy` runs `requirements-satisfy`,
  `as-built-satisfy` and `wpb-budgets-satisfy`: `tethysSystem.flight ID: 8` → `ID: 37` and the
  like; every pre-existing verdict is unchanged.
- **New verdicts (9 runs).** The same three `-satisfy` runs now also list the software cases under
  the system rows they verify: the 10 model-in-the-loop cases `pass`; the 31 planned cases print
  `? … verdict: error — unbound parameter` — the honest state is `@SoftwareVerification.verdict =
  planned`, the `?` line is F-SW802 (a planned case with unbound inputs cannot be evaluated at
  all); and `SA-001`/`SA-002` appear as `violated` because the release gate is open at this
  baseline. `vv-report`, `vv-matrix-l2` and `documents{,-html}/TethysVerificationTooling-VvReport`:
  the TS-/TA-/TC-/TG- rows gain the software cases in `verifiedBy`/`cases` (e.g. TS-001 now 2
  cases). `house-rules`: 72,638 → 75,271 elements, 0 violations. `list-views`,
  `render-documents-md`, `render-documents-html`: the three new documents.
