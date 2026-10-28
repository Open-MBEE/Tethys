package TethysCaptureSystem {
    doc /* The tug's capture system in detail: the inflatable bag, its booms, cinch lines and
         * sensors, the contact-load and despin model, the small/nominal/large/fast-spin/tumbling
         * target cases the pre-arrival uncertainty leaves open, and the capture envelope as a
         * constraint evaluated over them. TethysTug keeps the subsystem's limits (10 m,
         * 1 000 t); everything here refines them. */
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import RealFunctions::*;
    private import TethysEnvironment::*;
    private import TethysInterfaces::*;
    private import TethysTug::CaptureSystem;
    private import TethysTarget::*;
    private import TethysInspectorDetail::*;

    item def ContactLoad :> MechanicalLoad {
        doc /* The load the body puts into the capture mechanism: the backbone's force and
             * quasi-static acceleration, plus the torque the despin reacts and the impulse of
             * the contact itself. */
        attribute torque : TorqueValue;
        attribute impulse : ImpulseValue;
    }
    item def CinchTension {
        doc /* The tension in one cinch line as its load cell reports it. */
        attribute tension : ForceValue;
    }

    part def CaptureBag {
        doc /* The inflatable capture bag: a coated-fabric envelope that opens to its deployed
             * diameter on the booms, envelops the body and is cinched closed behind it. */
        attribute mass : MassValue;
        attribute deployedDiameter : LengthValue;
        attribute operatingPressure : PressureValue;
        attribute burstPressure : PressureValue;
        attribute tearStrength : ForceValue;
    }
    part def DeploymentBoom {
        doc /* One of the booms that carry the bag's mouth out and hold it open. */
        attribute mass : MassValue;
        attribute deployedLength : LengthValue;
    }
    part def CinchLine {
        doc /* One cinch line; its preload sets the friction that holds the body against the
             * despin torque, its breaking strength bounds the load path. */
        attribute preload : ForceValue;
        attribute breakingStrength : ForceValue;
        out item tension : CinchTension;
    }
    part def CinchMotor {
        doc /* One of the two redundant cinch winches. */
        attribute mass : MassValue;
        attribute stallTorque : TorqueValue;
    }
    part def ContactSensor {
        doc /* A load cell at a boom root; the twelve together resolve the contact force and
             * the torque the body applies through the bag. */
        attribute mass : MassValue;
        out item load : ContactLoad;
    }
    part def ReleaseCutter {
        doc /* A redundant line cutter; six release the bag and the body if the despin or the
             * return has to be abandoned. */
        attribute mass : MassValue;
    }

    part def CaptureMechanism :> CaptureSystem {
        doc /* The capture system as built: the bag on six booms, six cinch lines on two
             * winches, twelve contact sensors and six cutters. Its envelope is the backbone's
             * diameter and mass limits plus the limits below: the body must not arrive faster
             * than the load path takes, must not carry more angular momentum than the despin
             * budget removes, and must rotate about a principal axis. */
        part bag : CaptureBag;
        part booms : DeploymentBoom [6];
        part lines : CinchLine [6];
        part winches : CinchMotor [2];
        part sensors : ContactSensor [12];
        part cutters : ReleaseCutter [6];
        attribute maximumContactSpeed : SpeedValue;
        attribute contactStopDistance : LengthValue;
        attribute loadPathForceLimit : ForceValue;
        attribute maximumAngularMomentum : AngularMomentumValue;
        attribute minimumRotationPeriod : DurationValue;
        attribute maximumDespinTorque : TorqueValue;
        attribute slipTorqueLimit : TorqueValue;
        attribute minimumTemperature : ThermodynamicTemperatureValue;
        attribute maximumTemperature : ThermodynamicTemperatureValue;
        port thermal : ThermalPort;
    }

    part captureMechanism : CaptureMechanism {
        doc /* Argent's capture mechanism: a 12 m bag on 7 m booms, 20 kN load path over a
             * 0.5 m stop, 6.0 × 10⁴ N·m·s of despin authority (the 10 kg of hydrazine the
             * reaction control allocates to despin at 3 m arm and 220 s), a 120 N·m torque
             * limit under a 150 N·m slip limit, 0.10 m/s at contact. The minimum rotation
             * period follows from the angular-momentum limit for the largest body the backbone
             * admits (10 m, 1 000 t): MinimumRotationPeriod below gives 1 047 s; for the
             * nominal body the same limit admits 175 s. */
        attribute :>> maximumBodyDiameter = 10.0 [m];
        attribute :>> maximumBodyMass = 1000.0e3 [kg];
        part :>> bag {
            attribute :>> mass = 86.0 [kg];
            attribute :>> deployedDiameter = 12.0 [m];
            attribute :>> operatingPressure = 1.5e3 [Pa];
            attribute :>> burstPressure = 12.0e3 [Pa];
            attribute :>> tearStrength = 9.0e3 [N];
        }
        part :>> booms { attribute :>> mass = 11.0 [kg]; attribute :>> deployedLength = 7.0 [m]; }
        part :>> lines { attribute :>> preload = 2.5e3 [N]; attribute :>> breakingStrength = 40.0e3 [N]; }
        part :>> winches { attribute :>> mass = 9.0 [kg]; attribute :>> stallTorque = 60.0 ['N⋅m']; }
        part :>> sensors { attribute :>> mass = 0.4 [kg]; }
        part :>> cutters { attribute :>> mass = 0.3 [kg]; }
        attribute :>> mass = 196.0 [kg];
        attribute :>> maximumContactSpeed = 0.10 ['m/s'];
        attribute :>> contactStopDistance = 0.5 [m];
        attribute :>> loadPathForceLimit = 20.0e3 [N];
        attribute :>> maximumAngularMomentum = 6.0e4 ['N⋅m⋅s'];
        attribute :>> minimumRotationPeriod = 175.0 [s];
        attribute :>> maximumDespinTorque = 120.0 ['N⋅m'];
        attribute :>> slipTorqueLimit = 150.0 ['N⋅m'];
        attribute :>> minimumTemperature = 173.0 [K];
        attribute :>> maximumTemperature = 353.0 [K];
    }

    calc def SphereMomentOfInertia {
        doc /* Moment of inertia in kg·m² of a homogeneous sphere of mass m (kg) and diameter
             * d (m): (2/5) m (d/2)². */
        in massKg : Real;
        in diameterM : Real;
        return inertiaKgM2 : Real = 0.1 * massKg * diameterM * diameterM;
    }
    calc def AngularMomentum {
        doc /* Angular momentum in N·m·s of a body with moment of inertia I (kg·m²) rotating
             * with period T (s): 2πI/T. */
        in inertiaKgM2 : Real;
        in periodS : Real;
        return angularMomentumNms : Real = 2.0 * pi * inertiaKgM2 / periodS;
    }
    calc def EquatorialSurfaceSpeed {
        doc /* Surface speed in m/s at the equator of a body of diameter d (m) rotating with
             * period T (s): πd/T — what the mechanism meets if the approach is not matched to
             * the rotation. */
        in diameterM : Real;
        in periodS : Real;
        return speedMPerS : Real = pi * diameterM / periodS;
    }
    calc def DespinDuration {
        doc /* Time in s to remove angular momentum L (N·m·s) at a constant torque (N·m). */
        in angularMomentumNms : Real;
        in torqueNm : Real;
        return durationS : Real = angularMomentumNms / torqueNm;
    }
    calc def DespinPropellant {
        doc /* Propellant in kg a thruster couple at arm r (m) and Isp (s) spends removing
             * angular momentum L (N·m·s): the impulse L/r over the exhaust speed Isp·g₀. */
        in angularMomentumNms : Real;
        in armM : Real;
        in specificImpulseS : Real;
        return propellantKg : Real = angularMomentumNms / (armM * specificImpulseS * standardGravityMPerS2);
    }
    calc def ContactForce {
        doc /* Peak force in N stopping a body of mass m (kg) arriving at speed v (m/s) over a
             * distance d (m) at constant deceleration: m v² / (2 d). */
        in massKg : Real;
        in speedMPerS : Real;
        in stopDistanceM : Real;
        return forceN : Real = massKg * speedMPerS * speedMPerS / (2.0 * stopDistanceM);
    }
    calc def MinimumRotationPeriod {
        doc /* The shortest rotation period in s a body of mass m (kg) and diameter d (m) may
             * have for its angular momentum to stay under a limit L (N·m·s). */
        in angularMomentumLimitNms : Real;
        in massKg : Real;
        in diameterM : Real;
        return periodS : Real = 2.0 * pi * SphereMomentOfInertia(massKg, diameterM) / angularMomentumLimitNms;
    }

    constraint def CaptureEnvelope {
        doc /* A target is capturable when it fits the bag, weighs no more than the return
             * trajectory and the load path take, rotates slowly enough for the despin budget
             * and does so about a principal axis. */
        in body : SmallBody;
        in system : CaptureMechanism;
        body.meanDiameter <= system.maximumBodyDiameter
            and body.mass <= system.maximumBodyMass
            and body.rotationPeriod >= system.minimumRotationPeriod
            and body.spinState == SpinState::principalAxis
    }

    part def EnvelopeCase {
        doc /* One target case held against the mechanism's envelope. The cases are read as the
             * plain parts of TethysTarget::targetCases, not through the CaptureTargetCase variants
             * (finding F-F02). */
        part target : SmallBody;
        part mechanism : CaptureMechanism;
    }
    part smallTargetCase : EnvelopeCase {
        doc /* The small body: inside the envelope. */
        part :>> target = targetCases.small;
        part :>> mechanism = captureMechanism;
        assert constraint fits : CaptureEnvelope { in body = target; in system = mechanism; }
    }
    part nominalTargetCase : EnvelopeCase {
        doc /* The nominal body: inside the envelope. */
        part :>> target = targetCases.nominal;
        part :>> mechanism = captureMechanism;
        assert constraint fits : CaptureEnvelope { in body = target; in system = mechanism; }
    }
    part largeTargetCase : EnvelopeCase {
        doc /* The large design body (506 t): inside the envelope. */
        part :>> target = targetCases.large;
        part :>> mechanism = captureMechanism;
        assert constraint fits : CaptureEnvelope { in body = target; in system = mechanism; }
    }
    part densestTargetCase : EnvelopeCase {
        doc /* The densest body (576 t): inside the mechanism's envelope — it is the return
             * envelope (TethysBudgets::captureCommitEnvelope), not the bag, that refuses it. */
        part :>> target = targetCases.densest;
        part :>> mechanism = captureMechanism;
        assert constraint fits : CaptureEnvelope { in body = target; in system = mechanism; }
    }
    part largestTargetCase : EnvelopeCase {
        doc /* The largest body (9.5 m, 987 t, 100 s): inside the bag on diameter and mass,
             * outside the envelope on rotation period. */
        part :>> target = targetCases.largest;
        part :>> mechanism = captureMechanism;
        assert not constraint fits : CaptureEnvelope { in body = target; in system = mechanism; }
    }
    part fastSpinTargetCase : EnvelopeCase {
        doc /* The fast-spinning body: outside the envelope on rotation period. */
        part :>> target = targetCases.fastSpin;
        part :>> mechanism = captureMechanism;
        assert not constraint fits : CaptureEnvelope { in body = target; in system = mechanism; }
    }
    part tumblingTargetCase : EnvelopeCase {
        doc /* The tumbling body: outside the envelope on spin state. */
        part :>> target = targetCases.tumbling;
        part :>> mechanism = captureMechanism;
        assert not constraint fits : CaptureEnvelope { in body = target; in system = mechanism; }
    }

    interface def CaptureContactInterface :> CaptureInterface {
        doc /* The capture ICD: the backbone's mechanical ends and agreed limits (the speed at
             * contact, the cinch preload, the torque the despin may react through the bag
             * before it slips, and the temperature band the bag fabric and the body's surface
             * meet in), with the contact load flowing from the body into the tug. */
        flow of ContactLoad from bodySide.load to tugSide.load;
    }
    interface def DespinInterface {
        doc /* The despin ICD between the reaction control that supplies the torque and the
             * capture mechanism that reacts it into the body: torque command and limit. */
        end rcsSide : MechanicalPort;
        end mechanismSide : ~MechanicalPort;
        attribute commandedTorque : TorqueValue;
        attribute torqueLimit : TorqueValue;
        flow of ContactLoad from rcsSide.load to mechanismSide.load;
    }

    requirement def ContactSpeedRequirement {
        doc /* The approach shall meet the body no faster than the load path stops within
             * its limit for the heaviest body in the envelope. */
        attribute contactSpeed : SpeedValue;
        attribute speedLimit : SpeedValue;
        require constraint { contactSpeed <= speedLimit }
    }
    requirement <'TR-041'> contactSpeed : ContactSpeedRequirement {
        doc /* 0.10 m/s on a 1 000 t body over 0.5 m is 10 kN, half the 20 kN load path. */
        attribute :>> contactSpeed = 0.10 ['m/s'];
        attribute :>> speedLimit = 0.10 ['m/s'];
    }
    requirement def DespinTorqueRequirement {
        doc /* The despin torque shall stay under the slip limit of the cinched bag with margin. */
        attribute despinTorque : TorqueValue;
        attribute slipTorqueLimit : TorqueValue;
        require constraint { despinTorque <= 0.8 * slipTorqueLimit }
    }
    requirement <'TR-042'> despinTorque : DespinTorqueRequirement {
        doc /* 120 N·m under a 150 N·m slip limit: 4.2 × 10⁴ N·m·s in 350 s for the nominal body. */
        attribute :>> despinTorque = 120.0 ['N⋅m'];
        attribute :>> slipTorqueLimit = 150.0 ['N⋅m'];
    }
}
