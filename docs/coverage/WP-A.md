# WP-A coverage — requirements tree and verification programme

Files: `model/20-stakeholders.sysml` (`TethysStakeholders`), `model/21-requirements-l2.sysml`
(`TethysRequirementsL2`), `model/22-requirements-l3-l4.sysml` (`TethysRequirementsL3L4`),
`model/23-verification.sysml` (`TethysVerification`, mission tier) and
`model/24-verification-tooling.sysml` (`TethysVerificationTooling`, tool tier: DocumentQueries).
Findings: `docs/findings/WP-A.md` (F-A01…F-A06). Every command below is pinned in `runs/` through
`scripts/runs.sh`; `V` = `make validate`, `P` = `make pilot`, `H` = `make house-rules`,
`S` = `runs/requirements-satisfy.txt`, `A` = `runs/verification-cases.txt`,
`Q` = `runs/unverified-requirements.txt` / `runs/vv-matrix-l2.txt` / `runs/vv-report.txt`.

Status: **done** = construct present and its proving run is green; **partial** = present, part of
the row's intent is outside what the backbone or the tools let this package prove; **open** = not
modelled.

## SE rows

| row | file : element | proving command | status |
|---|---|---|---|
| SE-021 | 20 : `Stakeholder`, `stakeholderRegister` (8 stakeholders with role/influence/engagement) | V, P | done |
| SE-022 | 20 : `concern def` ×6, `concern` usages bound to the register | V, P | done |
| SE-023 | 20 : `StakeholderNeed`, `N-001`…`N-009`; `#refinement dependency` from TR-001…TR-009 to the needs | V, P, H | done |
| SE-024 | 20 : `ScienceObjective`, `SO-001`…`SO-004` (measurement → objective → TR-003/TR-008 by `#refinement`) | V, `vv-report` | done |
| SE-025 | 20 : `minimumSuccess` {`MS-001`, `MS-002`}, `fullSuccess` {`FS-001`, `FS-002`} (requirement groups) | V; verified by `successCriteriaValidation` (A) | done |
| SE-026 | 20 : `MissionMeasures` `#moe` attributes (`returnedMass`, `returnedMassPerXenon`, `timeToDelivery`, `earthImpactProbability`, `targetEnvelopeCoverage`) bound in `missionMeasures` | V, P | done |
| SE-027 | 20 : `MissionMeasures` `#mop` attributes (`sepThrust` from `SepThrust`, `stackAcceleration`, …) | V, P | done |
| SE-028 | 20 : `TechnicalPerformanceMeasure` (allocation, CBE, contingency, predicted, margin), `technicalPerformanceMeasures` ×5, `MarginAtLeast` asserts | `runs/tpm-margins.txt` (5/5 hold) | done |
| SE-029 | 20 : `RetrieveAmaranth`, `retrieveAmaranth` (design reference mission as included use cases in phase order) | V, P | done |
| SE-030 | 20 : `use case def` ×10 (one per phase plus `RecoverFromSafeMode`) with `subject`, `actor`s, `include`, `first…then` | V, P | done |
| SE-031 | 20 : `missionContext` (`ExternalBody` sun/earth/moon, `ref part system :> tethysSystem`, target, visitor) | V, P | done |
| SE-032 | 20 : `Capability`, `capabilities` ×9 | V, P | done |
| SE-033 | 20 : `DrivingRequirement` metadata; applied to TS-001, TS-003, TS-004, TS-008, TS-019, TA-009 | V | done |
| SE-034 | 20 : `targetCases` small/nominal/large/dense (+ `TargetCase` variation), `ProgrammeAssumptions`; 21 : `assume constraint` in TS-002, TS-006 | V, P, S | done |
| SE-035 | 20 : `N-007`, `Operator` actor; 21 : TS-013, TS-022; 22 : TG-005, TG-006 | S, A (`groundReadinessDemo`) | done |
| SE-036 | 21 : `SafetyRequirement` TS-008 (Earth-impact exclusion), TS-009 (DRO stability), `safetyRequirements` group (cislunar return reading per domain list §8) | S, A (`returnSafetyAnalysis`) | done |
| SE-037 | 23 : `MissionValidation`, `SuccessCriteriaValidation`, `ConOpsValidation` (`verify` the needs; demo verdicts) | A | done |
| SE-041 | 04 (backbone) TR-001…TR-009; 23 verifies each (`DeliveryAnalysis`, `CharacterisationAnalysis`, `ReturnSafetyAnalysis`, …) | Q (`unverified-requirements` = 0 rows) | done |
| SE-042 | 21 : TS-001…TS-022 on `TethysFlightSegment` / `TethysGroundSegment` / interface defs | V, P, S (18/18 hold) | done |
| SE-043 | 22 : TA-001…TA-014 (tug subsystems), TW-001…TW-005 (inspector), TG-001…TG-007 (ground) | V, P, S (49/49 hold) | done |
| SE-044 | 22 : TC-001…TC-006 (`ComponentRequirement`) | V, P, S | done |
| SE-045 | 21, 22 : `#derivation connection { end #original ::> …; end #derive ::> …; }` L1→L2 (9), L2→L3 (14), L3→L4 (5) | V, P; `vv-matrix-l2` `derivedFrom` column | done |
| SE-046 | 20 : `#refinement dependency` needs ← L1, objectives → L1; 21 : L2 attributes bound to `TethysEnvironment` calcs (`RocketEquationDeltaV`, `SolarFlux`, `SepThrust`) | V | done |
| SE-047 | all : `<'ID'>` shortName, `doc`, `@Verification {method, level, stage}`, `@StatusInfo {owner, status}`, `@Rationale`, `tier` | V, H | done |
| SE-048 | 21, 22 : `require constraint` over ISQ-typed attributes with SI unit literals | S | done |
| SE-049 | 21 : `l2Satisfaction`; 22 : `l3l4Satisfaction` (`satisfy … by argent.sep`, `tethysSystem.ground`, …) | S | done — `TethysFlightSegment::tug` and `inspector` are bound to `argent` and `wren` at integration, so `tethysSystem.flight.tug` carries the configured values through the binding; no recorded `satisfy` reads through `tethysSystem.flight.tug`, the tug requirements keep `argent` as their satisfier |
| SE-050 | 21 : `flightPerformanceRequirements`, `flightSafetyAndAutonomyRequirements`, `flightEnvironmentAndBudgetRequirements`, `interfaceRequirements`, `groundSegmentRequirements`, `safetyRequirements` | V; `documentInspection` (A) | done — groups ≤ 6 members (F-A02) |
| SE-051 | 21 : `InterfaceRequirement` TS-006 (`SpacecraftLauncherInterface`), TS-007 (`SpaceGroundLink`), TS-012 (`DockingInterface`) with `icd` | S | done |
| SE-052 | 21 : `EnvironmentalRequirement` TS-014 (contact and perihelion flux); 22 : TA-004, TA-011; 23 : `environmentalTestMatrix` | S, A (`contactSpeedTest`, `thermalBalanceTest`) | done |
| SE-053 | 21 : `PerformanceRequirement` TS-001, TS-003, TS-005, TS-011, TS-019; 22 : TA-001, TA-009 | S, A | done |
| SE-054 | 21 : `FunctionalRequirement` TS-010, TS-013, TS-018, TS-020, TS-022; 20 : `capabilities` | S | partial — functions are the capability register, not WP-B/WP-C action trees |
| SE-055 | 21 : `SafetyRequirement` TS-008, TS-009; TS-010 (TR-007), TS-015; `safetyRequirements` group | S, A (`redundancyInspection`, `returnSafetyAnalysis`) | done |
| SE-056 | 21 : `SoftwareRequirement` TS-015, TS-021; 22 : TA-010, TC-005 | S, A (`faultResponseTest`) | done |
| SE-057 | 21 : TS-020…TS-022; 22 : TG-001…TG-007 | S, A (`groundReadinessDemo`, `groundProceduresDemo`) | done |
| SE-058 | 24 : `VvMatrix` query (`verifiedBy`, `cases`, `satisfiedBy`, `derivedFrom`), `VvReport` document; 23 : `VvMatrix` views `l1Matrix`…`verificationCases` | Q (`vv-matrix-l2`, `vv-report`) | done — views expose members one by one (F-A04) |
| SE-059 | 20 : TPM `marginFraction`, `MarginAtLeast`, `pdrMassMargin`; 21 : TS-016 margin constraint | `tpm-margins`, S | done |
| SE-060 | 21 : `@StatusInfo { status = StatusKind::tbr }` TS-004, TS-012; `tbd` TS-018; 22 : TA-012 tbr, TA-013 tbd; `@Rationale` on each | V | done |
| SE-061 | 21 : `allocation … allocate <group> to tethysSystem.flight / .ground` | V, P | done |
| SE-062 | 21 : `BudgetRequirement` TS-004 (xenon split), TS-016 (dry mass allocation) | S, A (`propellantAnalysis`, `massBudgetAnalysis`) | done |
| SE-063 | 99 (backbone) `requirementHasDocumentation`, `definitionHasDocumentation` over every WP-A element; IDs on every requirement | H (0 violations) | done — `requirementHasText` (every `RequirementUsage` has a non-empty derived `text`) joined the backbone house rules at integration; a "single shall / no TBD" wording rule would be stricter than the spec and is not added |
| SE-064 | 21 : `VerificationRequirement` TS-017; 23 : `TestSpecification` (procedure, facility, report) on every usage | V, A (`captureEnvelopeTest`) | done |
| SE-065 | 21 : `Waiver` metadata on TS-013 (relief, scope, approvedBy, expires) | V | done |
| SE-211 | 23 : package doc, `TestSpecification`/`Closure`/`CampaignStep` vocabulary, `testBeds`, `testCampaign`, methods per `VerificationMethod` | V, P | done |
| SE-212 | all requirements : `@Verification { method = … }`; 23 : `metadata VerificationMethod about <Def>` for every case | V | done — declared with `about` (F-A06) |
| SE-213 | all requirements and 23 usages : `@Verification { level = VerificationLevel::…; stage = VerificationStage::… }` | V | done |
| SE-214 | 23 : 33 `verification` usages, each def ending in `PassIf(…)` | A (33/33 `verdict: pass`) | done |
| SE-215 | 23 : `testCampaign` (`CampaignPhase` ×5 with `first…then`), `RunCampaign`/`runCampaign`, `@CampaignStep` on test usages | `runs/test-campaign.txt` | done |
| SE-216 | 23 : `EnvironmentalTest`, `environmentalTestMatrix` ×5 (TVAC, vibration, cold start, bag deployment, EMC) | V | done |
| SE-217 | 23 : `@TestSpecification { procedure; facility; report }` on every usage | V | done |
| SE-218 | 23 : `in` as-run values on every test/demo usage (`measuredThrust = 1.86 [N]`, …) feeding the verdict | A | done |
| SE-219 | 23 : `@Closure { closedBy; evidence; status }` on every usage (5 `open`, 2 `tbr`) | V; `VerificationOutcomes` query | done |
| SE-220 | 23 : `@Nonconformance` NCR-017 on `contactSpeedTest` | V | done |
| SE-221 | 23 : `ConOpsValidation`, `GroundReadinessDemo`, `MissionValidation`, `SuccessCriteriaValidation` | A | done |
| SE-222 | 23 : `TestBed`, `testBeds` (flatsat, captureRig, dynamicsSimulator, trajectoryTool) referenced by `facility` | V | done |
| SE-223 | 23 : `ProximityNavigationTest` camera limiting-magnitude bench measurement | A | partial — no calibration-data construct |
| SE-224 | 23 : `@HeritageQualification` on `cinchMotorTest` | V | done |
| SE-225 | 23 : `SepCommissioning`, `InspectorCommissioning`, `DockingDemo` (stage `inFlight`) | A | done |
| SE-226 | 24 : `UnverifiedRequirements` (requirement → verification gap, 0 rows; a removed `verify` adds a row), `VvMatrix` (verification → requirement) | Q | done |
| SE-227 | 23 : `ThrustModelValidation` (`SepThrust` within 3 % of the hot-fire measurement) | A | done |

## LANG rows

| row | construct in WP-A | proving command | status |
|---|---|---|---|
| LANG-760…764, 777, 778 | `requirement`, `requirement def`, bodies with `doc`, attributes, constraints, metadata (20–22) | V, P | done |
| LANG-765, 766 | `subject` in every requirement, concern, viewpoint, use case and verification def | V, P | done |
| LANG-767…769 | `assume constraint` (TS-002, TS-006), `require constraint` throughout 20–22 | S | done |
| LANG-770…772 | `frame concern framed… :> …` in the viewpoint defs (20) | V, P | done |
| LANG-773, 774 | `actor operator : Operator`, `actor visitor : VisitingVehicle` (20) | V, P | done |
| LANG-775, 776 | `stakeholder` in concern defs and bound in concern usages (20) | V, P | done |
| LANG-779, 781…784 | `satisfy … by …` in `l2Satisfaction`, `l3l4Satisfaction` | S | done |
| LANG-780 | `not satisfy` | — | open — no requirement of the tree is asserted unsatisfied |
| LANG-785…789 | `concern def`, `concern` usages (20) | V, P | done |
| LANG-790…798 | case bodies and `objective { … }` of the use case and verification defs (20, 23) | V, P, A | done |
| LANG-804…811 | `verification def`, `verification` usages, `verify` (23) | A | done |
| LANG-812…817 | `use case def`, `use case`, `include use case` (20) | V, P | done |
| LANG-835…839 | `viewpoint def`, `viewpoint` usages, `satisfy verificationViewpoint` in `VvMatrix` (20, 23) | V, P | done |
