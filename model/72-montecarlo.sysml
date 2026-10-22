// Dispersion analyses over the target-uncertainty table and the other spread inputs of the
// return: each is an analysis case whose uncertain inputs are case parameters, so a run of
// `-sweep <input>=<low>..<high> -samples <n> -seed <s>` draws the input, evaluates the case
// and the objective's verdict per draw, and the out-of-spec count is the verdict column.
// Standard SysML v2 has no Monte Carlo construct of its own; the drawing is the tool's
// (uniform over the range) and the analysis stays standard. OpenSysML's own Monte Carlo
// library form of these cases, with weighted and distributed draws, is the tool-tier file
// model/74-analyses-tooling.sysml.
package TethysMonteCarlo {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import RealFunctions::*;
    private import TethysEnvironment::*;
    private import TethysTug::*;
    private import TethysAnalyses::*;
    private import TethysTarget::targetCases;
    private import TethysMission::transferBook;
    private import TethysInspector::wren;
    private import TethysBudgets::massBudget;
    private import TethysBudgets::propellantBudget;
    private import TethysMarginPolicy::activePolicy;

    // ---- Return against the target mass ------------------------------------------------------

    analysis def ReturnDispersion {
        doc /* The return Δv and thrusting time of LowThrustTransferAnalysis with the target mass
             * as a drawn input instead of a design case: the dispersion that sizes the xenon
             * reserve and bounds the capturable body. */
        subject tug : Tug;
        in attribute bodyMassKg : Real default = targetCases.nominal.mass / 1 [kg];
        in attribute outboundDeltaVMPerS : Real default = transferBook.deltaVOutbound / 1 ['m/s'];
        in attribute rendezvousDeltaVMPerS : Real default = transferBook.deltaVRendezvous / 1 ['m/s'];
        in attribute requiredReturnDeltaVMPerS : Real default = transferBook.deltaVRequiredReturn / 1 ['m/s'];
        in attribute missedThrustMargin : Real default = transferBook.missedThrustMargin;
        in attribute thrustDayAllowance : Real default = transferBook.thrustingTimeAllowed / 1 [d];
        in attribute thrustN : Real default = propellantBudget.thrustAtAphelion;

        attribute ispS : Real = tug.sep.specificImpulse / 1 [s];
        attribute massFlowKgPerS : Real = MassFlowRate(thrustN, ispS);
        attribute startMassKg : Real = (massBudget.launchMass - massBudget.adapterSeparated) / 1 [kg];
        attribute outboundXenonKg : Real = PropellantForDeltaV(outboundDeltaVMPerS, startMassKg, ispS);
        attribute rendezvousXenonKg : Real = PropellantForDeltaV(rendezvousDeltaVMPerS, startMassKg - outboundXenonKg, ispS);
        attribute returnXenonKg : Real =
            propellantBudget.usable / 1 [kg] / ((1.0 + activePolicy.systemMargin) * (1.0 + missedThrustMargin)) - outboundXenonKg - rendezvousXenonKg;
        attribute stackMassKg : Real = startMassKg - outboundXenonKg - rendezvousXenonKg - wren.wetMass / 1 [kg] + bodyMassKg;
        return returnDeltaVMPerS : Real = RocketEquationDeltaV(ispS, stackMassKg, stackMassKg - returnXenonKg);
        out totalThrustDays : Real = ThrustDays(
            (outboundXenonKg + rendezvousXenonKg + PropellantForDeltaV(requiredReturnDeltaVMPerS, stackMassKg, ispS)) * (1.0 + missedThrustMargin),
            massFlowKgPerS);

        objective canReturn : ReturnCapability {
            doc /* The return capability this case must show. */
            subject :>> tug = tug;
            in returnDeltaVMPerS = returnDeltaVMPerS;
            in requiredReturnDeltaVMPerS = requiredReturnDeltaVMPerS;
            in totalThrustDays = totalThrustDays;
            in thrustDayAllowance = thrustDayAllowance;
        }
    }
    analysis returnDispersion : ReturnDispersion {
        doc /* Run as `-sweep "bodyMassKg=215000.0..644000.0" -samples 200 -seed 7`: the small to
             * large case range; the rows whose objective is not satisfied are the masses the
             * baseline xenon cannot bring home. */
        subject :>> tug = argent;
    }

    // ---- Capture against size, density and spin ----------------------------------------------

    analysis def CaptureDispersion {
        doc /* CaptureDynamicsAnalysis with the body's diameter, bulk density and rotation period
             * drawn: the mass follows from SphereMass, and the envelope verdict counts the draws
             * the capture system cannot take. */
        subject tug : Tug;
        in attribute diameterM : Real default = amaranth.meanDiameter / 1 [m];
        in attribute densityKgPerM3 : Real default = amaranth.bulkDensity / 1 ['kg⋅m⁻³'];
        in attribute rotationPeriodS : Real default = amaranth.rotationPeriod / 1 [s];
        in attribute rcsThrusterForceN : Real default = 22.0;
        in attribute leverArmM : Real default = 3.0;
        in attribute rcsSpecificImpulseS : Real default = 220.0;

        attribute massKg : Real = SphereMass(diameterM, densityKgPerM3);
        attribute angularRateRadPerS : Real = 2.0 * pi / rotationPeriodS;
        attribute surfaceSpeedMPerS : Real = angularRateRadPerS * diameterM / 2.0;
        return angularMomentumNMS : Real = 0.4 * massKg * (diameterM / 2.0) ** 2 * angularRateRadPerS;
        attribute despinTimeS : Real = angularMomentumNMS / (2.0 * rcsThrusterForceN * leverArmM);
        out despinHydrazineKg : Real = 2.0 * rcsThrusterForceN * despinTimeS / (rcsSpecificImpulseS * standardGravityMPerS2);

        objective fitsEnvelope : CaptureEnvelope {
            doc /* The capture envelope this case checks the target against. */
            subject :>> tug = tug;
            in bodyDiameterM = diameterM;
            in bodyMassKg = massKg;
            in surfaceSpeedMPerS = surfaceSpeedMPerS;
            in despinHydrazineKg = despinHydrazineKg;
            in maximumSurfaceSpeedMPerS = 0.10;
            in despinHydrazineAllocationKg = 40.0;
        }
    }
    analysis captureDispersion : CaptureDispersion {
        doc /* Run as `-sweep "diameterM=5.4..8.2" -sweep "rotationPeriodS=120.0..600.0" -samples
             * 200 -seed 7`: the pre-arrival size range against the plausible spin range. */
        subject :>> tug = argent;
    }

    // ---- Missed thrust ---------------------------------------------------------------------

    requirement def DurationMargin {
        doc /* The mission duration, with the unplanned coast of safe-mode recoveries added to the
             * thrust arcs, shall stay within the nominal duration. */
        subject tug : Tug;
        in attribute missionDays : Real;
        in attribute nominalDurationDays : Real;
        require constraint { missionDays <= nominalDurationDays }
    }

    analysis def MissedThrustDispersion {
        doc /* Unplanned coast: every safe-mode entry costs a coast of a few days plus a recovery of
             * the thrust arc, and the days are added to the mission; the dispersion shows how many
             * safe-mode events of what length the duration margin absorbs. */
        subject tug : Tug;
        in attribute coastDaysPerEvent : Real default = 7.0;
        in attribute safeModeEvents : Real default = 2.0;
        in attribute recoveryDaysPerEvent : Real default = 3.0;
        in attribute thrustDays : Real default = propellantBudget.thrustingTimeNominal / 1 [d] {
            doc /* The nominal case's thrusting time from the propellant budget. */
        }
        in attribute nonThrustDays : Real default = 270.0;
        return missionDays : Real = thrustDays + nonThrustDays + safeModeEvents * (coastDaysPerEvent + recoveryDaysPerEvent);
        objective fitsDuration : DurationMargin {
            doc /* The duration margin the drawn coasts are checked against. */
            subject :>> tug = tug;
            in missionDays = missionDays;
            in nominalDurationDays = TethysMission::tethys.nominalDuration / 1 [d];
        }
    }
    analysis missedThrustDispersion : MissedThrustDispersion {
        doc /* Run as `-sweep "coastDaysPerEvent=2.0..30.0" -sweep "safeModeEvents=0.0..12.0"
             * -samples 200 -seed 7`. */
        subject :>> tug = argent;
    }

    // ---- Lunar gravity assist and insertion ------------------------------------------------

    calc def FlybyDeltaV {
        doc /* Δv in km/s a powered-free flyby of a body with GM (km³/s²) gives at periapsis radius
             * r (km) and hyperbolic excess speed v∞ (km/s): 2 v∞ sin(δ/2), sin(δ/2) = 1/(1 + r
             * v∞²/GM). */
        in gm : Real;
        in periapsisKm : Real;
        in vInfinityKmPerS : Real;
        return deltaVKmPerS : Real = 2.0 * vInfinityKmPerS / (1.0 + periapsisKm * vInfinityKmPerS ** 2 / gm);
    }

    requirement def InsertionReserve {
        doc /* The xenon reserve shall cover the insertion Δv the lunar flyby leaves to the tug,
             * with the insertion error added. */
        subject tug : Tug;
        in attribute insertionDeltaVMPerS : Real;
        in attribute reserveDeltaVMPerS : Real;
        require constraint { insertionDeltaVMPerS <= reserveDeltaVMPerS }
    }

    analysis def InsertionDispersion {
        doc /* The return's end game with the Earth-approach v∞ and the insertion error drawn,
             * in the co-linear idealisation: the stack arrives at the Moon's distance at the
             * speed its v∞ gives, the lunar gravity assist takes the turn its periapsis allows
             * off that speed, and the tug's xenon reserve on the stack must pay whatever is left
             * above the local escape speed, the orbit shaping and the error. */
        subject tug : Tug;
        in attribute vInfinityKmPerS : Real default = 0.8;
        in attribute insertionErrorMPerS : Real default = 5.0;
        in attribute periapsisAltitudeKm : Real default = 100.0;
        in attribute shapingDeltaVMPerS : Real default = 10.0;
        in attribute stackMassKg : Real default = 364000.0;
        in attribute xenonReserveKg : Real default = PropellantForDeltaV(transferBook.deltaVInsertion / 1 ['m/s'], stackMassKg, tug.sep.specificImpulse / 1 [s]) {
            doc /* The insertion allocation of the transfer book, as xenon on the stack. */
        }
        attribute lunarDistanceKm : Real = lunarOrbit.semiMajorAxis / 1 [km];
        attribute moonSpeedKmPerS : Real = CircularSpeed(earth.gravitationalParameterKm3PerS2, lunarDistanceKm);
        attribute escapeAtMoonKmPerS : Real = EscapeSpeed(earth.gravitationalParameterKm3PerS2, lunarDistanceKm);
        attribute approachSpeedKmPerS : Real = sqrt(vInfinityKmPerS ** 2 + escapeAtMoonKmPerS ** 2);
        attribute moonRelativeKmPerS : Real = approachSpeedKmPerS - moonSpeedKmPerS;
        attribute flybyDeltaVKmPerS : Real =
            FlybyDeltaV(moon.gravitationalParameterKm3PerS2, moon.equatorialRadius / 1 [km] + periapsisAltitudeKm, moonRelativeKmPerS);
        attribute unboundKmPerS : Real = max(approachSpeedKmPerS - flybyDeltaVKmPerS - escapeAtMoonKmPerS, 0.0);
        return insertionDeltaVMPerS : Real = 1000.0 * unboundKmPerS + shapingDeltaVMPerS + insertionErrorMPerS;
        out reserveDeltaVMPerS : Real =
            RocketEquationDeltaV(tug.sep.specificImpulse / 1 [s], stackMassKg, stackMassKg - xenonReserveKg);
        objective reserveCovers : InsertionReserve {
            doc /* The insertion reserve the drawn end game is checked against. */
            subject :>> tug = tug;
            in insertionDeltaVMPerS = insertionDeltaVMPerS;
            in reserveDeltaVMPerS = reserveDeltaVMPerS;
        }
    }
    analysis insertionDispersion : InsertionDispersion {
        doc /* Run as `-sweep "vInfinityKmPerS=0.5..1.0" -sweep "insertionErrorMPerS=0.0..20.0"
             * -samples 200 -seed 7`. */
        subject :>> tug = argent;
    }
}
