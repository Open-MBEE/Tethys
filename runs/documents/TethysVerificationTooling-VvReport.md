# Tethys verification and validation matrix

Every requirement of the Tethys tree (L1 to L4, needs, objectives and success criteria), the cases that verify it, the parts that satisfy it and the requirements it derives from.

*L1 mission requirements*

| shortName | name | verifiedBy | cases | satisfiedBy | derivedFrom |
| --- | --- | --- | --- | --- | --- |
| TR-001 | retrieval | DeliveryAnalysis | 1 |  |  |
| TR-002 | missionDuration | DeliveryAnalysis, MissionDurationByAnalysis | 2 |  |  |
| TR-003 | characterisation | CharacterisationAnalysis | 1 |  |  |
| TR-004 | launchCompatibility | InterfaceBaselineInspection | 1 |  |  |
| TR-005 | groundCompatibility | GroundReadinessDemo | 1 |  |  |
| TR-006 | cislunarSafety | ReturnSafetyAnalysis | 1 |  |  |
| TR-007 | missionClass | RedundancyInspection | 1 |  |  |
| TR-008 | deflectionDemonstration | DeflectionAnalysis | 1 |  |  |
| TR-009 | utilisationAccess | DockingDemo | 1 |  |  |

*Needs, objectives and success criteria*

| shortName | name | verifiedBy | cases | satisfiedBy | derivedFrom |
| --- | --- | --- | --- | --- | --- |
| N-001 | returnedBodyNeed | MissionValidation | 1 |  |  |
| N-002 | timelinessNeed | MissionValidation | 1 |  |  |
| N-003 | knownTargetNeed | MissionValidation | 1 |  |  |
| N-004 | noEarthRiskNeed | MissionValidation | 1 |  |  |
| N-005 | deflectionKnowledgeNeed | MissionValidation | 1 |  |  |
| N-006 | surfaceAccessNeed | DockingDemo | 1 |  |  |
| N-007 | operabilityNeed | GroundReadinessDemo, ConOpsValidation | 2 |  |  |
| N-008 | robustToTargetNeed | MissionValidation | 1 |  |  |
| N-009 | providerInterfaceNeed | InterfaceBaselineInspection | 1 |  |  |
| SO-001 | shapeModel | CharacterisationAnalysis | 1 |  |  |
| SO-002 | massEstimate | CharacterisationAnalysis | 1 |  |  |
| SO-003 | spinState | CharacterisationAnalysis | 1 |  |  |
| SO-004 | deflectionMeasurement | SuccessCriteriaValidation | 1 |  |  |
|  | minimumSuccess | SuccessCriteriaValidation | 1 |  |  |
|  | fullSuccess | SuccessCriteriaValidation | 1 |  |  |
| MS-001 | characterised | SuccessCriteriaValidation | 1 |  |  |
| MS-002 | deflected | SuccessCriteriaValidation | 1 |  |  |
| FS-001 | delivered | SuccessCriteriaValidation | 1 |  |  |
| FS-002 | accessible | SuccessCriteriaValidation | 1 |  |  |

*L2 system requirements*

| shortName | name | verifiedBy | cases | satisfiedBy | derivedFrom |
| --- | --- | --- | --- | --- | --- |
| TS-001 | captureEnvelope | CaptureEnvelopeTest | 1 | argent |  |
| TS-002 | deliveredMass | DeliveryAnalysis | 1 | flight |  |
| TS-003 | transferDuration | PowerAnalysis | 1 | flight |  |
| TS-004 | propellantCapacity | PropellantAnalysis | 1 | argent |  |
| TS-005 | characterisationProducts | CharacterisationAnalysis | 1 | flight |  |
| TS-006 | launchCompatibility | MassBudgetAnalysis | 1 |  |  |
| TS-007 | deepSpaceLink | LinkBudgetTest | 1 |  |  |
| TS-008 | earthImpactExclusion | ReturnSafetyAnalysis | 1 | flight |  |
| TS-009 | droStability | ReturnSafetyAnalysis | 1 | flight |  |
| TS-010 | thrustRedundancy | RedundancyInspection, SepCommissioning | 2 | argent |  |
| TS-011 | deflectionMeasurement | DeflectionAnalysis | 1 | flight |  |
| TS-012 | visitorDocking | DockingDemo | 1 |  |  |
| TS-013 | autonomousSurvival | AutonomyTest | 1 | flight |  |
| TS-014 | proximityContactEnvironment | ContactSpeedTest | 1 | argent |  |
| TS-015 | faultResponse | FaultResponseTest | 1 | flight |  |
| TS-016 | massBudget | MassBudgetAnalysis | 1 | argent |  |
| TS-017 | captureQualification | CaptureEnvelopeTest | 1 |  |  |
| TS-018 | inspectorDeployment | SeparationTest | 1 | flight |  |
| TS-019 | despinCapacity | DespinAnalysis | 1 | argent |  |
| TS-020 | groundCoverage | GroundReadinessDemo | 1 | ground |  |
| TS-021 | commandLatency | GroundReadinessDemo | 1 | ground |  |
| TS-022 | operatorWorkload | GroundReadinessDemo | 1 | ground |  |
|  | flightPerformanceRequirements | DocumentInspection | 1 |  |  |
|  | flightSafetyAndAutonomyRequirements | DocumentInspection | 1 |  |  |
|  | flightEnvironmentAndBudgetRequirements | DocumentInspection | 1 |  |  |
|  | interfaceRequirements | DocumentInspection | 1 |  |  |
|  | groundSegmentRequirements | DocumentInspection | 1 |  |  |
|  | safetyRequirements | DocumentInspection | 1 |  |  |

*L3 subsystem and L4 component requirements*

| shortName | name | verifiedBy | cases | satisfiedBy | derivedFrom |
| --- | --- | --- | --- | --- | --- |
| TA-001 | sepThrust | SepHotFireTest, ThrustModelValidation, SepCommissioning | 3 | sep | transferDuration |
| TA-002 | arrayPowerAtTarget | PowerAnalysis | 1 | eps | transferDuration |
| TA-003 | captureBagDiameter | CaptureEnvelopeTest | 1 | captureSystem | captureEnvelope |
| TA-004 | contactSpeedTolerance | ContactSpeedTest | 1 | captureSystem | proximityContactEnvironment |
| TA-005 | despinTorque | DespinAnalysis | 1 | rcs | despinCapacity |
| TA-006 | hydrazineLoad | DespinAnalysis | 1 | rcs | despinCapacity |
| TA-007 | deepSpaceEirp | LinkBudgetTest | 1 | telecom | deepSpaceLink |
| TA-008 | proximityLinkRange | InspectorAcceptanceTest, InspectorCommissioning | 2 | telecom | inspectorDeployment |
| TA-009 | relativeNavigation | ProximityNavigationTest | 1 | gnc | characterisationProducts |
| TA-010 | faultDetectionLatency | FaultResponseTest | 1 | cdh | faultResponse |
| TA-011 | heatRejection | ThermalBalanceTest | 1 | thermal | proximityContactEnvironment |
| TA-012 | dockingLoads | DockingLoadsAnalysis | 1 | structure | visitorDocking |
| TA-013 | inspectorSeparation | SeparationTest | 1 | structure | inspectorDeployment |
| TA-014 | spinStateSensing | CharacterisationAnalysis | 1 | sensors | characterisationProducts |
| TW-001 | imagingResolution | InspectorAcceptanceTest | 1 | payload | characterisationProducts |
| TW-002 | circumnavigationPropellant | CharacterisationAnalysis | 1 | propulsion | characterisationProducts |
| TW-003 | keepAlivePower | InspectorAcceptanceTest, InspectorCommissioning | 2 | bus | inspectorDeployment |
| TW-004 | inspectorMass | InspectorAcceptanceTest | 1 | wren | launchCompatibility |
| TW-005 | dopplerForMass | InspectorAcceptanceTest | 1 | bus | characterisationProducts |
| TG-001 | stationAperture | LinkBudgetTest | 1 | primaryStation | deepSpaceLink |
| TG-002 | stationSpacing | GroundInspection | 1 | network | deepSpaceLink |
| TG-003 | rangingAccuracy | DeflectionAnalysis | 1 | fdf | deflectionMeasurement |
| TG-004 | impactScreening | GroundProceduresDemo | 1 | fdf | earthImpactExclusion |
| TG-005 | sequenceTurnaround | GroundProceduresDemo | 1 | moc | commandLatency |
| TG-006 | monitoringAutomation | GroundProceduresDemo | 1 | moc | operatorWorkload |
| TG-007 | scienceArchive | GroundProceduresDemo | 1 | sds | characterisationProducts |
| TC-001 | thrusterUnitThrust | SepHotFireTest | 1 | sep | sepThrust, transferDuration |
| TC-002 | powerProcessingEfficiency | SepHotFireTest | 1 | sep | sepThrust, transferDuration |
| TC-003 | cinchMotorTorque | CinchMotorTest | 1 | captureSystem | captureBagDiameter, captureEnvelope |
| TC-004 | narrowAngleCameraSensitivity | ProximityNavigationTest | 1 | sensors | relativeNavigation, characterisationProducts |
| TC-005 | fdirTaskPeriod | FaultResponseTest | 1 | cdh | faultDetectionLatency, faultResponse |
| TC-006 | inspectorDetectorPitch | InspectorAcceptanceTest | 1 | payload | imagingResolution, characterisationProducts |

## Requirements without a verification case

*Unverified requirements (expected empty)*

| shortName | name |
| --- | --- |
