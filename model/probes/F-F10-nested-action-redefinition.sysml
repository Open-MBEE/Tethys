// Findings F-F10: redefinitions of a nested state-space action's own features (`action :>> fall {
// calc :>> getNextState { calc :>> integrate : RK4; } event occurrence :>> ground : ZeroCrossing {
// :>> guard = …; } }`) are not applied by the runtime, whether written in an analysis usage
// (`dropA`) or in a specialising analysis def (`dropC`); the same bindings written where the nested
// action is declared (`dropB`) run. Load alone: sysml -analysis NestedRedefinitionProbe::dropA
//   -analysis NestedRedefinitionProbe::dropC -analysis NestedRedefinitionProbe::dropB <this file>
// Observed: dropA and dropC fail with `unsupported state-space dynamics: zero crossing ground of
// action fall binds no guard`; dropB gives finalHeight = [55.855]. Expected: all three give
// finalHeight = [55.855] — a redefining usage's nested redefinitions apply to the redefined
// feature (KerML 7.3.4.4 Redefinition; SysML v2 7.6.3 Usages). Both validators accept the file.
package NestedRedefinitionProbe {
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
        event occurrence ground : ZeroCrossingEventDef;
    }

    analysis def Drop {
        doc /* Three seconds of free fall from 100 m; the integrator and the guard are bound by
             * the usage or a specialisation. */
        action fall : FreeFall {
            :>> stateSpace = VectorOf((100.0, 0.0));
            :>> timeStep = 1 [s];
            :>> stopTime = 3 [s];
        }
        return finalHeight : Real = fall.stateSpace.elements#(1);
    }

    analysis dropA : Drop {
        action :>> fall {
            calc :>> getNextState { calc :>> integrate : RK4; }
            event occurrence :>> ground : ZeroCrossing { :>> guard = stateSpace.elements#(1) - 50.0; }
        }
    }

    analysis def DropRk4 :> Drop {
        action :>> fall {
            calc :>> getNextState { calc :>> integrate : RK4; }
            event occurrence :>> ground : ZeroCrossing { :>> guard = stateSpace.elements#(1) - 50.0; }
        }
    }
    analysis dropC : DropRk4;

    analysis def DropBoundAtDeclaration {
        action fall : FreeFall {
            :>> stateSpace = VectorOf((100.0, 0.0));
            :>> timeStep = 1 [s];
            :>> stopTime = 3 [s];
            calc :>> getNextState { calc :>> integrate : RK4; }
            event occurrence :>> ground : ZeroCrossing { :>> guard = stateSpace.elements#(1) - 50.0; }
        }
        return finalHeight : Real = fall.stateSpace.elements#(1);
    }
    analysis dropB : DropBoundAtDeclaration;
}
