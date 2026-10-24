// Probe F-SW703: a calc usage as the target of a succession inside an action body.
// Expected (SysML v2 §7.16.2 calculation usages are action usages; §7.16.4 succession between
// action usages): `withSuccession` instantiates and runs like `withoutSuccession`; both end with
// verdict = "cleared".
package FSW703 {
    private import ScalarValues::*;
    calc def Passes {
        doc /* A rule check with one Boolean result. */
        in value : Real;
        return passed : Boolean = value >= 0.5;
    }
    action def WithSuccession {
        doc /* The check is a step in the flow: load, then check, then decide. */
        attribute verdict : String := "pending";
        action load { assign verdict := "loaded"; }
        then calc check : Passes { in value = 0.9; }
        then decide;
            if check.passed then clear;
            else refuse;
        action clear { assign verdict := "cleared"; }
        then done;
        action refuse { assign verdict := "refused"; }
        then done;
    }
    action def WithoutSuccession {
        doc /* The same check declared outside the flow and read lazily by the decision. */
        attribute verdict : String := "pending";
        calc check : Passes { in value = 0.9; }
        action load { assign verdict := "loaded"; }
        then decide;
            if check.passed then clear;
            else refuse;
        action clear { assign verdict := "cleared"; }
        then done;
        action refuse { assign verdict := "refused"; }
        then done;
    }
    part def FlowChecker {
        doc /* Performs the flow form. */
        perform action flowForm : WithSuccession;
    }
    part def LazyChecker {
        doc /* Performs the lazy form. */
        perform action lazyForm : WithoutSuccession;
    }
    part flowChecker : FlowChecker {
        doc /* Expected to run; fails to instantiate on the pinned runtime. */
    }
    part lazyChecker : LazyChecker {
        doc /* The workaround form; runs on the pinned runtime. */
    }
}
