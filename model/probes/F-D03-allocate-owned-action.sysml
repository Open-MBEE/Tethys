// Probe: an allocation whose end is an action usage owned (not performed) by the same part
// definition. Both ends are features of the owning type, so they are accessible connector
// ends; the pilot reports "Must be an accessible feature" for the owned action while it
// accepts the same allocation written with `perform action`. OpenSysML accepts both.
// Excluded from make check (not under model/*.sysml).
package ProbeAllocateOwnedAction {
    occurrence def Pass;
    action def Downlink;
    part def Plan {
        occurrence pass1 : Pass;
        action owned : Downlink;
        perform action performed : Downlink;
        allocate owned to pass1;
        allocate performed to pass1;
    }
}
