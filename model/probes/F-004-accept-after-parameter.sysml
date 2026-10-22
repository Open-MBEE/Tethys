// Probe for docs/findings.md F-004: `accept after` on a duration that arrived through an `in`
// parameter is refused at instantiation, while the same wait on an owned attribute with a
// literal value runs. Run:
//   sysml -quiet -instantiate ProbeF004::hostA -action "ProbeF004::HostA::a ProbeF004::hostA" -advance 2000000 model/probes/F-004-accept-after-parameter.sysml
//   sysml -quiet -instantiate ProbeF004::hostC -action "ProbeF004::HostC::c ProbeF004::hostC" -advance 2000000 model/probes/F-004-accept-after-parameter.sysml
// Observed: hostA — "accept after howLong must be constant, got sequence"; hostC — finished = [true].
package ProbeF004 {
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
