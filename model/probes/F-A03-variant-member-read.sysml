// Probe: reading a variant's bound attribute through the variation def. OpenSysML evaluates
// `cases.big.m` (a nested part) but not `Case::big.m` (a variant): "cannot chain through
// non-instance member (variant)". Run: sysml -instantiate VariantRead::holder -validate=VariantRead::holder <this file>
package VariantRead {
    private import ScalarValues::*;
    part def B { attribute m : Real; }
    variation part def Case :> B { variant part big : Case { attribute :>> m = 2.0; } }
    part cases { part big : B { attribute :>> m = 2.0; } }
    part holder {
        assert constraint viaVariant { Case::big.m >= 1.0 }
        assert constraint viaNested { cases.big.m >= 1.0 }
    }
}
