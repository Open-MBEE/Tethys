// Findings F-F05, minimal reproducer: an analysis case whose only step is a state-space action.
// Run standalone, `fall` ends after three 1 s RK4 steps at height 100 − 4.905·9 = 55.855 m
// (state ⟨55.855, −29.43⟩). Nested in `drop`, the action is neither performed nor refused:
// `-analysis NestedStateSpaceProbe::drop` returns `finalHeight = [100.0]`, the initial state.
// Expected: finalHeight = 55.855. Standalone, needs no other file.
package NestedStateSpaceProbe {
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
        :>> stateSpace : FallState = VectorOf((100.0, 0.0));
        :>> timeStep = 1 [s];
        :>> stopTime = 3 [s];
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

    action fall : FreeFall;

    analysis def Drop {
        action fall : FreeFall;
        return finalHeight : Real = fall.stateSpace.elements#(1);
    }
    analysis drop : Drop;
}
