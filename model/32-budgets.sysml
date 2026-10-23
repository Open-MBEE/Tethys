// Every engineering budget of Argent, closed in the model: each is a calculation over the unit
// tree of TethysTugStructure, each holds its margin against TethysMarginPolicy, and each is
// asserted by a system requirement. Nothing here is a typed-in total.
package TethysBudgets {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SequenceFunctions::*;
    private import ControlFunctions::collect;
    private import ControlFunctions::forAll;
    private import QuantityCalculations::sum;
    private import RealFunctions::sqrt;
    private import TethysEnvironment::*;
    private import TethysMission::tethys;
    private import TethysLaunch::arcturus5H;
    private import TethysInspector::wren;
    private import TethysTug::argent;
    private import TethysTugStructure::*;
    private import TethysMarginPolicy::*;
    private import TethysRequirements::*;
    private import VerificationCases::VerificationMethodKind;

    // ---- target cases: the design driver ------------------------------------------------------
    attribute def TargetCase {
        doc /* One pre-arrival case of the target: the mass the return budgets carry and the
             * spin that sizes the despin. */
        attribute label : String;
        attribute bodyMass : MassValue;
        attribute meanDiameter : LengthValue;
        attribute rotationPeriod : DurationValue;
    }
    attribute smallTarget : TargetCase {
        doc /* −40 % on the nominal mass: the light, fast case. */
        attribute :>> label = "small";
        attribute :>> bodyMass = 217.0e3 [kg];
        attribute :>> meanDiameter = 5.7 [m];
        attribute :>> rotationPeriod = 180.0 [s];
    }
    attribute nominalTarget : TargetCase {
        doc /* The backbone estimate of 2031 QX. */
        attribute :>> label = "nominal";
        attribute :>> bodyMass = amaranth.mass;
        attribute :>> meanDiameter = amaranth.meanDiameter;
        attribute :>> rotationPeriod = amaranth.rotationPeriod;
    }
    attribute largeTarget : TargetCase {
        doc /* +40 % on the nominal mass: the heavy case that sizes the return. */
        attribute :>> label = "large";
        attribute :>> bodyMass = 507.0e3 [kg];
        attribute :>> meanDiameter = 7.6 [m];
        attribute :>> rotationPeriod = 252.0 [s];
    }
    attribute targetCases : TargetCase[*] = (smallTarget, nominalTarget, largeTarget) {
        doc /* The three cases in the order the budget tables report them. */
    }

    // ---- shared physics -----------------------------------------------------------------------
    calc def ArrayPower {
        doc /* Array power at a heliocentric distance from its 1 AU rating, inverse-square
             * flux, an end-of-life factor and a pointing cosine loss. */
        in ratedAtOneAu : PowerValue;
        in distanceAu : Real;
        in endOfLifeFactor : Real;
        in cosineLoss : Real;
        return power : PowerValue =
            ratedAtOneAu * (SolarFlux(distanceAu) / 1361.0) * endOfLifeFactor * cosineLoss;
    }
    calc def ExpNeg {
        doc /* e^(−x) for x ≥ 0 as a power of e, which the Kernel Function Library can
             * evaluate without an exponential function. */
        in x : Real;
        return value : Real = 2.718281828459045 ** (-x);
    }
    calc def PropellantFor {
        doc /* Propellant for a Δv (m/s) from an initial mass with the given Isp:
             * m₀ (1 − e^(−Δv/(Isp g₀))). */
        in deltaVMPerS : Real;
        in initialMass : MassValue;
        in specificImpulse : DurationValue;
        return propellant : MassValue =
            initialMass * (1.0 - ExpNeg(deltaVMPerS / ((specificImpulse / (1 [s])) * standardGravityMPerS2)));
    }
    calc def MassFlowRate {
        doc /* Propellant mass flow in kg/s of a thruster of thrust T (N) and Isp (s). */
        in thrustN : Real;
        in specificImpulseS : Real;
        return kgPerS : Real = thrustN / (specificImpulseS * standardGravityMPerS2);
    }
    calc def RootSumSquareDegrees {
        doc /* Root-sum-square of angular error contributors, as a plain number of degrees. */
        in contributors : AngularMeasureValue[*] nonunique;
        return rssDegrees : Real =
            sqrt(RealFunctions::sum(contributors->collect { in c : AngularMeasureValue; (c / (1 ['°'])) ** 2 }));
    }
    calc def Survival {
        doc /* Reliability of one unit over a duration: e^(−λt). */
        in failureRate : FrequencyValue;
        in duration : DurationValue;
        return reliability : Real = ExpNeg(failureRate * duration);
    }
    calc def SetReliability {
        doc /* Reliability of a set of identical units of which `required` must survive
             * (k-of-n with independent failures); the sixteen-thruster case is bounded below
             * by eight independent pairs. */
        in failureRates : FrequencyValue[*] nonunique;
        in required : Natural;
        in duration : DurationValue;
        attribute installed : Natural = size(failureRates);
        attribute r : Real = Survival(failureRates#(1), duration);
        return reliability : Real =
            if installed == 1 ? r
            else if installed == 2 and required == 1 ? 1.0 - (1.0 - r) ** 2
            else if installed == 2 ? r ** 2
            else if installed == 3 and required == 2 ? 3.0 * r ** 2 - 2.0 * r ** 3
            else if installed == 4 and required == 3 ? 4.0 * r ** 3 - 3.0 * r ** 4
            else if installed == 4 and required == 2 ? 6.0 * r ** 2 * (1.0 - r) ** 2 + 4.0 * r ** 3 * (1.0 - r) + r ** 4
            else if installed == 6 and required == 5 ? 6.0 * r ** 5 * (1.0 - r) + r ** 6
            else if installed == 16 and required == 8 ? (1.0 - (1.0 - r) ** 2) ** 8
            else r ** installed;
    }
    calc def UnitSetReliability {
        doc /* SetReliability of a set of unit usages, reading their failure rates and the
             * required count they declare. */
        in units : Unit[*];
        in duration : DurationValue;
        return reliability : Real = SetReliability(units.failureRate, head(units.required), duration);
    }

    // ---- the tug seen by the budgets: explicit per-unit-set sums ------------------------------
    calc def TugPowerInMode {
        doc /* Electrical demand of the whole tug in a mode: every unit set of every subsystem,
             * one term each, read from the design directly (docs/findings/WP-B.md says why
             * the sets are named rather than reached through each subsystem's `units`). */
        in mode : TugMode;
        return power : PowerValue =
            UnitsPowerInMode(argentDesign.structure.inspectorDispenser, mode)
            + UnitsPowerInMode(argentDesign.structure.arrayDeploymentMechanisms, mode)
            + UnitsPowerInMode(argentDesign.structure.radiatorDeploymentMechanism, mode)
            + UnitsPowerInMode(argentDesign.structure.dockingMechanism, mode)
            + UnitsPowerInMode(argentDesign.thermal.coolantPumps, mode)
            + UnitsPowerInMode(argentDesign.thermal.heaters, mode)
            + UnitsPowerInMode(argentDesign.thermal.sensors, mode)
            + UnitsPowerInMode(argentDesign.eps.arrayDrives, mode)
            + UnitsPowerInMode(argentDesign.eps.powerConditioning, mode)
            + UnitsPowerInMode(argentDesign.eps.highVoltageSwitching, mode)
            + UnitsPowerInMode(argentDesign.cdh.flightComputers, mode)
            + UnitsPowerInMode(argentDesign.cdh.massMemories, mode)
            + UnitsPowerInMode(argentDesign.cdh.remoteInterfaceUnits, mode)
            + UnitsPowerInMode(argentDesign.telecom.transponders, mode)
            + UnitsPowerInMode(argentDesign.telecom.amplifiers, mode)
            + UnitsPowerInMode(argentDesign.telecom.antennaPointing, mode)
            + UnitsPowerInMode(argentDesign.telecom.proximityTransceivers, mode)
            + UnitsPowerInMode(argentDesign.gnc.starTrackers, mode)
            + UnitsPowerInMode(argentDesign.gnc.inertialUnits, mode)
            + UnitsPowerInMode(argentDesign.gnc.sunSensors, mode)
            + UnitsPowerInMode(argentDesign.gnc.reactionWheels, mode)
            + UnitsPowerInMode(argentDesign.gnc.navigationCameras, mode)
            + UnitsPowerInMode(argentDesign.gnc.lidars, mode)
            + UnitsPowerInMode(argentDesign.sep.thrusters, mode)
            + UnitsPowerInMode(argentDesign.sep.powerProcessingUnits, mode)
            + UnitsPowerInMode(argentDesign.sep.flowControllers, mode)
            + UnitsPowerInMode(argentDesign.sep.gimbals, mode)
            + UnitsPowerInMode(argentDesign.sep.propellantManagement, mode)
            + UnitsPowerInMode(argentDesign.rcs.thrusters, mode)
            + UnitsPowerInMode(argentDesign.rcs.feed, mode)
            + UnitsPowerInMode(argentDesign.captureSystem.winches, mode)
            + UnitsPowerInMode(argentDesign.captureSystem.inflation, mode)
            + UnitsPowerInMode(argentDesign.captureSystem.contactSensors, mode)
            + UnitsPowerInMode(argentDesign.captureSystem.release, mode)
            + UnitsPowerInMode(argentDesign.sensors.narrowAngleCamera, mode)
            + UnitsPowerInMode(argentDesign.sensors.wideAngleCamera, mode)
            + UnitsPowerInMode(argentDesign.sensors.thermalImager, mode);
    }
    calc def BusPowerInMode {
        doc /* The demand of everything but the thruster strings: what the array must supply
             * before any power goes to propulsion. */
        in mode : TugMode;
        return power : PowerValue = TugPowerInMode(mode)
            - UnitsPowerInMode(argentDesign.sep.thrusters, mode)
            - UnitsPowerInMode(argentDesign.sep.powerProcessingUnits, mode);
    }
    calc def TugHeatInMode {
        doc /* Heat dissipated inside the tug in a mode, same terms as the power. */
        in mode : TugMode;
        return heat : PowerValue =
            UnitsHeatInMode(argentDesign.structure.inspectorDispenser, mode)
            + UnitsHeatInMode(argentDesign.structure.arrayDeploymentMechanisms, mode)
            + UnitsHeatInMode(argentDesign.structure.radiatorDeploymentMechanism, mode)
            + UnitsHeatInMode(argentDesign.structure.dockingMechanism, mode)
            + UnitsHeatInMode(argentDesign.thermal.coolantPumps, mode)
            + UnitsHeatInMode(argentDesign.thermal.heaters, mode)
            + UnitsHeatInMode(argentDesign.thermal.sensors, mode)
            + UnitsHeatInMode(argentDesign.eps.arrayDrives, mode)
            + UnitsHeatInMode(argentDesign.eps.powerConditioning, mode)
            + UnitsHeatInMode(argentDesign.eps.highVoltageSwitching, mode)
            + UnitsHeatInMode(argentDesign.cdh.flightComputers, mode)
            + UnitsHeatInMode(argentDesign.cdh.massMemories, mode)
            + UnitsHeatInMode(argentDesign.cdh.remoteInterfaceUnits, mode)
            + UnitsHeatInMode(argentDesign.telecom.transponders, mode)
            + UnitsHeatInMode(argentDesign.telecom.amplifiers, mode)
            + UnitsHeatInMode(argentDesign.telecom.antennaPointing, mode)
            + UnitsHeatInMode(argentDesign.telecom.proximityTransceivers, mode)
            + UnitsHeatInMode(argentDesign.gnc.starTrackers, mode)
            + UnitsHeatInMode(argentDesign.gnc.inertialUnits, mode)
            + UnitsHeatInMode(argentDesign.gnc.sunSensors, mode)
            + UnitsHeatInMode(argentDesign.gnc.reactionWheels, mode)
            + UnitsHeatInMode(argentDesign.gnc.navigationCameras, mode)
            + UnitsHeatInMode(argentDesign.gnc.lidars, mode)
            + UnitsHeatInMode(argentDesign.sep.thrusters, mode)
            + UnitsHeatInMode(argentDesign.sep.powerProcessingUnits, mode)
            + UnitsHeatInMode(argentDesign.sep.flowControllers, mode)
            + UnitsHeatInMode(argentDesign.sep.gimbals, mode)
            + UnitsHeatInMode(argentDesign.sep.propellantManagement, mode)
            + UnitsHeatInMode(argentDesign.rcs.thrusters, mode)
            + UnitsHeatInMode(argentDesign.rcs.feed, mode)
            + UnitsHeatInMode(argentDesign.captureSystem.winches, mode)
            + UnitsHeatInMode(argentDesign.captureSystem.inflation, mode)
            + UnitsHeatInMode(argentDesign.captureSystem.contactSensors, mode)
            + UnitsHeatInMode(argentDesign.captureSystem.release, mode)
            + UnitsHeatInMode(argentDesign.sensors.narrowAngleCamera, mode)
            + UnitsHeatInMode(argentDesign.sensors.wideAngleCamera, mode)
            + UnitsHeatInMode(argentDesign.sensors.thermalImager, mode);
    }
    calc def UnitsDataRate {
        doc /* Data generated per second by a set of units while operating, scaled by the
             * share powered at once. */
        in units : Unit[*];
        return rate : TransferRateValue = sum(units->collect { in u : Unit; u.dataRate * u.poweredShare });
    }

    // ---- mass ----------------------------------------------------------------------------------
    part def MassBudget {
        doc /* Dry mass by maturity contingency against the backbone allocation, and launch
             * mass against the launcher at the mission C3. The target is not in the launch
             * mass; it enters the stack mass properties after capture. */
        attribute dryEstimate : MassValue = argentDesign.dryMassEstimate;
        attribute dryWithContingency : MassValue = argentDesign.dryMassAllocated;
        attribute dryAllocation : MassValue = argent.dryMass;
        attribute dryMargin : Real = MarginFraction(dryAllocation, dryWithContingency);
        attribute xenon : MassValue = argentDesign.sep.xenonMass;
        attribute hydrazine : MassValue = argentDesign.rcs.hydrazineMass;
        attribute inspector : MassValue = wren.wetMass;
        attribute adapterSeparated : MassValue = argentDesign.structure.launchAdapterRing.mass;
        attribute launchMass : MassValue = dryAllocation + xenon + hydrazine + inspector;
        attribute launcherCapability : MassValue = arcturus5H.performanceAtC3;
        attribute launchMargin : Real = MarginFraction(launcherCapability, launchMass);
        assert constraint dryCloses : ClosesWithMargin {
            in capability = dryAllocation; in demand = dryWithContingency; in policy = activePolicy;
        }
        assert constraint launchCloses : ClosesWithMargin {
            in capability = launcherCapability; in demand = launchMass; in policy = activePolicy;
        }
    }
    part massBudget : MassBudget {
        doc /* The Phase B mass budget of Argent. */
    }

    // ---- power -------------------------------------------------------------------------------
    part def PowerBudget {
        doc /* Demand per mode from the unit tree against the array at the worst sun distance
             * of the mission (the target's aphelion) at end of life with a 2° pointing loss.
             * Thrusting is budgeted at the cruise throttle point; the thrusters take what
             * the array has left above that. */
        attribute aphelionAu : Real = amaranth.orbit.aphelionAu;
        attribute perihelionAu : Real = amaranth.orbit.perihelionAu;
        attribute endOfLifeFactor : Real = head(argentDesign.eps.arrayWings.endOfLifeFactor);
        attribute cosineLoss : Real = 0.9994;
        attribute arrayAtAphelionEol : PowerValue =
            ArrayPower(argentDesign.eps.arrayPowerAtOneAu, aphelionAu, endOfLifeFactor, cosineLoss);
        attribute arrayAtPerihelionBol : PowerValue =
            ArrayPower(argentDesign.eps.arrayPowerAtOneAu, perihelionAu, 1.0, cosineLoss);
        attribute demandEarlyOperations : PowerValue = TugPowerInMode(TugMode::earlyOperations);
        attribute demandThrusting : PowerValue = TugPowerInMode(TugMode::thrusting);
        attribute demandCoasting : PowerValue = TugPowerInMode(TugMode::coasting);
        attribute demandProximityOperations : PowerValue = TugPowerInMode(TugMode::proximityOperations);
        attribute demandCapture : PowerValue = TugPowerInMode(TugMode::capture);
        attribute demandDespin : PowerValue = TugPowerInMode(TugMode::despin);
        attribute demandDroHold : PowerValue = TugPowerInMode(TugMode::droHold);
        attribute demandSafe : PowerValue = TugPowerInMode(TugMode::safe);
        attribute busDemandThrusting : PowerValue = BusPowerInMode(TugMode::thrusting);
        attribute availableForPropulsion : PowerValue = arrayAtAphelionEol - busDemandThrusting;
        attribute thrustingMargin : Real = MarginFraction(arrayAtAphelionEol, demandThrusting);
        assert constraint earlyOperationsClose : ClosesWithMargin {
            in capability = arrayAtAphelionEol; in demand = demandEarlyOperations; in policy = activePolicy;
        }
        assert constraint thrustingCloses : ClosesWithMargin {
            in capability = arrayAtAphelionEol; in demand = demandThrusting; in policy = activePolicy;
        }
        assert constraint coastingCloses : ClosesWithMargin {
            in capability = arrayAtAphelionEol; in demand = demandCoasting; in policy = activePolicy;
        }
        assert constraint proximityOperationsClose : ClosesWithMargin {
            in capability = arrayAtAphelionEol; in demand = demandProximityOperations; in policy = activePolicy;
        }
        assert constraint captureCloses : ClosesWithMargin {
            in capability = arrayAtAphelionEol; in demand = demandCapture; in policy = activePolicy;
        }
        assert constraint despinCloses : ClosesWithMargin {
            in capability = arrayAtAphelionEol; in demand = demandDespin; in policy = activePolicy;
        }
        assert constraint droHoldCloses : ClosesWithMargin {
            in capability = arrayAtAphelionEol; in demand = demandDroHold; in policy = activePolicy;
        }
        assert constraint safeCloses : ClosesWithMargin {
            in capability = arrayAtAphelionEol; in demand = demandSafe; in policy = activePolicy;
        }
    }
    part powerBudget : PowerBudget {
        doc /* The Phase B power budget of Argent, every mode. */
    }

    // ---- energy ------------------------------------------------------------------------------
    part def EnergyBudget {
        doc /* Battery energy over the longest eclipse of the mission — up to four hours in
             * the Earth's shadow at the distant retrograde orbit — and over launch to array
             * deployment, each within the batteries' depth-of-discharge limit. */
        attribute capacity : EnergyValue = argentDesign.eps.batteryCapacity;
        attribute usable : EnergyValue = capacity * head(argentDesign.eps.batteries.maximumDepthOfDischarge);
        attribute droEclipse : DurationValue = 4.0 [h];
        attribute launchToArrays : DurationValue = 1.5 [h];
        attribute eclipseEnergy : EnergyValue = TugPowerInMode(TugMode::droHold) * droEclipse;
        attribute launchEnergy : EnergyValue = TugPowerInMode(TugMode::earlyOperations) * launchToArrays;
        attribute eclipseMargin : Real = MarginFraction(usable, eclipseEnergy);
        assert constraint eclipseCloses : ClosesWithMargin {
            in capability = usable; in demand = eclipseEnergy; in policy = activePolicy;
        }
        assert constraint launchCloses : ClosesWithMargin {
            in capability = usable; in demand = launchEnergy; in policy = activePolicy;
        }
    }
    part energyBudget : EnergyBudget {
        doc /* The Phase B energy budget of Argent. */
    }

    part def InspectorEnergyBudget {
        doc /* Wren's rechargeable battery over the longest occultation of the Sun by the
             * target seen on its slow circumnavigation, at its standby load. */
        attribute capacity : EnergyValue = 180.0 ['W⋅h'];
        attribute maximumDepthOfDischarge : Real = 0.6;
        attribute standbyLoad : PowerValue = 11.0 [W];
        attribute occultation : DurationValue = 5.0 [h];
        attribute usable : EnergyValue = capacity * maximumDepthOfDischarge;
        attribute demand : EnergyValue = standbyLoad * occultation;
        assert constraint closes : ClosesWithMargin {
            in capability = usable; in demand = demand; in policy = activePolicy;
        }
    }
    part inspectorEnergyBudget : InspectorEnergyBudget {
        doc /* Wren's energy budget. */
    }

    // ---- data ----------------------------------------------------------------------------------
    part def DataBudget {
        doc /* Characterisation data generated per day in proximity operations at the imaging
             * duty cycle, against the daily Ka-band downlink at the maximum Earth range and
             * against mass memory for the days between passes. */
        attribute generatingRate : TransferRateValue =
            UnitsDataRate(argentDesign.gnc.navigationCameras) + UnitsDataRate(argentDesign.gnc.lidars)
            + UnitsDataRate(argentDesign.sensors.narrowAngleCamera)
            + UnitsDataRate(argentDesign.sensors.wideAngleCamera)
            + UnitsDataRate(argentDesign.sensors.thermalImager)
            + UnitsDataRate(argentDesign.captureSystem.contactSensors)
            + UnitsDataRate(argentDesign.cdh.flightComputers)
            + UnitsDataRate(argentDesign.cdh.remoteInterfaceUnits);
        attribute imagingDutyCycle : Real = 0.03;
        attribute dailyGenerated : StorageCapacityValue =
            (generatingRate / (1 ['bit/s'])) * imagingDutyCycle * 86400.0 * (1 [bit]);
        attribute downlinkRateAtMaximumRange : TransferRateValue = 2.5e6 ['bit/s'];
        attribute dailyContact : DurationValue = 10.0 [h];
        attribute dailyDownlink : StorageCapacityValue =
            (downlinkRateAtMaximumRange / (1 ['bit/s'])) * (dailyContact / (1 [s])) * (1 [bit]);
        attribute storage : StorageCapacityValue = argentDesign.cdh.storageCapacity;
        attribute daysWithoutContact : Real = 10.0;
        attribute storageDemand : StorageCapacityValue = dailyGenerated * daysWithoutContact;
        assert constraint downlinkCloses : ClosesWithMargin {
            in capability = dailyDownlink; in demand = dailyGenerated; in policy = activePolicy;
        }
        assert constraint storageCloses : ClosesWithMargin {
            in capability = storage; in demand = storageDemand; in policy = activePolicy;
        }
    }
    part dataBudget : DataBudget {
        doc /* The Phase B data budget of Argent. */
    }

    // ---- Δv, xenon and the SEP string ----------------------------------------------------------
    calc def XenonForMission {
        doc /* Xenon for the four low-thrust arcs with the target of the given case attached
             * on the return: outbound and rendezvous on the tug alone, return and insertion
             * on the stack, each arc from the mass the previous one left. */
        in body : TargetCase;
        attribute isp : DurationValue = argentDesign.sep.specificImpulse;
        attribute launchMass : MassValue = massBudget.launchMass - massBudget.adapterSeparated;
        attribute outbound : MassValue = PropellantFor(deltaVOutbound, launchMass, isp);
        attribute afterOutbound : MassValue = launchMass - outbound;
        attribute rendezvous : MassValue = PropellantFor(deltaVRendezvous, afterOutbound, isp);
        attribute afterRendezvous : MassValue = afterOutbound - rendezvous - wren.wetMass;
        attribute stack : MassValue = afterRendezvous + body.bodyMass;
        attribute returnLeg : MassValue = PropellantFor(deltaVReturn, stack, isp);
        attribute insertion : MassValue = PropellantFor(deltaVInsertion, stack - returnLeg, isp);
        return xenon : MassValue = (outbound + rendezvous + returnLeg + insertion) * (1.0 + missedThrustMargin);
    }
    attribute deltaVOutbound : Real = 2800.0 {
        doc /* Low-thrust Δv in m/s from the escape asymptote to the target's orbit. */
    }
    attribute deltaVRendezvous : Real = 150.0 {
        doc /* Δv in m/s for the approach, station-keeping and the capture manoeuvres. */
    }
    attribute deltaVReturn : Real = 160.0 {
        doc /* Low-thrust Δv in m/s from the target's orbit to the lunar gravity assist: the
             * allocation the xenon left after rendezvous can give the heaviest stack, which the
             * return trajectory design (TethysAnalyses) must meet with the Earth-like orbit's
             * small relative velocity and the gravity assist. */
    }
    attribute deltaVInsertion : Real = 40.0 {
        doc /* Δv in m/s from the gravity assist into the distant retrograde orbit. */
    }
    attribute missedThrustMargin : Real = 0.10 {
        doc /* Unplanned coast allowance on every arc. */
    }

    part def PropellantBudget {
        doc /* Xenon required against the load for every target case, with residuals held
             * back; and the thrusting time the mission needs against the time the timeline
             * gives it, from the SEP string: array power at aphelion less the bus, through the
             * PPUs to thrust, Isp to mass flow. */
        attribute loaded : MassValue = argentDesign.sep.xenonMass;
        attribute residualFraction : Real = 0.02;
        attribute usable : MassValue = loaded * (1.0 - residualFraction);
        attribute xenonSmall : MassValue = XenonForMission(smallTarget);
        attribute xenonNominal : MassValue = XenonForMission(nominalTarget);
        attribute xenonLarge : MassValue = XenonForMission(largeTarget);
        attribute xenonMargin : Real = MarginFraction(usable, xenonLarge);
        attribute tankCapacity : MassValue = argentDesign.sep.xenonCapacity;
        attribute throughputPerThruster : MassValue = xenonLarge / argentDesign.sep.operatingThrusters;
        attribute throughputLife : MassValue = head(argentDesign.sep.thrusters.xenonThroughputLife);
        attribute sepPowerAtAphelion : PowerValue = powerBudget.availableForPropulsion;
        attribute ppuEfficiency : Real = head(argentDesign.sep.powerProcessingUnits.efficiency);
        attribute thrustAtAphelion : Real = SepThrust((sepPowerAtAphelion / (1 [W])) * ppuEfficiency,
            argentDesign.sep.specificImpulse / (1 [s]), head(argentDesign.sep.thrusters.efficiency));
        attribute thrustAtFullPower : Real = SepThrust((argentDesign.sep.maximumPower / (1 [W])) * ppuEfficiency,
            argentDesign.sep.specificImpulse / (1 [s]), head(argentDesign.sep.thrusters.efficiency));
        attribute massFlowAtAphelion : Real = MassFlowRate(thrustAtAphelion, argentDesign.sep.specificImpulse / (1 [s]));
        attribute thrustingTimeLarge : DurationValue = (xenonLarge / (1 [kg])) / massFlowAtAphelion * (1 [s]);
        attribute thrustingTimeAllowed : DurationValue = 1400.0 [d];
        attribute stackAccelerationLarge : Real = thrustAtAphelion / ((massBudget.launchMass + largeTarget.bodyMass) / (1 [kg]));
        assert constraint xenonClosesLarge : ClosesWithMargin {
            in capability = usable; in demand = xenonLarge; in policy = activePolicy;
        }
        assert constraint xenonClosesNominal : ClosesWithMargin {
            in capability = usable; in demand = xenonNominal; in policy = activePolicy;
        }
        assert constraint xenonClosesSmall : ClosesWithMargin {
            in capability = usable; in demand = xenonSmall; in policy = activePolicy;
        }
        assert constraint tanksHoldLoad : ReserveNotNegative { in loaded = tankCapacity; in demand = loaded; }
        assert constraint throughputWithinLife : ClosesWithMargin {
            in capability = throughputLife; in demand = throughputPerThruster; in policy = activePolicy;
        }
        assert constraint thrustingTimeCloses : ClosesWithMargin {
            in capability = thrustingTimeAllowed; in demand = thrustingTimeLarge; in policy = activePolicy;
        }
    }
    part propellantBudget : PropellantBudget {
        doc /* The Phase B xenon and thrusting-time budget of Argent over the target cases. */
    }

    calc def DespinPropellant {
        doc /* Hydrazine to remove the angular momentum of a uniform sphere of the case's mass,
             * diameter and spin period with thrusters on the given arm:
             * H = 0.4 m r² ω, m = H / (arm · Isp · g₀). */
        in body : TargetCase;
        in momentArm : LengthValue;
        in specificImpulse : DurationValue;
        attribute radius : Real = (body.meanDiameter / (1 [m])) / 2.0;
        attribute spinRate : Real = 2.0 * pi / (body.rotationPeriod / (1 [s]));
        attribute angularMomentum : Real = 0.4 * (body.bodyMass / (1 [kg])) * radius ** 2 * spinRate;
        return propellant : MassValue =
            angularMomentum / ((momentArm / (1 [m])) * (specificImpulse / (1 [s])) * standardGravityMPerS2) * (1 [kg]);
    }
    part def HydrazineBudget {
        doc /* Hydrazine for proximity operations, the despin of each target case and the
             * attitude control of the stack through the return, against the load. */
        attribute loaded : MassValue = argentDesign.rcs.hydrazineMass;
        attribute residualFraction : Real = 0.03;
        attribute usable : MassValue = loaded * (1.0 - residualFraction);
        attribute isp : DurationValue = head(argentDesign.rcs.thrusters.specificImpulse);
        attribute momentArm : LengthValue = head(argentDesign.rcs.thrusters.momentArm);
        attribute proximityDeltaV : Real = 30.0;
        attribute tugMassAtTarget : MassValue = massBudget.launchMass - massBudget.adapterSeparated - 700.0 [kg];
        attribute proximityOperations : MassValue = PropellantFor(proximityDeltaV, tugMassAtTarget, isp);
        attribute despinSmall : MassValue = DespinPropellant(smallTarget, momentArm, isp);
        attribute despinNominal : MassValue = DespinPropellant(nominalTarget, momentArm, isp);
        attribute despinLarge : MassValue = DespinPropellant(largeTarget, momentArm, isp);
        attribute stackAttitudeControl : MassValue = 95.0 [kg];
        attribute wheelDesaturation : MassValue = 25.0 [kg];
        attribute demandLarge : MassValue = proximityOperations + despinLarge + stackAttitudeControl + wheelDesaturation;
        attribute demandSmall : MassValue = proximityOperations + despinSmall + stackAttitudeControl + wheelDesaturation;
        attribute hydrazineMargin : Real = MarginFraction(usable, demandLarge);
        assert constraint closesLarge : ClosesWithMargin {
            in capability = usable; in demand = demandLarge; in policy = activePolicy;
        }
        assert constraint closesSmall : ClosesWithMargin {
            in capability = usable; in demand = demandSmall; in policy = activePolicy;
        }
        assert constraint tanksHoldLoad : ReserveNotNegative {
            in loaded = argentDesign.rcs.hydrazineCapacity; in demand = loaded;
        }
    }
    part hydrazineBudget : HydrazineBudget {
        doc /* The Phase B hydrazine budget of Argent over the target cases. */
    }

    // ---- pointing ------------------------------------------------------------------------------
    part def PointingBudget {
        doc /* Root-sum-square error trees for the high-gain antenna and for the thrust vector
             * through the stack's centre of mass, each against its allocation. */
        attribute starTrackerKnowledge : AngularMeasureValue = head(argentDesign.gnc.starTrackers.attitudeKnowledgeError);
        attribute gyroDrift : AngularMeasureValue = 0.0020 ['°'];
        attribute controlError : AngularMeasureValue = 0.0100 ['°'];
        attribute antennaAlignment : AngularMeasureValue = 0.0150 ['°'];
        attribute gimbalResolution : AngularMeasureValue = 0.0080 ['°'];
        attribute thermalDistortion : AngularMeasureValue = 0.0120 ['°'];
        attribute antennaPointingErrorDegrees : Real = RootSumSquareDegrees((starTrackerKnowledge,
            gyroDrift, controlError, antennaAlignment, gimbalResolution, thermalDistortion));
        attribute antennaAllocation : AngularMeasureValue = 0.0500 ['°'];
        attribute centreOfMassKnowledge : AngularMeasureValue = 0.2000 ['°'];
        attribute thrusterAlignment : AngularMeasureValue = 0.1000 ['°'];
        attribute gimbalControl : AngularMeasureValue = 0.0500 ['°'];
        attribute thrustVectorErrorDegrees : Real = RootSumSquareDegrees((starTrackerKnowledge,
            gyroDrift, centreOfMassKnowledge, thrusterAlignment, gimbalControl));
        attribute thrustVectorAllocation : AngularMeasureValue = 0.5000 ['°'];
        assert constraint antennaCloses {
            antennaPointingErrorDegrees * (1.0 + activePolicy.systemMargin) <= antennaAllocation / (1 ['°'])
        }
        assert constraint thrustVectorCloses {
            thrustVectorErrorDegrees * (1.0 + activePolicy.systemMargin) <= thrustVectorAllocation / (1 ['°'])
        }
    }
    part pointingBudget : PointingBudget {
        doc /* The Phase B pointing budget of Argent. */
    }

    // ---- thermal -------------------------------------------------------------------------------
    calc def RadiatorRejection {
        doc /* Heat a radiator rejects to deep space: ε σ A T⁴ with the Sun off its face. */
        in area : AreaValue;
        in emissivity : Real;
        in temperature : ThermodynamicTemperatureValue;
        return heat : PowerValue =
            emissivity * 5.670374419e-8 * (area / (1 ['m²'])) * (temperature / (1 [K])) ** 4 * (1 [W]);
    }
    part def ThermalBudget {
        doc /* Hot case: full-power thrusting at the target's perihelion, every dissipation on
             * the radiators at their hot-case temperature. Cold case: coasting at aphelion,
             * heater power within its power-budget allocation. Every unit's predicted
             * temperatures within its limits in both cases. */
        attribute hotCaseHeat : PowerValue = TugHeatInMode(TugMode::thrusting) * 1.22;
        attribute radiatorTemperature : ThermodynamicTemperatureValue = head(argentDesign.thermal.radiators.predictedHotTemperature);
        attribute radiatorCapacity : PowerValue = RadiatorRejection(argentDesign.thermal.radiatorArea,
            head(argentDesign.thermal.radiators.emissivity), radiatorTemperature);
        attribute coldCaseHeaterPower : PowerValue = UnitsPowerInMode(argentDesign.thermal.heaters, TugMode::coasting);
        attribute heaterAllocation : PowerValue = 320.0 [W];
        attribute hotUnitsWithinLimits : Boolean = argentDesign.units->forAll { in u : Unit;
            u.predictedHotTemperature <= u.maxOperatingTemperature };
        attribute coldUnitsWithinLimits : Boolean = argentDesign.units->forAll { in u : Unit;
            u.predictedColdTemperature >= u.minOperatingTemperature };
        assert constraint radiatorsClose : ClosesWithMargin {
            in capability = radiatorCapacity; in demand = hotCaseHeat; in policy = activePolicy;
        }
        assert constraint heatersClose : ClosesWithMargin {
            in capability = heaterAllocation; in demand = coldCaseHeaterPower; in policy = activePolicy;
        }
        assert constraint unitsWithinLimits { hotUnitsWithinLimits and coldUnitsWithinLimits }
    }
    part thermalBudget : ThermalBudget {
        doc /* The Phase B thermal budget of Argent. */
    }

    // ---- capture contact loads -----------------------------------------------------------------
    part def CaptureLoadBudget {
        doc /* The loads of capture for the heavy case: the body arrested from its surface speed
             * over the bag's compliance stroke, the cinch preload, and the steady thrust load
             * through the booms, each against the capture system's capacity. */
        attribute contactSpeed : SpeedValue = 0.085 ['m/s'];
        attribute arrestTime : DurationValue = 3.0 [s];
        attribute contactForceLarge : ForceValue = largeTarget.bodyMass * contactSpeed / arrestTime;
        attribute cinchPreload : ForceValue = sum(argentDesign.captureSystem.winches.lineTension);
        attribute thrustLoad : ForceValue = propellantBudget.thrustAtFullPower * (1 [N]);
        attribute loadCapacity : ForceValue = argentDesign.captureSystem.bag.cinchLoadCapacity;
        assert constraint contactCloses : ClosesWithMargin {
            in capability = loadCapacity; in demand = contactForceLarge; in policy = activePolicy;
        }
        assert constraint preloadWithinCapacity : ClosesWithMargin {
            in capability = loadCapacity; in demand = cinchPreload + thrustLoad; in policy = activePolicy;
        }
    }
    part captureLoadBudget : CaptureLoadBudget {
        doc /* The Phase B capture load budget of Argent. */
    }

    // ---- radiation, EMC, processors --------------------------------------------------------------
    part def RadiationBudget {
        doc /* Mission total ionising dose behind the bus shielding — belt transit, solar
             * particle events and cosmic rays over the nominal duration — times the design
             * margin, against every unit's rating. */
        attribute missionDose : AbsorbedDoseValue = 150.0 [Gy];
        attribute radiationDesignMargin : Real = 2.0;
        attribute requiredRating : AbsorbedDoseValue = missionDose * radiationDesignMargin;
        attribute everyUnitRated : Boolean = argentDesign.units->forAll { in u : Unit; u.doseRating >= requiredRating };
        assert constraint allRated { everyUnitRated }
    }
    part radiationBudget : RadiationBudget {
        doc /* The Phase B radiation budget of Argent. */
    }

    part def MagneticCleanlinessBudget {
        doc /* Sum of the units' magnetic moments against the allocation the relative-navigation
             * and attitude sensors tolerate. */
        attribute totalMoment : MagneticMomentValue = sum(argentDesign.units.magneticMoment);
        attribute allocated : MagneticMomentValue = 30.0 ['A⋅m²'];
        assert constraint closes : ClosesWithMargin {
            in capability = allocated; in demand = totalMoment; in policy = activePolicy;
        }
    }
    part magneticCleanlinessBudget : MagneticCleanlinessBudget {
        doc /* The Phase B magnetic cleanliness budget of Argent. */
    }

    part def ProcessorBudget {
        doc /* Flight computer processor and memory loads against capacity with the 50 %
             * reserve the software margin policy demands at PDR. */
        attribute reserve : Real = 0.50;
        attribute capacityMips : Real = head(argentDesign.cdh.flightComputers.processorCapacityMips);
        attribute loadMips : Real = head(argentDesign.cdh.flightComputers.processorLoadMips);
        attribute memoryCapacity : StorageCapacityValue = head(argentDesign.cdh.flightComputers.memoryCapacity);
        attribute memoryAllocated : StorageCapacityValue = head(argentDesign.cdh.flightComputers.memoryAllocated);
        assert constraint processorCloses { loadMips <= capacityMips * (1.0 - reserve) }
        assert constraint memoryCloses { memoryAllocated <= memoryCapacity * (1.0 - reserve) }
    }
    part processorBudget : ProcessorBudget {
        doc /* The Phase B processor budget of Argent. */
    }

    // ---- reliability -----------------------------------------------------------------------------
    part def ReliabilityBudget {
        doc /* Mission reliability as the product over every unit set of its k-of-n survival
             * over the nominal duration, against the allocation. */
        attribute duration : DurationValue = tethys.nominalDuration;
        attribute structureReliability : Real =
            UnitSetReliability(argentDesign.structure.primaryStructure, duration)
            * UnitSetReliability(argentDesign.structure.launchAdapterRing, duration)
            * UnitSetReliability(argentDesign.structure.inspectorDispenser, duration)
            * UnitSetReliability(argentDesign.structure.arrayDeploymentMechanisms, duration)
            * UnitSetReliability(argentDesign.structure.radiatorDeploymentMechanism, duration)
            * UnitSetReliability(argentDesign.structure.dockingMechanism, duration)
            * UnitSetReliability(argentDesign.structure.harness, duration);
        attribute thermalReliability : Real =
            UnitSetReliability(argentDesign.thermal.insulation, duration)
            * UnitSetReliability(argentDesign.thermal.radiators, duration)
            * UnitSetReliability(argentDesign.thermal.coolantPumps, duration)
            * UnitSetReliability(argentDesign.thermal.loopPlumbing, duration)
            * UnitSetReliability(argentDesign.thermal.heaters, duration)
            * UnitSetReliability(argentDesign.thermal.sensors, duration);
        attribute powerReliability : Real =
            UnitSetReliability(argentDesign.eps.arrayWings, duration)
            * UnitSetReliability(argentDesign.eps.arrayDrives, duration)
            * UnitSetReliability(argentDesign.eps.batteries, duration)
            * UnitSetReliability(argentDesign.eps.powerConditioning, duration)
            * UnitSetReliability(argentDesign.eps.highVoltageSwitching, duration);
        attribute avionicsReliability : Real =
            UnitSetReliability(argentDesign.cdh.flightComputers, duration)
            * UnitSetReliability(argentDesign.cdh.massMemories, duration)
            * UnitSetReliability(argentDesign.cdh.remoteInterfaceUnits, duration);
        attribute telecomReliability : Real =
            UnitSetReliability(argentDesign.telecom.transponders, duration)
            * UnitSetReliability(argentDesign.telecom.amplifiers, duration)
            * UnitSetReliability(argentDesign.telecom.highGainAntenna, duration)
            * UnitSetReliability(argentDesign.telecom.antennaPointing, duration)
            * UnitSetReliability(argentDesign.telecom.lowGainAntennas, duration)
            * UnitSetReliability(argentDesign.telecom.proximityTransceivers, duration);
        attribute gncReliability : Real =
            UnitSetReliability(argentDesign.gnc.starTrackers, duration)
            * UnitSetReliability(argentDesign.gnc.inertialUnits, duration)
            * UnitSetReliability(argentDesign.gnc.sunSensors, duration)
            * UnitSetReliability(argentDesign.gnc.reactionWheels, duration)
            * UnitSetReliability(argentDesign.gnc.navigationCameras, duration)
            * UnitSetReliability(argentDesign.gnc.lidars, duration);
        attribute propulsionReliability : Real =
            UnitSetReliability(argentDesign.sep.thrusters, duration)
            * UnitSetReliability(argentDesign.sep.powerProcessingUnits, duration)
            * UnitSetReliability(argentDesign.sep.xenonTanks, duration)
            * UnitSetReliability(argentDesign.sep.flowControllers, duration)
            * UnitSetReliability(argentDesign.sep.gimbals, duration)
            * UnitSetReliability(argentDesign.sep.propellantManagement, duration);
        attribute reactionControlReliability : Real =
            UnitSetReliability(argentDesign.rcs.thrusters, duration)
            * UnitSetReliability(argentDesign.rcs.tanks, duration)
            * UnitSetReliability(argentDesign.rcs.feed, duration);
        attribute captureReliability : Real =
            UnitSetReliability(argentDesign.captureSystem.bag, duration)
            * UnitSetReliability(argentDesign.captureSystem.booms, duration)
            * UnitSetReliability(argentDesign.captureSystem.winches, duration)
            * UnitSetReliability(argentDesign.captureSystem.inflation, duration)
            * UnitSetReliability(argentDesign.captureSystem.contactSensors, duration)
            * UnitSetReliability(argentDesign.captureSystem.release, duration);
        attribute sensorsReliability : Real =
            UnitSetReliability(argentDesign.sensors.narrowAngleCamera, duration)
            * UnitSetReliability(argentDesign.sensors.wideAngleCamera, duration)
            * UnitSetReliability(argentDesign.sensors.thermalImager, duration);
        attribute missionReliability : Real = structureReliability * thermalReliability * powerReliability
            * avionicsReliability * telecomReliability * gncReliability * propulsionReliability
            * reactionControlReliability * captureReliability * sensorsReliability;
        attribute allocated : Real = 0.85;
        attribute subsystemAllocation : Real = 0.95;
        assert constraint missionCloses { missionReliability >= allocated }
        assert constraint subsystemsClose {
            structureReliability >= subsystemAllocation and thermalReliability >= subsystemAllocation
            and powerReliability >= subsystemAllocation and avionicsReliability >= subsystemAllocation
            and telecomReliability >= subsystemAllocation and gncReliability >= subsystemAllocation
            and propulsionReliability >= subsystemAllocation and reactionControlReliability >= subsystemAllocation
            and captureReliability >= subsystemAllocation and sensorsReliability >= subsystemAllocation
        }
    }
    part reliabilityBudget : ReliabilityBudget {
        doc /* The Phase B reliability budget of Argent. */
    }

    // ---- requirements asserting each budget --------------------------------------------------
    requirement <'TS-121'> massBudgetCloses : SystemRequirement {
        doc /* The dry mass of the tug with maturity contingency shall fit its allocation, and
             * the launch mass shall fit the launcher's performance at the mission C3, each with
             * the system margin of the active margin policy. */
        subject budget : MassBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        require budget.dryCloses;
        require budget.launchCloses;
    }
    requirement <'TS-123'> powerBudgetCloses : SystemRequirement {
        doc /* In every flight mode the array at the target's aphelion at end of life shall
             * supply the tug's demand with the system margin of the active margin policy. */
        subject budget : PowerBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        require budget.earlyOperationsClose;
        require budget.thrustingCloses;
        require budget.coastingCloses;
        require budget.proximityOperationsClose;
        require budget.captureCloses;
        require budget.despinCloses;
        require budget.droHoldCloses;
        require budget.safeCloses;
    }
    requirement <'TS-125'> energyBudgetCloses : SystemRequirement {
        doc /* The batteries shall carry the tug through the longest eclipse and through launch
             * to array deployment within their depth-of-discharge limit, with margin. */
        subject budget : EnergyBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        require budget.eclipseCloses;
        require budget.launchCloses;
    }
    requirement <'TS-126'> inspectorEnergyBudgetCloses : SystemRequirement {
        doc /* Wren's battery shall carry it through the longest solar occultation by the
             * target within its depth-of-discharge limit, with margin. */
        subject budget : InspectorEnergyBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        require budget.closes;
    }
    requirement <'TS-127'> dataBudgetCloses : SystemRequirement {
        doc /* The characterisation data generated per day shall be downlinked each day with
             * margin, and the mass memory shall hold ten days of it. */
        subject budget : DataBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        require budget.downlinkCloses;
        require budget.storageCloses;
    }
    requirement <'TS-130'> propellantBudgetCloses : SystemRequirement {
        doc /* The xenon load less residuals shall cover the Δv of every arc with the heaviest
             * target case attached and the missed-thrust allowance, within the thruster
             * throughput life and the thrusting time the timeline allows, with margin. */
        subject budget : PropellantBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        require budget.xenonClosesLarge;
        require budget.xenonClosesNominal;
        require budget.xenonClosesSmall;
        require budget.tanksHoldLoad;
        require budget.throughputWithinLife;
        require budget.thrustingTimeCloses;
    }
    requirement <'TS-131'> hydrazineBudgetCloses : SystemRequirement {
        doc /* The hydrazine load less residuals shall cover proximity operations, the despin of
             * the heaviest, fastest target case and the attitude control of the stack, with
             * margin. */
        subject budget : HydrazineBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        require budget.closesLarge;
        require budget.closesSmall;
        require budget.tanksHoldLoad;
    }
    requirement <'TS-132'> pointingBudgetCloses : SystemRequirement {
        doc /* The root-sum-square pointing error of the high-gain antenna and of the thrust
             * vector shall each fit its allocation with margin. */
        subject budget : PointingBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        require budget.antennaCloses;
        require budget.thrustVectorCloses;
    }
    requirement <'TS-134'> thermalBudgetCloses : SystemRequirement {
        doc /* The radiators shall reject the hot-case heat with margin, the heaters shall stay
             * within their power allocation in the cold case, and every unit shall stay within
             * its temperature limits in both. */
        subject budget : ThermalBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        require budget.radiatorsClose;
        require budget.heatersClose;
        require budget.unitsWithinLimits;
    }
    requirement <'TS-135'> captureLoadBudgetCloses : SystemRequirement {
        doc /* The capture system shall carry the contact, preload and thrust loads of the
             * heaviest target case with margin. */
        subject budget : CaptureLoadBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        require budget.contactCloses;
        require budget.preloadWithinCapacity;
    }
    requirement <'TS-137'> radiationBudgetCloses : SystemRequirement {
        doc /* Every unit shall be rated to the mission dose times the radiation design margin. */
        subject budget : RadiationBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::unit; stage = VerificationStage::qualification; }
        require budget.allRated;
    }
    requirement <'TS-139'> magneticCleanlinessCloses : SystemRequirement {
        doc /* The sum of the units' magnetic moments shall fit the sensors' allocation with
             * margin. */
        subject budget : MagneticCleanlinessBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::acceptance; }
        require budget.closes;
    }
    requirement <'TS-140'> reliabilityBudgetCloses : SystemRequirement {
        doc /* Mission reliability over the nominal duration shall meet its allocation, and each
             * subsystem its own. */
        subject budget : ReliabilityBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        require budget.missionCloses;
        require budget.subsystemsClose;
    }
    requirement <'TS-142'> processorBudgetCloses : SystemRequirement {
        doc /* Flight computer processor and memory loads shall leave the reserve the software
             * margin policy demands. */
        subject budget : ProcessorBudget;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        require budget.processorCloses;
        require budget.memoryCloses;
    }

    assert satisfy massBudgetCloses by massBudget {
        doc /* The mass budget closes against its requirement. */
    }
    assert satisfy powerBudgetCloses by powerBudget {
        doc /* The power budget closes in every mode against its requirement. */
    }
    assert satisfy energyBudgetCloses by energyBudget {
        doc /* The energy budget closes against its requirement. */
    }
    assert satisfy inspectorEnergyBudgetCloses by inspectorEnergyBudget {
        doc /* Wren's energy budget closes against its requirement. */
    }
    assert satisfy dataBudgetCloses by dataBudget {
        doc /* The data budget closes against its requirement. */
    }
    assert satisfy propellantBudgetCloses by propellantBudget {
        doc /* The xenon and thrusting-time budget closes against its requirement. */
    }
    assert satisfy hydrazineBudgetCloses by hydrazineBudget {
        doc /* The hydrazine budget closes against its requirement. */
    }
    assert satisfy pointingBudgetCloses by pointingBudget {
        doc /* The pointing budget closes against its requirement. */
    }
    assert satisfy thermalBudgetCloses by thermalBudget {
        doc /* The thermal budget closes against its requirement. */
    }
    assert satisfy captureLoadBudgetCloses by captureLoadBudget {
        doc /* The capture load budget closes against its requirement. */
    }
    assert satisfy radiationBudgetCloses by radiationBudget {
        doc /* The radiation budget closes against its requirement. */
    }
    assert satisfy magneticCleanlinessCloses by magneticCleanlinessBudget {
        doc /* The magnetic cleanliness budget closes against its requirement. */
    }
    assert satisfy reliabilityBudgetCloses by reliabilityBudget {
        doc /* The reliability budget closes against its requirement. */
    }
    assert satisfy processorBudgetCloses by processorBudget {
        doc /* The processor budget closes against its requirement. */
    }
}
