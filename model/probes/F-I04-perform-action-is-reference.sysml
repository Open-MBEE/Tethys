// F-I04 (docs/findings/integration.md): under -self-check at OpenSysML 98d8eca77, every performed
// action fails SysMLValidation::validateEventOccurrenceUsageIsReference — the reflective
// isComposite of a PerformActionUsage answers true while api-json writes isComposite = false.
// A performed action is referential (SysML v2 §8.3.16), so the rule should hold on all four.
package 'F-I04-perform-action-is-reference' {
    private import ScalarValues::*;
    action def Burn {
        doc /* A burn with one input. */
        in duration : Real;
    }
    part def Tug {
        doc /* A tug that performs its actions four ways. */
        perform action warmUp;
        perform action burn : Burn { in duration = 10.0; }
        perform action coast : Burn;
        perform action safe { first start; then done; }
    }
}
