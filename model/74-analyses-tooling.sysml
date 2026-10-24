// OpenSysML's own analysis surfaces over the TethysAnalyses, TethysMonteCarlo and TethysDynamics
// cases: Simulation::MonteCarlo runs with weighted (Stochastic) and distributed (RandomFunctions)
// draws, and the state-space actions bound to StateSpaceIntegration's integrator and stepping.
// Tool tier: it references OpenSysML library packages and is gated by the batch pilot only; the
// mission-tier files it imports stand on the standard libraries alone.
package TethysAnalysesTooling {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import VectorFunctions::*;
    private import Simulation::*;
    private import Stochastic::*;
    private import RandomFunctions::*;
    private import StateSpaceIntegration::*;
    private import TethysEnvironment::*;
    private import TethysTug::*;
    private import TethysAnalyses::*;
    private import TethysTarget::targetCases;
    private import TethysMonteCarlo::*;
    private import TethysDynamics::*;
    private import TethysMission::transferBook;

    // ---- Monte Carlo over the target-uncertainty table ---------------------------------------

    action def DrawTargetCase {
        doc /* One target case per run, weighted by the pre-arrival belief: small 25 %, nominal
             * 50 %, large 25 %. */
        out bodyMassKg : Real;
        action small assign bodyMassKg := targetCases.small.mass / 1 [kg];
        action nominal assign bodyMassKg := targetCases.nominal.mass / 1 [kg];
        action large assign bodyMassKg := targetCases.large.mass / 1 [kg];
        first start; then decide pick;
        then small { @Probability { p = 0.25; } }
        then nominal { @Probability { p = 0.50; } }
        then large { @Probability { p = 0.25; } }
        first small then done; first nominal then done; first large then done;
    }

    analysis def ReturnOverTargetCases :> MonteCarlo {
        doc /* The return Δv over the weighted target cases, run with `-runs <n> -seed <s>`;
             * outOfSpec counts the runs whose return objective fails. */
        subject :>> analysed : Tug;
        action draw : DrawTargetCase;
        analysis dispersion : ReturnDispersion {
            subject :>> tug = analysed;
            in bodyMassKg = draw.bodyMassKg;
        }
        attribute :>> observed = dispersion.returnDeltaV / 1 ['m/s'];
        objective canReturn : ReturnCapability {
            doc /* The return capability this case must show. */
            subject :>> tug = analysed;
            in returnDeltaV = dispersion.returnDeltaV;
            in requiredReturnDeltaV = transferBook.deltaVRequiredReturn;
            in totalThrustTime = dispersion.totalThrustTime;
            in thrustTimeAllowance = transferBook.thrustingTimeAllowed;
        }
    }
    analysis returnOverTargetCases : ReturnOverTargetCases { subject :>> analysed = argent; }

    analysis def ReturnOverContinuousMass :> MonteCarlo {
        doc /* The return Δv with the body mass drawn from a triangular distribution over the
             * small–nominal–large range; `-draws min -runs 1` and `-draws max -runs 1` give the
             * worst-case corners. */
        subject :>> analysed : Tug;
        attribute bodyMassKg : Real = triangular(targetCases.small.mass / 1 [kg], targetCases.nominal.mass / 1 [kg], targetCases.large.mass / 1 [kg]);
        analysis dispersion : ReturnDispersion {
            subject :>> tug = analysed;
            in bodyMassKg = bodyMassKg;
        }
        attribute :>> observed = dispersion.returnDeltaV / 1 ['m/s'];
        objective canReturn : ReturnCapability {
            doc /* The return capability this case must show. */
            subject :>> tug = analysed;
            in returnDeltaV = dispersion.returnDeltaV;
            in requiredReturnDeltaV = transferBook.deltaVRequiredReturn;
            in totalThrustTime = dispersion.totalThrustTime;
            in thrustTimeAllowance = transferBook.thrustingTimeAllowed;
        }
    }
    analysis returnOverContinuousMass : ReturnOverContinuousMass { subject :>> analysed = argent; }

    // ---- State-space actions on OpenSysML's integrator ---------------------------------------

    action droRevolutionRk4 : ThreeBodyDynamics {
        doc /* One revolution of the destination DRO with StateSpaceIntegration::RK4 bound as the
             * integrator and the x-axis crossing guarded on y. */
        :>> stateSpace = VectorOf((dro70000.x0, 0.0, 0.0, dro70000.vy0));
        :>> timeStep = (dro70000.periodTimeUnits / 320.0) [s];
        :>> stopTime = dro70000.periodTimeUnits [s];
        calc :>> getNextState { calc :>> integrate : RK4; }
        event occurrence :>> xAxisCrossing : ZeroCrossing { :>> guard = stateSpace.elements#(2); }
    }

    analysis droStabilityRk4 : DroStabilityAnalysis {
        doc /* The DRO stability analysis with StateSpaceIntegration::RK4 bound as the integrator of
             * its revolution and the x-axis crossing guarded on y, so the closure and period the
             * objective asks for are evaluated here; the mission-tier `droStability` keeps the
             * model's own RungeKutta4 (findings F-F01). */
        subject :>> tug = argent;
        action :>> revolution {
            calc :>> getNextState { calc :>> integrate : RK4; }
            event occurrence :>> xAxisCrossing : ZeroCrossing { :>> guard = stateSpace.elements#(2); }
        }
    }

    action firstThrustArcRk4 : ThrustCoastDynamics {
        doc /* Thirty days of full thrust from 1 AU with StateSpaceIntegration::RK4. */
        attribute thrustN : Real = SepThrust(argent.sep.maximumPower / 1 [W], argent.sep.specificImpulse / 1 [s], 0.65);
        in :>> input = VectorOf((thrustN, MassFlowRate(thrustN, argent.sep.specificImpulse / 1 [s])));
        :>> stateSpace = VectorOf((solar.astronomicalUnit / 1 [km], 0.0, 0.0,
            CircularSpeed(sun.gravitationalParameterKm3PerS2, solar.astronomicalUnit / 1 [km]), argent.wetMass / 1 [kg]));
        :>> timeStep = 86400 [s];
        :>> stopTime = 2592000 [s];
        calc :>> getNextState { calc :>> integrate : RK4; }
    }
}
