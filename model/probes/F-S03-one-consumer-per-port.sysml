// Probe for docs/findings/WP-SW-3.md F-S03: a transfer arriving at a part's port is consumed by one
// of the machines the part exhibits — the last declared with an enabled transition — whether the
// machines are inline, bound state definitions or mixed; a machine alone takes it in every region.
// Run:
//   sysml -quiet -instantiate FS03::twoBound -state "FS03::TwoBound::one FS03::twoBound.host" -advance 10 model/probes/F-S03-one-consumer-per-port.sysml
//   sysml -quiet -instantiate FS03::twoBound -state "FS03::TwoBound::two FS03::twoBound.host" -advance 10 model/probes/F-S03-one-consumer-per-port.sysml
//   sysml -quiet -instantiate FS03::inlineThenBound -state "FS03::InlineThenBound::inline FS03::inlineThenBound.host" -advance 10 model/probes/F-S03-one-consumer-per-port.sysml
//   sysml -quiet -instantiate FS03::separatePorts -state "FS03::SeparatePorts::inline FS03::separatePorts.host" -advance 10 model/probes/F-S03-one-consumer-per-port.sysml
//   sysml -quiet -instantiate FS03::alone -state "FS03::Alone::regions FS03::alone.host" -advance 10 model/probes/F-S03-one-consumer-per-port.sysml
// Observed: twoBound — `one` stays idle, `two` reaches gone; inlineThenBound — inline stays idle;
// separatePorts — both reach gone; alone — both regions move (`b | d`).
package FS03 {
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
    state def TwoRegions parallel {
        doc /* Two regions each with a transition on the command. */
        port command : GoPort;
        state left { entry; then a; state a; state b; transition first a accept Go via command then b; }
        state right { entry; then c; state c; state d; transition first c accept Go via command then d; }
    }
    part def TwoBound {
        doc /* Two bound state definitions on one port. */
        port command : GoPort;
        exhibit state one : Listener;
        bind one.command = command;
        exhibit state two : Listener;
        bind two.command = command;
    }
    part def InlineThenBound {
        doc /* An inline machine then a bound one on one port. */
        port command : GoPort;
        exhibit state inline { entry; then idle; state idle; state gone; transition first idle accept Go via command then gone; }
        exhibit state bound : Listener;
        bind bound.command = command;
    }
    part def SeparatePorts {
        doc /* The same two machines on two ports. */
        port command : GoPort;
        port other : GoPort;
        exhibit state inline { entry; then idle; state idle; state gone; transition first idle accept Go via other then gone; }
        exhibit state bound : Listener;
        bind bound.command = command;
    }
    part def Alone {
        doc /* One parallel machine on the port. */
        port command : GoPort;
        exhibit state regions : TwoRegions;
        bind regions.command = command;
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
    part twoBound { part injector : Injector; part host : TwoBound; interface l : GoLink connect injector.outbound to host.command; }
    part inlineThenBound { part injector : Injector; part host : InlineThenBound; interface l : GoLink connect injector.outbound to host.command; }
    part separatePorts {
        part injector : Injector;
        part host : SeparatePorts;
        interface l : GoLink connect injector.outbound to host.command;
        interface l2 : GoLink connect injector.outbound to host.other;
    }
    part alone { part injector : Injector; part host : Alone; interface l : GoLink connect injector.outbound to host.command; }
}
