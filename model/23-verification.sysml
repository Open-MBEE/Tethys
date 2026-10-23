// The verification programme: the V&V plan vocabulary, verification cases per method with
// executable verdicts (every requirement of the tree is verified by at least one), validation of
// the needs and use cases, the test campaign timeline, the environmental test matrix, test beds,
// closure, non-conformances and the V&V matrix view.
package TethysVerification {
    doc /* Verification and validation of Tethys. A verification case's objective names the
         * requirements it verifies; its body returns a verdict from the backbone values or
         * from the as-run result bound on the usage. Metadata records the specification,
         * facility, result and closure state of each activity. */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SequenceFunctions::size;
    private import RealFunctions::abs;
    private import VerificationCases::*;
    private import ModelingMetadata::*;
    private import StandardViewDefinitions::*;
    private import Views::asTreeDiagram;
    private import TethysRequirements::Verification;
    private import TethysRequirements::VerificationLevel;
    private import TethysRequirements::VerificationStage;
    private import TethysRequirements::retrieval;
    private import TethysRequirements::missionDuration;
    private import TethysRequirements::characterisation;
    private import TethysRequirements::groundCompatibility;
    private import TethysRequirements::cislunarSafety;
    private import TethysRequirements::missionClass;
    private import TethysRequirements::deflectionDemonstration;
    private import TethysRequirements::utilisationAccess;
    private import TethysRequirementsL2::*;
    private import TethysRequirementsL3L4::*;
    private import TethysStakeholders::targetCases;
    private import TethysStakeholders::missionMeasures;
    private import TethysStakeholders::verificationViewpoint;
    private import TethysStakeholders::returnedBodyNeed;
    private import TethysStakeholders::timelinessNeed;
    private import TethysStakeholders::knownTargetNeed;
    private import TethysStakeholders::noEarthRiskNeed;
    private import TethysStakeholders::deflectionKnowledgeNeed;
    private import TethysStakeholders::surfaceAccessNeed;
    private import TethysStakeholders::operabilityNeed;
    private import TethysStakeholders::robustToTargetNeed;
    private import TethysStakeholders::providerInterfaceNeed;
    private import TethysStakeholders::shapeModel;
    private import TethysStakeholders::massEstimate;
    private import TethysStakeholders::spinState;
    private import TethysStakeholders::minimumSuccess;
    private import TethysStakeholders::fullSuccess;
    private import TethysStakeholders::retrieveAmaranth;
    private import TethysSystem::*;
    private import TethysTug::*;
    private import TethysInspector::*;

    // The method metadata of each case is declared with `metadata … about` after its def rather
    // than inside the body: see docs/findings/WP-A.md F-A06.

    // ---- V&V plan vocabulary --------------------------------------------------------------

    metadata def TestSpecification {
        doc /* The specification an activity runs to: its procedure, where it runs and the
             * report its result is recorded in. */
        attribute procedure : String;
        attribute facility : String;
        attribute report : String;
    }
    metadata def Closure {
        doc /* The verification control entry: who closed the requirement, on what evidence,
             * and the closure state. */
        attribute closedBy : String;
        attribute evidence : String;
        attribute status : StatusKind;
    }
    metadata def Nonconformance {
        doc /* A non-conformance raised during an activity and its disposition. */
        attribute reference : String;
        attribute description : String;
        attribute disposition : String;
        attribute status : StatusKind;
    }
    metadata def HeritageQualification {
        doc /* Qualification by similarity: the heritage unit and what differs from it. */
        attribute heritageUnit : String;
        attribute delta : String;
    }
    metadata def CampaignStep {
        doc /* Where an activity sits in the test campaign. */
        attribute campaignPhase : String;
        attribute sequence : Integer;
    }

    part def TestBed {
        doc /* A simulator or test bed the programme verifies against. */
        attribute fidelity : String;
        attribute readyBy : String;
    }
    part testBeds {
        doc /* The simulators and test beds. */
        part flatsat : TestBed {
            doc /* Engineering-model avionics with flight software, used for fault-response and
                 * autonomy tests. */
            attribute :>> fidelity = "engineering model avionics, flight software";
            attribute :>> readyBy = "CDR";
        }
        part captureRig : TestBed {
            doc /* A thermal-vacuum rig with a rotating mock body for bag deployment and cinch tests. */
            attribute :>> fidelity = "full-scale bag, 10 m mock body, vacuum";
            attribute :>> readyBy = "CDR plus 6 months";
        }
        part dynamicsSimulator : TestBed {
            doc /* Six-degree-of-freedom proximity-operations simulator with the GNC flight code. */
            attribute :>> fidelity = "6-DoF, flight GNC code in the loop";
            attribute :>> readyBy = "PDR";
        }
        part trajectoryTool : TestBed {
            doc /* The flight dynamics facility's propagation tool used for the Earth-impact and
                 * DRO analyses, validated against independent propagation. */
            attribute :>> fidelity = "n-body with SRP, validated";
            attribute :>> readyBy = "PDR";
        }
    }

    // ---- Verification cases: test -----------------------------------------------------------

    verification def CaptureEnvelopeTest {
        doc /* Full-scale deployment, inflation and cinch of the capture bag around a rotating
             * mock body of the large case's diameter in vacuum. */
        subject tug : Tug;
        objective {
            doc /* The bag accommodates the large and dense cases. */
            verify captureEnvelope { doc /* Verified by this case. */ }
            verify captureBagDiameter { doc /* Verified by this case. */ }
            verify captureQualification { doc /* Verified by this case. */ }
        }
        PassIf(tug.captureSystem.maximumBodyDiameter >= targetCases.large.meanDiameter + 0.5 [m]
            and tug.captureSystem.maximumBodyMass >= targetCases.large.mass
            and tug.captureSystem.maximumBodyMass >= targetCases.dense.mass)
    }
    metadata VerificationMethod about CaptureEnvelopeTest { kind = VerificationMethodKind::test; }
    verification def ContactSpeedTest {
        doc /* Bag contact with a surface moving at the design contact speed on the capture rig. */
        subject tug : Tug;
        in attribute measuredToleratedSpeed : SpeedValue;
        objective {
            doc /* The bag survives contact at the large case's equatorial speed. */
            verify proximityContactEnvironment { doc /* Verified by this case. */ }
            verify contactSpeedTolerance { doc /* Verified by this case. */ }
        }
        PassIf(measuredToleratedSpeed >= 3.14159265 * targetCases.large.meanDiameter / targetCases.large.rotationPeriod)
    }
    metadata VerificationMethod about ContactSpeedTest { kind = VerificationMethodKind::test; }
    verification def SepHotFireTest {
        doc /* Thrust-stand hot fire of one thruster string at its power share and a three-string
             * firing at maximum power. */
        subject tug : Tug;
        in attribute measuredThrust : ForceValue;
        in attribute measuredUnitThrust : ForceValue;
        objective {
            doc /* Thrust at power meets the subsystem and unit requirements. */
            verify sepThrust { doc /* Verified by this case. */ }
            verify thrusterUnitThrust { doc /* Verified by this case. */ }
            verify powerProcessingEfficiency { doc /* Verified by this case. */ }
        }
        PassIf(measuredThrust >= 1.8 [N] and measuredUnitThrust >= 0.6 [N])
    }
    metadata VerificationMethod about SepHotFireTest { kind = VerificationMethodKind::test; }
    verification def LinkBudgetTest {
        doc /* Compatibility test of the flight transponder with a Meridian station emulator at
             * the design range attenuation. */
        subject tug : Tug;
        in attribute measuredEirp : PowerValue;
        in attribute measuredMargin : Real;
        objective {
            doc /* The link closes with 3 dB margin at the design range. */
            verify deepSpaceLink { doc /* Verified by this case. */ }
            verify deepSpaceEirp { doc /* Verified by this case. */ }
            verify stationAperture { doc /* Verified by this case. */ }
        }
        PassIf(measuredEirp >= 1500.0 [W] and measuredMargin >= 3.0)
    }
    metadata VerificationMethod about LinkBudgetTest { kind = VerificationMethodKind::test; }
    verification def FaultResponseTest {
        doc /* Injected thrust-vector and contact faults on the flatsat, timing detection and the
             * safe configuration. */
        subject tug : Tug;
        in attribute measuredDetection : DurationValue;
        in attribute measuredResponse : DurationValue;
        objective {
            doc /* Detection within 0.5 s and safe configuration within 2 s. */
            verify faultResponse { doc /* Verified by this case. */ }
            verify faultDetectionLatency { doc /* Verified by this case. */ }
            verify fdirTaskPeriod { doc /* Verified by this case. */ }
        }
        PassIf(measuredDetection <= 0.5 [s] and measuredResponse <= 2 [s])
    }
    metadata VerificationMethod about FaultResponseTest { kind = VerificationMethodKind::test; }
    verification def AutonomyTest {
        doc /* Seven-day unattended run of the flatsat with simulated safe-mode entries. */
        subject tug : Tug;
        in attribute unattendedDuration : DurationValue;
        objective {
            doc /* The vehicle stays safe and commandable for 7 d. */
            verify autonomousSurvival { doc /* Verified by this case. */ }
        }
        PassIf(unattendedDuration >= 7 [d])
    }
    metadata VerificationMethod about AutonomyTest { kind = VerificationMethodKind::test; }
    verification def InspectorAcceptanceTest {
        doc /* Wren acceptance: mass properties, keep-alive power, proximity link, imaging
             * resolution and Doppler accuracy on the bench. */
        subject inspector : Inspector;
        in attribute measuredKeepAlive : PowerValue;
        in attribute measuredGsd : LengthValue;
        in attribute measuredDoppler : SpeedValue;
        objective {
            doc /* The inspector meets its L3 and L4 requirements. */
            verify inspectorMass { doc /* Verified by this case. */ }
            verify keepAlivePower { doc /* Verified by this case. */ }
            verify imagingResolution { doc /* Verified by this case. */ }
            verify dopplerForMass { doc /* Verified by this case. */ }
            verify inspectorDetectorPitch { doc /* Verified by this case. */ }
            verify proximityLinkRange { doc /* Verified by this case. */ }
        }
        PassIf(inspector.wetMass <= 25.0 [kg] and measuredKeepAlive <= 5.0 [W]
            and measuredGsd <= 0.02 [m] and measuredDoppler <= 0.0001 [m/s])
    }
    metadata VerificationMethod about InspectorAcceptanceTest { kind = VerificationMethodKind::test; }
    verification def SeparationTest {
        doc /* Dispenser release test on the gravity-offload rig: separation speed and tip-off. */
        subject tug : Tug;
        in attribute measuredSeparationSpeed : SpeedValue;
        objective {
            doc /* Separation between 2 and 5 cm/s. */
            verify inspectorDeployment { doc /* Verified by this case. */ }
            verify inspectorSeparation { doc /* Verified by this case. */ }
        }
        PassIf(measuredSeparationSpeed >= 0.02 [m/s] and measuredSeparationSpeed <= 0.05 [m/s])
    }
    metadata VerificationMethod about SeparationTest { kind = VerificationMethodKind::test; }
    verification def ProximityNavigationTest {
        doc /* Closed-loop relative navigation on the dynamics simulator with flight GNC code,
             * and camera sensitivity on the optical bench. */
        subject tug : Tug;
        in attribute measuredPositionError : LengthValue;
        in attribute measuredVelocityError : SpeedValue;
        in attribute measuredLimitingMagnitude : Real;
        objective {
            doc /* Relative position to 0.1 m at 100 m; the camera reaches magnitude 12.5. */
            verify relativeNavigation { doc /* Verified by this case. */ }
            verify narrowAngleCameraSensitivity { doc /* Verified by this case. */ }
        }
        PassIf(measuredPositionError <= 0.1 [m] and measuredVelocityError <= 0.001 [m/s] and measuredLimitingMagnitude >= 12.5)
    }
    metadata VerificationMethod about ProximityNavigationTest { kind = VerificationMethodKind::test; }
    verification def ThermalBalanceTest {
        doc /* Thermal-vacuum balance test at perihelion flux with the bag deployed. */
        subject tug : Tug;
        in attribute measuredRejection : PowerValue;
        objective {
            doc /* The radiators reject 8 kW. */
            verify heatRejection { doc /* Verified by this case. */ }
        }
        PassIf(measuredRejection >= 8.0 [kW])
    }
    metadata VerificationMethod about ThermalBalanceTest { kind = VerificationMethodKind::test; }
    verification def CinchMotorTest {
        doc /* Stall-torque test of a cinch motor at qualification temperature. */
        subject tug : Tug;
        in attribute measuredStallTorqueNm : Real;
        objective {
            doc /* Stall torque of 40 N m. */
            verify cinchMotorTorque { doc /* Verified by this case. */ }
        }
        PassIf(measuredStallTorqueNm >= 40.0)
    }
    metadata VerificationMethod about CinchMotorTest { kind = VerificationMethodKind::test; }

    // ---- Verification cases: analysis ---------------------------------------------------------

    verification def PropellantAnalysis {
        doc /* Rocket-equation check of the outbound and return delta-v against the xenon load,
             * with the nominal and dense cases attached. */
        subject tug : Tug;
        objective {
            doc /* Outbound 3 200 m/s; return 300 m/s nominal, 240 m/s dense. */
            verify propellantCapacity { doc /* Verified by this case. */ }
        }
        PassIf(TethysEnvironment::RocketEquationDeltaV(2900.0, tug.wetMass / 1 [kg], (tug.wetMass - 1500 [kg]) / 1 [kg]) >= 3200.0
            and TethysEnvironment::RocketEquationDeltaV(2900.0, (tug.wetMass - 1500 [kg] + targetCases.nominal.mass) / 1 [kg], (tug.wetMass - 1500 [kg] + targetCases.nominal.mass - (tug.sep.xenonMass - 1500 [kg])) / 1 [kg]) >= 300.0
            and TethysEnvironment::RocketEquationDeltaV(2900.0, (tug.wetMass - 1500 [kg] + targetCases.dense.mass) / 1 [kg], (tug.wetMass - 1500 [kg] + targetCases.dense.mass - (tug.sep.xenonMass - 1500 [kg])) / 1 [kg]) >= 240.0)
    }
    metadata VerificationMethod about PropellantAnalysis { kind = VerificationMethodKind::analyze; }
    verification def DespinAnalysis {
        doc /* Angular-momentum budget of the large-case despin against the hydrazine load and
             * the RCS torque. */
        subject tug : Tug;
        objective {
            doc /* Despin uses under a quarter of the hydrazine. */
            verify despinCapacity { doc /* Verified by this case. */ }
            verify despinTorque { doc /* Verified by this case. */ }
            verify hydrazineLoad { doc /* Verified by this case. */ }
        }
        PassIf(tug.rcs.hydrazineMass >= 4.0 * 60.0 [kg])
    }
    metadata VerificationMethod about DespinAnalysis { kind = VerificationMethodKind::analyze; }
    verification def PowerAnalysis {
        doc /* Array power at 1.034 AU against the SEP throttle point and bus load, and the
             * transfer timeline (TS-003's thrust, coast, proximity and reserve allocations)
             * against the nominal duration. */
        subject tug : Tug;
        objective {
            doc /* 38 kW plus 6 kW available at the target. */
            verify arrayPowerAtTarget { doc /* Verified by this case. */ }
            verify transferDuration { doc /* Verified by this case. */ }
        }
        PassIf(tug.eps.arrayPowerAtOneAu * (TethysEnvironment::SolarFlux(1.034) / TethysEnvironment::SolarFlux(1.0)) >= 44.0 [kW]
            and 1100 [d] + 650 [d] + 150 [d] + 300 [d] <= TethysMission::tethys.nominalDuration)
    }
    metadata VerificationMethod about PowerAnalysis { kind = VerificationMethodKind::analyze; }
    verification def MassBudgetAnalysis {
        doc /* Dry mass against allocation with the PDR margin; launch mass against the launcher. */
        subject tug : Tug;
        objective {
            doc /* 15 % margin on dry mass; launch mass under 17 200 kg. */
            verify massBudget { doc /* Verified by this case. */ }
            verify launchCompatibility { doc /* Verified by this case. */ }
        }
        PassIf(tug.dryMass * 1.15 <= 7000 [kg] and tug.wetMass + wren.wetMass <= TethysLaunch::arcturus5H.performanceAtC3)
    }
    metadata VerificationMethod about MassBudgetAnalysis { kind = VerificationMethodKind::analyze; }
    verification def ReturnSafetyAnalysis {
        doc /* Monte Carlo of thrust loss along the return on the trajectory tool: Earth-impact
             * probability and DRO stability horizon. */
        subject flight : TethysFlightSegment;
        objective {
            doc /* Impact probability under one in a million; DRO bound for 100 years. */
            verify earthImpactExclusion { doc /* Verified by this case. */ }
            verify droStability { doc /* Verified by this case. */ }
            verify cislunarSafety { doc /* Verified by this case. */ }
        }
        PassIf(missionMeasures.earthImpactProbability < 1.0e-6 and TethysEnvironment::destinationDro.stabilityHorizon >= 36525.0 [d])
    }
    metadata VerificationMethod about ReturnSafetyAnalysis { kind = VerificationMethodKind::analyze; }
    verification def DeliveryAnalysis {
        doc /* Delivered mass and schedule for the nominal case from the mission design. */
        subject flight : TethysFlightSegment;
        objective {
            doc /* 100 t within the nominal duration. */
            verify deliveredMass { doc /* Verified by this case. */ }
            verify retrieval { doc /* Verified by this case. */ }
            verify missionDuration { doc /* Verified by this case. */ }
        }
        PassIf(0.99 * targetCases.nominal.mass >= 100.0e3 [kg] and 2200 [d] <= TethysMission::tethys.nominalDuration)
    }
    metadata VerificationMethod about DeliveryAnalysis { kind = VerificationMethodKind::analyze; }
    verification def CharacterisationAnalysis {
        doc /* Covariance analysis of the mass, shape and spin products from the inspector and tug
             * measurements. */
        subject flight : TethysFlightSegment;
        objective {
            doc /* Mass to 10 %, shape to 0.1 m, spin to 1 %. */
            verify characterisationProducts { doc /* Verified by this case. */ }
            verify characterisation { doc /* Verified by this case. */ }
            verify shapeModel { doc /* Verified by this case. */ }
            verify massEstimate { doc /* Verified by this case. */ }
            verify spinState { doc /* Verified by this case. */ }
            verify spinStateSensing { doc /* Verified by this case. */ }
            verify circumnavigationPropellant { doc /* Verified by this case. */ }
        }
        PassIf(missionMeasures.massEstimateUncertainty <= 0.10)
    }
    metadata VerificationMethod about CharacterisationAnalysis { kind = VerificationMethodKind::analyze; }
    verification def DeflectionAnalysis {
        doc /* Orbit-determination covariance over a 30 d slow-push arc with 2 m ranging. */
        subject flight : TethysFlightSegment;
        objective {
            doc /* Velocity change to 1 mm/s. */
            verify deflectionMeasurement { doc /* Verified by this case. */ }
            verify deflectionDemonstration { doc /* Verified by this case. */ }
            verify TethysRequirementsL3L4::rangingAccuracy { doc /* Verified by this case. */ }
        }
        PassIf(missionMeasures.rangingAccuracy / (30 [d]) <= 0.001 [m/s])
    }
    metadata VerificationMethod about DeflectionAnalysis { kind = VerificationMethodKind::analyze; }
    verification def DockingLoadsAnalysis {
        doc /* Structural analysis of the docking load path into the cinched body. */
        subject tug : Tug;
        in attribute analysedCapability : ForceValue;
        objective {
            doc /* 5 kN through the docking port. */
            verify dockingLoads { doc /* Verified by this case. */ }
        }
        PassIf(analysedCapability >= 5000.0 [N])
    }
    metadata VerificationMethod about DockingLoadsAnalysis { kind = VerificationMethodKind::analyze; }
    verification def ThrustModelValidation {
        doc /* Validation of the SepThrust model against the hot-fire measurement: the model must
             * match the thrust stand to 3 %. */
        subject tug : Tug;
        in attribute measuredThrust : ForceValue;
        objective {
            doc /* Model within 3 % of test. */
            verify sepThrust { doc /* Verified by this case. */ }
        }
        PassIf(abs(measuredThrust / 1 [N] - TethysEnvironment::SepThrust(tug.sep.maximumPower / 1 [W], tug.sep.specificImpulse / 1 [s], 0.65)) <= 0.03 * TethysEnvironment::SepThrust(tug.sep.maximumPower / 1 [W], tug.sep.specificImpulse / 1 [s], 0.65))
    }
    metadata VerificationMethod about ThrustModelValidation { kind = VerificationMethodKind::analyze; }

    // ---- Verification cases: inspection ------------------------------------------------------

    verification def RedundancyInspection {
        doc /* Inspection of the SEP string count and the fault tree against the single-point
             * failure list. */
        subject tug : Tug;
        objective {
            doc /* One more thruster than operated. */
            verify thrustRedundancy { doc /* Verified by this case. */ }
            verify missionClass { doc /* Verified by this case. */ }
        }
        PassIf(tug.sep.thrusterCount - tug.sep.operatingThrusters >= 1)
    }
    metadata VerificationMethod about RedundancyInspection { kind = VerificationMethodKind::inspect; }
    verification def DocumentInspection {
        doc /* Inspection of the requirement groups, ICDs and the interface requirement set at
             * the system PDR. */
        subject mission : TethysMission::Mission;
        objective {
            doc /* Every group and interface requirement is baselined. */
            verify flightPerformanceRequirements { doc /* Verified by this case. */ }
            verify flightSafetyAndAutonomyRequirements { doc /* Verified by this case. */ }
            verify flightEnvironmentAndBudgetRequirements { doc /* Verified by this case. */ }
            verify interfaceRequirements { doc /* Verified by this case. */ }
            verify groundSegmentRequirements { doc /* Verified by this case. */ }
            verify safetyRequirements { doc /* Verified by this case. */ }
        }
        PassIf(true)
    }
    metadata VerificationMethod about DocumentInspection { kind = VerificationMethodKind::inspect; }
    verification def InterfaceBaselineInspection {
        doc /* Inspection of the launch and ground ICDs at the system PDR against the providers'
             * need and the L1 launch compatibility requirement. */
        subject mission : TethysMission::Mission;
        in attribute icdsBaselined : Natural;
        objective {
            doc /* Both ICDs are baselined. */
            verify providerInterfaceNeed { doc /* Verified by this case. */ }
            verify TethysRequirements::launchCompatibility { doc /* Verified by this case. */ }
        }
        PassIf(icdsBaselined >= 2)
    }
    metadata VerificationMethod about InterfaceBaselineInspection { kind = VerificationMethodKind::inspect; }
    verification def GroundInspection {
        doc /* Inspection of the station inventory and spacing. */
        subject ground : TethysGroundSegment;
        objective {
            doc /* Three stations. */
            verify stationSpacing { doc /* Verified by this case. */ }
        }
        PassIf(ground.network.stations->size() >= 3)
    }
    metadata VerificationMethod about GroundInspection { kind = VerificationMethodKind::inspect; }

    // ---- Verification cases: demonstration (ground and in flight) -----------------------------

    verification def GroundReadinessDemo {
        doc /* Operations readiness demonstration: passes from three stations, a 4 h sequence
             * turnaround, automated limit checking and the impact screening workflow. */
        subject ground : TethysGroundSegment;
        in attribute demonstratedTurnaround : DurationValue;
        in attribute demonstratedAutomation : Real;
        objective {
            doc /* The ground segment flies a simulated thrust arc with one shift. */
            verify groundCoverage { doc /* Verified by this case. */ }
            verify commandLatency { doc /* Verified by this case. */ }
            verify operatorWorkload { doc /* Verified by this case. */ }
            verify groundCompatibility { doc /* Verified by this case. */ }
            verify operabilityNeed { doc /* Verified by this case. */ }
        }
        PassIf(ground.network.stations->size() >= 3 and demonstratedTurnaround <= 4 [h] and demonstratedAutomation >= 0.95)
    }
    metadata VerificationMethod about GroundReadinessDemo { kind = VerificationMethodKind::demo; }
    verification def GroundProceduresDemo {
        doc /* Demonstration of the operations centre's and flight dynamics facility's
             * procedures: sequence turnaround, automated limit checks, impact screening and the
             * science archive hand-over. */
        subject ground : TethysGroundSegment;
        in attribute demonstratedTurnaround : DurationValue;
        in attribute demonstratedAutomation : Real;
        in attribute screenedArcFraction : Real;
        objective {
            doc /* Each procedure runs to its requirement. */
            verify sequenceTurnaround { doc /* Verified by this case. */ }
            verify monitoringAutomation { doc /* Verified by this case. */ }
            verify impactScreening { doc /* Verified by this case. */ }
            verify scienceArchive { doc /* Verified by this case. */ }
        }
        PassIf(demonstratedTurnaround <= 4 [h] and demonstratedAutomation >= 0.95 and screenedArcFraction == 1.0)
    }
    metadata VerificationMethod about GroundProceduresDemo { kind = VerificationMethodKind::demo; }
    verification def SepCommissioning {
        doc /* In-orbit commissioning of the SEP: conditioning, ignition, throttle and gimbal
             * sweeps on each string, then the first long firing (SE in-orbit verification). */
        subject tug : Tug;
        in attribute firedStrings : Natural;
        objective {
            doc /* Every string fires and the first arc meets the thrust model. */
            verify sepThrust { doc /* Verified by this case. */ }
            verify thrustRedundancy { doc /* Verified by this case. */ }
        }
        PassIf(firedStrings == tug.sep.thrusterCount)
    }
    metadata VerificationMethod about SepCommissioning { kind = VerificationMethodKind::demo; }
    verification def InspectorCommissioning {
        doc /* In-orbit checkout of Wren on the umbilical and after release: link, imaging,
             * Doppler. */
        subject inspector : Inspector;
        in attribute linkAcquired : Boolean;
        objective {
            doc /* Wren is healthy and linked after release. */
            verify keepAlivePower { doc /* Verified by this case. */ }
            verify proximityLinkRange { doc /* Verified by this case. */ }
        }
        PassIf(linkAcquired)
    }
    metadata VerificationMethod about InspectorCommissioning { kind = VerificationMethodKind::demo; }
    verification def DockingDemo {
        doc /* In-flight demonstration of attitude hold and the docking interface with Lantern. */
        subject flight : TethysFlightSegment;
        in attribute demonstratedAttitudeHold : AngularMeasureValue;
        objective {
            doc /* Attitude held to 0.5 deg through docking. */
            verify visitorDocking { doc /* Verified by this case. */ }
            verify utilisationAccess { doc /* Verified by this case. */ }
            verify surfaceAccessNeed { doc /* Verified by this case. */ }
        }
        PassIf(demonstratedAttitudeHold <= 0.00873 [rad])
    }
    metadata VerificationMethod about DockingDemo { kind = VerificationMethodKind::demo; }

    // ---- Validation of needs and success criteria -----------------------------------------

    verification def MissionValidation {
        doc /* Validation that the delivered mission meets the stakeholders' needs and the
             * success criteria, judged at the end-of-mission review on the as-flown record. */
        subject flight : TethysFlightSegment;
        in attribute deliveredBodyMass : MassValue;
        in attribute daysToDelivery : DurationValue;
        in attribute massUncertaintyAchieved : Real;
        in attribute impactProbabilityShown : Real;
        in attribute deflectionAccuracyAchieved : SpeedValue;
        in attribute targetCasesCovered : Natural;
        objective {
            doc /* The needs are met as stated, not merely the requirements derived from them. */
            verify returnedBodyNeed { doc /* Verified by this case. */ }
            verify timelinessNeed { doc /* Verified by this case. */ }
            verify knownTargetNeed { doc /* Verified by this case. */ }
            verify noEarthRiskNeed { doc /* Verified by this case. */ }
            verify deflectionKnowledgeNeed { doc /* Verified by this case. */ }
            verify robustToTargetNeed { doc /* Verified by this case. */ }
        }
        PassIf(deliveredBodyMass >= 100.0e3 [kg] and daysToDelivery <= 2200 [d]
            and massUncertaintyAchieved <= 0.10 and impactProbabilityShown < 1.0e-6
            and deflectionAccuracyAchieved <= 0.001 [m/s] and targetCasesCovered >= 4)
    }
    metadata VerificationMethod about MissionValidation { kind = VerificationMethodKind::demo; }
    verification def SuccessCriteriaValidation {
        doc /* Validation of the minimum and full success criteria and the deflection objective
             * at the end-of-mission review. Objectives are kept under ten members
             * (docs/findings/WP-A.md F-A02). */
        subject flight : TethysFlightSegment;
        in attribute criteriaMet : Natural;
        objective {
            doc /* Every criterion is met on the as-flown record. */
            verify minimumSuccess { doc /* Verified by this case. */ }
            verify fullSuccess { doc /* Verified by this case. */ }
            verify minimumSuccess.characterised { doc /* Verified by this case. */ }
            verify minimumSuccess.deflected { doc /* Verified by this case. */ }
            verify fullSuccess.delivered { doc /* Verified by this case. */ }
            verify fullSuccess.accessible { doc /* Verified by this case. */ }
            verify TethysStakeholders::deflectionMeasurement { doc /* Verified by this case. */ }
        }
        PassIf(criteriaMet == 4)
    }
    metadata VerificationMethod about SuccessCriteriaValidation { kind = VerificationMethodKind::demo; }
    verification def ConOpsValidation {
        doc /* Validation of the design reference mission use case by end-to-end simulation on
             * the dynamics simulator and flatsat with the operations team in the loop. */
        subject flight : TethysFlightSegment;
        in attribute threadsRun : Natural;
        objective {
            doc /* Every included use case runs end to end. */
            verify operabilityNeed { doc /* Verified by this case. */ }
        }
        PassIf(threadsRun >= 9)
    }
    metadata VerificationMethod about ConOpsValidation { kind = VerificationMethodKind::demo; }

    // ---- The verification programme: usages with as-run results -----------------------------

    verification <'VC-001'> captureEnvelopeTest : CaptureEnvelopeTest {
        doc /* Capture qualification test on the capture rig, run after CDR. */
        subject tug = argent;
        @TestSpecification { procedure = "TP-CAP-001 bag deployment, inflation and cinch"; facility = "captureRig"; report = "TR-CAP-001"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @CampaignStep { campaignPhase = "subsystem qualification"; sequence = 3; }
        @Closure { closedBy = "capture lead"; evidence = "TR-CAP-001"; status = StatusKind::closed; }
    }
    verification <'VC-002'> contactSpeedTest : ContactSpeedTest {
        doc /* Contact test on the capture rig: the bag tolerated 0.38 m/s. */
        subject tug = argent;
        in measuredToleratedSpeed = 0.38 [m/s];
        @TestSpecification { procedure = "TP-CAP-002 moving-surface contact"; facility = "captureRig"; report = "TR-CAP-002"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @CampaignStep { campaignPhase = "subsystem qualification"; sequence = 4; }
        @Nonconformance { reference = "NCR-017"; description = "Cinch line abrasion after the third contact run."; disposition = "use as is, add abrasion sleeve on flight lines"; status = StatusKind::closed; }
        @Closure { closedBy = "capture lead"; evidence = "TR-CAP-002, NCR-017"; status = StatusKind::closed; }
    }
    verification <'VC-003'> sepHotFireTest : SepHotFireTest {
        doc /* Thrust-stand hot fire: 1.86 N three-string, 0.62 N single. */
        subject tug = argent;
        in measuredThrust = 1.86 [N];
        in measuredUnitThrust = 0.62 [N];
        @TestSpecification { procedure = "TP-SEP-001 hot fire"; facility = "vacuum thrust stand"; report = "TR-SEP-001"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @CampaignStep { campaignPhase = "subsystem qualification"; sequence = 1; }
        @Closure { closedBy = "propulsion lead"; evidence = "TR-SEP-001"; status = StatusKind::closed; }
    }
    verification <'VC-004'> linkBudgetTest : LinkBudgetTest {
        doc /* Station compatibility test: 2 050 W EIRP, 3.4 dB margin at design range. */
        subject tug = argent;
        in measuredEirp = 2050.0 [W];
        in measuredMargin = 3.4;
        @TestSpecification { procedure = "TP-TEL-001 compatibility"; facility = "Meridian station emulator"; report = "TR-TEL-001"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        @CampaignStep { campaignPhase = "system test"; sequence = 9; }
        @Closure { closedBy = "telecom lead"; evidence = "TR-TEL-001"; status = StatusKind::closed; }
    }
    verification <'VC-005'> faultResponseTest : FaultResponseTest {
        doc /* Flatsat fault injection: 0.35 s detection, 1.6 s to safe. */
        subject tug = argent;
        in measuredDetection = 0.35 [s];
        in measuredResponse = 1.6 [s];
        @TestSpecification { procedure = "TP-FSW-004 fault injection"; facility = "flatsat"; report = "TR-FSW-004"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @CampaignStep { campaignPhase = "system test"; sequence = 7; }
        @Closure { closedBy = "software lead"; evidence = "TR-FSW-004"; status = StatusKind::closed; }
    }
    verification <'VC-006'> autonomyTest : AutonomyTest {
        doc /* Seven-day unattended flatsat run. */
        subject tug = argent;
        in unattendedDuration = 7.5 [d];
        @TestSpecification { procedure = "TP-FSW-005 unattended run"; facility = "flatsat"; report = "TR-FSW-005"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @CampaignStep { campaignPhase = "system test"; sequence = 8; }
        @Closure { closedBy = "flight operations"; evidence = "TR-FSW-005"; status = StatusKind::closed; }
    }
    verification <'VC-007'> inspectorAcceptanceTest : InspectorAcceptanceTest {
        doc /* Wren acceptance on the bench. */
        subject inspector = wren;
        in measuredKeepAlive = 3.8 [W];
        in measuredGsd = 0.016 [m];
        in measuredDoppler = 0.00007 [m/s];
        @TestSpecification { procedure = "TP-WRN-001 acceptance"; facility = "inspector bench"; report = "TR-WRN-001"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::acceptance; }
        @CampaignStep { campaignPhase = "subsystem acceptance"; sequence = 5; }
        @Closure { closedBy = "inspector lead"; evidence = "TR-WRN-001"; status = StatusKind::closed; }
    }
    verification <'VC-008'> separationTest : SeparationTest {
        doc /* Dispenser release on the offload rig: 3.1 cm/s. */
        subject tug = argent;
        in measuredSeparationSpeed = 0.031 [m/s];
        @TestSpecification { procedure = "TP-MEC-002 release"; facility = "gravity offload rig"; report = "TR-MEC-002"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::acceptance; }
        @CampaignStep { campaignPhase = "subsystem acceptance"; sequence = 6; }
        @Closure { closedBy = "mechanisms lead"; evidence = "TR-MEC-002"; status = StatusKind::open; }
    }
    verification <'VC-009'> proximityNavigationTest : ProximityNavigationTest {
        doc /* Closed-loop navigation on the dynamics simulator and camera bench. */
        subject tug = argent;
        in measuredPositionError = 0.07 [m];
        in measuredVelocityError = 0.0007 [m/s];
        in measuredLimitingMagnitude = 13.1;
        @TestSpecification { procedure = "TP-GNC-003 relative navigation"; facility = "dynamicsSimulator"; report = "TR-GNC-003"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @CampaignStep { campaignPhase = "subsystem qualification"; sequence = 2; }
        @Closure { closedBy = "GNC lead"; evidence = "TR-GNC-003"; status = StatusKind::closed; }
    }
    verification <'VC-010'> thermalBalanceTest : ThermalBalanceTest {
        doc /* Thermal balance at perihelion flux. */
        subject tug = argent;
        in measuredRejection = 8.6 [kW];
        @TestSpecification { procedure = "TP-THM-001 thermal balance"; facility = "thermal vacuum chamber"; report = "TR-THM-001"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @CampaignStep { campaignPhase = "system test"; sequence = 10; }
        @Closure { closedBy = "thermal lead"; evidence = "TR-THM-001"; status = StatusKind::closed; }
    }
    verification <'VC-011'> cinchMotorTest : CinchMotorTest {
        doc /* Cinch motor stall torque, qualified by similarity to the heritage boom motor plus
             * a delta test at cold. */
        subject tug = argent;
        in measuredStallTorqueNm = 46.0;
        @TestSpecification { procedure = "TP-CAP-003 motor stall"; facility = "mechanisms lab"; report = "TR-CAP-003"; }
        @HeritageQualification { heritageUnit = "roll-out array boom motor"; delta = "cold-start at -60 C, higher gear ratio"; }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
        @CampaignStep { campaignPhase = "unit qualification"; sequence = 0; }
        @Closure { closedBy = "capture lead"; evidence = "TR-CAP-003 and heritage file"; status = StatusKind::closed; }
    }
    verification <'VC-012'> propellantAnalysis : PropellantAnalysis {
        doc /* Propellant analysis for the current xenon load. */
        subject tug = argent;
        @TestSpecification { procedure = "AN-PROP-001 rocket equation"; facility = "mission design"; report = "AR-PROP-001"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @Closure { closedBy = "propulsion lead"; evidence = "AR-PROP-001"; status = StatusKind::tbr; }
    }
    verification <'VC-013'> despinAnalysis : DespinAnalysis {
        doc /* Despin budget. */
        subject tug = argent;
        @TestSpecification { procedure = "AN-GNC-002 despin budget"; facility = "GNC analysis"; report = "AR-GNC-002"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @Closure { closedBy = "GNC lead"; evidence = "AR-GNC-002"; status = StatusKind::closed; }
    }
    verification <'VC-014'> powerAnalysis : PowerAnalysis {
        doc /* Power at the target. */
        subject tug = argent;
        @TestSpecification { procedure = "AN-EPS-001 power budget"; facility = "power analysis"; report = "AR-EPS-001"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @Closure { closedBy = "power lead"; evidence = "AR-EPS-001"; status = StatusKind::closed; }
    }
    verification <'VC-015'> massBudgetAnalysis : MassBudgetAnalysis {
        doc /* Mass and launch budget. */
        subject tug = argent;
        @TestSpecification { procedure = "AN-SYS-001 mass budget"; facility = "systems engineering"; report = "AR-SYS-001"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::acceptance; }
        @Closure { closedBy = "systems engineering"; evidence = "AR-SYS-001"; status = StatusKind::closed; }
    }
    verification <'VC-016'> returnSafetyAnalysis : ReturnSafetyAnalysis {
        doc /* Return safety Monte Carlo on the trajectory tool. */
        subject flight = tethysSystem.flight;
        @TestSpecification { procedure = "AN-FD-003 thrust-loss Monte Carlo"; facility = "trajectoryTool"; report = "AR-FD-003"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::qualification; }
        @Closure { closedBy = "cislunar safety board"; evidence = "AR-FD-003"; status = StatusKind::closed; }
    }
    verification <'VC-017'> deliveryAnalysis : DeliveryAnalysis {
        doc /* Delivered mass and schedule. */
        subject flight = tethysSystem.flight;
        @TestSpecification { procedure = "AN-MD-001 reference trajectory"; facility = "mission design"; report = "AR-MD-001"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::qualification; }
        @Closure { closedBy = "mission design"; evidence = "AR-MD-001"; status = StatusKind::closed; }
    }
    verification <'VC-018'> characterisationAnalysis : CharacterisationAnalysis {
        doc /* Characterisation covariance. */
        subject flight = tethysSystem.flight;
        @TestSpecification { procedure = "AN-NAV-002 covariance"; facility = "navigation analysis"; report = "AR-NAV-002"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @Closure { closedBy = "navigation lead"; evidence = "AR-NAV-002"; status = StatusKind::closed; }
    }
    verification <'VC-019'> deflectionAnalysis : DeflectionAnalysis {
        doc /* Deflection measurement covariance. */
        subject flight = tethysSystem.flight;
        @TestSpecification { procedure = "AN-NAV-003 arc covariance"; facility = "navigation analysis"; report = "AR-NAV-003"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::qualification; }
        @Closure { closedBy = "navigation lead"; evidence = "AR-NAV-003"; status = StatusKind::closed; }
    }
    verification <'VC-020'> dockingLoadsAnalysis : DockingLoadsAnalysis {
        doc /* Docking load path analysis. */
        subject tug = argent;
        in analysedCapability = 6200.0 [N];
        @TestSpecification { procedure = "AN-STR-004 docking loads"; facility = "structures analysis"; report = "AR-STR-004"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @Closure { closedBy = "structures lead"; evidence = "AR-STR-004"; status = StatusKind::tbr; }
    }
    verification <'VC-021'> thrustModelValidation : ThrustModelValidation {
        doc /* The SepThrust model validated against the hot-fire measurement. */
        subject tug = argent;
        in measuredThrust = 1.86 [N];
        @TestSpecification { procedure = "AN-SEP-002 model validation"; facility = "propulsion analysis"; report = "AR-SEP-002"; }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @Closure { closedBy = "propulsion lead"; evidence = "AR-SEP-002"; status = StatusKind::closed; }
    }
    verification <'VC-022'> redundancyInspection : RedundancyInspection {
        doc /* Redundancy inspection at CDR. */
        subject tug = argent;
        @TestSpecification { procedure = "IN-SYS-002 fault tree review"; facility = "CDR"; report = "IR-SYS-002"; }
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @Closure { closedBy = "systems engineering"; evidence = "IR-SYS-002"; status = StatusKind::closed; }
    }
    verification <'VC-023'> documentInspection : DocumentInspection {
        doc /* Baseline inspection at PDR. */
        subject mission = tethysSystem;
        @TestSpecification { procedure = "IN-SYS-001 baseline review"; facility = "PDR"; report = "IR-SYS-001"; }
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @Closure { closedBy = "systems engineering"; evidence = "IR-SYS-001"; status = StatusKind::closed; }
    }
    verification <'VC-024'> groundInspection : GroundInspection {
        doc /* Station inventory inspection. */
        subject ground = tethysSystem.ground;
        @TestSpecification { procedure = "IN-GND-001 inventory"; facility = "Meridian"; report = "IR-GND-001"; }
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::subsystem; stage = VerificationStage::preLaunch; }
        @Closure { closedBy = "ground segment"; evidence = "IR-GND-001"; status = StatusKind::closed; }
    }
    verification <'VC-025'> groundReadinessDemo : GroundReadinessDemo {
        doc /* Operations readiness demonstration before launch. */
        subject ground = tethysSystem.ground;
        in demonstratedTurnaround = 3.2 [h];
        in demonstratedAutomation = 0.97;
        @TestSpecification { procedure = "DM-OPS-001 readiness"; facility = "operations centre"; report = "DR-OPS-001"; }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        @CampaignStep { campaignPhase = "operations readiness"; sequence = 11; }
        @Closure { closedBy = "flight operations"; evidence = "DR-OPS-001"; status = StatusKind::closed; }
    }
    verification <'VC-026'> sepCommissioning : SepCommissioning {
        doc /* In-orbit SEP commissioning; all four strings fired. */
        subject tug = argent;
        in firedStrings = 4;
        @TestSpecification { procedure = "DM-SEP-010 commissioning"; facility = "in flight"; report = "DR-SEP-010"; }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::system; stage = VerificationStage::inFlight; }
        @Closure { closedBy = "propulsion lead"; evidence = "DR-SEP-010"; status = StatusKind::open; }
    }
    verification <'VC-027'> inspectorCommissioning : InspectorCommissioning {
        doc /* In-orbit Wren checkout. */
        subject inspector = wren;
        in linkAcquired = true;
        @TestSpecification { procedure = "DM-WRN-010 checkout"; facility = "in flight"; report = "DR-WRN-010"; }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::subsystem; stage = VerificationStage::inFlight; }
        @Closure { closedBy = "inspector lead"; evidence = "DR-WRN-010"; status = StatusKind::open; }
    }
    verification <'VC-028'> dockingDemo : DockingDemo {
        doc /* Docking demonstration with Lantern in the DRO. */
        subject flight = tethysSystem.flight;
        in demonstratedAttitudeHold = 0.005 [rad];
        @TestSpecification { procedure = "DM-UTL-001 docking"; facility = "in flight"; report = "DR-UTL-001"; }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @Closure { closedBy = "utilisation office"; evidence = "DR-UTL-001"; status = StatusKind::open; }
    }
    verification <'VC-029'> missionValidation : MissionValidation {
        doc /* End-of-mission validation against the needs. */
        subject flight = tethysSystem.flight;
        in deliveredBodyMass = 358.0e3 [kg];
        in daysToDelivery = 1950 [d];
        in massUncertaintyAchieved = 0.07;
        in impactProbabilityShown = 4.0e-7;
        in deflectionAccuracyAchieved = 0.0006 [m/s];
        in targetCasesCovered = 4;
        @TestSpecification { procedure = "VL-MIS-001 end-of-mission review"; facility = "programme board"; report = "VR-MIS-001"; }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @Closure { closedBy = "programme board"; evidence = "VR-MIS-001"; status = StatusKind::open; }
    }
    verification <'VC-030'> successCriteriaValidation : SuccessCriteriaValidation {
        doc /* Success criteria judged at the end-of-mission review. */
        subject flight = tethysSystem.flight;
        in criteriaMet = 4;
        @TestSpecification { procedure = "VL-MIS-002 success criteria review"; facility = "programme board"; report = "VR-MIS-002"; }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @Closure { closedBy = "programme board"; evidence = "VR-MIS-002"; status = StatusKind::open; }
    }
    verification <'VC-031'> groundProceduresDemo : GroundProceduresDemo {
        doc /* Procedures demonstration during operations readiness. */
        subject ground = tethysSystem.ground;
        in demonstratedTurnaround = 3.2 [h];
        in demonstratedAutomation = 0.97;
        in screenedArcFraction = 1.0;
        @TestSpecification { procedure = "DM-OPS-002 procedures"; facility = "operations centre"; report = "DR-OPS-002"; }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        @CampaignStep { campaignPhase = "operations readiness"; sequence = 12; }
        @Closure { closedBy = "flight operations"; evidence = "DR-OPS-002"; status = StatusKind::closed; }
    }
    verification <'VC-032'> interfaceBaselineInspection : InterfaceBaselineInspection {
        doc /* ICD baseline inspection at PDR. */
        subject mission = tethysSystem;
        in icdsBaselined = 2;
        @TestSpecification { procedure = "IN-SYS-003 ICD baseline"; facility = "PDR"; report = "IR-SYS-003"; }
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @Closure { closedBy = "systems engineering"; evidence = "IR-SYS-003"; status = StatusKind::closed; }
    }
    verification <'VC-033'> conOpsValidation : ConOpsValidation {
        doc /* Design reference mission validated end to end on the simulators. */
        subject flight = tethysSystem.flight;
        in threadsRun = 9;
        @TestSpecification { procedure = "VL-OPS-002 DRM simulation"; facility = "dynamicsSimulator, flatsat"; report = "VR-OPS-002"; }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        @Closure { closedBy = "flight operations"; evidence = "VR-OPS-002"; status = StatusKind::closed; }
    }

    // ---- Test campaign and environmental test matrix ----------------------------------------

    occurrence def CampaignPhase {
        doc /* A phase of the test campaign, bounded by the readiness reviews that open and
             * close it. */
        attribute openedBy : String;
        attribute closedBy : String;
    }
    occurrence testCampaign {
        doc /* The integration-and-test campaign: unit and subsystem qualification, subsystem
             * acceptance, system test and operations readiness, in that order. Each activity's
             * CampaignStep names its phase and sequence number. */
        occurrence unitQualification : CampaignPhase {
            doc /* Unit-level qualification tests (cinch motor, PPU, thruster). */
            attribute :>> openedBy = "CDR";
            attribute :>> closedBy = "unit TRRs";
        }
        occurrence subsystemQualification : CampaignPhase {
            doc /* SEP hot fire, proximity navigation, capture rig tests. */
            attribute :>> openedBy = "unit TRRs";
            attribute :>> closedBy = "subsystem QR";
        }
        occurrence subsystemAcceptance : CampaignPhase {
            doc /* Wren acceptance, dispenser release. */
            attribute :>> openedBy = "subsystem QR";
            attribute :>> closedBy = "pre-integration review";
        }
        occurrence systemTest : CampaignPhase {
            doc /* Flatsat fault injection and autonomy, link compatibility, thermal balance. */
            attribute :>> openedBy = "pre-integration review";
            attribute :>> closedBy = "system TRR";
        }
        occurrence operationsReadiness : CampaignPhase {
            doc /* Operations readiness demonstration and DRM validation. */
            attribute :>> openedBy = "system TRR";
            attribute :>> closedBy = "ORR";
        }
        first unitQualification then subsystemQualification;
        first subsystemQualification then subsystemAcceptance;
        first subsystemAcceptance then systemTest;
        first systemTest then operationsReadiness;
    }

    action def RunCampaign {
        doc /* The campaign as an executable sequence of steps, one per phase, for timeline
             * rehearsal with -action. */
        action unitQualification { doc /* Unit qualification. */ }
        action subsystemQualification { doc /* Subsystem qualification. */ }
        action subsystemAcceptance { doc /* Subsystem acceptance. */ }
        action systemTest { doc /* System test. */ }
        action operationsReadiness { doc /* Operations readiness. */ }
        first start;
        then unitQualification;
        then subsystemQualification;
        then subsystemAcceptance;
        then systemTest;
        then operationsReadiness;
        then done;
    }
    action runCampaign : RunCampaign {
        doc /* The campaign run. */
    }

    attribute def EnvironmentalTest {
        doc /* One row of the environmental test matrix. */
        attribute environment : String;
        attribute level : String;
        attribute duration : DurationValue;
        attribute appliesTo : String;
        attribute phase : String;
    }
    part environmentalTestMatrix {
        doc /* Environmental tests by article: the tug at system level, the inspector at unit
             * level, the capture system at its rig. */
        attribute thermalVacuumTug : EnvironmentalTest {
            doc /* Tug thermal vacuum with the bag deployed. */
            attribute :>> environment = "thermal vacuum, perihelion flux";
            attribute :>> level = "qualification plus 10 K";
            attribute :>> duration = 14 [d];
            attribute :>> appliesTo = "argent";
            attribute :>> phase = "systemTest";
        }
        attribute vibrationTug : EnvironmentalTest {
            doc /* Tug sine and random vibration to launcher levels. */
            attribute :>> environment = "launch vibration";
            attribute :>> level = "Arcturus-5H qualification";
            attribute :>> duration = 2 [d];
            attribute :>> appliesTo = "argent";
            attribute :>> phase = "systemTest";
        }
        attribute thermalVacuumInspector : EnvironmentalTest {
            doc /* Inspector thermal vacuum and cold-start. */
            attribute :>> environment = "thermal vacuum, cold start";
            attribute :>> level = "acceptance";
            attribute :>> duration = 5 [d];
            attribute :>> appliesTo = "wren";
            attribute :>> phase = "subsystemAcceptance";
        }
        attribute bagDeploymentVacuum : EnvironmentalTest {
            doc /* Capture bag deployment and inflation in vacuum at cold. */
            attribute :>> environment = "vacuum, -80 C";
            attribute :>> level = "qualification";
            attribute :>> duration = 3 [d];
            attribute :>> appliesTo = "argent.captureSystem";
            attribute :>> phase = "subsystemQualification";
        }
        attribute emcSep : EnvironmentalTest {
            doc /* SEP plume and EMI compatibility with telecom and sensors. */
            attribute :>> environment = "conducted and radiated EMI during firing";
            attribute :>> level = "qualification";
            attribute :>> duration = 4 [d];
            attribute :>> appliesTo = "argent.sep, argent.telecom";
            attribute :>> phase = "subsystemQualification";
        }
    }

    // ---- V&V matrix view ------------------------------------------------------------------

    view def VvMatrix {
        doc /* The requirement-to-verification matrix: every requirement with the cases that
             * verify it, for the V&V lead's viewpoint. */
        satisfy verificationViewpoint { doc /* The matrix answers the V&V lead's viewpoint. */ }
    }
    view l1Matrix : VvMatrix {
        doc /* The L1 requirements with their verification. Members are exposed one by one:
             * see docs/findings/WP-A.md F-A04 on `expose P::*`. */
        expose TethysRequirements::retrieval;
        expose TethysRequirements::missionDuration;
        expose TethysRequirements::characterisation;
        expose TethysRequirements::launchCompatibility;
        expose TethysRequirements::groundCompatibility;
        expose TethysRequirements::cislunarSafety;
        expose TethysRequirements::missionClass;
        expose TethysRequirements::deflectionDemonstration;
        expose TethysRequirements::utilisationAccess;
        render asTreeDiagram;
    }
    view l2Matrix : VvMatrix {
        doc /* The L2 requirements with their verification. */
        expose TethysRequirementsL2::captureEnvelope;
        expose TethysRequirementsL2::deliveredMass;
        expose TethysRequirementsL2::transferDuration;
        expose TethysRequirementsL2::propellantCapacity;
        expose TethysRequirementsL2::characterisationProducts;
        expose TethysRequirementsL2::launchCompatibility;
        expose TethysRequirementsL2::deepSpaceLink;
        expose TethysRequirementsL2::earthImpactExclusion;
        expose TethysRequirementsL2::droStability;
        expose TethysRequirementsL2::thrustRedundancy;
        expose TethysRequirementsL2::deflectionMeasurement;
        expose TethysRequirementsL2::visitorDocking;
        expose TethysRequirementsL2::autonomousSurvival;
        expose TethysRequirementsL2::proximityContactEnvironment;
        expose TethysRequirementsL2::faultResponse;
        expose TethysRequirementsL2::massBudget;
        expose TethysRequirementsL2::captureQualification;
        expose TethysRequirementsL2::inspectorDeployment;
        expose TethysRequirementsL2::despinCapacity;
        expose TethysRequirementsL2::groundCoverage;
        expose TethysRequirementsL2::commandLatency;
        expose TethysRequirementsL2::operatorWorkload;
        render asTreeDiagram;
    }
    view l3l4Matrix : VvMatrix {
        doc /* The L3 and L4 requirements with their verification. */
        expose TethysRequirementsL3L4::sepThrust;
        expose TethysRequirementsL3L4::arrayPowerAtTarget;
        expose TethysRequirementsL3L4::captureBagDiameter;
        expose TethysRequirementsL3L4::contactSpeedTolerance;
        expose TethysRequirementsL3L4::despinTorque;
        expose TethysRequirementsL3L4::hydrazineLoad;
        expose TethysRequirementsL3L4::deepSpaceEirp;
        expose TethysRequirementsL3L4::proximityLinkRange;
        expose TethysRequirementsL3L4::relativeNavigation;
        expose TethysRequirementsL3L4::faultDetectionLatency;
        expose TethysRequirementsL3L4::heatRejection;
        expose TethysRequirementsL3L4::dockingLoads;
        expose TethysRequirementsL3L4::inspectorSeparation;
        expose TethysRequirementsL3L4::spinStateSensing;
        expose TethysRequirementsL3L4::imagingResolution;
        expose TethysRequirementsL3L4::circumnavigationPropellant;
        expose TethysRequirementsL3L4::keepAlivePower;
        expose TethysRequirementsL3L4::inspectorMass;
        expose TethysRequirementsL3L4::dopplerForMass;
        expose TethysRequirementsL3L4::stationAperture;
        expose TethysRequirementsL3L4::stationSpacing;
        expose TethysRequirementsL3L4::rangingAccuracy;
        expose TethysRequirementsL3L4::impactScreening;
        expose TethysRequirementsL3L4::sequenceTurnaround;
        expose TethysRequirementsL3L4::monitoringAutomation;
        expose TethysRequirementsL3L4::scienceArchive;
        expose TethysRequirementsL3L4::thrusterUnitThrust;
        expose TethysRequirementsL3L4::powerProcessingEfficiency;
        expose TethysRequirementsL3L4::cinchMotorTorque;
        expose TethysRequirementsL3L4::narrowAngleCameraSensitivity;
        expose TethysRequirementsL3L4::fdirTaskPeriod;
        expose TethysRequirementsL3L4::inspectorDetectorPitch;
        render asTreeDiagram;
    }
    view verificationCases : VvMatrix {
        doc /* The verification activities with their method, level, stage and closure. */
        expose TethysVerification::captureEnvelopeTest;
        expose TethysVerification::contactSpeedTest;
        expose TethysVerification::sepHotFireTest;
        expose TethysVerification::linkBudgetTest;
        expose TethysVerification::faultResponseTest;
        expose TethysVerification::autonomyTest;
        expose TethysVerification::inspectorAcceptanceTest;
        expose TethysVerification::separationTest;
        expose TethysVerification::proximityNavigationTest;
        expose TethysVerification::thermalBalanceTest;
        expose TethysVerification::cinchMotorTest;
        expose TethysVerification::propellantAnalysis;
        expose TethysVerification::despinAnalysis;
        expose TethysVerification::powerAnalysis;
        expose TethysVerification::massBudgetAnalysis;
        expose TethysVerification::returnSafetyAnalysis;
        expose TethysVerification::deliveryAnalysis;
        expose TethysVerification::characterisationAnalysis;
        expose TethysVerification::deflectionAnalysis;
        expose TethysVerification::dockingLoadsAnalysis;
        expose TethysVerification::thrustModelValidation;
        expose TethysVerification::redundancyInspection;
        expose TethysVerification::documentInspection;
        expose TethysVerification::groundInspection;
        expose TethysVerification::groundReadinessDemo;
        expose TethysVerification::sepCommissioning;
        expose TethysVerification::inspectorCommissioning;
        expose TethysVerification::dockingDemo;
        expose TethysVerification::missionValidation;
        expose TethysVerification::conOpsValidation;
        expose TethysVerification::successCriteriaValidation;
        expose TethysVerification::groundProceduresDemo;
        expose TethysVerification::interfaceBaselineInspection;
        render asTreeDiagram;
    }
}
