// Probe for docs/findings/WP-SW-3.md F-S10 (timing): `accept after` on an `in` parameter of a
// DurationValue beside the same wait on a literal with a unit, and a command latency chain summed
// with units against a budget. Run:
//   sysml -quiet -instantiate FS10::host -action "FS10::Host::parameterised FS10::host" -action "FS10::Host::literal FS10::host" -advance 100 model/probes/F-S10-accept-after-parameter-and-latency-chain.sysml
//   sysml -quiet -instantiate FS10::chain -validate=FS10::chain model/probes/F-S10-accept-after-parameter-and-latency-chain.sysml
//   sysml -e "FS10::chain.endToEnd" model/probes/F-S10-accept-after-parameter-and-latency-chain.sysml
package FS10 {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    action def WaitFor {
        doc /* Waits for the duration passed in, then reports. */
        in howLong : DurationValue;
        out finished : Boolean = false;
        first start;
        then action wait accept after howLong;
        then assign finished := true;
        then done;
    }
    action def WaitTenSeconds {
        doc /* Waits ten seconds written as a literal with its unit. */
        out finished : Boolean = false;
        first start;
        then action wait accept after 10.0 [s];
        then assign finished := true;
        then done;
    }
    part def Host {
        doc /* Performs both waits. */
        perform action parameterised : WaitFor { in howLong = 10.0 [s]; }
        perform action literal : WaitTenSeconds;
    }
    part host : Host;
    constraint def LatencyWithinBudget {
        doc /* The command latency chain closes against its budget. */
        in uplink : DurationValue;
        in ingest : DurationValue;
        in dispatch : DurationValue;
        in budget : DurationValue;
        uplink + ingest + dispatch <= budget
    }
    part chain {
        doc /* One-way light time at 0.5 au, the ingest service's frame, the dispatcher's tick. */
        attribute uplink : DurationValue = 249.0 [s];
        attribute ingest : DurationValue = 0.250 [s];
        attribute dispatch : DurationValue = 0.125 [s];
        attribute budget : DurationValue = 5.0 [min];
        attribute endToEnd : DurationValue = uplink + ingest + dispatch;
        assert constraint latency : LatencyWithinBudget {
            in uplink = chain::uplink;
            in ingest = chain::ingest;
            in dispatch = chain::dispatch;
            in budget = chain::budget;
        }
    }
}
