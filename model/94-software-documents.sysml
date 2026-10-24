// The software architecture document set as the model carries it: one record per document with
// its identifier, title, version, status, the document definition that renders it and the
// packages it is derived from. The tooling file renders the documents themselves; this register
// is the pilot-portable entry point the document index is rendered from.
package TethysSoftwareDocuments {
    doc /* The register of the Argent flight software and Meridian Operations Suite document set.
         * Every document is rendered from the model by TethysSoftwareDocumentsTooling; the
         * register carries what a rendered document cannot derive about itself: its identifier,
         * version and status at this baseline. Reading order: the index first, then the
         * architecture description, the requirements specification, the design descriptions,
         * the interface control volume, the dictionary volume, the test plan and the operations
         * handbook. */

    private import ScalarValues::*;
    private import SequenceFunctions::size;
    private import ControlFunctions::select;
    private import TethysSoftwareRequirements::*;

    enum def DocumentStatus {
        doc /* Where a document of the set stands: drafted from the model, baselined at a review,
             * or released with the software it describes. */
        draft;
        baselined;
        released;
    }

    attribute def DocumentRecord {
        doc /* One document of the set: its identifier, title, version and status, the document
             * definition that renders it, the number of volumes it is rendered as and the model
             * packages its sections are queried from. */
        attribute id : String;
        attribute title : String;
        attribute version : String;
        attribute status : DocumentStatus;
        attribute renderTarget : String;
        attribute volumes : Natural default = 1;
        attribute sourcePackages : String[*];
    }

    part def SoftwareDocumentSet {
        doc /* The document set: nine records, two of which (the flight and ground design
             * descriptions) are rendered as twelve volumes each, one per application or
             * component. Every record is a draft at version 0.1 until the software release gate
             * of TethysSoftwareAssurance closes; the status is read by the index document and by
             * the release report, not asserted by them. */
        attribute index : DocumentRecord {
            :>> id = "SW-IDX-001"; :>> title = "Software document index"; :>> version = "0.1"; :>> status = DocumentStatus::draft;
            :>> renderTarget = "TethysSoftwareDocumentsTooling::SoftwareDocumentIndex";
            :>> sourcePackages = ("TethysSoftwareDocuments");
        }
        attribute architectureDescription : DocumentRecord {
            :>> id = "SW-SAD-001"; :>> title = "Software architecture description"; :>> version = "0.1"; :>> status = DocumentStatus::draft;
            :>> renderTarget = "TethysSoftwareDocumentsTooling::SoftwareArchitectureDescription";
            :>> sourcePackages = ("TethysFlightSoftware", "TethysFlightTiming", "TethysGroundSoftware", "TethysAllocations", "TethysSoftwareRequirements");
        }
        attribute requirementsSpecification : DocumentRecord {
            :>> id = "SW-SRS-001"; :>> title = "Software requirements specification"; :>> version = "0.1"; :>> status = DocumentStatus::draft;
            :>> renderTarget = "TethysSoftwareDocumentsTooling::SoftwareRequirementsSpecification";
            :>> sourcePackages = ("TethysSoftwareRequirements", "TethysSoftwareAssurance", "TethysVerification");
        }
        attribute flightDesignDescriptions : DocumentRecord {
            :>> id = "SW-SDD-F"; :>> title = "Flight application design descriptions"; :>> version = "0.1"; :>> status = DocumentStatus::draft;
            :>> renderTarget = "TethysSoftwareDocumentsTooling::FlightApplicationDesignDescription"; :>> volumes = 12;
            :>> sourcePackages = ("TethysFlightSoftware", "TethysFlightBehaviour", "TethysFlightTiming", "TethysFlightDictionary", "TethysSoftwareRequirements", "TethysSoftwareAssurance", "TethysAllocations");
        }
        attribute groundDesignDescriptions : DocumentRecord {
            :>> id = "SW-SDD-G"; :>> title = "Meridian component design descriptions"; :>> version = "0.1"; :>> status = DocumentStatus::draft;
            :>> renderTarget = "TethysSoftwareDocumentsTooling::GroundComponentDesignDescription"; :>> volumes = 12;
            :>> sourcePackages = ("TethysGroundSoftware", "TethysSoftwareRequirements", "TethysSoftwareAssurance", "TethysVerification");
        }
        attribute interfaceControlVolume : DocumentRecord {
            :>> id = "SW-ICD-001"; :>> title = "Software interface control volume"; :>> version = "0.1"; :>> status = DocumentStatus::draft;
            :>> renderTarget = "TethysSoftwareDocumentsTooling::SoftwareInterfaceControlVolume";
            :>> sourcePackages = ("TethysSoftwareIcds", "TethysIcds");
        }
        attribute dictionaryVolume : DocumentRecord {
            :>> id = "SW-DIC-001"; :>> title = "Flight dictionary volume"; :>> version = "0.1"; :>> status = DocumentStatus::draft;
            :>> renderTarget = "TethysSoftwareDocumentsTooling::FlightDictionaryVolume";
            :>> sourcePackages = ("TethysFlightDictionary", "TethysFdir");
        }
        attribute testPlan : DocumentRecord {
            :>> id = "SW-STP-001"; :>> title = "Software test plan and verification cross-reference"; :>> version = "0.1"; :>> status = DocumentStatus::draft;
            :>> renderTarget = "TethysSoftwareDocumentsTooling::SoftwareTestPlan";
            :>> sourcePackages = ("TethysSoftwareAssurance", "TethysVerification", "TethysGroundSoftware", "TethysSoftwareRequirements");
        }
        attribute operationsHandbook : DocumentRecord {
            :>> id = "SW-OPS-001"; :>> title = "Software operations handbook"; :>> version = "0.1"; :>> status = DocumentStatus::draft;
            :>> renderTarget = "TethysSoftwareDocumentsTooling::SoftwareOperationsHandbook";
            :>> sourcePackages = ("TethysModes", "TethysSequence", "TethysFdir", "TethysOperations", "TethysGroundSoftware", "TethysFlightDictionary");
        }
        attribute records : DocumentRecord[9] = (index, architectureDescription, requirementsSpecification,
            flightDesignDescriptions, groundDesignDescriptions, interfaceControlVolume, dictionaryVolume, testPlan, operationsHandbook);
        attribute documentCount : Natural = size(records);
        attribute volumeCount : Natural = documentCount - 2 + flightDesignDescriptions.volumes + groundDesignDescriptions.volumes;
        attribute releasedCount : Natural = size(records.status->select { in s : DocumentStatus; s == DocumentStatus::released });
    }

    part softwareDocumentSet : SoftwareDocumentSet {
        doc /* The document set at this baseline. */
    }

    // ---- system verification cases that also cover software requirements ---------------------
    // Each usage subsets a TethysVerification case and adds the TF-/TM- rows derived from the system
    // rows that case verifies, so the software rows are reachable from the system campaign too. They
    // live here, after 67 and 88, so the requirement rows of 67 and the 41-row matrix of 88 keep
    // their counts; the test plan and the requirements specification render them.
    verification captureEnvelopeTestSoftware :> TethysVerification::captureEnvelopeTest {
        doc /* CaptureEnvelopeTest as it also verifies the software requirements derived from the system rows it verifies. */
        objective {
            doc /* The software rows derived from the system rows this case verifies. */
            verify simulatorFidelity { doc /* Verified by this case. */ }
        }
    }
    verification contactSpeedTestSoftware :> TethysVerification::contactSpeedTest {
        doc /* ContactSpeedTest as it also verifies the software requirements derived from the system rows it verifies. */
        objective {
            doc /* The software rows derived from the system rows this case verifies. */
            verify inspectorHandlingApplication { doc /* Verified by this case. */ }
            verify captureControlApplication { doc /* Verified by this case. */ }
            verify proximityGoNoGo { doc /* Verified by this case. */ }
        }
    }
    verification linkBudgetTestSoftware :> TethysVerification::linkBudgetTest {
        doc /* LinkBudgetTest as it also verifies the software requirements derived from the system rows it verifies. */
        objective {
            doc /* The software rows derived from the system rows this case verifies. */
            verify telemetryRatesByMode { doc /* Verified by this case. */ }
            verify timeCorrelation { doc /* Verified by this case. */ }
            verify telemetrySampleLatency { doc /* Verified by this case. */ }
            verify dataStoreRetention { doc /* Verified by this case. */ }
            verify telemetryOutput { doc /* Verified by this case. */ }
            verify housekeepingSampling { doc /* Verified by this case. */ }
            verify telecomApplication { doc /* Verified by this case. */ }
            verify passPlanningVolume { doc /* Verified by this case. */ }
        }
    }
    verification faultResponseTestSoftware :> TethysVerification::faultResponseTest {
        doc /* FaultResponseTest as it also verifies the software requirements derived from the system rows it verifies. */
        objective {
            doc /* The software rows derived from the system rows this case verifies. */
            verify eventLogging { doc /* Verified by this case. */ }
            verify parameterTables { doc /* Verified by this case. */ }
            verify partitionIsolation { doc /* Verified by this case. */ }
            verify faultDetectionChain { doc /* Verified by this case. */ }
            verify safeConfigurationLatency { doc /* Verified by this case. */ }
            verify fdirTaskRate { doc /* Verified by this case. */ }
            verify safeModeEntry { doc /* Verified by this case. */ }
            verify heartbeatFailover { doc /* Verified by this case. */ }
            verify boardSupportWatchdog { doc /* Verified by this case. */ }
            verify gncApplication { doc /* Verified by this case. */ }
            verify captureControlApplication { doc /* Verified by this case. */ }
            verify fdirApplication { doc /* Verified by this case. */ }
            verify modeManagementApplication { doc /* Verified by this case. */ }
        }
    }
    verification autonomyTestSoftware :> TethysVerification::autonomyTest {
        doc /* AutonomyTest as it also verifies the software requirements derived from the system rows it verifies. */
        objective {
            doc /* The software rows derived from the system rows this case verifies. */
            verify eventLogging { doc /* Verified by this case. */ }
            verify imageIntegrity { doc /* Verified by this case. */ }
            verify bootFallback { doc /* Verified by this case. */ }
            verify safeModeEntry { doc /* Verified by this case. */ }
            verify modeTransitions { doc /* Verified by this case. */ }
            verify redundancyManagement { doc /* Verified by this case. */ }
            verify heartbeatFailover { doc /* Verified by this case. */ }
            verify dataStoreRetention { doc /* Verified by this case. */ }
            verify boardSupportWatchdog { doc /* Verified by this case. */ }
            verify cdhApplication { doc /* Verified by this case. */ }
            verify thermalControlApplication { doc /* Verified by this case. */ }
            verify parameterBootUpdateApplication { doc /* Verified by this case. */ }
            verify flightDynamicsProducts { doc /* Verified by this case. */ }
        }
    }
    verification deflectionAnalysisSoftware :> TethysVerification::deflectionAnalysis {
        doc /* DeflectionAnalysis as it also verifies the software requirements derived from the system rows it verifies. */
        objective {
            doc /* The software rows derived from the system rows this case verifies. */
            verify timeCorrelation { doc /* Verified by this case. */ }
            verify flightDynamicsProducts { doc /* Verified by this case. */ }
        }
    }
    verification groundReadinessDemoSoftware :> TethysVerification::groundReadinessDemo {
        doc /* GroundReadinessDemo as it also verifies the software requirements derived from the system rows it verifies. */
        objective {
            doc /* The software rows derived from the system rows this case verifies. */
            verify commandIngest { doc /* Verified by this case. */ }
            verify telemetryRatesByMode { doc /* Verified by this case. */ }
            verify commandDispatchLatency { doc /* Verified by this case. */ }
            verify sequencingEngine { doc /* Verified by this case. */ }
            verify schedulerCapacity { doc /* Verified by this case. */ }
            verify autonomyApplication { doc /* Verified by this case. */ }
            verify commandValidation { doc /* Verified by this case. */ }
            verify hazardousApproval { doc /* Verified by this case. */ }
            verify sequenceClearance { doc /* Verified by this case. */ }
            verify trendingAutomation { doc /* Verified by this case. */ }
            verify passPlanningVolume { doc /* Verified by this case. */ }
            verify anomalyDisposition { doc /* Verified by this case. */ }
        }
    }
    verification groundProceduresDemoSoftware :> TethysVerification::groundProceduresDemo {
        doc /* GroundProceduresDemo as it also verifies the software requirements derived from the system rows it verifies. */
        objective {
            doc /* The software rows derived from the system rows this case verifies. */
            verify sequenceClearance { doc /* Verified by this case. */ }
            verify limitAlarming { doc /* Verified by this case. */ }
            verify trendingAutomation { doc /* Verified by this case. */ }
            verify flightDynamicsProducts { doc /* Verified by this case. */ }
            verify archiveRetention { doc /* Verified by this case. */ }
        }
    }
}
