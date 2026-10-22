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
        in attribute bodyMassKg : Real default = targetCases.nominal.mass / 1 [kg] {
            doc /* The drawn target mass in kg: a plain Real, not a MassValue, because the sampler
                 * and the sweep runner write bare numbers to the parameter they draw
                 * (finding F-F08). */
        }
        in attribute outboundDeltaV : SpeedValue default = transferBook.deltaVOutbound;
        in attribute rendezvousDeltaV : SpeedValue default = transferBook.deltaVRendezvous;
        in attribute requiredReturnDeltaV : SpeedValue default = transferBook.deltaVRequiredReturn;
        in attribute missedThrustMargin : Real default = transferBook.missedThrustMargin;
        in attribute thrustTimeAllowance : DurationValue default = transferBook.thrustingTimeAllowed;
        in attribute thrust : ForceValue default = propellantBudget.thrustAtAphelion;

        attribute ispS : Real = tug.sep.specificImpulse / 1 [s];
        attribute massFlow : MassFlowRateValue = MassFlowRate(thrust / 1 [N], ispS) ['kg⋅s⁻¹'];
        attribute startMass : MassValue = massBudget.launchMass - massBudget.adapterSeparated;
        attribute outboundXenon : MassValue =
            PropellantForDeltaV(outboundDeltaV / 1 ['m/s'], startMass / 1 [kg], ispS) [kg];
        attribute rendezvousXenon : MassValue =
            PropellantForDeltaV(rendezvousDeltaV / 1 ['m/s'], (startMass - outboundXenon) / 1 [kg], ispS) [kg];
        attribute returnXenon : MassValue =
            propellantBudget.usable / ((1.0 + activePolicy.systemMargin) * (1.0 + missedThrustMargin))
            - outboundXenon - rendezvousXenon;
        attribute stackMass : MassValue =
            startMass - outboundXenon - rendezvousXenon - wren.wetMass + bodyMassKg [kg];
        return returnDeltaV : SpeedValue =
            RocketEquationDeltaV(ispS, stackMass / 1 [kg], (stackMass - returnXenon) / 1 [kg]) ['m/s'];
        out totalThrustTime : DurationValue = ThrustDays(
            ((outboundXenon + rendezvousXenon) / 1 [kg]
                + PropellantForDeltaV(requiredReturnDeltaV / 1 ['m/s'], stackMass / 1 [kg], ispS))
                * (1.0 + missedThrustMargin),
            massFlow / 1 ['kg⋅s⁻¹']) [d];

        objective canReturn : ReturnCapability {
            doc /* The return capability this case must show. */
            subject :>> tug = tug;
            in returnDeltaV = returnDeltaV;
            in requiredReturnDeltaV = requiredReturnDeltaV;
            in totalThrustTime = totalThrustTime;
            in thrustTimeAllowance = thrustTimeAllowance;
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
        in attribute diameterM : Real default = amaranth.meanDiameter / 1 [m] {
            doc /* The drawn diameter in m and the drawn rotation period in s are plain Reals, not
                 * LengthValue and DurationValue, because the sampler writes bare numbers to the
                 * parameters it draws (finding F-F08). */
        }
        in attribute density : MassDensityValue default = amaranth.bulkDensity;
        in attribute rotationPeriodS : Real default = amaranth.rotationPeriod / 1 [s];
        in attribute rcsThrusterForce : ForceValue default = 22.0 [N];
        in attribute leverArm : LengthValue default = 3.0 [m];
        in attribute rcsSpecificImpulse : DurationValue default = 220.0 [s];

        attribute mass : MassValue = SphereMass(diameterM, density / 1 ['kg⋅m⁻³']) [kg];
        attribute angularRate : AngularVelocityValue = (2.0 * pi / rotationPeriodS) ['rad⋅s⁻¹'];
        attribute surfaceSpeed : SpeedValue = ((angularRate / 1 ['rad⋅s⁻¹']) * diameterM / 2.0) ['m/s'];
        return angularMomentum : AngularMomentumValue =
            (0.4 * (mass / 1 [kg]) * (diameterM / 2.0) ** 2 * (angularRate / 1 ['rad⋅s⁻¹'])) ['N⋅m⋅s'];
        attribute despinTime : DurationValue =
            ((angularMomentum / 1 ['N⋅m⋅s']) / (2.0 * (rcsThrusterForce / 1 [N]) * (leverArm / 1 [m]))) [s];
        out despinHydrazine : MassValue =
            (2.0 * (rcsThrusterForce / 1 [N]) * (despinTime / 1 [s])
                / ((rcsSpecificImpulse / 1 [s]) * standardGravityMPerS2)) [kg];

        objective fitsEnvelope : CaptureEnvelope {
            doc /* The capture envelope this case checks the target against. */
            subject :>> tug = tug;
            in bodyDiameter = diameterM [m];
            in bodyMass = mass;
            in surfaceSpeed = surfaceSpeed;
            in despinHydrazine = despinHydrazine;
            in maximumSurfaceSpeed = 0.10 ['m/s'];
            in despinHydrazineAllocation = 40.0 [kg];
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
        in attribute missionTime : DurationValue;
        in attribute nominalDuration : DurationValue;
        require constraint { missionTime <= nominalDuration }
    }

    analysis def MissedThrustDispersion {
        doc /* Unplanned coast: every safe-mode entry costs a coast of a few days plus a recovery of
             * the thrust arc, and the days are added to the mission; the dispersion shows how many
             * safe-mode events of what length the duration margin absorbs. */
        subject tug : Tug;
        in attribute coastDaysPerEvent : Real default = 7.0 {
            doc /* The drawn coast in days per event and the drawn event count are plain Reals
                 * because the sampler writes bare numbers to the parameters it draws (finding
                 * F-F08). */
        }
        in attribute safeModeEvents : Real default = 2.0;
        in attribute recoveryPerEvent : DurationValue default = 3.0 [d];
        in attribute thrustTime : DurationValue default = propellantBudget.thrustingTimeNominal {
            doc /* The nominal case's thrusting time from the propellant budget. */
        }
        in attribute nonThrustTime : DurationValue default = 270.0 [d];
        return missionTime : DurationValue =
            thrustTime + nonThrustTime + safeModeEvents * (coastDaysPerEvent [d] + recoveryPerEvent);
        objective fitsDuration : DurationMargin {
            doc /* The duration margin the drawn coasts are checked against. */
            subject :>> tug = tug;
            in missionTime = missionTime;
            in nominalDuration = TethysMission::tethys.nominalDuration;
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
        in attribute insertionDeltaV : SpeedValue;
        in attribute reserveDeltaV : SpeedValue;
        require constraint { insertionDeltaV <= reserveDeltaV }
    }

    analysis def InsertionDispersion {
        doc /* The return's end game with the Earth-approach v∞ and the insertion error drawn,
             * in the co-linear idealisation: the stack arrives at the Moon's distance at the
             * speed its v∞ gives, the lunar gravity assist takes the turn its periapsis allows
             * off that speed, and the tug's xenon reserve on the stack must pay whatever is left
             * above the local escape speed, the orbit shaping and the error. */
        subject tug : Tug;
        in attribute vInfinityKmPerS : Real default = 0.8 {
            doc /* The drawn v∞ in km/s and the drawn insertion error in m/s are plain Reals
                 * because the sampler writes bare numbers to the parameters it draws (finding
                 * F-F08). */
        }
        in attribute insertionErrorMPerS : Real default = 5.0;
        in attribute periapsisAltitude : LengthValue default = 100.0 [km];
        in attribute shapingDeltaV : SpeedValue default = 10.0 ['m/s'];
        in attribute stackMass : MassValue default = 364000.0 [kg];
        in attribute xenonReserve : MassValue default = (PropellantForDeltaV(transferBook.deltaVInsertion / 1 ['m/s'], stackMass / 1 [kg], tug.sep.specificImpulse / 1 [s])) [kg] {
            doc /* The insertion allocation of the transfer book, as xenon on the stack. */
        }
        attribute lunarDistanceKm : Real = lunarOrbit.semiMajorAxis / 1 [km];
        attribute moonSpeedKmPerS : Real = CircularSpeed(earth.gravitationalParameterKm3PerS2, lunarDistanceKm);
        attribute escapeAtMoonKmPerS : Real = EscapeSpeed(earth.gravitationalParameterKm3PerS2, lunarDistanceKm);
        attribute approachSpeedKmPerS : Real = sqrt(vInfinityKmPerS ** 2 + escapeAtMoonKmPerS ** 2);
        attribute moonRelativeKmPerS : Real = approachSpeedKmPerS - moonSpeedKmPerS;
        attribute flybyDeltaVKmPerS : Real =
            FlybyDeltaV(moon.gravitationalParameterKm3PerS2, moon.equatorialRadius / 1 [km] + periapsisAltitude / 1 [km], moonRelativeKmPerS);
        attribute unboundKmPerS : Real = max(approachSpeedKmPerS - flybyDeltaVKmPerS - escapeAtMoonKmPerS, 0.0);
        return insertionDeltaV : SpeedValue =
            (1000.0 * unboundKmPerS + shapingDeltaV / 1 ['m/s'] + insertionErrorMPerS) ['m/s'];
        out reserveDeltaV : SpeedValue = RocketEquationDeltaV(tug.sep.specificImpulse / 1 [s],
            stackMass / 1 [kg], (stackMass - xenonReserve) / 1 [kg]) ['m/s'];
        objective reserveCovers : InsertionReserve {
            doc /* The insertion reserve the drawn end game is checked against. */
            subject :>> tug = tug;
            in insertionDeltaV = insertionDeltaV;
            in reserveDeltaV = reserveDeltaV;
        }
    }
    analysis insertionDispersion : InsertionDispersion {
        doc /* Run as `-sweep "vInfinityKmPerS=0.5..1.0" -sweep "insertionErrorMPerS=0.0..20.0"
             * -samples 200 -seed 7`. */
        subject :>> tug = argent;
    }
}
