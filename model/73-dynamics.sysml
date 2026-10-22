// Sampled functions and state-space dynamics: the array degradation and solar-flux tables with
// the standard-SysML interpolation that reads them, the array-power analysis they feed, the
// circular restricted three-body model of the distant retrograde orbit, the heliocentric
// thrust-and-coast model of a transfer arc, the discrete despin model, and the DRO stability
// analysis. Integration is the fourth-order Runge–Kutta step written here against
// StateSpaceRepresentation::Integrate; model/probes/F-F01-state-space-integrator.sysml binds
// OpenSysML's own integrator to the same dynamics.
package TethysDynamics {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import RealFunctions::*;
    private import SequenceFunctions::*;
    private import ControlFunctions::*;
    private import VectorFunctions::*;
    private import SampledFunctions::*;
    private import StateSpaceRepresentation::*;
    private import TethysEnvironment::*;
    private import TethysTug::*;
    private import TethysAnalyses::*;
    private import TethysTarget::targetCases;

    // ---- Sampled functions -------------------------------------------------------------------

    calc def LinearInterpolation {
        doc /* The range value of a sampled function at x by linear interpolation between the two
             * samples that bracket x; outside the sampled domain the nearer end value is held.
             * Written against SampledFunction because the library's interpolateLinear computes
             * a wrong value (findings F-002). */
        in fn : SampledFunction;
        in x : Real;
        private attribute xs : Real[1..*] ordered = fn.samples.domainValue;
        private attribute ys : Real[1..*] ordered = fn.samples.rangeValue;
        private attribute n : Positive = size(xs);
        private attribute i : Positive =
            if x <= xs#(1) ? 1
            else if x >= xs#(n) ? n - 1
            else (1..n - 1)->select { in k : Positive; xs#(k) <= x and x < xs#(k + 1) }#(1);
        private attribute f : Real = RealFunctions::min(max((x - xs#(i)) / (xs#(i + 1) - xs#(i)), 0.0), 1.0);
        return y : Real = ys#(i) + f * (ys#(i + 1) - ys#(i));
    }

    attribute degradation0 : SamplePair { :>> domainValue = 0.0; :>> rangeValue = 1.000; }
    attribute degradation1 : SamplePair { :>> domainValue = 365.0; :>> rangeValue = 0.975; }
    attribute degradation2 : SamplePair { :>> domainValue = 730.0; :>> rangeValue = 0.955; }
    attribute degradation3 : SamplePair { :>> domainValue = 1095.0; :>> rangeValue = 0.940; }
    attribute degradation4 : SamplePair { :>> domainValue = 1460.0; :>> rangeValue = 0.927; }
    attribute degradation5 : SamplePair { :>> domainValue = 1825.0; :>> rangeValue = 0.915; }
    attribute degradation6 : SamplePair { :>> domainValue = 2200.0; :>> rangeValue = 0.905; }
    attribute arrayDegradation : SampledFunction {
        doc /* Array power as a fraction of beginning-of-life power against days since launch:
             * solar-proton fluence, ultraviolet darkening and thermal cycling for a 1 AU
             * interplanetary mission at the cell vendor's lot data (invented table, shaped like
             * a ECSS-E-ST-20-08 end-of-life prediction). */
        :>> samples = (degradation0, degradation1, degradation2, degradation3, degradation4, degradation5, degradation6);
    }

    attribute flux0 : SamplePair { :>> domainValue = 0.96; :>> rangeValue = SolarFlux(0.96); }
    attribute flux1 : SamplePair { :>> domainValue = 1.00; :>> rangeValue = SolarFlux(1.00); }
    attribute flux2 : SamplePair { :>> domainValue = 1.04; :>> rangeValue = SolarFlux(1.04); }
    attribute flux3 : SamplePair { :>> domainValue = 1.08; :>> rangeValue = SolarFlux(1.08); }
    attribute flux4 : SamplePair { :>> domainValue = 1.12; :>> rangeValue = SolarFlux(1.12); }
    attribute flux5 : SamplePair { :>> domainValue = 1.16; :>> rangeValue = SolarFlux(1.16); }
    attribute solarFluxTable : SampledFunction {
        doc /* Solar flux in W/m² tabulated over the mission's heliocentric range in 0.04 AU
             * steps from the SolarFlux calc, the tabulated form the power subsystem's tools
             * exchange. */
        :>> samples = (flux0, flux1, flux2, flux3, flux4, flux5);
    }

    calc def ArrayDegradationAt {
        doc /* Power fraction remaining at a mission day, from the arrayDegradation table. */
        in missionDay : Real;
        return fraction : Real = LinearInterpolation(arrayDegradation, missionDay);
    }
    calc def SolarFluxFromTable {
        doc /* Solar flux in W/m² at a heliocentric distance in AU, from the solarFluxTable. */
        in distanceAu : Real;
        return flux : Real = LinearInterpolation(solarFluxTable, distanceAu);
    }

    // ---- Array power over the mission --------------------------------------------------------

    requirement def PowerForThrust {
        doc /* At every point of the mission the degraded array shall deliver at least the
             * propulsion system's lowest useful operating power plus the housekeeping load. */
        subject tug : Tug;
        in attribute availableSepPowerW : Real;
        in attribute minimumSepPowerW : Real;
        require constraint { availableSepPowerW >= minimumSepPowerW }
    }

    analysis def ArrayPowerAnalysis {
        doc /* Array power, propulsion power and thrust at a heliocentric distance and a mission
             * day: the 1 AU power scaled by the tabulated flux and the degradation fraction, less
             * housekeeping, capped at the propulsion system's maximum; the thrust that power
             * buys is the trip-time driver of the array trade. */
        subject tug : Tug;
        in attribute distanceAu : Real default = 1.034;
        in attribute missionDay : Real default = 0.0;
        in attribute housekeepingW : Real default = 2000.0;
        in attribute minimumSepPowerW : Real default = 20000.0;
        attribute arrayPowerW : Real =
            tug.eps.arrayPowerAtOneAu / 1 [W] * SolarFluxFromTable(distanceAu) / SolarFlux(1.0) * ArrayDegradationAt(missionDay);
        return availableSepPowerW : Real = RealFunctions::min(arrayPowerW - housekeepingW, tug.sep.maximumPower / 1 [W]);
        out thrustN : Real = SepThrust(availableSepPowerW, tug.sep.specificImpulse / 1 [s], 0.65);
        objective enoughPower : PowerForThrust {
            doc /* The power the degraded array must still deliver. */
            subject :>> tug = tug;
            in availableSepPowerW = availableSepPowerW;
            in minimumSepPowerW = minimumSepPowerW;
        }
    }
    metadata CredibilityAssessment about ArrayPowerAnalysis { verificationFactor = 3; validation = 1; inputPedigree = 1; resultsUncertainty = 2; resultsRobustness = 2; useHistory = 1; managementProcess = 2; peopleQualification = 3; }
    analysis arrayPowerAtAphelionEnd : ArrayPowerAnalysis {
        doc /* The worst point: the target's aphelion at the end of the return. */
        subject :>> tug = argent;
        in :>> distanceAu = amaranth.orbit.aphelionAu;
        in :>> missionDay = 1800.0;
    }

    // ---- Circular restricted three-body model of the distant retrograde orbit ----------------

    attribute def RotatingFrameState :> StateSpace {
        doc /* Position and velocity in the Earth–Moon rotating frame, nondimensional: x, y in
             * Earth–Moon distances, ẋ, ẏ in Earth–Moon distances per inverse mean motion. */
    }
    attribute def NoInput :> Input {
        doc /* The three-body problem has no control input; one placeholder element. */
    }
    attribute def MoonDistanceOutput :> Output {
        doc /* Distance from the Moon, nondimensional. */
    }

    attribute def ThreeBodyConstants {
        doc /* The Earth–Moon circular restricted three-body problem's scales: the mass ratio
             * μ = GM☾/(GM⊕ + GM☾), the length unit (the Earth–Moon distance), the time unit
             * (the inverse mean motion) and the speed unit, all derived from TethysEnvironment. */
        attribute massRatio : Real = moon.gravitationalParameterKm3PerS2
            / (earth.gravitationalParameterKm3PerS2 + moon.gravitationalParameterKm3PerS2);
        attribute lengthUnitKm : Real = lunarOrbit.semiMajorAxis / 1 [km];
        attribute timeUnitS : Real = sqrt(lengthUnitKm ** 3 / (earth.gravitationalParameterKm3PerS2 + moon.gravitationalParameterKm3PerS2));
        attribute speedUnitKmPerS : Real = lengthUnitKm / timeUnitS;
    }
    attribute earthMoon : ThreeBodyConstants {
        doc /* μ = 0.01215, 384 400 km, 4.342 d, 1.0245 km/s. */
    }

    calc def RungeKutta4 :> Integrate {
        doc /* The classical fourth-order Runge–Kutta step over the state derivative, the
             * standard-SysML specialisation of StateSpaceRepresentation::Integrate (OpenSysML
             * does not execute it, findings F-F01). */
        attribute k1 : StateDerivative = getDerivative(input, initialState);
        attribute k2 : StateDerivative = getDerivative(input, initialState + k1 * (timeInterval / 2.0));
        attribute k3 : StateDerivative = getDerivative(input, initialState + k2 * (timeInterval / 2.0));
        attribute k4 : StateDerivative = getDerivative(input, initialState + k3 * timeInterval);
        return :>> result = initialState + (k1 + k2 * 2.0 + k3 * 2.0 + k4) * (timeInterval / 6.0);
    }

    action def SteppedDynamics :> ContinuousStateSpaceDynamics {
        doc /* Continuous dynamics advanced at a fixed step until a stop time: the standard
             * library gives the protocol, this adds the clock. */
        attribute timeStep : DurationValue;
        attribute stopTime : DurationValue;
        attribute time : DurationValue;
    }

    action def ThreeBodyDynamics :> SteppedDynamics {
        doc /* Equations of motion of a massless body in the Earth–Moon rotating frame:
             * ẍ = x + 2ẏ − (1−μ)(x+μ)/r₁³ − μ(x−1+μ)/r₂³, ÿ = y − 2ẋ − (1−μ)y/r₁³ − μy/r₂³. */
        attribute constants : ThreeBodyConstants = earthMoon;
        in :>> input : NoInput = VectorOf((0.0));
        :>> stateSpace : RotatingFrameState;
        calc :>> getDerivative {
            in input : NoInput;
            in stateSpace : RotatingFrameState;
            attribute mu : Real = constants.massRatio;
            attribute x : Real = stateSpace.elements#(1);
            attribute y : Real = stateSpace.elements#(2);
            attribute vx : Real = stateSpace.elements#(3);
            attribute vy : Real = stateSpace.elements#(4);
            attribute r1 : Real = sqrt((x + mu) ** 2 + y ** 2);
            attribute r2 : Real = sqrt((x - 1.0 + mu) ** 2 + y ** 2);
            return : StateDerivative = VectorOf((
                vx,
                vy,
                x + 2.0 * vy - (1.0 - mu) * (x + mu) / r1 ** 3 - mu * (x - 1.0 + mu) / r2 ** 3,
                y - 2.0 * vx - (1.0 - mu) * y / r1 ** 3 - mu * y / r2 ** 3
            )) / 1 [s];
        }
        calc :>> getOutput {
            in input : NoInput;
            in stateSpace : RotatingFrameState;
            attribute mu : Real = constants.massRatio;
            return : MoonDistanceOutput =
                VectorOf((sqrt((stateSpace.elements#(1) - 1.0 + mu) ** 2 + stateSpace.elements#(2) ** 2)));
        }
        event occurrence xAxisCrossing : ZeroCrossingEventDef {
            doc /* y = 0: the orbit's symmetry crossings, two per revolution. */
        }
    }

    attribute def DroInitialConditions {
        doc /* The planar distant retrograde orbit of TethysEnvironment::destinationDro as a
             * state on the Earth–Moon line: at the given distance on the far side of the Moon
             * with a retrograde speed that closes the orbit (shooting solution for the 70 000 km
             * orbit: ẏ₀ = 0.51936 speed units, period 3.2047 time units). */
        attribute distanceFromMoon : LengthValue;
        attribute x0 : Real = 1.0 - earthMoon.massRatio - distanceFromMoon / 1 [km] / earthMoon.lengthUnitKm;
        attribute vy0 : Real;
        attribute periodTimeUnits : Real;
    }
    attribute dro70000 : DroInitialConditions {
        attribute :>> distanceFromMoon = destinationDro.radiusAboutMoon;
        attribute :>> vy0 = 0.51936359;
        attribute :>> periodTimeUnits = 3.20467695;
    }

    action droRevolution : ThreeBodyDynamics {
        doc /* One full revolution of the destination DRO: 320 steps of one 320th of the period
             * (3.2047 time units, about 1.04 h a step), so the final state is compared with the
             * initial one after exactly one period and the closure is a closure, not the arc the
             * orbit still had to go. */
        :>> stateSpace = VectorOf((dro70000.x0, 0.0, 0.0, dro70000.vy0));
        :>> timeStep = (dro70000.periodTimeUnits / 320.0) [s];
        :>> stopTime = dro70000.periodTimeUnits [s];
        calc :>> getNextState { calc :>> integrate : RungeKutta4; }
    }

    requirement def OrbitCloses {
        doc /* After one revolution the state shall return to within the tolerance of its start,
             * and the period the propagation shows shall match the design value. */
        subject tug : Tug;
        in attribute closureKm : Real;
        in attribute closureToleranceKm : Real;
        in attribute periodDays : Real;
        in attribute designPeriodDays : Real;
        in attribute periodToleranceDays : Real;
        require constraint { closureKm <= closureToleranceKm }
        require constraint { periodDays >= designPeriodDays - periodToleranceDays and periodDays <= designPeriodDays + periodToleranceDays }
    }

    analysis def DroStabilityAnalysis {
        doc /* The destination orbit is a three-body orbit, so its period and its persistence are
             * shown by propagation, not by a two-body formula: the period follows from the time
             * unit and the closure of the propagated revolution is the per-revolution drift that,
             * multiplied over the hundred-year horizon, bounds the unattended wander. */
        subject tug : Tug;
        in attribute closureToleranceKm : Real default = 1000.0;
        in attribute periodToleranceDays : Real default = 0.1;
        attribute periodDays : Real = dro70000.periodTimeUnits * earthMoon.timeUnitS / 86400.0;
        attribute revolutionsInHorizon : Real = destinationDro.stabilityHorizon / 1 [d] / periodDays;
        action revolution : ThreeBodyDynamics {
            :>> stateSpace = VectorOf((dro70000.x0, 0.0, 0.0, dro70000.vy0));
            :>> timeStep = (dro70000.periodTimeUnits / 320.0) [s];
            :>> stopTime = dro70000.periodTimeUnits [s];
            calc :>> getNextState { calc :>> integrate : RungeKutta4; }
        }
        return closureKm : Real = earthMoon.lengthUnitKm
            * sqrt((revolution.stateSpace.elements#(1) - dro70000.x0) ** 2 + revolution.stateSpace.elements#(2) ** 2);
        out periodShownDays : Real = periodDays;
        objective closes : OrbitCloses {
            doc /* The closure and period the propagated revolution must show. */
            subject :>> tug = tug;
            in closureKm = closureKm;
            in closureToleranceKm = closureToleranceKm;
            in periodDays = periodDays;
            in designPeriodDays = destinationDro.period / 1 [d];
            in periodToleranceDays = periodToleranceDays;
        }
    }
    metadata CredibilityAssessment about DroStabilityAnalysis { verificationFactor = 2; validation = 2; inputPedigree = 3; resultsUncertainty = 1; resultsRobustness = 1; useHistory = 2; managementProcess = 2; peopleQualification = 3; }
    analysis droStability : DroStabilityAnalysis { subject :>> tug = argent; }

    // ---- Heliocentric thrust and coast -------------------------------------------------------

    attribute def HeliocentricState :> StateSpace {
        doc /* x, y (km), ẋ, ẏ (km/s) in the ecliptic about the Sun, and the vehicle mass (kg). */
    }
    attribute def ThrustInput :> Input {
        doc /* Thrust magnitude (N) along the velocity, zero on a coast arc, and the mass flow
             * (kg/s) it costs. */
    }
    attribute def OrbitOutput :> Output {
        doc /* Heliocentric distance (AU) and speed (km/s). */
    }

    action def ThrustCoastDynamics :> SteppedDynamics {
        doc /* Point-mass heliocentric motion with tangential thrust: the first-order model of a
             * thrust arc or a coast arc of the transfer; thrust is in newtons, positions in km,
             * so the acceleration is divided by 1000. */
        in :>> input : ThrustInput;
        :>> stateSpace : HeliocentricState;
        calc :>> getDerivative {
            in input : ThrustInput;
            in stateSpace : HeliocentricState;
            attribute x : Real = stateSpace.elements#(1);
            attribute y : Real = stateSpace.elements#(2);
            attribute vx : Real = stateSpace.elements#(3);
            attribute vy : Real = stateSpace.elements#(4);
            attribute massKg : Real = stateSpace.elements#(5);
            attribute r : Real = sqrt(x ** 2 + y ** 2);
            attribute v : Real = sqrt(vx ** 2 + vy ** 2);
            attribute accelKmPerS2 : Real = input.elements#(1) / massKg / 1000.0;
            return : StateDerivative = VectorOf((
                vx,
                vy,
                0.0 - sun.gravitationalParameterKm3PerS2 * x / r ** 3 + accelKmPerS2 * vx / v,
                0.0 - sun.gravitationalParameterKm3PerS2 * y / r ** 3 + accelKmPerS2 * vy / v,
                0.0 - input.elements#(2)
            )) / 1 [s];
        }
        calc :>> getOutput {
            in input : ThrustInput;
            in stateSpace : HeliocentricState;
            return : OrbitOutput = VectorOf((
                sqrt(stateSpace.elements#(1) ** 2 + stateSpace.elements#(2) ** 2) / (solar.astronomicalUnit / 1 [km]),
                sqrt(stateSpace.elements#(3) ** 2 + stateSpace.elements#(4) ** 2)
            ));
        }
    }

    action firstThrustArc : ThrustCoastDynamics {
        doc /* Thirty days of full thrust from a 1 AU circular departure at the tug's injected
             * mass, in one-day steps. */
        attribute thrustN : Real = SepThrust(argent.sep.maximumPower / 1 [W], argent.sep.specificImpulse / 1 [s], 0.65);
        in :>> input = VectorOf((thrustN, MassFlowRate(thrustN, argent.sep.specificImpulse / 1 [s])));
        :>> stateSpace = VectorOf((solar.astronomicalUnit / 1 [km], 0.0, 0.0,
            CircularSpeed(sun.gravitationalParameterKm3PerS2, solar.astronomicalUnit / 1 [km]), argent.wetMass / 1 [kg]));
        :>> timeStep = 86400 [s];
        :>> stopTime = 2592000 [s];
        calc :>> getNextState { calc :>> integrate : RungeKutta4; }
    }

    // ---- Despin as a discrete process --------------------------------------------------------

    attribute def SpinState :> StateSpace {
        doc /* The stack's angular rate (rad/s) and the hydrazine spent so far (kg). */
    }
    attribute def DespinInput :> Input {
        doc /* Torque applied per pulse (N·m), pulse length (s) and thruster mass flow (kg/s). */
    }
    attribute def SpinOutput :> Output {
        doc /* Rotation period (s). */
    }

    action def DespinDynamics :> DiscreteStateSpaceDynamics {
        doc /* The despin as a sequence of equal thruster pulses on the captured stack: each pulse
             * removes torque × pulse length of angular momentum from the moment of inertia and
             * costs its propellant. */
        attribute momentOfInertiaKgM2 : Real;
        attribute timeStep : DurationValue;
        attribute stopTime : DurationValue;
        attribute time : DurationValue;
        in :>> input : DespinInput;
        :>> stateSpace : SpinState;
        calc :>> getDifference {
            in input : DespinInput;
            in stateSpace : SpinState;
            attribute pulseDeltaRate : Real = input.elements#(1) * input.elements#(2) / momentOfInertiaKgM2;
            return : StateSpace = VectorOf((
                0.0 - RealFunctions::min(pulseDeltaRate, stateSpace.elements#(1)),
                input.elements#(3) * input.elements#(2)
            ));
        }
        calc :>> getOutput {
            in input : DespinInput;
            in stateSpace : SpinState;
            return : SpinOutput = VectorOf((2.0 * pi / max(stateSpace.elements#(1), 1.0e-9)));
        }
    }

    action despinNominal : DespinDynamics {
        doc /* The nominal body (I = 1.67 × 10⁶ kg·m², 252 s period) despun by 60 s pulses of
             * two 22 N thrusters on a 3 m arm: 316 s of firing in six pulses, 6.5 kg. */
        :>> momentOfInertiaKgM2 = 0.4 * (targetCases.nominal.mass / 1 [kg]) * (targetCases.nominal.meanDiameter / 1 [m] / 2.0) ** 2;
        in :>> input = VectorOf((2.0 * 22.0 * 3.0, 60.0, 2.0 * 22.0 / (220.0 * standardGravityMPerS2)));
        :>> stateSpace = VectorOf((2.0 * pi / (targetCases.nominal.rotationPeriod / 1 [s]), 0.0));
        :>> timeStep = 60 [s];
        :>> stopTime = 360 [s];
    }
}
