# Argent flight software assurance report

*Software classification register*

| name | level | rationale |
| --- | --- | --- |
| captureControl | levelA | cinch firing (TH-003 bag tear if fired on an over-envelope body) and despin (TH-004); holds the arm, ground-enable and capture-mode inhibits of TethysFdir::ArmAndFireCaptureCinch |
| fdir | levelA | the Earth-impact exclusion monitor and abort (TH-001), safe-mode requests on command loss, thruster and PPU fault recovery (TH-004, TH-005) |
| modeManagement | levelA | safe-mode entry and the capture-mode inhibit (TH-003); dispatches every hazardous command (TH-001, TH-006) |
| gnc | levelA | computes the lunar gravity-assist targeting burn (TH-001 erroneous final targeting) and the relative state in proximity operations (TH-002) |
| autonomy | levelA | autonomous abort to the 500 m hold point (TH-002, TS-803) and the on-board sequence interlock on uncleared thrust arcs (TH-001) |
| sepControl | levelA | thrust on the final targeting arc (TH-001) and the software inhibit on PPU high voltage before separation plus 600 s (TH-006, TS-807) |
| executive | levelA | schedules and isolates every level-A application; a scheduling failure removes every software control at once |
| boardSupport | levelA | drives the remote interface units that actuate the cinch, the PPUs and the thrusters; the last software element before each hazardous actuator |
| cdh | levelB | routes commands and telemetry; a failure loses contact until the redundant computer takes over, no hazard cause of its own |
| powerManagement | levelB | load shedding keeps the battery above the floor; a failure degrades to safe mode, no hazard cause |
| telecom | levelB | carries the ground enable and the ground authority of TS-802; a failure is a loss of contact handled by the command-loss timer |
| parameterBootUpdate | levelB | a corrupted image or table is caught by the boot check and the safe image; no hazard cause |
| thermalControl | levelC | heater failures are slow and trended by the ground |
| inspectorHandling | levelC | the release is a two-step command; a relay failure loses survey products, not the mission |
| time | levelB | time-tags every sequence and the inhibit hold timer of TS-807 |
| events | levelB | carries the fault events the supervisor acts on |
| tables | levelB | holds the monitor limits and the two-step window |
| dataStore | levelB | recorder for telemetry and images; loss is recoverable by replay |
| commandIngest | levelB | checks the confirmation key of every hazardous command before dispatch |
| telemetryOutput | levelB | the ground's view of the inhibit states and the fault log |
| housekeeping | levelC | periodic health packets; loss is a degraded trend |
| scheduler | levelB | rate groups of the applications within the executive's partitions |
| bootUpdate | levelB | image checks and the fallback to the safe image |
| commandBuilder | levelB | the two-step rule for hazardous commands and the ground enable of the cinch; a human approves each step (TH-001, TH-003) |
| sequencer | levelB | refuses uncleared thrust arcs (FR-001) and keep-out violations (FR-002); the on-board interlock backs it |
| telemetryServer | levelB | the operators' view of inhibit states and alarms |
| flightDynamicsTool | levelA | confirms the post-manoeuvre trajectory misses Earth before the final targeting enable (TS-802, TH-001) |
| passPlanner | levelC | a bad plan loses a pass, caught by the next |
| dataArchive | levelD | archive and distribution; no operational decision depends on it in real time |
| anomalyTracker | levelD | record keeping for the anomaly board |
| proximityPlanner | levelC | plans within the keep-out; the checklist is reviewed by the flight director before the capture go |
| flatsatSimulator | levelC | test equipment: a wrong result is caught by the independent model-in-the-loop comparison |
| captureRigSimulator | levelC | test equipment driving a rotating mock body on the ground |
| dynamicsSimulatorSoftware | levelC | test equipment |
| flightSoftwareSimulator | levelC | test equipment; sequence validation before uplink is backed by the flight-rule checker |

*Rows without a level (expected empty)*

| name | level |
| --- | --- |

<a id="gate"></a>

*Release-readiness requirements*

| shortName | name | Verification::method |
| --- | --- | --- |
| SA-001 | releaseReadiness | inspect |
| SA-002 | levelAHasIndependentVv | inspect |
