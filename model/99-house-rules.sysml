// House rules `make house-rules` applies with -self-check-package TethysHouseRules: each
// constraint def's first in parameter is typed by a metaclass, so it governs every element
// that classifies as one. CONVENTIONS.md states each rule in prose.
package TethysHouseRules {
    private import SequenceFunctions::*;

    constraint def definitionHasDocumentation {
        doc /* Every definition carries a doc comment. */
        in d : SysML::Definition;
        not d.documentation->isEmpty()
    }

    constraint def requirementHasDocumentation {
        doc /* Every requirement usage states its text as a doc comment. */
        in r : SysML::RequirementUsage;
        not r.documentation->isEmpty()
    }

    constraint def requirementHasText {
        doc /* Every requirement usage has a non-empty derived text (the body of its
             * documentation), so a requirement is never only a name and a constraint. */
        in r : SysML::RequirementUsage;
        not r.text->isEmpty()
    }

    constraint def allocationUsageIsTyped {
        doc /* Every allocation usage is typed by an allocation def, so each allocation matrix
             * reads by kind and the deployment chain of the flight software is explicit. */
        in a : SysML::AllocationUsage;
        not a.allocationDefinition->isEmpty()
    }

    constraint def portUsageIsTyped {
        doc /* Every port usage is typed by a port def from TethysInterfaces, so an ICD
             * can be written against it. */
        in p : SysML::PortUsage;
        not p.portDefinition->isEmpty()
    }
}
