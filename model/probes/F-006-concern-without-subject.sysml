// F-006: a concern definition with a stakeholder and no explicit subject.
// Run: sysml -validate -strict model/probes/F-006-concern-without-subject.sysml   (accepted)
//      build/pilot-validator/validate-sysml model/probes/F-006-concern-without-subject.sysml
//      (error: Subject must be first parameter.)
// The two validators disagree on validateRequirementDefinitionSubjectParameterPosition
// (SysML v2 8.3.19) when the subject is the implicit one; the model declares every concern's
// subject explicitly, which both accept.
package F006 {
    part def Analyst {
        doc /* Someone who reads the model. */
    }
    concern def Traceability {
        doc /* A concern with a stakeholder and no explicit subject. */
        stakeholder analyst : Analyst;
    }
}
