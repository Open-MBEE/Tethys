# Coverage matrix — acceptance criteria for the Tethys model

The model is "complete" when every `must` row of the two reviews below is satisfied by a construct in `model/` and its checkable predicate is run by `make check` (as a house rule, a `-run-query`, a `-satisfy` verdict or a pinned run under `runs/`). `should` rows are expected; `could` rows are taken when cheap. Each work package owns the rows listed against it and records, per row, the file:element that satisfies it and the command that proves it; a row a package cannot satisfy because of the tool becomes an entry in [findings.md](findings.md) and keeps its row open.

Source reviews (kept verbatim; rows are referenced by id, never copied):

- [se-completeness-checklist.md](se-completeness-checklist.md) — systems-engineering artefacts, `SE-###`
- [language-tool-coverage-matrix.md](language-tool-coverage-matrix.md) — language `LANG-###`, tool surfaces `TOOL-###`, libraries `LIB-###`, known soft spots `GAP-###`

## 1. Systems-engineering rows by owner

| Section | Rows | must | should | could | Owner |
| --- | --- | --- | --- | --- | --- |
| 1.1 Programme, lifecycle and technical management | SE-001–SE-020 (20) | 9 | 7 | 4 | backbone |
| 1.2 Stakeholders, needs, concept of operations, measures | SE-021–SE-037 (17) | 12 | 3 | 2 | WP-A requirements+verification |
| 1.3 Requirements | SE-041–SE-065 (25) | 18 | 7 | 0 | WP-A requirements+verification |
| 1.4 Architecture: functional, logical, physical, allocation | SE-071–SE-090 (20) | 9 | 7 | 4 | WP-B orbiter structure+budgets (allocations: WP-J) |
| 1.5 Interfaces and ICDs | SE-101–SE-112 (12) | 9 | 3 | 0 | WP-D ground, operations, ICDs, link budgets |
| 1.6 Engineering budgets (each with allocation, current best estimate, contingency, margin, and a margin policy per phase) | SE-121–SE-146 (26) | 16 | 8 | 2 | WP-B orbiter structure+budgets |
| 1.7 Behaviour, modes, mission sequence, FDIR | SE-151–SE-166 (16) | 12 | 2 | 2 | WP-E mission sequence, modes, FDIR (probe EDL: WP-C) |
| 1.8 Safety, dependability, hazards | SE-171–SE-182 (12) | 3 | 7 | 2 | WP-J safety, risk, allocations |
| 1.9 Analyses, trades, modelling & simulation | SE-191–SE-204 (14) | 7 | 5 | 2 | WP-F analyses, trades, Monte Carlo, external tools |
| 1.10 Verification and validation programme | SE-211–SE-227 (17) | 11 | 3 | 3 | WP-A requirements+verification |
| 1.11 Risk management | SE-241–SE-247 (7) | 2 | 2 | 3 | WP-J safety, risk, allocations |
| 1.12 Mission phases, timeline and events | SE-260–SE-265 (6) | 5 | 1 | 0 | WP-E mission sequence, modes, FDIR |
| 1.13 Production, as-built and configuration | SE-266–SE-275 (6) | 2 | 3 | 1 | WP-I as-built, data import |
| 1.14 Operations products | SE-271–SE-283 (12) | 5 | 4 | 3 | WP-D ground, operations, ICDs, link budgets |
| 1.15 Disposal and closeout | SE-290–SE-292 (3) | 1 | 1 | 1 | WP-I as-built, data import |
| 1.16 Environments (definitions the requirements and budgets refer to) | SE-301–SE-313 (11) | 7 | 1 | 3 | backbone |
| 1.17 Views, documents, model management and house rules | SE-321–SE-329 (9) | 5 | 2 | 2 | WP-H views, documents, layout |
| **Total** | 233 | 133 | 66 | 34 | |

Section 2 of the SE review was written for the earlier Venus-orbiter concept of this model; the small-body / solar-electric domain list that replaces it is [small-body-domain-list.md](small-body-domain-list.md), and it feeds `TethysEnvironment` (backbone) and the subsystem/interface/failure-mode/trade lists of WP-B, WP-D, WP-E and WP-F. Section 3 ("what no published model covers", 20 boundary groups) is the first list every work package checks its constructs against; section 4 (verification-query mechanisms) is the recipe for turning a predicate into a gate.

## 2. Language rows by group

Every group is owned by the work package whose content naturally needs it; constructs nothing needs naturally go to WP-G (variants, KerML physics library, and the notation forms no mission content reaches), which exists to leave no production unexercised.

| Group | Rows | must | should | could |
| --- | --- | --- | --- | --- |
| KerML-only notation (Root Namespace) | 1 | 0 | 0 | 1 |
| KerML-only notation (Elements) | 4 | 0 | 2 | 2 |
| KerML-only notation (Dependencies) | 2 | 2 | 0 | 0 |
| KerML-only notation (Annotations) | 10 | 8 | 0 | 2 |
| KerML-only notation (Namespaces) | 41 | 22 | 11 | 8 |
| KerML-only notation (Packages) | 7 | 3 | 4 | 0 |
| KerML-only notation (Types) | 39 | 26 | 6 | 7 |
| KerML-only notation (Classifiers) | 11 | 7 | 2 | 2 |
| KerML-only notation (Features) | 61 | 35 | 14 | 12 |
| KerML-only notation (Feature Values) | 2 | 0 | 2 | 0 |
| KerML-only notation (Multiplicities) | 7 | 0 | 6 | 1 |
| KerML-only notation (Classification) | 1 | 1 | 0 | 0 |
| KerML-only notation (Classes) | 1 | 1 | 0 | 0 |
| KerML-only notation (Structures) | 1 | 0 | 1 | 0 |
| KerML-only notation (Associations) | 2 | 0 | 2 | 0 |
| KerML-only notation (Connectors) | 15 | 6 | 7 | 2 |
| KerML-only notation (Behaviors) | 3 | 0 | 2 | 1 |
| KerML-only notation (Functions) | 5 | 0 | 3 | 2 |
| KerML-only notation (Expressions) | 3 | 1 | 1 | 1 |
| KerML-only notation (Predicates) | 1 | 0 | 1 | 0 |
| KerML-only notation (Boolean Expressions) | 1 | 0 | 1 | 0 |
| KerML-only notation (Invariants) | 3 | 3 | 0 | 0 |
| KerML-only notation (Interactions) | 15 | 3 | 5 | 7 |
| KerML-only notation (Metadata) | 11 | 3 | 6 | 2 |
| Expressions | 121 | 26 | 32 | 63 |
| Elements & relationships | 3 | 0 | 1 | 2 |
| Dependencies | 2 | 2 | 0 | 0 |
| Comments, documentation, textual representation | 11 | 8 | 0 | 3 |
| Metadata & semantic metadata | 13 | 0 | 10 | 3 |
| Packages, imports, aliases, visibility, filters | 30 | 10 | 14 | 6 |
| Definition & usage (common declaration parts) | 69 | 11 | 39 | 19 |
| Variation, variants, body members | 7 | 4 | 3 | 0 |
| User-defined keywords (extension) | 2 | 0 | 2 | 0 |
| Attributes | 5 | 0 | 5 | 0 |
| Enumerations | 8 | 0 | 8 | 0 |
| Occurrences, individuals, snapshots/timeslices, events | 17 | 5 | 8 | 4 |
| Successions (occurrence shorthand) | 6 | 0 | 2 | 4 |
| Items | 5 | 0 | 5 | 0 |
| Parts | 5 | 0 | 5 | 0 |
| Ports & conjugation | 10 | 0 | 6 | 4 |
| Connections, bindings, successions | 20 | 2 | 14 | 4 |
| Interfaces | 18 | 0 | 14 | 4 |
| Allocations | 7 | 0 | 7 | 0 |
| Flows & messages | 23 | 0 | 11 | 12 |
| Actions | 14 | 0 | 11 | 3 |
| Action nodes (accept, send, assign, if, loops, terminate, control) | 57 | 14 | 21 | 22 |
| Action successions & guards | 5 | 0 | 5 | 0 |
| States | 22 | 0 | 18 | 4 |
| Transitions (trigger, guard, effect) | 14 | 0 | 9 | 5 |
| Calculations | 10 | 0 | 7 | 3 |
| Constraints & assertions | 8 | 2 | 5 | 1 |
| Requirements, subject/actor/stakeholder, assume/require, satisfy | 25 | 2 | 18 | 5 |
| Concerns & framing | 5 | 0 | 5 | 0 |
| Cases & objectives | 9 | 0 | 8 | 1 |
| Analysis cases | 5 | 0 | 5 | 0 |
| Verification cases | 8 | 0 | 8 | 0 |
| Use cases | 6 | 0 | 6 | 0 |
| Views, exposure, rendering | 17 | 2 | 13 | 2 |
| Viewpoints | 5 | 0 | 5 | 0 |
| Renderings | 5 | 5 | 0 | 0 |

## 3. Tool surfaces

| Surface | Rows | must | should | could |
| --- | --- | --- | --- | --- |
| CLI `sysml` | 118 | 47 | 52 | 19 |
| CLI `sysml` — | 2 | 2 | 0 | 0 |
| REPL (`sysml` prompt / Jupyter cell) | 75 | 35 | 40 | 0 |
| gRPC `sysml-grpc` (`api/proto/sysml.proto`) | 31 | 0 | 31 | 0 |
| MCP `sysml-mcp` tool (group every group) | 1 | 0 | 1 | 0 |
| MCP `sysml-mcp` tool (group lsp) | 21 | 0 | 21 | 0 |
| MCP `sysml-mcp` tool (group runtime) | 31 | 0 | 31 | 0 |
| MCP `sysml-mcp` tool (group session) | 29 | 0 | 29 | 0 |
| Jupyter kernel `sysml-jupyter-kernel` | 10 | 4 | 4 | 2 |
| LSP `sysml-lsp` | 18 | 2 | 16 | 0 |
| VS Code extension (`editors/vscode`) | 9 | 0 | 9 | 0 |
| Client | 7 | 1 | 6 | 0 |
| WebAssembly | 5 | 0 | 2 | 3 |

CLI, REPL and `-run-query` surfaces are exercised by every package through `scripts/runs.sh`; gRPC, Jupyter, LSP, VS Code, the MCP server, the language clients and WebAssembly are Phase 5 (walkthrough notebooks and client scripts over the finished model).

## 4. Libraries

| Library | Members listed |
| --- | --- |
| `ISQAtomicNuclear` | 116 |
| `SI` | 110 |
| `ISQElectromagnetism` | 103 |
| `ISQThermodynamics` | 97 |
| `OOSEM` | 93 |
| `ISQMechanics` | 80 |
| `ISQLight` | 70 |
| `MOSA` | 68 |
| `ISQChemistryMolecular` | 68 |
| `ISQCondensedMatter` | 54 |
| `ISQSpaceTime` | 52 |
| `SysMLValidation` | 50 |
| `ShapeItems` | 49 |
| `DocumentQueries` | 46 |
| `ISQInformation` | 46 |
| `Actions` | 29 |
| `ISQCharacteristicNumbers` | 29 |
| `Occurrences` | 27 |
| `RealFunctions` | 26 |
| `Performances` | 25 |
| `RationalFunctions` | 25 |
| `VectorFunctions` | 24 |
| `SequenceFunctions` | 23 |
| `ISQAcoustics` | 23 |
| `DataFunctions` | 21 |
| `IntegerFunctions` | 21 |
| `ComplexFunctions` | 20 |
| `NumericalFunctions` | 20 |
| `ScalarFunctions` | 19 |
| `ControlFunctions` | 17 |
| `ISQBase` | 16 |
| `Time` | 16 |
| `BaseFunctions` | 15 |
| `StateSpaceRepresentation` | 15 |
| `Transfers` | 14 |
| `Views` | 13 |
| `StateMachines` | 13 |
| `NaturalFunctions` | 13 |
| `Requirements` | 12 |
| `SpatialFrames` | 12 |
| `TrigFunctions` | 12 |
| `Objects` | 11 |
| `Collections` | 11 |
| `ScalarValues` | 11 |
| `CollectionFunctions` | 11 |
| `StringFunctions` | 9 |
| `StandardViewDefinitions` | 8 |
| `Clocks` | 8 |
| `FeatureReferencingPerformances` | 8 |
| `OccurrenceFunctions` | 8 |
| `ControlPerformances` | 7 |
| `BooleanFunctions` | 7 |
| `SampledFunctions` | 7 |
| `Flows` | 6 |
| `VerificationCases` | 6 |
| `DiagramLayout` | 6 |
| `MigrationMetadata` | 6 |
| `OpenSysMLMathFunctions` | 6 |
| `Links` | 6 |
| `CausationConnections` | 6 |
| `Interfaces` | 5 |
| `Base` | 5 |
| `Observation` | 5 |
| `VectorValues` | 5 |
| `TradeStudies` | 5 |
| `SpatialItems` | 5 |
| `ModelingMetadata` | 5 |
| `RiskMetadata` | 5 |
| `CauseAndEffect` | 5 |
| `Connections` | 4 |
| `Constraints` | 4 |
| `AnalysisRecords` | 4 |
| `OpenSysMLRenderings` | 4 |
| `RandomFunctions` | 4 |
| `StateSpaceIntegration` | 4 |
| `Triggers` | 4 |
| `ParametersOfInterestMetadata` | 4 |
| `MeasurementReferences` | 4 |
| `DerivationConnections` | 4 |
| `Items` | 3 |
| `States` | 3 |
| `Simulation` | 3 |
| `Metaobjects` | 3 |
| `TransitionPerformances` | 3 |
| `ISQ` | 3 |
| `QuantityCalculations` | 3 |
| `RequirementDerivation` | 3 |
| `Allocations` | 2 |
| `AnalysisCases` | 2 |
| `Calculations` | 2 |
| `Metadata` | 2 |
| `Parts` | 2 |
| `Ports` | 2 |
| `IdentityMetadata` | 2 |
| `StatePerformances` | 2 |
| `AnalysisTooling` | 2 |
| `ImageMetadata` | 2 |
| `Quantities` | 2 |
| `VectorCalculations` | 2 |
| `Cases` | 1 |
| `UseCases` | 1 |
| `StateActivity` | 1 |
| `Stochastic` | 1 |
| `MeasurementRefCalculations` | 1 |
| `SIPrefixes` | 1 |
| `TensorCalculations` | 1 |

## 5. Known soft spots

180 `GAP-###` rows, each with the smallest legitimate Tethys construct that reaches it and the behaviour the specification requires. Every work package includes the GAP rows whose construct falls in its files; the outcome of each (behaves per spec / finding) is recorded in [findings.md](findings.md).

## 6. Status

Filled in per row by the work packages as they land: `docs/coverage/<WP>.md` holds the owner's row → construct → proving command table; this file stays the index.
