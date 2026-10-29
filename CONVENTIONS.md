# Modelling conventions

- **Standard SysML v2 only, in two tiers.** No OpenSysML-only notation anywhere:
  `sysml -validate -strict -warnings-as-errors` accepts every file. The *mission tier* — every
  file that describes the mission (stakeholders, requirements, architecture, budgets, behaviour,
  analyses, verification, risk, as-built) — uses the standard libraries only and must pass the
  standalone pinned OMG pilot validator (`make pilot-mission`), so it opens in any SysML v2 tool.
  The *tool tier* — files that reference an OpenSysML library package (`DocumentQueries`,
  `DiagramLayout`, `OpenSysMLRenderings`, `AnalysisRecords`, `Simulation`, `Stochastic`,
  `StateSpaceIntegration`, `OOSEM`, `MOSA`, …) to exercise OpenSysML's document, layout, analysis
  and migration surfaces — is gated by the batch pilot with those libraries loaded as an extension
  library, resolved against but not validated (`make pilot-all`, which runs over every file).
  `make tiers` lists the split; it is derived from the files, not declared. A tool-tier file may
  import mission-tier packages, never the reverse. Prefer the standard construct where one exists
  (`StateSpaceRepresentation` over `StateSpaceIntegration`, `Analysis` over `AnalysisRecords`,
  `RiskMetadata` over a custom register); when a tool-tier library is the only way to prove a
  coverage row, keep that use in its own file so the mission tier stays portable.
- **One top-level package per file**, named `Tethys<Area>` (`TethysEnvironment`,
  `TethysTug`, …); the root `Tethys` package in `00-tethys.sysml` documents the mission
  and imports nothing — cross-package references import the sibling package explicitly
  (`private import TethysEnvironment::*;`). Files are numbered so `model/*.sysml` sorts in
  dependency order.
- **Fictional.** Invented names and numbers everywhere; physically plausible, derived in the model
  from public constants where possible (`TethysEnvironment`), never copied from a real or
  planned mission. No real agency or program names.
- **Units.** Every physical quantity is typed by an `ISQ` quantity and valued with an `SI` unit
  literal (`attribute mass : ISQ::MassValue = 1200 [SI::kg];`). No bare `Real` for a physical
  quantity. One declared exception: the KerML library `model/81-physics.kerml` takes and returns
  SI base units as `Real`; the SysML packages attach the ISQ kind and unit literal at the point
  of use.
- **Documentation.** Every definition and every requirement carries a `doc` comment; rationale
  uses `ModelingMetadata::Rationale`; status uses `ModelingMetadata::StatusInfo`.
- **Identity.** Requirements, interfaces, verification cases and risks carry a stable short id
  (`<'TR-0120'>` style) and a `IdentityMetadata` annotation where a document or an external system
  needs a UUID.
- **Naming.** Definitions `UpperCamel`, usages `lowerCamel`, packages `UpperCamel`, enum
  literals `lowerCamel`; requirement ids `TR-` (mission), `TS-` (system), `TA-`/`TW-`
  (tug/inspector subsystem), `TG-` (ground), `TI-` (interface).
- **Budgets close in the model.** Rollups are calculations over the part tree, margins are
  constraints, and a requirement asserts each budget; nothing is a typed-in total.
- **Runs are pinned.** Every command a package's documentation names is in `scripts/runs.sh` and
  its output under `runs/`; `make check` diffs them. A finding against OpenSysML or a library
  gets a row in the findings register: the backbone's in `docs/findings.md` (F-001…), each work
  package's in `docs/findings/<WP>.md` with ids `F-<letter>NN` (`F-H01`), with the smallest
  construct that shows it and (once fixed upstream) the version that fixed it; probes live under
  `model/probes/`, outside the gated `model/*.sysml` glob.
