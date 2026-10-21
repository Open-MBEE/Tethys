// House rules `make house-rules` applies with -self-check-package HesperiaHouseRules: each
// constraint def's first in parameter is typed by a metaclass, so it governs every element
// that classifies as one. CONVENTIONS.md states each rule in prose.
package HesperiaHouseRules {
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

    constraint def portUsageDeclaresDirection {
        doc /* Every port usage on a definition declares in, out or inout. */
        in p : SysML::PortUsage;
        not p.direction->isEmpty()
    }
}
