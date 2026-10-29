# Tethys verification and validation matrix

Every requirement of the Tethys tree (L1 to L4, needs, objectives and success criteria), the cases that verify it, the parts that satisfy it and the requirements it derives from.

*L1 mission requirements*

| shortName | name | Verification::method | Verification::level | Verification::stage | verifiedBy | cases | satisfiedBy | derivedFrom |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TR-001 | retrieval | analyze | mission | inFlight | DeliveryAnalysis | 1 |  |  |
| TR-002 | missionDuration | analyze | mission | inFlight | DeliveryAnalysis, MissionDurationByAnalysis | 2 |  |  |
| TR-003 | characterisation | analyze | mission | inFlight | CharacterisationAnalysis | 1 |  |  |
| TR-004 | launchCompatibility | test | system | acceptance | InterfaceBaselineInspection | 1 |  |  |
| TR-005 | groundCompatibility | test | system | preLaunch | GroundReadinessDemo | 1 |  |  |
| TR-006 | cislunarSafety | analyze | mission | qualification | ReturnSafetyAnalysis | 1 |  |  |
| TR-007 | missionClass | analyze | system | qualification | RedundancyInspection | 1 |  |  |
| TR-008 | deflectionDemonstration | demo | mission | inFlight | DeflectionAnalysis | 1 |  |  |
| TR-009 | utilisationAccess | demo | mission | inFlight | DockingDemo | 1 |  |  |

<a id="needs"></a>

*Needs, objectives and success criteria*

| shortName | name | Verification::method | Verification::level | Verification::stage | verifiedBy | cases | satisfiedBy | derivedFrom |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N-001 | returnedBodyNeed | demo | mission | inFlight | MissionValidation | 1 |  |  |
| N-002 | timelinessNeed | analyze | mission | inFlight | MissionValidation | 1 |  |  |
| N-003 | knownTargetNeed | demo | mission | inFlight | MissionValidation | 1 |  |  |
| N-004 | noEarthRiskNeed | analyze | mission | qualification | MissionValidation | 1 |  |  |
| N-005 | deflectionKnowledgeNeed | demo | mission | inFlight | MissionValidation | 1 |  |  |
| N-006 | surfaceAccessNeed | demo | mission | inFlight | DockingDemo | 1 |  |  |
| N-007 | operabilityNeed | demo | system | preLaunch | GroundReadinessDemo, ConOpsValidation | 2 |  |  |
| N-008 | robustToTargetNeed | analyze | mission | qualification | MissionValidation | 1 |  |  |
| N-009 | providerInterfaceNeed | inspect | system | qualification | InterfaceBaselineInspection | 1 |  |  |
| SO-001 | shapeModel | analyze | mission | inFlight | CharacterisationAnalysis | 1 |  |  |
| SO-002 | massEstimate | analyze | mission | inFlight | CharacterisationAnalysis | 1 |  |  |
| SO-003 | spinState | analyze | mission | inFlight | CharacterisationAnalysis | 1 |  |  |
| SO-004 | deflectionMeasurement | analyze | mission | inFlight | SuccessCriteriaValidation | 1 |  |  |
|  | minimumSuccess | demo | mission | inFlight | SuccessCriteriaValidation | 1 |  |  |
|  | fullSuccess | demo | mission | inFlight | SuccessCriteriaValidation | 1 |  |  |
| MS-001 | characterised | demo | mission | inFlight | SuccessCriteriaValidation | 1 |  |  |
| MS-002 | deflected | demo | mission | inFlight | SuccessCriteriaValidation | 1 |  |  |
| FS-001 | delivered | demo | mission | inFlight | SuccessCriteriaValidation | 1 |  |  |
| FS-002 | accessible | demo | mission | inFlight | SuccessCriteriaValidation | 1 |  |  |

*L2 system requirements*

| shortName | name | Verification::method | Verification::level | Verification::stage | verifiedBy | cases | satisfiedBy | derivedFrom |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TS-001 | captureEnvelope | test | system | qualification | CaptureEnvelopeTest, CaptureSequenceTest | 2 | argent |  |
| TS-002 | deliveredMass | analyze | mission | inFlight | DeliveryAnalysis | 1 | flight |  |
| TS-003 | transferDuration | analyze | mission | qualification | TransferTimelineByAnalysis | 1 | flight |  |
| TS-004 | propellantCapacity | analyze | system | qualification | PropellantAnalysis | 1 | argent |  |
| TS-005 | characterisationProducts | analyze | system | inFlight | CharacterisationAnalysis, InspectorRelayTest | 2 | flight |  |
| TS-006 | launchCompatibility | inspect | system | preLaunch | MassBudgetAnalysis | 1 |  |  |
| TS-007 | deepSpaceLink | test | system | preLaunch | LinkBudgetTest, SpaceLinkTest | 2 |  |  |
| TS-008 | earthImpactExclusion | analyze | mission | qualification | ReturnSafetyAnalysis, FinalTargetingTest | 2 | flight |  |
| TS-009 | droStability | analyze | mission | qualification | ReturnSafetyAnalysis | 1 | flight |  |
| TS-010 | thrustRedundancy | inspect | system | qualification | RedundancyInspection, SepCommissioning, ThrustArcControlTest | 3 | argent |  |
| TS-011 | deflectionMeasurement | analyze | mission | inFlight | DeflectionAnalysis | 1 | flight |  |
| TS-012 | visitorDocking | demo | mission | inFlight | DockingDemo | 1 |  |  |
| TS-013 | autonomousSurvival | test | system | qualification | AutonomyTest, CaptureAbortTest, ModeManagementTest | 3 | flight |  |
| TS-014 | proximityContactEnvironment | test | subsystem | qualification | ContactSpeedTest | 1 | argent |  |
| TS-015 | faultResponse | test | system | qualification | FaultResponseTest, FaultDetectionTest | 2 | flight |  |
| TS-016 | massBudget | analyze | system | acceptance | MassBudgetAnalysis | 1 | argent |  |
| TS-017 | captureQualification | test | subsystem | qualification | CaptureEnvelopeTest, CaptureSequenceTest | 2 |  |  |
| TS-018 | inspectorDeployment | test | system | acceptance | SeparationTest | 1 | flight |  |
| TS-019 | despinCapacity | analyze | system | qualification | DespinAnalysis | 1 | argent |  |
| TS-020 | groundCoverage | demo | system | preLaunch | GroundReadinessDemo | 1 | ground |  |
| TS-021 | commandLatency | demo | system | preLaunch | GroundReadinessDemo, CommandRoutingTest | 2 | ground |  |
| TS-022 | operatorWorkload | demo | system | preLaunch | GroundReadinessDemo | 1 | ground |  |
|  | flightPerformanceRequirements | inspect | system | qualification | DocumentInspection | 1 |  |  |
|  | flightSafetyAndAutonomyRequirements | inspect | system | qualification | DocumentInspection | 1 |  |  |
|  | flightEnvironmentAndBudgetRequirements | inspect | system | qualification | DocumentInspection | 1 |  |  |
|  | interfaceRequirements | inspect | system | qualification | DocumentInspection | 1 |  |  |
|  | groundSegmentRequirements | inspect | system | qualification | DocumentInspection | 1 |  |  |
|  | safetyRequirements | inspect | mission | qualification | DocumentInspection | 1 |  |  |

*L3 subsystem and L4 component requirements*

| shortName | name | Verification::method | Verification::level | Verification::stage | verifiedBy | cases | satisfiedBy | derivedFrom |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TA-001 | sepThrust | test | subsystem | qualification | SepHotFireTest, ThrustModelValidation, SepCommissioning, ThrustArcControlTest | 4 | sep | transferDuration |
| TA-002 | arrayPowerAtTarget | analyze | subsystem | qualification | PowerAnalysis, PowerManagementTest | 2 | eps | transferDuration |
| TA-003 | captureBagDiameter | test | subsystem | qualification | CaptureEnvelopeTest | 1 | captureSystem | captureEnvelope |
| TA-004 | contactSpeedTolerance | test | subsystem | qualification | ContactSpeedTest | 1 | captureSystem | proximityContactEnvironment |
| TA-005 | despinTorque | analyze | subsystem | qualification | DespinAnalysis | 1 | rcs | despinCapacity |
| TA-006 | hydrazineLoad | inspect | subsystem | acceptance | DespinAnalysis | 1 | rcs | despinCapacity |
| TA-007 | deepSpaceEirp | test | subsystem | acceptance | LinkBudgetTest, SpaceLinkTest | 2 | telecom | deepSpaceLink |
| TA-008 | proximityLinkRange | test | subsystem | acceptance | InspectorAcceptanceTest, InspectorCommissioning, InspectorRelayTest | 3 | telecom | inspectorDeployment |
| TA-009 | relativeNavigation | test | subsystem | qualification | ProximityNavigationTest, RelativeStateEstimationTest | 2 | gnc | characterisationProducts |
| TA-010 | faultDetectionLatency | test | subsystem | qualification | FaultResponseTest, FaultDetectionTest | 2 | cdh | faultResponse |
| TA-011 | heatRejection | test | subsystem | qualification | ThermalBalanceTest, ThermalControlTest | 2 | thermal | proximityContactEnvironment |
| TA-012 | dockingLoads | analyze | subsystem | qualification | DockingLoadsAnalysis | 1 | structure | visitorDocking |
| TA-013 | inspectorSeparation | test | subsystem | acceptance | SeparationTest | 1 | structure | inspectorDeployment |
| TA-014 | spinStateSensing | analyze | subsystem | qualification | CharacterisationAnalysis | 1 | sensors | characterisationProducts |
| TW-001 | imagingResolution | test | subsystem | acceptance | InspectorAcceptanceTest | 1 | payload | characterisationProducts |
| TW-002 | circumnavigationPropellant | analyze | subsystem | qualification | CharacterisationAnalysis | 1 | propulsion | characterisationProducts |
| TW-003 | keepAlivePower | test | subsystem | acceptance | InspectorAcceptanceTest, InspectorCommissioning | 2 | bus | inspectorDeployment |
| TW-004 | inspectorMass | test | subsystem | acceptance | InspectorAcceptanceTest | 1 | wren | launchCompatibility |
| TW-005 | dopplerForMass | test | subsystem | qualification | InspectorAcceptanceTest | 1 | bus | characterisationProducts |
| TG-001 | stationAperture | inspect | subsystem | preLaunch | LinkBudgetTest | 1 | primaryStation | deepSpaceLink |
| TG-002 | stationSpacing | inspect | subsystem | preLaunch | GroundInspection | 1 | network | deepSpaceLink |
| TG-003 | rangingAccuracy | demo | subsystem | preLaunch | DeflectionAnalysis | 1 | fdf | deflectionMeasurement |
| TG-004 | impactScreening | demo | subsystem | preLaunch | GroundProceduresDemo, FinalTargetingTest | 2 | fdf | earthImpactExclusion |
| TG-005 | sequenceTurnaround | demo | subsystem | preLaunch | GroundProceduresDemo, GroundCommandTwoStepTest | 2 | moc | commandLatency |
| TG-006 | monitoringAutomation | demo | subsystem | preLaunch | GroundProceduresDemo, PassPlanningTest | 2 | moc | operatorWorkload |
| TG-007 | scienceArchive | demo | subsystem | preLaunch | GroundProceduresDemo | 1 | sds | characterisationProducts |
| TC-001 | thrusterUnitThrust | test | unit | qualification | SepHotFireTest | 1 | sep | sepThrust, transferDuration |
| TC-002 | powerProcessingEfficiency | test | unit | acceptance | SepHotFireTest | 1 | sep | sepThrust, transferDuration |
| TC-003 | cinchMotorTorque | test | unit | acceptance | CinchMotorTest, CaptureSequenceTest | 2 | captureSystem | captureBagDiameter, captureEnvelope |
| TC-004 | narrowAngleCameraSensitivity | test | unit | qualification | ProximityNavigationTest | 1 | sensors | relativeNavigation, characterisationProducts |
| TC-005 | fdirTaskPeriod | test | unit | acceptance | FaultResponseTest, FaultDetectionTest | 2 | cdh | faultDetectionLatency, faultResponse |
| TC-006 | inspectorDetectorPitch | inspect | unit | acceptance | InspectorAcceptanceTest | 1 | payload | imagingResolution, characterisationProducts |

## Requirements without a verification case

*Unverified requirements (expected empty)*

| shortName | name |
| --- | --- |
