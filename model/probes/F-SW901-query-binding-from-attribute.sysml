// F-SW901: a document block's query argument can only be bound to a literal. Binding it to an
// attribute of the document (so a family of documents could share one section set and differ
// only in the bound subject) is rejected by the document planner: "binding root has type
// element, expected ScalarValues::String". Consequence: the 24 design descriptions each bind
// their literals; see docs/findings/WP-SW-9.md.
package F_SW901 {
    private import ScalarValues::*;
    private import DocumentQueries::*;
    part def Widget { doc /* A widget with a mass. */ attribute mass : Real; }
    part w1 : Widget { :>> mass = 1.0; }
    part w2 : Widget { :>> mass = 2.0; }
    calc def WidgetRows :> Query {
        doc /* Name and mass of the parts under the named root. */
        in root : String;
        Project(source = WhereType(source = OwnedElements(source = Named(qualifiedName = root)), type = "PartUsage"), properties = ("name", "mass"))
    }
    part def BoundByAttribute :> Document {
        doc /* The query argument bound to the document's own attribute: rejected. */
        attribute root : String;
        :>> title default = "Bound by attribute";
        part widgets : Table { :>> caption = "Widgets"; calc q : WidgetRows { in :>> root = root; } }
    }
    part def OneDoc :> BoundByAttribute { doc /* The specialisation that sets the attribute. */ :>> title = "One"; :>> root = "F_SW901"; }
    part def BoundByLiteral :> Document {
        doc /* The same table with a literal binding: rendered. */
        :>> title = "Bound by literal";
        part widgets : Table { :>> caption = "Widgets"; calc q : WidgetRows { in :>> root = "F_SW901"; } }
    }
}
