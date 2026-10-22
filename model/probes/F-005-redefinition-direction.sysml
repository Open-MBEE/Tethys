package 'F-005' {
    doc /* A usage redefines an `in` parameter of its definition without restating the
         * direction; the redefining feature's direction must conform. */
    private import ScalarValues::*;
    action def Burn { in durationS : Real; }
    action burn : Burn { :>> durationS = 3.0; }
}
