// Probe: a requirement definition with 30 require members, for -validate time and -requirement.
// SysML 7.21.2 (requirement definitions and usages): require constraints are owned constraint
// usages; nothing in the clause limits their number.
package F_SW195 {
    private import ScalarValues::*;
    requirement def ThirtyRequires {
        attribute x : Real default = 1.0;
        require constraint c1 { x > -1.0 }
        require constraint c2 { x > -2.0 }
        require constraint c3 { x > -3.0 }
        require constraint c4 { x > -4.0 }
        require constraint c5 { x > -5.0 }
        require constraint c6 { x > -6.0 }
        require constraint c7 { x > -7.0 }
        require constraint c8 { x > -8.0 }
        require constraint c9 { x > -9.0 }
        require constraint c10 { x > -10.0 }
        require constraint c11 { x > -11.0 }
        require constraint c12 { x > -12.0 }
        require constraint c13 { x > -13.0 }
        require constraint c14 { x > -14.0 }
        require constraint c15 { x > -15.0 }
        require constraint c16 { x > -16.0 }
        require constraint c17 { x > -17.0 }
        require constraint c18 { x > -18.0 }
        require constraint c19 { x > -19.0 }
        require constraint c20 { x > -20.0 }
        require constraint c21 { x > -21.0 }
        require constraint c22 { x > -22.0 }
        require constraint c23 { x > -23.0 }
        require constraint c24 { x > -24.0 }
        require constraint c25 { x > -25.0 }
        require constraint c26 { x > -26.0 }
        require constraint c27 { x > -27.0 }
        require constraint c28 { x > -28.0 }
        require constraint c29 { x > -29.0 }
        require constraint c30 { x > -30.0 }
    }
    requirement thirty : ThirtyRequires;
    requirement thirtyFails : ThirtyRequires { attribute :>> x = -31.0; }
}
