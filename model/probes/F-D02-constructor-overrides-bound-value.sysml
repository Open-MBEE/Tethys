// Probe: a constructor argument for a feature whose definition already fixes its value with
// `=`. A bound feature value cannot be overridden, so the pilot rejects `new A(x = 2)`;
// OpenSysML -validate -strict accepts it (it does flag the same override written as a
// redefinition). Excluded from make check (not under model/*.sysml).
package ProbeConstructorOverridesBoundValue {
    private import ScalarValues::*;
    item def A {
        attribute x : Integer = 1;
    }
    part def Receiver;
    part receiver : Receiver;
    action def Make {
        action send1 send new A(x = 2) to receiver;
    }
}
