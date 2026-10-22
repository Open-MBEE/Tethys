// Probe for docs/findings/WP-SW-3.md F-S05: `bind m.command = requests` — a state definition's port
// bound to a part port of another name — never delivers: the machine's `accept … via command`
// resolves to the part's port of the same name, so the bind is not what joins them. The same
// machine bound to a part port named `command` receives. Run:
//   sysml -quiet -instantiate FS05::mismatched -state "FS05::MismatchedHost::m FS05::mismatched.host" -advance 10 model/probes/F-S05-bind-port-name-mismatch.sysml
//   sysml -quiet -instantiate FS05::matched -state "FS05::MatchedHost::m FS05::matched.host" -advance 10 model/probes/F-S05-bind-port-name-mismatch.sysml
// Observed: mismatched stays `idle` (the message is rendered "(not accepted)"); matched reaches `gone`.
package FS05 {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    item def Go {
        doc /* The command sent once. */
    }
    port def GoPort {
        doc /* Receives the command. */
        in item go : Go;
    }
    interface def GoLink {
        doc /* Injector to host. */
        end source : ~GoPort;
        end sink : GoPort;
    }
    state def Listener {
        doc /* One transition on the command through its port. */
        port command : GoPort;
        entry; then idle;
        state idle;
        state gone;
        transition first idle accept Go via command then gone;
    }
    part def MismatchedHost {
        doc /* Binds the machine's `command` to the part's `requests`. */
        port requests : GoPort;
        exhibit state m : Listener;
        bind m.command = requests;
    }
    part def MatchedHost {
        doc /* Binds the machine's `command` to the part's `command`. */
        port command : GoPort;
        exhibit state m : Listener;
        bind m.command = command;
    }
    part def Injector {
        doc /* Sends the command once after a second. */
        port outbound : ~GoPort;
        perform action script {
            first start;
            then action wait accept after 1.0 [s];
            then send new Go() via outbound;
            then done;
        }
    }
    part mismatched { part injector : Injector; part host : MismatchedHost; interface l : GoLink connect injector.outbound to host.requests; }
    part matched { part injector : Injector; part host : MatchedHost; interface l : GoLink connect injector.outbound to host.command; }
}
