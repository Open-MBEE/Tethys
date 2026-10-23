package 'F-I01' {
    doc /* A viewpoint that frames a concern but requires no constraint, satisfied by a view:
         * the `-satisfy` verdict for a requirement that has nothing to evaluate. */
    private import Views::*;
    part def Mission;
    part mission : Mission;
    concern def Traceability {
        doc /* Every element is readable in its place. */
        subject mission : Mission;
    }
    concern traceability : Traceability {
        doc /* The concern as the project holds it. */
    }
    viewpoint def Reading {
        doc /* A reading of the model that frames the concern and requires nothing further. */
        frame traceability {
            doc /* Framed: traceability. */
        }
    }
    viewpoint reading : Reading {
        doc /* The reading as the project applies it. */
    }
    view tree {
        doc /* The one view that answers the reading. */
        expose mission;
        render asElementTable;
        satisfy reading {
            doc /* This view answers the reading. */
        }
    }
}
