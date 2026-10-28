// Tool-tier companion of TethysSoftwareAssurance: the document queries that prove every software
// component is classified, every software function has a verification case, and render the software
// FMECA, the verification cross-reference matrix, the release gate and the fault tree. This is the
// only WP-SW-8 file that references an OpenSysML library package (DocumentQueries).
package TethysSoftwareAssuranceTooling {
    doc /* Document queries over TethysSoftwareAssurance. `UncoveredSoftwareFunctions` and
         * `UnclassifiedSoftwareRows` are the gates (expected empty); `SoftwareVcrm` is the
         * verification cross-reference matrix; `SoftwareFmecaDocument`, `SoftwareVcrmDocument`
         * and `SoftwareAssuranceReport` render the tables. */

    private import ScalarValues::*;
    private import KerML::Root::*;
    private import DocumentQueries::*;

    calc def AssuranceRoot :> Query {
        doc /* The software assurance package. */
        Named(qualifiedName = "TethysSoftwareAssurance")
    }

    calc def ClassificationRows :> Query {
        doc /* The classification register: one row per flight and ground software component with
             * its assurance level and rationale. */
        Project(
            source = WhereFeature(source = WhereType(source = Descendants(source = Named(qualifiedName = "TethysSoftwareAssurance::classificationRegister"), maxDepth = 1), type = "PartUsage"), 'feature' = "level", operator = "!=", value = ""),
            properties = ("name", "level", "rationale")
        )
    }

    calc def UnclassifiedSoftwareRows :> Query {
        doc /* Classification rows whose level is unset: expected empty, the complement of the
             * register's flightRowsAreDistinct and groundRowsCoverTheSuite assertions. */
        Project(
            source = WhereFeature(source = WhereType(source = Descendants(source = Named(qualifiedName = "TethysSoftwareAssurance::classificationRegister"), maxDepth = 1), type = "PartUsage"), 'feature' = "level", operator = "==", value = ""),
            properties = ("name", "level")
        )
    }

    calc def SoftwareFunctions :> Query {
        doc /* The software functions of TethysAllocations: the usages typed SoftwareFunction other
             * than the SoftwareHosting end and the cases' verifiedFunctions, which the type also
             * types. */
        Except(
            source = RelatedElements(source = Named(qualifiedName = "TethysAllocations::SoftwareFunction"), relationshipKind = "typing", direction = "incoming", maxDepth = 1),
            exclude = Union(source = Descendants(source = AssuranceRoot()), other = Descendants(source = Named(qualifiedName = "TethysAllocations::SoftwareHosting")))
        )
    }

    calc def SoftwareFunctionCoverage :> Query {
        doc /* Every software function with the verification cases that exercise it, found through
             * the cases' verifiedFunctions subsetting. */
        Project(
            source = SoftwareFunctions(),
            properties = ("name",),
            columns = (
                RelatedColumn(name = "verifiedBy", relationshipKind = "subsetting", direction = "incoming", aggregate = "list"),
                RelatedColumn(name = "cases", relationshipKind = "subsetting", direction = "incoming", aggregate = "count"),
                RelatedColumn(name = "hostedOn", relationshipKind = "allocation", direction = "outgoing", aggregate = "list")
            )
        )
    }

    calc def UncoveredSoftwareFunctions :> Query {
        doc /* Software functions no verification case subsets: expected empty. */
        Project(
            source = WhereRelated(source = SoftwareFunctions(), relationshipKind = "subsetting", direction = "incoming", exists = false),
            properties = ("name",)
        )
    }

    calc def SoftwareVerificationCases :> Query {
        doc /* The verification usages of the assurance package. */
        WhereType(source = Descendants(source = AssuranceRoot(), maxDepth = 1), type = "VerificationCaseUsage")
    }

    calc def SoftwareVcrm :> Query {
        doc /* The verification cross-reference matrix: each case with its level, test bed, verdict,
             * evidence and method, the system rows it verifies and the functions it exercises. */
        Project(
            source = SoftwareVerificationCases(),
            properties = ("name", "SoftwareVerification::level", "SoftwareVerification::testBed", "SoftwareVerification::verdict", "SoftwareVerification::evidence", "Verification::method"),
            columns = (
                RelatedColumn(name = "verifies", relationshipKind = "verification", direction = "outgoing", aggregate = "list"),
                RelatedColumn(name = "rows", relationshipKind = "verification", direction = "outgoing", aggregate = "count")
            )
        )
    }

    calc def PassedCases :> Query {
        doc /* The cases that pass: expected to be the model-in-the-loop cases only. */
        Project(
            source = WhereFeature(source = SoftwareVerificationCases(), 'feature' = "SoftwareVerification::verdict", operator = "==", value = "pass"),
            properties = ("name", "SoftwareVerification::level", "SoftwareVerification::evidence")
        )
    }

    calc def SoftwareFmecaRows :> Query {
        doc /* The software FMECA table. */
        Project(
            source = WhereFeature(source = WhereType(source = Descendants(source = Named(qualifiedName = "TethysSoftwareAssurance::softwareFmeca"), maxDepth = 1), type = "OccurrenceUsage"), 'feature' = "failureMode", operator = "!=", value = ""),
            properties = ("shortName", "name", "failureMode", "localEffect", "endEffect", "detection", "response", "criticality", "level")
        )
    }

    calc def FaultTreeEvents :> Query {
        doc /* The premature-cinch fault tree: its basic and intermediate events with probabilities. */
        Project(
            source = WhereType(source = Descendants(source = Named(qualifiedName = "TethysSoftwareAssurance::prematureCinchTree"), maxDepth = 1), type = "OccurrenceUsage"),
            properties = ("name", "probability")
        )
    }

    calc def ReleaseGateRows :> Query {
        doc /* The release-readiness requirements and their verdicts. */
        Project(
            source = WhereType(source = Descendants(source = AssuranceRoot(), maxDepth = 1), type = "RequirementUsage"),
            properties = ("shortName", "name", "Verification::method")
        )
    }

    part def SoftwareFmecaDocument :> Document {
        doc /* The software FMECA rendered from the model. */
        attribute :>> title = "Argent flight software FMECA";
        part scope : Paragraph {
            attribute :>> text = "One row per application and one for the executive: failure mode, local and end effect, detection, response and criticality, with the assurance level of the component.";
        }
        part rows : Table {
            attribute :>> caption = "Software failure modes";
            calc rows : SoftwareFmecaRows;
        }
        part tree : Table {
            attribute :>> caption = "Premature-cinch fault tree events";
            calc rows : FaultTreeEvents;
        }
    }

    part def SoftwareVcrmDocument :> Document {
        doc /* The software verification cross-reference matrix rendered from the model. */
        attribute :>> title default = "Argent flight software and Meridian verification cross-reference matrix";
        part scope : Paragraph {
            attribute :>> text = "Every software verification case with its level, test bed, as-run verdict and evidence, the system requirements it verifies and the software functions it exercises. Planned cases have not run.";
        }
        part matrix : Table {
            attribute :>> caption = "Verification cross-reference matrix";
            calc rows : SoftwareVcrm;
        }
        part coverage : Table {
            attribute :>> caption = "Software functions and their cases";
            calc rows : SoftwareFunctionCoverage;
        }
        part uncovered : Table {
            attribute :>> caption = "Software functions without a case (expected empty)";
            calc rows : UncoveredSoftwareFunctions;
        }
        part passed : Table {
            attribute :>> caption = "Cases passed at this baseline";
            calc rows : PassedCases;
        }
    }

    part def SoftwareAssuranceReport :> Document {
        doc /* The software assurance report: classification, release gate and the gates' queries. */
        attribute :>> title = "Argent flight software assurance report";
        part classification : Table {
            attribute :>> caption = "Software classification register";
            calc rows : ClassificationRows;
        }
        part unclassified : Table {
            attribute :>> caption = "Rows without a level (expected empty)";
            calc rows : UnclassifiedSoftwareRows;
        }
        part gate : Table {
            attribute :>> caption = "Release-readiness requirements";
            calc rows : ReleaseGateRows;
        }
    }
}
