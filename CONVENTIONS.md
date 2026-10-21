# Modelling conventions

- **Standard SysML v2 only.** `sysml -validate -strict -warnings-as-errors` and the pinned OMG
  pilot validator both accept every file. No OpenSysML-only notation; OpenSysML libraries
  (`OOSEM`, `DocumentQueries`, …) are ordinary library packages and are fine.
- **One top-level package per file**, named `Hesperia<Area>` (`HesperiaEnvironment`,
  `HesperiaOrbiter`, …); the root `Hesperia` package in `00-hesperia.sysml` documents the mission
  and imports nothing — cross-package references import the sibling package explicitly
  (`private import HesperiaEnvironment::*;`). Files are numbered so `model/*.sysml` sorts in
  dependency order.
- **Fictional.** Invented names and numbers everywhere; physically plausible, derived in the model
  from public constants where possible (`HesperiaEnvironment`), never copied from a real or
  planned mission. No real agency or program names.
- **Units.** Every physical quantity is typed by an `ISQ` quantity and valued with an `SI` unit
  literal (`attribute mass : ISQ::MassValue = 1200 [SI::kg];`). No bare `Real` for a physical
  quantity.
- **Documentation.** Every definition and every requirement carries a `doc` comment; rationale
  uses `ModelingMetadata::Rationale`; status uses `ModelingMetadata::StatusInfo`.
- **Identity.** Requirements, interfaces, verification cases and risks carry a stable short id
  (`<'HR-0120'>` style) and a `IdentityMetadata` annotation where a document or an external system
  needs a UUID.
- **Naming.** Definitions `UpperCamel`, usages `lowerCamel`, packages `UpperCamel`, enum
  literals `lowerCamel`; requirement ids `HR-` (mission), `HS-` (system), `HO-`/`HK-`
  (orbiter/probe subsystem), `HG-` (ground), `HI-` (interface).
- **Budgets close in the model.** Rollups are calculations over the part tree, margins are
  constraints, and a requirement asserts each budget; nothing is a typed-in total.
- **Runs are pinned.** Every command a package's documentation names is in `scripts/runs.sh` and
  its output under `runs/`; `make check` diffs them. A finding against OpenSysML gets a row in
  `docs/findings.md`, the smallest construct that shows it, and (once fixed upstream) the
  version that fixed it.
