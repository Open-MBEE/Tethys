# Meridian Operations Suite — ground software

The ground software of the Tethys mission as the model describes it (`TethysGroundSoftware`,
model file 69; interfaces 68, flight dictionary 64, requirements 67, assurance 88). Two runtimes
share the generated tables:

- `meridian/` — Python ≥ 3.11 package, one subpackage per component of
  `TethysGroundSoftware::MeridianOperationsSuite`, each class named for the model's part and
  documented with its qualified name. Depends on `argent_tables` (`software/generated/python`), the
  pinned `opensysml` client (`build/software/venv`) and the standard library only.
- `go/` — Go ≥ 1.22 module `github.com/Open-MBEE/Tethys/software/ground/go` with the always-on
  services: the telemetry server (`telemetry`: CCSDS packet ingestion, decommutation by the
  generated packet tables, dictionary limits, alarms, archive, MLS-2 frame synchronisation) and the
  command uplink service (`uplink`: accepts Forge/Warden products, enforces the two-step hazardous
  flow server-side, frames for MLS-2 from the ICD parameter table). It imports the generated Go
  tables `software/generated/go/argenttables` (`emit_go.py`).
- `tests/` — pytest oracle tests; each names the pinned run and the model element it checks.
- `fixtures/packets.json` — the golden packet fixtures (format below).

| Product | Model part of `meridianOperationsSuite` (`TethysGroundSoftware::`) | Module |
| --- | --- | --- |
| Meridian Forge | `moc.commandBuilder : CommandBuilder` | `meridian/forge/` |
| Meridian Warden | `moc.sequencer : FlightRuleChecker` (+ `SequenceStore` stand-in, `UplinkExchange`) | `meridian/warden/` |
| Meridian Lantern | `moc.telemetryServer : TelemetryServer` | `meridian/lantern/`, `go/telemetry` |
| Meridian Almanac | `moc.passPlanner : PassPlanner` | `meridian/almanac/` |
| Meridian Ledger | `moc.anomalyTracker : AnomalyTracker` | `meridian/ledger/` |
| Meridian Compass | `moc.proximityPlanner : ProximityPlanner` | `meridian/compass/` |
| Meridian Sextant | `fdf.flightDynamicsTool : FlightDynamicsTool` | `meridian/sextant/` |
| Meridian Vault | `sds.dataArchive : DataArchive` | `meridian/vault/` |
| Meridian Anvil | `testBeds.flatsat : HardwareInTheLoopTestBed` | `meridian/simulators/anvil.py` |
| Meridian Capstan | `testBeds.captureRig : CaptureRigController` | `meridian/simulators/capstan.py` |
| Meridian Orrery | `testBeds.dynamicsSimulator : DynamicsSimulator` | `meridian/simulators/orrery.py` |
| Meridian Mirror | `testBeds.trajectoryTool : FlightSoftwareInTheLoopSimulator` | `meridian/simulators/mirror.py` |
| (uplink service) | `TethysInterfaces` TI-021 MLS-2 link, `CommandBuilder`/`FlightRuleChecker` products | `go/uplink` |

Everything the model defines as a `calc def` (orbit determination, manoeuvre design, station
visibility, pass volume, link budget, trends) is evaluated through the pinned OpenSysML Python
client against a `sysml-grpc` service built from the pinned checkout (`meridian/modelbridge.py`),
not re-implemented. Everything table-driven reads `argent_tables` — the `ground` table carries the
model's flight rules (`FR-001` … `FR-004`), the on-board sequence definitions, the component
catalogue, stations, pass allocations and retention rules.

## Running

```sh
make tools software-venv            # pinned OpenSysML + client, once
make software-ground-check          # pytest (meridian), gofmt/vet/test (Go), generated-Go vet
```

`software-ground-test` alone runs pytest; it builds `build/opensysml/sysml-grpc` from the pinned
checkout on first use. Model-call timings of the test session are written to
`build/software/ground-model-timings.txt`.

## Packet contract and fixture format

The byte layout of every telemetry packet is fully determined by the generated tables:
`packets.PRIMARY_HEADER` (field widths of the six-octet CCSDS primary header, in order: version,
type, secondary-header flag, APID, sequence flags, sequence count, data length), `packets.TIME_CODE`
(the secondary header: a CCSDS unsegmented time code, 32-bit coarse seconds + 16-bit fine, epoch
and resolution from the dictionary), then `PACKET_FIELDS` in table order with `offset_bits` /
`width_bits` from the start of the packet. Fields are packed MSB-first and unsigned; `data_length`
is the CCSDS value (octets after the primary header minus one). `meridian/ccsds.py` encodes and
decodes from those tables alone; `go/telemetry` decodes the same bytes from the Go tables.

`fixtures/packets.json` holds one packet per dictionary `PacketDefinition` (51), written by
`meridian/fixtures.py` from the tables with a deterministic raw value per field, so that the
flight telemetry service can be checked against the same bytes:

```json
{
  "format": "meridian-packet-fixtures/1",
  "model_tool_commit": "<OpenSysML commit the tables were generated with>",
  "primary_header": { "versionWidth": 3, "typeWidth": 1, "...": "widths of PrimaryHeaderLayout" },
  "time_code": { "coarseWidth": 32, "fineWidth": 16, "fineResolution": 1.52587890625e-05, "epoch": "..." },
  "packets": [
    {
      "mnemonic": "<PacketDefinition.mnemonic>", "apid": 16, "length_octets": 24,
      "sequence_count": 0, "time_coarse": 1000, "time_fine": 0,
      "hex": "<the whole packet, primary header included>",
      "raw": { "<point mnemonic>": 2048, "...": 0 },
      "engineering": { "<point mnemonic>": 29.0, "...": 0.0 }
    }
  ]
}
```

`raw` is the unsigned field value per telemetry point in `PACKET_FIELDS` order; `engineering` is
`EngineeringUnits(raw, scale, offset)` with the calibration derived from the point's red limits
(a point without both limits is carried as its raw count). A consumer passes when `decode(hex)`
reproduces `apid`, `sequence_count`, `time_coarse`, `time_fine` and every `raw` value, and its
calibration reproduces `engineering`. Regenerate with
`PYTHONPATH=software/ground:software/generated/python build/software/venv/bin/python -m meridian.fixtures`
(`test_lantern.py` fails on drift).
