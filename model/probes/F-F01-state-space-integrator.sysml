// Findings F-F01: the TethysDynamics DRO revolution with OpenSysML's own integrator bound in
// place of the standard-SysML RungeKutta4 the model declares. Loaded after model/*.sysml.
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
}
