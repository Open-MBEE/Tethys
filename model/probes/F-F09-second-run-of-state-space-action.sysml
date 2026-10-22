// Findings F-F09: the second run of the same state-space action in one process does not step
// from its bound initial state. Load alone: sysml -action FF09::fall -action FF09::fall <this file>
// Observed: the first run ends at stateSpace ⟨55.855, −29.43⟩ (three 1 s RK4 steps of free fall
// from 100 m), the second at ⟨100.0, 0.0⟩ with time = 3.0 [s]. The same holds for an analysis
// run before the action (`-analysis … -action …`). Expected: both runs end at ⟨55.855, −29.43⟩;
// each run is a separate performance of the action (SysML v2 7.16.1).
package FF09 {
    private import ScalarValues::*;
    private import SI::*;
    private import VectorFunctions::*;
    private import StateSpaceRepresentation::*;
    private import StateSpaceIntegration::*;

    attribute def FallState :> StateSpace;
    attribute def NoInput :> Input;
    attribute def HeightOutput :> Output;

    action def FreeFall :> ContinuousStateSpaceDynamics, FixedStepDynamics {
        in :>> input : NoInput = VectorOf((0.0));
        :>> stateSpace : FallState;
        calc :>> getDerivative {
            in input : NoInput;
            in stateSpace : FallState;
            return : StateDerivative = VectorOf((stateSpace.elements#(2), -9.81)) / 1 [s];
        }
        calc :>> getOutput {
            in input : NoInput;
            in stateSpace : FallState;
            return : HeightOutput = VectorOf((stateSpace.elements#(1)));
        }
        calc :>> getNextState { calc :>> integrate : RK4; }
    }

    action fall : FreeFall {
        :>> stateSpace = VectorOf((100.0, 0.0));
        :>> timeStep = 1 [s];
        :>> stopTime = 3 [s];
    }
}
