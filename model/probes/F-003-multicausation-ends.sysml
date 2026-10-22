package 'F-003-multicausation-ends' {
    doc /* Smallest reproducer for docs/findings.md F-003. Both validators accept this file; running
         * `sysml -instantiate 'F-003-multicausation-ends'::tree` reports a multiplicity violation
         * on gate.causes and gate.effects although both ends are bound through subsetting ends. */
    private import CauseAndEffect::*;
    occurrence tree {
        #cause event occurrence a;
        #cause event occurrence b;
        #effect event occurrence top;
        #multicausation connection gate {
            end #cause :> causes ::> a;
            end #cause :> causes ::> b;
            end #effect :> effects ::> top;
        }
    }
}
