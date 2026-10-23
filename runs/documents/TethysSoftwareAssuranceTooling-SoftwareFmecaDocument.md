# Argent flight software FMECA

One row per application and one for the executive: failure mode, local and end effect, detection, response and criticality, with the assurance level of the component.

<a id="rows"></a>

*Software failure modes*

| shortName | name | failureMode | localEffect | endEffect | detection | response | criticality | level |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SFM-01 | executiveSchedulerStall | partition scheduler stall: a major frame is not released | every application misses its rate group | watchdog resets the computer; redundant computer takes over | builtInTest | switchover | major | levelA |
| SFM-02 | cdhRoutingLoss | message bus queue overflow drops commands | commands not delivered to their application | loss of commandability until the command-loss timer safes the tug | telemetryLimit | safeMode | major | levelB |
| SFM-03 | gncTargetingError | targeting solution from a stale ephemeris | burn vector inside the Earth corridor | Earth-impact trajectory unless the exclusion monitor aborts | navigationResidual | abortReturn | catastrophic | levelA |
| SFM-04 | sepUncommandedThrust | thrust arc not terminated at its end time | thrust continues past the planned arc | trajectory error; on the final arc an Earth-corridor entry | telemetryLimit | safeMode | catastrophic | levelA |
| SFM-05 | powerLoadShedMissed | battery floor comparison against a stale measurement | loads stay on below the floor | battery depth of discharge exceeded; FDIR safes the tug | telemetryLimit | loadShed | major | levelB |
| SFM-06 | thermalSetpointError | setpoint table index off by one | one zone too cold or too warm | component out of its allowable range; trended by the ground | groundTrending | retry | minor | levelC |
| SFM-07 | telecomTransmitterStuck | transmitter-off command lost at the arc start | transmitter on while thrusting | flight rule FR-001 violated; power margin consumed | telemetryLimit | retry | minor | levelB |
| SFM-08 | inspectorRelayLoss | relay buffer overrun | survey frames lost | characterisation products delayed | groundTrending | retry | negligible | levelC |
| SFM-09 | captureCinchWithInhibit | inhibit gate bypassed | cinch motor runs before the envelope check | bag torn on an over-envelope body | builtInTest | abortReturn | critical | levelA |
| SFM-10 | autonomyAbortMissed | abort rule disabled by a parameter load | keep-out breach continues | collision with the target | navigationResidual | abortReturn | critical | levelA |
| SFM-11 | fdirMonitorMasked | monitor mask left set after a test | fault not detected | no abort on an Earth-corridor entry | groundTrending | safeMode | catastrophic | levelA |
| SFM-12 | modeManagerWrongMode | mode flag not cleared on exit | the capture-mode inhibit is removed | one of three cinch inhibits lost | telemetryLimit | safeMode | critical | levelA |
| SFM-13 | bootImageCorrupt | image checksum mismatch after upload | boot falls back to the safe image | mission software reverted until reload | builtInTest | retry | minor | levelB |

*Premature-cinch fault tree events*

| name | probability |
| --- | --- |
| controllerFiresInhibited | 0.0001 |
| modeFlagStuck | 0.001 |
| groundEnableWithoutApproval | 0.001 |
| driverSpuriousFire | 1e-06 |
| allInhibitsLost |  |
| cinchFiresPrematurely |  |
| inhibitsLostGate |  |
| topGate |  |
| withinBudget |  |
