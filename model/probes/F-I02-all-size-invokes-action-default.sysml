package 'F-I02' {
    doc /* `(all Body)->size()` where an individual Body performs a sequence whose action has an
         * `out` default computed from its `in`: counting the individuals runs the sequence and
         * meets the output-default-before-input defect. */
    private import ScalarValues::*;
    private import SequenceFunctions::size;
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
    individual part def Body;
    individual part amaranth : Body {
        item theReport : Report { attribute :>> size = 6.8; }
        perform action run : Sequence;
        bind run.measure.report = theReport;
    }
    part readiness {
        attribute bodyCount : Natural = (all Body)->size();
    }
}
