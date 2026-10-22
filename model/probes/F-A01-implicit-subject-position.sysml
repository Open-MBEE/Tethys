// Probe: a concern def with a stakeholder parameter and no explicit subject. The pilot reports
// "Subject must be first parameter"; OpenSysML accepts it. With `subject s : Thing;` first, both accept.
package ImplicitSubjectPosition {
    part def Thing;
    concern def Rejected {
        stakeholder owner : Thing;
    }
    viewpoint def AlsoRejected {
        frame concern c : Rejected;
    }
    concern def Accepted {
        subject s : Thing;
        stakeholder owner : Thing;
    }
}
