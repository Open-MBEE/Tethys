# WP-SW-13 coverage — software conformance (flight host, generated tables, ground suite vs the pinned model)

Files: `software/conformance/` (`argent_conformance/` package, `expected/`, `evidence/`, `scenarios/`,
`probes/`, `conformance.mk`, `README.md`), one include in the root `Makefile`, the `software-conformance-check`
CI job, one paragraph in `software/README.md`. Flight-side edits the comparison forced, each listed in
`docs/findings/WP-SW-13.md` with its test: `software/flight/sm/sm_runner.[ch]` (F-SW1301, `test_held_items`),
`software/flight/host/argent_host.c` (F-SW1302, F-SW1306), `software/flight/tests/compare_runs.py` and the
regenerated `software/flight/scenarios/*.stim` (F-SW1303). Model edit: five `TethysSoftwareAssurance` cases
`planned` → `pass` with their evidence paths (below). Nothing under `software/ground/`, `software/gen/` or
`software/generated/` is edited. Tool: the pinned OpenSysML `5cd37f288` (`sysml`, `sysml-grpc`, Python client).

## Trace tier — machines × scenarios

Host `argent_host --fast-forward --trace` against `ExecuteState(trace=true)`; every configuration change of
every machine with its time, the model's transitions and accepts. 149 machine-runs compared, 146 agree,
3 adjudicated divergences, 348 configuration changes, 434 model transitions, 282 model accepts.

| Run | Machines compared | Agree | Diverge | Host-only | Configuration changes | Adjudicated |
| --- | --- | --- | --- | --- | --- | --- |
| `vc-final-targeting` | 2 | 1 | 1 | 10 | 11 | `TugModes` F-SW1305 |
| `vc-thrust-arc` | 12 | 12 | 0 | 0 | 28 | — |
| `sw-mode-manager-early-ops` | 12 | 12 | 0 | 0 | 21 | — |
| `sw-mode-manager-thrust-arc` | 12 | 12 | 0 | 0 | 26 | — |
| `sw-mode-manager-proximity-ops` | 12 | 12 | 0 | 0 | 27 | — |
| `sw-mode-manager-full-flight` | 12 | 11 | 1 | 0 | 32 | `InspectorHandler` F-SW1304 |
| `sw-mode-manager-dispatch` | 12 | 11 | 1 | 0 | 32 | `InspectorHandler` F-SW1304 |
| `sw-mode-manager-safe` | 12 | 12 | 0 | 0 | 26 | — |
| `sw-mode-manager-recovered` | 12 | 12 | 0 | 0 | 31 | — |
| `sw-fdir-command-loss-expired` | 12 | 12 | 0 | 0 | 26 | — |
| `sw-fdir-thruster-restarting` | 12 | 12 | 0 | 0 | 26 | — |
| `sw-sep-string-restarting` | 12 | 12 | 0 | 0 | 26 | — |
| `sw-capture-controller` | 1 | 1 | 0 | 11 | 5 | — |
| `sw-capture-controller-inhibited` | 1 | 1 | 0 | 11 | 3 | — |
| `sw-boot` | 1 | 1 | 0 | 11 | 11 | — |
| `sw-failover` | 12 | 12 | 0 | 0 | 17 | — |

`host-only`: the model scenario executes one machine (capture, boot) or the system tug's `fdir` only
(`vc-final-targeting`); the host always runs all twelve.

## Calc tier — every calc def the software uses

Interpreted (`Model.eval` in the calc's package, model units) against compiled C and Go at the pin over the
grids in `calcs.py`; Real within 1e-9 relative, Integer/Boolean/enumeration exact. No Python target at the
pin (F-SW1307).

| Bucket | Count | Calcs |
| --- | --- | --- |
| agree | 10 | ExpNeg, Log10, DecibelsFromRatio, RatioFromDecibels, GainToNoiseTemperatureDbPerK, LinkMarginDb, RelayDaysRequired, EngineeringUnits, CheckLimits, EnvelopeMargin |
| disagree | 0 | — |
| does-not-compile-at-pin | 15 | MarginFraction, ArrayPower, PropellantFor, MassFlowRate, Survival, TugPowerInMode, BusPowerInMode, TugHeatInMode, Wavelength, DishGainDbi, FreeSpaceLossDb, CharacterisationDataVolume, OrbitDetermination, StationVisible, CheckFlightRules |
| not-driveable | 22 | ContingencyFor, WithContingency, RootSumSquareDegrees, SetReliability, UnitSetReliability, UnitsDataRate, ReturnableBodyMass, XenonForMission, DespinPropellant, RadiatorRejection, MarginReport, TaskDemandInFrame, TasksDemandInFrame, Utilisation, TaskResponse, BusSlotsInMode, LoadInMode, FootprintOf, ValidateCommand, DecommutatePacket, ManoeuvreDesign, PassVolume |

Reasons: `does-not-compile-at-pin` — quantity-typed parameters or results, package-level constants
(F-SW1308), each recorded verbatim in `expected/calc/<Package__Calc>.txt` with the interpreted values of the
grid; `not-driveable` — record-, part- or sequence-typed inputs that no one-line grid value expresses; the
file names what covers each (the pinned runs, `software-ground-check`). Budgets held against policy, identical
on both sides and failing: the power margin 0.1193 (11.9 %) against the 15 % row, the bus slots by mode
`[0, 32, 32, 32, 32, 36, 32, 36, 36, 32, …]` from the model and from `argent_tables.modes` against the 32-slot
reserve (TF-011).

## As-run verification cases (model 88)

Of the 31 `planned` cases, the five at level `flightSoftwareInTheLoop` are driveable by this harness (host +
model + ground); none is at level `modelInTheLoop` (all ten of those already pass against pinned runs).

| Case | Level | As-run verdict | Evidence |
| --- | --- | --- | --- |
| `finalTargetingFlightSoftwareInTheLoop` | flightSoftwareInTheLoop | pass | `software/conformance/evidence/finalTargetingFlightSoftwareInTheLoop.txt` |
| `thrustArcFlightSoftwareInTheLoop` | flightSoftwareInTheLoop | pass | `software/conformance/evidence/thrustArcFlightSoftwareInTheLoop.txt` |
| `captureSequenceFlightSoftwareInTheLoop` | flightSoftwareInTheLoop | pass | `software/conformance/evidence/captureSequenceFlightSoftwareInTheLoop.txt` |
| `faultDetectionFlightSoftwareInTheLoop` | flightSoftwareInTheLoop | pass | `software/conformance/evidence/faultDetectionFlightSoftwareInTheLoop.txt` |
| `groundTwoStepIntegration` | flightSoftwareInTheLoop | pass | `software/conformance/evidence/groundTwoStepIntegration.txt` |

Not runnable here, left `planned` with the reason: 12 `unit` cases (developer workstation benches of the
flight unit tests), 4 `integration` (dynamics simulator / integration bench / operations-centre integration),
4 `hardwareInTheLoop` (flatsat, capture rig), 6 `flatsat`. SA-001/SA-002 and the IV&V activity status are
not touched; the five as-run passes are what this set would let the release gate count.

## Measurements

Development VM (8 cores): whole gate 48–54 s wall-clock, `sysml-grpc` peak RSS 0.80–0.83 GB (`/usr/bin/time`
maximum resident set 819 MB); trace tier ~11 s (model `sw-mode-manager-full-flight` 1.5 s, 26.7 KB of trace
text; host traces 82 KB–396 KB JSONL per run with `--fast-forward`); calc tier: compiles 35–39 s wall in
parallel (~5 s per `sysml -compile`), evaluation < 0.02 s per calc; cases 7 s including their two extra runs.
`build/software/conformance/measurements.txt` holds the per-step table of the last run. Under the five-minute
budget, so one tier; no fast/full split.
