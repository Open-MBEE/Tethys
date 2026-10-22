// Tool tier: the software ICD documents. One document per software ICD of TethysSoftwareIcds
// (SCD-020 bus protocol, SCD-021 space-link profile, SCD-022 relay profile, SCD-023 register
// maps) and the inter-application message catalogue, each built from DocumentQueries over the
// model: the ends and parameters through the IcdEnds and IcdParameters queries of
// TethysIcdDocuments, the rate sets and register maps through nested-member projections.
// The message-catalogue view exposes the item definitions only (a filtered expose), so the
// library members the package privately imports stay out of the table.
package TethysSoftwareIcdDocuments {
    private import ScalarValues::*;
    private import DocumentQueries::*;
    private import KerML::Root::Element;
    private import TethysIcdDocuments::IcdEnds;
    private import TethysIcdDocuments::IcdParameters;

    // ---- queries over the software ICD package -----------------------------------------
    calc def Messages :> Query {
        doc /* One row per message type of the catalogue: the item definitions of
             * TethysSoftwareIcds with their documentation. */
        Project(
            source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysSoftwareIcds")), type = "ItemDefinition"),
            properties = ("name", "documentation")
        )
    }
    calc def MessageFigures :> Query {
        doc /* One row per message of the catalogue part with its identifier, length and period,
             * read from the message type each item is typed by. */
        Project(
            source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysSoftwareIcds::MessageCatalogue")), type = "ItemUsage"),
            properties = ("name", "type", "apid", "length", "period")
        )
    }
    calc def Topics :> Query {
        doc /* One row per interface attached to the flight software: the message topics and the
             * ICD usages of argentSoftwareIcds, with the publisher and subscribers each names. */
        Project(
            source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysSoftwareIcds::argentSoftwareIcds")), type = "InterfaceUsage"),
            properties = ("name", "type", "documentation")
        )
    }
    calc def RateSets :> Query {
        doc /* One row per rate set of the space-link profile: the mode and its rates. */
        Project(
            source = WhereName(
                source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysSoftwareIcds::SpaceLinkProfileIcd")), type = "AttributeUsage"),
                operator = "endsWith", value = "Rates"),
            properties = ("name", "mode", "downlinkRate", "uplinkRate", "housekeepingPeriod")
        )
    }
    calc def Registers :> Query {
        doc /* One row per register of the named register map: address, width, meaning, access. */
        in map : String;
        Project(
            source = WhereType(source = OwnedElements(source = Named(qualifiedName = map)), type = "AttributeUsage"),
            properties = ("name", "address", "width", "meaning", "access")
        )
    }

    // ---- the message catalogue --------------------------------------------------------------
    view messageTypes {
        doc /* The message item definitions: the item defs of the software ICD package and of
             * the packet bases it imports, and only those. The filter excludes the part,
             * interface and metadata definitions, which are item definitions in the metamodel
             * (PartDefinition and MetadataDefinition specialise ItemDefinition). */
        expose TethysSoftwareIcds::*[@SysML::ItemDefinition and not (@SysML::PartDefinition) and not (@SysML::MetadataDefinition)];
        render Views::asElementTable;
    }
    part def MessageCatalogueDocument :> Document {
        doc /* The inter-application message catalogue: message types, their figures, and the
             * topics that carry them between the applications. */
        :>> title = "SCD-019 Inter-application message catalogue";
        part scope : Paragraph {
            :>> text = "Every message between the flight applications and services is a space packet on the AABP-1 software bus; its application identifier is the topic, its publisher and subscribers are the ends of the topic interface.";
        }
        part types : Section {
            :>> title = "Message types";
            part table : Table {
                :>> caption = "Message item definitions";
                calc rows : Messages;
            }
        }
        part figures : Section {
            :>> title = "Identifiers, lengths and periods";
            part table : Table {
                :>> caption = "Figures per catalogue message";
                calc rows : MessageFigures;
            }
        }
        part topics : Section {
            :>> title = "Topics and ICD attachments";
            part table : Table {
                :>> caption = "Interfaces attached to the flight software";
                calc rows : Topics;
            }
        }
    }

    // ---- one document per software ICD -----------------------------------------------------
    part def BusProtocolIcdDocument :> Document {
        doc /* SCD-020, the AABP-1 on-board bus protocol. */
        :>> title = "SCD-020 AABP-1 on-board bus protocol";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysSoftwareIcds::OnBoardBusProtocolIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Protocol parameters";
            part table : Table {
                :>> caption = "Framing, addressing, schedule and error handling";
                calc rows : IcdParameters { in :>> icd = "TethysSoftwareIcds::OnBoardBusProtocolIcd"; }
            }
        }
    }
    part def SpaceLinkProfileIcdDocument :> Document {
        doc /* SCD-021, the MLS-2 space-link profile over CCSDS Space Packets. */
        :>> title = "SCD-021 MLS-2 space-link profile";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysSoftwareIcds::SpaceLinkProfileIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Profile parameters";
            part table : Table {
                :>> caption = "Packets, frames, virtual channels and the rate envelope";
                calc rows : IcdParameters { in :>> icd = "TethysSoftwareIcds::SpaceLinkProfileIcd"; }
            }
        }
        part rateSets : Section {
            :>> title = "Rate sets per tug mode";
            part table : Table {
                :>> caption = "Downlink and uplink rates and housekeeping period by mode; safeRates is the fallback";
                calc rows : RateSets;
            }
        }
    }
    part def InspectorRelayProfileIcdDocument :> Document {
        doc /* SCD-022, the relay profile between the tug and Wren. */
        :>> title = "SCD-022 Tug–inspector relay profile";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysSoftwareIcds::InspectorRelaySoftwareIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Profile parameters";
            part table : Table {
                :>> caption = "Rates, identifiers, store-and-forward and acknowledgement";
                calc rows : IcdParameters { in :>> icd = "TethysSoftwareIcds::InspectorRelaySoftwareIcd"; }
            }
        }
    }
    part def RegisterMapIcdDocument :> Document {
        doc /* SCD-023, the remote interface unit register maps. */
        :>> title = "SCD-023 Remote interface unit register maps";
        part ends : Section {
            :>> title = "Interface ends";
            part table : Table {
                :>> caption = "Ends and their port types";
                calc rows : IcdEnds { in :>> icd = "TethysSoftwareIcds::RemoteInterfaceUnitRegisterIcd"; }
            }
        }
        part parameters : Section {
            :>> title = "Register access parameters";
            part table : Table {
                :>> caption = "Address and data widths, access frame and burst";
                calc rows : IcdParameters { in :>> icd = "TethysSoftwareIcds::RemoteInterfaceUnitRegisterIcd"; }
            }
        }
        part thermalPropulsion : Section {
            :>> title = "Thermal and propulsion unit";
            part table : Table {
                :>> caption = "Registers of the thermal and propulsion remote interface unit";
                calc rows : Registers { in :>> map = "TethysSoftwareIcds::ThermalPropulsionRiuRegisterMap"; }
            }
        }
        part mechanism : Section {
            :>> title = "Mechanism unit";
            part table : Table {
                :>> caption = "Registers of the mechanism remote interface unit";
                calc rows : Registers { in :>> map = "TethysSoftwareIcds::MechanismRiuRegisterMap"; }
            }
        }
    }
}
