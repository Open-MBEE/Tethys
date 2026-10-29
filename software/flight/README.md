# Argent flight software (host build)

The Argent Flight Executive and its twelve applications as C11, built and run on the host, driven
only by the tables the generator writes into `software/generated/c/` from the SysML v2 model
(models 63–69, 88). Nothing in this directory re-states a model value: counts, rates, slots, WCETs,
opcodes, limits, state and transition tables all come from the headers; the few physical constants
the host simulation needs are quoted from the model with their source in a comment next to them.

Everything here is fictional (Argent, Kestrel, AABP-1, MLS-2). The only real standards used are the
CCSDS Space Packet Protocol primary header and the CUC time code, both as the model's
`PrimaryHeaderLayout`/`TethysTimeCode` describe them.

## Layout

| Directory | What it is |
| --- | --- |
| `exec/` | The Kestrel-style time/space-partitioned cyclic executive: partitions, rate groups and the 22 tasks from `argent_schedule.h`, 8 × 125 ms minor frames per major frame, WCET accounting per task per frame (model WCET is charged; host time is recorded separately and never used as WCET), partition pools of the model's `memoryBudget` sizes closed after initialisation. Integer microseconds throughout the scheduling path. |
| `hal/` | The hardware abstraction: `hal/hal.h` is the interface, `hal/host/` its only implementation (simulated clock, RIU register map from the 68 ICDs, AABP-1 frame, MLS-2 link availability, image store ledger). `hal/sim/` holds the small first-order power/thermal/GN&C/SEP plant models; their initial conditions are host choices listed in `sim.c`, while every threshold the applications decide on is the model's value, quoted with its source next to the constant in `apps/`. |
| `bus/` | The AABP-1 software bus: 13 streams on the 64-slot frame, per-mode slot allocation from `argent_bus_streams[]`, publish/subscribe over the 12 topics of the 68 message catalogue (one publishing end, the other ends subscribe). `bus_reserve_check()` fails where the table's load exceeds the 50 % reserve — proximity operations, capture and despin at 36 of 64 — and the trace shows it. |
| `svc/` | Command (binary search over the sorted `argent_commands[]`, argument count/type/range, allowed-mode mask, criticality, hazardous arm/execute against the inhibit register), telemetry (per-mode sampling from the rate sets, packet assembly from `argent_packets[]`/`argent_packet_fields[]`, CCSDS primary header, CUC time code), events (181, severities, fault flags to FDIR), parameters/limits/monitors (48 rows, 12 tables, 6 flight limits, 12 monitor limits), image slots (segments, verify, activate, rollback, boot count). |
| `sm/` | One table-driven state-machine runner over `argent_*_states[]`/`argent_*_transitions[]`: hierarchy, initial substates, entry/exit actions, completion (`ARGENT_STATE_DONE`) transitions, `after` timers, orthogonal regions (`TugModes`, `FdirSupervisor`), guards and effects registered by named-expression id. `sm_fully_bound()` fails on any id without an implementation. |
| `apps/` | One module per model application: `app_cdh`, `app_gnc`, `app_sep`, `app_power`, `app_thermal`, `app_telecom`, `app_inspector`, `app_capture`, `app_autonomy` (the sequencing engine, six sequences as data), `app_fdir` (supervisor and response relay), `app_mode` (`TugModes` and the dispatcher), `app_pbu` (parameters, boot, update). `system.c` wires them to the executive, bus, services and trace. |
| `trace/` | The JSONL trace writer (contract below). |
| `host/` | `argent_host`, the scenario harness. |
| `scenarios/` | The fourteen shipped scenarios, derived from `runs/sw-*.txt` by `tests/compare_runs.py` and checked byte-identical by the gate. |
| `tests/` | The self-contained unit-test runner (`runner.c`, seven `test_*.c` suites), `banned_constructs.sh`, `compare_runs.py`, `report_sizes.sh`. |

## Routing of items between applications

The model sends items `via <port>`; the tables carry the port name on every transition
(`argent_transition_t.port`). An item posted with the `command` port is the uplink side and reaches
every machine; an item posted by an application is addressed to the machine the model names
(`SepStandby() via sepCommands` goes to `SepStringController`, `SafeModeRequest` from the FDIR
supervisor goes relay → dispatcher → `TugModes`). Items are queued and delivered at the start of the
next minor frame; a machine that is not scheduled in the current mode does not tick, which is why
the launch mode (`allFlightModes` excludes it in model 31) runs no application task and the host
delivers the launcher uplink to the machines directly until separation.

## Host harness

```
build/software/flight/argent_host --scenario software/flight/scenarios/sw-mode-manager-early-ops.stim \
    --major-frames 17280 --fast-forward --trace build/software/flight/scenarios/sw-mode-manager-early-ops.jsonl
```

| Option | Meaning |
| --- | --- |
| `--scenario file` | Stimulus file (below). Without one the executive idles for the requested frames. |
| `--major-frames N` | Simulated seconds to run (one major frame = 1 s). |
| `--trace out.jsonl` | Write the trace. |
| `--fast-forward` | When no item is queued and no timer or stimulus is due, jump to the major frame before the next one; the jump is recorded as a `skip` record. Frames with activity are always traced. |

Stimulus file, one entry per line, `t=<seconds> <kind> ...`, times in simulated seconds from start:

| Kind | Form | Effect |
| --- | --- | --- |
| `item` | `t=60 item CaptureArm` / `t=180 item CaptureGo 6 400000` | An uplinked item (model `send new X(...) via uplink`), numeric arguments in the order the sequence render prints them. |
|  |  | Arguments keep the unit the render shows: `RangeUpdate 20` is 20 km (the guards compare with `rendezvousRange` in km), `InspectorImagingGo 4` a 4 h pass; the `SepDisposalBurn` the dispatcher sends to the SEP controller carries its duration in seconds. |
| `cmd` | `t=10 cmd CDH_NOOP` | A dictionary command by mnemonic through the command service (arguments as for `item`). |
| `link` | `t=300 link up` / `link down` | MLS-2 link availability. |
| `fault` | `t=400 fault PpuTrip` | An injected fault event raised through the event service into FDIR. |
| `expect` | `t=17280 expect TugModes=coast \| standby \| highGain \| wheels \| stowed` | Assert a machine's active configuration (region-wise, `*` matches any region). |

Exit codes: 0 ok; 1 usage or output failure; 2 task or frame overrun; 3 expectation failed;
4 unhandled fault (an FDIR level with no response, or an assertion inside the flight code);
5 stimulus parse error or unknown item/command/event.

## Trace contract (JSON Lines)

One JSON object per minor frame, in frame order, plus `skip` records under `--fast-forward`.
Names are the model's: machine names as in `argent_state_machines[].name`, state names as the
`name` column of the state tables, event mnemonics as in `argent_events[]`, command mnemonics as in
`argent_commands[]`. The trace is deterministic: the same scenario produces a byte-identical file on
the strict and the sanitised build (the gate checks it).

```json
{"frame":1,"minor":1,"t_us":125000,"mode":"launch",
 "machines":{"SepStringController":"off","PowerManager":"nominal","ThermalController":"operational | heaterOff",
             "TelecomManager":"safeRate","InspectorHandler":"stowed","CaptureController":"characterising",
             "RedundancyManager":"primeActive","BootUpdateManager":"bootRom",
             "TugModes":"onLauncher | off | lowGain | thrusters | stowed","ModeManagementDispatcher":"dispatching",
             "FdirSupervisor":"armed | nominal | nominal | nominal | nominal | monitoring","FdirResponseRelay":"relaying"},
 "events":[{"id":12,"name":"CDH_EVT_BOOT_COMPLETE","severity":1,"fault":false,"value":1}],
 "commands":[{"cmd":"CDH_NOOP","verdict":"accepted","inhibits":31}],
 "packets":[{"apid":1024,"seq":7,"len":132}],
 "faults":[],
 "bus":{"slots":32,"capacity":64,"reserve_ok":true},
 "exec":{"charged_us":4100,"tasks":5,"task_overruns":0,"frame_overruns":0},
 "inhibits":31}
{"skip":{"from_frame":16,"to_frame":34552,"from_us":2000000,"to_us":4319000000}}
```

| Key | Content |
| --- | --- |
| `frame`, `minor`, `t_us` | Minor-frame index since start, index within the major frame (0–7), simulated time in µs. |
| `mode` | `TugMode` name of the current mode row (`argent_mode_table[].name`); `onLauncher` is reported as the table's `launch`. |
| `machines` | Active configuration of every machine. One leaf per region, regions joined by ` \| ` in table order — the same string OpenSysML prints after `Current state:` in `runs/sw-mode-manager-*.txt`. |
| `events` | Events raised in this frame: dictionary id, mnemonic, severity, fault flag, value. |
| `commands` | Commands processed: mnemonic, verdict (`accepted`, `armed`, `unknownOpcode`, `argumentCount`, `argumentType`, `argumentRange`, `modeNotAllowed`, `inhibited`, `notArmed`, `armExpired`, `armTableFull`), inhibit register after the command. |
| `packets` | Packets emitted: APID, 14-bit sequence count, total length in octets. |
| `faults` | Unhandled faults (`{"fault":"text"}`): an FDIR level with no response or an internal assertion; the host exits 4 after the frame. |
| `bus` | Slots allocated this frame, the 64-slot capacity, the reserve verdict for the current mode. |
| `exec` | Modelled WCET charged in this frame (µs), tasks fired, cumulative task and frame overruns. |
| `inhibits` | The inhibit register (bit 0 capture arm, 1 capture mode, 2 ground enable, 3 high-voltage hold, 4 two-step pending). |
| `skip` | A fast-forward jump: nothing happened between `from_frame` and `to_frame`. |

A conformance harness compares the per-machine state sequences (the `machines` values at the
frames where they change) and the counters with OpenSysML `-state … -advance` runs; the shipped
scenarios' `expect` lines are the first such comparison.

## Gate

`make software-flight-check` (included from the root Makefile; CI job `software-flight-check`):
strict build (`-std=c11 -Wall -Wextra -Werror -pedantic -fno-common -O2`) and sanitised build
(`-fsanitize=address,undefined`) of the host and the unit tests, the unit tests on both, the
banned-construct scan (`malloc`/`calloc`/`realloc`/`free`/`alloca`, wall-clock calls, floating point in
the executive's scheduling path, variable-length arrays), the fourteen scenarios on both builds with
byte-identical traces, the pinned-run comparison with the shipped scenarios regenerated byte-identically
from `runs/`, the golden-packet cross-check (`tests/golden_packets.py`: every packet of
`software/ground/fixtures/packets.json` rebuilt byte for byte from its engineering values through
`argent_host --golden`), and the size report against the model's `codeSize`/`dataSize`/`budgetedMemory` (reported,
never resized). About 12 s on a laptop; `make software-flight-scenarios-update` rewrites the shipped
scenarios after `runs/` are re-recorded.
