// Tool tier: the flight dictionary document set, generated from TethysFlightDictionary with
// OpenSysML's DocumentQueries library — the command, telemetry, event and packet tables and the
// packet field layout; `-render-document` writes them. Nothing in the mission tier depends on
// this file.
package TethysFlightDictionaryDocuments {
    private import ScalarValues::*;
    private import DocumentQueries::*;
    private import KerML::Root::Element;
    private import TethysFlightDictionary::*;

    // ---- queries over the dictionary package ---------------------------------------------
    calc def CommandTable :> Query {
        doc /* One row per command: mnemonic, opcode, owning application, criticality,
             * hazardous flag and the number of arguments. */
        Project(
            source = OrderBy(source = WhereFeature(
                    source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysFlightDictionary")), type = "ItemUsage"),
                    'feature' = "opcodeNumber", operator = ">=", value = "0"), property = "opcodeNumber", direction = "ascending", missing = "last", multiple = "first"),
            properties = ("mnemonic", "opcodeNumber", "application", "criticality", "hazardous", "argumentCount", "documentation")
        )
    }
    calc def TelemetryTable :> Query {
        doc /* One row per telemetry point: mnemonic, point id, source application, kind, red
             * and yellow limits, unit and sample rate. */
        Project(
            source = OrderBy(source = WhereFeature(
                    source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysFlightDictionary")), type = "ItemUsage"),
                    'feature' = "pointId", operator = ">=", value = "0"), property = "pointId", direction = "ascending", missing = "last", multiple = "first"),
            properties = ("mnemonic", "pointId", "source", "kind", "redLow", "yellowLow", "yellowHigh", "redHigh", "unitSymbol", "rate")
        )
    }
    calc def EventTable :> Query {
        doc /* One row per event: mnemonic, id, source application, severity, text and fault
             * relevance. */
        Project(
            source = OrderBy(source = WhereFeature(
                    source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysFlightDictionary")), type = "ItemUsage"),
                    'feature' = "eventId", operator = ">=", value = "0"), property = "eventId", direction = "ascending", missing = "last", multiple = "first"),
            properties = ("mnemonic", "eventId", "source", "severity", "fdirRelevant", "text")
        )
    }
    calc def PacketTable :> Query {
        doc /* One row per packet: mnemonic, application id and class, source, rate, field
             * count and length, with the layout check. */
        Project(
            source = OrderBy(source = WhereFeature(
                    source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysFlightDictionary")), type = "ItemUsage"),
                    'feature' = "packetId", operator = ">=", value = "0"), property = "apid", direction = "ascending", missing = "last", multiple = "first"),
            properties = ("mnemonic", "apid", "apidClass", "source", "rate", "fieldCount", "headerBits", "payloadBits", "lengthOctets", "layoutConsistent")
        )
    }
    calc def PacketFieldTable :> Query {
        doc /* The field layout of the named packet: one row per field with its order, bit
             * offset, width and the telemetry point it carries. */
        in packet : String;
        Project(
            source = OrderBy(source = WhereType(source = OwnedElements(source = Named(qualifiedName = packet)), type = "AttributeUsage"),
                property = "order", direction = "ascending", missing = "last", multiple = "first"),
            properties = ("name", "order", "offset", "width", "point")
        )
    }

    // ---- the dictionary document ---------------------------------------------------------
    part def FlightDictionaryDocument :> Document {
        doc /* The Argent flight dictionary: commands, telemetry, events and packets of the
             * twelve applications, as the ground system loads them. */
        :>> title = "Argent flight dictionary";
        part scope : Paragraph {
            :>> text = "Every command, telemetry point, event and packet the Argent flight software and the Meridian ground system agree on, read from TethysFlightDictionary. Opcodes, mnemonics, application ids and event ids are unique; the dictionary requirement in TethysOperations checks it.";
        }
        part commands : Section {
            :>> title = "Command dictionary";
            part table : Table {
                :>> caption = "Commands by opcode";
                calc rows : CommandTable;
            }
        }
        part telemetry : Section {
            :>> title = "Telemetry dictionary";
            part table : Table {
                :>> caption = "Telemetry points by id";
                calc rows : TelemetryTable;
            }
        }
        part events : Section {
            :>> title = "Event dictionary";
            part table : Table {
                :>> caption = "Events by id";
                calc rows : EventTable;
            }
        }
        part packets : Section {
            :>> title = "Packet definitions";
            part table : Table {
                :>> caption = "Packets by application id";
                calc rows : PacketTable;
            }
            part layout : Table {
                :>> caption = "Field layout of the first housekeeping packet";
                calc rows : PacketFieldTable { in :>> packet = "TethysFlightDictionary::cdhHkPacket01"; }
            }
        }
    }
}
