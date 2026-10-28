// WP-E — fault detection, isolation and recovery. The fault taxonomy and the monitor limits,
// the monitors as constraints, the FDIR supervisor as a parallel state machine (command-loss
// timer, thruster and PPU fault recovery, power and attitude monitors, the Earth-impact
// exclusion monitor that aborts the return), the hazardous-function inhibit chain, and the
// fault-injection scenarios the pinned runs execute against the mode machine of TethysModes.
package TethysFdir {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysModes::*;

    // ---- 1. Fault taxonomy and limits ---------------------------------------------------
    enum def FdirLevel {
        doc /* Where a fault is detected and handled: inside a unit, by the subsystem
             * controller, or by the system-level supervisor (which alone may call safe mode). */
        unit; subsystem; system;
    }
    enum def FaultResponse {
        doc /* The responses the supervisor can take. */
        retry; switchover; loadShed; safeMode; abortReturn;
    }
    item def FaultEvent :> OnBoardEvent {
        doc /* A detected fault, raised by a monitor with the level it was detected at. */
        attribute level : FdirLevel;
    }
    item def ThrusterFlameout :> FaultEvent {
        doc /* A thruster's discharge has extinguished (domain failure modes F1, F3). */
        attribute thrusterId : Natural;
    }
    item def PpuTrip :> FaultEvent {
        doc /* A power processing unit has tripped on over-current (F2, F7). */
        attribute ppuId : Natural;
    }
    item def AttitudeLoss :> FaultEvent {
        doc /* Attitude knowledge lost or rates above the control authority (F24). */
    }
    item def BatteryLow :> FaultEvent {
        doc /* Battery state of charge below the load-shed threshold (F25). */
        attribute stateOfCharge : Real;
    }
    item def ProcessorReset :> FaultEvent {
        doc /* The flight computer has rebooted (F27); the supervisor restarts its timers. */
    }
    item def GroundContact :> OnBoardEvent {
        doc /* Any valid telecommand received: the command-loss timer is re-armed. */
    }
    item def TrajectoryUpdate :> OnBoardEvent {
        doc /* A return-trajectory solution from navigation: the predicted Earth closest
             * approach and the impact probability over the knowledge uncertainty. */
        attribute earthClosestApproach : LengthValue;
        attribute impactProbability : Real;
    }

    attribute def MonitorLimits {
        doc /* The thresholds the supervisor's monitors compare against. */
        attribute commandLossTimeout : DurationValue;
        attribute thrusterRestartDelay : DurationValue;
        attribute maximumFlameoutRetries : Natural;
        attribute batteryLowFraction : Real;
        attribute earthExclusionRadius : LengthValue;
        attribute maximumImpactProbability : Real;
    }
    attribute cruiseLimits : MonitorLimits {
        doc /* Cruise limits: seven days without contact (one missed weekly pass plus margin)
             * calls safe mode; two restarts before a switchover to the spare thruster; the
             * exclusion radius is ten Earth radii — the stack must never be targeted inside it. */
        :>> commandLossTimeout = 7.0 [d];
        :>> thrusterRestartDelay = 2.0 [h];
        :>> maximumFlameoutRetries = 2;
        :>> batteryLowFraction = 0.30;
        :>> earthExclusionRadius = 63781.37 [km];
        :>> maximumImpactProbability = 1.0e-4;
    }

    // ---- 2. Monitors as constraints -----------------------------------------------------
    constraint def EarthImpactExcluded {
        doc /* The return trajectory keeps the stack outside the exclusion sphere with an impact
             * probability under the limit (TethysRequirements TR-006). */
        in earthClosestApproach : LengthValue;
        in impactProbability : Real;
        in limits : MonitorLimits;
        earthClosestApproach > limits.earthExclusionRadius
            and impactProbability <= limits.maximumImpactProbability
    }
    constraint def BatteryHealthy {
        doc /* State of charge above the load-shed fraction. */
        in stateOfCharge : Real;
        in limits : MonitorLimits;
        stateOfCharge >= limits.batteryLowFraction
    }
    constraint def ThrusterStringAvailable {
        doc /* Enough thrusters remain for the operating set (TethysTug: four fitted, three
             * operating). */
        in healthyThrusters : Natural;
        in operatingThrusters : Natural;
        healthyThrusters >= operatingThrusters
    }

    // ---- 3. The FDIR supervisor ---------------------------------------------------------
    state def FdirSupervisor parallel {
        doc /* The system-level supervisor. Each region is one monitor with its own
             * detection, isolation and recovery; a region that exhausts its recovery raises
             * SafeModeRequest, and the trajectory monitor raises AbortReturn. Faults and
             * commands arrive on `command` (the exhibiting tug's port of the same name); the
             * supervisor's own requests are sent to the tug itself, where the mode machine
             * (TethysModes::TugModes) exhibited beside it takes them. */
        port command : CommandPort;
        attribute limits : MonitorLimits default = cruiseLimits;
        attribute healthyThrusters : Natural = 4;
        attribute operatingThrusters : Natural = 3;
        attribute flameoutRetries : Natural = 0;
        attribute ppuTrips : Natural = 0;
        attribute safeModeRequests : Natural = 0;
        attribute lastEarthClosestApproach : LengthValue = 400000.0 [km];
        attribute lastImpactProbability : Real = 0.0;

        state commandLossTimer {
            doc /* Re-armed by every ground contact (the telecom subsystem reports one per
                 * pass); on expiry the supervisor calls safe mode (sun-pointed, low-gain
                 * omni), where the ground can reach the tug again. */
            entry; then armed;
            state armed;
            state expired {
                entry action callSafe {
                    assign safeModeRequests := safeModeRequests + 1;
                    then send new SafeModeRequest(reason = "command-loss timer expired");
                }
            }
            transition first armed accept GroundContact via command then armed;
            transition first armed accept ProcessorReset via command then armed;
            transition first armed accept after limits.commandLossTimeout then expired;
            transition first expired accept GroundContact via command then armed;
        }

        state thrusterHealth {
            doc /* Flameout recovery: restart the thruster up to the retry limit, then switch
                 * to the spare; with the spare used and another string lost, the operating set
                 * cannot be met and the supervisor calls safe mode. */
            entry; then nominal;
            state nominal;
            state restarting;
            state onSpare;
            state stringLost {
                entry action callSafe {
                    assign safeModeRequests := safeModeRequests + 1;
                    then send new SafeModeRequest(reason = "thruster string lost: operating set not available");
                }
            }
            transition first nominal accept f : ThrusterFlameout via command if flameoutRetries < limits.maximumFlameoutRetries
                do assign flameoutRetries := flameoutRetries + 1 then restarting;
            transition first restarting accept after limits.thrusterRestartDelay then nominal;
            transition first nominal accept f : ThrusterFlameout via command if flameoutRetries >= limits.maximumFlameoutRetries
                do assign healthyThrusters := healthyThrusters - 1 then onSpare;
            transition first onSpare accept f : ThrusterFlameout via command
                do assign healthyThrusters := healthyThrusters - 1 then stringLost;
        }

        state ppuHealth {
            doc /* PPU trip recovery: cross-strap the thruster to the redundant PPU on the
                 * first trip; a second trip leaves the string on the remaining PPU and calls
                 * safe mode for the ground to replan the thrust profile. */
            entry; then nominal;
            state nominal;
            state crossStrapped;
            state ppuLost {
                entry action callSafe {
                    assign safeModeRequests := safeModeRequests + 1;
                    then send new SafeModeRequest(reason = "second PPU trip: thrust profile replan needed");
                }
            }
            transition first nominal accept PpuTrip via command do assign ppuTrips := ppuTrips + 1 then crossStrapped;
            transition first crossStrapped accept PpuTrip via command do assign ppuTrips := ppuTrips + 1 then ppuLost;
        }

        state powerHealth {
            doc /* Battery monitor: below the load-shed fraction the supervisor sheds loads
                 * through safe mode; the ground clears it with SafeModeExit. */
            entry; then nominal;
            state nominal;
            state loadShed {
                entry action callSafe {
                    assign safeModeRequests := safeModeRequests + 1;
                    then send new SafeModeRequest(reason = "battery state of charge below load-shed fraction");
                }
            }
            transition first nominal accept b : BatteryLow via command if b.stateOfCharge < limits.batteryLowFraction then loadShed;
            transition first loadShed accept SafeModeExit via command then nominal;
        }

        state attitudeHealth {
            doc /* Attitude monitor: loss of attitude knowledge or control goes straight to
                 * safe mode's sun acquisition on thrusters. */
            entry; then nominal;
            state nominal;
            state sunAcquisition {
                entry action callSafe {
                    assign safeModeRequests := safeModeRequests + 1;
                    then send new SafeModeRequest(reason = "attitude loss");
                }
            }
            transition first nominal accept AttitudeLoss via command then sunAcquisition;
            transition first sunAcquisition accept SafeModeExit via command then nominal;
        }

        state earthImpactExclusion {
            doc /* The Earth-impact exclusion monitor: every trajectory update is checked
                 * against the exclusion sphere and the impact-probability limit; a violation
                 * aborts the return (AbortReturn → TugModes abortHold, thrust inhibited). */
            entry; then monitoring;
            state monitoring;
            state aborted {
                entry send new AbortReturn(reason = "Earth-impact exclusion violated");
            }
            transition first monitoring accept t : TrajectoryUpdate via command
                if t.earthClosestApproach > limits.earthExclusionRadius and t.impactProbability <= limits.maximumImpactProbability
                do action record { assign lastEarthClosestApproach := t.earthClosestApproach; then assign lastImpactProbability := t.impactProbability; }
                then monitoring;
            transition first monitoring accept t : TrajectoryUpdate via command
                if t.earthClosestApproach <= limits.earthExclusionRadius or t.impactProbability > limits.maximumImpactProbability
                do action record { assign lastEarthClosestApproach := t.earthClosestApproach; then assign lastImpactProbability := t.impactProbability; }
                then aborted;
            transition first aborted accept SafeModeExit via command then monitoring;
        }
    }

    // ---- 4. Hazardous-function inhibits -------------------------------------------------
    action def ArmAndFireCaptureCinch {
        doc /* The capture-bag cinch actuator is a hazardous function: it fires only with
             * three independent inhibits removed — the arm command, the ground enable, and the
             * vehicle in capture mode. Any missing inhibit holds the actuator and reports it. */
        in armCommanded : Boolean;
        in groundEnable : Boolean;
        in inCaptureMode : Boolean;
        out fired : Boolean = false;
        out holdReason : String = "";
        first start;
        then decide inhibitGate;
            if armCommanded and groundEnable and inCaptureMode then fire;
            else hold;
        action fire assign fired := true;
        then done;
        action hold assign holdReason := "cinch inhibited: an inhibit is still in place";
        then done;
    }
    constraint def NoFireWithoutInhibitsRemoved {
        doc /* Firing implies all three inhibits were removed (SE-163). */
        in fired : Boolean;
        in armCommanded : Boolean;
        in groundEnable : Boolean;
        in inCaptureMode : Boolean;
        fired implies (armCommanded and groundEnable and inCaptureMode)
    }
    part def InhibitChain {
        doc /* The cinch inhibit chain as an object the checker runs with every input free. */
        attribute armCommanded : Boolean default true;
        attribute groundEnable : Boolean default true;
        attribute inCaptureMode : Boolean default true;
        perform action cinch : ArmAndFireCaptureCinch {
            in armCommanded = InhibitChain::armCommanded;
            in groundEnable = InhibitChain::groundEnable;
            in inCaptureMode = InhibitChain::inCaptureMode;
        }
        assert constraint noFireWithoutInhibitsRemoved : NoFireWithoutInhibitsRemoved {
            in fired = cinch.fired;
            in armCommanded = InhibitChain::armCommanded;
            in groundEnable = InhibitChain::groundEnable;
            in inCaptureMode = InhibitChain::inCaptureMode;
        }
    }
    part armedChain : InhibitChain {
        doc /* All inhibits removed: the actuator fires. */
    }
    part inhibitedChain : InhibitChain {
        doc /* Ground enable missing: the actuator holds. */
        attribute :>> groundEnable = false;
    }

    // ---- 5. Fault-injection scenarios ---------------------------------------------------
    part def FdirTug :> ModedTug {
        doc /* The tug with its FDIR supervisor beside the mode machine. */
        exhibit state fdir : FdirSupervisor;
        bind fdir.command = command;
    }
    part def FaultInjector {
        doc /* A test conductor injecting faults and events into the tug's command port. */
        port uplink : ~CommandPort;
    }
    part def CommandLossInjector :> FaultInjector {
        doc /* Brings the tug to coast, keeps contact with passes on days 5 and 10, then falls
             * silent: the timer expires on day 17, the tug safes, and a contact on day 23
             * followed by SafeModeExit on day 24 recovers it to coast. */
        perform action campaign {
            first start;
            then action toSeparation accept after 0.05 [d];
            then action separation send new SeparationConfirmed() via uplink;
            then action toDeployment accept after 0.05 [d];
            then action deployment send new ArraysDeployed() via uplink;
            then action toPass1 accept after 4.9 [d];
            then action pass1 send new GroundContact() via uplink;
            then action toPass2 accept after 5.0 [d];
            then action pass2 send new GroundContact() via uplink;
            then action silence accept after 13.0 [d];
            then action pass3 send new GroundContact() via uplink;
            then action recoveryHold accept after 1.0 [d];
            then action recover send new SafeModeExit() via uplink;
            then done;
        }
    }
    part def ThrusterFaultInjector :> FaultInjector {
        doc /* During the first thrust arc: two flameouts are restarted, the third switches
             * to the spare, the fourth loses the string and safes the tug. */
        perform action campaign {
            first start;
            then action toSeparation accept after 0.05 [d];
            then action separation send new SeparationConfirmed() via uplink;
            then action toDeployment accept after 0.05 [d];
            then action deployment send new ArraysDeployed() via uplink;
            then action commissioning accept after 5.0 [d];
            then action pass0 send new GroundContact() via uplink;
            then action arc send new ThrustArcGo(plannedDuration = 200.0 [d]) via uplink;
            then action run1 accept after 5.0 [d];
            then action pass1 send new GroundContact() via uplink;
            then action flameout1 send new ThrusterFlameout(level = FdirLevel::subsystem, thrusterId = 2) via uplink;
            then action run2 accept after 5.0 [d];
            then action pass2 send new GroundContact() via uplink;
            then action flameout2 send new ThrusterFlameout(level = FdirLevel::subsystem, thrusterId = 2) via uplink;
            then action run3 accept after 5.0 [d];
            then action pass3 send new GroundContact() via uplink;
            then action flameout3 send new ThrusterFlameout(level = FdirLevel::subsystem, thrusterId = 2) via uplink;
            then action run4 accept after 5.0 [d];
            then action pass4 send new GroundContact() via uplink;
            then action ppuTrip send new PpuTrip(level = FdirLevel::subsystem, ppuId = 1) via uplink;
            then action run5 accept after 5.0 [d];
            then action pass5 send new GroundContact() via uplink;
            then action flameout4 send new ThrusterFlameout(level = FdirLevel::system, thrusterId = 3) via uplink;
            then action safeHold accept after 2.0 [d];
            then done;
        }
    }
    part def EarthImpactInjector :> FaultInjector {
        doc /* A stacked return on a compressed clock (a ground pass every five days): the
             * capture is completed by injected events, the return arc starts, a nominal
             * trajectory update is accepted, then a solution inside the exclusion sphere
             * aborts the return. */
        perform action campaign {
            first start;
            then action toSeparation accept after 0.05 [d];
            then action separation send new SeparationConfirmed() via uplink;
            then action toDeployment accept after 0.05 [d];
            then action deployment send new ArraysDeployed() via uplink;
            then action cruise accept after 5.0 [d];
            then action pass0 send new GroundContact() via uplink;
            then action approachGo send new ProximityOperationsGo() via uplink;
            then action approachRun accept after 5.0 [d];
            then action pass1 send new GroundContact() via uplink;
            then action rendezvous send new RangeUpdate(range = 20.0 [km]) via uplink;
            then action captureCommit send new CaptureGo(estimatedMass = 362.0e3 [kg], estimatedDiameter = 6.8 [m]) via uplink;
            then action captureRun accept after 3.0 [d];
            then action pass2 send new GroundContact() via uplink;
            then action captureDone send new CaptureComplete() via uplink;
            then action despinRun accept after 5.0 [d];
            then action pass3 send new GroundContact() via uplink;
            then action despinDone send new DespinComplete() via uplink;
            then action returnArc send new ReturnThrustGo(plannedDuration = 400.0 [d]) via uplink;
            then action run1 accept after 5.0 [d];
            then action pass4 send new GroundContact() via uplink;
            then action nominalSolution send new TrajectoryUpdate(earthClosestApproach = 384400.0 [km], impactProbability = 1.0e-7) via uplink;
            then action run2 accept after 5.0 [d];
            then action pass5 send new GroundContact() via uplink;
            then action violatingSolution send new TrajectoryUpdate(earthClosestApproach = 12000.0 [km], impactProbability = 2.0e-3) via uplink;
            then action abortHold accept after 2.0 [d];
            then done;
        }
    }
    part def FaultScenario {
        doc /* One tug under one fault injector. */
        part tug : FdirTug;
        part injector : FaultInjector;
        interface link : CommandLink connect injector.uplink to tug.command;
    }
    part commandLossScenario : FaultScenario {
        doc /* Command-loss timer expiry and recovery. */
        part :>> injector : CommandLossInjector;
    }
    part thrusterFaultScenario : FaultScenario {
        doc /* Thruster flameouts and a PPU trip during the first arc. */
        part :>> injector : ThrusterFaultInjector;
    }
    part earthImpactScenario : FaultScenario {
        doc /* Earth-impact exclusion abort on the return. */
        part :>> injector : EarthImpactInjector;
    }
}
