// The L3 subsystem requirements of the tug (TA), the inspector (TW) and the ground segment (TG),
// each derived from an L2 requirement and written on a subsystem def of the backbone, and L4
// component samples (TC) derived from them. Design values the backbone does not carry are
// stated in the requirement so that -satisfy can evaluate every constraint.
package TethysRequirementsL3L4 {
    doc /* L3 and L4 requirements of Tethys. Subsystems whose backbone configuration carries
         * values (Argent's eps, sep, rcs and captureSystem; Wren) are the satisfying parts;
         * the others are satisfied by the requirement's own design values until the owning
         * package binds them. */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SequenceFunctions::size;
    private import ModelingMetadata::*;
    private import RequirementDerivation::*;
    private import VerificationCases::VerificationMethodKind;
    private import TethysRequirements::SubsystemRequirement;
    private import TethysRequirements::ComponentRequirement;
    private import TethysRequirements::Verification;
    private import TethysRequirements::VerificationLevel;
    private import TethysRequirements::VerificationStage;
    private import TethysRequirementsL2::*;
    private import TethysStakeholders::targetCases;
    private import TethysStakeholders::missionMeasures;
    private import TethysStakeholders::DrivingRequirement;
    private import TethysSystem::*;
    private import TethysTug::*;
    private import TethysInspector::*;
    private import TethysGround::*;

    // ---- L3: tug subsystems -----------------------------------------------------------------

    requirement <'TA-001'> sepThrust : SubsystemRequirement {
        doc /* The SEP subsystem shall produce at least 1.8 N at its maximum power with three
             * thrusters operating, at the design efficiency of 0.65. */
        subject sep : SolarElectricPropulsion;
        attribute efficiency : Real = 0.65;
        attribute thrust : ForceValue = TethysEnvironment::SepThrust(sep.maximumPower / 1 [W], sep.specificImpulse / 1 [s], efficiency) [N];
        require constraint { thrust >= 1.8 [N] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "propulsion lead"; status = StatusKind::closed; }
    }
    requirement <'TA-002'> arrayPowerAtTarget : SubsystemRequirement {
        doc /* The electrical power subsystem shall supply at least 38 kW to the SEP (95 % of its
             * maximum, the throttle point the transfer is designed at) plus a 6 kW bus load at
             * the target's heliocentric distance, where the solar flux is that at 1.034 AU. */
        subject eps : ElectricalPower;
        attribute busLoad : PowerValue = 6.0 [kW];
        attribute sepPowerAtTarget : PowerValue = 38.0 [kW];
        attribute fluxRatio : Real = TethysEnvironment::SolarFlux(1.034) / TethysEnvironment::SolarFlux(1.0);
        attribute powerAtTarget : PowerValue = eps.arrayPowerAtOneAu * fluxRatio;
        require constraint { powerAtTarget >= sepPowerAtTarget + busLoad }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "power lead"; status = StatusKind::closed; }
    }
    requirement <'TA-003'> captureBagDiameter : SubsystemRequirement {
        doc /* The capture system shall envelop a body of the large case's diameter with 0.5 m of
             * clearance all round. */
        subject captureSystem : CaptureSystem;
        attribute clearance : LengthValue = 0.5 [m];
        require constraint { captureSystem.maximumBodyDiameter >= targetCases.large.meanDiameter + clearance }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "capture lead"; status = StatusKind::closed; }
    }
    requirement <'TA-004'> contactSpeedTolerance : SubsystemRequirement {
        doc /* The capture bag and cinch lines shall tolerate contact with a surface moving at up
             * to 0.35 m/s, the large case's equatorial speed with margin. */
        subject captureSystem : CaptureSystem;
        attribute designContactSpeed : SpeedValue = 0.35 [m/s];
        attribute largeCaseSurfaceSpeed : SpeedValue = 3.14159265 * targetCases.large.meanDiameter / targetCases.large.rotationPeriod;
        require constraint { designContactSpeed >= largeCaseSurfaceSpeed }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "capture lead"; status = StatusKind::closed; }
    }
    requirement <'TA-005'> despinTorque : SubsystemRequirement {
        doc /* The reaction-control subsystem shall produce a despin torque of at least 11.6 N m
             * about any stack axis: a 22 N thruster pair on a 3 m lever arm gives 66 N m. */
        subject rcs : ReactionControl;
        attribute thrusterForce : ForceValue = 22.0 [N];
        attribute leverArm : LengthValue = 3.0 [m];
        attribute torqueNm : Real = (thrusterForce / 1 [N]) * (leverArm / 1 [m]);
        require constraint { torqueNm >= 11.6 }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "GNC lead"; status = StatusKind::closed; }
    }
    requirement <'TA-006'> hydrazineLoad : SubsystemRequirement {
        doc /* The reaction-control subsystem shall carry at least four times the hydrazine the
             * large-case despin uses (about 60 kg), covering nutation damping, forced-motion
             * station-keeping and disposal. */
        subject rcs : ReactionControl;
        attribute despinAllocation : MassValue = 60.0 [kg];
        require constraint { rcs.hydrazineMass >= 4.0 * despinAllocation }
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::subsystem; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "GNC lead"; status = StatusKind::closed; }
    }
    requirement <'TA-007'> deepSpaceEirp : SubsystemRequirement {
        doc /* The telecommunications subsystem shall radiate an EIRP of at least 1 500 W toward
             * Earth so that the link closes at the TS-007 design range with a 34 m station. */
        subject telecom : Telecommunications;
        attribute eirp : PowerValue = 2000.0 [W];
        require constraint { eirp >= 1500.0 [W] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "telecom lead"; status = StatusKind::closed; }
    }
    requirement <'TA-008'> proximityLinkRange : SubsystemRequirement {
        doc /* The telecommunications subsystem shall maintain the inspector proximity link to
             * 5 km at 1 Mbit/s. */
        subject telecom : Telecommunications;
        attribute linkRange : LengthValue = 5000.0 [m];
        attribute dataRate : Real = 1.0e6;
        require constraint { linkRange >= 5000.0 [m] and dataRate >= 1.0e6 }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "telecom lead"; status = StatusKind::closed; }
    }
    requirement <'TA-009'> relativeNavigation : SubsystemRequirement {
        doc /* The GNC subsystem shall know the tug's position relative to the body to 0.1 m and
             * its velocity to 1 mm/s at 100 m range, closed loop, without ground intervention. */
        subject gnc : GuidanceNavigationControl;
        attribute positionKnowledge : LengthValue = 0.08 [m];
        attribute velocityKnowledge : SpeedValue = 0.0008 [m/s];
        require constraint { positionKnowledge <= 0.1 [m] and velocityKnowledge <= 0.001 [m/s] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "GNC lead"; status = StatusKind::closed; }
        @DrivingRequirement { driver = "lidar and camera suite, closed-loop control rate"; }
    }
    requirement <'TA-010'> faultDetectionLatency : SubsystemRequirement {
        doc /* The command and data handling subsystem shall detect a thrust-vector or contact
             * fault within 0.5 s of its signature appearing in telemetry. */
        subject cdh : CommandAndDataHandling;
        attribute detectionLatency : DurationValue = 0.4 [s];
        require constraint { detectionLatency <= 0.5 [s] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "software lead"; status = StatusKind::closed; }
    }
    requirement <'TA-011'> heatRejection : SubsystemRequirement {
        doc /* The thermal control subsystem shall reject 8 kW of PPU and bus dissipation at the
             * perihelion solar flux with the bag deployed over the forward radiators. */
        subject thermal : ThermalControl;
        attribute rejection : PowerValue = 9.0 [kW];
        require constraint { rejection >= 8.0 [kW] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "thermal lead"; status = StatusKind::closed; }
    }
    requirement <'TA-012'> dockingLoads : SubsystemRequirement {
        doc /* The structure shall carry 5 kN of docking load through the docking port into the
             * cinched body without exceeding bag tension limits. */
        subject structure : StructureAndMechanisms;
        attribute dockingLoad : ForceValue = 6000.0 [N];
        require constraint { dockingLoad >= 5000.0 [N] }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "structures lead"; status = StatusKind::tbr; }
        @Rationale { text = "The 5 kN figure is TBR until the Lantern docking ICD fixes the contact velocity."; }
    }
    requirement <'TA-013'> inspectorSeparation : SubsystemRequirement {
        doc /* The inspector attachment shall release the inspector at 2 to 5 cm/s with a tip-off
             * rate below 1 deg/s. */
        subject structure : StructureAndMechanisms;
        attribute separationSpeed : SpeedValue = 0.03 [m/s];
        require constraint { separationSpeed >= 0.02 [m/s] and separationSpeed <= 0.05 [m/s] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "mechanisms lead"; status = StatusKind::tbd; }
    }
    requirement <'TA-014'> spinStateSensing : SubsystemRequirement {
        doc /* The characterisation sensors shall determine the body's spin period to 1 % from
             * light curves and landmark tracking within one day of hold at 1 km. */
        subject sensors : CharacterisationSensors;
        attribute periodUncertainty : Real = 0.005;
        require constraint { periodUncertainty <= 0.01 }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "navigation lead"; status = StatusKind::closed; }
    }

    // ---- L3: inspector -------------------------------------------------------------------

    requirement <'TW-001'> imagingResolution : SubsystemRequirement {
        doc /* The imaging payload shall resolve 2 cm per pixel at 50 m range so that the shape
             * model meets its 0.1 m requirement with five pixels per facet. */
        subject payload : ImagingPayload;
        attribute groundSampleDistance : LengthValue = 0.015 [m];
        require constraint { groundSampleDistance <= 0.02 [m] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "inspector lead"; status = StatusKind::closed; }
    }
    requirement <'TW-002'> circumnavigationPropellant : SubsystemRequirement {
        doc /* The cold-gas propulsion shall provide 20 m/s of delta-v for circumnavigation and
             * station-keeping, about 1 kg at 60 s specific impulse on a 24 kg vehicle. */
        subject propulsion : ColdGasPropulsion;
        attribute deltaV : SpeedValue = 22.0 [m/s];
        require constraint { deltaV >= 20.0 [m/s] }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "inspector lead"; status = StatusKind::closed; }
    }
    requirement <'TW-003'> keepAlivePower : SubsystemRequirement {
        doc /* The cubesat bus shall survive on 5 W of keep-alive power from the tug umbilical
             * for the whole outbound cruise. */
        subject bus : CubesatBus;
        attribute keepAlivePower : PowerValue = 4.0 [W];
        require constraint { keepAlivePower <= 5.0 [W] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "inspector lead"; status = StatusKind::closed; }
    }
    requirement <'TW-004'> inspectorMass : SubsystemRequirement {
        doc /* The inspector's wet mass shall not exceed the 25 kg dispenser class. */
        subject inspector : Inspector;
        require constraint { inspector.wetMass <= 25.0 [kg] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "inspector lead"; status = StatusKind::closed; }
    }
    requirement <'TW-005'> dopplerForMass : SubsystemRequirement {
        doc /* The cubesat bus transponder shall support two-way proximity Doppler to 0.1 mm/s so
             * that the body's mass follows from the inspector's orbit perturbation to 10 %. */
        subject bus : CubesatBus;
        attribute dopplerAccuracy : SpeedValue = 0.00008 [m/s];
        require constraint { dopplerAccuracy <= 0.0001 [m/s] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "navigation lead"; status = StatusKind::closed; }
    }

    // ---- L3: ground segment ---------------------------------------------------------------

    requirement <'TG-001'> stationAperture : SubsystemRequirement {
        doc /* Each deep-space station shall provide a 34 m class aperture with a system noise
             * temperature below 30 K at X band. */
        subject station : DeepSpaceStation;
        attribute minimumAperture : LengthValue = 34.0 [m];
        attribute noiseTemperature : Real = 25.0;
        require constraint { minimumAperture >= 34.0 [m] and noiseTemperature <= 30.0 }
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::subsystem; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground segment"; status = StatusKind::closed; }
    }
    requirement <'TG-002'> stationSpacing : SubsystemRequirement {
        doc /* The network shall operate three stations spaced in longitude so that the tug is
             * visible from at least one of them at all times. */
        subject network : GroundNetwork;
        require constraint { network.stations->size() >= 3 }
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::subsystem; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "ground segment"; status = StatusKind::closed; }
    }
    requirement <'TG-003'> rangingAccuracy : SubsystemRequirement {
        doc /* The flight dynamics facility shall determine the two-way range to 2 m and the
             * range rate to 0.1 mm/s per pass. */
        subject fdf : FlightDynamicsFacility;
        attribute rangeAccuracy : LengthValue = 1.5 [m];
        require constraint { rangeAccuracy <= missionMeasures.rangingAccuracy }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::subsystem; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "flight dynamics"; status = StatusKind::closed; }
    }
    requirement <'TG-004'> impactScreening : SubsystemRequirement {
        doc /* The flight dynamics facility shall screen every return thrust arc against the
             * Earth-impact exclusion before release and shall archive the screening record. */
        subject fdf : FlightDynamicsFacility;
        attribute screenedFraction : Real = 1.0;
        require constraint { screenedFraction == 1.0 }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::subsystem; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "cislunar safety board"; status = StatusKind::closed; }
    }
    requirement <'TG-005'> sequenceTurnaround : SubsystemRequirement {
        doc /* The operations centre shall build, validate and release a command sequence within
             * 4 h of a request during proximity operations. */
        subject moc : MissionOperationsCentre;
        attribute turnaround : DurationValue = 3.5 [h];
        require constraint { turnaround <= 4 [h] }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::subsystem; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "flight operations"; status = StatusKind::closed; }
    }
    requirement <'TG-006'> monitoringAutomation : SubsystemRequirement {
        doc /* The operations centre shall automate at least 95 % of nominal thrust-arc telemetry
             * limit checks so that one shift of three can fly an arc. */
        subject moc : MissionOperationsCentre;
        attribute automatedFraction : Real = 0.97;
        require constraint { automatedFraction >= 0.95 }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::subsystem; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "flight operations"; status = StatusKind::closed; }
    }
    requirement <'TG-007'> scienceArchive : SubsystemRequirement {
        doc /* The science data system shall archive the shape, mass and spin products within
             * 30 d of the capture-commit review and the deflection measurement within 30 d of
             * the end of its arc. */
        subject sds : ScienceDataSystem;
        attribute archiveLatency : DurationValue = 30 [d];
        require constraint { archiveLatency <= 30 [d] }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::subsystem; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "science team"; status = StatusKind::closed; }
    }

    // ---- L4 samples: components -----------------------------------------------------------

    requirement <'TC-001'> thrusterUnitThrust : ComponentRequirement {
        doc /* One thruster at its 13.33 kW share of the SEP power shall produce at least 0.6 N. */
        subject sep : SolarElectricPropulsion;
        attribute unitPower : PowerValue = 13333.0 [W];
        attribute unitThrust : ForceValue = TethysEnvironment::SepThrust(unitPower / 1 [W], sep.specificImpulse / 1 [s], 0.65) [N];
        require constraint { unitThrust >= 0.6 [N] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "propulsion lead"; status = StatusKind::closed; }
    }
    requirement <'TC-002'> powerProcessingEfficiency : ComponentRequirement {
        doc /* Each power processing unit shall convert high-voltage bus power to thruster power
             * at 95 % efficiency or better. */
        subject sep : SolarElectricPropulsion;
        attribute efficiency : Real = 0.955;
        require constraint { efficiency >= 0.95 }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "propulsion lead"; status = StatusKind::closed; }
    }
    requirement <'TC-003'> cinchMotorTorque : ComponentRequirement {
        doc /* Each cinch motor shall hold a stall torque of 40 N m against the cinched body. */
        subject captureSystem : CaptureSystem;
        attribute stallTorqueNm : Real = 45.0;
        require constraint { stallTorqueNm >= 40.0 }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "capture lead"; status = StatusKind::closed; }
    }
    requirement <'TC-004'> narrowAngleCameraSensitivity : ComponentRequirement {
        doc /* The narrow-angle camera shall detect a body of absolute magnitude 28.2 at 5 000 km
             * in a 10 s exposure: a limiting magnitude of 12.5 or fainter. */
        subject sensors : CharacterisationSensors;
        attribute limitingMagnitude : Real = 13.2;
        require constraint { limitingMagnitude >= 12.5 }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "navigation lead"; status = StatusKind::closed; }
    }
    requirement <'TC-005'> fdirTaskPeriod : ComponentRequirement {
        doc /* The fault-protection software task shall run every 100 ms. */
        subject cdh : CommandAndDataHandling;
        attribute taskPeriod : DurationValue = 0.1 [s];
        require constraint { taskPeriod <= 0.1 [s] }
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::unit; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "software lead"; status = StatusKind::closed; }
    }
    requirement <'TC-006'> inspectorDetectorPitch : ComponentRequirement {
        doc /* The inspector camera detector shall have a pixel pitch that gives 2 cm at 50 m
             * with the 50 mm lens: 20 micrometres or finer. */
        subject payload : ImagingPayload;
        attribute pixelPitch : LengthValue = 15.0e-6 [m];
        require constraint { pixelPitch <= 20.0e-6 [m] }
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::unit; stage = VerificationStage::acceptance; }
        @StatusInfo { owner = "inspector lead"; status = StatusKind::closed; }
    }

    // ---- Derivation ----------------------------------------------------------------------

    #derivation connection { end #original ::> transferDuration; end #derive ::> sepThrust; end #derive ::> arrayPowerAtTarget; }
    #derivation connection { end #original ::> captureEnvelope; end #derive ::> captureBagDiameter; }
    #derivation connection { end #original ::> proximityContactEnvironment; end #derive ::> contactSpeedTolerance; end #derive ::> heatRejection; }
    #derivation connection { end #original ::> despinCapacity; end #derive ::> despinTorque; end #derive ::> hydrazineLoad; }
    #derivation connection { end #original ::> deepSpaceLink; end #derive ::> deepSpaceEirp; end #derive ::> stationAperture; end #derive ::> stationSpacing; }
    #derivation connection { end #original ::> inspectorDeployment; end #derive ::> proximityLinkRange; end #derive ::> inspectorSeparation; end #derive ::> keepAlivePower; }
    #derivation connection { end #original ::> characterisationProducts; end #derive ::> relativeNavigation; end #derive ::> spinStateSensing; end #derive ::> imagingResolution; end #derive ::> dopplerForMass; end #derive ::> circumnavigationPropellant; end #derive ::> scienceArchive; }
    #derivation connection { end #original ::> faultResponse; end #derive ::> faultDetectionLatency; }
    #derivation connection { end #original ::> visitorDocking; end #derive ::> dockingLoads; }
    #derivation connection { end #original ::> launchCompatibility; end #derive ::> inspectorMass; }
    #derivation connection { end #original ::> deflectionMeasurement; end #derive ::> TethysRequirementsL3L4::rangingAccuracy; }
    #derivation connection { end #original ::> earthImpactExclusion; end #derive ::> impactScreening; }
    #derivation connection { end #original ::> commandLatency; end #derive ::> sequenceTurnaround; }
    #derivation connection { end #original ::> operatorWorkload; end #derive ::> monitoringAutomation; }
    #derivation connection { end #original ::> sepThrust; end #derive ::> thrusterUnitThrust; end #derive ::> powerProcessingEfficiency; }
    #derivation connection { end #original ::> captureBagDiameter; end #derive ::> cinchMotorTorque; }
    #derivation connection { end #original ::> relativeNavigation; end #derive ::> narrowAngleCameraSensitivity; }
    #derivation connection { end #original ::> faultDetectionLatency; end #derive ::> fdirTaskPeriod; }
    #derivation connection { end #original ::> imagingResolution; end #derive ::> inspectorDetectorPitch; }

    // ---- Satisfaction ---------------------------------------------------------------------

    part l3l4Satisfaction {
        doc /* Satisfying parts for the L3 and L4 requirements, evaluated by -satisfy. Argent's
             * configured subsystems and Wren carry values; the ground subsystems are the
             * system's. TG-001 has no single-station part in the backbone to be satisfied by
             * (the network's stations are a [3] multiplicity); it is closed by inspection. */
        satisfy sepThrust by argent.sep { doc /* Argent's SEP. */ }
        satisfy arrayPowerAtTarget by argent.eps { doc /* Argent's power subsystem. */ }
        satisfy captureBagDiameter by argent.captureSystem { doc /* Argent's capture system. */ }
        satisfy contactSpeedTolerance by argent.captureSystem { doc /* Argent's capture system. */ }
        satisfy despinTorque by argent.rcs { doc /* Argent's reaction control. */ }
        satisfy hydrazineLoad by argent.rcs { doc /* Argent's reaction control. */ }
        satisfy deepSpaceEirp by argent.telecom { doc /* Argent's telecommunications. */ }
        satisfy proximityLinkRange by argent.telecom { doc /* Argent's telecommunications. */ }
        satisfy relativeNavigation by argent.gnc { doc /* Argent's GNC. */ }
        satisfy faultDetectionLatency by argent.cdh { doc /* Argent's C&DH. */ }
        satisfy heatRejection by argent.thermal { doc /* Argent's thermal control. */ }
        satisfy dockingLoads by argent.structure { doc /* Argent's structure. */ }
        satisfy inspectorSeparation by argent.structure { doc /* Argent's structure. */ }
        satisfy spinStateSensing by argent.sensors { doc /* Argent's sensors. */ }
        satisfy imagingResolution by wren.payload { doc /* Wren's imaging payload. */ }
        satisfy circumnavigationPropellant by wren.propulsion { doc /* Wren's cold-gas propulsion. */ }
        satisfy keepAlivePower by wren.bus { doc /* Wren's bus. */ }
        satisfy inspectorMass by wren { doc /* Wren. */ }
        satisfy dopplerForMass by wren.bus { doc /* Wren's bus. */ }
        satisfy stationSpacing by tethysSystem.ground.network { doc /* The Meridian network. */ }
        satisfy TethysRequirementsL3L4::rangingAccuracy by tethysSystem.ground.network.fdf { doc /* The flight dynamics facility. */ }
        satisfy impactScreening by tethysSystem.ground.network.fdf { doc /* The flight dynamics facility. */ }
        satisfy sequenceTurnaround by tethysSystem.ground.network.moc { doc /* The operations centre. */ }
        satisfy monitoringAutomation by tethysSystem.ground.network.moc { doc /* The operations centre. */ }
        satisfy scienceArchive by tethysSystem.ground.network.sds { doc /* The science data system. */ }
        satisfy thrusterUnitThrust by argent.sep { doc /* Argent's SEP. */ }
        satisfy powerProcessingEfficiency by argent.sep { doc /* Argent's SEP. */ }
        satisfy cinchMotorTorque by argent.captureSystem { doc /* Argent's capture system. */ }
        satisfy narrowAngleCameraSensitivity by argent.sensors { doc /* Argent's sensors. */ }
        satisfy fdirTaskPeriod by argent.cdh { doc /* Argent's C&DH. */ }
        satisfy inspectorDetectorPitch by wren.payload { doc /* Wren's imaging payload. */ }
    }
}
