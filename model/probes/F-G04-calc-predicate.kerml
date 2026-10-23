library package ProbeCalcPredicate {
    doc /* A Predicate is a Function (KerML §8.3.4.7 Functions), but
         * `sysml -calc "ProbeCalcPredicate::Closes(2.0, 1.0)"` answers "not a calc: ... is a
         * predicate usage, not a calc definition or usage". */
    private import ScalarValues::*;
    predicate Closes { in supply : Real; in demand : Real; return : Boolean = supply >= demand; }
}
