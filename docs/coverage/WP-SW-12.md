# WP-SW-12 coverage — the Argent flight software (host build)

Files: `software/flight/` (C11: `exec/`, `hal/`, `bus/`, `svc/`, `sm/`, `apps/`, `trace/`, `host/`,
`scenarios/`, `tests/`, `README.md`), `software/flight/flight.mk` (included by the root Makefile), the
`software-flight-check` CI job, one paragraph in `software/README.md`. No model file and nothing under
`software/generated/` is edited; no generator change was needed. Tool: the pinned OpenSysML
`5cd37f288` only through the pinned `runs/sw-*.txt`, which are the oracle for every scenario and for
the state-machine unit tests. Findings: `docs/findings/WP-SW-12.md` (F-SW1201 … F-SW1206).

## Model element → software artefact

| Model element (file) | Software | Simulated / stubbed behind the HAL | Oracle |
| --- | --- | --- | --- |
| `ArgentFlightSoftware` executive, 5 partitions, 4 rate groups, 22 tasks, WCETs, 8 × 125 ms frame (63, 66) | `exec/executive.c` over `argent_partitions[]`, `argent_rate_groups[]`, `argent_scheduled_tasks[]`, `argent_partition_schedules[]`; integer-µs clock; pools of the partitions' `memoryBudget`, closed after init | Partition memory is a host pool ledger (budget reported, 64 KiB backing each); timers are the simulated clock | `test_exec.c`: every task bound, fires on its `firingFrames` in its `activeModes`, WCET = table, overrun on cost > WCET |
| Two flight computers, failover (63, 65 `RedundancyManager`) | `app_cdh.c` + `RedundancyManager` machine; heartbeat items from the redundant computer are scenario stimuli | The second computer is not executed; its heartbeat is the scenario's | `runs/sw-failover.txt` (`lastComputer`) |
| AABP-1 bus: 13 streams, 64 slots, per-mode allocation, reserve rule (66, 68) | `bus/bus.c`: `bus_slot_load()`, `bus_table_load()`, `bus_reserve_check()` | The frame is accounted, not serialised: slots and octets per frame, no wire timing | `test_bus.c`: per-mode load = `argent_bus_mode_loads[]`, reserve fails in exactly proximityOperations/capture/despin at 36/64 (TF-011, kept failing) |
| Inter-application message catalogue, 12 topics / 39 ends (68) | `bus_subscribe()`/`bus_publish()`; applications publish mode, fault, sequence-step and health topics | — | `test_bus.c`: every topic delivers to its `end_count − 1` subscribers (3- and 4-end topics included) |
| RIU register maps, 2 maps / 16 registers (68) | `hal/host/hal_host.c` register file addressed by the table | Register contents come from `hal/sim/` plant models | `argent_host` scenarios |
| MLS-2 link profile, 16 per-mode rate sets (68) | `svc/telemetry.c` `telemetry_rate_set()`; housekeeping period scales sampling and HK packets | Link availability is a scenario `link up/down` | `test_telemetry.c`: 16 rate sets, a minute of cycling emits packets |
| Command dictionary: 344 commands, 206 arguments, 51 hazardous, allowed modes, criticality (64, 88) | `svc/command.c`: binary search, argument count/type/range/width, mode mask, two-step arm/execute, inhibit register (`INHIBIT_*`) | — | `test_command.c`: all 344 found; all 51 hazardous refused with inhibits set (16 cinch chain, 19 high-voltage hold, 16 two-step); arm window expiry; mode mask |
| Telemetry: 961 points (320 HK), 51 packets / 961 fields, CCSDS primary header, CUC time code (64, 68) | `svc/telemetry.c`: sampling at the table rate × mode scale, `telemetry_build_packet()` (field offsets are absolute, calibration spans the red limits) | Point values come from the plant models and application state via the sampler callback | `test_telemetry.c`: every packet builds with the header bits and the table length, 14-bit sequence wrap; `tests/golden_packets.py`: the ground package's 51 golden packets byte for byte |
| Events: 181 (65 fault), severities, FDIR relevance (64) | `svc/event.c` → FDIR sink → `FdirSupervisor` machine | — | `test_services.c` |
| Parameter tables 48 rows / 12 tables, 6 flight limits, 12 monitor limits, 5 fault-event types (64, 62) | `svc/parameter.c`: range-checked writes, table CRC, red/yellow monitors | — | `test_services.c` |
| Boot/update: image slots, segments, verify, activate, rollback (65 `BootUpdateManager`) | `svc/image.c` + `app_pbu.c` | Image store is a length/checksum ledger (`hal_image_*`), no bytes kept | `runs/sw-boot.txt` (`running`), `test_services.c` |
| Twelve applications (63) | `apps/app_{cdh,gnc,sep,power,thermal,telecom,inspector,capture,autonomy,fdir,mode,pbu}.c` | GN&C/SEP/power/thermal first-order plants in `hal/sim/sim.c` (host initial conditions); the thresholds the applications decide on are model values quoted next to each constant in `apps/` | scenarios + `test_system.c` |
| 12 state machines, 102 states, 167 transitions, 21 guards, 39 effects, entry/exit actions, `after` timers, orthogonal regions (60, 62, 65) | `sm/sm_runner.c` + per-application bindings | — | `test_system.c`: every guard/effect/entry/exit id bound (`sm_fully_bound`), every state and transition reachable; `test_sm.c` against four pinned runs |
| Mode management: `TugModes` 37/57, dispatcher 1/16 (one guard) with `send … via <port>` effects (60, 65) | `app_mode.c`; dispatcher effects routed to the machine the model's port names | — | `runs/sw-mode-manager-{early-ops,thrust-arc,proximity-ops,full-flight,dispatch,safe,recovered}.txt` |
| FDIR supervisor 21/17, response relay 1/2, command-loss timer, thruster/PPU/power/attitude health, Earth-impact exclusion (62, 65) | `app_fdir.c`; supervisor → relay → dispatcher → `TugModes` | Fault stimuli are scenario `fault`/`item` lines | `runs/sw-fdir-command-loss-expired.txt`, `runs/sw-fdir-thruster-restarting.txt`, `runs/sw-sep-string-restarting.txt` |
| Capture controller, three-inhibit cinch chain (65, 88) | `app_capture.c`, `INHIBIT_CAPTURE_ARM/MODE/GROUND_ENABLE` | Contact and body estimate are stimuli | `runs/sw-capture-controller.txt`, `runs/sw-capture-controller-inhibited.txt` |
| Sequencing engine, six on-board sequences (65) | `app_autonomy.c` `system_sequences[]` as data, `releaseDelay` 600 s | — | `test_system.c`: each sequence runs every step |
| Trace for the conformance harness | `trace/trace.c`, contract in `software/flight/README.md` | — | gate: byte-identical strict vs sanitised traces |

Not implemented, by intent: no second flight computer executes (failover is driven); no byte-level
AABP-1/MLS-2 framing (the model gives slot and rate accounting, not a wire format); no real plant
dynamics beyond the first-order models in `hal/sim/`.

## TF- rows checked on the host

TF-004 (overrun detection, `test_exec.c`), TF-011 (bus reserve, `test_bus.c`, failing as designed),
TF-019 (every machine starts / every id bound, `test_sm.c`, `test_system.c`), TF-021 (determinism,
`test_system.c` and the strict-vs-sanitised trace comparison in the gate). The model-88 inhibit
register is `test_command.c`.

## Measurements

| What | Value |
| --- | --- |
| Source | 3 429 lines of C/Python/sh under `software/flight/` |
| Strict host build (`-O2`) | ~2.3 s; sanitised ~3.6 s; four binaries ~9 s |
| Unit tests | 9 277 checks, 29 cases, 0.03 s strict / 0.06 s sanitised |
| Golden packets | 51/51 packets of `software/ground/fixtures/packets.json` reproduced byte for byte (header, CUC time code, every field) |
| Scenarios | 14 pinned runs, horizons 600 s … 129 600 000 s, all 14 in 0.2 s with `--fast-forward`; 2.0 MB of JSONL in total |
| `make software-flight-check` | 11.4 s wall on the development VM |
| `argent_host` size | file 528 440 B, text 304 577 B, data 199 793 B, bss 2 410 880 B |
| Model budgets (`runs/sw-fsw-structure.txt`) | codeSize 18 700 000 B, dataSize 78 000 000 B, budgetedMemory 1 900 000 000 B — text/codeSize 1.63 %, (data+bss)/dataSize 3.35 % (host build; reported, never resized) |
| Deliberate failures kept visible | bus reserve 36/64 in three modes (`reserve_ok:false` in the trace, `bus_reserve_check()` false); power margin and SA-001/SA-002 gate are ground/model verdicts, untouched |

## Oracles per test

`test_sm.c` and the scenarios read the final `Current state:` line of the named `runs/sw-*.txt`;
`compare_runs.py` derives each scenario's stimuli from the `-sequence` render
(`runs/sw-mode-manager-dispatch-sequence.txt`) or, when the render stops before the run horizon, from
the model's conductor script (`model/65-flight-behaviour.sysml`), never from hand-copied numbers.
The table-driven unit tests use the generated headers as the oracle for counts and values.
