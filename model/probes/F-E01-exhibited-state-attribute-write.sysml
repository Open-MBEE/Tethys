// Probe for docs/findings/WP-E.md F-E01: an action of the exhibiting part assigns an attribute of
// the exhibited state usage through a feature chain (g.missDistance); the running machine's
// change trigger keeps reading the initial value. Run:
//   sysml -quiet -instantiate ProbeFE01::flight -state ProbeFE01::flight -advance 200 -trace model/probes/F-E01-exhibited-state-attribute-write.sysml
// Observed: `stmt assign g.missDistance` writes instance#2 while the machine evaluates
// `missDistance -> 20000.0 [km]` at every poll; it stays in `cruise` and the Abort is
// "consumed by no transition". Expected: `aborting` at t = 100 s, `safe` at t = 150 s.
package ProbeFE01 {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    item def Abort { doc /* Abort the return. */ }
    state def Guard {
        doc /* A trajectory monitor on its own attribute. */
        attribute missDistance : LengthValue = 20000.0 [km];
        attribute aborted : Boolean = false;
        entry; then cruise;
        state cruise;
        state aborting { entry assign aborted := true; }
        state safe;
        transition first cruise accept when missDistance < 10000.0 [km] then aborting;
        transition first aborting accept Abort then safe;
    }
    part def Flight {
        doc /* Exhibits the monitor and degrades its miss distance from a performed action. */
        exhibit state g : Guard;
        perform action nav {
            first start;
            then action w accept after 100 [s];
            then action degrade assign g.missDistance := 5000.0 [km];
            then action w2 accept after 50 [s];
            then action a send new Abort();
            then done;
        }
    }
    part flight : Flight { doc /* The probe object. */ }
}
