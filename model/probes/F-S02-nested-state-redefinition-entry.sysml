// Probe for docs/findings/WP-SW-3.md F-S02: an entry action added to a redefined nested state
// (`state :>> two { entry assign … }`), in a state definition specialising another or in the body
// of an `exhibit state m : Base { … }`, validates but never runs; the same write from a transition
// effect reached through a two-level `exhibit` (outer part, inner part, machine) does run. Run:
//   sysml -quiet -instantiate FS02::specialised -state "FS02::SpecialisedHost::m FS02::specialised" -advance 10 -trace model/probes/F-S02-nested-state-redefinition-entry.sysml
//   sysml -quiet -instantiate FS02::bodied -state "FS02::BodiedHost::m FS02::bodied" -advance 10 -trace model/probes/F-S02-nested-state-redefinition-entry.sysml
//   sysml -quiet -instantiate FS02::outer -state "FS02::Inner::m FS02::outer.inner" -advance 10 -trace model/probes/F-S02-nested-state-redefinition-entry.sysml
// Observed: specialised and bodied reach `two` with no `stmt assign hits` in the trace; outer reaches
// `two` and the trace shows `stmt assign writes` from the transition effect.
package FS02 {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    state def Base {
        doc /* Two states and a timed transition between them. */
        attribute hits : Integer default = 0;
        attribute writes : Integer default = 0;
        entry; then one;
        state one;
        state two;
        transition first one accept after 1.0 [s] do assign writes := writes + 1 then two;
    }
    state def Specialised :> Base {
        doc /* Adds an entry action to the inherited state `two`. */
        state :>> two {
            entry assign hits := hits + 1;
        }
    }
    part def SpecialisedHost {
        doc /* Exhibits the specialised machine. */
        exhibit state m : Specialised;
    }
    part def BodiedHost {
        doc /* Adds the same entry action in the exhibit body. */
        exhibit state m : Base {
            state :>> two {
                entry assign hits := hits + 1;
            }
        }
    }
    part def Inner {
        doc /* The inner part exhibiting the base machine. */
        exhibit state m : Base;
    }
    part def Outer {
        doc /* The outer part holding the inner one: two levels above the machine. */
        part inner : Inner;
    }
    part specialised : SpecialisedHost;
    part bodied : BodiedHost;
    part outer : Outer;
}
