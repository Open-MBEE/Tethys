library package ProbeKerMLWrapper {
    doc /* Any KerML file: the pinned standalone pilot wrapper (validate-sysml) exits 1 with
         * "File must have .sysml extension" before parsing it. */
    private import ScalarValues::*;
    function Twice { in x : Real; return : Real = 2.0 * x; }
}
