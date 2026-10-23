// Tool-tier companion of TethysSoftwareRequirements: the satisfactions of the ground-software
// rows by the Meridian Operations Suite and the derivations from its GS- rows (both need
// TethysGroundSoftware, which the pilot resolves only from a later-numbered file), the
// derivation/satisfaction coverage queries and the software requirements document. This is the
// only WP software-requirements file that references an OpenSysML library package
// (DocumentQueries).
package TethysSoftwareRequirementsTooling {
    doc /* Coverage queries and the rendered software requirements document.
         * `UnderivedSoftwareRequirements` and `UnsatisfiedSoftwareRequirements` are gates: every
         * TF-/TM- row has at least one derivation source and one satisfier, so both pinned runs
         * are empty. `UncoveredFlightSoftware` and `UncoveredGroundSoftware` list the software
         * elements of the flight software and of the Meridian suite that satisfy no row; both are
         * empty too. `SoftwareRequirementsDocument` renders the tiers with their derivation
         * sources, satisfiers. */

    private import ScalarValues::*;
    private import KerML::Root::*;
    private import DocumentQueries::*;
    private import RequirementDerivation::*;
    private import TethysSoftwareRequirements::*;
    private import TethysGroundSoftware::meridianOperationsSuite;

    // ---- the GS- rows of TethysGroundSoftware stop being local: the TM rows derive from them -
    #derivation connection { end #original ::> TethysGroundSoftware::commandValidation; end #derive ::> commandValidation; end #derive ::> hazardousApproval; }
    #derivation connection { end #original ::> TethysGroundSoftware::sequenceClearance; end #derive ::> sequenceClearance; }
    #derivation connection { end #original ::> TethysGroundSoftware::dictionaryDrivenTelemetry; end #derive ::> telemetryDecommutation; end #derive ::> limitAlarming; }
    #derivation connection { end #original ::> TethysGroundSoftware::plannedPassesFitTheLink; end #derive ::> passPlanningVolume; }

    // ---- satisfaction of the TM rows by the Meridian Operations Suite ------------------------
    satisfy commandValidation by meridianOperationsSuite.moc.commandBuilder { doc /* Meridian Forge, the command builder. */ }
    satisfy hazardousApproval by meridianOperationsSuite.moc.commandBuilder { doc /* Meridian Forge holds hazardous commands for the second approver. */ }
    satisfy sequenceClearance by meridianOperationsSuite.moc.sequencer { doc /* Meridian Warden, the flight rule checker. */ }
    satisfy telemetryDecommutation by meridianOperationsSuite.moc.telemetryServer { doc /* Meridian Lantern, the telemetry server. */ }
    satisfy limitAlarming by meridianOperationsSuite.moc.telemetryServer { doc /* Meridian Lantern alarms from the dictionary and the limit table. */ }
    satisfy trendingAutomation by meridianOperationsSuite.moc.telemetryServer { doc /* Meridian Lantern trends every housekeeping point. */ }
    satisfy flightDynamicsProducts by meridianOperationsSuite.fdf.flightDynamicsTool { doc /* Meridian Sextant, the flight dynamics tool. */ }
    satisfy passPlanningVolume by meridianOperationsSuite.moc.passPlanner { doc /* Meridian Almanac, the pass planner. */ }
    satisfy archiveRetention by meridianOperationsSuite.sds.dataArchive { doc /* Meridian Vault, the data archive. */ }
    satisfy anomalyDisposition by meridianOperationsSuite.moc.anomalyTracker { doc /* Meridian Ledger, the anomaly tracker. */ }
    satisfy proximityGoNoGo by meridianOperationsSuite.moc.proximityPlanner { doc /* Meridian Compass, the proximity planner. */ }
    satisfy simulatorFidelity by meridianOperationsSuite.testBeds.flatsat { doc /* Meridian Anvil, the hardware-in-the-loop flatsat. */ }
    satisfy simulatorFidelity by meridianOperationsSuite.testBeds.trajectoryTool { doc /* Meridian Mirror, the flight-software-in-the-loop simulator. */ }
    satisfy simulatorFidelity by meridianOperationsSuite.testBeds.dynamicsSimulator { doc /* Meridian Orrery, the dynamics simulator. */ }
    satisfy simulatorFidelity by meridianOperationsSuite.testBeds.captureRig { doc /* Meridian Capstan, the capture rig controller. */ }

    // ---- coverage queries --------------------------------------------------------------------
    calc def SoftwareRequirementRows :> Query {
        doc /* Every TF-/TM- requirement usage of TethysSoftwareRequirements: the requirement
             * usages under the package that are not satisfy references. */
        Except(
            source = WhereType(source = Descendants(source = Named(qualifiedName = "TethysSoftwareRequirements")), type = "RequirementUsage"),
            exclude = WhereType(source = Descendants(source = Named(qualifiedName = "TethysSoftwareRequirements")), type = "SatisfyRequirementUsage")
        )
    }

    calc def UnderivedSoftwareRequirements :> Query {
        doc /* The software requirements with no derivation source. The pinned run is empty. */
        Project(
            source = WhereRelated(source = SoftwareRequirementRows(), relationshipKind = "derivation", direction = "incoming", exists = false),
            properties = ("shortName", "name")
        )
    }

    calc def UnsatisfiedSoftwareRequirements :> Query {
        doc /* The software requirements no software element satisfies. The pinned run is empty. */
        Project(
            source = WhereRelated(source = SoftwareRequirementRows(), relationshipKind = "satisfaction", direction = "incoming", exists = false),
            properties = ("shortName", "name")
        )
    }

    calc def FlightSoftwareElements :> Query {
        doc /* The software elements of the Argent flight software: the executive, the bus, the
             * core services and the twelve applications owned by ArgentFlightSoftware. */
        Except(
            source = WhereType(source = Descendants(source = Named(qualifiedName = "TethysFlightSoftware::ArgentFlightSoftware"), maxDepth = 1), type = "PartUsage"),
            exclude = Union(
                source = WhereType(source = Descendants(source = Named(qualifiedName = "TethysFlightSoftware::ArgentFlightSoftware"), maxDepth = 1), type = "ConnectionUsage"),
                other = Named(qualifiedName = ("TethysFlightSoftware::ArgentFlightSoftware::components", "TethysFlightSoftware::ArgentFlightSoftware::flightImage", "TethysFlightSoftware::ArgentFlightSoftware::safeImage"))
            )
        )
    }

    calc def GroundSoftwareElements :> Query {
        doc /* The software elements of the Meridian Operations Suite: every part typed by a
             * GroundSoftwareComponent that the suite's centre, flight dynamics, science data
             * system and test beds redefine (the twelve the suite lists as `components`). */
        WhereType(
            source = Union(
                source = Union(
                    source = Descendants(source = Named(qualifiedName = "TethysGroundSoftware::SoftwareOperationsCentre"), maxDepth = 1),
                    other = Descendants(source = Named(qualifiedName = "TethysGroundSoftware::SoftwareFlightDynamics"), maxDepth = 1)
                ),
                other = Union(
                    source = Descendants(source = Named(qualifiedName = "TethysGroundSoftware::SoftwareScienceDataSystem"), maxDepth = 1),
                    other = Descendants(source = Named(qualifiedName = "TethysGroundSoftware::SimulatedTestBedSet"), maxDepth = 1)
                )
            ),
            type = "GroundSoftwareComponent"
        )
    }

    calc def UncoveredFlightSoftware :> Query {
        doc /* The flight software elements that satisfy no software requirement. The pinned run
             * is empty. */
        Project(
            source = WhereRelated(source = FlightSoftwareElements(), relationshipKind = "satisfaction", direction = "outgoing", exists = false),
            properties = ("qualifiedName")
        )
    }

    calc def UncoveredGroundSoftware :> Query {
        doc /* The Meridian suite elements that satisfy no software requirement. The pinned run
             * is empty. */
        Project(
            source = WhereRelated(source = GroundSoftwareElements(), relationshipKind = "satisfaction", direction = "outgoing", exists = false),
            properties = ("qualifiedName")
        )
    }

    calc def SoftwareRequirementMatrix :> Query {
        doc /* Every software requirement with its verification method and level, the system rows
             * it derives from directly and the software elements that satisfy it. */
        Project(
            source = SoftwareRequirementRows(),
            properties = ("shortName", "name", "Verification::method", "Verification::level"),
            columns = (
                RelatedColumn(name = "derivedFrom", relationshipKind = "derivation", direction = "incoming", maxDepth = 1, aggregate = "list"),
                RelatedColumn(name = "satisfiedBy", relationshipKind = "satisfaction", direction = "incoming", aggregate = "list"),
                RelatedColumn(name = "satisfiers", relationshipKind = "satisfaction", direction = "incoming", aggregate = "count")
            )
        )
    }

    // ---- the software requirements document --------------------------------------------------
    part def SoftwareRequirementsDocument :> Document {
        doc /* The software requirements document: the flight and ground tiers with their
             * derivation sources and satisfiers, and the coverage gates; the satisfaction verdicts are
             * the pinned -satisfy runs, because the verdict query cannot reach objects nested
             * as deep as the flight software's components. */
        attribute :>> title default = "Tethys software requirements";
        part scope : Paragraph {
            attribute :>> text = "The flight software requirements (TF-) on the Argent Flight Executive, its core services and applications, and the ground software requirements (TM-) on the Meridian Operations Suite; each row derives from the system rows it refines and names the software element that satisfies it; the verdicts of the constraints are the pinned satisfaction runs.";
        }
        part rows : Table {
            attribute :>> caption = "Software requirements: derivation sources and satisfiers";
            calc rows : SoftwareRequirementMatrix;
        }
        part gates : Section {
            attribute :>> title = "Coverage gates";
            part underived : Table {
                attribute :>> caption = "Software requirements without a derivation source (expected empty)";
                calc rows : UnderivedSoftwareRequirements;
            }
            part unsatisfied : Table {
                attribute :>> caption = "Software requirements without a satisfier (expected empty)";
                calc rows : UnsatisfiedSoftwareRequirements;
            }
            part flight : Table {
                attribute :>> caption = "Flight software elements satisfying no requirement (expected empty)";
                calc rows : UncoveredFlightSoftware;
            }
            part ground : Table {
                attribute :>> caption = "Meridian suite elements satisfying no requirement (expected empty)";
                calc rows : UncoveredGroundSoftware;
            }
        }
    }
}
