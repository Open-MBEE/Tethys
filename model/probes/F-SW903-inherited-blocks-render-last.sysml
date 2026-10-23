// F-SW903: a document that specialises another document inherits its blocks, but the renderer
// emits the specialising document's own blocks first and the inherited blocks after them, so a
// volume that extends an existing document cannot place its added sections after the base
// content without redefining every base block. See docs/findings/WP-SW-9.md.
package F_SW903 {
    private import ScalarValues::*;
    private import DocumentQueries::*;
    part def Base :> Document {
        doc /* The base document: one paragraph. */
        :>> title default = "Base";
        part baseText : Paragraph { :>> text = "Base block."; }
    }
    part def Volume :> Base {
        doc /* The volume: adds one paragraph, which renders before the inherited one. */
        :>> title = "Volume";
        part addedText : Paragraph { :>> text = "Added block."; }
    }
}
