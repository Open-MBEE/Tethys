# Argent flight software and Meridian Operations Suite operations handbook

How the flight software is operated through the Meridian Operations Suite, as TethysModes, TethysSequence, TethysFdir, TethysOperations and TethysGroundSoftware define it.

## Flight modes

*Flight modes*

| name | documentation |
| --- | --- |
| launch | From lift-off to the end of early operations: separation, array<br>deployment, sun acquisition. |
| freeFlight | Modes before capture. Entered at coast; re-entered at coast after a<br>safe-mode recovery. |
| stacked | Modes with the target captured: despin, return thrust and coast, DRO<br>hold, visiting-vehicle docking, disposal. Re-entered at stackCoast after<br>a safe-mode recovery. |
| safe | Sun-pointed, low-gain, thrusters and high-voltage bus off, waiting for<br>ground recovery; while in safe mode the sun-pointing hold is re-acquired<br>every hour (the \`do\` behaviour). |
| abortHold | Return aborted by the Earth-impact exclusion monitor: thrust inhibited,<br>attitude held, high-gain link up, waiting for a replanned trajectory. |

*Subsystem configuration commanded in each mode*

| name | sepThrusting | highVoltageBusOn | highGainAntennaOn | proximityLinkOn | wheelControl | captureSystemArmed | sensorsOn |
| --- | --- | --- | --- | --- | --- | --- | --- |
| launch | false | false | false | false | false | false | false |
| earlyOperations | false | false | false | false | true | false | false |
| coast | false | false | true | false | true | false | false |
| thrust | true | true | false | false | true | false | false |
| approach | true | true | true | false | true | false | true |
| proximityOperations | false | false | true | true | false | false | true |
| retreat | false | false | true | true | false | false | true |
| capture | false | false | false | true | false | true | true |
| despin | false | false | false | false | false | false | false |
| stackCoast | false | false | true | false | true | false | false |
| stackThrust | true | true | false | false | true | false | false |
| droHold | false | false | true | false | true | false | false |
| dockedPassive | false | false | true | true | false | false | false |
| disposal | true | true | false | false | true | false | false |
| safe | false | false | false | false | false | false | false |
| abortHold | false | false | true | false | true | false | false |
| rows |  |  |  |  |  |  |  |

## On-board sequences

*Sequences by number*

| name | sequenceId | timeTagged | documentation |
| --- | --- | --- | --- |
| OnBoardSequence | 0 | true | A sequence the autonomy application can load and dispatch: a numbered, stored<br>behaviour whose steps are time-tagged relative to its start. Every sequence below<br>specialises it; TethysFlightBehaviour's sequencing engine loads them by number. |
| ThrustArc | 1 | true | One thrust arc: the SEP string thrusts for the arc's duration at the given<br>thrust and burns the xenon that duration implies; the result is the xenon left. |
| DespinSequence | 2 | true | Despin the captured stack with the hydrazine thrusters: each pulse train<br>lengthens the spin period by a fixed factor until the period is above the<br>threshold at which the wheels take over. |
| InspectorReleaseSequence | 3 | true | The inspector release as a timed go/no-go sequence: checkout, umbilical<br>disconnect, a hold for the ground go, then release — each step gated by the<br>state the previous one must have reached. |
| DroInsertionSequence | 4 | true | The insertion into the distant retrograde orbit after the lunar assist: the<br>post-assist trajectory is checked against the insertion corridor, the<br>insertion arc is executed, and a miss leaves the stack in the backup<br>heliocentric loiter orbit rather than in cislunar space. The arc length is an<br>owned attribute, not a parameter: see docs/findings/WP-E.md F-E02. |
| DroStationKeeping | 5 | true | The DRO checkout's station-keeping demonstration: hydrazine trims are repeated<br>until the along-track drift is inside the control box, then the three<br>demonstration cycles of the checkout plan are costed. |
| MissionSequence | 6 | true | The flight from lift-off to disposal as an executable action over the phases<br>of TethysMission::flightTimeline. The clock runs in days; the thrust arcs are<br>loops counted against the arc plan; the capture commit is a decision over the<br>delivered target estimate and the capture envelope, and a refused commit ends<br>the mission in a retreat hold (\`terminate\`). The lunar assist is waited for as a<br>timed event (\`accept at\` a clock instant scheduled after the return arcs). |

## Fault protection

*Fault and on-board events*

| name | documentation |
| --- | --- |
| FaultEvent | A detected fault, raised by a monitor with the level it was detected at. |
| ThrusterFlameout | A thruster's discharge has extinguished (domain failure modes F1, F3). |
| PpuTrip | A power processing unit has tripped on over-current (F2, F7). |
| AttitudeLoss | Attitude knowledge lost or rates above the control authority (F24). |
| BatteryLow | Battery state of charge below the load-shed threshold (F25). |
| ProcessorReset | The flight computer has rebooted (F27); the supervisor restarts its timers. |
| GroundContact | Any valid telecommand received: the command-loss timer is re-armed. |
| TrajectoryUpdate | A return-trajectory solution from navigation: the predicted Earth closest<br>approach and the impact probability over the knowledge uncertainty. |
| InhibitChain | The cinch inhibit chain as an object the checker runs with every input free. |
| FdirTug | The tug with its FDIR supervisor beside the mode machine. |
| FaultInjector | A test conductor injecting faults and events into the tug's command port. |
| CommandLossInjector | Brings the tug to coast, keeps contact with passes on days 5 and 10, then falls<br>silent: the timer expires on day 17, the tug safes, and a contact on day 23<br>followed by SafeModeExit on day 24 recovers it to coast. |
| ThrusterFaultInjector | During the first thrust arc: two flameouts are restarted, the third switches<br>to the spare, the fourth loses the string and safes the tug. |
| EarthImpactInjector | A stacked return on a compressed clock (a ground pass every five days): the<br>capture is completed by injected events, the return arc starts, a nominal<br>trajectory update is accepted, then a solution inside the exclusion sphere<br>aborts the return. |
| FaultScenario | One tug under one fault injector. |

*Supervisor monitors*

| name | type | documentation |
| --- | --- | --- |
| commandLossTimer |  | Re-armed by every ground contact (the telecom subsystem reports one per<br>pass); on expiry the supervisor calls safe mode (sun-pointed, low-gain<br>omni), where the ground can reach the tug again. |
| thrusterHealth |  | Flameout recovery: restart the thruster up to the retry limit, then switch<br>to the spare; with the spare used and another string lost, the operating set<br>cannot be met and the supervisor calls safe mode. |
| ppuHealth |  | PPU trip recovery: cross-strap the thruster to the redundant PPU on the<br>first trip; a second trip leaves the string on the remaining PPU and calls<br>safe mode for the ground to replan the thrust profile. |
| powerHealth |  | Battery monitor: below the load-shed fraction the supervisor sheds loads<br>through safe mode; the ground clears it with SafeModeExit. |
| attitudeHealth |  | Attitude monitor: loss of attitude knowledge or control goes straight to<br>safe mode's sun acquisition on thrusters. |
| earthImpactExclusion |  | The Earth-impact exclusion monitor: every trajectory update is checked<br>against the exclusion sphere and the impact-probability limit; a violation<br>aborts the return (AbortReturn → TugModes abortHold, thrust inhibited). |

*Limit tables*

| name | commandLossTimeout | thrusterRestartDelay | maximumFlameoutRetries | batteryLowFraction | earthExclusionRadius | maximumImpactProbability |
| --- | --- | --- | --- | --- | --- | --- |
| flightLimitTable | 7 \[d\] | 2 \[h\] | 2 | 0.3 | 63781.37 \[km\] | 0.0001 |
| cruiseLimits | 7 \[d\] | 2 \[h\] | 2 | 0.3 | 63781.37 \[km\] | 0.0001 |

## Flight rules and procedures

**TG-010** — The dictionary shall assign distinct application ids within the 11-bit range, distinct opcodes, mnemonics and event ids; every command shall have an opcode and a mode precondition, every packet shall sum to its length, every telemetry point shall name its source application and carry ordered limits, and every fault-supervisor threshold shall read a limit-table row.

**FR-001** — The flight system shall not thrust while the proximity link is active.

**FR-002** — The tug shall remain outside the 500 m keep-out sphere until a capture sequence is loaded and authorised.

**FR-003** — The imager boresight shall stay more than 25° from the Sun while its cover is open.

**FR-004** — Battery state of charge shall not fall below 40 % in any planned activity.

**TG-020** — Operations shall be declared ready only with three stations committed, every procedure validated on the flatsat, at least two end-to-end rehearsals flown, every contingency procedure rehearsed and every position staffed.

The presented status meets every criterion.

**TG-021** — Every trended resource shall project above its floor at the end of the nominal mission.

Xenon projects above its reserve.

Battery capacity projects above its floor.

**TG-022** — An extended mission shall be proposed only if the xenon left covers its station keeping with the reserve intact.

The two-year proposal fits the xenon left.

*Procedures and activities*

| name | documentation |
| --- | --- |
| CommandExecutiveCoverage | Every dictionary command is accepted by at least one executive behaviour: this<br>action lists the acceptances the flight software offers. |
| RelayThenThrustProcedure | Procedure OPS-014: a relay session followed by a thrust arc, with the FR-001 and<br>FR-004 rules asserted at every step so a schedule that violates them is found. |
| DownlinkActivity | A downlink activity allocated to a pass: what it returns and how much. |
| TrackingActivity | Two-way Doppler and ranging over a pass for orbit determination. |
| ContingencyProcedure | A ground response to a credible failure mode: the triggering telemetry, the<br>failure mode from the domain list it answers, and the commands it sends. |
| LinearTrend | A value extrapolated linearly from its current value and rate of change. |

## Meridian command workflow

*Uplink exchange: command builder, flight-rule checker, flight sequence store*

| name | type | documentation |
| --- | --- | --- |
| checker | TethysGroundSoftware::FlightRuleChecker |  |
| flight | TethysGroundSoftware::SequenceStoreStandIn |  |
| link | TethysSoftwareIcds::SpaceLinkProfileIcd |  |

*Command requests checked by the command builder*

| name | mnemonic | argumentValue | modeAtExecution | approvals |
| --- | --- | --- | --- | --- |
| productName |  |  |  |  |
| version |  |  |  |  |
| dictionaryCommandCount |  |  |  |  |
| hazardousCommandCount |  |  |  |  |
| secondApprover |  |  |  |  |
| thrustArcRequest | SEP\_START\_THRUST\_ARC | 0.8 | thrust | 2 |
| thrustArcInCoastRequest | SEP\_START\_THRUST\_ARC | 0.8 | coast | 2 |
| resetWithOneApproval | CDH\_RESET\_PROCESSOR | 4660 | coast | 1 |
| resetKeyOutOfRange | CDH\_RESET\_PROCESSOR | 70000 | coast | 2 |
| misspelledRequest | SEP\_START\_THRUST | 0.8 | thrust | 2 |
| verdictsAsPlanted |  |  |  |  |

*Telemetry server limit checks*

| name | type | severity |
| --- | --- | --- |
| busVoltageSample | TethysGroundSoftware::EngineeringUnits |  |
| busVoltageAlarm | TethysGroundSoftware::CheckLimits | nominal |
| lowBatteryAlarm | TethysGroundSoftware::CheckLimits | violation |
| xenonTrend | TethysOperations::LinearTrend |  |

## Pass planning

*Pass planner figures*

| productName | version | visibilityHalfWidth |
| --- | --- | --- |
| Meridian Almanac | 1.9 | 65 \['°'\] |

*Operations centre consoles and roles*

| name | type | documentation |
| --- | --- | --- |
| commandBuilder | TethysGroundSoftware::CommandBuilder |  |
| sequencer | TethysGroundSoftware::FlightRuleChecker |  |
| telemetryServer | TethysGroundSoftware::TelemetryServer |  |
| passPlanner | TethysGroundSoftware::PassPlanner |  |
| anomalyTracker | TethysGroundSoftware::AnomalyTracker |  |
| proximityPlanner | TethysGroundSoftware::ProximityPlanner |  |
| ace | TethysMeridian::OperationsRole |  |
| gateway | TethysGroundSoftware::SuitePacketGateway |  |
| telemetryRelay | TethysGroundSoftware::GroundPacketRelay |  |
| commandRelay | TethysGroundSoftware::GroundPacketRelay |  |
| sequenceRelay | TethysGroundSoftware::GroundPacketRelay |  |
|  |  |  |
|  |  |  |
|  |  |  |
