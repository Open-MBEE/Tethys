// F-I05 (docs/findings/integration.md): at OpenSysML 98d8eca77 the self-check visits the implied
// ConjugatedPortDefinition ~P of every port def as a Definition. It owns no documentation, so a
// rule "every definition carries a doc comment" fails on ~P unless it exempts the conjugate, as
// TethysHouseRules::definitionHasDocumentation now does (the second rule here).
package 'F-I05-conjugated-port-definition' {
    private import ScalarValues::*;
    item def Packet {
        doc /* A packet. */
    }
    port def PacketPort {
        doc /* A documented port def; its conjugate ~PacketPort is implied and undocumented. */
        out item packet : Packet;
    }
    package Rules {
        private import SequenceFunctions::*;
        constraint def definitionHasDocumentation {
            doc /* Fails on PacketPort::~PacketPort. */
            in d : SysML::Definition;
            not d.documentation->isEmpty()
        }
        constraint def declaredDefinitionHasDocumentation {
            doc /* Holds: the implied conjugate is exempt. */
            in d : SysML::Definition;
            d istype SysML::ConjugatedPortDefinition or not d.documentation->isEmpty()
        }
    }
}
