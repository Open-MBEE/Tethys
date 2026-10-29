// The document set generated from the model: the system description, the interface control
// documents, the verification matrix and the risk register. Each document is a part def
// specializing DocumentQueries::Document whose tables, lists and definitions are queries over the
// sibling packages and whose diagrams are the views in TethysViews; `-render-documents` writes
// the set in Markdown or HTML, `-render-document … -doc-form pdf` one document as PDF.
package TethysDocuments {
    private import DocumentQueries::*;
    private import KerML::Root::Element;
    private import ScalarValues::*;

    // ---- queries ----------------------------------------------------------------------------
    calc def MissionRequirements :> Query {
        doc /* The L1 requirements with their identifier, name, text and tier, and the
             * verification method, level and stage each declares as @Verification, read through
             * the metadata def's features. */
        Project(
            source = WhereType(
                source = OwnedElements(source = Named(qualifiedName = "TethysRequirements")),
                type = "RequirementUsage"),
            properties = ("shortName", "name", "documentation", "tier", "Verification::method", "Verification::level", "Verification::stage"))
    }
    calc def RequirementText :> Query {
        doc /* Identifier and statement of every L1 requirement, for the definitions block. */
        Project(
            source = WhereType(
                source = OwnedElements(source = Named(qualifiedName = "TethysRequirements")),
                type = "RequirementUsage"),
            properties = ("shortName", "documentation"))
    }
    calc def Segments :> Query {
        doc /* The system's segment-level parts: name, type and description. An InterfaceUsage
             * is a PartUsage (SysML v2.1 §8.3.12), so the system-level interfaces the system
             * also owns are taken out again; SystemInterfaces lists them. */
        Project(
            source = Except(
                source = WhereType(
                    source = OwnedElements(source = Named(qualifiedName = "TethysSystem::tethysSystem")),
                    type = "PartUsage"),
                exclude = WhereType(
                    source = OwnedElements(source = Named(qualifiedName = "TethysSystem::tethysSystem")),
                    type = "InterfaceUsage")),
            properties = ("name", "documentation"))
    }
    calc def SystemInterfaces :> Query {
        doc /* The top-level interface usages: each one is an ICD. */
        Project(
            source = WhereType(
                source = OwnedElements(source = Named(qualifiedName = "TethysSystem::tethysSystem")),
                type = "InterfaceUsage"),
            properties = ("name"))
    }
    calc def InterfaceDefinitions :> Query {
        doc /* Every interface definition, with the description an ICD opens with. */
        Project(
            source = WhereType(
                source = OwnedElements(source = Named(qualifiedName = "TethysInterfaces")),
                type = "InterfaceDefinition"),
            properties = ("name", "documentation"))
    }
    calc def InterfaceEnds :> Query {
        doc /* The two ends of every interface definition, with the port each is typed by. */
        Project(
            source = WhereType(
                source = Descendants(
                    source = WhereType(
                        source = OwnedElements(source = Named(qualifiedName = "TethysInterfaces")),
                        type = "InterfaceDefinition"),
                    maxDepth = 1),
                type = "PortUsage"),
            properties = ("owner", "name", "type"))
    }
    calc def Ports :> Query {
        doc /* The port definitions ICDs reference, with what crosses each. */
        Project(
            source = WhereType(
                source = OwnedElements(source = Named(qualifiedName = "TethysInterfaces")),
                type = "PortDefinition"),
            properties = ("name", "documentation"))
    }
    calc def Items :> Query {
        doc /* The items that flow across the interfaces. An InterfaceDefinition is a
             * PartDefinition and so an ItemDefinition (SysML v2.1 §8.3.12), so the interface
             * definitions of the package are taken out again; InterfaceDefinitions lists them. */
        Project(
            source = Except(
                source = WhereType(
                    source = OwnedElements(source = Named(qualifiedName = "TethysInterfaces")),
                    type = "ItemDefinition"),
                exclude = WhereType(
                    source = OwnedElements(source = Named(qualifiedName = "TethysInterfaces")),
                    type = ("PartDefinition", "InterfaceDefinition"))),
            properties = ("name", "documentation"))
    }
    calc def TugSubsystems :> Query {
        doc /* The tug's subsystems: the parts the Tug definition owns, less its interfaces,
             * rather than the few the argent usage redefines. */
        Project(
            source = Except(
                source = WhereType(
                    source = OwnedElements(source = Named(qualifiedName = "TethysTug::Tug")),
                    type = "PartUsage"),
                exclude = WhereType(
                    source = OwnedElements(source = Named(qualifiedName = "TethysTug::Tug")),
                    type = "InterfaceUsage")),
            properties = ("name", "type"))
    }
    calc def FlightPhases :> Query {
        doc /* The flight phases in declaration (succession) order. */
        Project(
            source = WhereType(
                source = OwnedElements(source = Named(qualifiedName = "TethysMission::flightTimeline")),
                type = "OccurrenceUsage"),
            properties = ("name", "type"))
    }
    calc def Risks :> Query {
        doc /* Every element annotated as a risk (RiskMetadata) under the packages that own
             * the risk register and the hazard log, with its documentation. */
        Project(
            source = WhereMetadata(
                source = Descendants(source = Named(qualifiedName = ("TethysRisk", "TethysSafety"))),
                'metadata' = "RiskMetadata::Risk"),
            properties = ("name", "documentation"))
    }

    // ---- documents --------------------------------------------------------------------------
    // The documents as usages, so one can cross-reference a block of another by dot notation.
    ref systemDescription : SystemDescription;
    ref interfaceControlDocuments : InterfaceControlDocuments;
    ref verificationMatrix : VerificationMatrix;

    part def SystemDescription :> Document {
        doc /* The mission and system description: what Tethys Retrieval is, its segments, its
             * interfaces and its L1 requirements, every table and diagram drawn from the model. */
        attribute redefines title = "Tethys Retrieval — System Description";

        part summary : Paragraph {
            attribute redefines text = "Tethys Retrieval is a fictional asteroid-retrieval mission: the solar-electric tug Argent flies to the small near-Earth asteroid 2031 QX Amaranth, characterises it with the free-flying inspector Wren, captures and despins it, and returns it to a lunar distant retrograde orbit for the visiting vehicle Lantern. Every name and number is invented; the physics is not.";
        }
        part provenance : Paragraph {
            part lead : Span { attribute redefines text = "This document is"; }
            part generated : Span { attribute redefines text = "generated"; attribute redefines style = "emphasis"; }
            part fromText : Span { attribute redefines text = "from the SysML v2 model by"; }
            part tool : Span { attribute redefines text = "sysml -render-documents"; attribute redefines style = "code"; }
            part see : Span { attribute redefines text = "; the interface set is"; }
            part icdRef : Ref { ref redefines target = interfaceControlDocuments.interfaces; }
            part andText : Span { attribute redefines text = "and the verification matrix"; }
            part vcrmRef : Ref { ref redefines target = verificationMatrix.matrix; }
        }

        part system : Section {
            attribute redefines title = "The system";
            part intro : Paragraph {
                attribute redefines text = "The mission is one system of five segment-level parts: the flight segment (tug and inspector), the launch segment, the ground segment, the target body and the visiting vehicle that is external to the mission and present only through its docking interface.";
            }
            part segments : Table {
                attribute redefines caption = "Segment-level parts of the system";
                calc rows : Segments;
            }
            part icd : Diagram {
                attribute redefines caption = "Segment-level interface control (positioned by TethysLayout)";
                ref redefines source = TethysViews::segmentInterfaces;
            }
            part overview : Diagram {
                attribute redefines caption = "The system's parts, ports and interfaces";
                ref redefines source = TethysViewsTooling::systemOverview;
            }
        }

        part tug : Section {
            attribute redefines title = "The tug Argent";
            part subsystems : Table {
                attribute redefines caption = "Subsystems of the flight tug";
                calc rows : TugSubsystems;
            }
            part power : Diagram {
                attribute redefines caption = "The power bus from the electrical power subsystem to every load";
                ref redefines source = TethysViews::tugPowerBus;
            }
        }

        part timeline : Section {
            attribute redefines title = "Mission timeline";
            part phases : List {
                attribute redefines style = "number";
                calc items : FlightPhases;
            }
            part tree : Diagram {
                attribute redefines caption = "The flight timeline: phases and the events that bound them";
                attribute redefines direction = "LR";
                ref redefines source = TethysViews::missionTimeline;
            }
        }

        part requirements : Section {
            attribute redefines title = "Mission requirements";
            part text : Definitions {
                attribute redefines term = "shortName";
                attribute redefines description = "documentation";
                calc rows : RequirementText;
            }
            part tree : Diagram {
                attribute redefines caption = "The L1 requirements";
                ref redefines source = TethysViews::requirementsTree;
            }
        }
    }

    part def InterfaceControlDocuments :> Document {
        doc /* The interface control document set: one entry per interface definition, the ends
             * and ports of each, the port definitions and the items that cross them. */
        attribute redefines title = "Tethys Retrieval — Interface Control Documents";

        part intro : Paragraph {
            part lead : Span { attribute redefines text = "Every boundary in the mission is controlled by one interface definition in"; }
            part pkg : Span { attribute redefines text = "TethysInterfaces"; attribute redefines style = "code"; }
            part tail : Span { attribute redefines text = "; the segment-level usages are drawn in the"; }
            part back : Ref { ref redefines target = systemDescription.system; }
        }
        part interfaces : Section {
            attribute redefines title = "Interface definitions";
            part list : Table {
                attribute redefines caption = "Interface definitions, one ICD each";
                calc rows : InterfaceDefinitions;
            }
            part ends : Table {
                attribute redefines caption = "Interface ends and the port type at each";
                attribute redefines groupBy = "owner";
                calc rows : InterfaceEnds;
            }
            part usages : Table {
                attribute redefines caption = "System-level interface usages";
                calc rows : SystemInterfaces;
            }
        }
        part ports : Section {
            attribute redefines title = "Ports";
            part table : Table {
                attribute redefines caption = "Port definitions";
                calc rows : Ports;
            }
        }
        part items : Section {
            attribute redefines title = "Items crossing the interfaces";
            part table : Table {
                attribute redefines caption = "Item definitions";
                calc rows : Items;
            }
        }
        part drawing : Section {
            attribute redefines title = "Flight segment interfaces";
            part wiring : Diagram {
                attribute redefines caption = "Tug ↔ inspector: carrier umbilical and relay link";
                ref redefines source = TethysViews::flightSegmentWiring;
            }
        }
    }

    part def VerificationMatrix :> Document {
        doc /* The verification cross-reference matrix: every L1 requirement with its tier,
             * statement and the method, level and stage it declares as @Verification. */
        attribute redefines title = "Tethys Retrieval — Verification Matrix";

        part intro : Paragraph {
            attribute redefines text = "One row per requirement. The verification cases that close each row are added by the verification package; a requirement without one stays visible here as uncovered.";
        }
        part matrix : Section {
            attribute redefines title = "Requirements";
            part table : Table {
                attribute redefines caption = "L1 requirements";
                attribute redefines columnLabels = ("Id", "Name", "Statement", "Tier", "Method", "Level", "Stage");
                calc rows : MissionRequirements;
            }
            part drawn : Diagram {
                attribute redefines caption = "The same requirements as an element table";
                ref redefines source = TethysViews::requirementsTable;
            }
        }
    }

    part def RiskRegister :> Document {
        doc /* The risk register: every element annotated RiskMetadata::Risk under the mission
             * packages. Empty until the safety and risk package annotates its risks, and visibly
             * so — the table renders with its header. */
        attribute redefines title = "Tethys Retrieval — Risk Register";

        part intro : Paragraph {
            attribute redefines text = "Risks are elements of the model annotated with RiskMetadata::Risk; this register is their current list.";
        }
        part register : Section {
            attribute redefines title = "Open risks";
            part table : Table {
                attribute redefines caption = "Elements annotated as risks";
                calc rows : Risks;
            }
        }
    }
}
