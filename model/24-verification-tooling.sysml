// Tool-tier companion of TethysVerification: the document queries that compute the V&V matrix,
// the list of unverified requirements and the verdict table, and the V&V report document. This is
// the only WP-A file that references an OpenSysML library package (DocumentQueries).
package TethysVerificationTooling {
    doc /* Document queries over the requirements tree. `UnverifiedRequirements` is the gate:
         * it lists every requirement usage with no incoming verification relationship, and the
         * pinned run of it must be empty. `VvMatrix` is the requirement-to-verification matrix
         * as rows; `VvReport` renders both as a document. */

    private import ScalarValues::*;
    private import KerML::Root::*;
    private import DocumentQueries::*;

    calc def TreeRoots :> Query {
        doc /* The packages that hold the requirements tree: L1, the stakeholder layer, L2 and
             * L3/L4. */
        Named(qualifiedName = ("TethysRequirements", "TethysStakeholders", "TethysRequirementsL2", "TethysRequirementsL3L4"))
    }

    calc def RequirementRows :> Query {
        doc /* Every requirement usage under root that is a requirement in its own right: not a
             * satisfy reference, not a concern or viewpoint, not a use case's objective, and
             * not a `require`/`verify` member that merely subsets another requirement. */
        in root : Element[0..*] ordered;
        Except(
            source = WhereType(source = Descendants(source = root), type = "RequirementUsage"),
            exclude = Union(
                source = Union(
                    source = WhereType(source = Descendants(source = root), type = "SatisfyRequirementUsage"),
                    other = Union(
                        source = WhereType(source = Descendants(source = root), type = "ConcernUsage"),
                        other = WhereType(source = Descendants(source = root), type = "ViewpointUsage")
                    )
                ),
                other = Union(
                    source = WhereRelated(source = WhereType(source = Descendants(source = root), type = "RequirementUsage"), relationshipKind = "subsetting", direction = "outgoing", maxDepth = 1),
                    other = Descendants(source = WhereType(source = Descendants(source = root), type = "UseCaseDefinition"), maxDepth = 1)
                )
            )
        )
    }

    calc def UnverifiedRequirements :> Query {
        doc /* The requirements of the whole tree that no verification case verifies. Empty when
             * the programme is complete; the pinned run is the gate. */
        Project(
            source = WhereRelated(source = RequirementRows(root = TreeRoots()), relationshipKind = "verification", direction = "incoming", exists = false),
            properties = ("shortName", "name")
        )
    }

    calc def VvMatrix :> Query {
        doc /* The V&V matrix: each requirement with the number of verification cases that verify
             * it, the cases themselves and the parts that satisfy it. */
        in root : Element[0..*] ordered;
        Project(
            source = RequirementRows(root = root),
            properties = ("shortName", "name"),
            columns = (
                RelatedColumn(name = "verifiedBy", relationshipKind = "verification", direction = "incoming", aggregate = "list"),
                RelatedColumn(name = "cases", relationshipKind = "verification", direction = "incoming", aggregate = "count"),
                RelatedColumn(name = "satisfiedBy", relationshipKind = "satisfaction", direction = "incoming", aggregate = "list"),
                RelatedColumn(name = "derivedFrom", relationshipKind = "derivation", direction = "incoming", aggregate = "list")
            )
        )
    }

    calc def VerificationOutcomes :> Query {
        doc /* Every verification case, requirement and satisfaction under root with its verdict. */
        in root : Element[0..*] ordered;
        Project(
            source = WhereFeature(source = Verdicts(source = root), 'feature' = "kind", operator = "!=", value = "constraint"),
            properties = ("path", "kind", "name", "verdict", "verification")
        )
    }

    calc def VvMatrixOf :> Query {
        doc /* VvMatrix over the package the qualified name denotes, for document tables, which
             * bind strings rather than packages. */
        in rootName : String;
        VvMatrix(root = Named(qualifiedName = rootName))
    }

    part def VvReport :> Document {
        doc /* The verification and validation report: the matrix over every requirement level
             * and the outstanding list. */
        attribute :>> title = "Tethys verification and validation matrix";
        part scope : Paragraph {
            attribute :>> text = "Every requirement of the Tethys tree (L1 to L4, needs, objectives and success criteria), the cases that verify it, the parts that satisfy it and the requirements it derives from.";
        }
        part l1 : Table {
            attribute :>> caption = "L1 mission requirements";
            calc rows : VvMatrixOf { in rootName = "TethysRequirements"; }
        }
        part needs : Table {
            attribute :>> caption = "Needs, objectives and success criteria";
            calc rows : VvMatrixOf { in rootName = "TethysStakeholders"; }
        }
        part l2 : Table {
            attribute :>> caption = "L2 system requirements";
            calc rows : VvMatrixOf { in rootName = "TethysRequirementsL2"; }
        }
        part l3l4 : Table {
            attribute :>> caption = "L3 subsystem and L4 component requirements";
            calc rows : VvMatrixOf { in rootName = "TethysRequirementsL3L4"; }
        }
        part outstanding : Section {
            attribute :>> title = "Requirements without a verification case";
            part none : Table {
                attribute :>> caption = "Unverified requirements (expected empty)";
                calc rows : UnverifiedRequirements;
            }
        }
    }
}
