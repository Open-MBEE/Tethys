// Probe for docs/findings/WP-E.md F-E02: `accept after` on a duration that arrived through an `in`
// parameter is refused at instantiation, while the same wait on an owned attribute with a
// literal value runs. Run:
//   sysml -quiet -instantiate ProbeFE02::hostA -action "ProbeFE02::HostA::a ProbeFE02::hostA" -advance 2000000 model/probes/F-E02-accept-after-parameter.sysml
//   sysml -quiet -instantiate ProbeFE02::hostC -action "ProbeFE02::HostC::c ProbeFE02::hostC" -advance 2000000 model/probes/F-E02-accept-after-parameter.sysml
// Observed: hostA — "accept after howLong must be constant, got sequence"; hostC — finished = [true].
package ProbeFE02 {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    action def WaitIn {
        doc /* Waits for the duration passed in. */
        in howLong : DurationValue;
        out finished : Boolean = false;
        first start;
        then action w accept after howLong;
        then assign finished := true;
        then done;
    }
    action def WaitAttr {
        doc /* Waits for an owned literal duration. */
        attribute howLong : DurationValue = 20.0 [d];
        out finished : Boolean = false;
        first start;
        then action w accept after howLong;
        then assign finished := true;
        then done;
    }
    part def HostA { doc /* Binds the parameter from an attribute. */ attribute dur : DurationValue = 20.0 [d]; perform action a : WaitIn { in howLong = HostA::dur; } }
    part def HostC { doc /* Owned literal. */ perform action c : WaitAttr; }
    part hostA : HostA { doc /* Fails. */ }
    part hostC : HostC { doc /* Runs. */ }
}
