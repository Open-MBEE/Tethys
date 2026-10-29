# WP-I — as-built individuals, imported data and disposal

Files: `model/95-as-built.sysml` (`TethysAsBuilt`), `model/96-imported-data.sysml`
(`TethysImportedData`), `model/97-disposal.sysml` (`TethysDisposal`), `data/`.
Recorded with OpenSysML `v0.10.1-2054-g0a5fa2d94` (built from source at origin/develop 0a5fa2d94) and the pinned pilot validator; every
command below is a `run` line in `scripts/runs.sh` with its output under `runs/`, except the
`make check` gates. `$MODEL` is `model/*.sysml`.

| Row | Construct (file:element) | Proving command | Result |
| --- | --- | --- | --- |
| SE-266 (could) | `95:Provenance` metadata (`procurement : ProcurementKind`, `supplier`, `heritageNote`) on `argentFM` (make) and `wrenFM` (buy, two prior flights) | `make validate`, `make pilot` | satisfied |
| SE-267 (must) | `95:IntegrationSequence` action def (deliver → integrate → weigh → environmental test → mate inspector → ship) performed by `integration`; as-built mate `inspectorMated` connection | `sysml -action TethysAsBuilt::integration $MODEL` (`runs/as-built-integration.txt`) | satisfied: `Final state: Completed` |
| SE-268 (must) | `95:ArgentFlightModel`, `WrenFlightModel`, `SepFlightUnit`, `EpsFlightUnit`, `CaptureFlightUnit`, `RcsFlightUnit` — `individual part def`s specialising the design defs and `AsBuiltUnit` (`identity : UnitIdentity` with serial/lot/drawing, `asMeasuredMass`, `designMass`, `massDeviation`); `argentFM` (ARG-FM-001, 5 638.4 kg vs 5 600 kg) and `wrenFM` (WRN-FM-001, 24.9 kg vs 24.0 kg); `AsMeasuredMassWithinTolerance` requirement; as-measured masses also as `data/as-built-masses.txt` | `runs/as-built-individuals.txt` (`-e` of serials and deviations), `runs/as-built-satisfy.txt` (`-satisfy`), `runs/import-dry-run.txt` (TSV) | satisfied: Argent +0.69 % holds; Wren +3.75 % violated (by design, see SE-269) |
| SE-269 (should) | `95:waiverTW001 : Waiver` and `dependency wrenMassDeviation from wrenFM to waiverTW001`; `satisfy wrenMassWithinTolerance by wrenFM` records the violation | `sysml -satisfy $MODEL` | satisfied: `✗ satisfy wrenMassWithinTolerance by wrenFM fails … violated` |
| SE-270 (should) | per-unit end-item data as `UnitIdentity` + `Provenance` + as-measured masses on each unit; no `Document` per unit | — | open: a `-render-document` end-item data package is not written (DocumentQueries is OpenSysML-only, see `CONVENTIONS.md`) |
| SE-271–SE-274 | operations products owned by WP-H | — | not WP-I |
| SE-275 (should) | `96:argentFlight` snapshots (`afterArraysDeployed`, `atRendezvous`, `atCaptureComplete`, `atDroInsertion`) each with an unvalued `telemetry : TelemetrySample`, filled from `data/argent-telemetry.csv`; `amaranthTracked` snapshots with `ephemeris : EphemerisSample` filled from `data/amaranth-ephemeris.json` through `data/amaranth-ephemeris.map.json`; `xenonUsedOutbound`/`xenonUsedReturn` calcs over the imported values | `runs/import-dry-run.txt`, `runs/import-repl.txt` | partial — the import mechanism is proven (20 + 12 values set: `xenonUsedOutbound = 3290.0 [kg]`, `xenonUsedReturn = 2750.0 [kg]`, `earthRange = 10600000.0 [km]`), but the values in `data/argent-telemetry.csv` are placeholders that contradict the budgets (`propellantBudget.outboundAlone` ≈ 1 173 kg, the whole nominal mission ≈ 4 233 kg) and the DRO geometry (0.31–0.46 × 10⁶ km, not 10.6 × 10⁶); real as-flown values wait on the SE-263 source decision; CLI write-back is F-I01 |
| SE-290 (must) | `97:heliocentricDisposal` TS-290, `disposalPropellantReserve` TS-291 (rocket equation over the DRO-insertion xenon), `passivation` TS-292, `separationSafety` TS-293 (small/nominal/large/as-characterised body cases); `DisposalSequence` action def performed by `disposal`; `TugEndOfLife` state def exhibited by `argentAtEndOfLife` | `runs/disposal-requirements.txt`, `runs/disposal-sequence.txt`, `runs/disposal-states.txt` | satisfied: four requirements hold; action `Completed`; state machine ends in `passivated` |
| SE-291 (should) | `97:argentAtEndOfLife.passivated` final as-flown snapshot (last telemetry frame, tank pressure, battery and transmitter flags); `closeout : CloseoutRecord` referencing it | `runs/disposal-requirements.txt` (TS-292 reads the snapshot), `make validate` | satisfied |
| SE-292 (could) | `97:pfar : PostFlightAssessment` with three `@Issue` lessons | `make validate`, `make pilot` | satisfied |
| SE-263 (WP-H/ops, cross-ref) | one `individual part` per flight unit (`argentFM`, `wrenFM`, `amaranthFM`); `argentFlight`, `amaranthTracked`, `argentAtEndOfLife` subset them rather than declare a second individual | `make validate` | supports |
| LANG-519–523 (occurrence defs/usages, `event occurrence`) | snapshots and timeslices below; events stay in `TethysMission::flightTimeline` (backbone) | `make validate`, `make pilot` | satisfied where owned |
| LANG-524 (`individual part def`, must) | `95:ArgentFlightModel`, `WrenFlightModel`, `AmaranthAsCharacterised`, four `*FlightUnit` defs | `make validate`, `make pilot` | satisfied |
| LANG-525 (`individual part` usage, must) | `95:argentFM`, `wrenFM`, `amaranthFM` | `make validate`, `make pilot` | satisfied |
| LANG-526–531 (snapshot/timeslice/portion ordering) | `95:argentFM.atCdr → atAcceptance`, `amaranthFM.preArrival → postCharacterisation → postCapture`; `96:argentFlight` four snapshots + `outboundThrust` timeslice; `97:argentAtEndOfLife` two further snapshots ordered after the inherited `atDroInsertion`; `first … then …` throughout | `runs/as-built-individuals.txt` (`massEstimateRatio = 1.2155` reads across snapshots), `runs/import-repl.txt` (snapshot values read after import) | satisfied |
| LANG-532 (`individual occurrence def`, must) | not needed: the individuals are parts; see LANG-524 | — | open — conscious non-use, no mission reading for an `individual occurrence def` |
| LANG-533–535 (snapshot as requirement subject, timeslice features) | `97:satisfy passivation by argentAtEndOfLife.passivated`; `96:outboundThrust.averageThrust` | `runs/disposal-requirements.txt`, `runs/as-built-satisfy.txt` | satisfied |
| GAP-101 (`individual`/`snapshot` modifiers) | every modifier above | `make validate`, `make pilot` | both validators accept |
| TOOL-054 `-import` (must) | CSV, JSON and TSV in one run | `runs/import-dry-run.txt` | satisfied (preview); write-back F-I01 |
| TOOL-055 `-import-as` (must) | `-import-as values` | `runs/import-dry-run.txt` | satisfied |
| TOOL-056 `-import-map` | `data/amaranth-ephemeris.map.json` (`records`, `element.prefix`, nested `path`, `unit`, `ignore`) | `runs/import-dry-run.txt`, `runs/import-repl.txt` | satisfied |
| TOOL-057 `-import-format` (must) | `data/as-built-masses.txt` read as `tsv` | `runs/import-dry-run.txt` | satisfied |
| TOOL-058 `-import-dry-run` | all three files | `runs/import-dry-run.txt` | satisfied |
| TOOL-152 `%import` (REPL) | `%import … map …` then `%calc`/`%eval` over the imported snapshot values | `runs/import-repl.txt` | satisfied |

Target uncertainty: `separationSafety` evaluates the separation impulse (an `ImpulseValue`)
against `TethysTarget::targetCases.{small,nominal,large}.mass` (213 t, 362 t, 506 t) and the
as-characterised `amaranthFM.postCapture.mass` (438.8 t), returning `SpeedValue`s
(`runs/disposal-quantities.txt`); `passivation` compares its `passivationDelay` (23 d, from the
`closeout` record) with the 30 d deadline; `AmaranthAsCharacterised`
carries the pre-arrival estimate and the measured values as ordered snapshots, so
`massEstimateRatio` (1.2155) is the realised uncertainty.

Open: SE-270 (no per-unit `Document`), LANG-532 (no `individual occurrence def` needed),
F-I01 (CLI `-import` cannot write a multi-file model back; the REPL path proves the import).
