# WP-SW-3 — flight software behaviour

Package `TethysFlightBehaviour` (`model/65-flight-behaviour.sysml`, mission tier): one state
machine per application that has modes, exhibited by the application part of
`TethysFlightSoftware::ArgentFlightSoftware` and bound to its ports; the sequencing engine as
action definitions typing the sequences of `TethysSequence`; the FDIR supervisor exhibited by the
FDIR application; the scenarios that drive the software with the operations centre and fault
injectors of the system-level runs. Runs are pinned as `runs/sw-*.txt`; findings in
`docs/findings/WP-SW-3.md`.

## Rows

| Row | Construct | Run / check | Status |
| --- | --- | --- | --- |
| SW-004 event service: reports with severity, event-to-response hooks | `ApplicationReport :> SoftwareEvent` (level, `isFault`, application, report) sent by the dispatcher on the application's `events` port over `EventLink` to the event service; FDIR responses relayed on `FdirSoftware::supervisorRequests` to `ModeManagementSoftware::fdirRequests` | `sw-mode-manager-dispatch` (sequence rendering `sw-mode-manager-dispatch-sequence.txt`), `sw-mode-manager-safe` | sat — the report items are local until the dictionary (see Integration asks in the PR) |
| SW-013 boot: ROM → image, check value, safe-image fallback | `BootUpdateManager` (bootRom, loadingImage, running, safeImage; `bootTimeout`), `ImageSlot` | `sw-boot` (`boots`, `fallbacks`, slot `safe` then `primary`) | sat |
| SW-014 redundancy: fail-over between prime and redundant computers | `RedundancyManager` exhibited by `BehaviouralCdh :> CdhWithSoftware` (heartbeat timer, `ProcessorReset` on `faults`, commanded switch, switch-over time, `lastComputer`) | `sw-failover` (prime reset → redundant → heartbeat lost → last computer) | sat |
| SW-015 C&DH: routing, time-tagged commands | Command links from the mode manager to each application (`CommandLink` reused from `TethysModes`); time-tagged dispatch in `DispatchTimeTagged` | `sw-mode-manager-dispatch`, `sw-autonomy-engine` | sat (packet framing stays in `TethysIcds`) |
| SW-016 GN&C | Attitude-control activity carried by `SubsystemConfiguration.gncWheelControlActive`; the control laws stay in `TethysDynamics` (73) | — | partial (laws are WP-F's) |
| SW-017 SEP control: string states, flameout restart | `SepStringController` (off, standby, thrusting, restarting; `restartDelay`), driven by `SepStandby`/`SepThrust`/`SepOff` and `ThrusterFlameout` | `sw-sep-string-restarting` (the thruster-fault script of `TethysFdir`) | sat |
| SW-018 power: load-shedding tiers, undervoltage response | `PowerManager` (`LoadShedTier` none/tierOne/tierTwo/survival; `BatteryStateOfCharge` against `cruiseLimits.batteryLowFraction`; `LoadShed`/`LoadRestore` from the mode manager) | `sw-mode-manager-safe-sequence.txt` shows `LoadShed` on safe-mode entry | sat |
| SW-019 thermal: set-points per mode, heater loop | `ThermalController parallel` (set-point selection operational/survival; heater loop with hysteresis on `TemperatureReport`) | instantiated in every software scenario; driven by `LoadShed`/`LoadRestore` | sat |
| SW-020 telecom: antenna and rate, relay | `TelecomManager` (safeRate, highGainIdle, pass with `passDuration`, relaying) | `sw-mode-manager-dispatch-sequence.txt` (`HighGainSelect`, `LowGainSelect`, `RelayEnable`/`RelayDisable`) | sat |
| SW-021 inspector handling | `InspectorHandler` (stowed, checkout, released, relayingImagery, retired) on the inspector commands of `TethysModes` | `sw-mode-manager-dispatch-sequence.txt` | sat |
| SW-022 capture control: inhibit chain, commit, contact, cinch, despin | `CaptureController` realising `TethysProximityOps::CaptureSequence`: three inhibit attributes written by `CaptureArm`, `GroundEnable`, `CaptureGo`; `cinching` runs `TethysFdir::ArmAndFireCaptureCinch`; `assert constraint noFireWithoutInhibits : NoFireWithoutInhibitsRemoved` | `sw-capture-controller` (captured), `sw-capture-controller-inhibited` (contact before enable → inhibited), `sw-capture-controller-check` and `-check-inhibited` (`-engine check`, exhaustive, holds) | sat |
| SW-023 autonomy / sequencing engine | `TethysSequence::OnBoardSequence` (typing the six sequences there, loaded by number), `LoadSequence`, `CheckConstraints`, `DispatchTimeTagged` (`accept after` an `in DurationValue`), `AbortSequence`, `SequenceRun` | `sw-autonomy-engine` (loaded, constraints passed, dispatched at the time tag) | sat |
| SW-024 FDIR monitors in software | `FdirSoftware :> FdirApplication` exhibits `TethysFdir::FdirSupervisor` with `limits` from the application's `limitTable`; `responseRelay` forwards its requests | `sw-fdir-command-loss-expired`, `sw-fdir-thruster-restarting` (the same scripts as `runs/fdir-*.txt`) | sat |
| SW-025 mode management: table, transitions with entry/exit, dispatch | `ModeManagementSoftware` exhibits `TugModes` and the `dispatcher` (one transition per mode command, sending the application commands the `SubsystemConfiguration` row implies and an `ApplicationReport`) | `sw-mode-manager-early-ops`, `-thrust-arc`, `-proximity-ops`, `-full-flight` (same states as `runs/modes-tug-*.txt`), `sw-mode-manager-dispatch` | sat |
| SW-026 safe mode: shed, low gain, command-loss timer, ground exit | Software FDIR `commandLossTimer` → `SafeModeRequest` relayed → dispatcher sheds (`SepOff`, `LowGainSelect`, `LoadShed`, `CaptureDisarm`, `SequenceAbort`) and raises the request for the software `TugModes` → `safe`; `SafeModeExit` restores | `sw-mode-manager-safe` (`safe | off | lowGain | thrusters | stowed`), `sw-mode-manager-recovered` (`coast | standby | highGain | wheels | stowed`) | sat |
| SW-028 software update: segments, verify, activate, roll back | `BootUpdateManager` (receivingUpdate on `ImageSegment` over `UpdateLink`, `ImageVerify`, `ImageActivate` → reboot on `backup`, `ImageRollback`) | `sw-boot` (`segmentsReceived = 3`, `uploadVerified`) | sat |
| SW-249 backbone: `TugModes` entry/exit actions name the applications; rows carry application activity | `model/60-modes.sysml`: `lastApplicationCommand`/`applicationCommands` written by entry/exit actions of thrust, proximityOperations, capture, stackThrust, safe, abortHold; `SubsystemConfiguration.sepControlActive`, `gncWheelControlActive`, `telecomHighGainActive`, `inspectorHandlingActive`, `captureControlActive` derived from the subsystem flags | `modes-tug-*` (moved: more action steps) | sat |
| SW-250 backbone: `FdirSupervisor` exhibited by the FDIR application; thresholds from a table | `model/62-fdir.sysml`: `limits : MonitorLimits default = cruiseLimits`, so `FdirSoftware` supplies its `limitTable`; exhibited in `FdirSoftware` | `sw-fdir-*` | sat (the table is `cruiseLimits` until `TethysFlightDictionary` exists) |

## Boundary probes

| Probe | File | Finding |
| --- | --- | --- |
| SW-187 twenty parallel regions, `-advance` and `-engine check` time | `model/probes/SW-187-twenty-region-supervisor.sysml` | F-S08, F-S09 |
| SW-190 send/accept between two exhibiting parts over an interface, rendered as a sequence | `model/probes/F-S01-send-via-state-definition-port.sysml` | F-S01 |
| SW-191 `accept after` parameter vs constant; latency chain with units | `model/probes/SW-191-accept-after-parameter-and-latency-chain.sysml` | F-S10 |
| SW-196 attribute writes from transition effects through a two-level `exhibit` | `model/probes/F-S02-nested-state-redefinition-entry.sysml` | F-S02 |

Found on the way: F-S03 (one consumer per port), F-S04 (redefined interface end), F-S05 (bind by
name), F-S06 (port shadowing an inherited attribute), F-S07 (checker and CLI surface).
