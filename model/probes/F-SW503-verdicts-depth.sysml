// F-SW503 probe: DocumentQueries::Verdicts refuses a source whose object tree nests deeper than
// eight part levels, even when the satisfaction it is asked about is on a direct child. `eight`
// (leaf at level 8) answers; `ten` (leaf at level 10) is refused with "objects nested beyond the
// depth the validation descends were not checked". Standalone:
//   sysml -quiet -run-query F_SW503::EightVerdicts -run-query F_SW503::TenVerdicts model/probes/F-SW503-verdicts-depth.sysml
package F_SW503 {
    doc /* Minimal probe for the Verdicts nesting-depth limit: the same requirement satisfied by
         * a direct child of two roots, one with a leaf eight levels down and one ten levels down. */
    private import ScalarValues::*;
    private import KerML::Root::*;
    private import DocumentQueries::*;

    part def Leaf { doc /* The deepest level, with an assertion of its own. */ attribute depth : Natural default = 1; assert constraint positive { depth > 0 } }
    part def E8 { doc /* Eight-chain level 8. */ part c : Leaf; }
    part def E7 { doc /* Eight-chain level 7. */ part c : E8; }
    part def E6 { doc /* Eight-chain level 6. */ part c : E7; }
    part def E5 { doc /* Eight-chain level 5. */ part c : E6; }
    part def E4 { doc /* Eight-chain level 4. */ part c : E5; }
    part def E3 { doc /* Eight-chain level 3. */ part c : E4; }
    part def E2 { doc /* Eight-chain level 2. */ part c : E3; }
    part def Eight { doc /* A root whose leaf is eight levels down. */ part direct : Leaf; part c : E2; }
    part def T10 { doc /* Ten-chain level 10. */ part c : Leaf; }
    part def T9 { doc /* Ten-chain level 9. */ part c : T10; }
    part def T8 { doc /* Ten-chain level 8. */ part c : T9; }
    part def T7 { doc /* Ten-chain level 7. */ part c : T8; }
    part def T6 { doc /* Ten-chain level 6. */ part c : T7; }
    part def T5 { doc /* Ten-chain level 5. */ part c : T6; }
    part def T4 { doc /* Ten-chain level 4. */ part c : T5; }
    part def T3 { doc /* Ten-chain level 3. */ part c : T4; }
    part def T2 { doc /* Ten-chain level 2. */ part c : T3; }
    part def Ten { doc /* A root whose leaf is ten levels down. */ part direct : Leaf; part c : T2; }

    requirement directPositive { doc /* The direct child's depth is positive. */ subject l : Leaf; require constraint { l.depth > 0 } }

    part eight : Eight;
    part ten : Ten;
    satisfy directPositive by eight.direct { doc /* One level down under the eight-level root. */ }
    satisfy directPositive by ten.direct { doc /* One level down under the ten-level root. */ }

    calc def EightVerdicts :> Query {
        doc /* Answers: one row, holds. */
        Project(source = Verdicts(source = Named(qualifiedName = "F_SW503::eight"), kind = "satisfaction"), properties = ("path", "verdict"))
    }
    calc def TenVerdicts :> Query {
        doc /* Refused: the root nests objects beyond the depth the validation descends. */
        Project(source = Verdicts(source = Named(qualifiedName = "F_SW503::ten"), kind = "satisfaction"), properties = ("path", "verdict"))
    }
}
