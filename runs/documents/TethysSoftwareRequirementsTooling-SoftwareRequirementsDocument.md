# Tethys software requirements

The flight software requirements (TF-) on the Argent Flight Executive, its core services and applications, and the ground software requirements (TM-) on the Meridian Operations Suite; each row derives from the system rows it refines and names the software element that satisfies it; the verdicts of the constraints are the pinned satisfaction runs.

*Software requirements: derivation sources and satisfiers*

| shortName | name | Verification::method | Verification::level | derivedFrom | satisfiedBy | satisfiers |
| --- | --- | --- | --- | --- | --- | --- |
| TF-001 | commandIngest | test | software | dictionaryConsistent, commandLatency | commandIngest | 1 |
| TF-002 | hazardousTwoStep | test | software | dictionaryConsistent, noThrustDuringRelay | commandIngest | 1 |
| TF-003 | telemetryRatesByMode | test | software | deepSpaceLink, groundCoverage | telecom | 1 |
| TF-004 | eventLogging | test | software | autonomousSurvival, faultDetectionLatency | events | 1 |
| TF-005 | parameterTables | test | software | dictionaryConsistent, fdirTaskPeriod | tables | 1 |
| TF-006 | timeCorrelation | test | software | deepSpaceLink, rangingAccuracy | time | 1 |
| TF-007 | imageIntegrity | test | software | autonomousSurvival | bootUpdate | 1 |
| TF-008 | bootFallback | test | software | autonomousSurvival | parameterBootUpdate | 1 |
| TF-009 | partitionIsolation | analyze | software | faultResponse, processorBudgetCloses | executive | 1 |
| TF-010 | processorMemoryReserve | analyze | software | processorBudgetCloses | softwareProcessorBudget | 1 |
| TF-011 | busReserve | analyze | software | busBudgetCloses | softwareBusBudget | 1 |
| TF-012 | busReserveCoast | analyze | software | busBudgetCloses | softwareBusBudgetCoast | 1 |
| TF-013 | faultDetectionChain | analyze | software | faultDetectionLatency, latencyBudgetCloses | faultDetection | 1 |
| TF-014 | safeConfigurationLatency | analyze | software | faultResponse, latencyBudgetCloses | safeConfiguration | 1 |
| TF-015 | fdirTaskRate | analyze | software | fdirTaskPeriod | fdirTask | 1 |
| TF-016 | commandDispatchLatency | analyze | software | commandLatency, latencyBudgetCloses | commandDispatch | 1 |
| TF-017 | telemetrySampleLatency | analyze | software | deepSpaceLink, latencyBudgetCloses | telemetrySample | 1 |
| TF-018 | safeModeEntry | test | software | autonomousSurvival, faultResponse | modeManagement | 1 |
| TF-019 | modeTransitions | test | software | autonomousSurvival | modeManagement | 1 |
| TF-020 | sequencingEngine | test | software | commandLatency, noThrustDuringRelay, batteryDepthOfDischarge | autonomy | 1 |
| TF-021 | redundancyManagement | test | software | autonomousSurvival | cdh | 1 |
| TF-022 | heartbeatFailover | test | software | autonomousSurvival, faultResponse | cdh | 1 |
| TF-023 | busMessaging | test | software | busBudgetCloses | softwareBus | 1 |
| TF-024 | dataStoreRetention | analyze | software | deepSpaceLink, autonomousSurvival | dataStore | 1 |
| TF-025 | telemetryOutput | test | software | dictionaryConsistent, deepSpaceLink | telemetryOutput | 1 |
| TF-026 | housekeepingSampling | test | software | deepSpaceLink | housekeeping | 1 |
| TF-027 | schedulerCapacity | test | software | commandLatency | scheduler | 1 |
| TF-028 | boardSupportWatchdog | test | software | autonomousSurvival, faultResponse | boardSupport | 1 |
| TF-030 | cdhApplication | test | software | autonomousSurvival | cdh | 1 |
| TF-031 | gncApplication | test | software | faultResponse | gnc | 1 |
| TF-032 | sepControlApplication | test | software | noThrustDuringRelay | sepControl | 1 |
| TF-033 | powerManagementApplication | test | software | batteryDepthOfDischarge | powerManagement | 1 |
| TF-034 | thermalControlApplication | test | software | autonomousSurvival | thermalControl | 1 |
| TF-035 | telecomApplication | test | software | deepSpaceLink | telecom | 1 |
| TF-036 | inspectorHandlingApplication | test | software | proximityContactEnvironment | inspectorHandling | 1 |
| TF-037 | captureControlApplication | test | software | faultResponse, proximityContactEnvironment | captureControl | 1 |
| TF-038 | autonomyApplication | test | software | commandLatency | autonomy | 1 |
| TF-039 | fdirApplication | test | software | faultDetectionLatency, fdirTaskPeriod | fdir | 1 |
| TF-040 | modeManagementApplication | test | software | faultResponse | modeManagement | 1 |
| TF-041 | parameterBootUpdateApplication | test | software | autonomousSurvival | parameterBootUpdate | 1 |
| TM-001 | commandValidation | analyze | software | commandValidation, dictionaryConsistent, commandLatency | commandBuilder | 1 |
| TM-002 | hazardousApproval | demo | software | commandValidation, noThrustDuringRelay, operatorWorkload | commandBuilder | 1 |
| TM-003 | sequenceClearance | demo | software | sequenceClearance, commandLatency, noThrustDuringRelay, batteryDepthOfDischarge, sequenceTurnaround | sequencer | 1 |
| TM-004 | telemetryDecommutation | analyze | software | dictionaryDrivenTelemetry, dictionaryConsistent | telemetryServer | 1 |
| TM-005 | limitAlarming | analyze | software | dictionaryDrivenTelemetry, batteryDepthOfDischarge, monitoringAutomation | telemetryServer | 1 |
| TM-006 | trendingAutomation | analyze | software | monitoringAutomation, operatorWorkload | telemetryServer | 1 |
| TM-007 | flightDynamicsProducts | analyze | software | autonomousSurvival, rangingAccuracy, impactScreening | flightDynamicsTool | 1 |
| TM-008 | passPlanningVolume | analyze | software | plannedPassesFitTheLink, deepSpaceLink, groundCoverage | passPlanner | 1 |
| TM-009 | archiveRetention | analyze | software | scienceArchive | dataArchive | 1 |
| TM-010 | anomalyDisposition | demo | software | operatorWorkload, operationsReadiness | anomalyTracker | 1 |
| TM-011 | proximityGoNoGo | demo | software | approachKeepOut, sunExclusion, proximityContactEnvironment | proximityPlanner | 1 |
| TM-012 | simulatorFidelity | test | software | captureQualification | flatsat, trajectoryTool, dynamicsSimulator, captureRig | 4 |

## Coverage gates

*Software requirements without a derivation source (expected empty)*

| shortName | name |
| --- | --- |

*Software requirements without a satisfier (expected empty)*

| shortName | name |
| --- | --- |

*Flight software elements satisfying no requirement (expected empty)*

| qualifiedName |
| --- |

*Meridian suite elements satisfying no requirement (expected empty)*

| qualifiedName |
| --- |
