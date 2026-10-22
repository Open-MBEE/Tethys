// The trade studies behind the baseline: array power against trip time, specific impulse
// against thrust, direct escape against a spiral-out, the destination orbit and the capture
// mechanism. Each is a TradeStudies::TradeStudy whose evaluation function scores the
// alternatives from the analyses in TethysAnalyses; the selection each returns is the choice
// the baseline in TethysTug and TethysEnvironment carries, and the rationale says why.
package TethysTrades {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TradeStudies::*;
    private import ModelingMetadata::*;
    private import TethysEnvironment::*;
    private import TethysTug::*;
    private import TethysAnalyses::*;
    private import TethysTarget::targetCases;
    private import TethysMission::transferBook;

    // ---- T3: array power against trip time ---------------------------------------------------

    part def ArrayOption {
        doc /* A solar-array sizing option: the power it delivers at 1 AU at beginning of life,
             * the mass of both wings with their deployment mechanisms, and its cost in the
             * project's cost unit. */
        attribute powerAtOneAu : PowerValue;
        attribute wingMass : MassValue;
        attribute costUnits : Real;
    }
    part array30kW : ArrayOption {
        doc /* Two conventional rigid wings. */
        attribute :>> powerAtOneAu = 30.0 [kW];
        attribute :>> wingMass = 300.0 [kg];
        attribute :>> costUnits = 60.0;
    }
    part array48kW : ArrayOption {
        doc /* Two roll-out wings, the baseline. */
        attribute :>> powerAtOneAu = 48.0 [kW];
        attribute :>> wingMass = 480.0 [kg];
        attribute :>> costUnits = 90.0;
    }
    part array70kW : ArrayOption {
        doc /* Two roll-out wings at the largest size the fairing stows. */
        attribute :>> powerAtOneAu = 70.0 [kW];
        attribute :>> wingMass = 700.0 [kg];
        attribute :>> costUnits = 150.0;
    }

    calc def PowerAvailableToSep {
        doc /* Electric power the propulsion system can draw at the far end of the heliocentric
             * range: the array's 1 AU power scaled by the solar flux ratio at the target's
             * aphelion, less the housekeeping load. */
        in powerAtOneAuW : Real;
        in housekeepingW : Real;
        return sepPowerW : Real =
            powerAtOneAuW * SolarFlux(amaranth.orbit.aphelionAu) / SolarFlux(1.0) - housekeepingW;
    }

    analysis def ArrayPowerTrade :> TradeStudy {
        doc /* Trip time against array mass and cost: each option is scored by the days of
             * thrusting the mission's xenon takes at the power that option gives the thrusters at
             * aphelion, plus a penalty in days per kilogram of wing and per cost unit; the least
             * score wins. */
        subject :>> studyAlternatives : ArrayOption[1..*];
        in attribute xenonToProcessKg : Real default = 6300.0;
        in attribute housekeepingW : Real default = 2000.0;
        in attribute massPenaltyDaysPerKg : Real default = 0.5;
        in attribute costPenaltyDaysPerUnit : Real default = 5.0;
        objective :>> tradeStudyObjective : MinimizeObjective {
            doc /* The alternative with the least evaluation is selected. */
        }
        calc :>> evaluationFunction {
            in part option :>> alternative : ArrayOption;
            attribute sepPowerW : Real = PowerAvailableToSep(option.powerAtOneAu / 1 [W], housekeepingW);
            attribute thrustN : Real = SepThrust(sepPowerW, argent.sep.specificImpulse / 1 [s], 0.65);
            attribute thrustDays : Real = ThrustDays(xenonToProcessKg, MassFlowRate(thrustN, argent.sep.specificImpulse / 1 [s]));
            return :>> result : Real = thrustDays
                + massPenaltyDaysPerKg * (option.wingMass / 1 [kg]) + costPenaltyDaysPerUnit * option.costUnits;
        }
        return part :>> selectedAlternative : ArrayOption;
    }
    analysis arrayPowerTrade : ArrayPowerTrade {
        subject :>> studyAlternatives = (array30kW, array48kW, array70kW);
    }
    metadata Rationale about arrayPowerTrade {
        text = "48 kW selected: 30 kW cannot process the xenon inside the thrust-arc allowance, and 70 kW buys about 370 fewer days at a mass and cost the trade does not repay; argent.eps.arrayPowerAtOneAu carries the selection.";
    }

    // ---- T4: specific impulse against thrust -------------------------------------------------

    part def ThrusterOption {
        doc /* A Hall-thruster operating point: specific impulse and total efficiency at the
             * propulsion system's maximum power. */
        attribute specificImpulse : DurationValue;
        attribute efficiency : Real;
    }
    part isp2000 : ThrusterOption { attribute :>> specificImpulse = 2000.0 [s]; attribute :>> efficiency = 0.60; }
    part isp2900 : ThrusterOption { attribute :>> specificImpulse = 2900.0 [s]; attribute :>> efficiency = 0.65; }
    part isp3500 : ThrusterOption { attribute :>> specificImpulse = 3500.0 [s]; attribute :>> efficiency = 0.68; }

    analysis def SpecificImpulseTrade :> TradeStudy {
        doc /* Xenon against thrusting time: each operating point is scored by the days needed to
             * spend the xenon the outbound Δv on the tug and the return Δv on the nominal stack
             * cost at that Isp, plus a penalty per kilogram of xenon; an option whose xenon
             * exceeds the tank is penalised out. The least score wins. */
        subject :>> studyAlternatives : ThrusterOption[1..*];
        in attribute outboundDeltaVMPerS : Real default = (transferBook.deltaVOutbound + transferBook.deltaVRendezvous) / 1 ['m/s'] {
            doc /* Outbound and rendezvous arcs of the transfer book (TethysMission::transferBook). */
        }
        in attribute returnDeltaVMPerS : Real default = transferBook.deltaVRequiredReturn / 1 ['m/s'] {
            doc /* Return and insertion arcs of the transfer book. */
        }
        in attribute xenonPenaltyDaysPerKg : Real default = 0.1;
        in attribute tankOverflowPenaltyDays : Real default = 10000.0;
        objective :>> tradeStudyObjective : MinimizeObjective {
            doc /* The alternative with the least evaluation is selected. */
        }
        calc :>> evaluationFunction {
            in part option :>> alternative : ThrusterOption;
            attribute ispS : Real = option.specificImpulse / 1 [s];
            attribute outboundXenonKg : Real = PropellantForDeltaV(outboundDeltaVMPerS, argent.wetMass / 1 [kg], ispS);
            attribute stackKg : Real = argent.wetMass / 1 [kg] - outboundXenonKg + targetCases.nominal.mass / 1 [kg];
            attribute returnXenonKg : Real = PropellantForDeltaV(returnDeltaVMPerS, stackKg, ispS);
            attribute xenonKg : Real = outboundXenonKg + returnXenonKg;
            attribute thrustN : Real = SepThrust(argent.sep.maximumPower / 1 [W], ispS, option.efficiency);
            attribute thrustDays : Real = ThrustDays(xenonKg, MassFlowRate(thrustN, ispS));
            attribute overflow : Real = if xenonKg > argent.sep.xenonMass / 1 [kg] ? tankOverflowPenaltyDays else 0.0;
            return :>> result : Real = thrustDays + xenonPenaltyDaysPerKg * xenonKg + overflow;
        }
        return part :>> selectedAlternative : ThrusterOption;
    }
    analysis specificImpulseTrade : SpecificImpulseTrade {
        subject :>> studyAlternatives = (isp2000, isp2900, isp3500);
    }
    metadata Rationale about specificImpulseTrade {
        text = "2 900 s selected: 2 000 s needs more xenon than the tank holds, 3 500 s saves 900 kg of xenon but adds 150 days of thrusting; argent.sep.specificImpulse carries the selection.";
    }

    // ---- T2: direct escape against spiral-out ------------------------------------------------

    part def DepartureOption {
        doc /* How the stack leaves the Earth: the launcher's injection energy, the days the tug
             * spends spiralling through the radiation belts, and the launch cost. */
        attribute injectionC3Km2PerS2 : Real;
        attribute beltTransitDays : Real;
        attribute launchCostUnits : Real;
    }
    part directEscape : DepartureOption {
        doc /* Arcturus-5H injects the full stack to C3 ≈ 2 km²/s²; the belts are crossed in hours. */
        attribute :>> injectionC3Km2PerS2 = 2.0;
        attribute :>> beltTransitDays = 0.5;
        attribute :>> launchCostUnits = 180.0;
    }
    part spiralOut : DepartureOption {
        doc /* A medium launcher to a 400 km orbit and a solar-electric spiral to escape: about
             * 240 days of thrusting, 150 of them inside the belts. */
        attribute :>> injectionC3Km2PerS2 = -60.0;
        attribute :>> beltTransitDays = 150.0;
        attribute :>> launchCostUnits = 90.0;
    }

    analysis def DepartureTrade :> TradeStudy {
        doc /* Launch cost against trip time and array damage: the score is the launch cost plus a
             * penalty per day in the belts (array degradation and the schedule it costs); the
             * least score wins. */
        subject :>> studyAlternatives : DepartureOption[1..*];
        in attribute beltDayPenaltyUnits : Real default = 1.0;
        objective :>> tradeStudyObjective : MinimizeObjective {
            doc /* The alternative with the least evaluation is selected. */
        }
        calc :>> evaluationFunction {
            in part option :>> alternative : DepartureOption;
            return :>> result : Real = option.launchCostUnits + beltDayPenaltyUnits * option.beltTransitDays;
        }
        return part :>> selectedAlternative : DepartureOption;
    }
    analysis departureTrade : DepartureTrade { subject :>> studyAlternatives = (directEscape, spiralOut); }
    metadata Rationale about departureTrade {
        text = "Direct escape selected once a belt day is weighed at more than 0.6 cost units; TethysLaunch carries the heavy launcher and TR-004 the direct injection.";
    }

    // ---- T8: destination orbit ---------------------------------------------------------------

    part def DestinationOrbitOption {
        doc /* A cislunar orbit the target could be parked in, scored on the criteria TR-006 and
             * TR-009 care about. */
        attribute stationKeepingDeltaVPerYear : SpeedValue;
        attribute insertionDeltaV : SpeedValue;
        attribute visitorAccessDeltaV : SpeedValue;
        attribute longestEclipse : DurationValue;
        attribute unattendedStabilityYears : Real;
    }
    part distantRetrograde : DestinationOrbitOption {
        doc /* The 70 000 km DRO of TethysEnvironment::destinationDro. */
        attribute :>> stationKeepingDeltaVPerYear = 0.0 ['m/s'];
        attribute :>> insertionDeltaV = 40.0 ['m/s'];
        attribute :>> visitorAccessDeltaV = 1100.0 ['m/s'];
        attribute :>> longestEclipse = 4.0 [h];
        attribute :>> unattendedStabilityYears = 100.0;
    }
    part nearRectilinearHalo : DestinationOrbitOption {
        doc /* A southern near-rectilinear halo orbit about the second libration point. */
        attribute :>> stationKeepingDeltaVPerYear = 10.0 ['m/s'];
        attribute :>> insertionDeltaV = 60.0 ['m/s'];
        attribute :>> visitorAccessDeltaV = 900.0 ['m/s'];
        attribute :>> longestEclipse = 1.0 [h];
        attribute :>> unattendedStabilityYears = 0.5;
    }
    part librationHalo : DestinationOrbitOption {
        doc /* A large halo orbit about the second libration point. */
        attribute :>> stationKeepingDeltaVPerYear = 30.0 ['m/s'];
        attribute :>> insertionDeltaV = 30.0 ['m/s'];
        attribute :>> visitorAccessDeltaV = 850.0 ['m/s'];
        attribute :>> longestEclipse = 2.0 [h];
        attribute :>> unattendedStabilityYears = 0.2;
    }
    part highEarthOrbit : DestinationOrbitOption {
        doc /* A 100 000 km circular Earth orbit, perturbed by the Moon. */
        attribute :>> stationKeepingDeltaVPerYear = 5.0 ['m/s'];
        attribute :>> insertionDeltaV = 350.0 ['m/s'];
        attribute :>> visitorAccessDeltaV = 600.0 ['m/s'];
        attribute :>> longestEclipse = 6.0 [h];
        attribute :>> unattendedStabilityYears = 20.0;
    }

    analysis def DestinationOrbitTrade :> TradeStudy {
        doc /* Weighted multi-criteria score: station-keeping, insertion and visitor-access Δv and
             * the longest eclipse count against an option, unattended stability for it, each
             * criterion with its weight; the highest score wins. */
        subject :>> studyAlternatives : DestinationOrbitOption[1..*];
        in attribute stationKeepingWeight : Real default = 10.0;
        in attribute insertionWeight : Real default = 1.0;
        in attribute accessWeight : Real default = 0.2;
        in attribute eclipseWeightPerHour : Real default = 10.0;
        in attribute stabilityWeightPerYear : Real default = 5.0;
        objective :>> tradeStudyObjective : MaximizeObjective {
            doc /* The alternative with the highest evaluation is selected. */
        }
        calc :>> evaluationFunction {
            in part option :>> alternative : DestinationOrbitOption;
            return :>> result : Real =
                stabilityWeightPerYear * option.unattendedStabilityYears
                - stationKeepingWeight * (option.stationKeepingDeltaVPerYear / 1 ['m/s'])
                - insertionWeight * (option.insertionDeltaV / 1 ['m/s'])
                - accessWeight * (option.visitorAccessDeltaV / 1 ['m/s'])
                - eclipseWeightPerHour * (option.longestEclipse / 1 [h]);
        }
        return part :>> selectedAlternative : DestinationOrbitOption;
    }
    analysis destinationOrbitTrade : DestinationOrbitTrade {
        subject :>> studyAlternatives = (distantRetrograde, nearRectilinearHalo, librationHalo, highEarthOrbit);
    }
    metadata Rationale about destinationOrbitTrade {
        text = "The distant retrograde orbit selected: the only option stable for the 100 years TR-006 asks without station-keeping; TethysEnvironment::destinationDro carries the selection.";
    }

    // ---- T5: capture mechanism ---------------------------------------------------------------

    part def CaptureMechanismOption {
        doc /* A way of taking hold of the body, scored 1 (worst) to 5 (best) on how much of the
             * size, shape and spin envelope it tolerates, how benign its contact dynamics are and
             * how well it can be tested on the ground, with its mass. */
        attribute envelopeTolerance : Natural;
        attribute contactBenignity : Natural;
        attribute groundTestability : Natural;
        attribute mechanismMass : MassValue;
    }
    part inflatableBag : CaptureMechanismOption {
        doc /* An inflatable bag closed by cinch lines: tolerant of shape and spin, soft contact. */
        attribute :>> envelopeTolerance = 5; attribute :>> contactBenignity = 4;
        attribute :>> groundTestability = 3; attribute :>> mechanismMass = 450.0 [kg];
    }
    part rigidArms : CaptureMechanismOption {
        doc /* Three articulated arms with grapple pads: precise, intolerant of a tumbling body. */
        attribute :>> envelopeTolerance = 2; attribute :>> contactBenignity = 2;
        attribute :>> groundTestability = 5; attribute :>> mechanismMass = 380.0 [kg];
    }
    part deployableNet : CaptureMechanismOption {
        doc /* A tethered net: tolerant, but the tethered dynamics are hard to control and test. */
        attribute :>> envelopeTolerance = 4; attribute :>> contactBenignity = 3;
        attribute :>> groundTestability = 2; attribute :>> mechanismMass = 220.0 [kg];
    }
    part harpoons : CaptureMechanismOption {
        doc /* Tethered harpoons: light, but they load one point of an unknown material. */
        attribute :>> envelopeTolerance = 3; attribute :>> contactBenignity = 1;
        attribute :>> groundTestability = 3; attribute :>> mechanismMass = 150.0 [kg];
    }

    analysis def CaptureMechanismTrade :> TradeStudy {
        doc /* Weighted scoring of the capture mechanisms; the highest score wins. */
        subject :>> studyAlternatives : CaptureMechanismOption[1..*];
        in attribute toleranceWeight : Real default = 3.0;
        in attribute benignityWeight : Real default = 3.0;
        in attribute testabilityWeight : Real default = 1.0;
        in attribute massWeightPerKg : Real default = 0.01;
        objective :>> tradeStudyObjective : MaximizeObjective {
            doc /* The alternative with the highest evaluation is selected. */
        }
        calc :>> evaluationFunction {
            in part option :>> alternative : CaptureMechanismOption;
            return :>> result : Real =
                toleranceWeight * option.envelopeTolerance + benignityWeight * option.contactBenignity
                + testabilityWeight * option.groundTestability - massWeightPerKg * (option.mechanismMass / 1 [kg]);
        }
        return part :>> selectedAlternative : CaptureMechanismOption;
    }
    analysis captureMechanismTrade : CaptureMechanismTrade {
        subject :>> studyAlternatives = (inflatableBag, rigidArms, deployableNet, harpoons);
    }
    metadata Rationale about captureMechanismTrade {
        text = "The inflatable bag selected: with the target's shape and spin unknown before arrival, envelope tolerance and benign contact outweigh its mass; TethysTug::CaptureSystem carries the selection.";
    }
}
