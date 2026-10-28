// The software architecture document set rendered from the model: the architecture description,
// the requirements specification, the design descriptions (one per flight application and per
// Meridian component), the interface control volume, the dictionary volume, the test plan and
// the operations handbook, with the index TethysSoftwareDocuments registers them in. Every
// section is a query or a view over the software packages; the only prose is the scope and
// reading-order paragraphs. Tool tier: DocumentQueries is OpenSysML's library, so this file is
// not part of the pilot-portable mission model.
package TethysSoftwareDocumentsTooling {
    doc /* The document set. Each document composes what the earlier tooling packages already
         * define: the requirements specification specialises SoftwareRequirementsDocument, the
         * dictionary volume specialises FlightDictionaryDocument, the test plan specialises
         * SoftwareVcrmDocument, the interface control volume refers to the five software
         * interface documents and reuses their queries, and the design descriptions bind the
         * shared design queries to one application or component each. Documents are rendered one
         * at a time with -render-document and together with -render-documents. */

    private import ScalarValues::*;
    private import DocumentQueries::*;
    private import TethysSoftwareRequirementsTooling::SoftwareRequirementRows;
    private import TethysSoftwareRequirementsTooling::FlightSoftwareElements;
    private import TethysSoftwareRequirementsTooling::GroundSoftwareElements;
    private import TethysSoftwareRequirementsTooling::SoftwareRequirementsDocument;
    private import TethysSoftwareAssuranceTooling::ClassificationRows;
    private import TethysSoftwareAssuranceTooling::SoftwareVerificationCases;
    private import TethysSoftwareAssuranceTooling::SoftwareVcrmDocument;
    private import TethysSoftwareAssuranceTooling::SoftwareAssuranceReport;
    private import TethysSoftwareAssuranceTooling::SoftwareFmecaDocument;
    private import TethysSoftwareIcdDocuments::Messages;
    private import TethysSoftwareIcdDocuments::Topics;
    private import TethysSoftwareIcdDocuments::RateSets;
    private import TethysSoftwareIcdDocuments::Registers;
    private import TethysSoftwareIcdDocuments::MessageCatalogueDocument;
    private import TethysSoftwareIcdDocuments::BusProtocolIcdDocument;
    private import TethysSoftwareIcdDocuments::SpaceLinkProfileIcdDocument;
    private import TethysSoftwareIcdDocuments::InspectorRelayProfileIcdDocument;
    private import TethysSoftwareIcdDocuments::RegisterMapIcdDocument;
    private import TethysIcdDocuments::IcdRegisterDocument;
    private import TethysFlightDictionaryDocuments::FlightDictionaryDocument;
    private import TethysVerificationTooling::VvReport;

    // ---- shared queries ----------------------------------------------------------------------

    calc def NamedParts :> Query {
        doc /* The part usages owned by the element the qualified name denotes, with their type
             * and documentation: the generic decomposition table. */
        in root : String;
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = root)), type = "PartUsage"),
            properties = ("name", "type", "documentation"))
    }

    calc def NamedPorts :> Query {
        doc /* The ports of a definition with their port definitions. */
        in root : String;
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = root)), type = "PortUsage"),
            properties = ("name", "type", "documentation"))
    }

    calc def NamedAttributes :> Query {
        doc /* The attributes a definition declares, with their types and documentation: the
             * parameters and figures of a component as the model types them. */
        in root : String;
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = root)), type = "AttributeUsage"),
            properties = ("name", "type", "documentation"))
    }

    calc def NamedStates :> Query {
        doc /* The states of a state definition or of a behavioural component (its exhibited
             * state machines). */
        in root : String;
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = root)), type = "StateUsage"),
            properties = ("name", "type", "documentation"))
    }

    calc def Satisfied :> Query {
        doc /* The requirements the named element satisfies. */
        in element : String;
        Project(source = Named(qualifiedName = element), properties = ("name"),
            columns = (RelatedColumn(name = "satisfies", relationshipKind = "satisfaction", direction = "outgoing", aggregate = "list"),
                       RelatedColumn(name = "rows", relationshipKind = "satisfaction", direction = "outgoing", aggregate = "count")))
    }

    calc def Purpose :> Query {
        doc /* One element with its type and documentation: the purpose statement of a definition
             * as its doc comment gives it. */
        in element : String;
        Project(source = Named(qualifiedName = element), properties = ("name", "type", "documentation"))
    }

    calc def Classification :> Query {
        doc /* The classification-register row of a component: its assurance level and the
             * rationale the register gives. */
        in row : String;
        Project(source = Named(qualifiedName = row), properties = ("name", "level", "documentation"))
    }

    // ---- flight software architecture ----------------------------------------------------------

    calc def FlightComponents :> Query {
        doc /* Every component of the Argent flight software (board support, executive, bus, the
             * nine core services and the twelve applications) with its layer, load and footprint. */
        Project(source = FlightSoftwareElements(),
            properties = ("name", "type", "layer", "processorLoadMips", "codeSize", "dataSize", "criticality"))
    }

    calc def FlightApplications :> Query {
        doc /* The twelve applications with their rate, priority and the modes they are active in:
             * the modes-by-application activity table. */
        Project(source = WhereFeature(source = FlightSoftwareElements(), 'feature' = "layer", operator = "==", value = "application"),
            properties = ("name", "type", "rate", "priority", "activeModes"))
    }

    calc def Partitions :> Query {
        doc /* The executive's time and space partitions with their window, memory region,
             * criticality and restart policy. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysFlightSoftware::ArgentFlightSoftware::executive")), type = "PartUsage"),
            properties = ("name", "windowDuration", "memoryBudget", "criticality", "restartable"))
    }

    calc def Deployment :> Query {
        doc /* The deployment allocations: functions hosted by applications, applications placed in
             * partitions and partitions placed on the prime and redundant flight computers. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysAllocations::softwareDeployment")), type = "AllocationUsage"),
            properties = ("name", "type", "documentation"))
    }

    calc def RateGroups :> Query {
        doc /* The rate groups of the flight timing with their rate, period and activations per
             * major frame. */
        Project(source = WhereFeature(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysFlightTiming::FlightTiming")), type = "PartUsage"),
                'feature' = "rate", operator = ">=", value = "0"),
            properties = ("name", "rate", "period", "activationsPerMajorFrame"))
    }

    calc def ScheduledTasks :> Query {
        doc /* Every scheduled task of the five partition schedules with its period, worst-case
             * execution time, deadline, utilisation and the modes it runs in. */
        Project(source = WhereFeature(source = WhereType(source = Descendants(source = Named(qualifiedName = "TethysFlightTiming::argentTiming"), maxDepth = 3), type = "PartUsage"),
                'feature' = "wcet", operator = ">=", value = "0"),
            properties = ("name", "period", "wcet", "deadline", "utilisation", "activeModes"))
    }

    calc def TaskOf :> Query {
        doc /* The scheduled task of one component. */
        in task : String;
        Project(source = Named(qualifiedName = task), properties = ("name", "period", "wcet", "deadline", "utilisation", "activeModes"))
    }

    calc def ModeDemands :> Query {
        doc /* The processor and bus demand records per mode of the software budgets; the figures
             * are computed on instantiation, so the table names the modes the budgets are closed in. */
        Project(source = WhereFeature(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysFlightTiming::SoftwareBudgets")), type = "AttributeUsage"),
                'feature' = "mode", operator = "!=", value = ""),
            properties = ("name", "mode", "documentation"))
    }

    calc def BudgetVerdicts :> Query {
        doc /* The design verdicts of the software budgets as the model evaluates them: the
             * processor and memory budget, the bus budget in the busiest mode and in coast, and
             * the four latency budgets, each with its constraint and the requirement it satisfies. */
        Project(source = Verdicts(source = Named(qualifiedName = (
                "TethysFlightTiming::softwareProcessorBudget", "TethysFlightTiming::softwareBusBudget", "TethysFlightTiming::softwareBusBudgetCoast",
                "TethysFlightTiming::faultDetectionBudget", "TethysFlightTiming::safeConfigurationBudget",
                "TethysFlightTiming::commandDispatchBudget", "TethysFlightTiming::telemetrySampleBudget"))),
            properties = ("path", "kind", "name", "verdict"))
    }

    calc def GroundComponents :> Query {
        doc /* The twelve components of the Meridian Operations Suite (six operations-centre
             * components, flight dynamics, the archive and the four simulators) with product
             * name and version. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = (
                "TethysGroundSoftware::SoftwareOperationsCentre", "TethysGroundSoftware::SoftwareFlightDynamics",
                "TethysGroundSoftware::SoftwareScienceDataSystem", "TethysGroundSoftware::SimulatedTestBedSet"))), type = "PartUsage"),
            properties = ("name", "type", "productName", "version", "documentation"))
    }

    // ---- verification cross-references ----------------------------------------------------------

    calc def SoftwareRequirementVerification :> Query {
        doc /* Every TF-/TM- row with the verification cases that verify it: the software cases
             * of TethysSoftwareAssurance and the system cases of TethysVerification that
             * TethysSoftwareDocuments subsets for the rows derived from what they verify. */
        Project(source = SoftwareRequirementRows(), properties = ("shortName", "name"),
            columns = (RelatedColumn(name = "verifiedBy", relationshipKind = "verification", direction = "incoming", aggregate = "list"),
                       RelatedColumn(name = "cases", relationshipKind = "verification", direction = "incoming", aggregate = "count")))
    }

    calc def UnverifiedSoftwareRequirements :> Query {
        doc /* Software rows no verification case verifies. */
        Project(source = WhereRelated(source = SoftwareRequirementRows(), relationshipKind = "verification", direction = "incoming", exists = false),
            properties = ("shortName", "name", "documentation"))
    }

    calc def SystemCasesCoveringSoftware :> Query {
        doc /* The system verification cases, as subset in TethysSoftwareDocuments, with the
             * software rows each verifies. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysSoftwareDocuments")), type = "VerificationCaseUsage"),
            properties = ("name", "documentation"),
            columns = (RelatedColumn(name = "verifies", relationshipKind = "verification", direction = "outgoing", aggregate = "list")))
    }

    calc def ProgrammeTestBeds :> Query {
        doc /* The programme's test beds (TethysVerification::testBeds) with fidelity and readiness. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysVerification::TestBedSet")), type = "PartUsage"),
            properties = ("name", "fidelity", "readyBy", "documentation"))
    }

    calc def SimulatedTestBeds :> Query {
        doc /* The same four test beds as the Meridian suite runs them: the simulator product and
             * version that retype each. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysGroundSoftware::SimulatedTestBedSet")), type = "PartUsage"),
            properties = ("name", "type", "productName", "version", "fidelity", "readyBy"))
    }

    calc def AssurancePlanLevels :> Query {
        doc /* The assurance plan per level: activities, activities complete and whether the level
             * is complete. Level A is incomplete while independent verification is in progress. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysSoftwareAssurance::assurancePlan")), type = "PartUsage"),
            properties = ("name", "level", "activityCount", "completeCount", "allComplete"))
    }

    // ---- dictionaries ------------------------------------------------------------------------------

    calc def ParameterRows :> Query {
        doc /* The rows of one application's parameter table: id, value, range, unit and whether
             * the value is in range. */
        in table : String;
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = table)), type = "AttributeUsage"),
            properties = ("parameterId", "value", "minimum", "maximum", "unitSymbol", "inRange"))
    }

    calc def FdirLimits :> Query {
        doc /* The fault-protection limit tables: the flight table of the dictionary and the
             * cruise limits of the fault-protection package it is loaded from. */
        Project(source = Named(qualifiedName = ("TethysFlightDictionary::flightLimitTable", "TethysFdir::cruiseLimits")),
            properties = ("name", "commandLossTimeout", "thrusterRestartDelay", "maximumFlameoutRetries", "batteryLowFraction", "earthExclusionRadius", "maximumImpactProbability"))
    }

    calc def CommandsOf :> Query {
        doc /* The commands an application owns: mnemonic, opcode, criticality and hazard flag. */
        in application : String;
        Project(source = WhereFeature(source = WhereFeature(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysFlightDictionary")), type = "ItemUsage"),
                    'feature' = "opcodeNumber", operator = ">=", value = "0"), 'feature' = "application", operator = "==", value = application),
            properties = ("mnemonic", "opcodeNumber", "criticality", "hazardous", "documentation"))
    }

    calc def TelemetryOf :> Query {
        doc /* The telemetry points an application is the source of: mnemonic, id, kind, rate and
             * unit. */
        in application : String;
        Project(source = WhereFeature(source = WhereFeature(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysFlightDictionary")), type = "ItemUsage"),
                    'feature' = "pointId", operator = ">=", value = "0"), 'feature' = "source", operator = "==", value = application),
            properties = ("mnemonic", "pointId", "kind", "rate", "unitSymbol"))
    }

    calc def EventsOf :> Query {
        doc /* The events an application raises: mnemonic, id, severity and whether the fault
             * application acts on it. */
        in application : String;
        Project(source = WhereFeature(source = WhereFeature(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysFlightDictionary")), type = "ItemUsage"),
                    'feature' = "eventId", operator = ">=", value = "0"), 'feature' = "source", operator = "==", value = application),
            properties = ("mnemonic", "eventId", "severity", "fdirRelevant", "text"))
    }

    calc def PacketsOf :> Query {
        doc /* The packets an application is the source of: application id, class, rate and length. */
        in application : String;
        Project(source = WhereFeature(source = WhereFeature(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysFlightDictionary")), type = "ItemUsage"),
                    'feature' = "apid", operator = ">=", value = "0"), 'feature' = "source", operator = "==", value = application),
            properties = ("mnemonic", "apid", "apidClass", "rate", "lengthOctets", "layoutConsistent"))
    }

    // ---- operations ----------------------------------------------------------------------------------

    calc def FlightModes :> Query {
        doc /* The flight modes of the tug's mode machine. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysModes::TugModes::flightMode")), type = "StateUsage"),
            properties = ("name", "documentation"))
    }

    calc def ModeConfigurations :> Query {
        doc /* The subsystem configuration the mode table commands in each mode. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysModes::TugModeTable")), type = "AttributeUsage"),
            properties = ("name", "sepThrusting", "highVoltageBusOn", "highGainAntennaOn", "proximityLinkOn", "wheelControl", "captureSystemArmed", "sensorsOn"))
    }

    calc def OnBoardSequences :> Query {
        doc /* The on-board sequences the autonomy application loads by number. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysSequence")), type = "ActionDefinition"),
            properties = ("name", "sequenceId", "timeTagged", "documentation"))
    }

    calc def FaultEvents :> Query {
        doc /* The fault and on-board events the fault-protection supervisor accepts. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysFdir")), type = "ItemDefinition"),
            properties = ("name", "documentation"))
    }

    calc def OperationsRequirements :> Query {
        doc /* The flight rules and ground operations rows of TethysOperations with their text. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysOperations")), type = "RequirementUsage"),
            properties = ("shortName", "documentation"))
    }

    calc def Procedures :> Query {
        doc /* The operations procedures and activities TethysOperations defines as actions. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysOperations")), type = "ActionDefinition"),
            properties = ("name", "documentation"))
    }

    calc def CommandRequests :> Query {
        doc /* The command requests the command builder checks: mnemonic, argument, the mode at
             * execution and the approvals attached. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysGroundSoftware::CommandBuilder")), type = "AttributeUsage"),
            properties = ("name", "mnemonic", "argumentValue", "modeAtExecution", "approvals"))
    }

    calc def TelemetryAlarms :> Query {
        doc /* The limit checks of the telemetry server and the severity each raises. */
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysGroundSoftware::TelemetryServer")), type = "CalculationUsage"),
            properties = ("name", "type", "severity"))
    }

    calc def PassPlannerFigures :> Query {
        doc /* The pass planner's product, version and visibility half-width. */
        Project(source = Named(qualifiedName = "TethysGroundSoftware::PassPlanner"),
            properties = ("productName", "version", "visibilityHalfWidth"))
    }

    calc def DocumentRecords :> Query {
        doc /* The register of the document set with identifier, version, status, volumes, render
             * target and source packages. */
        Project(source = WhereFeature(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "TethysSoftwareDocuments::SoftwareDocumentSet")), type = "AttributeUsage"),
                'feature' = "volumes", operator = ">=", value = "1"),
            properties = ("id", "title", "version", "status", "volumes", "renderTarget", "sourcePackages"))
    }

    // ---- the documents the volumes refer to -------------------------------------------------------

    ref messageCatalogue : MessageCatalogueDocument;
    ref busProtocolIcd : BusProtocolIcdDocument;
    ref spaceLinkProfileIcd : SpaceLinkProfileIcdDocument;
    ref inspectorRelayProfileIcd : InspectorRelayProfileIcdDocument;
    ref registerMapIcd : RegisterMapIcdDocument;
    ref icdRegister : IcdRegisterDocument;
    ref vvReport : VvReport;
    ref assuranceReport : SoftwareAssuranceReport;
    ref fmecaDocument : SoftwareFmecaDocument;

    // ---- 1. software architecture description --------------------------------------------------

    part def SoftwareArchitectureDescription :> Document {
        doc /* Flight and ground software architecture: context, decomposition, partitions,
             * deployment, the Meridian suite, allocation, mode activity, timing and the budget
             * verdicts, in that order. */
        attribute :>> title = "Argent flight software and Meridian Operations Suite architecture description";
        part scope : Paragraph {
            attribute :>> text = "The architecture of the Argent flight software (Kestrel executive, core services, twelve applications, two flight computers, the AABP-1 bus) and of the Meridian Operations Suite, as TethysFlightSoftware, TethysFlightTiming, TethysGroundSoftware and TethysAllocations define it. Every table is a query over those packages; the budget verdicts are the model's own.";
        }
        part context : Section {
            attribute :>> title = "Context";
            part flight : Table {
                attribute :>> caption = "Flight software components: layer, processor load, code and data size, criticality";
                calc rows : FlightComponents;
            }
            part ground : Table {
                attribute :>> caption = "Meridian Operations Suite components: product and version";
                calc rows : GroundComponents;
            }
        }
        part decomposition : Section {
            attribute :>> title = "Decomposition";
            part applications : Table {
                attribute :>> caption = "Applications: rate, priority and active modes";
                calc rows : FlightApplications;
            }
            part partitions : Table {
                attribute :>> caption = "Executive partitions: window, memory region, criticality, restart policy";
                calc rows : Partitions;
            }
            part computers : Table {
                attribute :>> caption = "Avionics with software: the two flight computers and their images";
                calc rows : NamedParts { in :>> root = "TethysFlightSoftware::CdhWithSoftware"; }
            }
        }
        part deployment : Section {
            attribute :>> title = "Deployment and allocation";
            part allocations : Table {
                attribute :>> caption = "Function hosting, application deployment and partition placement";
                calc rows : Deployment;
            }
        }
        part timing : Section {
            attribute :>> title = "Timing and scheduling";
            part rateGroups : Table {
                attribute :>> caption = "Rate groups";
                calc rows : RateGroups;
            }
            part tasks : Table {
                attribute :>> caption = "Scheduled tasks: period, worst-case execution time, deadline, utilisation, active modes";
                calc rows : ScheduledTasks;
            }
        }
        part budgets : Section {
            attribute :>> title = "Processor, memory and bus budgets";
            part modes : Table {
                attribute :>> caption = "Modes the budgets are closed in";
                calc rows : ModeDemands;
            }
            part verdicts : Table {
                attribute :>> caption = "Budget verdicts as the model evaluates them";
                calc rows : BudgetVerdicts;
            }
        }
    }

    // ---- 2. software requirements specification --------------------------------------------------

    part def SoftwareRequirementsSpecification :> SoftwareRequirementsDocument {
        doc /* The requirements document of TethysSoftwareRequirementsTooling (rows with
             * derivation sources and satisfiers, then the coverage gates) followed by the
             * verification cross-reference this volume adds: which cases verify each row, the
             * rows no case verifies, and the system cases that cover software rows. */
        attribute :>> title = "Argent flight software and Meridian Operations Suite requirements specification";
        part verificationCrossReference : Section {
            attribute :>> title = "Verification cross-reference";
            part verifiedBy : Table {
                attribute :>> caption = "Software requirements and the cases that verify them";
                calc rows : SoftwareRequirementVerification;
            }
            part unverified : Table {
                attribute :>> caption = "Software requirements without a verification case";
                calc rows : UnverifiedSoftwareRequirements;
            }
            part systemCases : Table {
                attribute :>> caption = "System verification cases covering software requirements";
                calc rows : SystemCasesCoveringSoftware;
            }
        }
    }

    // ---- 3. software design descriptions ----------------------------------------------------------

    part def FlightApplicationDesignDescription :> Document {
        doc /* The common form of the twelve flight application design descriptions: purpose,
             * ports, state machine, parameter table, schedule, the dictionary items the
             * application owns (its commands, telemetry, events and packets; the fault events are
             * its fault-protection interface), the requirements it satisfies and its assurance
             * classification. Each application's volume specialises this document and binds the
             * queries to its own definitions. */
        attribute :>> title default = "Flight application design descriptions";
        part scope : Paragraph {
            attribute :>> text = "One volume per application of the Argent flight software, in the order of TethysFlightSoftware::ArgentFlightSoftware. Every table is a query over TethysFlightSoftware, TethysFlightBehaviour, TethysFlightTiming, TethysFlightDictionary, TethysSoftwareRequirements and TethysSoftwareAssurance.";
        }
    }

    part def GroundComponentDesignDescription :> Document {
        doc /* The common form of the twelve Meridian component design descriptions: purpose, ports,
             * the figures and tables the component carries, the requirements it satisfies and its
             * assurance classification; the four simulators add their test-bed row. */
        attribute :>> title default = "Meridian component design descriptions";
        part scope : Paragraph {
            attribute :>> text = "One volume per component of the Meridian Operations Suite, in the order of TethysGroundSoftware::MeridianOperationsSuite::components. Every table is a query over TethysGroundSoftware, TethysSoftwareRequirements, TethysSoftwareAssurance and TethysVerification.";
        }
    }

    part def CdhDesignDescription :> FlightApplicationDesignDescription {
        doc /* Design description of the cdh application. */
        attribute :>> title = "Command and data handling application design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Application definition"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::CdhApplication"; } }
            part behaviour : Table { attribute :>> caption = "Behavioural specialisation"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::CdhApplication"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the application"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::CdhApplication"; } }
            part behaviourPorts : Table { attribute :>> caption = "Ports added by the behavioural specialisation"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::CdhApplication"; } }
        }
        part stateMachine : Section {
            attribute :>> title = "State machine";
            part exhibited : Table { attribute :>> caption = "Exhibited state machines"; calc rows : NamedStates { in :>> root = "TethysFlightSoftware::CdhApplication"; } }
        }
        part parameters : Section {
            attribute :>> title = "Parameter table";
            part rows : Table { attribute :>> caption = "Parameters: id, value, range, unit"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::cdhParameterTable"; } }
        }
        part schedule : Section {
            attribute :>> title = "Rate, worst-case execution time and deadline";
            part task : Table { attribute :>> caption = "Scheduled task"; calc rows : TaskOf { in :>> task = "TethysFlightTiming::argentTiming::platformSchedule::cdhTask"; } }
        }
        part dictionary : Section {
            attribute :>> title = "Commands, telemetry, events and packets owned";
            part commands : Table { attribute :>> caption = "Commands"; calc rows : CommandsOf { in :>> application = "cdh"; } }
            part telemetry : Table { attribute :>> caption = "Telemetry points"; calc rows : TelemetryOf { in :>> application = "cdh"; } }
            part events : Table { attribute :>> caption = "Events (the fault-relevant ones are the fault-protection interface)"; calc rows : EventsOf { in :>> application = "cdh"; } }
            part packets : Table { attribute :>> caption = "Packets"; calc rows : PacketsOf { in :>> application = "cdh"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysFlightSoftware::ArgentFlightSoftware::cdh"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::cdh"; } }
        }
    }

    part def GncDesignDescription :> FlightApplicationDesignDescription {
        doc /* Design description of the gnc application. */
        attribute :>> title = "Guidance, navigation and control application design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Application definition"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::GncApplication"; } }
            part behaviour : Table { attribute :>> caption = "Behavioural specialisation"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::GncApplication"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the application"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::GncApplication"; } }
            part behaviourPorts : Table { attribute :>> caption = "Ports added by the behavioural specialisation"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::GncApplication"; } }
        }
        part stateMachine : Section {
            attribute :>> title = "State machine";
            part exhibited : Table { attribute :>> caption = "Exhibited state machines"; calc rows : NamedStates { in :>> root = "TethysFlightSoftware::GncApplication"; } }
        }
        part parameters : Section {
            attribute :>> title = "Parameter table";
            part rows : Table { attribute :>> caption = "Parameters: id, value, range, unit"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::gncParameterTable"; } }
        }
        part schedule : Section {
            attribute :>> title = "Rate, worst-case execution time and deadline";
            part task : Table { attribute :>> caption = "Scheduled task"; calc rows : TaskOf { in :>> task = "TethysFlightTiming::argentTiming::gncSchedule::gncTask"; } }
        }
        part dictionary : Section {
            attribute :>> title = "Commands, telemetry, events and packets owned";
            part commands : Table { attribute :>> caption = "Commands"; calc rows : CommandsOf { in :>> application = "gnc"; } }
            part telemetry : Table { attribute :>> caption = "Telemetry points"; calc rows : TelemetryOf { in :>> application = "gnc"; } }
            part events : Table { attribute :>> caption = "Events (the fault-relevant ones are the fault-protection interface)"; calc rows : EventsOf { in :>> application = "gnc"; } }
            part packets : Table { attribute :>> caption = "Packets"; calc rows : PacketsOf { in :>> application = "gnc"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysFlightSoftware::ArgentFlightSoftware::gnc"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::gnc"; } }
        }
    }

    part def SepControlDesignDescription :> FlightApplicationDesignDescription {
        doc /* Design description of the sepControl application. */
        attribute :>> title = "Electric propulsion control application design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Application definition"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::SepControlApplication"; } }
            part behaviour : Table { attribute :>> caption = "Behavioural specialisation"; calc rows : Purpose { in :>> element = "TethysFlightBehaviour::SepControlSoftware"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the application"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::SepControlApplication"; } }
            part behaviourPorts : Table { attribute :>> caption = "Ports added by the behavioural specialisation"; calc rows : NamedPorts { in :>> root = "TethysFlightBehaviour::SepControlSoftware"; } }
        }
        part stateMachine : Section {
            attribute :>> title = "State machine";
            part exhibited : Table { attribute :>> caption = "Exhibited state machines"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::SepControlSoftware"; } }
            part states : Table { attribute :>> caption = "States"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::SepStringController"; } }
        }
        part parameters : Section {
            attribute :>> title = "Parameter table";
            part rows : Table { attribute :>> caption = "Parameters: id, value, range, unit"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::sepParameterTable"; } }
        }
        part schedule : Section {
            attribute :>> title = "Rate, worst-case execution time and deadline";
            part task : Table { attribute :>> caption = "Scheduled task"; calc rows : TaskOf { in :>> task = "TethysFlightTiming::argentTiming::gncSchedule::sepControlTask"; } }
        }
        part dictionary : Section {
            attribute :>> title = "Commands, telemetry, events and packets owned";
            part commands : Table { attribute :>> caption = "Commands"; calc rows : CommandsOf { in :>> application = "sepControl"; } }
            part telemetry : Table { attribute :>> caption = "Telemetry points"; calc rows : TelemetryOf { in :>> application = "sepControl"; } }
            part events : Table { attribute :>> caption = "Events (the fault-relevant ones are the fault-protection interface)"; calc rows : EventsOf { in :>> application = "sepControl"; } }
            part packets : Table { attribute :>> caption = "Packets"; calc rows : PacketsOf { in :>> application = "sepControl"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysFlightSoftware::ArgentFlightSoftware::sepControl"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::sepControl"; } }
        }
    }

    part def PowerManagementDesignDescription :> FlightApplicationDesignDescription {
        doc /* Design description of the powerManagement application. */
        attribute :>> title = "Power management application design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Application definition"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::PowerManagementApplication"; } }
            part behaviour : Table { attribute :>> caption = "Behavioural specialisation"; calc rows : Purpose { in :>> element = "TethysFlightBehaviour::PowerManagementSoftware"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the application"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::PowerManagementApplication"; } }
            part behaviourPorts : Table { attribute :>> caption = "Ports added by the behavioural specialisation"; calc rows : NamedPorts { in :>> root = "TethysFlightBehaviour::PowerManagementSoftware"; } }
        }
        part stateMachine : Section {
            attribute :>> title = "State machine";
            part exhibited : Table { attribute :>> caption = "Exhibited state machines"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::PowerManagementSoftware"; } }
            part states : Table { attribute :>> caption = "States"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::PowerManager"; } }
        }
        part parameters : Section {
            attribute :>> title = "Parameter table";
            part rows : Table { attribute :>> caption = "Parameters: id, value, range, unit"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::epsParameterTable"; } }
        }
        part schedule : Section {
            attribute :>> title = "Rate, worst-case execution time and deadline";
            part task : Table { attribute :>> caption = "Scheduled task"; calc rows : TaskOf { in :>> task = "TethysFlightTiming::argentTiming::subsystemSchedule::powerManagementTask"; } }
        }
        part dictionary : Section {
            attribute :>> title = "Commands, telemetry, events and packets owned";
            part commands : Table { attribute :>> caption = "Commands"; calc rows : CommandsOf { in :>> application = "powerManagement"; } }
            part telemetry : Table { attribute :>> caption = "Telemetry points"; calc rows : TelemetryOf { in :>> application = "powerManagement"; } }
            part events : Table { attribute :>> caption = "Events (the fault-relevant ones are the fault-protection interface)"; calc rows : EventsOf { in :>> application = "powerManagement"; } }
            part packets : Table { attribute :>> caption = "Packets"; calc rows : PacketsOf { in :>> application = "powerManagement"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysFlightSoftware::ArgentFlightSoftware::powerManagement"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::powerManagement"; } }
        }
    }

    part def ThermalControlDesignDescription :> FlightApplicationDesignDescription {
        doc /* Design description of the thermalControl application. */
        attribute :>> title = "Thermal control application design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Application definition"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::ThermalControlApplication"; } }
            part behaviour : Table { attribute :>> caption = "Behavioural specialisation"; calc rows : Purpose { in :>> element = "TethysFlightBehaviour::ThermalControlSoftware"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the application"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::ThermalControlApplication"; } }
            part behaviourPorts : Table { attribute :>> caption = "Ports added by the behavioural specialisation"; calc rows : NamedPorts { in :>> root = "TethysFlightBehaviour::ThermalControlSoftware"; } }
        }
        part stateMachine : Section {
            attribute :>> title = "State machine";
            part exhibited : Table { attribute :>> caption = "Exhibited state machines"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::ThermalControlSoftware"; } }
            part states : Table { attribute :>> caption = "States"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::ThermalController"; } }
        }
        part parameters : Section {
            attribute :>> title = "Parameter table";
            part rows : Table { attribute :>> caption = "Parameters: id, value, range, unit"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::thmParameterTable"; } }
        }
        part schedule : Section {
            attribute :>> title = "Rate, worst-case execution time and deadline";
            part task : Table { attribute :>> caption = "Scheduled task"; calc rows : TaskOf { in :>> task = "TethysFlightTiming::argentTiming::subsystemSchedule::thermalControlTask"; } }
        }
        part dictionary : Section {
            attribute :>> title = "Commands, telemetry, events and packets owned";
            part commands : Table { attribute :>> caption = "Commands"; calc rows : CommandsOf { in :>> application = "thermalControl"; } }
            part telemetry : Table { attribute :>> caption = "Telemetry points"; calc rows : TelemetryOf { in :>> application = "thermalControl"; } }
            part events : Table { attribute :>> caption = "Events (the fault-relevant ones are the fault-protection interface)"; calc rows : EventsOf { in :>> application = "thermalControl"; } }
            part packets : Table { attribute :>> caption = "Packets"; calc rows : PacketsOf { in :>> application = "thermalControl"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysFlightSoftware::ArgentFlightSoftware::thermalControl"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::thermalControl"; } }
        }
    }

    part def TelecomDesignDescription :> FlightApplicationDesignDescription {
        doc /* Design description of the telecom application. */
        attribute :>> title = "Telecom application design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Application definition"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::TelecomApplication"; } }
            part behaviour : Table { attribute :>> caption = "Behavioural specialisation"; calc rows : Purpose { in :>> element = "TethysFlightBehaviour::TelecomSoftware"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the application"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::TelecomApplication"; } }
            part behaviourPorts : Table { attribute :>> caption = "Ports added by the behavioural specialisation"; calc rows : NamedPorts { in :>> root = "TethysFlightBehaviour::TelecomSoftware"; } }
        }
        part stateMachine : Section {
            attribute :>> title = "State machine";
            part exhibited : Table { attribute :>> caption = "Exhibited state machines"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::TelecomSoftware"; } }
            part states : Table { attribute :>> caption = "States"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::TelecomManager"; } }
        }
        part parameters : Section {
            attribute :>> title = "Parameter table";
            part rows : Table { attribute :>> caption = "Parameters: id, value, range, unit"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::comParameterTable"; } }
        }
        part schedule : Section {
            attribute :>> title = "Rate, worst-case execution time and deadline";
            part task : Table { attribute :>> caption = "Scheduled task"; calc rows : TaskOf { in :>> task = "TethysFlightTiming::argentTiming::platformSchedule::telecomTask"; } }
        }
        part dictionary : Section {
            attribute :>> title = "Commands, telemetry, events and packets owned";
            part commands : Table { attribute :>> caption = "Commands"; calc rows : CommandsOf { in :>> application = "telecom"; } }
            part telemetry : Table { attribute :>> caption = "Telemetry points"; calc rows : TelemetryOf { in :>> application = "telecom"; } }
            part events : Table { attribute :>> caption = "Events (the fault-relevant ones are the fault-protection interface)"; calc rows : EventsOf { in :>> application = "telecom"; } }
            part packets : Table { attribute :>> caption = "Packets"; calc rows : PacketsOf { in :>> application = "telecom"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysFlightSoftware::ArgentFlightSoftware::telecom"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::telecom"; } }
        }
    }

    part def InspectorHandlingDesignDescription :> FlightApplicationDesignDescription {
        doc /* Design description of the inspectorHandling application. */
        attribute :>> title = "Inspector handling application design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Application definition"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::InspectorHandlingApplication"; } }
            part behaviour : Table { attribute :>> caption = "Behavioural specialisation"; calc rows : Purpose { in :>> element = "TethysFlightBehaviour::InspectorHandlingSoftware"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the application"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::InspectorHandlingApplication"; } }
            part behaviourPorts : Table { attribute :>> caption = "Ports added by the behavioural specialisation"; calc rows : NamedPorts { in :>> root = "TethysFlightBehaviour::InspectorHandlingSoftware"; } }
        }
        part stateMachine : Section {
            attribute :>> title = "State machine";
            part exhibited : Table { attribute :>> caption = "Exhibited state machines"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::InspectorHandlingSoftware"; } }
            part states : Table { attribute :>> caption = "States"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::InspectorHandler"; } }
        }
        part parameters : Section {
            attribute :>> title = "Parameter table";
            part rows : Table { attribute :>> caption = "Parameters: id, value, range, unit"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::insParameterTable"; } }
        }
        part schedule : Section {
            attribute :>> title = "Rate, worst-case execution time and deadline";
            part task : Table { attribute :>> caption = "Scheduled task"; calc rows : TaskOf { in :>> task = "TethysFlightTiming::argentTiming::payloadSchedule::inspectorHandlingTask"; } }
        }
        part dictionary : Section {
            attribute :>> title = "Commands, telemetry, events and packets owned";
            part commands : Table { attribute :>> caption = "Commands"; calc rows : CommandsOf { in :>> application = "inspectorHandling"; } }
            part telemetry : Table { attribute :>> caption = "Telemetry points"; calc rows : TelemetryOf { in :>> application = "inspectorHandling"; } }
            part events : Table { attribute :>> caption = "Events (the fault-relevant ones are the fault-protection interface)"; calc rows : EventsOf { in :>> application = "inspectorHandling"; } }
            part packets : Table { attribute :>> caption = "Packets"; calc rows : PacketsOf { in :>> application = "inspectorHandling"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysFlightSoftware::ArgentFlightSoftware::inspectorHandling"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::inspectorHandling"; } }
        }
    }

    part def CaptureControlDesignDescription :> FlightApplicationDesignDescription {
        doc /* Design description of the captureControl application. */
        attribute :>> title = "Capture control application design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Application definition"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::CaptureControlApplication"; } }
            part behaviour : Table { attribute :>> caption = "Behavioural specialisation"; calc rows : Purpose { in :>> element = "TethysFlightBehaviour::CaptureControlSoftware"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the application"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::CaptureControlApplication"; } }
            part behaviourPorts : Table { attribute :>> caption = "Ports added by the behavioural specialisation"; calc rows : NamedPorts { in :>> root = "TethysFlightBehaviour::CaptureControlSoftware"; } }
        }
        part stateMachine : Section {
            attribute :>> title = "State machine";
            part exhibited : Table { attribute :>> caption = "Exhibited state machines"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::CaptureControlSoftware"; } }
            part states : Table { attribute :>> caption = "States"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::CaptureController"; } }
        }
        part parameters : Section {
            attribute :>> title = "Parameter table";
            part rows : Table { attribute :>> caption = "Parameters: id, value, range, unit"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::capParameterTable"; } }
        }
        part schedule : Section {
            attribute :>> title = "Rate, worst-case execution time and deadline";
            part task : Table { attribute :>> caption = "Scheduled task"; calc rows : TaskOf { in :>> task = "TethysFlightTiming::argentTiming::payloadSchedule::captureControlTask"; } }
        }
        part dictionary : Section {
            attribute :>> title = "Commands, telemetry, events and packets owned";
            part commands : Table { attribute :>> caption = "Commands"; calc rows : CommandsOf { in :>> application = "captureControl"; } }
            part telemetry : Table { attribute :>> caption = "Telemetry points"; calc rows : TelemetryOf { in :>> application = "captureControl"; } }
            part events : Table { attribute :>> caption = "Events (the fault-relevant ones are the fault-protection interface)"; calc rows : EventsOf { in :>> application = "captureControl"; } }
            part packets : Table { attribute :>> caption = "Packets"; calc rows : PacketsOf { in :>> application = "captureControl"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysFlightSoftware::ArgentFlightSoftware::captureControl"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::captureControl"; } }
        }
    }

    part def AutonomyDesignDescription :> FlightApplicationDesignDescription {
        doc /* Design description of the autonomy application. */
        attribute :>> title = "Autonomy and sequencing application design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Application definition"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::AutonomyApplication"; } }
            part behaviour : Table { attribute :>> caption = "Behavioural specialisation"; calc rows : Purpose { in :>> element = "TethysFlightBehaviour::AutonomySoftware"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the application"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::AutonomyApplication"; } }
            part behaviourPorts : Table { attribute :>> caption = "Ports added by the behavioural specialisation"; calc rows : NamedPorts { in :>> root = "TethysFlightBehaviour::AutonomySoftware"; } }
        }
        part stateMachine : Section {
            attribute :>> title = "State machine";
            part exhibited : Table { attribute :>> caption = "Exhibited state machines"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::AutonomySoftware"; } }
        }
        part parameters : Section {
            attribute :>> title = "Parameter table";
            part rows : Table { attribute :>> caption = "Parameters: id, value, range, unit"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::autParameterTable"; } }
        }
        part schedule : Section {
            attribute :>> title = "Rate, worst-case execution time and deadline";
            part task : Table { attribute :>> caption = "Scheduled task"; calc rows : TaskOf { in :>> task = "TethysFlightTiming::argentTiming::autonomySchedule::autonomyTask"; } }
        }
        part dictionary : Section {
            attribute :>> title = "Commands, telemetry, events and packets owned";
            part commands : Table { attribute :>> caption = "Commands"; calc rows : CommandsOf { in :>> application = "autonomy"; } }
            part telemetry : Table { attribute :>> caption = "Telemetry points"; calc rows : TelemetryOf { in :>> application = "autonomy"; } }
            part events : Table { attribute :>> caption = "Events (the fault-relevant ones are the fault-protection interface)"; calc rows : EventsOf { in :>> application = "autonomy"; } }
            part packets : Table { attribute :>> caption = "Packets"; calc rows : PacketsOf { in :>> application = "autonomy"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysFlightSoftware::ArgentFlightSoftware::autonomy"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::autonomy"; } }
        }
    }

    part def FdirDesignDescription :> FlightApplicationDesignDescription {
        doc /* Design description of the fdir application. */
        attribute :>> title = "Fault protection application design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Application definition"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::FdirApplication"; } }
            part behaviour : Table { attribute :>> caption = "Behavioural specialisation"; calc rows : Purpose { in :>> element = "TethysFlightBehaviour::FdirSoftware"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the application"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::FdirApplication"; } }
            part behaviourPorts : Table { attribute :>> caption = "Ports added by the behavioural specialisation"; calc rows : NamedPorts { in :>> root = "TethysFlightBehaviour::FdirSoftware"; } }
        }
        part stateMachine : Section {
            attribute :>> title = "State machine";
            part exhibited : Table { attribute :>> caption = "Exhibited state machines"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::FdirSoftware"; } }
            part states : Table { attribute :>> caption = "States"; calc rows : NamedStates { in :>> root = "TethysFdir::FdirSupervisor"; } }
        }
        part parameters : Section {
            attribute :>> title = "Parameter table";
            part rows : Table { attribute :>> caption = "Parameters: id, value, range, unit"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::fdrParameterTable"; } }
        }
        part schedule : Section {
            attribute :>> title = "Rate, worst-case execution time and deadline";
            part task : Table { attribute :>> caption = "Scheduled task"; calc rows : TaskOf { in :>> task = "TethysFlightTiming::argentTiming::platformSchedule::fdirTask"; } }
        }
        part dictionary : Section {
            attribute :>> title = "Commands, telemetry, events and packets owned";
            part commands : Table { attribute :>> caption = "Commands"; calc rows : CommandsOf { in :>> application = "fdir"; } }
            part telemetry : Table { attribute :>> caption = "Telemetry points"; calc rows : TelemetryOf { in :>> application = "fdir"; } }
            part events : Table { attribute :>> caption = "Events (the fault-relevant ones are the fault-protection interface)"; calc rows : EventsOf { in :>> application = "fdir"; } }
            part packets : Table { attribute :>> caption = "Packets"; calc rows : PacketsOf { in :>> application = "fdir"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysFlightSoftware::ArgentFlightSoftware::fdir"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::fdir"; } }
        }
    }

    part def ModeManagementDesignDescription :> FlightApplicationDesignDescription {
        doc /* Design description of the modeManagement application. */
        attribute :>> title = "Mode management application design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Application definition"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::ModeManagementApplication"; } }
            part behaviour : Table { attribute :>> caption = "Behavioural specialisation"; calc rows : Purpose { in :>> element = "TethysFlightBehaviour::ModeManagementSoftware"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the application"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::ModeManagementApplication"; } }
            part behaviourPorts : Table { attribute :>> caption = "Ports added by the behavioural specialisation"; calc rows : NamedPorts { in :>> root = "TethysFlightBehaviour::ModeManagementSoftware"; } }
        }
        part stateMachine : Section {
            attribute :>> title = "State machine";
            part exhibited : Table { attribute :>> caption = "Exhibited state machines"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::ModeManagementSoftware"; } }
            part states : Table { attribute :>> caption = "States"; calc rows : NamedStates { in :>> root = "TethysModes::TugModes"; } }
        }
        part parameters : Section {
            attribute :>> title = "Parameter table";
            part rows : Table { attribute :>> caption = "Parameters: id, value, range, unit"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::modParameterTable"; } }
        }
        part schedule : Section {
            attribute :>> title = "Rate, worst-case execution time and deadline";
            part task : Table { attribute :>> caption = "Scheduled task"; calc rows : TaskOf { in :>> task = "TethysFlightTiming::argentTiming::platformSchedule::modeManagementTask"; } }
        }
        part dictionary : Section {
            attribute :>> title = "Commands, telemetry, events and packets owned";
            part commands : Table { attribute :>> caption = "Commands"; calc rows : CommandsOf { in :>> application = "modeManagement"; } }
            part telemetry : Table { attribute :>> caption = "Telemetry points"; calc rows : TelemetryOf { in :>> application = "modeManagement"; } }
            part events : Table { attribute :>> caption = "Events (the fault-relevant ones are the fault-protection interface)"; calc rows : EventsOf { in :>> application = "modeManagement"; } }
            part packets : Table { attribute :>> caption = "Packets"; calc rows : PacketsOf { in :>> application = "modeManagement"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysFlightSoftware::ArgentFlightSoftware::modeManagement"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::modeManagement"; } }
        }
    }

    part def ParameterBootUpdateDesignDescription :> FlightApplicationDesignDescription {
        doc /* Design description of the parameterBootUpdate application. */
        attribute :>> title = "Parameter, boot and update application design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Application definition"; calc rows : Purpose { in :>> element = "TethysFlightSoftware::ParameterBootUpdateApplication"; } }
            part behaviour : Table { attribute :>> caption = "Behavioural specialisation"; calc rows : Purpose { in :>> element = "TethysFlightBehaviour::ParameterBootUpdateSoftware"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the application"; calc rows : NamedPorts { in :>> root = "TethysFlightSoftware::ParameterBootUpdateApplication"; } }
            part behaviourPorts : Table { attribute :>> caption = "Ports added by the behavioural specialisation"; calc rows : NamedPorts { in :>> root = "TethysFlightBehaviour::ParameterBootUpdateSoftware"; } }
        }
        part stateMachine : Section {
            attribute :>> title = "State machine";
            part exhibited : Table { attribute :>> caption = "Exhibited state machines"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::ParameterBootUpdateSoftware"; } }
            part states : Table { attribute :>> caption = "States"; calc rows : NamedStates { in :>> root = "TethysFlightBehaviour::BootUpdateManager"; } }
        }
        part parameters : Section {
            attribute :>> title = "Parameter table";
            part rows : Table { attribute :>> caption = "Parameters: id, value, range, unit"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::pbuParameterTable"; } }
        }
        part schedule : Section {
            attribute :>> title = "Rate, worst-case execution time and deadline";
            part task : Table { attribute :>> caption = "Scheduled task"; calc rows : TaskOf { in :>> task = "TethysFlightTiming::argentTiming::platformSchedule::parameterBootUpdateTask"; } }
        }
        part dictionary : Section {
            attribute :>> title = "Commands, telemetry, events and packets owned";
            part commands : Table { attribute :>> caption = "Commands"; calc rows : CommandsOf { in :>> application = "parameterBootUpdate"; } }
            part telemetry : Table { attribute :>> caption = "Telemetry points"; calc rows : TelemetryOf { in :>> application = "parameterBootUpdate"; } }
            part events : Table { attribute :>> caption = "Events (the fault-relevant ones are the fault-protection interface)"; calc rows : EventsOf { in :>> application = "parameterBootUpdate"; } }
            part packets : Table { attribute :>> caption = "Packets"; calc rows : PacketsOf { in :>> application = "parameterBootUpdate"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysFlightSoftware::ArgentFlightSoftware::parameterBootUpdate"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::parameterBootUpdate"; } }
        }
    }

    part def CommandBuilderDesignDescription :> GroundComponentDesignDescription {
        doc /* Design description of the commandBuilder component. */
        attribute :>> title = "Command builder (Meridian Forge) design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Component definition"; calc rows : Purpose { in :>> element = "TethysGroundSoftware::CommandBuilder"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the component"; calc rows : NamedPorts { in :>> root = "TethysGroundSoftware::CommandBuilder"; } }
        }
        part figures : Section {
            attribute :>> title = "Figures and tables";
            part attributes : Table { attribute :>> caption = "Attributes the component carries"; calc rows : NamedAttributes { in :>> root = "TethysGroundSoftware::CommandBuilder"; } }
            part parts : Table { attribute :>> caption = "Parts the component owns"; calc rows : NamedParts { in :>> root = "TethysGroundSoftware::CommandBuilder"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysGroundSoftware::SoftwareOperationsCentre::commandBuilder"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::commandBuilder"; } }
        }
    }

    part def SequencerDesignDescription :> GroundComponentDesignDescription {
        doc /* Design description of the sequencer component. */
        attribute :>> title = "Sequencer and flight-rule checker (Meridian Warden) design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Component definition"; calc rows : Purpose { in :>> element = "TethysGroundSoftware::FlightRuleChecker"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the component"; calc rows : NamedPorts { in :>> root = "TethysGroundSoftware::FlightRuleChecker"; } }
        }
        part figures : Section {
            attribute :>> title = "Figures and tables";
            part attributes : Table { attribute :>> caption = "Attributes the component carries"; calc rows : NamedAttributes { in :>> root = "TethysGroundSoftware::FlightRuleChecker"; } }
            part parts : Table { attribute :>> caption = "Parts the component owns"; calc rows : NamedParts { in :>> root = "TethysGroundSoftware::FlightRuleChecker"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysGroundSoftware::SoftwareOperationsCentre::sequencer"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::sequencer"; } }
        }
    }

    part def TelemetryServerDesignDescription :> GroundComponentDesignDescription {
        doc /* Design description of the telemetryServer component. */
        attribute :>> title = "Telemetry server (Meridian Lantern) design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Component definition"; calc rows : Purpose { in :>> element = "TethysGroundSoftware::TelemetryServer"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the component"; calc rows : NamedPorts { in :>> root = "TethysGroundSoftware::TelemetryServer"; } }
        }
        part figures : Section {
            attribute :>> title = "Figures and tables";
            part attributes : Table { attribute :>> caption = "Attributes the component carries"; calc rows : NamedAttributes { in :>> root = "TethysGroundSoftware::TelemetryServer"; } }
            part parts : Table { attribute :>> caption = "Parts the component owns"; calc rows : NamedParts { in :>> root = "TethysGroundSoftware::TelemetryServer"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysGroundSoftware::SoftwareOperationsCentre::telemetryServer"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::telemetryServer"; } }
        }
    }

    part def PassPlannerDesignDescription :> GroundComponentDesignDescription {
        doc /* Design description of the passPlanner component. */
        attribute :>> title = "Pass planner (Meridian Almanac) design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Component definition"; calc rows : Purpose { in :>> element = "TethysGroundSoftware::PassPlanner"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the component"; calc rows : NamedPorts { in :>> root = "TethysGroundSoftware::PassPlanner"; } }
        }
        part figures : Section {
            attribute :>> title = "Figures and tables";
            part attributes : Table { attribute :>> caption = "Attributes the component carries"; calc rows : NamedAttributes { in :>> root = "TethysGroundSoftware::PassPlanner"; } }
            part parts : Table { attribute :>> caption = "Parts the component owns"; calc rows : NamedParts { in :>> root = "TethysGroundSoftware::PassPlanner"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysGroundSoftware::SoftwareOperationsCentre::passPlanner"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::passPlanner"; } }
        }
    }

    part def AnomalyTrackerDesignDescription :> GroundComponentDesignDescription {
        doc /* Design description of the anomalyTracker component. */
        attribute :>> title = "Anomaly tracker (Meridian Ledger) design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Component definition"; calc rows : Purpose { in :>> element = "TethysGroundSoftware::AnomalyTracker"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the component"; calc rows : NamedPorts { in :>> root = "TethysGroundSoftware::AnomalyTracker"; } }
        }
        part figures : Section {
            attribute :>> title = "Figures and tables";
            part attributes : Table { attribute :>> caption = "Attributes the component carries"; calc rows : NamedAttributes { in :>> root = "TethysGroundSoftware::AnomalyTracker"; } }
            part parts : Table { attribute :>> caption = "Parts the component owns"; calc rows : NamedParts { in :>> root = "TethysGroundSoftware::AnomalyTracker"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysGroundSoftware::SoftwareOperationsCentre::anomalyTracker"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::anomalyTracker"; } }
        }
    }

    part def ProximityPlannerDesignDescription :> GroundComponentDesignDescription {
        doc /* Design description of the proximityPlanner component. */
        attribute :>> title = "Proximity planner (Meridian Compass) design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Component definition"; calc rows : Purpose { in :>> element = "TethysGroundSoftware::ProximityPlanner"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the component"; calc rows : NamedPorts { in :>> root = "TethysGroundSoftware::ProximityPlanner"; } }
        }
        part figures : Section {
            attribute :>> title = "Figures and tables";
            part attributes : Table { attribute :>> caption = "Attributes the component carries"; calc rows : NamedAttributes { in :>> root = "TethysGroundSoftware::ProximityPlanner"; } }
            part parts : Table { attribute :>> caption = "Parts the component owns"; calc rows : NamedParts { in :>> root = "TethysGroundSoftware::ProximityPlanner"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysGroundSoftware::SoftwareOperationsCentre::proximityPlanner"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::proximityPlanner"; } }
        }
    }

    part def FlightDynamicsToolDesignDescription :> GroundComponentDesignDescription {
        doc /* Design description of the flightDynamicsTool component. */
        attribute :>> title = "Flight dynamics tool (Meridian Sextant) design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Component definition"; calc rows : Purpose { in :>> element = "TethysGroundSoftware::FlightDynamicsTool"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the component"; calc rows : NamedPorts { in :>> root = "TethysGroundSoftware::FlightDynamicsTool"; } }
        }
        part figures : Section {
            attribute :>> title = "Figures and tables";
            part attributes : Table { attribute :>> caption = "Attributes the component carries"; calc rows : NamedAttributes { in :>> root = "TethysGroundSoftware::FlightDynamicsTool"; } }
            part parts : Table { attribute :>> caption = "Parts the component owns"; calc rows : NamedParts { in :>> root = "TethysGroundSoftware::FlightDynamicsTool"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysGroundSoftware::SoftwareFlightDynamics::flightDynamicsTool"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::flightDynamicsTool"; } }
        }
    }

    part def DataArchiveDesignDescription :> GroundComponentDesignDescription {
        doc /* Design description of the dataArchive component. */
        attribute :>> title = "Data archive (Meridian Vault) design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Component definition"; calc rows : Purpose { in :>> element = "TethysGroundSoftware::DataArchive"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the component"; calc rows : NamedPorts { in :>> root = "TethysGroundSoftware::DataArchive"; } }
        }
        part figures : Section {
            attribute :>> title = "Figures and tables";
            part attributes : Table { attribute :>> caption = "Attributes the component carries"; calc rows : NamedAttributes { in :>> root = "TethysGroundSoftware::DataArchive"; } }
            part parts : Table { attribute :>> caption = "Parts the component owns"; calc rows : NamedParts { in :>> root = "TethysGroundSoftware::DataArchive"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysGroundSoftware::SoftwareScienceDataSystem::dataArchive"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::dataArchive"; } }
        }
    }

    part def FlatsatDesignDescription :> GroundComponentDesignDescription {
        doc /* Design description of the flatsat component. */
        attribute :>> title = "Flatsat hardware-in-the-loop test bed (Meridian Anvil) design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Component definition"; calc rows : Purpose { in :>> element = "TethysGroundSoftware::HardwareInTheLoopTestBed"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the component"; calc rows : NamedPorts { in :>> root = "TethysGroundSoftware::HardwareInTheLoopTestBed"; } }
        }
        part figures : Section {
            attribute :>> title = "Figures and tables";
            part attributes : Table { attribute :>> caption = "Attributes the component carries"; calc rows : NamedAttributes { in :>> root = "TethysGroundSoftware::HardwareInTheLoopTestBed"; } }
            part parts : Table { attribute :>> caption = "Parts the component owns"; calc rows : NamedParts { in :>> root = "TethysGroundSoftware::HardwareInTheLoopTestBed"; } }
        }
        part testBed : Section {
            attribute :>> title = "Test bed";
            part row : Table { attribute :>> caption = "Programme test bed this simulator retypes"; calc rows : Purpose { in :>> element = "TethysVerification::TestBedSet::flatsat"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysGroundSoftware::SimulatedTestBedSet::flatsat"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::flatsatSimulator"; } }
        }
    }

    part def CaptureRigDesignDescription :> GroundComponentDesignDescription {
        doc /* Design description of the captureRig component. */
        attribute :>> title = "Capture rig controller (Meridian Capstan) design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Component definition"; calc rows : Purpose { in :>> element = "TethysGroundSoftware::CaptureRigController"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the component"; calc rows : NamedPorts { in :>> root = "TethysGroundSoftware::CaptureRigController"; } }
        }
        part figures : Section {
            attribute :>> title = "Figures and tables";
            part attributes : Table { attribute :>> caption = "Attributes the component carries"; calc rows : NamedAttributes { in :>> root = "TethysGroundSoftware::CaptureRigController"; } }
            part parts : Table { attribute :>> caption = "Parts the component owns"; calc rows : NamedParts { in :>> root = "TethysGroundSoftware::CaptureRigController"; } }
        }
        part testBed : Section {
            attribute :>> title = "Test bed";
            part row : Table { attribute :>> caption = "Programme test bed this simulator retypes"; calc rows : Purpose { in :>> element = "TethysVerification::TestBedSet::captureRig"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysGroundSoftware::SimulatedTestBedSet::captureRig"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::captureRigSimulator"; } }
        }
    }

    part def DynamicsSimulatorDesignDescription :> GroundComponentDesignDescription {
        doc /* Design description of the dynamicsSimulator component. */
        attribute :>> title = "Dynamics simulator (Meridian Orrery) design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Component definition"; calc rows : Purpose { in :>> element = "TethysGroundSoftware::DynamicsSimulator"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the component"; calc rows : NamedPorts { in :>> root = "TethysGroundSoftware::DynamicsSimulator"; } }
        }
        part figures : Section {
            attribute :>> title = "Figures and tables";
            part attributes : Table { attribute :>> caption = "Attributes the component carries"; calc rows : NamedAttributes { in :>> root = "TethysGroundSoftware::DynamicsSimulator"; } }
            part parts : Table { attribute :>> caption = "Parts the component owns"; calc rows : NamedParts { in :>> root = "TethysGroundSoftware::DynamicsSimulator"; } }
        }
        part testBed : Section {
            attribute :>> title = "Test bed";
            part row : Table { attribute :>> caption = "Programme test bed this simulator retypes"; calc rows : Purpose { in :>> element = "TethysVerification::TestBedSet::dynamicsSimulator"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysGroundSoftware::SimulatedTestBedSet::dynamicsSimulator"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::dynamicsSimulatorSoftware"; } }
        }
    }

    part def TrajectoryToolDesignDescription :> GroundComponentDesignDescription {
        doc /* Design description of the trajectoryTool component. */
        attribute :>> title = "Flight-software-in-the-loop simulator (Meridian Mirror) design description";
        part purpose : Section {
            attribute :>> title = "Purpose";
            part definition : Table { attribute :>> caption = "Component definition"; calc rows : Purpose { in :>> element = "TethysGroundSoftware::FlightSoftwareInTheLoopSimulator"; } }
        }
        part interfaces : Section {
            attribute :>> title = "Ports";
            part ports : Table { attribute :>> caption = "Ports of the component"; calc rows : NamedPorts { in :>> root = "TethysGroundSoftware::FlightSoftwareInTheLoopSimulator"; } }
        }
        part figures : Section {
            attribute :>> title = "Figures and tables";
            part attributes : Table { attribute :>> caption = "Attributes the component carries"; calc rows : NamedAttributes { in :>> root = "TethysGroundSoftware::FlightSoftwareInTheLoopSimulator"; } }
            part parts : Table { attribute :>> caption = "Parts the component owns"; calc rows : NamedParts { in :>> root = "TethysGroundSoftware::FlightSoftwareInTheLoopSimulator"; } }
        }
        part testBed : Section {
            attribute :>> title = "Test bed";
            part row : Table { attribute :>> caption = "Programme test bed this simulator retypes"; calc rows : Purpose { in :>> element = "TethysVerification::TestBedSet::trajectoryTool"; } }
        }
        part requirements : Section {
            attribute :>> title = "Requirements satisfied";
            part satisfied : Table { attribute :>> caption = "Software requirements satisfied"; calc rows : Satisfied { in :>> element = "TethysGroundSoftware::SimulatedTestBedSet::trajectoryTool"; } }
        }
        part criticality : Section {
            attribute :>> title = "Assurance classification";
            part level : Table { attribute :>> caption = "Classification register row"; calc rows : Classification { in :>> row = "TethysSoftwareAssurance::classificationRegister::flightSoftwareSimulator"; } }
        }
    }

    // ---- 4. software interface control volume -----------------------------------------------------

    part def SoftwareInterfaceControlVolume :> Document {
        doc /* The software interface control documents in one volume: the inter-application
             * message catalogue, the on-board bus protocol (TI-020), the space link profile
             * (TI-021), the inspector relay profile (TI-022) and the register maps (TI-023), each
             * referred to as its own document and summarised by the same queries. */
        attribute :>> title = "Argent flight software interface control volume";
        part scope : Paragraph {
            part lead : Span { attribute :>> text = "This volume collects the software interface control documents of TethysSoftwareIcdDocuments:"; }
            part catalogueRef : Ref { ref :>> target = messageCatalogue.topics; }
            part busText : Span { attribute :>> text = ", the on-board bus protocol"; }
            part busRef : Ref { ref :>> target = busProtocolIcd.ends; }
            part linkText : Span { attribute :>> text = ", the space link profile"; }
            part linkRef : Ref { ref :>> target = spaceLinkProfileIcd.rateSets; }
            part relayText : Span { attribute :>> text = ", the inspector relay profile"; }
            part relayRef : Ref { ref :>> target = inspectorRelayProfileIcd.ends; }
            part registerText : Span { attribute :>> text = "and the register maps"; }
            part registerRef : Ref { ref :>> target = registerMapIcd.parameters; }
            part systemText : Span { attribute :>> text = "; the system-level interface register is"; }
            part systemRef : Ref { ref :>> target = icdRegister.classes; }
            part tail : Span { attribute :>> text = "."; }
        }
        part catalogue : Section {
            attribute :>> title = "Inter-application message catalogue";
            part messages : Table {
                attribute :>> caption = "Message types";
                calc rows : Messages;
            }
            part topics : Table {
                attribute :>> caption = "Topics: publisher and subscribers";
                calc rows : Topics;
            }
        }
        part spaceLink : Section {
            attribute :>> title = "Space link profile rate sets";
            part rateSets : Table {
                attribute :>> caption = "Rate sets per mode";
                calc rows : RateSets;
            }
        }
        part registers : Section {
            attribute :>> title = "Remote interface unit register maps";
            part thermalPropulsion : Table {
                attribute :>> caption = "Thermal and propulsion remote interface unit registers";
                calc rows : Registers { in :>> map = "TethysSoftwareIcds::ThermalPropulsionRiuRegisterMap"; }
            }
            part mechanism : Table {
                attribute :>> caption = "Mechanism remote interface unit registers";
                calc rows : Registers { in :>> map = "TethysSoftwareIcds::MechanismRiuRegisterMap"; }
            }
        }
    }

    // ---- 5. flight dictionary volume -----------------------------------------------------------------

    part def FlightDictionaryVolume :> FlightDictionaryDocument {
        doc /* The flight dictionary document of TethysFlightDictionaryDocuments (commands,
             * telemetry, events, packets and packet layouts) followed by the parameter tables of
             * the twelve applications and the fault-protection limit tables. */
        attribute :>> title = "Argent flight dictionary volume";
        part parameters : Section {
            attribute :>> title = "Parameter tables";
            part cdh : Table { attribute :>> caption = "Command and data handling parameters"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::cdhParameterTable"; } }
            part gnc : Table { attribute :>> caption = "Guidance, navigation and control parameters"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::gncParameterTable"; } }
            part sep : Table { attribute :>> caption = "Electric propulsion control parameters"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::sepParameterTable"; } }
            part eps : Table { attribute :>> caption = "Power management parameters"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::epsParameterTable"; } }
            part thm : Table { attribute :>> caption = "Thermal control parameters"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::thmParameterTable"; } }
            part com : Table { attribute :>> caption = "Telecom parameters"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::comParameterTable"; } }
            part ins : Table { attribute :>> caption = "Inspector handling parameters"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::insParameterTable"; } }
            part cap : Table { attribute :>> caption = "Capture control parameters"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::capParameterTable"; } }
            part aut : Table { attribute :>> caption = "Autonomy parameters"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::autParameterTable"; } }
            part fdr : Table { attribute :>> caption = "Fault protection parameters"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::fdrParameterTable"; } }
            part mod : Table { attribute :>> caption = "Mode management parameters"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::modParameterTable"; } }
            part pbu : Table { attribute :>> caption = "Parameter, boot and update parameters"; calc rows : ParameterRows { in :>> table = "TethysFlightDictionary::pbuParameterTable"; } }
        }
        part limits : Section {
            attribute :>> title = "Fault-protection limit tables";
            part tables : Table {
                attribute :>> caption = "Flight limit table and cruise limits";
                calc rows : FdirLimits;
            }
        }
    }

    // ---- 6. software test plan ---------------------------------------------------------------------

    part def SoftwareTestPlan :> SoftwareVcrmDocument {
        doc /* The verification cross-reference matrix of TethysSoftwareAssuranceTooling (cases
             * with level, test bed, verdict and evidence; function coverage; passed cases)
             * followed by the test beds, the assurance plan and the requirement-side
             * cross-reference. Planned cases keep their planned verdict; nothing here closes
             * an activity. */
        attribute :>> title = "Argent flight software and Meridian Operations Suite test plan";
        part testBeds : Section {
            attribute :>> title = "Test beds";
            part programme : Table {
                attribute :>> caption = "Programme test beds (TethysVerification::testBeds): fidelity and readiness";
                calc rows : ProgrammeTestBeds;
            }
            part simulators : Table {
                attribute :>> caption = "The same test beds as the Meridian suite runs them";
                calc rows : SimulatedTestBeds;
            }
        }
        part plan : Section {
            attribute :>> title = "Assurance plan";
            part levels : Table {
                attribute :>> caption = "Assurance activities per level";
                calc rows : AssurancePlanLevels;
            }
            part reportRef : Paragraph {
                part lead : Span { attribute :>> text = "The release gate and its open items are reported in"; }
                part report : Ref { ref :>> target = assuranceReport.gate; }
                part fmecaText : Span { attribute :>> text = "; the failure modes in"; }
                part fmeca : Ref { ref :>> target = fmecaDocument.rows; }
                part tail : Span { attribute :>> text = "."; }
            }
        }
        part requirements : Section {
            attribute :>> title = "Requirement cross-reference";
            part verifiedBy : Table {
                attribute :>> caption = "Software requirements and the cases that verify them";
                calc rows : SoftwareRequirementVerification;
            }
            part unverified : Table {
                attribute :>> caption = "Software requirements without a verification case";
                calc rows : UnverifiedSoftwareRequirements;
            }
            part systemCases : Table {
                attribute :>> caption = "System verification cases covering software requirements";
                calc rows : SystemCasesCoveringSoftware;
            }
            part vvRef : Paragraph {
                part lead : Span { attribute :>> text = "The system requirements these rows derive from are verified in the verification and validation matrix,"; }
                part matrix : Ref { ref :>> target = vvReport.needs; }
                part tail : Span { attribute :>> text = "."; }
            }
        }
    }

    // ---- 7. software operations handbook ----------------------------------------------------------

    part def SoftwareOperationsHandbook :> Document {
        doc /* Operating the software: flight modes and the configuration each commands, the
             * on-board sequences, the fault-protection events and responses, the flight rules and
             * procedures, the Meridian command workflow and the pass-planning figures. */
        attribute :>> title = "Argent flight software and Meridian Operations Suite operations handbook";
        part scope : Paragraph {
            attribute :>> text = "How the flight software is operated through the Meridian Operations Suite, as TethysModes, TethysSequence, TethysFdir, TethysOperations and TethysGroundSoftware define it.";
        }
        part modes : Section {
            attribute :>> title = "Flight modes";
            part list : Table {
                attribute :>> caption = "Flight modes";
                calc rows : FlightModes;
            }
            part configurations : Table {
                attribute :>> caption = "Subsystem configuration commanded in each mode";
                calc rows : ModeConfigurations;
            }
        }
        part sequences : Section {
            attribute :>> title = "On-board sequences";
            part list : Table {
                attribute :>> caption = "Sequences by number";
                calc rows : OnBoardSequences;
            }
        }
        part faultProtection : Section {
            attribute :>> title = "Fault protection";
            part events : Table {
                attribute :>> caption = "Fault and on-board events";
                calc rows : FaultEvents;
            }
            part supervisor : Table {
                attribute :>> caption = "Supervisor monitors";
                calc rows : NamedStates { in :>> root = "TethysFdir::FdirSupervisor"; }
            }
            part limits : Table {
                attribute :>> caption = "Limit tables";
                calc rows : FdirLimits;
            }
        }
        part rules : Section {
            attribute :>> title = "Flight rules and procedures";
            part flightRules : Definitions {
                attribute :>> term = "shortName";
                attribute :>> description = "documentation";
                calc rows : OperationsRequirements;
            }
            part procedures : Table {
                attribute :>> caption = "Procedures and activities";
                calc rows : Procedures;
            }
        }
        part meridian : Section {
            attribute :>> title = "Meridian command workflow";
            part uplink : Table {
                attribute :>> caption = "Uplink exchange: command builder, flight-rule checker, flight sequence store";
                calc rows : NamedParts { in :>> root = "TethysGroundSoftware::UplinkExchange"; }
            }
            part requests : Table {
                attribute :>> caption = "Command requests checked by the command builder";
                calc rows : CommandRequests;
            }
            part alarms : Table {
                attribute :>> caption = "Telemetry server limit checks";
                calc rows : TelemetryAlarms;
            }
        }
        part passes : Section {
            attribute :>> title = "Pass planning";
            part planner : Table {
                attribute :>> caption = "Pass planner figures";
                calc rows : PassPlannerFigures;
            }
            part operations : Table {
                attribute :>> caption = "Operations centre consoles and roles";
                calc rows : NamedParts { in :>> root = "TethysGroundSoftware::SoftwareOperationsCentre"; }
            }
        }
    }

    // ---- 8. the index -----------------------------------------------------------------------------

    part def SoftwareDocumentIndex :> Document {
        doc /* The entry point of the set: the register with identifier, version and status, and
             * the reading order. */
        attribute :>> title = "Argent flight software and Meridian Operations Suite document index";
        part scope : Paragraph {
            attribute :>> text = "The software document set, rendered from the Tethys model. Read the architecture description first, then the requirements specification, the design descriptions, the interface control volume, the dictionary volume, the test plan and the operations handbook. Status and version are carried by TethysSoftwareDocuments::softwareDocumentSet.";
        }
        part register : Table {
            attribute :>> caption = "Document register";
            calc rows : DocumentRecords;
        }
    }
}
