// Argent down to its units: every subsystem of the backbone Tug refined into the boxes,
// mechanisms, tanks and thrusters that carry the engineering data the budgets roll up —
// mass with maturity, power and duty per mode, heat, temperature limits, failure rate,
// dose rating, magnetic moment, data rate — and the redundancy of each. The functional
// architecture the subsystems perform is here too; the budgets themselves are in
// TethysBudgets.
package TethysTugStructure {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SequenceFunctions::*;
    private import ControlFunctions::collect;
    private import QuantityCalculations::sum;
    private import TethysInterfaces::Heat;
    private import TethysInterfaces::Propellant;
    private import TethysInterfaces::MechanicalLoad;
    private import TethysInterfaces::Telemetry;
    private import TethysInterfaces::RfCarrier;
    private import TethysTug::*;
    private import TethysMarginPolicy::*;

    // ---- modes and the per-mode power model -------------------------------------------------
    enum def TugMode {
        doc /* The power and thermal modes of the tug; TethysModes gives each its state
             * machine, the budgets evaluate every one. */
        enum launch;
        enum earlyOperations;
        enum thrusting;
        enum coasting;
        enum proximityOperations;
        enum capture;
        enum despin;
        enum droHold;
        enum safe;
    }

    attribute allFlightModes : TugMode[*] = (TugMode::earlyOperations, TugMode::thrusting,
        TugMode::coasting, TugMode::proximityOperations, TugMode::capture, TugMode::despin,
        TugMode::droHold, TugMode::safe) {
        doc /* Every mode after separation: the modes a bus unit is powered in. */
    }
    attribute attitudeModes : TugMode[*] = (TugMode::earlyOperations, TugMode::coasting,
        TugMode::proximityOperations, TugMode::capture, TugMode::despin, TugMode::droHold,
        TugMode::safe) {
        doc /* Modes in which the wheels, not the gimballed thrusters, hold attitude. */
    }
    attribute targetModes : TugMode[*] = (TugMode::proximityOperations, TugMode::capture,
        TugMode::despin) {
        doc /* Modes flown within a few hundred metres of the target. */
    }
    attribute heaterModes : TugMode[*] = (TugMode::coasting, TugMode::droHold, TugMode::safe) {
        doc /* Cold modes: no PPU heat, heaters at full survival power. */
    }
    attribute warmModes : TugMode[*] = (TugMode::earlyOperations, TugMode::thrusting,
        TugMode::proximityOperations, TugMode::capture, TugMode::despin) {
        doc /* Modes with internal dissipation enough to keep heaters at trickle power. */
    }

    metadata def Critical {
        doc /* Marks a unit whose loss ends the mission unless a redundant unit takes over;
             * the redundancy budget demands multiplicity two or more, or a waiver. */
    }
    metadata def SinglePointWaiver {
        doc /* Accepts a critical unit flown without a redundant twin, with the reason. */
        attribute rationale : String;
    }

    // ---- the unit: what every box in the tree carries ------------------------------------------
    part def Unit {
        doc /* A unit of the tug: the smallest element the budgets read. Mass is the current
             * best estimate of one unit; the installed count is the multiplicity of the part
             * usage; the powered share says how many of the installed units draw power at
             * once (1 hot, 0.5 for a cold-redundant pair). Temperatures are the unit's
             * operating limits and the hot- and cold-case predictions TethysAnalyses supplies
             * from the thermal model; the failure rate is per unit; the dose rating is the
             * total ionising dose the unit is qualified to. */
        attribute mass : MassValue;
        attribute maturity : Maturity;
        attribute required : Natural;
        attribute poweredShare : Real;
        attribute operatingPower : PowerValue;
        attribute standbyPower : PowerValue;
        attribute operatingModes : TugMode[*];
        attribute standbyModes : TugMode[*];
        attribute heatFraction : Real;
        attribute minOperatingTemperature : ThermodynamicTemperatureValue;
        attribute maxOperatingTemperature : ThermodynamicTemperatureValue;
        attribute predictedHotTemperature : ThermodynamicTemperatureValue;
        attribute predictedColdTemperature : ThermodynamicTemperatureValue;
        attribute failureRate : FrequencyValue;
        attribute doseRating : AbsorbedDoseValue;
        attribute magneticMoment : MagneticMomentValue;
        attribute dataRate : TransferRateValue;
        attribute allocatedMass : MassValue = mass * (1.0 + ContingencyFor(maturity, activePolicy)) {
            doc /* The unit's mass allocation under the active margin policy. */
        }
    }

    part def PassiveUnit :> Unit {
        doc /* A unit that draws no power: structure, blankets, tanks, antennas, the bag. */
        attribute :>> poweredShare default = 0.0;
        attribute :>> operatingPower default = 0 [W];
        attribute :>> standbyPower default = 0 [W];
        attribute :>> operatingModes default = ();
        attribute :>> standbyModes default = ();
        attribute :>> heatFraction default = 0.0;
        attribute :>> minOperatingTemperature default = 150 [K];
        attribute :>> maxOperatingTemperature default = 400 [K];
        attribute :>> doseRating default = 100000 [Gy];
        attribute :>> magneticMoment default = 0.0 ['A⋅m²'];
        attribute :>> dataRate default = 0 ['bit/s'];
    }

    part def ElectronicUnit :> Unit {
        doc /* A powered box: all of its electrical power ends as heat inside it, it runs in
             * every flight mode unless redefined, and it carries the common avionics
             * temperature limits and dose rating. */
        attribute :>> poweredShare default = 1.0;
        attribute :>> standbyPower default = 0 [W];
        attribute :>> operatingModes default = allFlightModes;
        attribute :>> standbyModes default = ();
        attribute :>> heatFraction default = 1.0;
        attribute :>> minOperatingTemperature default = 253 [K];
        attribute :>> maxOperatingTemperature default = 323 [K];
        attribute :>> predictedHotTemperature default = 308 [K];
        attribute :>> predictedColdTemperature default = 268 [K];
        attribute :>> doseRating default = 500 [Gy];
        attribute :>> magneticMoment default = 0.1 ['A⋅m²'];
        attribute :>> dataRate default = 500 ['bit/s'];
    }

    calc def PowerInMode {
        doc /* The electrical power one installed unit draws in a mode: its operating power
             * in a mode it operates in, its standby power in a mode it stands by in, nothing
             * otherwise — scaled by the share of installed units powered at once. */
        in unit : Unit;
        in mode : TugMode;
        return power : PowerValue =
            (if includes(unit.operatingModes, mode) ? unit.operatingPower
             else if includes(unit.standbyModes, mode) ? unit.standbyPower
             else 0 [W]) * unit.poweredShare;
    }

    calc def HeatInMode {
        doc /* The heat one installed unit dissipates inside the tug in a mode. */
        in unit : Unit;
        in mode : TugMode;
        return heat : PowerValue = PowerInMode(unit, mode) * unit.heatFraction;
    }

    calc def UnitsPowerInMode {
        doc /* The electrical power a set of units draws in a mode. */
        in units : Unit[*];
        in mode : TugMode;
        return power : PowerValue = sum(units->collect { in u : Unit; PowerInMode(u, mode) });
    }

    calc def UnitsHeatInMode {
        doc /* The heat a set of units dissipates in a mode. */
        in units : Unit[*];
        in mode : TugMode;
        return heat : PowerValue = sum(units->collect { in u : Unit; HeatInMode(u, mode) });
    }

    part def Assembly :> Subsystem {
        doc /* A subsystem seen as the set of its units: its mass, allocation, power and heat
             * are rollups over them, never typed in. */
        part units : Unit[*];
        attribute :>> mass = sum(units.mass);
        attribute allocatedMass : MassValue = sum(units.allocatedMass);
    }

    // ---- structure and mechanisms ------------------------------------------------------------
    part def PrimaryStructure :> PassiveUnit {
        doc /* Central cylinder, shear panels and the thrust cone that carries the stack load
             * from the capture system into the launcher adapter. */
        attribute :>> mass = 640 [kg];
        attribute :>> maturity = Maturity::newDesign;
        attribute :>> required = 1;
        attribute :>> predictedHotTemperature = 296 [K];
        attribute :>> predictedColdTemperature = 231 [K];
        attribute :>> failureRate = 1.0e-12 [Hz];
        attribute firstLateralMode : FrequencyValue = 11.5 [Hz];
        attribute stowedDiameter : LengthValue = 4.2 [m];
        attribute stowedHeight : LengthValue = 7.9 [m];
    }
    part def LaunchAdapterRing :> PassiveUnit {
        doc /* The 1 666 mm clamp-band ring on the tug side of the launcher interface. */
        attribute :>> mass = 115 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 1;
        attribute :>> predictedHotTemperature = 300 [K];
        attribute :>> predictedColdTemperature = 240 [K];
        attribute :>> failureRate = 2.0e-12 [Hz];
        attribute interfaceDiameter : LengthValue = 1.666 [m];
    }
    part def InspectorDispenser :> ElectronicUnit {
        doc /* The canister that carries Wren to the target and pushes it off at release. */
        attribute :>> mass = 38 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> operatingPower = 12 [W];
        attribute :>> operatingModes = (TugMode::proximityOperations);
        attribute :>> failureRate = 3.0e-11 [Hz];
        attribute separationSpeed : SpeedValue = 0.05 ['m/s'];
    }
    part def DeploymentMechanism :> ElectronicUnit {
        doc /* A motorised hinge-and-latch set that deploys an array wing or a radiator once,
             * early in the mission. */
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> operatingModes = (TugMode::earlyOperations);
        attribute :>> failureRate = 5.0e-11 [Hz];
    }
    part def ArrayDeploymentMechanism :> DeploymentMechanism {
        doc /* Roll-out array deployment boom and motor, one per wing. */
        attribute :>> mass = 46 [kg];
        attribute :>> operatingPower = 60 [W];
    }
    part def RadiatorDeploymentMechanism :> DeploymentMechanism {
        doc /* Hinge set of the two deployable radiator panels. */
        attribute :>> mass = 24 [kg];
        attribute :>> operatingPower = 40 [W];
    }
    part def DockingMechanism :> ElectronicUnit {
        doc /* The androgynous docking ring the visiting vehicle Lantern berths to. */
        attribute :>> mass = 88 [kg];
        attribute :>> maturity = Maturity::newDesign;
        attribute :>> required = 1;
        attribute :>> operatingPower = 50 [W];
        attribute :>> operatingModes = (TugMode::droHold);
        attribute :>> failureRate = 4.0e-11 [Hz];
    }
    part def Harness :> PassiveUnit {
        doc /* Power and data harness, including the high-voltage runs to the PPUs. */
        attribute :>> mass = 185 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> predictedHotTemperature = 310 [K];
        attribute :>> predictedColdTemperature = 250 [K];
        attribute :>> failureRate = 5.0e-12 [Hz];
    }

    part def ArgentStructure :> StructureAndMechanisms, Assembly {
        doc /* The structure and mechanisms subsystem of Argent. */
        #Critical part primaryStructure : PrimaryStructure {
            @SinglePointWaiver { rationale = "primary structure is qualified with a 1.25 factor of safety on the stack load path and is not duplicable"; }
        }
        part launchAdapterRing : LaunchAdapterRing;
        part inspectorDispenser : InspectorDispenser;
        #Critical part arrayDeploymentMechanisms : ArrayDeploymentMechanism[2];
        part radiatorDeploymentMechanism : RadiatorDeploymentMechanism;
        part dockingMechanism : DockingMechanism;
        part harness : Harness;
        part :>> units = (primaryStructure, launchAdapterRing, inspectorDispenser,
            arrayDeploymentMechanisms, radiatorDeploymentMechanism, dockingMechanism, harness);
    }

    // ---- thermal control ----------------------------------------------------------------
    part def InsulationBlankets :> PassiveUnit {
        doc /* Multilayer insulation over the bus and the xenon tanks. */
        attribute :>> mass = 62 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 1;
        attribute :>> predictedHotTemperature = 330 [K];
        attribute :>> predictedColdTemperature = 200 [K];
        attribute :>> failureRate = 1.0e-12 [Hz];
    }
    part def RadiatorPanel :> PassiveUnit {
        doc /* A deployable radiator panel on the pumped loop; two reject the PPU heat. */
        attribute :>> mass = 72 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 2;
        attribute :>> predictedHotTemperature = 318 [K];
        attribute :>> predictedColdTemperature = 215 [K];
        attribute :>> failureRate = 2.0e-12 [Hz];
        attribute area : AreaValue = 7.5 ['m²'];
        attribute emissivity : Real = 0.86;
    }
    part def CoolantPump :> ElectronicUnit {
        doc /* A pump of the mechanically pumped loop that carries PPU heat to the radiators;
             * one runs, the other is a cold spare. */
        attribute :>> mass = 9 [kg];
        attribute :>> maturity = Maturity::newDesign;
        attribute :>> required = 1;
        attribute :>> poweredShare = 0.5;
        attribute :>> operatingPower = 70 [W];
        attribute :>> standbyPower = 20 [W];
        attribute :>> operatingModes = (TugMode::thrusting);
        attribute :>> standbyModes = (TugMode::earlyOperations, TugMode::coasting,
            TugMode::proximityOperations, TugMode::capture, TugMode::despin, TugMode::droHold,
            TugMode::safe);
        attribute :>> failureRate = 8.0e-11 [Hz];
    }
    part def LoopPlumbing :> PassiveUnit {
        doc /* Cold plates, lines and accumulator of the pumped loop. */
        attribute :>> mass = 78 [kg];
        attribute :>> maturity = Maturity::newDesign;
        attribute :>> required = 1;
        attribute :>> predictedHotTemperature = 318 [K];
        attribute :>> predictedColdTemperature = 258 [K];
        attribute :>> failureRate = 6.0e-12 [Hz];
    }
    part def HeaterSet :> ElectronicUnit {
        doc /* Survival and operational heaters on tanks, lines, mechanisms and the bag;
             * full power in the cold modes, trickle power when the bus dissipates enough. */
        attribute :>> mass = 36 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 1;
        attribute :>> operatingPower = 260 [W];
        attribute :>> standbyPower = 90 [W];
        attribute :>> operatingModes = heaterModes;
        attribute :>> standbyModes = warmModes;
        attribute :>> failureRate = 1.0e-11 [Hz];
    }
    part def ThermalSensors :> ElectronicUnit {
        doc /* Thermistors, thermostats and the heater switching electronics. */
        attribute :>> mass = 8 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 1;
        attribute :>> operatingPower = 3 [W];
        attribute :>> failureRate = 1.0e-11 [Hz];
    }

    part def ArgentThermal :> ThermalControl, Assembly {
        doc /* The thermal control subsystem of Argent. */
        part insulation : InsulationBlankets;
        part radiators : RadiatorPanel[2];
        #Critical part coolantPumps : CoolantPump[2];
        part loopPlumbing : LoopPlumbing;
        part heaters : HeaterSet;
        part sensors : ThermalSensors;
        part :>> units = (insulation, radiators, coolantPumps, loopPlumbing, heaters, sensors);
        attribute radiatorArea : AreaValue = sum(radiators.area);
    }

    // ---- electrical power ----------------------------------------------------------------
    part def SolarArrayWing :> PassiveUnit {
        doc /* A roll-out solar array wing: 24 kW at 1 AU and 1361 W/m² at beginning of life. */
        attribute :>> mass = 415 [kg];
        attribute :>> maturity = Maturity::newDesign;
        attribute :>> required = 2;
        attribute :>> predictedHotTemperature = 355 [K];
        attribute :>> predictedColdTemperature = 180 [K];
        attribute :>> failureRate = 3.0e-12 [Hz];
        attribute ratedPowerAtOneAu : PowerValue = 24 [kW];
        attribute deployedArea : AreaValue = 78 ['m²'];
        attribute endOfLifeFactor : Real = 0.94;
    }
    part def ArrayDriveMechanism :> ElectronicUnit {
        doc /* The single-axis drive and slip-ring assembly of one wing. */
        attribute :>> mass = 29 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 2;
        attribute :>> operatingPower = 15 [W];
        attribute :>> failureRate = 4.0e-11 [Hz];
    }
    part def Battery :> PassiveUnit {
        doc /* A lithium-ion battery string; two strings share the eclipse and peak loads. */
        attribute :>> mass = 52 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> minOperatingTemperature = 273 [K];
        attribute :>> maxOperatingTemperature = 308 [K];
        attribute :>> predictedHotTemperature = 301 [K];
        attribute :>> predictedColdTemperature = 281 [K];
        attribute :>> failureRate = 3.0e-11 [Hz];
        attribute capacity : EnergyValue = 7200 ['W⋅h'];
        attribute maximumDepthOfDischarge : Real = 0.6;
    }
    part def PowerConditioningUnit :> ElectronicUnit {
        doc /* The 28 V bus regulator, battery charge control and low-voltage distribution. */
        attribute :>> mass = 47 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 1;
        attribute :>> operatingPower = 65 [W];
        attribute :>> failureRate = 6.0e-11 [Hz];
        attribute busVoltage : ElectricPotentialValue = 28 [V];
    }
    part def HighVoltageSwitchUnit :> ElectronicUnit {
        doc /* Routes the array's high-voltage sections to the PPUs and cross-straps them. */
        attribute :>> mass = 56 [kg];
        attribute :>> maturity = Maturity::newDesign;
        attribute :>> required = 1;
        attribute :>> operatingPower = 90 [W];
        attribute :>> standbyPower = 10 [W];
        attribute :>> operatingModes = (TugMode::thrusting);
        attribute :>> standbyModes = attitudeModes;
        attribute :>> failureRate = 7.0e-11 [Hz];
        attribute busVoltage : ElectricPotentialValue = 300 [V];
    }

    part def ArgentPower :> TethysTug::ElectricalPowerSystem, Assembly {
        doc /* The electrical power subsystem of Argent. */
        #Critical part arrayWings : SolarArrayWing[2];
        #Critical part arrayDrives : ArrayDriveMechanism[2];
        #Critical part batteries : Battery[2];
        #Critical part powerConditioning : PowerConditioningUnit {
            @SinglePointWaiver { rationale = "internally redundant regulators, chargers and switches on a single backplane"; }
        }
        #Critical part highVoltageSwitching : HighVoltageSwitchUnit {
            @SinglePointWaiver { rationale = "dual relay matrix; any one PPU reachable from either array section"; }
        }
        part :>> units = (arrayWings, arrayDrives, batteries, powerConditioning, highVoltageSwitching);
        attribute :>> arrayPowerAtOneAu = sum(arrayWings.ratedPowerAtOneAu);
        attribute batteryCapacity : EnergyValue = sum(batteries.capacity);
    }

    // ---- command and data handling ------------------------------------------------------------
    part def FlightComputer :> ElectronicUnit {
        doc /* A flight computer: one runs, the other is a cold spare taking over on a
             * watchdog trip. Processor and memory capacities carry the software margins. */
        attribute :>> mass = 11 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 1;
        attribute :>> poweredShare = 0.5;
        attribute :>> operatingPower = 42 [W];
        attribute :>> doseRating = 1000 [Gy];
        attribute :>> failureRate = 9.0e-11 [Hz];
        attribute :>> dataRate = 4000 ['bit/s'];
        attribute processorCapacityMips : Real = 1200.0;
        attribute processorLoadMips : Real = 560.0;
        attribute memoryCapacity : StorageCapacityValue = 4.0e9 [B];
        attribute memoryAllocated : StorageCapacityValue = 1.9e9 [B];
    }
    part def MassMemory :> ElectronicUnit {
        doc /* Solid-state recorder for characterisation imagery and lidar data. */
        attribute :>> mass = 6 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> poweredShare = 0.5;
        attribute :>> operatingPower = 18 [W];
        attribute :>> failureRate = 5.0e-11 [Hz];
        attribute storageCapacity : StorageCapacityValue = 2.0e12 [B];
    }
    part def RemoteInterfaceUnit :> ElectronicUnit {
        doc /* Bus remote terminal gathering thermistors, valve drives and mechanism telemetry. */
        attribute :>> mass = 7 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 1;
        attribute :>> operatingPower = 14 [W];
        attribute :>> failureRate = 4.0e-11 [Hz];
        attribute :>> dataRate = 2000 ['bit/s'];
    }

    part def ArgentAvionics :> CommandAndDataHandling, Assembly {
        doc /* The command and data handling subsystem of Argent. */
        #Critical part flightComputers : FlightComputer[2];
        #Critical part massMemories : MassMemory[2];
        #Critical part remoteInterfaceUnits : RemoteInterfaceUnit[2];
        part :>> units = (flightComputers, massMemories, remoteInterfaceUnits);
        attribute storageCapacity : StorageCapacityValue = sum(massMemories.storageCapacity);
    }

    // ---- telecommunications -------------------------------------------------------------
    part def DeepSpaceTransponder :> ElectronicUnit {
        doc /* X-band up / X- and Ka-band down transponder with ranging; one hot, one cold. */
        attribute :>> mass = 4.2 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 1;
        attribute :>> poweredShare = 0.5;
        attribute :>> operatingPower = 32 [W];
        attribute :>> failureRate = 6.0e-11 [Hz];
        attribute downlinkFrequency : FrequencyValue = 32.0e9 [Hz];
    }
    part def TravellingWaveTubeAmplifier :> ElectronicUnit {
        doc /* Ka-band power amplifier: 120 W in, 70 W of RF out, the rest heat. */
        attribute :>> mass = 3.8 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 1;
        attribute :>> poweredShare = 0.5;
        attribute :>> operatingPower = 120 [W];
        attribute :>> heatFraction = 0.42;
        attribute :>> failureRate = 7.0e-11 [Hz];
        attribute radioFrequencyPower : PowerValue = 70 [W];
    }
    part def HighGainAntenna :> PassiveUnit {
        doc /* The 1.8 m gimballed high-gain reflector. */
        attribute :>> mass = 28 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> predictedHotTemperature = 340 [K];
        attribute :>> predictedColdTemperature = 190 [K];
        attribute :>> failureRate = 2.0e-12 [Hz];
        attribute diameter : LengthValue = 1.8 [m];
        attribute gainDb : Real = 53.5;
    }
    part def AntennaPointingMechanism :> ElectronicUnit {
        doc /* Two-axis gimbal that keeps the high-gain antenna on Earth while the arrays
             * track the Sun. */
        attribute :>> mass = 12 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> operatingPower = 10 [W];
        attribute :>> failureRate = 5.0e-11 [Hz];
    }
    part def LowGainAntenna :> PassiveUnit {
        doc /* Hemispherical X-band antenna for early operations and safe mode. */
        attribute :>> mass = 1.5 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 1;
        attribute :>> predictedHotTemperature = 340 [K];
        attribute :>> predictedColdTemperature = 190 [K];
        attribute :>> failureRate = 1.0e-12 [Hz];
        attribute gainDb : Real = 6.0;
    }
    part def ProximityTransceiver :> ElectronicUnit {
        doc /* UHF transceiver of the Wren relay link. */
        attribute :>> mass = 2.6 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> poweredShare = 0.5;
        attribute :>> operatingPower = 15 [W];
        attribute :>> operatingModes = targetModes;
        attribute :>> failureRate = 5.0e-11 [Hz];
        attribute relayDataRate : TransferRateValue = 2.0e6 ['bit/s'];
    }

    part def ArgentTelecom :> Telecommunications, Assembly {
        doc /* The telecommunications subsystem of Argent. */
        #Critical part transponders : DeepSpaceTransponder[2];
        #Critical part amplifiers : TravellingWaveTubeAmplifier[2];
        part highGainAntenna : HighGainAntenna;
        part antennaPointing : AntennaPointingMechanism;
        #Critical part lowGainAntennas : LowGainAntenna[2];
        part proximityTransceivers : ProximityTransceiver[2];
        part :>> units = (transponders, amplifiers, highGainAntenna, antennaPointing,
            lowGainAntennas, proximityTransceivers);
    }

    // ---- guidance, navigation and control --------------------------------------------------
    part def StarTracker :> ElectronicUnit {
        doc /* Autonomous star tracker head and electronics; both run, one suffices. */
        attribute :>> mass = 3.1 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 1;
        attribute :>> operatingPower = 9 [W];
        attribute :>> failureRate = 4.0e-11 [Hz];
        attribute attitudeKnowledgeError : AngularMeasureValue = 0.0010 ['°'];
    }
    part def InertialMeasurementUnit :> ElectronicUnit {
        doc /* Fibre-optic gyro and accelerometer package; one hot, one cold. */
        attribute :>> mass = 4.4 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 1;
        attribute :>> poweredShare = 0.5;
        attribute :>> operatingPower = 22 [W];
        attribute :>> failureRate = 6.0e-11 [Hz];
    }
    part def SunSensor :> ElectronicUnit {
        doc /* Coarse sun sensor for safe-mode Sun acquisition. */
        attribute :>> mass = 0.3 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 2;
        attribute :>> operatingPower = 0.5 [W];
        attribute :>> failureRate = 1.0e-11 [Hz];
    }
    part def ReactionWheel :> ElectronicUnit {
        doc /* Momentum wheel sized for the tug alone; the stack is controlled by the RCS. */
        attribute :>> mass = 9.5 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 3;
        attribute :>> operatingPower = 25 [W];
        attribute :>> standbyPower = 5 [W];
        attribute :>> operatingModes = attitudeModes;
        attribute :>> standbyModes = (TugMode::thrusting);
        attribute :>> failureRate = 1.2e-11 [Hz];
        attribute :>> magneticMoment = 0.4 ['A⋅m²'];
        attribute momentumCapacity : AngularMomentumValue = 75 ['N⋅m⋅s'];
        attribute maximumTorque : TorqueValue = 0.2 ['N⋅m'];
    }
    part def NavigationCamera :> ElectronicUnit {
        doc /* Relative-navigation camera for approach, station-keeping and capture. */
        attribute :>> mass = 2.8 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> operatingPower = 11 [W];
        attribute :>> operatingModes = (TugMode::coasting, TugMode::proximityOperations,
            TugMode::capture, TugMode::despin);
        attribute :>> failureRate = 5.0e-11 [Hz];
        attribute :>> dataRate = 8.0e6 ['bit/s'];
        attribute fieldOfView : AngularMeasureValue = 20.0 ['°'];
        attribute pointingKnowledgeError : AngularMeasureValue = 0.0050 ['°'];
    }
    part def Lidar :> ElectronicUnit {
        doc /* Scanning lidar for range and shape from 5 km to contact. */
        attribute :>> mass = 7.5 [kg];
        attribute :>> maturity = Maturity::newDesign;
        attribute :>> required = 1;
        attribute :>> poweredShare = 0.5;
        attribute :>> operatingPower = 45 [W];
        attribute :>> operatingModes = (TugMode::proximityOperations, TugMode::capture);
        attribute :>> failureRate = 9.0e-11 [Hz];
        attribute :>> dataRate = 1.2e6 ['bit/s'];
        attribute maximumRange : LengthValue = 5000 [m];
        attribute rangeAccuracy : LengthValue = 0.02 [m];
    }

    part def ArgentGnc :> GuidanceNavigationControl, Assembly {
        doc /* The guidance, navigation and control subsystem of Argent. */
        #Critical part starTrackers : StarTracker[2];
        #Critical part inertialUnits : InertialMeasurementUnit[2];
        #Critical part sunSensors : SunSensor[4];
        #Critical part reactionWheels : ReactionWheel[4];
        #Critical part navigationCameras : NavigationCamera[2];
        #Critical part lidars : Lidar[2];
        part :>> units = (starTrackers, inertialUnits, sunSensors, reactionWheels,
            navigationCameras, lidars);
    }

    // ---- solar electric propulsion ------------------------------------------------------------
    part def HallThruster :> ElectronicUnit {
        doc /* A Hall-effect thruster: 11 kW at the cruise throttle point used for the power
             * budget, 13.4 kW at full power, three of four firing; most of its power leaves in
             * the beam, eight percent heats the thruster body. */
        attribute :>> mass = 14.5 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 3;
        attribute :>> poweredShare = 0.75;
        attribute :>> operatingPower = 11 [kW];
        attribute :>> operatingModes = (TugMode::thrusting);
        attribute :>> heatFraction = 0.08;
        attribute :>> minOperatingTemperature = 200 [K];
        attribute :>> maxOperatingTemperature = 600 [K];
        attribute :>> predictedHotTemperature = 540 [K];
        attribute :>> predictedColdTemperature = 215 [K];
        attribute :>> failureRate = 1.5e-11 [Hz];
        attribute :>> magneticMoment = 2.5 ['A⋅m²'];
        attribute maximumPower : PowerValue = 13.4 [kW];
        attribute specificImpulse : DurationValue = 2900 [s];
        attribute efficiency : Real = 0.65;
        attribute xenonThroughputLife : MassValue = 3500 [kg];
        attribute minimumThrottlePower : PowerValue = 4 [kW];
    }
    part def PowerProcessingUnit :> ElectronicUnit {
        doc /* The power processing unit of one thruster: 95 % efficient, so its own draw is
             * the five percent it turns into heat on the pumped loop. */
        attribute :>> mass = 22 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 3;
        attribute :>> poweredShare = 0.75;
        attribute :>> operatingPower = 580 [W];
        attribute :>> operatingModes = (TugMode::thrusting);
        attribute :>> failureRate = 1.0e-11 [Hz];
        attribute efficiency : Real = 0.95;
    }
    part def XenonTank :> PassiveUnit {
        doc /* A composite-overwrapped tank storing supercritical xenon. */
        attribute :>> mass = 84 [kg];
        attribute :>> maturity = Maturity::newDesign;
        attribute :>> required = 2;
        attribute :>> minOperatingTemperature = 288 [K];
        attribute :>> maxOperatingTemperature = 323 [K];
        attribute :>> predictedHotTemperature = 311 [K];
        attribute :>> predictedColdTemperature = 291 [K];
        attribute :>> failureRate = 4.0e-12 [Hz];
        attribute capacity : MassValue = 3400 [kg];
        attribute volume : VolumeValue = 2.15 ['m³'];
        attribute maximumOperatingPressure : PressureValue = 12.0e6 [Pa];
    }
    part def XenonFlowController :> ElectronicUnit {
        doc /* Proportional flow control valves and pressure transducers of one thruster. */
        attribute :>> mass = 3.2 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 3;
        attribute :>> poweredShare = 0.75;
        attribute :>> operatingPower = 8 [W];
        attribute :>> operatingModes = (TugMode::thrusting);
        attribute :>> failureRate = 3.0e-11 [Hz];
    }
    part def ThrusterGimbal :> ElectronicUnit {
        doc /* Two-axis gimbal steering one thruster through the moving centre of mass of the
             * stack. */
        attribute :>> mass = 9 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 3;
        attribute :>> poweredShare = 0.75;
        attribute :>> operatingPower = 12 [W];
        attribute :>> operatingModes = (TugMode::thrusting);
        attribute :>> failureRate = 6.0e-11 [Hz];
        attribute range : AngularMeasureValue = 15.0 ['°'];
    }
    part def PropellantManagementAssembly :> ElectronicUnit {
        doc /* Regulators, latch valves and the tank heaters' controller of the xenon feed. */
        attribute :>> mass = 18 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> operatingPower = 6 [W];
        attribute :>> operatingModes = (TugMode::thrusting);
        attribute :>> failureRate = 3.0e-11 [Hz];
    }

    part def ArgentPropulsion :> SolarElectricPropulsion, Assembly {
        doc /* The solar electric propulsion subsystem of Argent. */
        #Critical part thrusters : HallThruster[4];
        #Critical part powerProcessingUnits : PowerProcessingUnit[4];
        #Critical part xenonTanks : XenonTank[2];
        #Critical part flowControllers : XenonFlowController[4];
        #Critical part gimbals : ThrusterGimbal[4];
        #Critical part propellantManagement : PropellantManagementAssembly {
            @SinglePointWaiver { rationale = "parallel-redundant regulators and latch valves within one assembly"; }
        }
        part :>> units = (thrusters, powerProcessingUnits, xenonTanks, flowControllers, gimbals,
            propellantManagement);
        attribute :>> thrusterCount = size(thrusters);
        attribute :>> operatingThrusters = head(thrusters.required);
        attribute :>> specificImpulse = head(thrusters.specificImpulse);
        attribute :>> maximumPower = sum(thrusters.maximumPower) * head(thrusters.poweredShare);
        attribute xenonCapacity : MassValue = sum(xenonTanks.capacity);
    }

    // ---- reaction control ----------------------------------------------------------------
    part def HydrazineThruster :> ElectronicUnit {
        doc /* A 22 N monopropellant thruster; sixteen in four pods give six-axis control of
             * the stack and the despin torque. */
        attribute :>> mass = 0.9 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 8;
        attribute :>> operatingPower = 10 [W];
        attribute :>> standbyPower = 3 [W];
        attribute :>> operatingModes = targetModes;
        attribute :>> standbyModes = (TugMode::earlyOperations, TugMode::thrusting,
            TugMode::coasting, TugMode::droHold, TugMode::safe);
        attribute :>> minOperatingTemperature = 280 [K];
        attribute :>> maxOperatingTemperature = 400 [K];
        attribute :>> predictedHotTemperature = 330 [K];
        attribute :>> predictedColdTemperature = 283 [K];
        attribute :>> failureRate = 2.0e-11 [Hz];
        attribute thrust : ForceValue = 22 [N];
        attribute specificImpulse : DurationValue = 225 [s];
        attribute momentArm : LengthValue = 3.2 [m];
    }
    part def HydrazineTank :> PassiveUnit {
        doc /* A diaphragm hydrazine tank. */
        attribute :>> mass = 21 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 2;
        attribute :>> minOperatingTemperature = 283 [K];
        attribute :>> maxOperatingTemperature = 323 [K];
        attribute :>> predictedHotTemperature = 305 [K];
        attribute :>> predictedColdTemperature = 288 [K];
        attribute :>> failureRate = 3.0e-12 [Hz];
        attribute capacity : MassValue = 210 [kg];
    }
    part def RcsFeedAssembly :> ElectronicUnit {
        doc /* Latch valves, filters, pressure transducers and lines of the hydrazine feed. */
        attribute :>> mass = 14 [kg];
        attribute :>> maturity = Maturity::heritage;
        attribute :>> required = 1;
        attribute :>> operatingPower = 4 [W];
        attribute :>> failureRate = 2.0e-11 [Hz];
    }

    part def ArgentReactionControl :> ReactionControl, Assembly {
        doc /* The hydrazine reaction control subsystem of Argent. */
        #Critical part thrusters : HydrazineThruster[16];
        #Critical part tanks : HydrazineTank[2];
        #Critical part feed : RcsFeedAssembly {
            @SinglePointWaiver { rationale = "dual-branch feed with cross-latch valves in one assembly"; }
        }
        part :>> units = (thrusters, tanks, feed);
        attribute hydrazineCapacity : MassValue = sum(tanks.capacity);
    }

    // ---- capture system ----------------------------------------------------------------
    part def CaptureBag :> PassiveUnit {
        doc /* The inflatable capture bag: a 10 m envelope of layered fabric with cinch lines
             * at its mouth and a load path into the booms. */
        attribute :>> mass = 210 [kg];
        attribute :>> maturity = Maturity::newDesign;
        attribute :>> required = 1;
        attribute :>> minOperatingTemperature = 200 [K];
        attribute :>> maxOperatingTemperature = 350 [K];
        attribute :>> predictedHotTemperature = 318 [K];
        attribute :>> predictedColdTemperature = 230 [K];
        attribute :>> failureRate = 1.0e-11 [Hz];
        attribute maximumBodyDiameter : LengthValue = 10.0 [m];
        attribute cinchLoadCapacity : ForceValue = 20000 [N];
        attribute contactPressureLimit : PressureValue = 2000 [Pa];
    }
    part def InflatableBoom :> PassiveUnit {
        doc /* A rigidising inflatable boom; six hold the bag open, five suffice. */
        attribute :>> mass = 24 [kg];
        attribute :>> maturity = Maturity::newDesign;
        attribute :>> required = 5;
        attribute :>> predictedHotTemperature = 330 [K];
        attribute :>> predictedColdTemperature = 210 [K];
        attribute :>> failureRate = 8.0e-12 [Hz];
        attribute length : LengthValue = 12 [m];
    }
    part def CinchWinch :> ElectronicUnit {
        doc /* A motorised winch that closes the bag mouth and preloads the body against the
             * booms. */
        attribute :>> mass = 16 [kg];
        attribute :>> maturity = Maturity::newDesign;
        attribute :>> required = 2;
        attribute :>> operatingPower = 180 [W];
        attribute :>> operatingModes = (TugMode::capture);
        attribute :>> failureRate = 7.0e-11 [Hz];
        attribute lineTension : ForceValue = 5000 [N];
    }
    part def InflationSystem :> ElectronicUnit {
        doc /* Nitrogen bottles, regulators and valves that inflate the booms. */
        attribute :>> mass = 32 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> operatingPower = 25 [W];
        attribute :>> operatingModes = (TugMode::capture);
        attribute :>> failureRate = 4.0e-11 [Hz];
    }
    part def ContactSensorSet :> ElectronicUnit {
        doc /* Load cells and proximity sensors in the booms and the bag mouth. */
        attribute :>> mass = 6 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> operatingPower = 8 [W];
        attribute :>> operatingModes = targetModes;
        attribute :>> failureRate = 3.0e-11 [Hz];
        attribute :>> dataRate = 20000 ['bit/s'];
    }
    part def BagReleaseMechanism :> ElectronicUnit {
        doc /* Pyrotechnic line cutters that free the body for the visiting vehicle at the end
             * of the mission. */
        attribute :>> mass = 11 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> operatingPower = 15 [W];
        attribute :>> operatingModes = (TugMode::droHold);
        attribute :>> failureRate = 2.0e-11 [Hz];
    }

    part def ArgentCapture :> CaptureSystem, Assembly {
        doc /* The capture system of Argent. */
        #Critical part bag : CaptureBag {
            @SinglePointWaiver { rationale = "a second bag is not carriable; the risk is retired by the Wren characterisation before the capture commit"; }
        }
        #Critical part booms : InflatableBoom[6];
        #Critical part winches : CinchWinch[3];
        #Critical part inflation : InflationSystem {
            @SinglePointWaiver { rationale = "two bottles and redundant valves within one assembly"; }
        }
        part contactSensors : ContactSensorSet;
        part release : BagReleaseMechanism;
        part :>> units = (bag, booms, winches, inflation, contactSensors, release);
        attribute :>> maximumBodyDiameter = bag.maximumBodyDiameter;
    }

    // ---- characterisation sensors -----------------------------------------------------------
    part def NarrowAngleCamera :> ElectronicUnit {
        doc /* Long-focal-length imager for approach detection and the shape model. */
        attribute :>> mass = 6.4 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> operatingPower = 14 [W];
        attribute :>> operatingModes = (TugMode::coasting, TugMode::proximityOperations,
            TugMode::capture);
        attribute :>> failureRate = 5.0e-11 [Hz];
        attribute :>> dataRate = 6.0e6 ['bit/s'];
        attribute fieldOfView : AngularMeasureValue = 1.5 ['°'];
    }
    part def WideAngleCamera :> ElectronicUnit {
        doc /* Context imager for the final approach and the bag mouth. */
        attribute :>> mass = 2.1 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> operatingPower = 6 [W];
        attribute :>> operatingModes = targetModes;
        attribute :>> failureRate = 4.0e-11 [Hz];
        attribute :>> dataRate = 3.0e6 ['bit/s'];
        attribute fieldOfView : AngularMeasureValue = 45.0 ['°'];
    }
    part def ThermalImager :> ElectronicUnit {
        doc /* Thermal-infrared imager for the surface temperature and thermal inertia. */
        attribute :>> mass = 4.8 [kg];
        attribute :>> maturity = Maturity::modified;
        attribute :>> required = 1;
        attribute :>> operatingPower = 12 [W];
        attribute :>> operatingModes = targetModes;
        attribute :>> failureRate = 5.0e-11 [Hz];
        attribute :>> dataRate = 1.0e6 ['bit/s'];
        attribute fieldOfView : AngularMeasureValue = 10.0 ['°'];
    }

    part def ArgentSensors :> CharacterisationSensors, Assembly {
        doc /* The tug's own characterisation sensors; Wren carries the second suite. */
        part narrowAngleCamera : NarrowAngleCamera;
        part wideAngleCamera : WideAngleCamera;
        part thermalImager : ThermalImager;
        part :>> units = (narrowAngleCamera, wideAngleCamera, thermalImager);
    }

    // ---- functional architecture -----------------------------------------------------------
    item def ThrustCommand {
        doc /* The thrust vector and throttle the guidance function asks of propulsion. */
        attribute throttle : Real;
    }
    item def AttitudeEstimate {
        doc /* The attitude and rate estimate navigation hands to control. */
        attribute knowledgeError : AngularMeasureValue;
    }
    item def RelativeState {
        doc /* Range, bearing and rate to the target from the relative-navigation sensors. */
        attribute range : LengthValue;
    }
    item def CharacterisationData {
        doc /* Imagery, lidar and thermal data of the target bound for the ground. */
        attribute volume : StorageCapacityValue;
    }

    action def ProvidePower {
        doc /* Convert sunlight to regulated low-voltage and unregulated high-voltage power. */
        out lowVoltage : TethysInterfaces::ElectricalPower;
        out highVoltage : TethysInterfaces::ElectricalPower;
    }
    action def ProcessPower {
        doc /* Condition array power into the discharge and magnet supplies of a thruster. */
        in highVoltage : TethysInterfaces::ElectricalPower;
        in command : ThrustCommand;
        out thrusterPower : TethysInterfaces::ElectricalPower;
        out loss : Heat;
    }
    action def GenerateThrust {
        doc /* Accelerate xenon to produce the commanded thrust. */
        in thrusterPower : TethysInterfaces::ElectricalPower;
        in xenon : Propellant;
        out thrust : MechanicalLoad;
        out heat : Heat;
    }
    action def FeedXenon {
        doc /* Regulate and meter xenon from the tanks to the firing thrusters. */
        out xenon : Propellant;
    }
    action def DetermineAttitude {
        doc /* Fuse star tracker, gyro and sun sensor data into an attitude estimate. */
        out attitude : AttitudeEstimate;
    }
    action def ControlAttitude {
        doc /* Hold or slew the tug, and the stack, with wheels, gimbals or hydrazine. */
        in attitude : AttitudeEstimate;
        in lowVoltage : TethysInterfaces::ElectricalPower;
        out thrustCommand : ThrustCommand;
    }
    action def NavigateRelative {
        doc /* Measure range, bearing and rate to the target from cameras and lidar. */
        in lowVoltage : TethysInterfaces::ElectricalPower;
        out relativeState : RelativeState;
    }
    action def CaptureBody {
        doc /* Deploy the bag, close it around the body and preload it against the booms. */
        in relativeState : RelativeState;
        in lowVoltage : TethysInterfaces::ElectricalPower;
        out contactLoad : MechanicalLoad;
    }
    action def DespinBody {
        doc /* Remove the stack's angular momentum with the hydrazine thrusters. */
        in attitude : AttitudeEstimate;
        in hydrazine : Propellant;
    }
    action def CharacteriseTarget {
        doc /* Image and sound the target and deliver the products to mass memory. */
        in lowVoltage : TethysInterfaces::ElectricalPower;
        out products : CharacterisationData;
    }
    action def HandleData {
        doc /* Execute the flight software, store products and frame telemetry. */
        in products : CharacterisationData;
        in lowVoltage : TethysInterfaces::ElectricalPower;
        out telemetry : Telemetry;
    }
    action def Communicate {
        doc /* Radiate telemetry to the Meridian network and receive commands. */
        in telemetry : Telemetry;
        in lowVoltage : TethysInterfaces::ElectricalPower;
        out carrier : RfCarrier;
    }
    action def RejectHeat {
        doc /* Carry PPU and bus heat to the radiators and keep every unit in its limits. */
        in loss : Heat;
        in heat : Heat;
        in lowVoltage : TethysInterfaces::ElectricalPower;
    }

    action def TugFunctions {
        doc /* The functional architecture of the tug: thirteen functions and the items that
             * flow between them. Each is performed by exactly one subsystem of ArgentTug. */
        action providePower : ProvidePower;
        action processPower : ProcessPower;
        action generateThrust : GenerateThrust;
        action feedXenon : FeedXenon;
        action determineAttitude : DetermineAttitude;
        action controlAttitude : ControlAttitude;
        action navigateRelative : NavigateRelative;
        action captureBody : CaptureBody;
        action despinBody : DespinBody;
        action characteriseTarget : CharacteriseTarget;
        action handleData : HandleData;
        action communicate : Communicate;
        action rejectHeat : RejectHeat;

        flow providePower.highVoltage to processPower.highVoltage;
        flow providePower.lowVoltage to controlAttitude.lowVoltage;
        flow providePower.lowVoltage to navigateRelative.lowVoltage;
        flow providePower.lowVoltage to captureBody.lowVoltage;
        flow providePower.lowVoltage to characteriseTarget.lowVoltage;
        flow providePower.lowVoltage to handleData.lowVoltage;
        flow providePower.lowVoltage to communicate.lowVoltage;
        flow providePower.lowVoltage to rejectHeat.lowVoltage;
        flow controlAttitude.thrustCommand to processPower.command;
        flow processPower.thrusterPower to generateThrust.thrusterPower;
        flow feedXenon.xenon to generateThrust.xenon;
        flow processPower.loss to rejectHeat.loss;
        flow generateThrust.heat to rejectHeat.heat;
        flow determineAttitude.attitude to controlAttitude.attitude;
        flow determineAttitude.attitude to despinBody.attitude;
        flow navigateRelative.relativeState to captureBody.relativeState;
        flow characteriseTarget.products to handleData.products;
        flow handleData.telemetry to communicate.telemetry;
    }

    // ---- the tug as designed --------------------------------------------------------------
    part def ArgentTug :> Tug {
        doc /* Argent with every subsystem refined to its units, the functions each performs,
             * and the typed flows on the backbone interfaces. Dry mass is the rollup over the
             * subsystems; the backbone's typed-in value is the allocation it is compared to. */
        part :>> structure : ArgentStructure {
            perform functions.captureBody;
        }
        part :>> thermal : ArgentThermal {
            perform functions.rejectHeat;
        }
        part :>> eps : ArgentPower {
            perform functions.providePower;
        }
        part :>> cdh : ArgentAvionics {
            perform functions.handleData;
        }
        part :>> telecom : ArgentTelecom {
            perform functions.communicate;
        }
        part :>> gnc : ArgentGnc {
            perform functions.determineAttitude;
            perform functions.controlAttitude;
            perform functions.navigateRelative;
        }
        part :>> sep : ArgentPropulsion {
            perform functions.processPower;
            perform functions.generateThrust;
            perform functions.feedXenon;
        }
        part :>> rcs : ArgentReactionControl {
            perform functions.despinBody;
        }
        part :>> captureSystem : ArgentCapture;
        part :>> sensors : ArgentSensors {
            perform functions.characteriseTarget;
        }
        part subsystems : Assembly[*] = (structure, thermal, eps, cdh, telecom, gnc, sep, rcs,
            captureSystem, sensors);
        part units : Unit[*] = (structure.units, thermal.units, eps.units, cdh.units,
            telecom.units, gnc.units, sep.units, rcs.units, captureSystem.units, sensors.units);
        perform action functions : TugFunctions;

        attribute dryMassEstimate : MassValue = sum(subsystems.mass) {
            doc /* Current best estimate of the dry mass: the sum of every unit. */
        }
        attribute dryMassAllocated : MassValue = sum(subsystems.allocatedMass) {
            doc /* Dry mass with each unit's maturity contingency applied. */
        }

        flow of TethysInterfaces::ElectricalPower from eps.mainBus.supply to cdh.power.supply;
        flow of TethysInterfaces::ElectricalPower from eps.mainBus.supply to telecom.power.supply;
        flow of TethysInterfaces::ElectricalPower from eps.mainBus.supply to gnc.power.supply;
        flow of TethysInterfaces::ElectricalPower from eps.mainBus.supply to thermal.power.supply;
        flow of TethysInterfaces::ElectricalPower from eps.mainBus.supply to rcs.power.supply;
        flow of TethysInterfaces::ElectricalPower from eps.mainBus.supply to captureSystem.power.supply;
        flow of TethysInterfaces::ElectricalPower from eps.mainBus.supply to sensors.power.supply;
        flow of TethysInterfaces::ElectricalPower from eps.highVoltageBus.supply to sep.power.supply;
    }

    part argentDesign : ArgentTug {
        doc /* The Phase B design of Argent: the unit tree the budgets of TethysBudgets read,
             * with the backbone's xenon load, hydrazine load and array power. */
        part :>> sep {
            attribute :>> xenonMass = argent.sep.xenonMass;
        }
        part :>> rcs {
            attribute :>> hydrazineMass = argent.rcs.hydrazineMass;
        }
        part :>> captureSystem {
            attribute :>> maximumBodyMass = argent.captureSystem.maximumBodyMass;
        }
        attribute :>> dryMass = argent.dryMass;
        attribute :>> wetMass = dryMass + sep.xenonMass + rcs.hydrazineMass;
    }
}
