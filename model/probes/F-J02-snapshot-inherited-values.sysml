package 'F-J02-snapshot-inherited-values' {
    doc /* Smallest reproducer for docs/findings/WP-J.md F-J02. The snapshot is a portion of the same
         * occurrence, so `atReview.product` is expected to read the owner's `width` (3) with the
         * snapshot's own `height` (5) and give 15. Both validators accept the file. */
    private import ScalarValues::*;
    part def Panel {
        attribute width : Natural;
        attribute height : Natural;
        attribute product : Natural = width * height;
    }
    part panel : Panel {
        attribute :>> width = 3;
        attribute :>> height default = 2;
        snapshot atReview : Panel {
            attribute :>> height = 5;
        }
    }
    part reader {
        attribute current : Natural = panel.product;
        attribute atReview : Natural = panel.atReview.product;
        assert constraint snapshotProduct { atReview == 15 }
    }
}
