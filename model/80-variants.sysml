package TethysVariants {
    doc /* Variants of the Tethys Retrieval architecture and of its target. The target is the
         * design driver: Amaranth's size, density and spin are known only within the envelope
         * of docs/small-body-domain-list.md §7, so the model carries the bounding cases as
         * variants rather than one number. The architecture alternatives of the trade list
         * (array size, thruster count, inspector, launcher) are variations too, and the
         * configuration constraints say which combinations close. Each concrete configuration
         * below is a complete selection that `sysml -instantiate` evaluates and `-validate`
         * judges; TethysBudgets refines the same numbers phase by phase. */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SequenceFunctions::*;
    private import TethysEnvironment::*;
    private import TethysMission::*;
    private import TethysTug::*;
    private import TethysInspector::*;
    private import TethysTarget::*;
    private import TethysLaunch::*;
    private import TethysBudgets::PropellantFor;
    private import TethysBudgets::massBudget;
    private import TethysBudgets::propellantBudget;

    variation part def TargetCase :> SmallBody {
        doc /* The bounding cases of the target envelope. Each case fixes the diameter, bulk
             * density and rotation period; the mass follows from the sphere model of
             * TethysEnvironment so that no case carries an independent mass number. */

        variant part small : SmallBody {
            doc /* Smallest body the survey cannot rule out: a low-density rubble pile that spins
                 * slowly. Cheapest to return, hardest to detect in the capture sensors. */
            attribute :>> meanDiameter = 5.4 [m];
            attribute :>> bulkDensity = 1900.0 ['kg⋅m⁻³'];
            attribute :>> mass = SphereMass(5.4, 1900.0) [kg];
            attribute :>> rotationPeriod = 420.0 [s];
        }

        variant part nominal : SmallBody {
            doc /* The survey's best estimate, equal to TethysEnvironment::amaranth. */
            attribute :>> meanDiameter = amaranth.meanDiameter;
            attribute :>> bulkDensity = amaranth.bulkDensity;
            attribute :>> mass = amaranth.mass;
            attribute :>> rotationPeriod = amaranth.rotationPeriod;
        }

        variant part large : SmallBody {
            doc /* Largest and densest body within the photometric error: near the capture
                 * system's diameter limit and heavy enough to stretch the return propellant. */
            attribute :>> meanDiameter = 8.2 [m];
            attribute :>> bulkDensity = 2800.0 ['kg⋅m⁻³'];
            attribute :>> mass = SphereMass(8.2, 2800.0) [kg];
            attribute :>> rotationPeriod = 180.0 [s];
        }

        variant part fastSpin : SmallBody {
            doc /* The nominal body spinning faster than the grapple can follow: a case the
                 * configuration constraints must reject rather than one the design absorbs. */
            attribute :>> meanDiameter = amaranth.meanDiameter;
            attribute :>> bulkDensity = amaranth.bulkDensity;
            attribute :>> mass = amaranth.mass;
            attribute :>> rotationPeriod = 95.0 [s];
        }
    }

    variation attribute def ArrayPowerChoice :> PowerValue {
        doc /* Solar-array size at 1 AU: the three wing builds of the array trade (domain list
             * §6, T3). */
        variant attribute compact = 30.0 [kW] {
            doc /* Two short wings; lightest array, longest thrust time. */
        }
        variant attribute baseline = 48.0 [kW] {
            doc /* The Argent baseline of TethysTug. */
        }
        variant attribute extended = 70.0 [kW] {
            doc /* Two long wings; buys thrust time back on the large target. */
        }
    }

    variation attribute def ThrusterCountChoice :> Natural {
        doc /* Number of gridded-ion strings fitted, one of which is a cold spare (domain list
             * §6, T11). */
        variant attribute threeStrings = 3 {
            doc /* Two operating plus one spare: the compact-array match. */
        }
        variant attribute fourStrings = 4 {
            doc /* Three operating plus one spare: the Argent baseline. */
        }
        variant attribute fiveStrings = 5 {
            doc /* Four operating plus one spare: the extended-array match. */
        }
    }

    variation attribute def XenonLoadChoice :> MassValue {
        doc /* Xenon loaded at launch. The load sets the return Δv with the body attached and,
             * with the array size, the thrusting time; it is the one knob that answers a heavier
             * target. */
        variant attribute light = 4200.0 [kg] {
            doc /* Enough for the small target with the compact array. */
        }
        variant attribute baseline = 6600.0 [kg] {
            doc /* The Argent baseline of TethysTug. */
        }
        variant attribute heavy = 8400.0 [kg] {
            doc /* The most the tank bay takes without a structural change. */
        }
    }

    variation part def LauncherChoice :> LaunchVehicle {
        doc /* Launch vehicle alternatives, each with its performance to the departure C3 of
             * TethysLaunch (domain list §6, T12). */
        variant part arcturus5H : LaunchVehicle {
            doc /* The TethysLaunch baseline. */
            attribute :>> performanceAtC3 = TethysLaunch::arcturus5H.performanceAtC3;
            attribute :>> characteristicEnergyKm2PerS2 = TethysLaunch::arcturus5H.characteristicEnergyKm2PerS2;
        }
        variant part corvid9 : LaunchVehicle {
            doc /* A smaller two-stage vehicle: cheaper, with less margin over the stack mass. */
            attribute :>> performanceAtC3 = 13400.0 [kg];
            attribute :>> characteristicEnergyKm2PerS2 = TethysLaunch::arcturus5H.characteristicEnergyKm2PerS2;
        }
    }

    abstract part def RetrievalArchitecture {
        doc /* One point of the architecture space: a target case, an array size, a string count,
             * an optional inspector and a launcher, with the derived performance that the
             * configuration constraints judge. Argent's dry mass, xenon load, specific impulse
             * and per-string power are taken from TethysTug and held fixed across variants. */

        part target : TargetCase;
        attribute arrayPower : ArrayPowerChoice;
        attribute thrusterCount : ThrusterCountChoice;
        attribute xenonLoad : XenonLoadChoice;
        part launcher : LauncherChoice;

        variation part inspector : Inspector[0..1] {
            doc /* With or without the free-flying inspector (domain list §6, T6). */
            variant part wrenFreeFlyer : Inspector[1] {
                doc /* The Wren inspector of TethysInspector is carried and released. */
                attribute :>> wetMass = wren.wetMass;
            }
            variant part tugOnly : Inspector[0] {
                doc /* No inspector: the tug characterises the body with its own sensors. */
            }
        }

        attribute operatingThrusters : Natural = thrusterCount - 1 {
            doc /* One string is always the cold spare. */
        }
        attribute powerPerString : PowerValue = argent.sep.maximumPower / argent.sep.operatingThrusters {
            doc /* Argent's per-string input power, 40 kW over three strings. */
        }
        attribute arrayPowerAtTarget : PowerValue = arrayPower * SolarFlux(amaranth.orbit.semiMajorAxisAu) / SolarFlux(1.0) {
            doc /* Array power at the target's heliocentric distance, inverse-square from 1 AU. */
        }
        attribute propulsionPower : PowerValue = operatingThrusters * powerPerString {
            doc /* Power the operating strings draw at full throttle. */
        }
        attribute thrust : ForceValue = SepThrust(propulsionPower.num * 1000.0, argent.sep.specificImpulse.num, 0.65) [N] {
            doc /* Thrust at full throttle from the TethysEnvironment thrust model. */
        }
        attribute exhaustVelocity : SpeedValue = 9.80665 * argent.sep.specificImpulse.num ['m/s'] {
            doc /* Effective exhaust velocity g₀·Isp. */
        }
        attribute tugAloneMass : MassValue = stackMass - massBudget.adapterSeparated {
            doc /* The stack after the adapter separates: what the outbound arc accelerates. */
        }
        attribute outboundXenon : MassValue = PropellantFor(transferBook.deltaVOutbound / 1 ['m/s'], tugAloneMass, argent.sep.specificImpulse) {
            doc /* Xenon the outbound arc of the transfer book (TethysMission::transferBook) spends
                 * on the tug alone, by the rocket equation; no target case changes it. */
        }
        attribute rendezvousXenon : MassValue = PropellantFor(transferBook.deltaVRendezvous / 1 ['m/s'], tugAloneMass - outboundXenon, argent.sep.specificImpulse) {
            doc /* Xenon the rendezvous arc of the transfer book spends. */
        }
        attribute returnXenon : MassValue = xenonLoad * (1.0 - propellantBudget.residualFraction) / (1.0 + transferBook.missedThrustMargin)
            - outboundXenon - rendezvousXenon {
            doc /* Xenon left for the return with the body attached: the load less residuals and the
                 * missed-thrust allowance of the book, less the two arcs flown alone. */
        }
        attribute returnDeltaV : SpeedValue = RocketEquationDeltaV(argent.sep.specificImpulse.num,
            argent.dryMass.num + target.mass.num + returnXenon.num,
            argent.dryMass.num + target.mass.num) ['m/s'] {
            doc /* Δv the return xenon buys with the body attached, by the rocket equation. */
        }
        attribute requiredReturnDeltaV : SpeedValue = transferBook.deltaVRequiredReturn {
            doc /* The return and insertion arcs of the transfer book: low-thrust from the target
                 * orbit to the lunar gravity assist, which returns most of the 493 m/s impulsive
                 * Hohmann floor from 1.034 AU, then into the storage orbit. */
        }
        attribute thrustTime : DurationValue = (xenonLoad.num / (thrust.num / exhaustVelocity.num) / 86400.0) [d] {
            doc /* Total thrusting time to spend the xenon load at full throttle. */
        }
        attribute thrustTimeAllowance : DurationValue = transferBook.thrustingTimeAllowed {
            doc /* Thrusting days the timeline allows, from the transfer book; the rest of the
                 * nominal duration is coast, proximity operations and margin. */
        }
        attribute stackMass : MassValue = argent.dryMass + xenonLoad + argent.rcs.hydrazineMass +
            (if inspector->isEmpty() ? 0.0 [kg] else wren.wetMass) + massBudget.adapterSeparated {
            doc /* Launch mass: dry tug, xenon load, hydrazine, inspector when carried, and the
                 * mass budget's launch adapter. */
        }
        attribute minimumRotationPeriod : DurationValue = 120.0 [s] {
            doc /* Slowest rotation the grapple can follow while closing. */
        }

        assert constraint captureEnvelope {
            doc /* The body fits the capture system. */
            target.meanDiameter <= argent.captureSystem.maximumBodyDiameter and
            target.mass <= argent.captureSystem.maximumBodyMass
        }
        assert constraint spinWithinGrappleRate {
            doc /* The grapple can follow the body's rotation. */
            target.rotationPeriod >= minimumRotationPeriod
        }
        assert constraint powerCloses {
            doc /* The array at the target's distance powers every operating string. */
            arrayPowerAtTarget >= propulsionPower
        }
        assert constraint returnCloses {
            doc /* The return xenon buys the required Δv with the body attached. */
            returnDeltaV >= requiredReturnDeltaV
        }
        assert constraint thrustTimeFits {
            doc /* The xenon can be spent within the thrusting allowance of the mission. */
            thrustTime <= thrustTimeAllowance
        }
        assert constraint launcherLifts {
            doc /* The launcher lifts the stack to the departure C3. */
            stackMass <= launcher.performanceAtC3
        }
        assert constraint stringsMatchArray {
            doc /* String count and array size are matched pairs of the trade list. */
            (arrayPower == arrayPower::compact and thrusterCount == thrusterCount::threeStrings) or
            (arrayPower == arrayPower::baseline and thrusterCount == thrusterCount::fourStrings) or
            (arrayPower == arrayPower::extended and thrusterCount == thrusterCount::fiveStrings)
        }
    }

    part baselineConfiguration : RetrievalArchitecture {
        doc /* The Argent baseline against the nominal target: 48 kW, four strings, 6 600 kg of
             * xenon, Wren carried, Arcturus-5H. Every configuration constraint holds. */
        part :>> target = target::nominal;
        attribute :>> arrayPower = arrayPower::baseline;
        attribute :>> thrusterCount = thrusterCount::fourStrings;
        attribute :>> xenonLoad = xenonLoad::baseline;
        part :>> inspector = inspector::wrenFreeFlyer;
        part :>> launcher = launcher::arcturus5H;
    }

    part smallTargetTugOnly : RetrievalArchitecture {
        doc /* The small target returned by a compact tug without an inspector on the smaller
             * launcher: the low-cost corner of the space. Every configuration constraint holds. */
        part :>> target = target::small;
        attribute :>> arrayPower = arrayPower::compact;
        attribute :>> thrusterCount = thrusterCount::threeStrings;
        attribute :>> xenonLoad = xenonLoad::light;
        part :>> inspector = inspector::tugOnly;
        part :>> launcher = launcher::corvid9;
    }

    part largeTargetStudy : RetrievalArchitecture {
        doc /* The large target with everything the architecture space offers: extended array,
             * five strings, the heavy xenon load, Arcturus-5H. It is expected to fail
             * returnCloses — 7 220 kg of return xenon buys about 250 m/s with an 810 t body
             * attached — which is the envelope's open corner: a body at the top of the
             * photometric error cannot be returned by this tug family, and the survey must
             * close the size before commitment. */
        part :>> target = target::large;
        attribute :>> arrayPower = arrayPower::extended;
        attribute :>> thrusterCount = thrusterCount::fiveStrings;
        attribute :>> xenonLoad = xenonLoad::heavy;
        part :>> inspector = inspector::wrenFreeFlyer;
        part :>> launcher = launcher::arcturus5H;
    }

    part fastSpinStudy : RetrievalArchitecture {
        doc /* The baseline against the fast-spinning nominal body. It is expected to fail
             * spinWithinGrappleRate and nothing else: the case is excluded by the grapple, not
             * by propulsion or launch. */
        part :>> target = target::fastSpin;
        attribute :>> arrayPower = arrayPower::baseline;
        attribute :>> thrusterCount = thrusterCount::fourStrings;
        attribute :>> xenonLoad = xenonLoad::baseline;
        part :>> inspector = inspector::wrenFreeFlyer;
        part :>> launcher = launcher::arcturus5H;
    }

    calc def ReturnDeltaV {
        doc /* Return Δv in m/s the rocket equation gives for a body mass and a return xenon
             * mass in kg, with Argent's dry mass and specific impulse: the number behind
             * returnCloses, callable for any target case. */
        in bodyMassKg : Real;
        in returnXenonKg : Real;
        return : Real = RocketEquationDeltaV(argent.sep.specificImpulse.num,
            argent.dryMass.num + bodyMassKg + returnXenonKg, argent.dryMass.num + bodyMassKg);
    }

    calc def ThrustTimeDays {
        doc /* Days of full-throttle thrusting to spend a xenon load in kg with a number of
             * operating strings at Argent's per-string power: the number behind thrustTimeFits. */
        in xenonKg : Real;
        in operatingStrings : Natural;
        attribute powerW : Real = operatingStrings * argent.sep.maximumPower.num * 1000.0 / argent.sep.operatingThrusters;
        attribute thrustN : Real = SepThrust(powerW, argent.sep.specificImpulse.num, 0.65);
        return : Real = xenonKg / (thrustN / (9.80665 * argent.sep.specificImpulse.num)) / 86400.0;
    }
}
