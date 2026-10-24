// Probe for docs/findings/WP-SW-3.md F-S01: a `send … via p` from a state definition's own port,
// bound by the exhibiting part (`bind m.outbound = outbound`), reaches nothing, while the same send
// written in an inline exhibited state usage through the part's port leaves over the interface,
// fans out to two receivers and renders as a message sequence. Run:
//   sysml -quiet -instantiate FS01::viaDefinitionPort -state "FS01::DefinitionSender::m FS01::viaDefinitionPort.a" -advance 10 model/probes/F-S01-send-via-state-definition-port.sysml
//   sysml -quiet -instantiate FS01::viaPartPort -state "FS01::InlineSender::m FS01::viaPartPort.a" -advance 10 -render-run sequence=build/runs/probe-F-S01-sequence.txt model/probes/F-S01-send-via-state-definition-port.sysml
// Observed: viaDefinitionPort — "send reaches no receiving port: port "outbound" is joined to no port
// that can receive it"; viaPartPort — both receivers reach `got`, two messages rendered.
package FS01 {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    item def Ping {
        doc /* The message sent. */
        attribute n : Integer;
    }
    port def PingPort {
        doc /* Receives pings. */
        in item ping : Ping;
    }
    interface def PingLink {
        doc /* Sender to receiver. */
        end source : ~PingPort;
        end sink : PingPort;
    }
    state def Receiver {
        doc /* Takes one ping through its port. */
        port inbound : PingPort;
        attribute received : Integer = 0;
        entry; then waiting;
        state waiting;
        state got;
        transition first waiting accept p : Ping via inbound do assign received := p.n then got;
    }
    state def Sender {
        doc /* Sends one ping through the state definition's own port after a second. */
        port outbound : ~PingPort;
        entry; then idle;
        state idle;
        state pinged {
            entry send new Ping(n = 7) via outbound;
        }
        transition first idle accept after 1.0 [s] then pinged;
    }
    part def DefinitionSender {
        doc /* Exhibits the sending state definition and binds its port. */
        port outbound : ~PingPort;
        exhibit state m : Sender;
        bind m.outbound = outbound;
    }
    part def InlineSender {
        doc /* The same machine written inline, sending through the part's port. */
        port outbound : ~PingPort;
        exhibit state m {
            entry; then idle;
            state idle;
            state pinged {
                entry send new Ping(n = 7) via outbound;
            }
            transition first idle accept after 1.0 [s] then pinged;
        }
    }
    part def ReceiverPart {
        doc /* Exhibits the receiver and binds its port. */
        port inbound : PingPort;
        exhibit state m : Receiver;
        bind m.inbound = inbound;
    }
    part def SecondReceiverPart :> ReceiverPart {
        doc /* A second receiver type, so each is addressable. */
    }
    part viaDefinitionPort {
        doc /* The failing form. */
        part a : DefinitionSender;
        part b : ReceiverPart;
        part c : SecondReceiverPart;
        interface ab : PingLink connect a.outbound to b.inbound;
        interface ac : PingLink connect a.outbound to c.inbound;
    }
    part viaPartPort {
        doc /* The working form. */
        part a : InlineSender;
        part b : ReceiverPart;
        part c : SecondReceiverPart;
        interface ab : PingLink connect a.outbound to b.inbound;
        interface ac : PingLink connect a.outbound to c.inbound;
    }
}
