// F-I06 (docs/findings/integration.md): at OpenSysML 98d8eca77 a requirement's `require` of the
// subject's asserted constraint usage fails to evaluate — "operator '*' is not defined for a
// sequence and a Rational" — because the constraint's bound in-parameter arrives as a one-element
// sequence when the argument names a feature of another name (`in demand = estimate`). The same constraint holds under -instantiate budget -validate=budget, and the
// satisfaction held at 5cd37f288. Bisected to OpenSysML 40662e31d9 (2026-11-06).
package 'F-I06-require-constraint-parameter-sequence' {
    private import ScalarValues::*;
    constraint def Closes {
        doc /* The capability covers the demand with a quarter on top. */
        in capability : Real;
        in demand : Real;
        capability >= demand * 1.25
    }
    part def Budget {
        doc /* A budget with one closure assertion. */
        attribute allotment : Real = 10.0;
        attribute estimate : Real = 5.0;
        assert constraint closes : Closes { in capability = allotment; in demand = estimate; }
    }
    part budget : Budget;
    requirement budgetCloses {
        doc /* The budget shall close. */
        subject b : Budget;
        require b.closes;
    }
    assert satisfy budgetCloses by budget;
}
