package 'F-C04' {
    doc /* An action's `out` parameter with a default computed from its `in` parameter,
         * invoked in a sequence whose input is bound through a `bind` in the context. */
    private import ScalarValues::*;
    item def Report { attribute size : Real; }
    action def Measure { out report : Report; }
    action def Decide {
        in report : Report;
        out go : Boolean = report.size <= 10.0;
    }
    action def Sequence {
        action measure : Measure;
        then action decision : Decide { in report = measure.report; }
        then done;
    }
    part context {
        item theReport : Report { attribute :>> size = 6.8; }
        perform action run : Sequence;
        bind run.measure.report = theReport;
    }
}
