library package ProbeStandaloneSubsetting {
    doc /* Both statements subset a feature that is not accessible from this namespace. The pilot
         * rejects both ("Must be an accessible feature"); OpenSysML rejects only the inline form. */
    private import ScalarValues::*;
    struct A { feature a : Real; }
    feature fu : A;
    specialization subset fu :> A::a;
    feature fv : Real :> A::a;
}
