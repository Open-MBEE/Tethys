# WP-SW-11 coverage — the Meridian Operations Suite (ground software)

Files: `software/ground/meridian/` (Python package), `software/ground/go/` (Go module),
`software/ground/tests/` (pytest), `software/ground/fixtures/packets.json`, `software/ground/README.md`,
`software/ground/ground.mk` and the `software-ground-check` CI job; additive generator changes in
`software/gen/` (`emit_go.py`, the `ground` table) with the regenerated `software/generated/`. No model
file is edited. Tool: the pinned OpenSysML `5cd37f288`; the Python client is the one `make software-venv`
installs from the pinned checkout, and model evaluations run against `build/opensysml/sysml-grpc` built
from that checkout. Findings: `docs/findings/WP-SW-11.md` (F-SW1101 … F-SW1109).

## Model element → software artefact

| Model element (file) | Product | Artefact | Simulated / stubbed |
| --- | --- | --- | --- |
| `TethysGroundSoftware::MeridianOperationsSuite`, `meridianOperationsSuite` (69) | — | `meridian.suite.MeridianOperationsSuite` (`moc`, `fdf`, `sds`, `testBeds`; 12 components, 4 simulators) | — |
| `moc.commandBuilder : CommandBuilder`, `ValidateCommand`, `CommandVerdict` (69); `flightDictionary.commands` (64) | Meridian Forge | `meridian.forge.CommandBuilder` (`validate`, `build`, `pack_command`) over `commands.COMMANDS`, `ground.CommandVerdict` | the dictionary is the generated table; approvals are names in the request |
| `moc.sequencer : FlightRuleChecker`, `GroundSequenceCheck`, `CheckFlightRules`, `LoadPlannedSequence` (69); `TethysOperations` FR-001 … FR-004 (53); `TethysSequence` sequences (61) | Meridian Warden | `meridian.warden.FlightRuleChecker`, `SequenceStoreStandIn`, `UplinkExchange` over `ground.FLIGHT_RULES`, `ON_BOARD_SEQUENCES`, `CHECK_LIMITS`, `THRUSTING_MODES` | the on-board `SequenceStore` is a stand-in that accepts the ids of `ground.STORED_SEQUENCES`; rule expressions are interpreted from the table text by a restricted evaluator |
| `moc.telemetryServer : TelemetryServer`, `CheckLimits`, `LinearTrend`, `AlarmLifecycle`, `EngineeringUnits` (69); packets/fields/limits (64); TI-021 frame geometry (68) | Meridian Lantern | `meridian.lantern.TelemetryServer`, `meridian.ccsds`; Go `telemetry.Server` | `LinearTrend` through the model (`xenonTrend`); limits, decommutation and lifecycle from the tables |
| `fdf.flightDynamicsTool : FlightDynamicsTool`, `OrbitDetermination`, `ManoeuvreDesign` (69) | Meridian Sextant | `meridian.sextant.FlightDynamicsTool` over `ModelBridge.eval` | nothing re-implemented: every calc is evaluated by the model service |
| `moc.passPlanner : PassPlanner`, `StationVisible`, `PassVolume`, `PlannedDailyPassPlan`, stations, pass allocations (69; ground segment 50) | Meridian Almanac | `meridian.almanac.PassPlanner` over `ground.STATIONS`, `STATION_PASSES`, `PASS_ALLOCATIONS`, `DOWNLINK_ACTIVITIES` | visibility/volume cross-checked against the model calcs in the tests |
| `sds.dataArchive : DataArchive`, `RetentionRule`, `ProductLevel` (69) | Meridian Vault | `meridian.vault.DataArchive` over `ground.RETENTION_RULES` | storage is an in-memory catalogue with CRC-32 checksums |
| `moc.anomalyTracker : AnomalyTracker`, `AnomalyLifecycle` (69); TF-011 (66), power margin (31/39), SA-001/SA-002 (88) | Meridian Ledger | `meridian.ledger.AnomalyTracker`, `ProgrammeGate` | programme gates read the model's values through the client and report them as the model says (failing, open) |
| `moc.proximityPlanner : ProximityPlanner`, `RelativeNavigationProduct`, go/no-go checklist, abort criteria (69) | Meridian Compass | `meridian.compass.ProximityPlanner`, `GoNoGoChecklist` over `ground.PROXIMITY_PRODUCTS`, `PROXIMITY_LIMITS` | — |
| `testBeds.trajectoryTool : FlightSoftwareInTheLoopSimulator` (69, `TethysVerification::testBeds`) | Meridian Mirror | `meridian.simulators.mirror.FlightSoftwareInTheLoopSimulator`, `TelemetryStream` | the flight software is simulated: packets at the per-mode rate sets with deterministic values |
| `testBeds.flatsat : HardwareInTheLoopTestBed` (69) | Meridian Anvil | `meridian.simulators.anvil.HardwareInTheLoopTestBed` over `interfaces` register tables | hardware is a register map |
| `testBeds.dynamicsSimulator : DynamicsSimulator` (69) | Meridian Orrery | `meridian.simulators.orrery.DynamicsSimulator` | deterministic relative-range steps, no six-degree-of-freedom dynamics |
| `testBeds.captureRig : CaptureRigController` (69) | Meridian Capstan | `meridian.simulators.capstan.CaptureRigController` | the rig is a state holder enforcing the two-step flow |
| TI-021 MLS-2 link (`SpaceLinkProfileIcd`, 68); `CommandBuilder`/`FlightRuleChecker` products | — | Go `uplink.Service`, `uplink.Framer`; `telemetry.Server.Frame` | the radio is not modelled: frames are byte slices |
| `PrimaryHeaderLayout`, `TethysTimeCode`, `PacketDefinition`, `PacketField` (64) | — | `meridian.ccsds` encoder/decoder, `meridian.fixtures`, Go `telemetry.Decode`; `fixtures/packets.json` | — |

Generated tables added (`Generator edits`): `argent_tables.ground` / `argenttables/ground.go` — 4 flight
rules, 6 on-board sequences, 12 ground components, 4 retention rules, 2 proximity products, 3 stations,
3 station passes, 3 pass allocations, 3 downlink activities, 3 check limits, 6 check reasons, alarm and
anomaly lifecycles (7 transitions each), 15 flight modes / 4 thrusting modes; and the whole dictionary in
Go (`software/generated/go/argenttables`, 12 files, 610 KB).

## Requirements and verification rows

| Row | Test |
| --- | --- |
| TM-001 commandValidation | `test_forge.py::test_tm001_…`, `test_verdicts_as_planted`; Go `TestModeAndOpcode` |
| TM-002 hazardousApproval | `test_forge.py::test_tm002_…`; Go `TestTwoStepServerSide` (all 51 hazardous commands) |
| TM-003 sequenceClearance | `test_warden.py::test_tm003_…`, `test_exchange_matches_the_pinned_run` |
| TM-004 telemetryDecommutation | `test_lantern.py::test_all_packets_decommutate_from_the_fixtures`; Go `TestAllPacketsDecommutate` |
| TM-005 limitAlarming | `test_lantern.py::test_tm005_…`, `test_bus_voltage_and_low_battery_alarms`; Go `TestLimitsAndAlarms` |
| TM-006 trendingAutomation | `test_lantern.py::test_tm006_…`, `test_xenon_trend` |
| TM-007 flightDynamicsProducts | `test_sextant.py::test_tm007_od_arc_within_autonomy` |
| TM-008 passPlanningVolume | `test_planning.py::test_tm008_…` |
| TM-009 archiveRetention | `test_planning.py::test_vault_distributed_levels_and_retention` |
| TM-010 anomalyDisposition | `test_planning.py::test_tm010_…` |
| TM-011 proximityGoNoGo | `test_planning.py::test_tm011_…`, `test_compass_checklist_go` |
| TM-012 simulatorFidelity | `test_simulators.py::test_stream_follows_the_per_mode_rate_set`, `test_simulators_are_the_model_test_beds` |
| TF-011 bus reserve, power margin, SA-001/SA-002 (surfaced, not fixed) | `test_planning.py::test_ledger_surfaces_the_programme_gates_as_modelled` |
| VCRM `groundTwoStepIntegration : GroundCommandTwoStepTest` (88) | `test_simulators.py::test_ground_two_step_integration` |
| VCRM `passPlanningIntegration : PassPlanningTest` (88) | `test_planning.py::test_almanac_visibility_and_volume` (planner against the model's link/pass calcs) |
| VCRM `relativeStateDynamics` (dynamics simulator) | `test_simulators.py::test_orrery_and_capstan` (the bed exists and steps; the estimator itself is flight software) |

No `GS-` rows exist in 67; the ground rows are `TM-001` … `TM-012`.

## Test oracles

| Test | Oracle |
| --- | --- |
| `test_forge.py::test_verdicts_as_planted` | `runs/sw-ground-structure.txt` `thrustArcVerdict`, `thrustArcInCoastVerdict`, `resetOneApprovalVerdict`, `resetKeyVerdict`, `misspelledVerdict`; request inputs read from the model through the client, cross-checked with `ValidateCommand` evaluated by the model |
| `test_forge.py::test_dictionary_counts` | `runs/sw-ground-structure.txt` counts (344 commands, 51 hazardous, 961 points, 51 packets) |
| `test_warden.py::test_exchange_matches_the_pinned_run[nominal/relayConflict]` | `runs/sw-ground-sequencer-check.txt` (`nominalUplink` cleared "cleared for uplink", 1 release / 1 load; `relayConflictUplink` refused "FR-001 thrust during a relay pass", 0 / 0) |
| `test_warden.py::test_rules_agree_with_the_model_calc` | `CheckFlightRules` evaluated by the model for the same candidate |
| `test_lantern.py::test_all_packets_decommutate_from_the_fixtures`, Go `TestAllPacketsDecommutate` | `allPacketsDecommutate` (run) and the golden fixtures' `raw`/`engineering` |
| `test_lantern.py::test_bus_voltage_and_low_battery_alarms` | `busVoltageAlarm`, `lowBatteryAlarm` severities in the run; `CheckLimits` through the model |
| `test_lantern.py::test_xenon_trend` | `xenonTrend` = 1836.0 in the run; `LinearTrend` inputs read from the model |
| `test_lantern.py::test_counts_and_frame_length` | TI-021 `transferFrameLength` 1115 (`runs/sw-ground-structure.txt`) |
| `test_planning.py::test_almanac_visibility_and_volume` | `calderaSeesTheTug` true, `tablelandSeesTheTug` false, `plannedDay` 1.14e11 bit, `imageryFits` true; `StationVisible`/`PassVolume` through the model |
| `test_planning.py::test_vault_distributed_levels_and_retention` | `distributedLevels` = 3 |
| `test_planning.py::test_compass_checklist_go` | checklist `go` = true, 12 items |
| `test_planning.py::test_ledger_surfaces_the_programme_gates_as_modelled` | `TethysFlightTiming` TF-011 (36 of 64 vs 32), `powerBudget.thrustingMargin` ≈ 0.119 vs 0.15, `TethysSoftwareAssurance` level-A IV&V `inProgress` — all evaluated by the model |
| `test_sextant.py::test_orbit_determination_and_return_arc_via_the_model` | `OrbitDetermination`, `ManoeuvreDesign` evaluated by the model (0.98198 km, 4.5e7 s, 1008000/11 kg); duration recorded |
| `test_simulators.py::*` | model `TestBed` parts in `ground.GROUND_COMPONENTS`; `telemetry.RATE_SET_BY_MODE`; the generated fixtures (drift) |
| `test_suite.py::*` | `runs/sw-ground-structure.txt` product names and component count 12 |
| Go `TestFrame`, `TestFraming` | TI-021 geometry 1115 / 6 / 4 octets from `IcdParametersByName` |

## Measurements

| What | Value |
| --- | --- |
| `make software-ground-check` (warm venv, `sysml-grpc` built) | 13.4 s wall; pytest 42 passed in 6.9 s, Go tests 7 passed |
| `build/opensysml/sysml-grpc` cold build from the pinned checkout | 11.6 s; 67.9 MB binary (boundary, F-SW1103) |
| `make software-check` with the Go emitter | 60.9 s wall (regeneration + byte-identical diff over C, Python and Go + C self-test + pytest) |
| Model service per test session | `parse_sources` 4.86 s over 64 files, then 95 evaluations in 1.4 s (`build/software/ground-model-timings.txt`) |
| Code | `meridian/` 1 651 lines Python, `go/` 791 lines Go, tests 527 lines; `emit_go.py` 464 lines |
| Data | `fixtures/packets.json` 88 211 B (51 packets); `argent_tables/ground.py` 16 299 B; `software/generated/go` 610 346 B |
