// Tool tier half of the F-SW192 probe: the field table read from the layout by DocumentQueries.
package F_SW192_Query {
    private import ScalarValues::*;
    private import DocumentQueries::*;
    calc def Fields :> Query {
        Project(source = OrderBy(source = WhereType(source = OwnedElements(source = Named(qualifiedName = "F_SW192::hk")), type = "AttributeUsage"),
            property = "order", direction = "ascending", missing = "last", multiple = "first"), properties = ("name", "order", "offset", "width"))
    }
}
