# WP-C — Wren inspector, capture system and proximity operations

Files: `model/40-inspector.sysml` (`TethysInspectorDetail`), `model/41-capture-system.sysml`
(`TethysCaptureSystem`), `model/42-proximity-ops.sysml` (`TethysProximityOps`); probes
`model/probes/F-003…F-006`. Gate: `make check` with OpenSysML built from source at develop
`0a5fa2d` (v0.10.1-2054 or later) and the pinned pilot validator; every command below is a
`run` line in `scripts/runs.sh` and its output is in `runs/`. "both" = accepted by
`sysml -validate -strict -warnings-as-errors` and by the pilot validator.

Target uncertainty: every target-dependent number is carried over the cases of
`TethysCaptureSystem::CaptureTargetCase` (small 181 t, nominal 362 t, large 1 010 t, fast-spin
120 s, tumbling) — the envelope is asserted to hold for the first two and asserted *not* to hold
for the other three (`runs/wpc-envelope-cases.txt`), and the despin propellant, angular momentum
and surface speed are computed per case (`runs/wpc-target-cases.txt`).

## SE rows (reading per `docs/small-body-domain-list.md` §8)

| Row | File : element | Proving command | Result |
| --- | --- | --- | --- |
| SE-151 prox-ops modes | `42:ProximityOpsModes` (hold, circumnavigating, approaching, cinched, retreating; guards `linkUp`/`commitGo`/`abort`/`contactMade`, timed return after 7 200 s) exhibited by `proximityOperations.modes` | `runs/wpc-prox-ops-modes.txt` (`-instantiate … -state "TethysProximityOps::ProximityOpsModes TethysProximityOps::proximityOperations" -advance 10000`) | satisfied for the proximity-operations modes: machine runs hold → cinched on the nominal guards. The full tug mode list is WP-E. |
| SE-152 mode × subsystem | — | — | open (WP-E carries the matrix; Wren's units per mode are not modelled here) |
| SE-153 subsystem machines with orthogonal regions | `42:ProximityOpsModes::circumnavigating parallel { imaging; sounding }` | as SE-151 | partial: Wren's payload regions only |
| SE-154 mission sequence | `40:CircumnavigationCampaign` (checkoutComplete → release → linkAcquired → imagingPasses → radarSounding → closePasses → characterisationDelivered → retreatToHold) | `make check` (both) | partial: WP-C's segment of the timeline; the flight timeline is the backbone's |
| SE-155 critical sequences with timing and go/no-go | `42:CaptureSequence` (`decide; if commit.go … else retreat`, `accept contact : ContactLoad`), `41:CaptureEnvelope` over the five cases, `42:ProximityOpsModes` (`accept after 7200.0 [s]`) | `runs/wpc-envelope-cases.txt`, `runs/wpc-capture-sequence.txt` | go/no-go satisfied (constraint verdicts per case); the sequence itself validates (both) but does not execute — F-006 |
| SE-156 (replaced by the thrust-arc campaign) | — | — | not WP-C |
| SE-157 capture sequence P10–P12 | `42:CaptureSequence` approach → contact → cinch → despin; `41:ContactForce`, `DespinDuration`, `DespinPropellant`, `MinimumRotationPeriod`; `TR-041`, `TR-042` | `runs/wpc-capture-calcs.txt`, `runs/wpc-requirements.txt` | satisfied: 10 kN at 0.10 m/s on 1 000 t over 0.5 m; 348 s and 6.44 kg for 4.17 × 10⁴ N·m·s at 120 N·m; 1 047 s minimum period for the largest body |
| SE-158 Wren release and tug retreat | `42:proxStackFM` snapshots `beforeRelease`/`afterRelease` (12 624 → 12 600 kg), `40:wrenFM` snapshots `atRelease`/`atEndOfCampaign`, `40:WrenCampaignOutcome` variants `nominal`/`linkLost`/`notReleased` (F18, F19), `42:Retreat`, `TR-043` | `runs/wpc-individuals.txt`, `runs/wpc-requirements.txt` | satisfied |
| SE-103 tug–inspector ICD | backbone `TugInspectorInterface` (umbilical only) | — | open: needs the mechanical (dispenser) and thermal ends — backbone change requested in the PR |
| SE-106 Wren proximity link | `42:ProximityLinkFlow` (`linkRate`), `imageryLink` 2 Mbit/s, `radarLink` 0.5 Mbit/s, `40:ProximityTransceiver`, `RadarEcho.delay` | `make check` (both) | partial: rates and timing carried; geometry window not modelled |
| capture / despin interface (SE-102, SE-107 reading) | `41:CaptureContactInterface :> CaptureInterface` (contact speed, cinch preload, despin and slip torque, temperature band, `flow of ContactLoad`), `41:DespinInterface`, `41:ContactLoad :> MechanicalLoad` | `make check` (both) | satisfied in WP-C's package; the backbone `CaptureInterface` should gain these attributes (PR body) |

## LANG rows

| Row | File : element | Proving command | Result |
| --- | --- | --- | --- |
| LANG-519, 520, 522 occurrence def | `40:occurrence def CircumnavigationCampaign` | `make check` | both |
| LANG-521, 523, 526, 527 individual def | `40:individual def WrenCampaign :> CircumnavigationCampaign`, `individual part def WrenFlightArticle`; `41`/`42:individual part def AmaranthFlightTarget`, `ProximityStackFM` | `make check`, `runs/wpc-individuals.txt` | both |
| LANG-524 `variation individual def` | `40:variation individual def WrenCampaignOutcome` with `variant occurrence nominal/linkLost/notReleased` | `make check` | both |
| LANG-525 `individual # def` | `model/probes/F-003-individual-prefix-def.sysml` | `sysml -validate -strict` vs pilot on the probe | open — pilot accepts, OpenSysML rejects (F-003); the model uses the usage form instead |
| LANG-528–530 occurrence usage | `40:occurrence imagingPasses`, `variant occurrence nominal` | `make check` | both |
| LANG-531 individual usage | `40:individual part wrenFM : WrenFlightArticle :> wren`, `42:individual part amaranthFM`, `proxStackFM` | `runs/wpc-individuals.txt` | both |
| LANG-532 `individual #` usage | `40:individual #FlightMeasured campaign : WrenCampaign` | `make check` | both (metadata *after* `individual`; the reverse order is F-004) |
| LANG-533, 534 snapshot / timeslice | `40:wrenFM` timeslices `stowed`/`freeFlying`/`retired`, snapshots `atRelease :> stowed.endShot`, `atEndOfCampaign`; `42:amaranthFM` timeslices `spinning`/`despun`, snapshots `atContact`, `atDespinComplete`; `42:proxStackFM` snapshots | `runs/wpc-individuals.txt` | both |
| LANG-535 event occurrence | `40:CircumnavigationCampaign` events (`event occurrence release` …) | `make check` | both |
| LANG-536–541 successions | `40:first checkoutComplete then release;` chain, `42:succession separation first beforeRelease then afterRelease;`, `then action …`/`then done` in `CaptureSequence`, `first spinning then despun` | `make check`, `runs/wpc-prox-ops-modes.txt` | both |
| LANG-607–609 flow def | `42:flow def ProximityLinkFlow { end source; end target; attribute linkRate }` | `make check` | both (a flow def without ends is rejected by both: "Must have at least two related elements") |
| LANG-610–614 message | `42:message characterisationReport of TargetCharacterisation from inspector to dataHandler;` | `make check` | both |
| LANG-615, 618–628 flow usage, payload, chained ends | `42:flow imageryLink : ProximityLinkFlow of ImageFrame from inspector.payload.visibleCamera.frames to dataHandler.imagery`, `radarLink`, unnamed `flow of TargetCharacterisation …`; `41:flow of ContactLoad from bodySide.load to tugSide.load` | `make check` | both; the pilot requires dotted flow ends |
| LANG-616, 617 succession flow | `42:CaptureSequence` `succession flow imageryToCharacterise of ImageFrame from collect.imagery to characterise.imagery;` | `make check` | both |
| LANG-629 flow redefinition | — | — | not exercised |

## Findings added

F-003 (`individual #Tag def` rejected by OpenSysML), F-004 (metadata before `individual` accepted
by OpenSysML, rejected by the pilot), F-005 (redefinition direction not checked by OpenSysML),
F-006 (action output default evaluated before its input is bound — blocks `-action` on
`CaptureSequence`). Rows in `docs/findings.md`, probes in `model/probes/`.
