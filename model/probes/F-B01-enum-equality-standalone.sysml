// F-B01 standalone reproducer: enum equality and enum-sequence membership inside a calc give the
// wrong answer when the calc is invoked from the command line and any further file is loaded
// after this one. One enum, one `==`, one `includes`, two access paths.
//
//   P=model/probes/F-B01-enum-equality-standalone.sysml; X=model/00-tethys.sysml
//   sysml -calc "ProbeEnumEquality::IsModified(ProbeEnumEquality::Maturity::modified)" $P        # = [true]   right
//   sysml -calc "ProbeEnumEquality::IsModified(ProbeEnumEquality::Maturity::modified)" $P $X     # = [false]  WRONG
//   sysml -calc "ProbeEnumEquality::IsModified(ProbeEnumEquality::Maturity::modified)" $X $P     # = [true]   right
//   sysml -calc "ProbeEnumEquality::HasModified((ProbeEnumEquality::Maturity::heritage, ProbeEnumEquality::Maturity::modified))" $P $X   # = [false]  WRONG (alone: [true])
//   sysml -e "ProbeEnumEquality::isModified" $P $X     # = true   right (the same call bound to an attribute)
//   sysml -e "ProbeEnumEquality::hasModified" $P $X    # = true   right
//
// Expected everywhere: true (KerML 8.4.4.1 `DataFunctions::'=='` on two `EnumerationUsage` values
// of the same literal; 8.4.4.6 `SequenceFunctions::includes`). Observed on OpenSysML
// v0.10.1-2054-g0a5fa2d94: a `-calc` whose enum-typed argument is given as a qualified literal
// compares unequal to the same literal inside the calc body whenever the defining file is not the
// last one loaded; the attribute path is right. In the full Tethys model the same wrong branch is
// taken by `TethysMarginPolicy::ContingencyFor` (runs/wpb-margin-policy.txt = 0.2 vs
// runs/wpb-margin-policy-alone.txt = 0.1) and, through the attribute path too, by the per-mode
// power rollups of `TethysBudgets` (model/probes/F-B01-in-model-differential.sysml).
package ProbeEnumEquality {
    private import ScalarValues::*;
    private import SequenceFunctions::includes;
    enum def Maturity {
        doc /* Three literals; any enum shows it. */
        heritage; modified; newDesign;
    }
    calc def IsModified {
        doc /* Expected true for Maturity::modified. */
        in maturity : Maturity;
        return result : Boolean = maturity == Maturity::modified;
    }
    calc def HasModified {
        doc /* Expected true for any sequence containing Maturity::modified. */
        in maturities : Maturity[*];
        return result : Boolean = includes(maturities, Maturity::modified);
    }
    attribute isModified : Boolean = IsModified(Maturity::modified) {
        doc /* The attribute path: expected and returned true. */
    }
    attribute hasModified : Boolean = HasModified((Maturity::heritage, Maturity::modified)) {
        doc /* The attribute path: expected and returned true. */
    }
}
