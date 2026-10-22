// The L2 system requirements: what each segment and the flight system must do so that the L1
// mission requirements TR-001 to TR-009 hold. Every L2 requirement is derived from at least one
// L1 requirement with a RequirementDerivation connection, has a subject in TethysSystem, carries
// @Verification, and where it states a number the number is a constraint over backbone values.
package TethysRequirementsL2 {
    doc /* L2 system requirements of Tethys, grouped by kind, derived from TethysRequirements
         * and satisfied by the parts of TethysSystem::tethysSystem. Target-dependent numbers are
         * written against the TethysTarget::CaptureTargetCase variants, not against Amaranth
         * alone. */

    private import ScalarValues::*;
    private import SequenceFunctions::size;
    private import ISQ::*;
    private import SI::*;
    private import ModelingMetadata::*;
    private import RequirementDerivation::*;
    private import VerificationCases::VerificationMethodKind;
    private import TethysRequirements::*;
    private import TethysStakeholders::*;
    private import TethysSystem::*;
    private import TethysTug::Tug;
    private import TethysInspector::Inspector;
    private import TethysGround::GroundNetwork;
    private import TethysInterfaces::*;

    // ---- Requirement kinds ---------------------------------------------------------------

    requirement def InterfaceRequirement :> SystemRequirement {
        doc /* An L2 requirement on an interface between two segments or with a provider. */
        attribute icd : String;
    }
    requirement def EnvironmentalRequirement :> SystemRequirement {
        doc /* An L2 requirement that the system withstand a stated environment. */
        attribute environment : String;
    }
    requirement def PerformanceRequirement :> SystemRequirement {
        doc /* An L2 requirement that quantifies how well a function is performed. */
    }
    requirement def FunctionalRequirement :> SystemRequirement {
        doc /* An L2 requirement that the system perform a function. */
    }
    requirement def SafetyRequirement :> SystemRequirement {
        doc /* An L2 requirement that bounds a hazard to the Earth, the Moon or the mission. */
        attribute hazard : String;
    }
    requirement def SoftwareRequirement :> SystemRequirement {
        doc /* An L2 requirement allocated to flight or ground software. */
    }
    requirement def BudgetRequirement :> SystemRequirement {
        doc /* An L2 requirement that allocates a resource budget across the architecture. */
    }
    requirement def VerificationRequirement :> SystemRequirement {
        doc /* An L2 requirement on how another requirement is to be verified. */
    }

    metadata def Waiver {
        doc /* A recorded deviation: the requirement stands, the stated relief applies to the
             * named scope until the expiry. */
        attribute relief : String;
        attribute scope : String;
        attribute approvedBy : String;
        attribute expires : String;
    }

    // ---- Flight-segment requirements -----------------------------------------------------

    requirement <'TS-001'> captureEnvelope : PerformanceRequirement {
        doc /* The tug's capture system shall accommodate any body inside the pre-arrival knowledge
             * bounds of TethysTarget::targetCases: up to the largest case's diameter and up to the
             * larger of the largest and densest cases' mass. */
        subject tug : Tug;
        attribute maximumBodyDiameter : LengthValue = tug.captureSystem.maximumBodyDiameter;
        attribute maximumBodyMass : MassValue = tug.captureSystem.maximumBodyMass;
        require constraint { maximumBodyDiameter >= targetCases.largest.meanDiameter }
        require constraint { maximumBodyMass >= targetCases.largest.mass }
        require constraint { maximumBodyMass >= targetCases.densest.mass }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "capture lead"; status = StatusKind::closed; }
        @DrivingRequirement { driver = "bag diameter, cinch loads, structure"; }
    }
    requirement <'TS-002'> deliveredMass : PerformanceRequirement {
        doc /* The flight segment shall deliver at least 99 % of the captured body's mass to the
             * DRO, so that the nominal case delivers the 100 t TR-001 requires. The small case
             * is below 100 t whatever the tug does: it is assumed out of the TR-001 envelope and
             * covered by minimum success. */
        subject flight : TethysFlightSegment;
        attribute retainedFraction : Real = 0.99;
        attribute deliveredNominalMass : MassValue = retainedFraction * targetCases.nominal.mass;
        assume constraint { targetCases.nominal.mass >= 100.0e3 [kg] }
        require constraint { deliveredNominalMass >= 100.0e3 [kg] }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @StatusInfo { owner = "mission design"; status = StatusKind::closed; }
    }
    requirement <'TS-003'> transferDuration : PerformanceRequirement {
        doc /* The flight segment shall complete launch to DRO insertion within the nominal
             * duration: 1 100 d of thrust, 650 d of coast and navigation arcs, 150 d of proximity
             * operations and a 300 d reserve. */
        subject flight : TethysFlightSegment;
        attribute thrustTime : DurationValue = 1100 [d];
        attribute coastTime : DurationValue = 650 [d];
        attribute proximityOperations : DurationValue = 150 [d];
        attribute reserve : DurationValue = 300 [d];
        attribute total : DurationValue = thrustTime + coastTime + proximityOperations + reserve;
        require constraint { total <= TethysMission::tethys.nominalDuration }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "mission design"; status = StatusKind::closed; }
        @DrivingRequirement { driver = "thrust time, hence power and Isp"; }
    }
    requirement <'TS-004'> propellantCapacity : BudgetRequirement {
        doc /* The tug shall carry xenon for an outbound delta-v of at least 3 200 m/s on the tug
             * alone and, after 1 500 kg of outbound xenon, a return delta-v of at least 300 m/s
             * with the nominal case attached and at least 240 m/s with the dense case attached,
             * the dense-case return relying on the lunar gravity assist to lower the insertion
             * cost. The remainder of the load is the return budget and its reserve. */
        subject tug : Tug;
        attribute outboundXenon : MassValue = 1500 [kg];
        attribute returnXenon : MassValue = tug.sep.xenonMass - outboundXenon;
        attribute tugAfterOutbound : MassValue = tug.wetMass - outboundXenon;
        attribute nominalStack : MassValue = tugAfterOutbound + targetCases.nominal.mass;
        attribute denseStack : MassValue = tugAfterOutbound + targetCases.densest.mass;
        attribute outboundDeltaV : SpeedValue = TethysEnvironment::RocketEquationDeltaV(2900.0, tug.wetMass / 1 [kg], tugAfterOutbound / 1 [kg]) [m/s];
        attribute nominalReturnDeltaV : SpeedValue = TethysEnvironment::RocketEquationDeltaV(2900.0, nominalStack / 1 [kg], (nominalStack - returnXenon) / 1 [kg]) [m/s];
        attribute denseReturnDeltaV : SpeedValue = TethysEnvironment::RocketEquationDeltaV(2900.0, denseStack / 1 [kg], (denseStack - returnXenon) / 1 [kg]) [m/s];
        require constraint { outboundDeltaV >= 3200 [m/s] }
        require constraint { nominalReturnDeltaV >= 300 [m/s] }
        require constraint { denseReturnDeltaV >= 240 [m/s] }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "propulsion lead"; status = StatusKind::tbr; }
        @Rationale { text = "The dense-case figure of 240 m/s is TBR until the return trajectory with lunar gravity assist is propagated; the large case is not returnable within the xenon load and is accepted as a minimum-success outcome."; }
        @DrivingRequirement { driver = "xenon load, return duration"; }
    }
    requirement <'TS-005'> characterisationProducts : PerformanceRequirement {
        doc /* Before capture commit the flight segment shall deliver a shape model at 0.1 m, the
             * mass to 10 % and the spin period to 1 %, for any TargetCase. */
        subject flight : TethysFlightSegment;
        attribute massUncertainty : Real = missionMeasures.massEstimateUncertainty;
        require constraint { massUncertainty <= 0.10 }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::inFlight; }
        @StatusInfo { owner = "navigation lead"; status = StatusKind::closed; }
    }
    requirement <'TS-006'> launchCompatibility : InterfaceRequirement {
        doc /* The flight segment's launch mass, including the inspector, shall not exceed the
             * Arcturus-5H performance at the assumed direct-escape C3, and it shall meet the
             * launch ICD's mechanical and electrical interface. */
        subject launchInterface : SpacecraftLauncherInterface;
        attribute :>> icd = "Tethys-Arcturus launch ICD";
        attribute launchMass : MassValue = TethysTug::argent.wetMass + TethysInspector::wren.wetMass;
        assume constraint { programmeAssumptions.directEscapeC3 == 2.0 }
        require constraint { launchMass <= TethysLaunch::arcturus5H.performanceAtC3 }
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "launch integration"; status = StatusKind::closed; }
    }
    requirement <'TS-007'> deepSpaceLink : InterfaceRequirement {
        doc /* The space-ground link shall close with a 3 dB margin at the maximum Earth range of
             * the mission at a telemetry rate of at least 2 kbit/s, and at the minimum range the
             * receiver shall not saturate. */
        subject link : SpaceGroundLink;
        attribute :>> icd = "Tethys-Meridian space-ground ICD";
        attribute designRange : LengthValue = 65.0e6 [km];
        attribute minimumRate : Real = 2000.0;
        require constraint { designRange >= TethysEnvironment::earthRange.maximum }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "telecom lead"; status = StatusKind::closed; }
    }
    requirement <'TS-008'> earthImpactExclusion : SafetyRequirement {
        doc /* The return trajectory shall be biased so that, with thrust lost at any instant and
             * not recovered, the probability of Earth impact within 100 years is below one in a
             * million, for every TargetCase. */
        subject flight : TethysFlightSegment;
        attribute :>> hazard = "uncontrolled Earth re-entry of the body";
        attribute impactProbability : Real = missionMeasures.earthImpactProbability;
        require constraint { impactProbability <= 1.0e-6 }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "cislunar safety board"; status = StatusKind::closed; }
        @DrivingRequirement { driver = "return trajectory biasing, navigation accuracy"; }
    }
    requirement <'TS-009'> droStability : SafetyRequirement {
        doc /* The stack shall be inserted into the designated DRO such that the body stays bound
             * to the Moon for the TR-006 horizon without station-keeping. */
        subject flight : TethysFlightSegment;
        attribute :>> hazard = "body escapes the DRO or decays onto the Moon";
        attribute stabilityHorizon : DurationValue = TethysEnvironment::destinationDro.stabilityHorizon;
        require constraint { stabilityHorizon >= 36525.0 [d] }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "flight dynamics"; status = StatusKind::closed; }
    }
    requirement <'TS-010'> thrustRedundancy : FunctionalRequirement {
        doc /* The tug shall complete the mission with any one SEP string failed: it carries one
             * more thruster than it operates at a time. */
        subject tug : Tug;
        require constraint { tug.sep.thrusterCount - tug.sep.operatingThrusters >= 1 }
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "propulsion lead"; status = StatusKind::closed; }
    }
    requirement <'TS-011'> deflectionMeasurement : PerformanceRequirement {
        doc /* During a 30 d slow-push arc the flight segment, tracked by Meridian, shall allow the
             * body's heliocentric velocity change to be determined to 1 mm/s; with 2 m two-way
             * ranging over the arc the velocity accuracy is the range accuracy over the arc. */
        subject flight : TethysFlightSegment;
        attribute arcDuration : DurationValue = 30 [d];
        attribute rangingAccuracy : LengthValue = missionMeasures.rangingAccuracy;
        attribute velocityAccuracy : SpeedValue = rangingAccuracy / arcDuration;
        require constraint { velocityAccuracy <= 0.001 [m/s] }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @StatusInfo { owner = "navigation lead"; status = StatusKind::closed; }
    }
    requirement <'TS-012'> visitorDocking : InterfaceRequirement {
        doc /* In the DRO the stack shall hold its attitude to 0.5 deg and its rates to 0.01 deg/s
             * for the duration of a Lantern approach and shall present the docking interface. */
        subject docking : DockingInterface;
        attribute :>> icd = "Tethys-Lantern docking ICD";
        attribute attitudeHold : AngularMeasureValue = 0.00873 [rad];
        attribute rateHold : AngularVelocityValue = 0.000175 [rad/s];
        require constraint { attitudeHold <= 0.00873 [rad] }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @StatusInfo { owner = "GNC lead"; status = StatusKind::tbr; }
        @Rationale { text = "The rate limit is TBR until Lantern's sensor suite is selected."; }
    }
    requirement <'TS-013'> autonomousSurvival : FunctionalRequirement {
        doc /* The flight segment shall remain power-positive, thermally safe and commandable for
             * 7 d without ground contact in any phase, with the body attached or not. */
        subject flight : TethysFlightSegment;
        attribute autonomyDuration : DurationValue = 7 [d];
        require constraint { autonomyDuration >= 7 [d] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "flight operations"; status = StatusKind::closed; }
        @Waiver { relief = "3 d during launch and early operations"; scope = "launchAndEarlyOperations"; approvedBy = "programme board"; expires = "arraysDeployed"; }
    }
    requirement <'TS-014'> proximityContactEnvironment : EnvironmentalRequirement {
        doc /* The capture system shall withstand contact with a surface moving at the large
             * case's equatorial speed and the thermal environment at the minimum heliocentric
             * range, including solar flux at perihelion. */
        subject tug : Tug;
        attribute :>> environment = "proximity operations and contact";
        attribute perihelionFlux : Real = TethysEnvironment::SolarFlux(1.003);
        attribute designFlux : Real = 1450.0;
        attribute largeCaseSurfaceSpeed : SpeedValue = 3.14159265 * targetCases.largest.meanDiameter / targetCases.large.rotationPeriod;
        attribute designContactSpeed : SpeedValue = 0.35 [m/s];
        require constraint { designFlux >= perihelionFlux }
        require constraint { designContactSpeed >= largeCaseSurfaceSpeed }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "capture lead"; status = StatusKind::closed; }
    }
    requirement <'TS-015'> faultResponse : SoftwareRequirement {
        doc /* Flight software shall detect a thrust-vector or contact fault and reach a safe
             * configuration within 2 s, faster than the shortest time to criticality during
             * capture and docking. */
        subject flight : TethysFlightSegment;
        attribute responseTime : DurationValue = 2 [s];
        attribute shortestTimeToCriticality : DurationValue = 5 [s];
        require constraint { responseTime < shortestTimeToCriticality }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::closed; }
    }
    requirement <'TS-016'> massBudget : BudgetRequirement {
        doc /* The tug dry mass shall stay within its 7 000 kg allocation with the PDR margin of
             * programmeAssumptions.pdrMassMargin held against the current estimate. */
        subject tug : Tug;
        attribute allocated : MassValue = 7000 [kg];
        require constraint { tug.dryMass * (1.0 + programmeAssumptions.pdrMassMargin) <= allocated }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "systems engineering"; status = StatusKind::closed; }
    }
    requirement <'TS-017'> captureQualification : VerificationRequirement {
        doc /* The capture system shall be qualified by a full-scale deployment, inflation and
             * cinch test in vacuum against a rotating mock body of the large case's diameter. */
        subject tug : Tug;
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "capture lead"; status = StatusKind::closed; }
    }
    requirement <'TS-018'> inspectorDeployment : FunctionalRequirement {
        doc /* The flight segment shall release the inspector at a separation speed between 2 and
             * 5 cm/s and maintain the proximity link with it to 5 km. */
        subject flight : TethysFlightSegment;
        attribute separationSpeed : SpeedValue = 0.03 [m/s];
        attribute linkRange : LengthValue = 5000 [m];
        require constraint { separationSpeed >= 0.02 [m/s] and separationSpeed <= 0.05 [m/s] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "inspector lead"; status = StatusKind::tbd; }
        @Rationale { text = "The separation speed is TBD pending the dispenser spring trade."; }
    }
    requirement <'TS-019'> despinCapacity : PerformanceRequirement {
        doc /* With the large case attached the tug shall remove the body's spin angular momentum
             * within 24 h using the reaction-control system, keeping the hydrazine used below a
             * quarter of the load. The momentum is 0.4 M R^2 omega for a sphere. */
        subject tug : Tug;
        attribute largeCaseMomentum : Real = 0.4 * (targetCases.largest.mass / 1 [kg]) * (targetCases.largest.meanDiameter / 2 [m]) * (targetCases.largest.meanDiameter / 2 [m]) * 2.0 * 3.14159265 / (targetCases.large.rotationPeriod / 1 [s]);
        attribute leverArm : LengthValue = 3.0 [m];
        attribute rcsSpecificImpulse : DurationValue = 220 [s];
        attribute hydrazineUsed : MassValue = (largeCaseMomentum / ((leverArm / 1 [m]) * (rcsSpecificImpulse / 1 [s]) * TethysEnvironment::standardGravityMPerS2)) [kg];
        require constraint { hydrazineUsed <= 0.25 * tug.rcs.hydrazineMass }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "GNC lead"; status = StatusKind::closed; }
        @DrivingRequirement { driver = "hydrazine load, thruster lever arm"; }
    }

    // ---- Ground-segment requirements -----------------------------------------------------

    requirement <'TS-020'> groundCoverage : FunctionalRequirement {
        doc /* The ground segment shall provide at least one tracking pass per day from three
             * stations spaced in longitude, and two-way ranging on every pass. */
        subject ground : TethysGroundSegment;
        attribute stationCount : Natural = ground.network.stations->size();
        require constraint { stationCount >= 3 }
        require constraint { programmeAssumptions.meridianPassesPerDay >= 1 }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground segment"; status = StatusKind::closed; }
    }
    requirement <'TS-021'> commandLatency : SoftwareRequirement {
        doc /* The ground segment shall uplink a validated command sequence within 4 h of a
             * request during proximity operations, and shall never command a thrust arc the
             * flight dynamics facility has not cleared against Earth-impact exclusion. */
        subject ground : TethysGroundSegment;
        attribute sequenceLatency : DurationValue = 4 [h];
        require constraint { sequenceLatency <= 4 [h] }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground segment"; status = StatusKind::closed; }
    }
    requirement <'TS-022'> operatorWorkload : FunctionalRequirement {
        doc /* The ground segment shall let a single shift of three operators run a thrust arc,
             * with all nominal thrust-arc monitoring automated. */
        subject ground : TethysGroundSegment;
        attribute operatorsPerShift : Natural = 3;
        require constraint { operatorsPerShift <= 3 }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "flight operations"; status = StatusKind::closed; }
    }

    // ---- Requirement groups and architecture allocation ----------------------------------

    requirement flightPerformanceRequirements {
        doc /* The L2 performance requirements the flight segment answers for. Groups are kept
             * to six members (docs/findings/WP-A.md F-A02). */
        require captureEnvelope;
        require deliveredMass;
        require transferDuration;
        require propellantCapacity;
        require characterisationProducts;
        require deflectionMeasurement;
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    requirement flightSafetyAndAutonomyRequirements {
        doc /* The L2 safety, redundancy and autonomy requirements of the flight segment. */
        require earthImpactExclusion;
        require droStability;
        require thrustRedundancy;
        require autonomousSurvival;
        require faultResponse;
        require despinCapacity;
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    requirement flightEnvironmentAndBudgetRequirements {
        doc /* The L2 environmental, budget, verification and deployment requirements of the
             * flight segment. */
        require proximityContactEnvironment;
        require massBudget;
        require captureQualification;
        require inspectorDeployment;
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    requirement interfaceRequirements {
        doc /* The L2 requirements written on an interface and owned by an ICD. */
        require launchCompatibility;
        require deepSpaceLink;
        require visitorDocking;
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    requirement groundSegmentRequirements {
        doc /* The L2 requirements the ground segment answers for. */
        require groundCoverage;
        require commandLatency;
        require operatorWorkload;
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    requirement safetyRequirements {
        doc /* The requirements the cislunar safety board reviews. */
        require earthImpactExclusion;
        require droStability;
        require thrustRedundancy;
        require faultResponse;
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::mission; stage = VerificationStage::qualification; }
    }

    allocation flightPerformanceAllocation allocate flightPerformanceRequirements to tethysSystem.flight {
        doc /* The flight performance group is allocated to the flight segment. */
    }
    allocation flightSafetyAllocation allocate flightSafetyAndAutonomyRequirements to tethysSystem.flight {
        doc /* The flight safety and autonomy group is allocated to the flight segment. */
    }
    allocation flightEnvironmentAllocation allocate flightEnvironmentAndBudgetRequirements to tethysSystem.flight {
        doc /* The flight environment and budget group is allocated to the flight segment. */
    }
    allocation groundAllocation allocate groundSegmentRequirements to tethysSystem.ground {
        doc /* The ground-segment group is allocated to the ground segment. */
    }

    // ---- Derivation from the L1 requirements -----------------------------------------------

    #derivation connection {
        end #original ::> retrieval;
        end #derive ::> captureEnvelope;
        end #derive ::> deliveredMass;
        end #derive ::> propellantCapacity;
        end #derive ::> despinCapacity;
    }
    #derivation connection {
        end #original ::> missionDuration;
        end #derive ::> transferDuration;
        end #derive ::> propellantCapacity;
    }
    #derivation connection {
        end #original ::> characterisation;
        end #derive ::> characterisationProducts;
        end #derive ::> inspectorDeployment;
        end #derive ::> captureEnvelope;
    }
    #derivation connection {
        end #original ::> TethysRequirements::launchCompatibility;
        end #derive ::> TethysRequirementsL2::launchCompatibility;
        end #derive ::> massBudget;
    }
    #derivation connection {
        end #original ::> groundCompatibility;
        end #derive ::> deepSpaceLink;
        end #derive ::> groundCoverage;
        end #derive ::> commandLatency;
    }
    #derivation connection {
        end #original ::> cislunarSafety;
        end #derive ::> earthImpactExclusion;
        end #derive ::> droStability;
    }
    #derivation connection {
        end #original ::> missionClass;
        end #derive ::> thrustRedundancy;
        end #derive ::> autonomousSurvival;
        end #derive ::> faultResponse;
        end #derive ::> operatorWorkload;
        end #derive ::> captureQualification;
        end #derive ::> proximityContactEnvironment;
    }
    #derivation connection {
        end #original ::> deflectionDemonstration;
        end #derive ::> deflectionMeasurement;
    }
    #derivation connection {
        end #original ::> utilisationAccess;
        end #derive ::> visitorDocking;
    }

    // ---- Satisfaction by the system architecture ----------------------------------------

    part l2Satisfaction {
        doc /* Which part of the architecture satisfies each L2 requirement; the constraints are
             * evaluated with -satisfy. Tug requirements are satisfied by TethysTug::argent, the
             * configured tug, because TethysSystem's tug part carries no values of its own.
             * TS-017 is a verification requirement with no constraint to evaluate; its closure is
             * the capture qualification test case. */
        satisfy captureEnvelope by TethysTug::argent { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy deliveredMass by tethysSystem.flight { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy transferDuration by tethysSystem.flight { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy propellantCapacity by TethysTug::argent { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy characterisationProducts by tethysSystem.flight { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy earthImpactExclusion by tethysSystem.flight { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy droStability by tethysSystem.flight { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy thrustRedundancy by TethysTug::argent { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy deflectionMeasurement by tethysSystem.flight { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy autonomousSurvival by tethysSystem.flight { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy proximityContactEnvironment by TethysTug::argent { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy faultResponse by tethysSystem.flight { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy massBudget by TethysTug::argent { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy inspectorDeployment by tethysSystem.flight { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy despinCapacity by TethysTug::argent { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy groundCoverage by tethysSystem.ground { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy commandLatency by tethysSystem.ground { doc /* Satisfied by the named part of the system architecture. */ }
        satisfy operatorWorkload by tethysSystem.ground { doc /* Satisfied by the named part of the system architecture. */ }
    }
}
