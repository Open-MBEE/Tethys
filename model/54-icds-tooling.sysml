// Tool tier: the ICD document set, generated from TethysIcds with OpenSysML's DocumentQueries
// library. One register document over every ICD and one document per ICD class with its
// parameter table and its verification case; `-render-document` and `-render-documents`
// write them. Nothing in the mission tier depends on this file.
package TethysIcdDocuments {
    private import ScalarValues::*;
    private import DocumentQueries::*;
    private import KerML::Root::Element;
    private import TethysIcds::*;

    // ---- queries over the ICD package ----------------------------------------------------
    calc def IcdRegister :> Query {
        doc /* One row per ICD class in TethysIcds and in TethysSoftwareIcds (the software ICDs,
             * TI-02x): name and documentation. */
        Project(
            source = WhereType(source = OwnedElements(source = (Named(qualifiedName = "TethysIcds"), Named(qualifiedName = "TethysSoftwareIcds"))), type = "InterfaceDefinition"),
            properties = ("name", "documentation")
        )
    }
    calc def IcdRequirements :> Query {
        doc /* The interface requirements of TethysIcds and TethysSoftwareIcds. */
        Project(
            source = WhereType(source = OwnedElements(source = (Named(qualifiedName = "TethysIcds"), Named(qualifiedName = "TethysSoftwareIcds"))), type = "RequirementUsage"),
            properties = ("name", "documentation")
        )
    }
    calc def IcdVerifications :> Query {
        doc /* The verification cases of TethysIcds and TethysSoftwareIcds with the ICD document
             * each covers. */
        Project(
            source = WhereType(source = OwnedElements(source = (Named(qualifiedName = "TethysIcds"), Named(qualifiedName = "TethysSoftwareIcds"))), type = "VerificationCaseUsage"),
            properties = ("name", "documentation")
        )
    }
    calc def IcdEnds :> Query {
        doc /* The ends of the named ICD with their port types: its own ends and those it
             * inherits from the backbone interface definition it specialises. */
        in icd : String;
        Project(
            source = WhereType(
                source = OwnedElements(source = (Named(qualifiedName = icd), RelatedElements(
                    source = Named(qualifiedName = icd), relationshipKind = "specialization", direction = "outgoing", maxDepth = 1))),
                type = "PortUsage"),
            properties = ("name", "type")
        )
    }
    calc def IcdParameters :> Query {
        doc /* One row per parameter the named ICD carries: its name, quantity type and the
             * value the model binds to it, read through the `valuation` property. */
        in icd : String;
        Project(
            source = WhereType(source = OwnedElements(source = Named(qualifiedName = icd)), type = "AttributeUsage"),
            properties = ("name", "type", "valuation")
        )
    }

    // ---- the register document -----------------------------------------------------------
    part def IcdRegisterDocument :> Document {
        doc /* The Tethys ICD register: every ICD class, the interface requirements and the
             * verification cases that close them. */
        :>> title = "Tethys Retrieval interface control document register";
        part scope : Paragraph {
            :>> text = "One interface control document per TethysInterfaces interface definition, each specialising its interface def with the parameters both sides must agree on, bound to both ends, under the control authority its InterfaceControl metadata names; the software ICDs (TI-02x) of TethysSoftwareIcds profile the packet and data-bus interfaces down to message, frame and register level.";
        }
        part classes : Section {
            :>> title = "ICD classes";
            part register : Table {
                :>> caption = "Interface control documents of the mission";
                calc rows : IcdRegister;
            }
        }
        part requirements : Section {
            :>> title = "Interface requirements";
            part register : Table {
                :>> caption = "Requirements that both sides conform to each ICD";
                calc rows : IcdRequirements;
            }
        }
        part verificationCases : Section {
            :>> title = "Interface verification";
            part register : Table {
                :>> caption = "Verification case per ICD";
                calc rows : IcdVerifications;
            }
        }
    }

    // ---- one document per ICD class: ends, then every parameter it carries ---------------
    part def SpaceGroundIcdDocument :> Document {
        doc /* ICD-003, Argent ↔ Meridian. */
        :>> title = "ICD-003 Space–ground RF interface";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::SpaceGroundIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::SpaceGroundIcd"; }
            }
        }
    }
    part def LaunchIcdDocument :> Document {
        doc /* ICD-002, stack ↔ Arcturus-5H. */
        :>> title = "ICD-002 Spacecraft–launcher interface";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::LaunchIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::LaunchIcd"; }
            }
        }
    }
    part def TugInspectorIcdDocument :> Document {
        doc /* ICD-001, Argent ↔ Wren stowed. */
        :>> title = "ICD-001 Tug–inspector umbilical interface";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::TugInspectorIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::TugInspectorIcd"; }
            }
        }
    }
    part def InspectorRelayIcdDocument :> Document {
        doc /* ICD-004, Wren ↔ Argent proximity link. */
        :>> title = "ICD-004 Inspector relay link";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::InspectorRelayIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::InspectorRelayIcd"; }
            }
        }
    }
    part def CaptureIcdDocument :> Document {
        doc /* ICD-005, Argent ↔ Amaranth. */
        :>> title = "ICD-005 Capture interface";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::CaptureIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::CaptureIcd"; }
            }
        }
    }
    part def DockingIcdDocument :> Document {
        doc /* ICD-006, Argent ↔ visiting vehicle. */
        :>> title = "ICD-006 Docking interface";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::DockingIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::DockingIcd"; }
            }
        }
    }
    part def InspectorDispenserIcdDocument :> Document {
        doc /* ICD-007, the dispenser. */
        :>> title = "ICD-007 Inspector dispenser interface";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::InspectorDispenserIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::InspectorDispenserIcd"; }
            }
        }
    }
    part def InspectorThermalIcdDocument :> Document {
        doc /* ICD-008, Wren stowed thermal. */
        :>> title = "ICD-008 Inspector thermal interface";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::InspectorThermalIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::InspectorThermalIcd"; }
            }
        }
    }
    part def PropellantFeedIcdDocument :> Document {
        doc /* ICD-009, fill and drain. */
        :>> title = "ICD-009 Propellant feed interface";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::PropellantFeedIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::PropellantFeedIcd"; }
            }
        }
    }
    part def PacketInterfaceDocument :> Document {
        doc /* TCD-010, the packet dictionary interface. */
        :>> title = "TCD-010 Command and telemetry packet interface";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::PacketInterface"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::PacketInterface"; }
            }
        }
    }
    part def PowerIcdDocument :> Document {
        doc /* ICD-011, the regulated bus. */
        :>> title = "ICD-011 Regulated power interface";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::PowerIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::PowerIcd"; }
            }
        }
    }
    part def HighVoltagePowerIcdDocument :> Document {
        doc /* ICD-012, the high-voltage bus. */
        :>> title = "ICD-012 High-voltage power interface";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::HighVoltagePowerIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::HighVoltagePowerIcd"; }
            }
        }
    }
    part def DataBusIcdDocument :> Document {
        doc /* ICD-013, the on-board data bus. */
        :>> title = "ICD-013 Data bus interface";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::DataBusIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::DataBusIcd"; }
            }
        }
    }
    part def ThermalIcdDocument :> Document {
        doc /* ICD-014, conductive thermal interfaces. */
        :>> title = "ICD-014 Thermal interface";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysIcds::ThermalIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Interface parameters";
            part table : Table {
                :>> caption = "Parameters both sides agree on";
                calc rows : IcdParameters { in :>> icd = "TethysIcds::ThermalIcd"; }
            }
        }
    }
}
