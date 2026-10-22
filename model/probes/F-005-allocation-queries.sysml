package 'F-005-allocation-queries' {
    doc /* Allocation coverage queries for TethysAllocations (docs/findings.md F-005). They need
         * the DocumentQueries library, which the pinned pilot validator does not ship, so they
         * live outside model/*.sysml and are run with the model as an extra file. */
    private import DocumentQueries::*;
    private import KerML::Root::*;

    calc def UnallocatedFunctions :> Query {
        doc /* Action usages under root with no outgoing allocation. Expected: no rows. */
        in root : Element;
        WhereRelated(source = WhereType(source = Descendants(source = root), type = "ActionUsage"),
                     relationshipKind = "allocation", direction = "outgoing", exists = false)
    }

    calc def UnallocatedRequirements :> Query {
        doc /* Requirement usages under root with no outgoing allocation. Expected: no rows. */
        in root : Element;
        WhereRelated(source = WhereType(source = OwnedElements(source = root), type = "RequirementUsage"),
                     relationshipKind = "allocation", direction = "outgoing", exists = false)
    }

    calc def AllocationTargets :> Query {
        doc /* The components an element is allocated to. */
        in origin : Element;
        RelatedElements(source = origin, relationshipKind = "allocation", direction = "outgoing", maxDepth = 1)
    }
}
