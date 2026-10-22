// Argent, the solar-electric tug: its subsystems and the ports the ICDs attach to. Each
// subsystem's internals, budgets and modes are filled in by the tug work package.
package TethysTug {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysInterfaces::*;

    part def Subsystem {
        doc /* A spacecraft subsystem: a mass, a power demand per mode, a power and a data
             * bus connection. */
        attribute mass : MassValue;
        port power : ~PowerOutlet;
        port bus : DataBusPort;
    }

    part def StructureAndMechanisms :> Subsystem {
        doc /* Primary structure, the launcher adapter ring, the inspector dispenser, the array
             * and radiator deployment mechanisms and the docking interface for the visiting
             * vehicle. */
        port launcherAttachment : MechanicalPort;
        port inspectorAttachment : MechanicalPort;
        port docking : DockingPort;
    }
    part def ThermalControl :> Subsystem {
        doc /* MLI, deployable radiators, heaters and the power-processing-unit heat rejection
             * loop; the hot case is full-power thrusting at the target's perihelion. */
        port radiator : ThermalPort;
        port inspectorThermal : ThermalPort;
    }
    part def ElectricalPowerSystem :> Subsystem {
        doc /* Two large roll-out solar array wings, battery and the high-voltage and
             * low-voltage power distribution; the array sizes the whole tug. */
        attribute arrayPowerAtOneAu : PowerValue;
        port mainBus : PowerOutlet;
        port highVoltageBus : PowerOutlet;
        port inspectorKeepAlive : UmbilicalPort;
    }
    part def CommandAndDataHandling :> Subsystem {
        doc /* Flight computers, mass memory and the on-board data bus controller. */
        port busController : DataBusPort;
    }
    part def Telecommunications :> Subsystem {
        doc /* X/Ka-band deep-space transponders and antennas, and the proximity-link
             * transceiver for the inspector. */
        port deepSpace : RfPort;
        port proximity : ~RfPort;
    }
    part def GuidanceNavigationControl :> Subsystem {
        doc /* Star trackers, inertial units, sun sensors, reaction wheels, and the relative
             * navigation sensors — cameras and a scanning lidar — for proximity operations and
             * capture. */
    }
    part def SolarElectricPropulsion :> Subsystem {
        doc /* Hall-effect thrusters on gimbals, their power processing units, the xenon
             * storage and feed system: every heliocentric Δv of the mission. */
        attribute xenonMass : MassValue;
        attribute thrusterCount : Natural;
        attribute operatingThrusters : Natural;
        attribute specificImpulse : DurationValue;
        attribute maximumPower : PowerValue;
        port xenonFill : FluidPort;
    }
    part def ReactionControl :> Subsystem {
        doc /* Hydrazine thrusters for proximity operations, capture, despin and wheel
             * desaturation. */
        attribute hydrazineMass : MassValue;
        port hydrazineFill : FluidPort;
    }
    part def CaptureSystem :> Subsystem {
        doc /* The inflatable capture bag, its deployment booms, cinching lines and the
             * contact-load path into the primary structure. */
        attribute maximumBodyDiameter : LengthValue;
        attribute maximumBodyMass : MassValue;
        port grapple : MechanicalPort;
    }
    part def CharacterisationSensors :> Subsystem {
        doc /* The tug's own target sensors: narrow- and wide-angle cameras, thermal imager and
             * the radio-science use of the telecom link for mass determination. */
    }

    part def Tug {
        doc /* The Argent tug: ten subsystems around the capture system. */
        attribute dryMass : MassValue;
        attribute wetMass : MassValue;
        part structure : StructureAndMechanisms;
        part thermal : ThermalControl;
        part eps : ElectricalPowerSystem;
        part cdh : CommandAndDataHandling;
        part telecom : Telecommunications;
        part gnc : GuidanceNavigationControl;
        part sep : SolarElectricPropulsion;
        part rcs : ReactionControl;
        part captureSystem : CaptureSystem;
        part sensors : CharacterisationSensors;

        interface powerToCdh : PowerInterface connect eps.mainBus to cdh.power;
        interface powerToTelecom : PowerInterface connect eps.mainBus to telecom.power;
        interface powerToGnc : PowerInterface connect eps.mainBus to gnc.power;
        interface powerToThermal : PowerInterface connect eps.mainBus to thermal.power;
        interface powerToRcs : PowerInterface connect eps.mainBus to rcs.power;
        interface powerToCapture : PowerInterface connect eps.mainBus to captureSystem.power;
        interface powerToSensors : PowerInterface connect eps.mainBus to sensors.power;
        interface highVoltageToSep : PowerInterface connect eps.highVoltageBus to sep.power;
    }

    part argent : Tug {
        doc /* The flight tug as sized at the start of Phase B: 5 600 kg dry, 6 600 kg xenon,
             * 400 kg hydrazine (about 1 100 days of thrust at 1.8 N: ~650 kg outbound, ~5 100 kg to bring 370 t home); 48 kW at 1 AU; four thrusters, three operating, Isp 2 900 s. */
        attribute :>> dryMass = 5600.0 [kg];
        attribute :>> wetMass = 12600.0 [kg];
        part :>> eps { attribute :>> arrayPowerAtOneAu = 48.0 [kW]; }
        part :>> sep {
            attribute :>> xenonMass = 6600.0 [kg];
            attribute :>> thrusterCount = 4;
            attribute :>> operatingThrusters = 3;
            attribute :>> specificImpulse = 2900.0 [s];
            attribute :>> maximumPower = 40.0 [kW];
        }
        part :>> rcs { attribute :>> hydrazineMass = 400.0 [kg]; }
        part :>> captureSystem {
            attribute :>> maximumBodyDiameter = 10.0 [m];
            attribute :>> maximumBodyMass = 1000.0e3 [kg];
        }
    }
}
