// Tool-tier views: the ones that need an OpenSysML rendering (OpenSysMLRenderings) and so are
// gated by the batch pilot only. Everything they expose and satisfy is in the mission-tier
// TethysViews; nothing in the mission tier refers back here.
package TethysViewsTooling {
    private import Views::*;
    private import OpenSysMLRenderings::*;

    view systemOverview {
        doc /* Everything in one drawing: the system's parts, ports and interfaces mixed. */
        expose TethysSystem::tethysSystem;
        render asMixedDiagram;
        view interfaces :> TethysViews::segmentInterfaces;
        satisfy TethysViews::interfaceViewpoint {
            doc /* This view answers the interfaceViewpoint. */
        }
        satisfy TethysViews::budgetViewpoint {
            doc /* This view answers the budgetViewpoint. */
        }
    }
}
