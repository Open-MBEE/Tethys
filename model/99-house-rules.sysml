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

    // ---- flight dictionary rules: every row of TethysFlightDictionary is complete ---------
    constraint def commandDeclaresOpcodeAndModes {
        doc /* Every command of the flight dictionary binds its opcode literal, its opcode number
             * and the modes it is accepted in; the dictionary requirement checks their distinctness. */
        in u : SysML::ItemUsage;
        (u.itemDefinition.name->includes("CommandDefinition") and u.owningNamespace.name->includes("TethysFlightDictionary")) implies
            (u.ownedFeature.name->includes("opcodeLiteral") and u.ownedFeature.name->includes("opcodeNumber")
                and u.ownedFeature.name->includes("allowedModes"))
    }
    constraint def telemetryPointDeclaresSourceAndLimits {
        doc /* Every telemetry point of the flight dictionary names its source application and
             * binds its mnemonic and its red limits. */
        in u : SysML::ItemUsage;
        (u.itemDefinition.ownedSpecialization.general.name->includes("TelemetryPointDefinition") and u.owningNamespace.name->includes("TethysFlightDictionary")) implies
            (u.ownedFeature.name->includes("source") and u.ownedFeature.name->includes("mnemonic")
                and u.ownedFeature.name->includes("redLow") and u.ownedFeature.name->includes("redHigh"))
    }
    constraint def eventDeclaresIdAndSeverity {
        doc /* Every event of the flight dictionary binds its id, severity and fault relevance. */
        in u : SysML::ItemUsage;
        (u.itemDefinition.name->includes("EventDefinition") and u.owningNamespace.name->includes("TethysFlightDictionary")) implies
            (u.ownedFeature.name->includes("eventId") and u.ownedFeature.name->includes("severity")
                and u.ownedFeature.name->includes("fdirRelevant"))
    }
    constraint def packetDeclaresLayout {
        doc /* Every packet of the flight dictionary binds its application id, its field widths
             * and offsets and the length they must sum to. */
        in u : SysML::ItemUsage;
        (u.itemDefinition.name->includes("PacketDefinition") and u.owningNamespace.name->includes("TethysFlightDictionary")) implies
            (u.ownedFeature.name->includes("apid") and u.ownedFeature.name->includes("widths")
                and u.ownedFeature.name->includes("offsets") and u.ownedFeature.name->includes("lengthOctets"))
    }
}
