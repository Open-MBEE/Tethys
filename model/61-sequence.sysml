// WP-E — the mission sequence. The phase plan with entry and exit criteria, the dated event
// schedule, the mission as one executable action over TethysMission::flightTimeline (thrust
// arcs as loops, optical-navigation coasts, rendezvous, characterisation in parallel with
// station-keeping, the capture commit as a go/no-go decision over the target estimate, despin
// as a loop, return arcs, lunar assist, DRO insertion, docking, disposal), the critical
// sequences with their timing gates, and the campaigns the pinned runs execute for the small,
// nominal and large target cases.
package TethysSequence {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import BaseFunctions::ToString;
    private import TethysModes::TargetEstimate;
    private import TethysModes::CaptureEnvelope;
    private import TethysModes::smallTarget;
    private import TethysModes::nominalTarget;
    private import TethysModes::largeTarget;

    // ---- 1. Phases with entry and exit criteria -----------------------------------------
    attribute def PhaseCriteria {
        doc /* One phase of TethysMission::flightTimeline with the criterion that opens it,
             * the criterion that closes it, and its planned duration. */
        attribute phase : String;
        attribute entryCriterion : String;
        attribute exitCriterion : String;
        attribute plannedDuration : DurationValue;
    }
    part def PhasePlan {
        doc /* The ten phases of the flight timeline in order, with the sum of their planned
             * durations held inside the nominal mission duration. */
        attribute launchAndEarlyOperations : PhaseCriteria {
            :>> phase = "launchAndEarlyOperations";
            :>> entryCriterion = "lift-off (TethysMission::flightTimeline::liftOff)";
            :>> exitCriterion = "arrays deployed, sun-pointed, two-way link through Meridian";
            :>> plannedDuration = 3.0 [d];
        }
        attribute sepCommissioning : PhaseCriteria {
            :>> phase = "sepCommissioning (within outboundCruise)";
            :>> entryCriterion = "arrays deployed and high-voltage bus energised";
            :>> exitCriterion = "all four thrusters fired at full power, gimbal calibration done";
            :>> plannedDuration = 30.0 [d];
        }
        attribute outboundCruise : PhaseCriteria {
            :>> phase = "outboundCruise";
            :>> entryCriterion = "SEP commissioned, first thrust arc commanded";
            :>> exitCriterion = "far-field hold reached, target acquired by the narrow-angle camera";
            :>> plannedDuration = 380.0 [d];
        }
        attribute approachAndRendezvous : PhaseCriteria {
            :>> phase = "approachAndRendezvous";
            :>> entryCriterion = "optical-navigation solution converged on the target";
            :>> exitCriterion = "station-keeping inside the rendezvous range";
            :>> plannedDuration = 35.0 [d];
        }
        attribute characterisation : PhaseCriteria {
            :>> phase = "characterisation";
            :>> entryCriterion = "inspector checked out and released";
            :>> exitCriterion = "shape, spin state and mass estimate delivered; go/no-go decided";
            :>> plannedDuration = 15.0 [d];
        }
        attribute capture : PhaseCriteria {
            :>> phase = "capture";
            :>> entryCriterion = "capture commit (estimate inside the capture envelope)";
            :>> exitCriterion = "bag cinched, stack despun below the control threshold";
            :>> plannedDuration = 13.0 [d];
        }
        attribute returnCruise : PhaseCriteria {
            :>> phase = "returnCruise";
            :>> entryCriterion = "stack mass properties identified, return arc commanded";
            :>> exitCriterion = "lunar gravity assist executed";
            :>> plannedDuration = 1000.0 [d];
        }
        attribute droInsertionAndCheckout : PhaseCriteria {
            :>> phase = "droInsertionAndCheckout";
            :>> entryCriterion = "post-assist trajectory inside the insertion corridor";
            :>> exitCriterion = "DRO orbit determined, station-keeping cycle demonstrated";
            :>> plannedDuration = 60.0 [d];
        }
        attribute utilisation : PhaseCriteria {
            :>> phase = "utilisation";
            :>> entryCriterion = "DRO checkout complete, stack passive for docking";
            :>> exitCriterion = "visiting-vehicle campaign complete";
            :>> plannedDuration = 300.0 [d];
        }
        attribute disposal : PhaseCriteria {
            :>> phase = "disposal (after extendedMission)";
            :>> entryCriterion = "tug separated from the target";
            :>> exitCriterion = "disposal burn complete, heliocentric disposal orbit confirmed";
            :>> plannedDuration = 30.0 [d];
        }
        attribute phases : PhaseCriteria[10] = (launchAndEarlyOperations, sepCommissioning,
            outboundCruise, approachAndRendezvous, characterisation, capture, returnCruise,
            droInsertionAndCheckout, utilisation, disposal);
        attribute plannedTotal : DurationValue = launchAndEarlyOperations.plannedDuration
            + sepCommissioning.plannedDuration + outboundCruise.plannedDuration
            + approachAndRendezvous.plannedDuration + characterisation.plannedDuration
            + capture.plannedDuration + returnCruise.plannedDuration
            + droInsertionAndCheckout.plannedDuration + utilisation.plannedDuration
            + disposal.plannedDuration;
        attribute nominalDuration : DurationValue = 2200.0 [d];
        assert constraint fitsNominalDuration {
            doc /* The planned phases fit the nominal mission duration (TethysMission). */
            plannedTotal <= nominalDuration
        }
    }
    part nominalPhasePlan : PhasePlan {
        doc /* The phase plan as baselined. */
    }

    // ---- 2. Dated event schedule --------------------------------------------------------
    attribute def ScheduledEvent {
        doc /* An event of the flight timeline with its planned day after lift-off. */
        attribute eventName : String;
        attribute dayAfterLaunch : DurationValue;
    }
    part def EventSchedule {
        doc /* The planned dates of the flight-timeline events, in the order the timeline
             * gives them; the ordering is asserted so a re-dated schedule that crosses two
             * events fails the gate. */
        attribute liftOff : ScheduledEvent { :>> eventName = "liftOff"; :>> dayAfterLaunch = 0.0 [d]; }
        attribute separationFromLauncher : ScheduledEvent { :>> eventName = "separationFromLauncher"; :>> dayAfterLaunch = 0.05 [d]; }
        attribute arraysDeployed : ScheduledEvent { :>> eventName = "arraysDeployed"; :>> dayAfterLaunch = 0.1 [d]; }
        attribute firstThrustArc : ScheduledEvent { :>> eventName = "firstThrustArc"; :>> dayAfterLaunch = 33.0 [d]; }
        attribute rendezvous : ScheduledEvent { :>> eventName = "rendezvous"; :>> dayAfterLaunch = 448.0 [d]; }
        attribute inspectorRelease : ScheduledEvent { :>> eventName = "inspectorRelease"; :>> dayAfterLaunch = 450.0 [d]; }
        attribute captureCommit : ScheduledEvent { :>> eventName = "captureCommit"; :>> dayAfterLaunch = 463.0 [d]; }
        attribute captureComplete : ScheduledEvent { :>> eventName = "captureComplete"; :>> dayAfterLaunch = 466.0 [d]; }
        attribute despinComplete : ScheduledEvent { :>> eventName = "despinComplete"; :>> dayAfterLaunch = 476.0 [d]; }
        attribute departureFromTarget : ScheduledEvent { :>> eventName = "departureFromTarget"; :>> dayAfterLaunch = 480.0 [d]; }
        attribute lunarGravityAssist : ScheduledEvent { :>> eventName = "lunarGravityAssist"; :>> dayAfterLaunch = 1480.0 [d]; }
        attribute droInsertion : ScheduledEvent { :>> eventName = "droInsertion"; :>> dayAfterLaunch = 1500.0 [d]; }
        attribute visitingVehicleDocking : ScheduledEvent { :>> eventName = "visitingVehicleDocking"; :>> dayAfterLaunch = 1560.0 [d]; }
        attribute tugSeparation : ScheduledEvent { :>> eventName = "tugSeparation"; :>> dayAfterLaunch = 1860.0 [d]; }
        attribute tugDisposalBurn : ScheduledEvent { :>> eventName = "tugDisposalBurn"; :>> dayAfterLaunch = 1890.0 [d]; }
        attribute events : ScheduledEvent[15] = (liftOff, separationFromLauncher, arraysDeployed,
            firstThrustArc, rendezvous, inspectorRelease, captureCommit, captureComplete,
            despinComplete, departureFromTarget, lunarGravityAssist, droInsertion,
            visitingVehicleDocking, tugSeparation, tugDisposalBurn);
        assert constraint eventsInTimelineOrder {
            doc /* Each event is dated after the one the flight timeline puts before it. */
            liftOff.dayAfterLaunch < separationFromLauncher.dayAfterLaunch
                and separationFromLauncher.dayAfterLaunch < arraysDeployed.dayAfterLaunch
                and arraysDeployed.dayAfterLaunch < firstThrustArc.dayAfterLaunch
                and firstThrustArc.dayAfterLaunch < rendezvous.dayAfterLaunch
                and rendezvous.dayAfterLaunch < inspectorRelease.dayAfterLaunch
                and inspectorRelease.dayAfterLaunch < captureCommit.dayAfterLaunch
                and captureCommit.dayAfterLaunch < captureComplete.dayAfterLaunch
                and captureComplete.dayAfterLaunch < despinComplete.dayAfterLaunch
                and despinComplete.dayAfterLaunch < departureFromTarget.dayAfterLaunch
                and departureFromTarget.dayAfterLaunch < lunarGravityAssist.dayAfterLaunch
                and lunarGravityAssist.dayAfterLaunch < droInsertion.dayAfterLaunch
                and droInsertion.dayAfterLaunch < visitingVehicleDocking.dayAfterLaunch
                and visitingVehicleDocking.dayAfterLaunch < tugSeparation.dayAfterLaunch
                and tugSeparation.dayAfterLaunch < tugDisposalBurn.dayAfterLaunch
        }
        assert constraint disposalInsideNominalDuration {
            doc /* The last event falls inside the nominal 2 200-day mission. */
            tugDisposalBurn.dayAfterLaunch <= 2200.0 [d]
        }
    }
    part baselineSchedule : EventSchedule {
        doc /* The schedule as baselined; the executed MissionSequence below reproduces its
             * phase lengths. */
    }

    // ---- 3. Thrust arcs, despin and the critical sequences ------------------------------
    action def ThrustArc {
        doc /* One thrust arc: the SEP string thrusts for the arc's duration at the given
             * thrust and burns the xenon that duration implies; the result is the xenon left. */
        in arcDuration : DurationValue;
        in xenonPerArc : MassValue;
        in xenonBefore : MassValue;
        out xenonAfter : MassValue = xenonBefore - xenonPerArc;
    }

    action def DespinSequence {
        doc /* Despin the captured stack with the hydrazine thrusters: each pulse train
             * lengthens the spin period by a fixed factor until the period is above the
             * threshold at which the wheels take over. */
        in initialSpinPeriod : DurationValue;
        in wheelTakeoverPeriod : DurationValue;
        attribute spinPeriod : DurationValue = initialSpinPeriod;
        attribute pulseTrains : Natural = 0;
        first start;
        then while spinPeriod < wheelTakeoverPeriod {
            action pulseTrain {
                assign spinPeriod := spinPeriod * 1.6;
                then assign pulseTrains := pulseTrains + 1;
            }
        }
        then done;
    }

    action def InspectorReleaseSequence {
        doc /* The inspector release as a timed go/no-go sequence: checkout, umbilical
             * disconnect, a hold for the ground go, then release — each step gated by the
             * state the previous one must have reached. */
        in checkoutPassed : Boolean;
        in groundGo : Boolean;
        attribute umbilicalDisconnected : Boolean = false;
        out released : Boolean = false;
        out holdReason : String = "";
        first start;
        then decide checkoutGate;
            if checkoutPassed then disconnectUmbilical;
            else holdOnCheckout;
        action holdOnCheckout assign holdReason := "inspector checkout not passed";
        then done;
        action disconnectUmbilical assign umbilicalDisconnected := true;
        then action groundGoHold accept after 12.0 [h];
        then decide groundGate;
            if groundGo and umbilicalDisconnected then release;
            else holdOnGround;
        action holdOnGround assign holdReason := "no ground go within the release window";
        then done;
        action release assign released := true;
        then done;
    }

    action def DroInsertionSequence {
        doc /* The insertion into the distant retrograde orbit after the lunar assist: the
             * post-assist trajectory is checked against the insertion corridor, the
             * insertion arc is executed, and a miss leaves the stack in the backup
             * heliocentric loiter orbit rather than in cislunar space. The arc length is an
             * owned attribute, not a parameter: see docs/findings/WP-E.md F-E02. */
        in corridorError : LengthValue;
        in corridorHalfWidth : LengthValue;
        attribute insertionArcDuration : DurationValue = 20.0 [d];
        out inserted : Boolean = false;
        out outcome : String = "";
        first start;
        then decide corridorGate;
            if corridorError <= corridorHalfWidth then insertionArc;
            else backupLoiter;
        action insertionArc accept after insertionArcDuration;
        then action insertionDone assign inserted := true;
        then action insertionReport assign outcome := "inserted into the DRO";
        then done;
        action backupLoiter assign outcome := "corridor missed: backup heliocentric loiter, retry next synodic window";
        then done;
    }

    // ---- 4. The mission as one action ---------------------------------------------------
    action def MissionSequence {
        doc /* The flight from lift-off to disposal as an executable action over the phases
             * of TethysMission::flightTimeline. The clock runs in days; the thrust arcs are
             * loops counted against the arc plan; the capture commit is a decision over the
             * delivered target estimate and the capture envelope, and a refused commit ends
             * the mission in a retreat hold. */
        in target : TargetEstimate;
        in envelope : CaptureEnvelope;
        in outboundArcPlan : Natural;
        in returnArcPlan : Natural;
        attribute xenonRemaining : MassValue = 6600.0 [kg];
        attribute outboundArcs : Natural = 0;
        attribute returnArcs : Natural = 0;
        attribute inspectorReleased : Boolean = false;
        out captured : Boolean = false;
        out inserted : Boolean = false;
        out outcome : String = "";

        first start;
        then action launchAndEarlyOperations accept after 3.0 [d];
        then action sepCommissioning accept after 30.0 [d];
        then while outboundArcs < outboundArcPlan {
            action outboundArc {
                action thrustArc : ThrustArc {
                    in arcDuration = 120.0 [d];
                    in xenonPerArc = 215.0 [kg];
                    in xenonBefore = xenonRemaining;
                }
                then assign xenonRemaining := thrustArc.xenonAfter;
                then assign outboundArcs := outboundArcs + 1;
                then action opticalNavigationCoast accept after 10.0 [d];
            }
        }
        then action farFieldApproach accept after 25.0 [d];
        then action rendezvous accept after 10.0 [d];
        then action inspectorRelease : InspectorReleaseSequence {
            in checkoutPassed = true;
            in groundGo = true;
        }
        then assign inspectorReleased := inspectorRelease.released;
        then fork characterisationFork;
            then inspectorCharacterisation;
            then tugStationKeeping;
        action inspectorCharacterisation accept after 14.0 [d];
        then characterisationJoin;
        action tugStationKeeping accept after 14.0 [d];
        then characterisationJoin;
        join characterisationJoin;
        then decide captureCommit;
            if target.estimatedMass <= envelope.maximumBodyMass and target.estimatedDiameter <= envelope.maximumBodyDiameter then captureAndDespin;
            else retreatHold;
        action retreatHold assign outcome := "capture refused: target estimate outside the capture envelope";
        then done;
        action captureAndDespin {
            action capture accept after 3.0 [d];
            then assign captured := true;
            then action despin : DespinSequence {
                in initialSpinPeriod = 900.0 [s];
                in wheelTakeoverPeriod = 7200.0 [s];
            }
        }
        then while returnArcs < returnArcPlan {
            action returnArc {
                action thrustArc : ThrustArc {
                    in arcDuration = 250.0 [d];
                    in xenonPerArc = 1250.0 [kg];
                    in xenonBefore = xenonRemaining;
                }
                then assign xenonRemaining := thrustArc.xenonAfter;
                then assign returnArcs := returnArcs + 1;
            }
        }
        then action lunarGravityAssist accept after 20.0 [d];
        then action droInsertion : DroInsertionSequence {
            in corridorError = 1200.0 [km];
            in corridorHalfWidth = 5000.0 [km];
        }
        then assign inserted := droInsertion.inserted;
        then action droCheckout accept after 60.0 [d];
        then action visitingVehicleDocking accept after 1.0 [d];
        then action utilisation accept after 300.0 [d];
        then action tugSeparation accept after 1.0 [d];
        then action disposalBurn accept after 30.0 [d];
        then assign outcome := "disposed after " + ToString(outboundArcs + returnArcs) + " thrust arcs";
        then done;
    }

    // ---- 5. Campaigns the runs execute ---------------------------------------------------
    part def FlightCampaign {
        doc /* One flight of the mission sequence against a target estimate and an arc plan. */
        attribute target : TargetEstimate;
        attribute envelope : CaptureEnvelope {
            :>> maximumBodyMass = 1000.0e3 [kg];
            :>> maximumBodyDiameter = 10.0 [m];
        }
        attribute outboundArcPlan : Natural default 3;
        attribute returnArcPlan : Natural default 4;
        perform action mission : MissionSequence {
            in target = FlightCampaign::target;
            in envelope = FlightCampaign::envelope;
            in outboundArcPlan = FlightCampaign::outboundArcPlan;
            in returnArcPlan = FlightCampaign::returnArcPlan;
        }
    }
    part smallTargetCampaign : FlightCampaign {
        doc /* Small target: capture accepted; the return needs fewer arcs. */
        attribute :>> target = smallTarget;
        attribute :>> returnArcPlan = 3;
    }
    part nominalCampaign : FlightCampaign {
        doc /* Nominal target: the baseline flight. */
        attribute :>> target = nominalTarget;
    }
    part largeTargetCampaign : FlightCampaign {
        doc /* Large target: the commit is refused and the flight ends in the retreat hold. */
        attribute :>> target = largeTarget;
    }
}
