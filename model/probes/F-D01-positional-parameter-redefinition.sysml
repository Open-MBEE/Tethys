// Probe: a usage body whose first parameter explicitly redefines the type's *second*
// parameter. Parameters redefine positionally as well, so `out :>> output` also redefines
// `input` and the directions conflict. The pilot reports it; OpenSysML -validate -strict
// accepts the file silently. Excluded from make check (not under model/*.sysml).
package ProbePositionalParameters {
    private import ScalarValues::*;
    action def Step {
        in input : Integer;
        out output : Integer;
    }
    action def Chain {
        action stepA : Step { out :>> output; }
        action stepB : Step { in :>> input; out :>> output; }
    }
}
