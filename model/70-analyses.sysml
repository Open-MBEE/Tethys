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
    private import TethysTarget::targetCases;
    private import TethysMission::tethys;
    private import TethysMission::transferBook;
    private import TethysInspector::wren;
    private import TethysBudgets::massBudget;
    private import TethysBudgets::propellantBudget;
    private import TethysRequirements::*;
    private import TethysRequirementsL2::transferDuration;
    private import TethysMarginPolicy::activePolicy;

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
    // body is not executable in OpenSysML, findings F-F03).
    metadata CredibilityAssessment about LowThrustTransferAnalysis { verificationFactor = 3; validation = 1; inputPedigree = 2; resultsUncertainty = 2; resultsRobustness = 2; useHistory = 1; managementProcess = 2; peopleQualification = 3; }
    metadata CredibilityAssessment about CaptureDynamicsAnalysis { verificationFactor = 3; validation = 1; inputPedigree = 2; resultsUncertainty = 2; resultsRobustness = 1; useHistory = 0; managementProcess = 2; peopleQualification = 3; }
    metadata CredibilityAssessment about ExternalTransferAnalysis { verificationFactor = 2; validation = 2; inputPedigree = 2; resultsUncertainty = 1; resultsRobustness = 2; useHistory = 1; managementProcess = 2; peopleQualification = 3; }

    // ---- Target cases ------------------------------------------------------------------------
    // The analyses run over the design cases of the one target-case table,
    // TethysTarget::targetCases; `TargetCase` is its variation under the name the analysis
    // configurations select by (`part :>> target = TargetCase::large`).
    alias TargetCase for TethysTarget::CaptureTargetCase;

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
        in attribute returnDeltaV : SpeedValue;
        in attribute requiredReturnDeltaV : SpeedValue;
        in attribute totalThrustTime : DurationValue;
        in attribute thrustTimeAllowance : DurationValue;
        require constraint { returnDeltaV >= requiredReturnDeltaV }
        require constraint { totalThrustTime <= thrustTimeAllowance }
    }

    analysis def LowThrustTransferAnalysis {
        doc /* First-order solar-electric transfer and return: the thrust and mass flow the SEP
             * system produces at full power, the xenon and thrusting time the outbound Δv costs,
             * and what the remaining xenon buys as Δv on the tug–body stack and how long it takes
             * to spend. The target case is the input the mission is most sensitive to. */
        subject tug : Tug;
        in part target : SmallBody;
        in attribute outboundDeltaVMPerS : Real default = transferBook.deltaVOutbound / 1 ['m/s'] {
            doc /* The outbound allocation of the transfer book (TethysMission::transferBook) in
                 * m/s; the Edelbaum circular-coplanar estimate of about 0.7 km/s for 1 → 1.034 AU
                 * with the plane change and phasing sits well inside it. A plain Real, not a
                 * SpeedValue, because the sweep runner writes bare numbers to the parameter it
                 * sweeps (finding F-F08). */
        }
        in attribute rendezvousDeltaV : SpeedValue default = transferBook.deltaVRendezvous {
            doc /* Approach, station-keeping and capture manoeuvres, from the transfer book. */
        }
        in attribute requiredReturnDeltaV : SpeedValue default = transferBook.deltaVRequiredReturn {
            doc /* Return leg to the lunar gravity assist plus the distant-retrograde-orbit
                 * insertion: the book's return and insertion allocations together. */
        }
        in attribute missedThrustMargin : Real default = transferBook.missedThrustMargin {
            doc /* Unplanned-coast allowance held back on every arc, from the transfer book. */
        }
        in attribute systemMargin : Real default = activePolicy.systemMargin {
            doc /* The system margin of the active margin policy, held back from the usable xenon
                 * exactly as TethysBudgets::propellantBudget closes it, so this book and the
                 * budget agree on which bodies return. */
        }
        in attribute thrustTimeAllowance : DurationValue default = transferBook.thrustingTimeAllowed {
            doc /* Thrusting time the timeline allows, from the transfer book. */
        }
        in attribute thrust : ForceValue default = propellantBudget.thrustAtAphelion {
            doc /* Thrust at the target's aphelion from the propellant budget's SEP string model:
                 * array power less the bus, through the PPUs, at the budget's thruster efficiency. */
        }

        attribute ispS : Real = tug.sep.specificImpulse / 1 [s] {
            doc /* The specific impulse in seconds for the Real-valued rocket-equation helpers. */
        }
        attribute massFlow : MassFlowRateValue = MassFlowRate(thrust / 1 [N], ispS) ['kg⋅s⁻¹'];
        attribute startMass : MassValue = massBudget.launchMass - massBudget.adapterSeparated;
        attribute usableXenon : MassValue = propellantBudget.usable;
        attribute outboundXenon : MassValue =
            PropellantForDeltaV(outboundDeltaVMPerS, startMass / 1 [kg], ispS) [kg];
        attribute rendezvousXenon : MassValue =
            PropellantForDeltaV(rendezvousDeltaV / 1 ['m/s'], (startMass - outboundXenon) / 1 [kg], ispS) [kg];
        attribute returnXenon : MassValue =
            usableXenon / ((1.0 + systemMargin) * (1.0 + missedThrustMargin)) - outboundXenon - rendezvousXenon {
            doc /* Xenon the stack may spend coming home: the usable load less the policy's system
                 * margin, the missed-thrust allowance and the two arcs flown alone. */
        }
        attribute stackMass : MassValue = startMass - outboundXenon - rendezvousXenon - wren.wetMass + target.mass;
        return returnDeltaV : SpeedValue =
            RocketEquationDeltaV(ispS, stackMass / 1 [kg], (stackMass - returnXenon) / 1 [kg]) ['m/s'];
        out outboundThrustTime : DurationValue = ThrustDays(
            ((outboundXenon + rendezvousXenon) / 1 [kg]) * (1.0 + missedThrustMargin), massFlow / 1 ['kg⋅s⁻¹']) [d];
        out returnThrustTime : DurationValue = ThrustDays(
            PropellantForDeltaV(requiredReturnDeltaV / 1 ['m/s'], stackMass / 1 [kg], ispS) * (1.0 + missedThrustMargin),
            massFlow / 1 ['kg⋅s⁻¹']) [d];
        out totalThrustTime : DurationValue = outboundThrustTime + returnThrustTime;

        objective canReturn : ReturnCapability {
            doc /* The return capability this case must show. */
            subject :>> tug = tug;
            in returnDeltaV = returnDeltaV;
            in requiredReturnDeltaV = requiredReturnDeltaV;
            in totalThrustTime = totalThrustTime;
            in thrustTimeAllowance = thrustTimeAllowance;
        }
    }

    analysis transferNominal : LowThrustTransferAnalysis {
        doc /* Argent against the nominal target. */
        subject :>> tug = argent;
        in :>> target = targetCases.nominal;
    }
    analysis transferSmall : LowThrustTransferAnalysis { subject :>> tug = argent; in :>> target = targetCases.small; }
    analysis transferLarge : LowThrustTransferAnalysis { subject :>> tug = argent; in :>> target = targetCases.large; }
    analysis transferDensest : LowThrustTransferAnalysis {
        doc /* Argent against the densest knowledge bound (576 t): over the return envelope with
             * the margin policy, which is why the commit gate refuses it. */
        subject :>> tug = argent;
        in :>> target = targetCases.densest;
    }

    // ---- Capture and despin ------------------------------------------------------------------

    requirement def CaptureEnvelope {
        doc /* The target shall fit the capture system: within its diameter and mass limits,
             * with an equatorial surface speed the bag can absorb, and with a despin that the
             * hydrazine allocated to it can pay for. */
        subject tug : Tug;
        in attribute bodyDiameter : LengthValue;
        in attribute bodyMass : MassValue;
        in attribute surfaceSpeed : SpeedValue;
        in attribute despinHydrazine : MassValue;
        in attribute maximumSurfaceSpeed : SpeedValue;
        in attribute despinHydrazineAllocation : MassValue;
        require constraint { bodyDiameter <= tug.captureSystem.maximumBodyDiameter }
        require constraint { bodyMass <= tug.captureSystem.maximumBodyMass }
        require constraint { surfaceSpeed <= maximumSurfaceSpeed }
        require constraint { despinHydrazine <= despinHydrazineAllocation }
    }

    analysis def CaptureDynamicsAnalysis {
        doc /* Rigid-body capture and despin of a spherical target: equatorial surface speed at
             * contact, moment of inertia and angular momentum, the torque a pair of hydrazine
             * thrusters on the tug's lever arm applies through the bag, and the time and
             * propellant the despin takes. */
        subject tug : Tug;
        in part target : SmallBody;
        in attribute rcsThrusterForce : ForceValue default = 22.0 [N];
        in attribute rcsThrusterCount : Natural default = 2;
        in attribute leverArm : LengthValue default = 3.0 [m];
        in attribute rcsSpecificImpulse : DurationValue default = 220.0 [s];
        in attribute maximumSurfaceSpeed : SpeedValue default = 0.10 ['m/s'];
        in attribute despinHydrazineAllocation : MassValue default = 40.0 [kg];

        attribute diameterM : Real = target.meanDiameter / 1 [m];
        attribute angularRate : AngularVelocityValue =
            (2.0 * pi / (target.rotationPeriod / 1 [s])) ['rad⋅s⁻¹'];
        attribute surfaceSpeed : SpeedValue = ((angularRate / 1 ['rad⋅s⁻¹']) * diameterM / 2.0) ['m/s'];
        attribute momentOfInertia : MomentOfInertiaValue =
            (0.4 * (target.mass / 1 [kg]) * (diameterM / 2.0) ** 2) ['kg⋅m²'];
        return angularMomentum : AngularMomentumValue =
            ((momentOfInertia / 1 ['kg⋅m²']) * (angularRate / 1 ['rad⋅s⁻¹'])) ['N⋅m⋅s'];
        attribute despinTorque : TorqueValue =
            ((rcsThrusterForce / 1 [N]) * rcsThrusterCount * (leverArm / 1 [m])) ['N⋅m'];
        out despinTime : DurationValue = ((angularMomentum / 1 ['N⋅m⋅s']) / (despinTorque / 1 ['N⋅m'])) [s];
        out despinHydrazine : MassValue =
            ((rcsThrusterForce / 1 [N]) * rcsThrusterCount * (despinTime / 1 [s])
                / ((rcsSpecificImpulse / 1 [s]) * standardGravityMPerS2)) [kg];

        objective fitsEnvelope : CaptureEnvelope {
            doc /* The capture envelope this case checks the target against. */
            subject :>> tug = tug;
            in bodyDiameter = target.meanDiameter;
            in bodyMass = target.mass;
            in surfaceSpeed = surfaceSpeed;
            in despinHydrazine = despinHydrazine;
            in maximumSurfaceSpeed = maximumSurfaceSpeed;
            in despinHydrazineAllocation = despinHydrazineAllocation;
        }
    }

    analysis captureNominal : CaptureDynamicsAnalysis { subject :>> tug = argent; in :>> target = targetCases.nominal; }
    analysis captureLarge : CaptureDynamicsAnalysis { subject :>> tug = argent; in :>> target = targetCases.large; }
    analysis captureFastSpin : CaptureDynamicsAnalysis { subject :>> tug = argent; in :>> target = targetCases.fastSpin; }

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
        in attribute thrustTime : DurationValue;
        in attribute allowance : DurationValue;
        require constraint { thrustTime <= allowance }
    }

    analysis def ExternalTransferAnalysis {
        doc /* The outbound transfer handed to ThrustArcSolver: the tool receives the orbit radii,
             * plane change, mass, thrust and Isp from the model and answers the Δv, xenon and
             * thrusting days; the objective checks the days against the outbound allowance. */
        subject tug : Tug;
        in attribute thrusterEfficiency : Real default = 0.65;
        in attribute outboundAllowance : DurationValue default = 260.0 [d];
        action solve : SolveThrustArc {
            in startAu = 1.0;
            in endAu = amaranth.orbit.semiMajorAxisAu;
            in planeChangeDeg = amaranth.orbit.inclination / 1 ['°'];
            in initialMassKg = tug.wetMass / 1 [kg];
            in thrustN = SepThrust(tug.sep.maximumPower / 1 [W], tug.sep.specificImpulse / 1 [s], thrusterEfficiency);
            in specificImpulseS = tug.sep.specificImpulse / 1 [s];
        }
        return thrustTime : DurationValue = solve.thrustDays [d];
        out deltaV : SpeedValue = solve.deltaVMPerS ['m/s'];
        out propellant : MassValue = solve.propellantKg [kg];
        objective fitsAllowance : TransferAllowance {
            doc /* The outbound thrust-arc allowance the tool result is checked against. */
            subject :>> tug = tug;
            in thrustTime = thrustTime;
            in allowance = outboundAllowance;
        }
    }

    analysis externalTransfer : ExternalTransferAnalysis { subject :>> tug = argent; }

    // ---- Requirement closed by analysis ------------------------------------------------------

    verification def MissionDurationByAnalysis {
        doc /* TR-002 and TS-003 verified by analysis: the thrusting time of the transfer and
             * return plus the non-thrusting phases must fit the nominal duration. */
        subject tug : Tug;
        in part target : SmallBody;
        in attribute nonThrustDays : Real default = 270.0;
        objective durationObjective {
            doc /* The mission duration requirement this case verifies. */
            verify missionDuration {
                doc /* TR-002 as verified here. */
            }
            verify transferDuration {
                doc /* TS-003: the planned timeline against the nominal duration. */
            }
        }
        analysis transfer : LowThrustTransferAnalysis {
            subject :>> tug = tug;
            in :>> target = target;
        }
        return verdict : VerdictKind =
            PassIf(transfer.totalThrustTime / 1 [d] + nonThrustDays <= tethys.nominalDuration / 1 [d]);
    }

    verification verifyDurationNominal : MissionDurationByAnalysis { subject :>> tug = argent; in :>> target = targetCases.nominal; }
    verification verifyDurationLarge : MissionDurationByAnalysis { subject :>> tug = argent; in :>> target = targetCases.large; }
}
