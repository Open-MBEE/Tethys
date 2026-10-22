// Diagram layout for the key diagrams: where TethysViews::segmentInterfaces draws each segment,
// how its interfaces are routed, and the note that explains the drawing. Layout is tool metadata
// (DiagramLayout, an OpenSysML library), not model semantics: deleting this file changes no
// element of the mission, only where a drawing puts it.
package TethysLayout {
    private import DiagramLayout::*;

    // Mission flow left to right: launch, flight, target; the visiting vehicle meets the stack
    // at the end, the ground segment talks to it from below. Segments are collapsed so the
    // segment-level ICD reads as five boxes and four interfaces.
    metadata Layout about TethysSystem::tethysSystem::launch {
        x = 40.0; y = 60.0; width = 220.0; height = 120.0; collapsed = true;
    }
    metadata Layout about TethysSystem::tethysSystem::flight {
        x = 370.0; y = 60.0; width = 220.0; height = 120.0; collapsed = true;
    }
    metadata Layout about TethysSystem::tethysSystem::target {
        x = 700.0; y = 60.0; width = 220.0; height = 120.0; collapsed = true;
    }
    metadata Layout about TethysSystem::tethysSystem::visitor {
        x = 700.0; y = 340.0; width = 220.0; height = 120.0; collapsed = true;
    }
    metadata Layout about TethysSystem::tethysSystem::ground {
        x = 370.0; y = 340.0; width = 220.0; height = 120.0; collapsed = true;
    }

    metadata Route about TethysSystem::tethysSystem::launchAdapter {
        points = (260.0, 120.0, 370.0, 120.0);
    }
    metadata Route about TethysSystem::tethysSystem::capture {
        points = (590.0, 120.0, 700.0, 120.0);
    }
    metadata Route about TethysSystem::tethysSystem::deepSpaceLink {
        points = (480.0, 180.0, 480.0, 340.0);
    }
    metadata Route about TethysSystem::tethysSystem::visitorDocking {
        points = (590.0, 150.0, 810.0, 340.0);
    }

    metadata Style about TethysSystem::tethysSystem::target {
        fill = "#f4e3c1"; line = "#8a6d3b";
    }
    metadata Note about TethysViews::segmentInterfaces {
        text = "Segment-level interface control: one interface definition per edge (TethysInterfaces).";
        x = 40.0; y = 440.0; width = 300.0; height = 60.0;
    }
}
