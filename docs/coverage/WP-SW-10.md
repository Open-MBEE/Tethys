# WP-SW-10 coverage — the generator toolchain

Files: `software/gen/` (generator), `software/generated/` (tables, manifest, C self-test),
`software/tests/` (pytest), `software/README.md`, the `software-*` Makefile targets and the
`software-check` CI job. No model file is edited. Tool: the pinned OpenSysML `5cd37f288`
(`runs/tool-version.txt`); the Python client is installed from the same checkout
(`build/opensysml-src/client/python`) into `build/software/venv`. Findings: `docs/findings/WP-SW-10.md`
(F-SW1001 … F-SW1009).

## Model element → generated artefact

| Model element (file) | C | Python | Rows |
| --- | --- | --- | --- |
| `TethysTugStructure::TugMode` (31) | `argent_tug_mode_t`, `argent_mode_mask_t` | `enums.TugMode` | 16 |
| `TethysModes::InspectorModes` leaf states (60) | `argent_inspector_mode_t` | `enums.InspectorMode` | 7 |
| `TethysFdir::FdirLevel`, `FaultResponse` (62) | enums | enums | 3, 5 |
| `TethysOperations::ApidClass` (53), `TethysFlightDictionary::flightApids` (64) | `argent_apid_class_t`, `ARGENT_APID_BASE_*` | `enums.ApidClass`, `packets.APID_BASES` | 6 |
| `TethysFlightDictionary::Opcode` + `CommandDefinition::opcodeNumber` (64) | `argent_opcode_t` | `enums.Opcode` | 344 |
| `EventDefinition::eventId` (64) | `ARGENT_EVENT_*` | `enums.EventId` | 181 |
| `ParameterRow::parameterId` (64) | `ARGENT_PARAMETER_*` | `enums.ParameterId` | 48 |
| `flightDictionary.commands`, `CommandArgument` (64); `TugMode` (31) | `argent_commands[]`, `argent_command_arguments[]` | `commands.COMMANDS` | 344 commands, 51 hazardous, 206 arguments |
| `flightDictionary.telemetryPoints` (64); `SpaceLinkProfileIcd` rate sets (68) | `argent_telemetry_points[]`, `argent_mode_rate_sets[]` | `telemetry.TELEMETRY_POINTS`, `MODE_RATE_SETS` | 961 points (320 housekeeping), 16 rate sets |
| `flightDictionary.events` (64) | `argent_events[]` | `events.EVENTS` | 181 (65 fault-relevant) |
| `flightDictionary.packets`, `PacketField`, `PrimaryHeaderLayout`, `TethysTimeCode` (64) | `argent_packets[]`, `argent_packet_fields[]`, `ARGENT_PRIMARY_HEADER_*`, `ARGENT_TIME_CODE_*` | `packets.*` | 51 packets, 961 fields |
| `flightDictionary.parameterTables`, `flightLimitTable`, `tableLimits` (64); `TethysFdir::cruiseLimits`, `FaultEvent` subtypes (62) | `argent_parameters[]`, `argent_parameter_tables[]`, `argent_limit_table[]`, `argent_monitor_limits[]`, `argent_fault_event_types[]` | `parameters.*` | 48 rows / 12 tables, 6 limits, 12 monitor limits, 5 fault types |
| `TethysModes::TugModeTable` (60); `ArgentFlightSoftware` applications (63); rate sets (68); `argentBus` (66) | `argent_mode_table[]`, `argent_applications[]` | `modes.MODE_TABLE`, `APPLICATIONS` | 16 rows × 13 flags, 12 applications |
| `TethysFlightBehaviour::{SepStringController, PowerManager, ThermalController, TelecomManager, InspectorHandler, CaptureController, RedundancyManager, BootUpdateManager}` (65) | `argent_<machine>_states/transitions/guards/effects[]` | `state_machines.<MACHINE>` | see below |
| `TethysModes::TugModes` (60), `ModeManagementSoftware::dispatcher` (65) | same | same | see below |
| `TethysFdir::FdirSupervisor` (62), `FdirSoftware::responseRelay` (65) | same | same | see below |
| `TethysFlightTiming::FlightTiming`, `argentTiming` (66); `ArgentFlightSoftware::executive` (63) | `argent_rate_groups[]`, `argent_partitions[]`, `argent_partition_schedules[]`, `argent_frame_slices[]`, `argent_scheduled_tasks[]` | `schedule.*` | 4 rate groups, 5 partitions, 5 schedules, 7 slices, 22 tasks, 8 minor frames |
| `TethysFlightTiming::argentBus` (66) | `argent_bus_streams[]`, `argent_bus_mode_loads[]` | `schedule.BUS_STREAMS`, `BUS_MODE_LOADS` | 13 streams, 64 slots, 16 mode loads (36 slots used in the full modes, as `runs/sw-timing-budgets.txt`) |
| `TethysSoftwareIcds::MessageCatalogue`, topics, `OnBoardBusProtocolIcd`, `SpaceLinkProfileIcd`, `InspectorRelaySoftwareIcd`, RIU register maps (68) | `argent_messages[]`, `argent_topics[]`, `argent_icd_parameters[]`, `argent_registers[]`, `argent_register_maps[]` | `interfaces.*` | 12 messages (APIDs 16–27), 12 topics, 43 ICD parameters, 2 register maps |

### State machines

| Machine | States | Transitions | Guards | Effects |
| --- | --- | --- | --- | --- |
| SepStringController | 4 | 8 | 0 | 0 |
| PowerManager | 4 | 9 | 3 | 0 |
| ThermalController | 6 | 4 | 2 | 0 |
| TelecomManager | 4 | 9 | 0 | 0 |
| InspectorHandler | 5 | 7 | 1 | 0 |
| CaptureController | 7 | 13 | 2 | 6 |
| RedundancyManager | 5 | 11 | 2 | 2 |
| BootUpdateManager | 6 | 10 | 0 | 4 |
| TugModes (5 regions) | 36 | 55 | 5 | 3 |
| ModeManagementDispatcher | 1 | 16 | 0 | 16 |
| FdirSupervisor (6 regions) | 21 | 17 | 5 | 4 |
| FdirResponseRelay | 1 | 2 | 0 | 2 |
| **Total** | **100** | **161** | **20** | **37** |

## Gates

| Gate | Command | Result |
| --- | --- | --- |
| Generation | `make software-generate` | 21 files, 1 108 347 B; convert 33.9 s + extract 7.1 s + emit < 0.1 s = 41.1 s wall; ≈ 285 MB resident |
| Determinism | `make software-check` (regenerate into `build/software/regen`, `diff -r`) | byte-identical, 45 s |
| C | `make software-selftest` (`-std=c11 -Wall -Wextra -Werror -pedantic`) | compiles; `selftest: ok` — 10 invariant groups (sorted unique ids, mode preconditions, argument widths, limit ordering, packet layouts sum to length, parameter ranges, machine indices, partition windows tile the major frame, register addresses) |
| Python | `make software-test` (pytest in the pinned-client venv) | 11 passed, cross-checked against `runs/sw-dictionary-counts.txt`, `sw-dictionary-time-code.txt`, `sw-timing-budgets.txt`, `sw-requirements-counts.txt` |
| CI | `.github/workflows/check.yml` job `software-check` | same tool-fetch steps as `check`; `make check` unchanged |

Boundaries: the whole-model api-json is 485 MB (F-SW1003), above the 20 MB output bound only as
an intermediate — the generated output is 1.1 MB and generation takes 41 s, inside the 2-minute bound.
