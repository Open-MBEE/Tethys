// Findings F-003: the TethysDynamics state-space actions with OpenSysML's own integrator and
// stepping bound in place of the standard-SysML RungeKutta4 and SteppedDynamics the model
// declares. Loaded after model/*.sysml.
package TethysDynamicsIntegratorProbe {
    private import ScalarValues::*;
    private import SI::*;
    private import VectorFunctions::*;
    private import StateSpaceIntegration::*;
    private import TethysEnvironment::*;
    private import TethysTug::*;
    private import TethysAnalyses::*;
    private import TethysDynamics::*;

    action droRevolutionRk4 : ThreeBodyDynamics {
        :>> stateSpace = VectorOf((dro70000.x0, 0.0, 0.0, dro70000.vy0));
        :>> timeStep = 0.01 [s];
        :>> stopTime = 3.20 [s];
        calc :>> getNextState { calc :>> integrate : RK4; }
        event occurrence :>> xAxisCrossing : ZeroCrossing { :>> guard = stateSpace.elements#(2); }
    }
    action firstThrustArcRk4 : ThrustCoastDynamics {
        attribute thrustN : Real = SepThrust(argent.sep.maximumPower / 1 [W], argent.sep.specificImpulse / 1 [s], 0.65);
        in :>> input = VectorOf((thrustN, MassFlowRate(thrustN, argent.sep.specificImpulse / 1 [s])));
        :>> stateSpace = VectorOf((solar.astronomicalUnit / 1 [km], 0.0, 0.0,
            CircularSpeed(sun.gravitationalParameterKm3PerS2, solar.astronomicalUnit / 1 [km]), argent.wetMass / 1 [kg]));
        :>> timeStep = 86400 [s];
        :>> stopTime = 2592000 [s];
        calc :>> getNextState { calc :>> integrate : RK4; }
    }

    analysis droStabilityRk4 : DroStabilityAnalysis {
        doc /* Findings F-007: the same analysis with the integrator OpenSysML executes, to show
             * what the nested propagation returns when it is performed. */
        subject :>> tug = argent;
        action :>> revolution {
            calc :>> getNextState { calc :>> integrate : RK4; }
            event occurrence :>> xAxisCrossing : ZeroCrossing { :>> guard = stateSpace.elements#(2); }
        }
    }
}
