// F-SW505 probe: a reference to an asserted constraint usage as the FIRST operand of `and` in a
// `require constraint` body draws the pilot warning "Bound features should have conforming
// types"; the same reference as the second operand does not. Standalone:
//   validate-sysml model/probes/F-SW505-constraint-reference-operand.sysml   (pilot: one warning at `referenceFirst`)
//   sysml -validate -strict -warnings-as-errors model/probes/...             (OpenSysML: clean)
package F_SW505 {
    doc /* Minimal probe for the operand-order warning on constraint references. */
    private import ScalarValues::*;

    part def Chain {
        doc /* A latency chain with its own bound check. */
        attribute latency : Real = 0.2;
        attribute bound : Real = 0.5;
        assert constraint withinBound { latency <= bound }
    }
    requirement referenceFirst { doc /* Constraint reference first. */ subject c : Chain; require constraint { c.withinBound and c.bound <= 1.0 } }
    requirement referenceSecond { doc /* Constraint reference second. */ subject c : Chain; require constraint { c.bound <= 1.0 and c.withinBound } }
    part chain : Chain;
    satisfy referenceFirst by chain { doc /* Holds. */ }
    satisfy referenceSecond by chain { doc /* Holds. */ }
}
