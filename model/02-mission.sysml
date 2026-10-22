// The mission as a whole: its segments, its programme lifecycle and its flight phases with the
// events that bound them. Segment internals live in their own packages.
package TethysMission {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysEnvironment::*;

    enum def MissionClass {
        doc /* Risk posture of the project, which sets the margin policy and redundancy level. */
        enum low;
        enum medium;
        enum high;
    }

    part def Mission {
        doc /* A deep-space mission: the flight, launch and ground segments that together achieve
             * the mission objectives, with the programmatic attributes a review gate reads. */
        attribute missionClass : MissionClass;
        attribute nominalDuration : DurationValue;
    }

    part def FlightSegment {
        doc /* Everything that leaves the ground: the tug and the inspector it carries. */
    }

    part def LaunchSegment {
        doc /* The launch vehicle, its adapter and the launch site and window. */
    }

    part def GroundSegment {
        doc /* The deep-space network, mission operations, flight dynamics and the science and
             * characterisation data system. */
    }

    part tethys : Mission {
        doc /* The Tethys Retrieval mission: medium class, 1 300 days from launch to the
             * delivery of the target into its lunar distant retrograde orbit. */
        attribute :>> missionClass = MissionClass::medium;
        attribute :>> nominalDuration = 2200 [d];
        part flight : FlightSegment;
        part launch : LaunchSegment;
        part ground : GroundSegment;
    }

    occurrence def ProjectPhase {
        doc /* A phase of the project lifecycle, closed by the review that ends it. */
        attribute closingReview : String;
    }

    occurrence def MissionPhase {
        doc /* A phase of the flight, bounded by the events it starts and ends with. */
    }

    occurrence projectLifecycle {
        doc /* The programmatic lifecycle: concept studies through closeout, in order. */
        occurrence preA : ProjectPhase { attribute :>> closingReview = "MCR"; }
        occurrence phaseA : ProjectPhase { attribute :>> closingReview = "SRR"; }
        occurrence phaseB : ProjectPhase { attribute :>> closingReview = "PDR"; }
        occurrence phaseC : ProjectPhase { attribute :>> closingReview = "CDR"; }
        occurrence phaseD : ProjectPhase { attribute :>> closingReview = "ORR"; }
        occurrence phaseE : ProjectPhase { attribute :>> closingReview = "DR"; }
        occurrence phaseF : ProjectPhase { attribute :>> closingReview = "closeout"; }
        first preA then phaseA;
        first phaseA then phaseB;
        first phaseB then phaseC;
        first phaseC then phaseD;
        first phaseD then phaseE;
        first phaseE then phaseF;
    }

    occurrence flightTimeline {
        doc /* The flight from lift-off to disposal: the phases every requirement, budget and
             * mode in the model refers to, and the events that bound them. The launcher injects
             * the stack directly onto an Earth-escape trajectory; the tug thrusts in arcs to the
             * target, station-keeps while Wren characterises it, captures and despins it, and
             * returns through a lunar gravity assist into the distant retrograde orbit. */
        event occurrence liftOff;
        event occurrence separationFromLauncher;
        event occurrence arraysDeployed;
        event occurrence firstThrustArc;
        event occurrence rendezvous;
        event occurrence inspectorRelease;
        event occurrence captureCommit;
        event occurrence captureComplete;
        event occurrence despinComplete;
        event occurrence departureFromTarget;
        event occurrence lunarGravityAssist;
        event occurrence droInsertion;
        event occurrence visitingVehicleDocking;
        event occurrence tugSeparation;
        event occurrence tugDisposalBurn;

        occurrence launchAndEarlyOperations : MissionPhase;
        occurrence outboundCruise : MissionPhase;
        occurrence approachAndRendezvous : MissionPhase;
        occurrence characterisation : MissionPhase;
        occurrence capture : MissionPhase;
        occurrence returnCruise : MissionPhase;
        occurrence droInsertionAndCheckout : MissionPhase;
        occurrence utilisation : MissionPhase;
        occurrence extendedMission : MissionPhase;
        occurrence disposal : MissionPhase;

        first liftOff then launchAndEarlyOperations;
        first launchAndEarlyOperations then separationFromLauncher;
        first separationFromLauncher then arraysDeployed;
        first arraysDeployed then outboundCruise;
        first outboundCruise then firstThrustArc;
        first firstThrustArc then approachAndRendezvous;
        first approachAndRendezvous then rendezvous;
        first rendezvous then characterisation;
        first characterisation then inspectorRelease;
        first inspectorRelease then captureCommit;
        first captureCommit then capture;
        first capture then captureComplete;
        first captureComplete then despinComplete;
        first despinComplete then departureFromTarget;
        first departureFromTarget then returnCruise;
        first returnCruise then lunarGravityAssist;
        first lunarGravityAssist then droInsertion;
        first droInsertion then droInsertionAndCheckout;
        first droInsertionAndCheckout then utilisation;
        first utilisation then visitingVehicleDocking;
        first visitingVehicleDocking then extendedMission;
        first extendedMission then tugSeparation;
        first tugSeparation then disposal;
        first disposal then tugDisposalBurn;
    }
}
