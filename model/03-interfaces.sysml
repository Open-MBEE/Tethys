// What crosses every boundary in the mission: the items that flow, the ports they flow through
// and the interface definitions each ICD is written against.
package TethysInterfaces {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;

    // ---- items ---------------------------------------------------------------------------
    item def ElectricalPower {
        doc /* Regulated or unregulated DC power on a bus. */
        attribute voltage : ElectricPotentialValue;
        attribute power : PowerValue;
    }
    item def Telemetry {
        doc /* Housekeeping or science data framed for a downlink or an on-board bus. */
        attribute dataRate : Real;
        attribute volume : Real;
    }
    item def Telecommand {
        doc /* A command packet or a command file. */
    }
    item def RfCarrier {
        doc /* A radio-frequency carrier with its modulation and power. */
        attribute frequency : FrequencyValue;
        attribute eirp : PowerValue;
    }
    item def Heat {
        doc /* Conducted or radiated thermal power. */
        attribute power : PowerValue;
    }
    item def MechanicalLoad {
        doc /* Quasi-static, sine, random, shock or contact load at a mechanical interface. */
        attribute quasiStaticAcceleration : AccelerationValue;
        attribute force : ForceValue;
    }
    item def Propellant {
        doc /* Pressurised propellant: xenon for the electric thrusters, hydrazine for the
             * reaction control thrusters, pressurant gas for either. */
        attribute mass : MassValue;
    }

    // ---- ports ---------------------------------------------------------------------------
    port def PowerOutlet {
        doc /* A power source port: power flows out, a load-current demand is reported back. */
        out item supply : ElectricalPower;
    }
    port def DataBusPort {
        doc /* A node on an on-board data bus. */
        inout item telemetry : Telemetry;
        inout item telecommand : Telecommand;
    }
    port def RfPort {
        doc /* An antenna or transponder port. */
        inout item carrier : RfCarrier;
    }
    port def ThermalPort {
        doc /* A conductive or radiative thermal interface. */
        inout item heat : Heat;
    }
    port def MechanicalPort {
        doc /* A structural attachment: loads cross it, a separation signal may end it. */
        inout item load : MechanicalLoad;
        attribute separable : Boolean;
    }
    port def UmbilicalPort {
        doc /* The electrical umbilical across a separable interface: keep-alive power,
             * checkout data and separation signals. */
        out item keepAlive : ElectricalPower;
        inout item checkout : Telemetry;
        out separationSignal : Boolean;
    }
    port def FluidPort {
        doc /* A propellant or pressurant line interface. */
        inout item propellantFlow : Propellant;
    }
    port def DockingPort {
        doc /* An androgynous docking interface: structural latch, power and data pass-through
             * for the visiting vehicle. */
        inout item load : MechanicalLoad;
        inout item transfer : ElectricalPower;
        inout item data : Telemetry;
    }

    // ---- interface definitions, one per ICD class --------------------------------------
    interface def TugInspectorInterface {
        doc /* Tug ↔ inspector before release, the electrical umbilical: keep-alive power,
             * checkout data and the separation signal. The stowed stack's mechanical and
             * thermal disciplines are InspectorDispenserInterface and InspectorThermalInterface,
             * each a binary interface of its own so every usage stays a two-ended connect; the
             * relay link takes over after release. */
        end tugSide : UmbilicalPort;
        end inspectorSide : ~UmbilicalPort;
    }
    interface def InspectorDispenserInterface {
        doc /* Tug ↔ inspector mechanical while stowed: the dispenser rails and release
             * mechanism carrying Wren's launch loads into the tug structure. */
        end tugSide : MechanicalPort;
        end inspectorSide : ~MechanicalPort;
    }
    interface def InspectorThermalInterface {
        doc /* Tug ↔ inspector thermal while stowed: heat conducted through the dispenser
             * rails that keeps Wren's battery above its survival temperature. */
        end tugSide : ThermalPort;
        end inspectorSide : ~ThermalPort;
    }
    interface def PropellantFeedInterface {
        doc /* Tank ↔ ground fill-and-drain: the xenon and hydrazine loading lines on the pad. */
        end tankSide : FluidPort;
        end groundSide : ~FluidPort;
    }
    interface def SpacecraftLauncherInterface {
        doc /* Stack ↔ launcher: adapter, loads, umbilical and separation. */
        end spacecraftSide : MechanicalPort;
        end launcherSide : ~MechanicalPort;
    }
    interface def SpaceGroundLink {
        doc /* Tug ↔ ground station: X/Ka-band telemetry, telecommand and ranging. */
        end spacecraftSide : RfPort;
        end groundSide : ~RfPort;
    }
    interface def InspectorRelayLink {
        doc /* Inspector ↔ tug proximity link: imagery and radar data up, commands down. */
        end inspectorSide : RfPort;
        end tugSide : ~RfPort;
    }
    interface def CaptureInterface {
        doc /* Tug ↔ target body: the contact loads through the capture mechanism during
             * capture, despin and the return thrust arcs. */
        end tugSide : MechanicalPort;
        end bodySide : ~MechanicalPort;
        attribute contactSpeedLimit : SpeedValue;
        attribute cinchPreload : ForceValue;
        attribute maximumDespinTorque : TorqueValue;
        attribute slipTorqueLimit : TorqueValue;
        attribute minimumTemperature : ThermodynamicTemperatureValue;
        attribute maximumTemperature : ThermodynamicTemperatureValue;
    }
    interface def DockingInterface {
        doc /* Tug ↔ visiting vehicle in the distant retrograde orbit. */
        end tugSide : DockingPort;
        end visitorSide : ~DockingPort;
    }
    interface def PowerInterface {
        doc /* A unit on the power bus. */
        end source : PowerOutlet;
        end load : ~PowerOutlet;
    }
    interface def DataBusInterface {
        doc /* Two nodes on an on-board data bus. */
        end a : DataBusPort;
        end b : ~DataBusPort;
    }
    interface def ThermalInterface {
        doc /* Two units coupled by a strap, a radiator or a mount. */
        end hot : ThermalPort;
        end cold : ~ThermalPort;
    }
}
