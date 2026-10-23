# WP-J coverage — safety, dependability, risk and allocations

Files: `model/85-safety.sysml` (`TethysSafety`), `model/86-risk.sysml` (`TethysRisk`),
`model/87-allocations.sysml` (`TethysAllocations`, mission tier) and
`model/87-allocations-tooling.sysml` (`TethysAllocationQueries`, tool tier). Runs recorded with
OpenSysML built from develop at `0a5fa2d94` (`v0.10.1-2054-g0a5fa2d94`); every command below is a
`run` line in `scripts/runs.sh` and its output is in `runs/<name>.txt`. Findings in
`docs/findings/WP-J.md` (F-J01…F-J04), probes under `model/probes/F-J0*.sysml`.

Result key: **sat** = satisfied by the construct and proven by the command; **sat (finding)** =
construct is spec-correct and accepted by both validators, but OpenSysML cannot evaluate it —
see the finding; **partial** = the row's intent is modelled but part of its predicate is out of
this package's scope; **open** = not covered.

## Safety and dependability (SE-171 – SE-182)

| Row | File : element | Proving command | Result |
| --- | --- | --- | --- |
| SE-171 hazard analysis | `85-safety` : `hazardLog` (TH-001…TH-007: `Hazard` with `severity`, `severityAfterControls`, `phase`, `#cause`/`#effect` occurrences, a `#causation` connection per cause path, `HazardControl`s with `status`, `evidence`, `controlRequirement` → TS-801…TS-808) | `safety-instantiate` (`-instantiate TethysSafety::hazardLog`); `validate`, `house-rules` | sat |
| SE-172 FMECA | `85-safety` : `fmeca` (FM-SEP-01…04, FM-CAP-01…03, FM-PRX-01…03: `FailureMode` with `failedItem`, `lostFunction`, `mode`, `cause`, `localEffect`, `endEffect`, `detection`, `compensatingProvision`, `severity`, `meanTimeToFailure`, `exposure`, derived `failureProbability`, `singlePointFailure`) | `safety-instantiate` (`-instantiate TethysSafety::fmeca`); `safety-calcs` (`FailureProbability(10.0)` = 0.0952) | sat |
| SE-173 fault trees | `85-safety` : `earthImpactTree`, `lossOfCaptureTree` (`BasicEvent` probabilities, `#multicausation` AND gates and `#causation` OR branches with `@CausationMetadata { isNecessary / isSufficient }`, `AndGate`/`OrGate`, `pEarthImpact`, `pCaptureLost`) | `safety-constraints` (`earthImpactTree::earthImpactExcluded` passed); `safety-calcs` (`AndGate(1e-3, 1e-3)`, `OrGate(2e-3, 1e-6)`, `AndGate(2e-2, 2.001e-3)`); `safety-instantiate` (`lossOfCaptureTree`) | sat; the AND-gate instance itself is F-J01 (`safety-fj01-probe`) |
| SE-174 critical items / SPF list | `85-safety` : `criticalItemsList` (`@CriticalItem { rationale; waived }` on `bagDeploymentLatch`, `primaryStructure`, `xenonTank`); `FailureMode::singlePointFailure` | `validate`; `house-rules` | sat |
| SE-175 reliability prediction / RBD | `85-safety` : `Exp`, `Reliability`, `FailureProbability`, `SeriesReliability`, `KOutOfNReliability3of4`, `reliabilityBudget` (per-subsystem MTTF and exposure as `DurationValue`s in `[h]`/`[d]`, ratio converted by the unit system; series bus string × 3-of-4 SEP, `requiredMissionReliability` 0.70) | `safety-constraints` (`reliabilityBudget::reliabilityAllocationMet` passed); `safety-calcs` (`Exp(-0.5)` = 0.60653, `Reliability(10.0)` = 0.90484, `KOutOfNReliability3of4(0.876)` = 0.9223); `safety-instantiate` | sat — the hooks WP-B rolls up |
| SE-176 probabilistic risk assessment | `85-safety` : `earthImpactTree` (per-mission Earth-impact probability 4.0e-5 against `earthImpactLimit` 1.0e-4); `lossOfCaptureTree::pCaptureLost` | `safety-constraints` (`earthImpactExcluded` passed) | partial — point-estimate PRA; the Monte Carlo dispersion run is WP-F/WP-B's `Simulation` tool-tier work |
| SE-177 fault propagation across interfaces | `85-safety` : `FailureMode::propagatesAcross` (FM-SEP-03 → TH-001, FM-CAP-03 → TH-003, FM-PRX-01/02 → TH-002, FM-PRX-03 → TH-004); `Hazard` causes/effects | `safety-instantiate` | sat |
| SE-178 waivers | `85-safety` : `CriticalItem::waived` (two granted, `xenonTank` pending) | `validate` | sat |
| SE-179 safety-critical software | `85-safety` : `safetyCriticalSoftware` (`@SafetyCritical { rationale }` on the final-targeting, abort and HV-inhibit functions); `87-allocations` : `SoftwareFunction` usages `planFinalTargeting`, `abortCapture`, `estimateRelativeState` | `validate`; `allocations-queries` | sat |
| SE-180 launch-site / ground safety data | `85-safety` : `groundSafetyData` (`xenonTankMaximumOperatingPressure`, `hydrazineLoad` from `argent.rcs`, `inhibitCount`), TS-807, TH-006 | `safety-constraints` (`groundSafetyData::twoInhibits` passed) | sat |
| SE-181 contamination and cleanliness | `85-safety` : `contaminationControl` (emissivity / throughput loss allocations, `plumeKeepOut`), TS-808, TH-007 | `validate` | sat |
| SE-182 debris / end of life | `85-safety` : `endOfLifeSafety` (tug disposal Δv and xenon, inspector disposal), TS-806, TH-005 | `safety-constraints` (`endOfLifeSafety::disposalPropellantSufficient` passed) | sat |

## Risk (SE-241 – SE-247)

| Row | File : element | Proving command | Result |
| --- | --- | --- | --- |
| SE-241 risk register | `86-risk` : `riskRegister` (TK-001…TK-006: `RiskItem` with `statement`, `owner`, `likelihood`, `consequence`, derived `score` and `rating`, `status`, `trend`, `mitigationRequirements`, `mitigationActions`, `@Risk { totalRisk … }`) | `risk-instantiate` (`-instantiate TethysRisk::riskRegister`); `risk-register-view` (`-render TethysRisk::riskRegisterView -render-form csv`; the `asElementTable` score/rating/status columns are F-J04); `risk-constraints` (`noUnownedRedRisk` over every entry passed) | sat (table columns: finding F-J04) |
| SE-242 5 × 5 matrix and thresholds | `86-risk` : `Likelihood`, `Consequence` (1–5), `riskMatrix` (red ≥ 15 or catastrophic with likelihood ≥ 3, yellow ≥ 8), `Score`, `RatingOf`, `ToLevel` | `risk-calcs` (`Score(moderate, catastrophic)` = 15, `RatingOf(veryLow, catastrophic)` = green, `(moderate, catastrophic)` = red, `(moderate, major)` = yellow, `(low, moderate)` = green, `(veryHigh, negligible)` = green, `ToLevel(4)` = 0.8) | sat |
| SE-243 burn-down / review snapshots | `86-risk` : `snapshot atSrr`/`atPdr : RiskItem` on every register entry; `burnDown` (`srrTotal`, `pdrTotal`, `currentTotal`, `registerBurningDown`, `earthImpactBurningDown`) | `risk-constraints` (both burn-down constraints "could not be evaluated"); `risk-calcs` (SRR/PDR scores 15 → 10 → 5 for TK-001, 16 → 12 for TK-002) | sat (finding F-J02, `risk-fj02-probe`) |
| SE-244 linkage to requirements, hazards, FMECA | `86-risk` : `RiskItem::relatedHazards`, `relatedFailureModes`, `threatenedRequirements`, `mitigationRequirements` (TK-001 → TH-001, FM-SEP-03, TR-006, TS-801/802 …) | `risk-instantiate`; `validate` | sat |
| SE-245 margin-related indicators | `86-risk` : `marginIndicators` (`xenonMarginFraction` from `argent.sep.xenonMass`, `envelopeMarginFraction` from `TethysSafety::envelopeCases`, triggers and flags) | `risk-constraints` (`marginIndicators::xenonFlagMatchesRegister` passed); `risk-instantiate` | sat |
| SE-246 lessons learned | `86-risk` : `lessonsLearned` (LL-001…LL-003: `LessonLearned` with `source`, `lesson`, `appliedAs`) | `risk-instantiate` (`-instantiate TethysRisk::lessonsLearned`) | sat |
| SE-247 technology risks and fallbacks | `86-risk` : `TechnologyRisk` (TK-006, `readinessNow`/`readinessNeeded`/`fallback`), `technologyPlan` (`variation part captureMechanism` with variants `inflatableBag` / `rigidClaw`) | `risk-constraints` (`technologyPlan::fallbackHoldsNominalTarget` passed) | sat |

## Allocations (SE-081 – SE-090, allocation aspects)

| Row | File : element | Proving command | Result |
| --- | --- | --- | --- |
| SE-081 configuration / envelope | `85-safety` : `envelopeCases` (`bagDiameter` = `argent.captureSystem.maximumBodyDiameter`, nominal = `TethysEnvironment::amaranth.meanDiameter`, small 5 m, large 7.7 m; `EnvelopeMargin` over `LengthValue`s); `87-allocations` : `encloseTarget` → `captureSystem`, `carryLoads` → `structure` | `safety-constraints` (`smallCaseFits`, `nominalCaseFits`, `largeCaseFits`, `largeCaseMarginAsSized` passed) | partial — fit checks only; the layout itself is WP-C |
| SE-082 item / flow definitions | — | — | open (WP-D; no allocation aspect) |
| SE-083 data architecture | `87-allocations` : `handleCommandsAndData`, `archiveScienceData` → `cdh`, `sds` | `allocations-matrix` | partial |
| SE-084 flight software architecture | `87-allocations` : `SoftwareFunction` usages allocated to `gnc` / `cdh`; `softwareHosting` | `allocations-queries`, `allocations-matrix` | partial — hosting only; partitions are WP-E |
| SE-085 ground segment architecture | `87-allocations` : `trackAndCommand`, `determineOrbit`, `operateMission`, `archiveScienceData` → `tethysSystem.ground.network.{stations, fdf, moc, sds}`; TR-005/TR-006 → network / fdf | `allocations-matrix`, `allocations-requirement-matrix` | sat (allocation aspect) |
| SE-086 launch segment architecture | `87-allocations` : `deliverToEscape` → `arcturus5H`; TR-004 → `arcturus5H`, `structure` | `allocations-matrix`, `allocations-requirement-matrix` | sat (allocation aspect) |
| SE-087 design justification | `85-safety` : `HazardControl::evidence`; `86-risk` : `LessonLearned::appliedAs`; `87-allocations` : `Sourcing::source` | `validate` | partial |
| SE-088 make / buy / heritage | `87-allocations` : `Sourcing` metadata (`SourcingKind` make / buy / heritage) on `sourcingRecord` | `allocations-instantiate` (`-instantiate TethysAllocations::sourcingRecord`) | sat |
| SE-089 parts / materials / processes | — | — | open (WP-C) |
| SE-090 MOSA | — | — | open — `MOSA` is a tool-tier library; not needed for the allocation rows |
| function → component | `87-allocations` : `missionFunctions` (21 `MissionFunction` leaves), `FunctionAllocation` (`end :>> source : Action; end :>> target : Part`), `functionAllocations` (21 allocations) | `allocations-queries` (`UnallocatedFunctions root=TethysAllocations::missionFunctions` → 0 rows; negative control `root=TethysRisk::riskRegister` → 14 rows); `allocations-matrix` | sat |
| requirement → component | `87-allocations` : `RequirementAllocation` (`end :>> source : RequirementCheck`), `requirementAllocations` (TR-001…TR-009 → 15 allocations) | `allocations-queries` (`UnallocatedRequirements root=TethysRequirements` → 0 rows; `AllocationTargets origin=TethysRequirements::cislunarSafety`); `allocations-requirement-matrix` | sat |
| allocation matrix view | `87-allocations` : `AllocationMatrixView :> GridView { filter @SysML::AllocationUsage; }`, `functionAllocationMatrix`, `requirementAllocationMatrix` | `allocations-matrix`, `allocations-requirement-matrix` (`-render … -render-form csv`: source rows × component columns) | sat (column naming F-J03) |

## Library rows

| Row | File : element | Proving command | Result |
| --- | --- | --- | --- |
| `RiskMetadata` (`Risk`, `RiskLevel`, `Level`) | `86-risk` : `@Risk { :>> totalRisk { :>> probability; :>> impact } }` on every TK entry, `technicalRisk`/`scheduleRisk` on TK-006; `ToLevel` maps the 1–5 scales onto `Level` | `risk-register-view` (metadata rows), `risk-calcs` (`ToLevel(4)`) | sat |
| `CauseAndEffect` (`#cause`, `#effect`, `#causation`, `#multicausation`, `CausationMetadata`) | `85-safety` : `hazardLog` causations, `earthImpactTree` / `lossOfCaptureTree` gates with `@CausationMetadata { isNecessary; isSufficient; probability }` | `safety-instantiate`, `safety-constraints`; `safety-fj01-probe` | sat (F-J01 on `-instantiate` of multicausation ends) |
| `Allocations` (`allocation def`, `allocate … to …`) | `87-allocations` : `FunctionAllocation`, `RequirementAllocation`, 36 allocation usages | `allocations-queries`, `allocations-matrix` | sat |
| OOSEM allocations (`LogicalComponent` / `PhysicalComponent`) | not used: OOSEM is a tool-tier library and the standard `Allocations` + `Actions` / `Parts` typing covers every row above without it | `tiers` | by design |
