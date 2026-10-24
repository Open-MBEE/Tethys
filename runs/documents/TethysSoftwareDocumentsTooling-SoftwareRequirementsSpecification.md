# Argent flight software and Meridian Operations Suite requirements specification

## Verification cross-reference

*Software requirements and the cases that verify them*

| shortName | name | verifiedBy | cases |
| --- | --- | --- | --- |
| TF-001 | commandIngest | CommandRoutingTest, BootAndParameterTest, groundReadinessDemoSoftware | 3 |
| TF-002 | hazardousTwoStep | ThrustArcControlTest, BootAndParameterTest | 2 |
| TF-003 | telemetryRatesByMode | SpaceLinkTest, linkBudgetTestSoftware, groundReadinessDemoSoftware | 3 |
| TF-004 | eventLogging | CaptureAbortTest, FaultDetectionTest, ModeManagementTest, faultResponseTestSoftware, autonomyTestSoftware | 5 |
| TF-005 | parameterTables | FaultDetectionTest, BootAndParameterTest, faultResponseTestSoftware | 3 |
| TF-006 | timeCorrelation | SpaceLinkTest, linkBudgetTestSoftware, deflectionAnalysisSoftware | 3 |
| TF-007 | imageIntegrity | CaptureAbortTest, ModeManagementTest, autonomyTestSoftware | 3 |
| TF-008 | bootFallback | CaptureAbortTest, ModeManagementTest, autonomyTestSoftware | 3 |
| TF-009 | partitionIsolation | FaultDetectionTest, faultResponseTestSoftware | 2 |
| TF-010 | processorMemoryReserve |  | 0 |
| TF-011 | busReserve |  | 0 |
| TF-012 | busReserveCoast |  | 0 |
| TF-013 | faultDetectionChain | FaultDetectionTest, faultResponseTestSoftware | 2 |
| TF-014 | safeConfigurationLatency | FaultDetectionTest, faultResponseTestSoftware | 2 |
| TF-015 | fdirTaskRate | FaultDetectionTest, faultResponseTestSoftware | 2 |
| TF-016 | commandDispatchLatency | CommandRoutingTest, groundReadinessDemoSoftware | 2 |
| TF-017 | telemetrySampleLatency | SpaceLinkTest, linkBudgetTestSoftware | 2 |
| TF-018 | safeModeEntry | CaptureAbortTest, FaultDetectionTest, ModeManagementTest, faultResponseTestSoftware, autonomyTestSoftware | 5 |
| TF-019 | modeTransitions | CaptureAbortTest, ModeManagementTest, autonomyTestSoftware | 3 |
| TF-020 | sequencingEngine | CommandRoutingTest, ThrustArcControlTest, PowerManagementTest, groundReadinessDemoSoftware | 4 |
| TF-021 | redundancyManagement | CaptureAbortTest, ModeManagementTest, autonomyTestSoftware | 3 |
| TF-022 | heartbeatFailover | CaptureAbortTest, FaultDetectionTest, ModeManagementTest, faultResponseTestSoftware, autonomyTestSoftware | 5 |
| TF-023 | busMessaging |  | 0 |
| TF-024 | dataStoreRetention | CaptureAbortTest, SpaceLinkTest, ModeManagementTest, linkBudgetTestSoftware, autonomyTestSoftware | 5 |
| TF-025 | telemetryOutput | SpaceLinkTest, BootAndParameterTest, linkBudgetTestSoftware | 3 |
| TF-026 | housekeepingSampling | SpaceLinkTest, linkBudgetTestSoftware | 2 |
| TF-027 | schedulerCapacity | CommandRoutingTest, groundReadinessDemoSoftware | 2 |
| TF-028 | boardSupportWatchdog | CaptureAbortTest, FaultDetectionTest, ModeManagementTest, faultResponseTestSoftware, autonomyTestSoftware | 5 |
| TF-030 | cdhApplication | CaptureAbortTest, ModeManagementTest, autonomyTestSoftware | 3 |
| TF-031 | gncApplication | FaultDetectionTest, faultResponseTestSoftware | 2 |
| TF-032 | sepControlApplication | ThrustArcControlTest | 1 |
| TF-033 | powerManagementApplication | PowerManagementTest | 1 |
| TF-034 | thermalControlApplication | CaptureAbortTest, ModeManagementTest, autonomyTestSoftware | 3 |
| TF-035 | telecomApplication | SpaceLinkTest, linkBudgetTestSoftware | 2 |
| TF-036 | inspectorHandlingApplication | contactSpeedTestSoftware | 1 |
| TF-037 | captureControlApplication | FaultDetectionTest, contactSpeedTestSoftware, faultResponseTestSoftware | 3 |
| TF-038 | autonomyApplication | CommandRoutingTest, groundReadinessDemoSoftware | 2 |
| TF-039 | fdirApplication | FaultDetectionTest, faultResponseTestSoftware | 2 |
| TF-040 | modeManagementApplication | FaultDetectionTest, faultResponseTestSoftware | 2 |
| TF-041 | parameterBootUpdateApplication | CaptureAbortTest, ModeManagementTest, autonomyTestSoftware | 3 |
| TM-001 | commandValidation | CommandRoutingTest, BootAndParameterTest, groundReadinessDemoSoftware | 3 |
| TM-002 | hazardousApproval | ThrustArcControlTest, groundReadinessDemoSoftware | 2 |
| TM-003 | sequenceClearance | CommandRoutingTest, ThrustArcControlTest, PowerManagementTest, groundReadinessDemoSoftware, groundProceduresDemoSoftware | 5 |
| TM-004 | telemetryDecommutation | BootAndParameterTest | 1 |
| TM-005 | limitAlarming | PowerManagementTest, PassPlanningTest, groundProceduresDemoSoftware | 3 |
| TM-006 | trendingAutomation | PassPlanningTest, groundReadinessDemoSoftware, groundProceduresDemoSoftware | 3 |
| TM-007 | flightDynamicsProducts | FinalTargetingTest, CaptureAbortTest, ModeManagementTest, autonomyTestSoftware, deflectionAnalysisSoftware, groundProceduresDemoSoftware | 6 |
| TM-008 | passPlanningVolume | SpaceLinkTest, linkBudgetTestSoftware, groundReadinessDemoSoftware | 3 |
| TM-009 | archiveRetention | groundProceduresDemoSoftware | 1 |
| TM-010 | anomalyDisposition | groundReadinessDemoSoftware | 1 |
| TM-011 | proximityGoNoGo | CaptureAbortTest, contactSpeedTestSoftware | 2 |
| TM-012 | simulatorFidelity | CaptureSequenceTest, captureEnvelopeTestSoftware | 2 |

*Software requirements without a verification case*

| shortName | name | documentation |
| --- | --- | --- |
| TF-010 | processorMemoryReserve | The flight software's processor load and memory footprint shall close against the<br>flight computer with the reserve the active software margin policy row<br>(TethysMarginPolicy::activeSoftwarePolicy) prescribes. Rationale: the reserve is<br>the policy's, not this row's, so a policy change re-evaluates every budget at<br>once (TS-142). |
| TF-011 | busReserve | The AABP-1 bus schedule of the full modes (proximity operations, capture, despin)<br>shall close against the frame with the reserve the active software margin policy<br>row prescribes. Rationale: the bus is the one shared resource every application<br>uses; the schedule currently uses more slots than the reserve allows, so this row<br>is open and its satisfaction fails until the maintainer resizes the schedule or<br>the policy (TS-143). |
| TF-012 | busReserveCoast | The AABP-1 bus schedule of the coast mode shall close against the frame with the<br>reserve the active software margin policy row prescribes. Rationale: coast is the<br>mode the tug spends most of the mission in, so its reserve is the one the growth<br>of the mission actually consumes (TS-143). |
| TF-023 | busMessaging | The AABP-1 software bus shall provide a topic for every software component, a<br>receive queue of at least one message per topic and a maximum message no longer<br>than the largest command packet. Rationale: a component without a topic cannot<br>publish, and a message longer than a packet cannot be relayed to the ground<br>(TS-143). |

*System verification cases covering software requirements*

| name | documentation | verifies |
| --- | --- | --- |
| captureEnvelopeTestSoftware | CaptureEnvelopeTest as it also verifies the software requirements derived from the system rows it verifies. | simulatorFidelity |
| contactSpeedTestSoftware | ContactSpeedTest as it also verifies the software requirements derived from the system rows it verifies. | inspectorHandlingApplication, captureControlApplication, proximityGoNoGo |
| linkBudgetTestSoftware | LinkBudgetTest as it also verifies the software requirements derived from the system rows it verifies. | telemetryRatesByMode, timeCorrelation, telemetrySampleLatency, dataStoreRetention, telemetryOutput, housekeepingSampling, telecomApplication, passPlanningVolume |
| faultResponseTestSoftware | FaultResponseTest as it also verifies the software requirements derived from the system rows it verifies. | eventLogging, parameterTables, partitionIsolation, faultDetectionChain, safeConfigurationLatency, fdirTaskRate, safeModeEntry, heartbeatFailover, boardSupportWatchdog, gncApplication, captureControlApplication, fdirApplication, modeManagementApplication |
| autonomyTestSoftware | AutonomyTest as it also verifies the software requirements derived from the system rows it verifies. | eventLogging, imageIntegrity, bootFallback, safeModeEntry, modeTransitions, redundancyManagement, heartbeatFailover, dataStoreRetention, boardSupportWatchdog, cdhApplication, thermalControlApplication, parameterBootUpdateApplication, flightDynamicsProducts |
| deflectionAnalysisSoftware | DeflectionAnalysis as it also verifies the software requirements derived from the system rows it verifies. | timeCorrelation, flightDynamicsProducts |
| groundReadinessDemoSoftware | GroundReadinessDemo as it also verifies the software requirements derived from the system rows it verifies. | commandIngest, telemetryRatesByMode, commandDispatchLatency, sequencingEngine, schedulerCapacity, autonomyApplication, commandValidation, hazardousApproval, sequenceClearance, trendingAutomation, passPlanningVolume, anomalyDisposition |
| groundProceduresDemoSoftware | GroundProceduresDemo as it also verifies the software requirements derived from the system rows it verifies. | sequenceClearance, limitAlarming, trendingAutomation, flightDynamicsProducts, archiveRetention |

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
