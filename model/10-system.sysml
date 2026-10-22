// The wiring that makes the segments one system: the concrete flight, launch and ground
// segments, the target body, the visiting vehicle and the top-level interfaces the ICDs are
// written against.
package TethysSystem {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysInterfaces::*;
    private import TethysMission::*;
    private import TethysTug::Tug;
    private import TethysInspector::Inspector;
    private import TethysTarget::SmallBody;
    private import TethysLaunch::*;
    private import TethysGround::*;

    part def TethysFlightSegment :> FlightSegment {
        doc /* The tug with Wren in its dispenser: the stack as launched. */
        part tug : Tug;
        part inspector : Inspector;
        interface inspectorCarrier : TugInspectorInterface
            connect tug.eps.inspectorKeepAlive to inspector.bus.umbilical;
        interface inspectorRelay : InspectorRelayLink
            connect inspector.bus.proximity to tug.telecom.proximity;
    }

    part def TethysLaunchSegment :> LaunchSegment {
        doc /* Arcturus-5H from its launch site within the Tethys window. */
        part vehicle : LaunchVehicle;
        part site : LaunchSite;
        part window : LaunchWindow;
    }

    part def TethysGroundSegment :> GroundSegment {
        doc /* The Meridian network and the mission's operations and data facilities. */
        part network : GroundNetwork;
    }

    part def VisitingVehicle {
        doc /* Lantern, the vehicle that visits the delivered target in the distant retrograde
             * orbit: external to the mission, present only through its docking interface. */
        attribute mass : MassValue;
        port docking : ~DockingPort;
    }

    part tethysSystem :> tethys {
        doc /* The Tethys Retrieval mission with its concrete segments, the target and the
             * visiting vehicle, and the interfaces between them. */
        part :>> flight : TethysFlightSegment;
        part :>> launch : TethysLaunchSegment;
        part :>> ground : TethysGroundSegment;
        part target : SmallBody;
        part visitor : VisitingVehicle;

        interface launchAdapter : SpacecraftLauncherInterface
            connect flight.tug.structure.launcherAttachment to launch.vehicle.payloadAdapter;
        interface deepSpaceLink : SpaceGroundLink
            connect flight.tug.telecom.deepSpace to ground.network.stations.uplinkDownlink;
        interface capture : CaptureInterface
            connect flight.tug.captureSystem.grapple to target.surface;
        interface visitorDocking : DockingInterface
            connect flight.tug.structure.docking to visitor.docking;
    }
}
