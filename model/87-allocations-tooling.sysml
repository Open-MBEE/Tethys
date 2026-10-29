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

    calc def UnallocatedApplications :> Query {
        doc /* Application usages under root with no outgoing allocation. Expected over
             * TethysFlightSoftware::ArgentFlightSoftware: no rows. */
        in root : Element;
        WhereRelated(source = WhereType(source = Descendants(source = root), type = "Application"),
                     relationshipKind = "allocation", direction = "outgoing", exists = false)
    }

    calc def AllocatedApplications :> Query {
        doc /* Application usages under root with an outgoing allocation: the control that the
             * query above is not vacuous. Expected over
             * TethysFlightSoftware::ArgentFlightSoftware: the twelve applications. */
        in root : Element;
        WhereRelated(source = WhereType(source = Descendants(source = root), type = "Application"),
                     relationshipKind = "allocation", direction = "outgoing", exists = true)
    }

    calc def UnallocatedPartitions :> Query {
        doc /* Partition usages under root with no outgoing allocation. Expected over
             * TethysFlightSoftware::ArgentFlightSoftware: no rows. */
        in root : Element;
        WhereRelated(source = WhereType(source = Descendants(source = root), type = "Partition"),
                     relationshipKind = "allocation", direction = "outgoing", exists = false)
    }

    calc def AllocatedPartitions :> Query {
        doc /* Partition usages under root with an outgoing allocation. Expected over
             * TethysFlightSoftware::ArgentFlightSoftware: the five partitions. */
        in root : Element;
        WhereRelated(source = WhereType(source = Descendants(source = root), type = "Partition"),
                     relationshipKind = "allocation", direction = "outgoing", exists = true)
    }

    calc def UnallocatedRequirements :> Query {
        doc /* Requirement usages owned by root with no outgoing allocation. Expected over
             * TethysRequirements: no rows. */
        in root : Element;
        WhereRelated(source = WhereType(source = OwnedElements(source = root), type = "RequirementUsage"),
                     relationshipKind = "allocation", direction = "outgoing", exists = false)
    }

    calc def SafetyCriticalFunctions :> Query {
        doc /* The functions under root annotated @SafetyCritical, with the rationale each
             * carries. Expected over TethysSafety::safetyCriticalSoftware: the three functions
             * of the hazard analysis; the row count is the safety-critical software count. */
        in root : Element;
        Project(
            source = WhereMetadata(source = Descendants(source = root),
                                   'metadata' = "TethysSafety::SafetyCritical"),
            properties = ("name", "documentation"))
    }

    calc def AllocationTargets :> Query {
        doc /* The components an element is allocated to. */
        in origin : Element;
        RelatedElements(source = origin, relationshipKind = "allocation", direction = "outgoing", maxDepth = 1)
    }
}
