# Software conformance harness

`software/conformance/` proves that the Argent flight software, the generated tables and the Meridian
ground suite agree with the Tethys model as the pinned OpenSysML (`scripts/fetch-tools.sh`, commit
`5cd37f288`) executes and evaluates it, and turns the software VCRM's planned model-in-the-loop cases
into as-run evidence. `make software-conformance-check` builds the flight host (`software/flight/flight.mk`),
builds and starts `sysml-grpc` from the pinned checkout (`software/ground/ground.mk`), runs the three tiers
below and compares every output byte for byte with the committed files; any difference fails the gate.
`make software-conformance-update` rewrites the committed files from a fresh run — review that diff, every
changed line is a conformance movement that needs an adjudication. Runtime dependencies: the pinned
`opensysml` client, the generated `argent_tables`, the standard library, the system C compiler and the
pinned Go toolchain (for the compiled calcs). On the development VM the whole gate takes about 50 s of
wall-clock with `sysml-grpc` peaking near 0.83 GB; `build/software/conformance/measurements.txt` lists
wall-clock, peak RSS and output size per step of the last run.

## What is compared

| Tier | Both sides | Committed under | Module |
| --- | --- | --- | --- |
| trace | the C host run with `--fast-forward --trace` against the model run through `ExecuteState(trace=true)`: for every machine the host runs, every configuration change with its time, plus the model's transitions and accepts | `expected/trace/<run>.txt`, `summary.txt` | `trace_check.py`, `hosttrace.py`, `modeltrace.py`, `scenarios.py` |
| calc | the model's interpretation of each `calc def` the software uses (`Model.eval` in the calc's package) against its compiled C and Go programs (`sysml -compile -target c|go -source`) over the grid in `calcs.py`; the power margin and bus slots against the generated tables and their policies | `expected/calc/<Package__Calc>.txt`, `summary.txt` | `calc_check.py`, `calcs.py` |
| cases | the planned `flightSoftwareInTheLoop` cases of `TethysSoftwareAssurance` (model 88) run on the host, the model and the ground suite, each against its own `PassIf` criterion | `evidence/<case>.txt`, `summary.txt` | `case_check.py` |

The runs of the trace tier are the fourteen pinned `runs/sw-*.txt` state-machine runs (host scenarios
derived from them by `software/flight/tests/compare_runs.py`) plus two conformance scenarios under
`scenarios/`: `vc-final-targeting` (the Earth-impact exclusion scenario of model 62 on the tug uplink)
and `vc-thrust-arc` (the thruster-fault scenario run on until the restarted string thrusts again).

Tolerances: a Real result agrees within 1e-9 relative (1e-12 absolute near zero); Integer, Boolean and
enumeration results must be identical; state sequences and their times must be identical (the host's
clock is the minor frame, 0.125 s, and every model time in these runs falls on a frame boundary or is
reported as it is, e.g. `t=38889240.125` for a task slot).

## How to read a divergence

`expected/trace/<run>.txt` lists, per machine, `agree` with the shared sequence or `diverge` with the
model's and the host's sequences side by side, each line `t=<s> <configuration>` where orthogonal
regions are separated by ` | ` exactly as the host's `machines` strings and OpenSysML's `Current state:`
lines. A `diverge` line carries ` -- F-SW13xx: …` when it is adjudicated: the finding names the
spec-compliant side and the other side's defect, and the gate accepts the divergence only in that exact
shape (`ADJUDICATED` in `scenarios.py`). `host-only` means the model scenario does not execute that
machine (the capture and boot scenarios run one machine). The calc files list `does-not-compile-at-pin`
with the pin's own message, then one row per grid point with `model=`, `c=`, `go=` and `DISAGREE` where a
compiled value leaves the tolerance; `not-driveable` names what covers the calc instead. An evidence file
lists the inputs, both sides' outputs for every observable the criterion needs, the criterion and the
verdict; a failing case stays `fail` and visible. Findings: `docs/findings/WP-SW-13.md`; coverage:
`docs/coverage/WP-SW-13.md`.

## How to add a run, a calc or a case

- A run: add a `Run` to `scenarios.py` (scenario part, machine usage, performer, horizon; `stim_dir`
  for a scenario file under `scenarios/`, `pinned` when the oracle run has another name), the host
  scenario file, and any new `(performer, machine)` pair to `MACHINE_MAP`; run
  `make software-conformance-update` and review `expected/trace/<run>.txt`.
- A calc: add a `Calc` to `calcs.py` with its parameter names in declaration order, a grid of the model's
  own values plus boundary points (a string value is a model expression — a quantity literal with a
  qualified unit such as `"1200.0 [SI::W]"` or an enumeration literal — and keeps the point interpreted
  only), the result kind and tolerance, and the source of the values.
- A case: add it to `CASES` in `case_check.py` with a runner that appends the inputs and both sides'
  outputs to the evidence lines and returns the criterion's truth; propose the model edit (verdict and
  `evidence` path in model 88) in the pull request that adds the evidence file.
