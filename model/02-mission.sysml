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
        doc /* The Tethys Retrieval mission: medium class, 2 200 days from launch to the
             * delivery of the target into its lunar distant retrograde orbit. */
        attribute :>> missionClass = MissionClass::medium;
        attribute :>> nominalDuration = 2200 [d];
        part flight : FlightSegment;
        part launch : LaunchSegment;
        part ground : GroundSegment;
    }

    attribute def TransferBook {
        doc /* The one Δv-by-phase and thrusting-time book of the mission. The budgets
             * (TethysBudgets), the transfer analyses (TethysAnalyses, TethysMonteCarlo, the
             * specific-impulse trade), the architecture variants (TethysVariants) and the tug's
             * own description read these values by reference, so an allocation changes here and
             * nowhere else.
             *
             * Derivation by the rocket equation at Isp 2 900 s (effective exhaust speed
             * c = Isp·g₀ = 28 439 m/s) from the budget's launch mass less the separated adapter,
             * 12 509 kg, with the 24 kg inspector released before the return:
             * outbound 2 800 m/s on the tug alone, 1 173 kg; rendezvous 150 m/s on the tug alone,
             * 60 kg; return 160 m/s on the 362 t nominal stack, 2 094 kg; insertion 40 m/s on
             * that stack, 522 kg. With the 10 % missed-thrust allowance on every arc that is
             * 4 233 kg for the nominal case, 3 087 kg for the 213 t small case and 5 341 kg for
             * the 506 t large case, against the 6 468 kg usable of the 6 600 kg loaded (2 %
             * residual): 21 % margin on the large case. The same chain returns at most about
             * 542 t with the 15 % margin policy and about 652 t with no margin
             * (TethysBudgets::propellantBudget.returnableBodyMass), so the 576 t densest body is
             * refused at commit. At the 1.69 N the array gives at the target's aphelion
             * the large case thrusts for about 1 040 days, within the 1 400 days the timeline
             * allows (TethysBudgets::propellantBudget evaluates every number above). */
        attribute deltaVOutbound : SpeedValue;
        attribute deltaVRendezvous : SpeedValue;
        attribute deltaVReturn : SpeedValue;
        attribute deltaVInsertion : SpeedValue;
        attribute deltaVRequiredReturn : SpeedValue;
        attribute missedThrustMargin : Real;
        attribute thrustingTimeAllowed : DurationValue;
    }
    attribute transferBook : TransferBook {
        doc /* The Phase B allocations of the Tethys Retrieval mission. */
        attribute :>> deltaVOutbound = 2800.0 ['m/s'] {
            doc /* Low-thrust Δv from the escape asymptote to the target's orbit: the Edelbaum
                 * estimate of about 0.7 km/s for 1 → 1.034 AU with the 0.030 eccentricity, the
                 * 0.6° plane change and phasing, with the low-thrust gravity losses and the
                 * launcher's v∞ disposal on top. */
        }
        attribute :>> deltaVRendezvous = 150.0 ['m/s'] {
            doc /* Approach, station-keeping and the capture manoeuvres. */
        }
        attribute :>> deltaVReturn = 160.0 ['m/s'] {
            doc /* Low-thrust Δv from the target's orbit to the lunar gravity assist: the
                 * allocation the xenon left after rendezvous can give the heaviest stack, which the
                 * return trajectory design must meet with the Earth-like orbit's small relative
                 * velocity and the gravity assist. */
        }
        attribute :>> deltaVInsertion = 40.0 ['m/s'] {
            doc /* From the gravity assist into the distant retrograde orbit. */
        }
        attribute :>> deltaVRequiredReturn = deltaVReturn + deltaVInsertion {
            doc /* What the xenon left on the stack must buy: the return and insertion arcs, 200 m/s. */
        }
        attribute :>> missedThrustMargin = 0.10 {
            doc /* Unplanned-coast allowance on every arc. */
        }
        attribute :>> thrustingTimeAllowed = 1400.0 [d] {
            doc /* Thrusting days the timeline gives the four arcs: the 2 200 day nominal duration
                 * less early operations, characterisation, capture and despin, insertion and
                 * checkout, and the coast margin the Monte Carlo dispersions size. */
        }
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
        doc /* The flight from integration and test through lift-off to disposal: the phases
             * every requirement, budget and mode in the model refers to, and the events that
             * bound them. The launcher injects
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
        event occurrence inspectorRetirement;
        event occurrence departureFromTarget;
        event occurrence lunarGravityAssist;
        event occurrence droInsertion;
        event occurrence visitingVehicleDocking;
        event occurrence tugSeparation;
        event occurrence tugDisposalBurn;

        occurrence integrationAndTest : MissionPhase;
        occurrence launchAndEarlyOperations : MissionPhase;
        occurrence sepCommissioning : MissionPhase;
        occurrence outboundCruise : MissionPhase;
        occurrence approachAndRendezvous : MissionPhase;
        occurrence characterisation : MissionPhase;
        occurrence capture : MissionPhase;
        occurrence returnCruise : MissionPhase;
        occurrence droInsertionAndCheckout : MissionPhase;
        occurrence utilisation : MissionPhase;
        occurrence extendedMission : MissionPhase;
        occurrence disposal : MissionPhase;

        first integrationAndTest then liftOff;
        first liftOff then launchAndEarlyOperations;
        first launchAndEarlyOperations then separationFromLauncher;
        first separationFromLauncher then arraysDeployed;
        first arraysDeployed then sepCommissioning;
        first sepCommissioning then outboundCruise;
        first outboundCruise then firstThrustArc;
        first firstThrustArc then approachAndRendezvous;
        first approachAndRendezvous then rendezvous;
        first rendezvous then characterisation;
        first characterisation then inspectorRelease;
        first inspectorRelease then captureCommit;
        first captureCommit then capture;
        first capture then captureComplete;
        first captureComplete then despinComplete;
        first despinComplete then inspectorRetirement;
        first inspectorRetirement then departureFromTarget;
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
