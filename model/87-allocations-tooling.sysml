package TethysAllocationQueries {
    doc /* Tool-tier coverage queries over TethysAllocations: the functions and requirements with
         * no allocation, and the components an element is allocated to. They need the
         * DocumentQueries library, so they live in this file rather than in
         * model/87-allocations.sysml, which stays in the mission tier. */
    private import DocumentQueries::*;
    private import KerML::Root::*;

    calc def UnallocatedFunctions :> Query {
        doc /* Action usages under root with no outgoing allocation. Expected over
             * TethysAllocations::missionFunctions: no rows. */
        in root : Element;
        WhereRelated(source = WhereType(source = Descendants(source = root), type = "ActionUsage"),
                     relationshipKind = "allocation", direction = "outgoing", exists = false)
    }

    calc def UnallocatedRequirements :> Query {
        doc /* Requirement usages owned by root with no outgoing allocation. Expected over
             * TethysRequirements: no rows. */
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
