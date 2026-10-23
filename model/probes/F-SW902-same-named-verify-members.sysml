// F-SW902: two `verify` members of one objective that reference requirements of the same name
// (a system row and the software row derived from it) are two owned members with the same
// effective name. OpenSysML strict rejects the objective (name-conflict); the pilot warns
// "Duplicate of other owned member name". Referencing the second row by its short name is
// accepted silently by OpenSysML although the effective name is still the referenced row's
// name. Consequence: GroundCommandTwoStepTest does not verify TM-003 directly; see
// docs/findings/WP-SW-9.md.
package F_SW902_System {
    requirement sequenceClearance { doc /* The system row. */ }
}
package F_SW902_Software {
    requirement <'TM-003'> sequenceClearance { doc /* The software row derived from it. */ }
}
package F_SW902 {
    private import F_SW902_System::*;
    verification def ByName {
        doc /* Both rows by name: rejected by OpenSysML strict, warned by the pilot. */
        objective { verify sequenceClearance { doc /* System row. */ } verify F_SW902_Software::sequenceClearance { doc /* Software row. */ } }
    }
    verification def ByShortName {
        doc /* The software row by short name: accepted by OpenSysML, warned by the pilot. */
        objective { verify sequenceClearance { doc /* System row. */ } verify F_SW902_Software::'TM-003' { doc /* Software row. */ } }
    }
}
