// The analyses the mission's design decisions rest on: the target cases every target-dependent
// number is evaluated over, the solar-electric transfer and return, the capture and despin
// dynamics, the external trajectory tool, and the verification case that closes the mission
// duration requirement by analysis. Trades, dispersions and the state-space models that use
// these cases live in TethysTrades, TethysMonteCarlo and TethysDynamics.
package TethysAnalyses {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import RealFunctions::*;
    private import VerificationCases::*;
    private import AnalysisTooling::*;
    private import ModelingMetadata::*;
    private import TethysEnvironment::*;
    private import TethysTug::*;
    private import TethysTarget::SmallBody;
    private import TethysMission::tethys;
    private import TethysRequirements::*;

    metadata def CredibilityAssessment {
        doc /* The eight modelling-and-simulation credibility factors of NASA-STD-7009B
             * Appendix E, each scored 0 (none) to 4 (highest), carried by every analysis case
             * definition in the model. */
        attribute verificationFactor : Natural;
        attribute validation : Natural;
        attribute inputPedigree : Natural;
        attribute resultsUncertainty : Natural;
        attribute resultsRobustness : Natural;
        attribute useHistory : Natural;
        attribute managementProcess : Natural;
        attribute peopleQualification : Natural;
    }

    // Credibility scores of the analysis definitions below (an annotation inside an analysis
    // body is not executable in OpenSysML, findings F-005).
    metadata CredibilityAssessment about LowThrustTransferAnalysis { verificationFactor = 3; validation = 1; inputPedigree = 2; resultsUncertainty = 2; resultsRobustness = 2; useHistory = 1; managementProcess = 2; peopleQualification = 3; }
    metadata CredibilityAssessment about CaptureDynamicsAnalysis { verificationFactor = 3; validation = 1; inputPedigree = 2; resultsUncertainty = 2; resultsRobustness = 1; useHistory = 0; managementProcess = 2; peopleQualification = 3; }
    metadata CredibilityAssessment about ExternalTransferAnalysis { verificationFactor = 2; validation = 2; inputPedigree = 2; resultsUncertainty = 1; resultsRobustness = 2; useHistory = 1; managementProcess = 2; peopleQualification = 3; }

    // ---- Target cases ------------------------------------------------------------------------

    part def TargetCaseBody :> SmallBody {
        doc /* A pre-arrival design case for the target body: its mass is never typed in but
             * follows from the diameter and bulk density through SphereMass, so a case is two
             * numbers and the rest derives. */
        attribute :>> mass = SphereMass(meanDiameter / 1 [m], bulkDensity / 1 ['kg⋅m⁻³']) [kg];
    }

    part smallTarget : TargetCaseBody {
        doc /* Small case: 5.9 m at 2 000 kg/m³, about 215 t — the bottom of the S-type density
             * range at the small end of the size estimate; the return Δv driver is easiest, the
             * delivered-mass requirement (TR-001) hardest. */
        attribute :>> meanDiameter = 5.9 [m];
        attribute :>> bulkDensity = 2000.0 ['kg⋅m⁻³'];
        attribute :>> rotationPeriod = 252.0 [s];
    }
    part nominalTarget : TargetCaseBody {
        doc /* Nominal case: the TethysEnvironment estimate, 6.8 m at 2 200 kg/m³, about 362 t,
             * 252 s rotation. */
        attribute :>> meanDiameter = amaranth.meanDiameter;
        attribute :>> bulkDensity = amaranth.bulkDensity;
        attribute :>> rotationPeriod = amaranth.rotationPeriod;
    }
    part largeTarget : TargetCaseBody {
        doc /* Large case: 7.6 m at 2 800 kg/m³, about 644 t — a dense monolith at the top of
             * the size estimate; the thrust-time and return-Δv driver. */
        attribute :>> meanDiameter = 7.6 [m];
        attribute :>> bulkDensity = 2800.0 ['kg⋅m⁻³'];
        attribute :>> rotationPeriod = 252.0 [s];
    }
    part fastSpinTarget : TargetCaseBody {
        doc /* Fast-spin case: the nominal body rotating in 120 s — the despin propellant and
             * contact-speed driver. */
        attribute :>> meanDiameter = amaranth.meanDiameter;
        attribute :>> bulkDensity = amaranth.bulkDensity;
        attribute :>> rotationPeriod = 120.0 [s];
    }

    variation part def TargetCase :> SmallBody {
        doc /* The target-uncertainty table as a variation: one variant per design case, each
             * bound to the case above so a configuration selects a case by name
             * (`part :>> target = TargetCase::large`). */
        variant part small : TargetCaseBody = smallTarget;
        variant part nominal : TargetCaseBody = nominalTarget;
        variant part large : TargetCaseBody = largeTarget;
        variant part fastSpin : TargetCaseBody = fastSpinTarget;
    }

    // ---- Solar-electric transfer and return --------------------------------------------------

    calc def Exponential {
        doc /* eˣ by its power series to the tenth term; for |x| ≤ 1 the truncation error is
             * below 3 × 10⁻⁸. The Kernel Function Library has no exponential (findings F-001),
             * and the propellant for a given Δv needs one. */
        in x : Real;
        return expX : Real = 1.0 + x + x ** 2 / 2.0 + x ** 3 / 6.0 + x ** 4 / 24.0
            + x ** 5 / 120.0 + x ** 6 / 720.0 + x ** 7 / 5040.0 + x ** 8 / 40320.0
            + x ** 9 / 362880.0 + x ** 10 / 3628800.0;
    }

    calc def PropellantForDeltaV {
        doc /* Propellant in kg a vehicle of initial mass m₀ (kg) spends for Δv (m/s) at the
             * specific impulse Isp (s): m₀ (1 − e^(−Δv/(Isp g₀))). */
        in deltaVMPerS : Real;
        in initialMassKg : Real;
        in specificImpulseS : Real;
        return propellantKg : Real =
            initialMassKg * (1.0 - Exponential(0.0 - deltaVMPerS / (specificImpulseS * standardGravityMPerS2)));
    }

    calc def MassFlowRate {
        doc /* Propellant mass flow in kg/s of a thruster producing the thrust T (N) at the
             * specific impulse Isp (s): ṁ = T / (Isp g₀). */
        in thrustN : Real;
        in specificImpulseS : Real;
        return massFlowKgPerS : Real = thrustN / (specificImpulseS * standardGravityMPerS2);
    }

    calc def ThrustDays {
        doc /* Days of continuous thrusting needed to process a propellant mass (kg) at a mass
             * flow (kg/s). */
        in propellantKg : Real;
        in massFlowKgPerS : Real;
        return days : Real = propellantKg / (massFlowKgPerS * 86400.0);
    }

    requirement def ReturnCapability {
        doc /* The tug shall bring the captured target home: the return Δv its remaining xenon
             * buys on the stack shall be at least the Δv the return trajectory needs, and the
             * thrusting time of the whole mission shall fit the thrust-arc allowance of the
             * mission timeline. */
        subject tug : Tug;
        in attribute returnDeltaVMPerS : Real;
        in attribute requiredReturnDeltaVMPerS : Real;
        in attribute totalThrustDays : Real;
        in attribute thrustDayAllowance : Real;
        require constraint { returnDeltaVMPerS >= requiredReturnDeltaVMPerS }
        require constraint { totalThrustDays <= thrustDayAllowance }
    }

    analysis def LowThrustTransferAnalysis {
        doc /* First-order solar-electric transfer and return: the thrust and mass flow the SEP
             * system produces at full power, the xenon and thrusting time the outbound Δv costs,
             * and what the remaining xenon buys as Δv on the tug–body stack and how long it takes
             * to spend. The target case is the input the mission is most sensitive to. */
        subject tug : Tug;
        in part target : SmallBody;
        in attribute outboundDeltaVMPerS : Real default = 2000.0 {
            doc /* Edelbaum circular-coplanar estimate 0.69 km/s for 1 → 1.034 AU, about 0.70 km/s
                 * for the 0.030 eccentricity, 0.49 km/s for the 0.6° plane change, rounded up for
                 * phasing and the launcher's v∞ disposal. */
        }
        in attribute requiredReturnDeltaVMPerS : Real default = 350.0 {
            doc /* Return leg shaped onto the lunar gravity assist plus the distant-retrograde-orbit
                 * insertion (invented allocation). */
        }
        in attribute xenonReserveKg : Real default = 300.0;
        in attribute thrustDayAllowance : Real default = 1930.0 {
            doc /* Nominal duration 2 200 d less the non-thrusting phases: early operations 30 d,
                 * characterisation 120 d, capture and despin 60 d, insertion and checkout 60 d. */
        }
        in attribute thrusterEfficiency : Real default = 0.65;

        attribute thrustN : Real = SepThrust(tug.sep.maximumPower / 1 [W], tug.sep.specificImpulse / 1 [s], thrusterEfficiency);
        attribute massFlowKgPerS : Real = MassFlowRate(thrustN, tug.sep.specificImpulse / 1 [s]);
        attribute outboundXenonKg : Real = PropellantForDeltaV(outboundDeltaVMPerS, tug.wetMass / 1 [kg], tug.sep.specificImpulse / 1 [s]);
        attribute returnXenonKg : Real = tug.sep.xenonMass / 1 [kg] - outboundXenonKg - xenonReserveKg;
        attribute stackMassKg : Real = tug.wetMass / 1 [kg] - outboundXenonKg + target.mass / 1 [kg];
        return returnDeltaVMPerS : Real =
            RocketEquationDeltaV(tug.sep.specificImpulse / 1 [s], stackMassKg, stackMassKg - returnXenonKg);
        out outboundThrustDays : Real = ThrustDays(outboundXenonKg, massFlowKgPerS);
        out returnThrustDays : Real = ThrustDays(returnXenonKg, massFlowKgPerS);
        out totalThrustDays : Real = outboundThrustDays + returnThrustDays;

        objective canReturn : ReturnCapability {
            subject :>> tug = tug;
            in returnDeltaVMPerS = returnDeltaVMPerS;
            in requiredReturnDeltaVMPerS = requiredReturnDeltaVMPerS;
            in totalThrustDays = totalThrustDays;
            in thrustDayAllowance = thrustDayAllowance;
        }
    }

    analysis transferNominal : LowThrustTransferAnalysis {
        doc /* Argent against the nominal target. */
        subject :>> tug = argent;
        in :>> target = nominalTarget;
    }
    analysis transferSmall : LowThrustTransferAnalysis { subject :>> tug = argent; in :>> target = smallTarget; }
    analysis transferLarge : LowThrustTransferAnalysis { subject :>> tug = argent; in :>> target = largeTarget; }

    // ---- Capture and despin ------------------------------------------------------------------

    requirement def CaptureEnvelope {
        doc /* The target shall fit the capture system: within its diameter and mass limits,
             * with an equatorial surface speed the bag can absorb, and with a despin that the
             * hydrazine allocated to it can pay for. */
        subject tug : Tug;
        in attribute bodyDiameterM : Real;
        in attribute bodyMassKg : Real;
        in attribute surfaceSpeedMPerS : Real;
        in attribute despinHydrazineKg : Real;
        in attribute maximumSurfaceSpeedMPerS : Real;
        in attribute despinHydrazineAllocationKg : Real;
        require constraint { bodyDiameterM <= tug.captureSystem.maximumBodyDiameter / 1 [m] }
        require constraint { bodyMassKg <= tug.captureSystem.maximumBodyMass / 1 [kg] }
        require constraint { surfaceSpeedMPerS <= maximumSurfaceSpeedMPerS }
        require constraint { despinHydrazineKg <= despinHydrazineAllocationKg }
    }

    analysis def CaptureDynamicsAnalysis {
        doc /* Rigid-body capture and despin of a spherical target: equatorial surface speed at
             * contact, moment of inertia and angular momentum, the torque a pair of hydrazine
             * thrusters on the tug's lever arm applies through the bag, and the time and
             * propellant the despin takes. */
        subject tug : Tug;
        in part target : SmallBody;
        in attribute rcsThrusterForceN : Real default = 22.0;
        in attribute rcsThrusterCount : Natural default = 2;
        in attribute leverArmM : Real default = 3.0;
        in attribute rcsSpecificImpulseS : Real default = 220.0;
        in attribute maximumSurfaceSpeedMPerS : Real default = 0.10;
        in attribute despinHydrazineAllocationKg : Real default = 40.0;

        attribute diameterM : Real = target.meanDiameter / 1 [m];
        attribute massKg : Real = target.mass / 1 [kg];
        attribute angularRateRadPerS : Real = 2.0 * pi / (target.rotationPeriod / 1 [s]);
        attribute surfaceSpeedMPerS : Real = angularRateRadPerS * diameterM / 2.0;
        attribute momentOfInertiaKgM2 : Real = 0.4 * massKg * (diameterM / 2.0) ** 2;
        return angularMomentumNMS : Real = momentOfInertiaKgM2 * angularRateRadPerS;
        attribute despinTorqueNM : Real = rcsThrusterForceN * rcsThrusterCount * leverArmM;
        out despinTimeS : Real = angularMomentumNMS / despinTorqueNM;
        out despinHydrazineKg : Real =
            rcsThrusterForceN * rcsThrusterCount * despinTimeS / (rcsSpecificImpulseS * standardGravityMPerS2);

        objective fitsEnvelope : CaptureEnvelope {
            subject :>> tug = tug;
            in bodyDiameterM = diameterM;
            in bodyMassKg = massKg;
            in surfaceSpeedMPerS = surfaceSpeedMPerS;
            in despinHydrazineKg = despinHydrazineKg;
            in maximumSurfaceSpeedMPerS = maximumSurfaceSpeedMPerS;
            in despinHydrazineAllocationKg = despinHydrazineAllocationKg;
        }
    }

    analysis captureNominal : CaptureDynamicsAnalysis { subject :>> tug = argent; in :>> target = nominalTarget; }
    analysis captureLarge : CaptureDynamicsAnalysis { subject :>> tug = argent; in :>> target = largeTarget; }
    analysis captureFastSpin : CaptureDynamicsAnalysis { subject :>> tug = argent; in :>> target = fastSpinTarget; }

    // ---- External trajectory tool ------------------------------------------------------------

    action def SolveThrustArc {
        doc /* The low-thrust transfer solved by the external ThrustArcSolver (Edelbaum
             * circular-coplanar transfer with plane change, then the exact rocket equation): the
             * body of this action is never performed by OpenSysML, the tool named by the
             * ToolExecution metadata performs it. */
        metadata ToolExecution {
            toolName = "ThrustArcSolver";
            uri = "tethys://tools/thrust-arc";
        }
        in startAu : Real[1] { @ToolVariable { name = "startAu"; } }
        in endAu : Real[1] { @ToolVariable { name = "endAu"; } }
        in planeChangeDeg : Real[1] { @ToolVariable { name = "planeChangeDeg"; } }
        in initialMassKg : Real[1] { @ToolVariable { name = "initialMassKg"; } }
        in thrustN : Real[1] { @ToolVariable { name = "thrustN"; } }
        in specificImpulseS : Real[1] { @ToolVariable { name = "specificImpulseS"; } }
        out deltaVMPerS : Real[1] { @ToolVariable { name = "deltaVMPerS"; } }
        out propellantKg : Real[1] { @ToolVariable { name = "propellantKg"; } }
        out thrustDays : Real[1] { @ToolVariable { name = "thrustDays"; } }
    }

    requirement def TransferAllowance {
        doc /* The outbound thrust arc shall fit its allowance in days. */
        subject tug : Tug;
        in attribute thrustDays : Real;
        in attribute allowanceDays : Real;
        require constraint { thrustDays <= allowanceDays }
    }

    analysis def ExternalTransferAnalysis {
        doc /* The outbound transfer handed to ThrustArcSolver: the tool receives the orbit radii,
             * plane change, mass, thrust and Isp from the model and answers the Δv, xenon and
             * thrusting days; the objective checks the days against the outbound allowance. */
        subject tug : Tug;
        in attribute thrusterEfficiency : Real default = 0.65;
        in attribute outboundAllowanceDays : Real default = 260.0;
        action solve : SolveThrustArc {
            in startAu = 1.0;
            in endAu = amaranth.orbit.semiMajorAxisAu;
            in planeChangeDeg = amaranth.orbit.inclination / 1 ['°'];
            in initialMassKg = tug.wetMass / 1 [kg];
            in thrustN = SepThrust(tug.sep.maximumPower / 1 [W], tug.sep.specificImpulse / 1 [s], thrusterEfficiency);
            in specificImpulseS = tug.sep.specificImpulse / 1 [s];
        }
        return thrustDays : Real = solve.thrustDays;
        out deltaVMPerS : Real = solve.deltaVMPerS;
        out propellantKg : Real = solve.propellantKg;
        objective fitsAllowance : TransferAllowance {
            subject :>> tug = tug;
            in thrustDays = solve.thrustDays;
            in allowanceDays = outboundAllowanceDays;
        }
    }

    analysis externalTransfer : ExternalTransferAnalysis { subject :>> tug = argent; }

    // ---- Requirement closed by analysis ------------------------------------------------------

    verification def MissionDurationByAnalysis {
        doc /* TR-002 verified by analysis: the thrusting time of the transfer and return plus the
             * non-thrusting phases must fit the nominal duration. */
        subject tug : Tug;
        in part target : SmallBody;
        in attribute nonThrustDays : Real default = 270.0;
        objective durationObjective {
            doc /* The mission duration requirement this case verifies. */
            verify missionDuration;
        }
        analysis transfer : LowThrustTransferAnalysis {
            subject :>> tug = tug;
            in :>> target = target;
        }
        return verdict : VerdictKind =
            PassIf(transfer.totalThrustDays + nonThrustDays <= tethys.nominalDuration / 1 [d]);
    }

    verification verifyDurationNominal : MissionDurationByAnalysis { subject :>> tug = argent; in :>> target = nominalTarget; }
    verification verifyDurationLarge : MissionDurationByAnalysis { subject :>> tug = argent; in :>> target = largeTarget; }
}
