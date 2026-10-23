// Findings F-F07, minimal reproducer: two fixed-step state-space actions named in one `sysml`
// invocation share the run's clock. Standalone, `thirtyDays` steps 30 × 86 400 s to
// stateSpace ⟨2592000.0⟩ at time 2 592 000 s and `threeSeconds` steps 3 × 1 s to ⟨3.0⟩.
// `-action StopTimeProbe::threeSeconds -action StopTimeProbe::thirtyDays` leaves the second
// action at ⟨2505600.0⟩, time 2 505 603 s: its clock starts at the first action's 3 s and the
// stop test `time + timeStep > stopTime` drops its 30th step. In the other order the second
// action takes no step at all (⟨0.0⟩, time 2 592 000 s). Expected: each action's `time`
// starts at 0 and it steps to its own `stopTime` whatever ran before it. Standalone, needs
// no other file.
package StopTimeProbe {
    private import ScalarValues::*;
    private import SI::*;
    private import VectorFunctions::*;
    private import StateSpaceRepresentation::*;
    private import StateSpaceIntegration::*;

    attribute def Clock :> StateSpace;
    attribute def NoInput :> Input;
    attribute def Elapsed :> Output;

    action def Count :> ContinuousStateSpaceDynamics, FixedStepDynamics {
        doc /* One state that grows at 1 per second, so the final state is the seconds stepped. */
        in :>> input : NoInput;
        :>> stateSpace : Clock;
        calc :>> getDerivative {
            in input : NoInput;
            in stateSpace : Clock;
            return : StateDerivative = VectorOf((1.0)) / 1 [s];
        }
        calc :>> getOutput {
            in input : NoInput;
            in stateSpace : Clock;
            return : Elapsed = VectorOf((stateSpace.elements#(1)));
        }
        calc :>> getNextState { calc :>> integrate : RK4; }
    }

    action threeSeconds : Count {
        :>> stateSpace = VectorOf((0.0));
        :>> timeStep = 1 [s];
        :>> stopTime = 3 [s];
    }
    action thirtyDays : Count {
        :>> stateSpace = VectorOf((0.0));
        :>> timeStep = 86400 [s];
        :>> stopTime = 2592000 [s];
    }
}
