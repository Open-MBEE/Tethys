# WP-H — views, viewpoints, documents and layout

Owned files: `model/90-views.sysml` (`TethysViews`, mission tier), `model/91-documents.sysml` (`TethysDocuments`),
`model/92-layout.sysml` (`TethysLayout`) and `model/93-views-tooling.sysml` (`TethysViewsTooling`: the `asMixedDiagram` view; tool tier); runs under `runs/` from the WP-H lines of `scripts/runs.sh`.
Gate build: OpenSysML `v0.10.1-2054-g0a5fa2d94` (develop 0a5fa2d94, built from source) (`runs/tool-version.txt`), pilot 2026-08 (0.62.0)
standalone on the mission tier (`make pilot-mission`) and as the batch validator with the OpenSysML
libraries as an extension library on every file (`make pilot-all`).

Every command below is `sysml … model/*.sysml`; `make check` runs them all through `scripts/runs.sh`.

## Systems-engineering rows (SE-321–SE-329)

| Row | Level | Construct | Proving command | Result |
| --- | --- | --- | --- | --- |
| SE-321 | must | `90-views.sysml`: 7 `StakeholderRole` part defs, 7 `concern def`s each naming its stakeholders (`RequirementTraceability`, `InterfaceControl`, `BudgetClosure`, `MissionSequence`, `ModeBehaviour`, `VerificationCoverage`, `RiskExposure`), 5 `viewpoint def`s framing them (`RequirementsViewpoint`, `InterfaceViewpoint`, `BudgetViewpoint`, `OperationsViewpoint`, `AssuranceViewpoint`) and one viewpoint usage each | `-validate -strict -warnings-as-errors` (`runs/validate.txt`); every role is a stakeholder of ≥1 concern and every concern is framed by ≥1 viewpoint, by inspection of the file | satisfied |
| SE-322 | must | 13 view usages with `expose`/`filter`/`render`/`satisfy`: `requirementsTree`, `requirementsTable`, `segmentInterfaces`, `flightSegmentWiring`, `tugPowerBus`, `interfaceDefinitions`, `massBudget`, `missionTimeline`, `projectLifecycle`, `modeMachine`, `environmentText`, `systemOverview` (+ subview `interfaces`); each viewpoint is satisfied by ≥1 view | `-render-all runs/views` (`runs/render-all.txt`, 18 files); `-list all` (`runs/list-views.txt`) | satisfied; `environmentText` is skipped by the tool (F-H03), `modeMachine` exposes the tug until the mode package lands its state def (note pinned) |
| SE-323 | could | `92-layout.sysml`: `Layout` (with `collapsed`) about the five segment parts, `Route` about the four system interfaces, `Style`, `Note` (`Canvas` not used: it must sit in the view body, which would pull `90-views.sysml` into the tool tier) | `-render TethysViews::segmentInterfaces -render-form dot` (`runs/render-segment-interfaces-dot.txt`: `pos=`/`pin=true` per node) | satisfied (extension, non-normative) |
| SE-324 | must | `91-documents.sysml`: `SystemDescription`, `InterfaceControlDocuments`, `VerificationMatrix`, `RiskRegister` over 15 `DocumentQueries` queries (incl. evaluated `Column(cell = …)` mass-budget columns), with `Table`, `List`, `Definitions`, `Diagram`, `Span`/`Ref` cross-document links | `-render-documents runs/documents` exit 0 (`runs/render-documents-md.txt`); `-render-documents … -doc-form html` exit 0 (`runs/render-documents-html.txt`); `-render-document TethysDocuments::SystemDescription -doc-form pdf -doc-toc -doc-number-sections -o SystemDescription.pdf` with OpenSysML's pinned doc toolchain (WeasyPrint, mmdc, dot): 7 pages, byte-identical on a second run | satisfied for md and html (pinned); pdf proven locally, not pinned (converter-dependent bytes, no toolchain in CI — see PR body) |
| SE-325 | should | `-convert api-json` of the whole model | two conversions compared with `cmp`: identical (5 687 distinct `@id`s) | satisfied locally; the 6 MB export is not pinned under `runs/` |
| SE-326 | must | the backbone's `TethysHouseRules` over the WP-H files (every def documented, every requirement usage — incl. `satisfy`, `frame`, concern and viewpoint usages — documented, every port typed) | `-validate -self-check-package TethysHouseRules` (`runs/house-rules.txt`): 0 violations, 0 unevaluated | satisfied |
| SE-327 | must | the three files | `-validate -strict -warnings-as-errors` exit 0; pilot batch validator exit 0 (10 pilot warnings `Bound features should have conforming types` on `calc rows : <Query>;` and `ref redefines source = <view>` — the DocumentQueries binding pattern) | satisfied |
| SE-328 | could | element counts from the api-json export (`"@type"` histogram: 97 PartUsage, 45 PartDefinition, 13 ViewUsage, 9 RequirementUsage, 9 InterfaceDefinition, 7 ConcernDefinition, 5 ViewpointDefinition) | `-convert api-json -o model.api.json` then `grep -o '"@type": *"[^"]*"' \| sort \| uniq -c` | recorded here, not pinned |
| SE-329 | should | `runs/tool-version.txt` names the OpenSysML build every pinned run was recorded with | `-version` (`run tool-version` in `scripts/runs.sh`) | satisfied |

## Language rows

| Row | Construct | Result |
| --- | --- | --- |
| LANG-818–822, 826–829 (view def / view usage / bodies) | `view def RequirementsTreeView { filter …; render asTreeDiagram; }`, `view requirementsTree : RequirementsTreeView { … }` | satisfied (`runs/validate.txt`) |
| LANG-823 ViewRenderingMember | `render asTreeDiagram;`, `render budgetTable;` | satisfied |
| LANG-824 ViewRenderingUsage (reference form) | `render budgetTable;` in `BudgetView` | satisfied |
| LANG-825 ViewRenderingUsage, `rendering` alternative | `render rendering tree : TimelineTree :> timelineTree;` in `TimelineView` | satisfied |
| LANG-830–834 expose forms | `expose TethysRequirements::*;` (NamespaceExpose), `expose TethysTug::argent;` (MembershipExpose), `expose TethysRequirements::**[@RequirementDerivation::OriginalRequirementMetadata];` (recursive filtered) | satisfied; the `::*` form over-exposes private imports (F-H02) |
| LANG-065 ElementFilterMember in a view body | `filter @TethysRequirements::Verification;` | satisfied (`runs/views/TethysViews.requirementsTree.mmd` shows the nine verified requirements) |
| LANG-835–839 viewpoints | five `viewpoint def`s and usages | satisfied |
| LANG-770, 785–789 concerns, `frame` | `concern def … { subject mission : Mission; stakeholder …; }`, `frame requirementTraceability { … }`, `frame concern interfaceControl : InterfaceControl { … }` | satisfied; explicit subjects because of F-H04 |
| LANG-840–844 renderings | `rendering def BudgetTable :> TabularRendering`, `rendering def TimelineTree :> GraphicalRendering`, `rendering budgetTable : BudgetTable :> asElementTable;`, `rendering timelineTree : TimelineTree :> asTreeDiagram;` | satisfied; the engine renders a user rendering by the standard rendering it subsets (`runs/views/TethysViews.massBudget.md`: `render budgetTable`) |

## Tool rows

| Row | Command | Pinned | Result |
| --- | --- | --- | --- |
| TOOL-019 `-run-query` | `-run-query TethysDocuments::MissionRequirements` (+ `InterfaceEnds`, `FlightPhases`, `Risks`, `MassBudgetLines`, `SubsystemMasses`) | `runs/document-queries.txt` | satisfied |
| TOOL-071 `-render` | `-render TethysViews::segmentInterfaces -render-form dot`, `-render TethysViews::massBudget -render-form csv` | `runs/render-segment-interfaces-dot.txt`, `runs/render-mass-budget-csv.txt` | satisfied |
| TOOL-072 `-render-all` | `-render-all runs/views` | `runs/views/` | satisfied |
| TOOL-074 `-render-form` | mermaid (default), markdown (tables), dot, csv | as above | satisfied |
| TOOL-077 `-render-unplaced` | not used: the positioned view collapses its five segments so every drawn node has a Layout | — | not exercised |
| TOOL-084/085/086 `-list` | `-list all` | `runs/list-views.txt` | satisfied (lists view defs as views: F-H05) |
| TOOL-087 `-render-document` | `-render-document TethysDocuments::SystemDescription -doc-form pdf …` | — | satisfied locally (see SE-324) |
| TOOL-088 `-render-documents` | md and html sets | `runs/documents/`, `runs/documents-html/` | satisfied |
| TOOL-089 `-doc-form` | markdown, html pinned; pdf local | as above | satisfied; pdf not pinned |
| TOOL-090 `-diagram-form` | not used (mermaid default; the positioned view is drawn by Graphviz regardless) | — | not exercised |

## Library rows

| Library | Members used | Not used |
| --- | --- | --- |
| `Views` (LIB-096–107) | `View`, `ViewpointCheck`, `Rendering`, `TabularRendering`, `GraphicalRendering`, `asTreeDiagram`, `asInterconnectionDiagram`, `asElementTable`, `asTextualNotation` (F-H03) | `TextualRendering` directly |
| `StandardViewDefinitions` | `InterconnectionView`, `StateTransitionView` | the rest |
| `OpenSysMLRenderings` (LIB-339–342) | `asMixedDiagram` | `asCaseDiagram`, `CaseView`, `MixedView` (no use cases in the backbone yet) |
| `DiagramLayout` (LIB-112–117) | `Layout`, `Route`, `Style`, `Note` | `Canvas`, `Picture` |
| `DocumentQueries` (LIB-118–163) | `Query`, `OwnedElements`, `Descendants`, `Named`, `WhereType`, `WhereMetadata`, `WhereName`, `Except`, `Project` (`properties` and `Column(path|cell)`), `Document`, `Section`, `Paragraph`, `Span`, `Ref`, `Table` (`caption`, `groupBy`, `columnLabels`), `List`, `Definitions`, `Diagram` | `Column`/`ColumnSpec` (F-H01 blocks the one use), `Verdicts`, `States`, `Events`, `RelatedElements`, `OrderBy`, `Formula`, `Image`, `Link`, `*Column` runs — content for later packages |

## Soft-spot rows

| Row | Outcome |
| --- | --- |
| GAP-088 `frame` forms | both forms accepted by both validators (`frame x { … }`, `frame concern c : C { … }`) |
| GAP-089 `satisfy` in a view body | `satisfy requirementsViewpoint { doc … }` accepted; `-render-all` draws the view (conformance evaluation not exercised: `%view` is a REPL surface) |
| GAP-108 expose is an Import | behaves as an import — and imports too much (F-H02) |
| GAP-110 DOT form | `runs/render-segment-interfaces-dot.txt`: pilot B&W style, `neato -n` with pinned positions |
| GAP-112 DiagramLayout geometry | positions honoured in dot and in the documents' SVG figure; model semantics unchanged (`-validate` identical with `92-layout.sysml` removed) |
| GAP-113 viewpoint conformance | not evaluated by `-render-all`; open for the REPL/Jupyter walkthrough |
| GAP-178 document markup | documents authored as `Paragraph`/`Span`/`Ref`/`Definitions`; rendered md, html, pdf |
| GAP-179 depth limiting | the segment ICD is bounded by `collapsed = true` layouts instead of `-render-depth` |

## Findings added

F-H01 (metadata attributes not projectable), F-H02 (`expose P::*` re-exposes private imports), F-H03 (`asTextualNotation` unsupported), F-H04 (pilot/OpenSysML disagree on a concern without an explicit subject), F-H05 (`-render-all`/`-list` treat view defs as views) — see `docs/findings/WP-H.md`.
