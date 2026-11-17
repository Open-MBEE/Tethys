<!-- TethysViews::interfaceDefinitions — table rendering (render asElementTable) -->
| Element | Kind | Type | Declared in |
| --- | --- | --- | --- |
| TethysInterfaces::ElectricalPower | item def |  |  |
| voltage | attribute | ElectricPotentialValue | TethysInterfaces::ElectricalPower |
| power | attribute | PowerValue | TethysInterfaces::ElectricalPower |
| TethysInterfaces::Telemetry | item def |  |  |
| dataRate | attribute | Real | TethysInterfaces::Telemetry |
| volume | attribute | Real | TethysInterfaces::Telemetry |
| TethysInterfaces::Telecommand | item def |  |  |
| TethysInterfaces::RfCarrier | item def |  |  |
| frequency | attribute | FrequencyValue | TethysInterfaces::RfCarrier |
| eirp | attribute | PowerValue | TethysInterfaces::RfCarrier |
| TethysInterfaces::Heat | item def |  |  |
| power | attribute | PowerValue | TethysInterfaces::Heat |
| TethysInterfaces::MechanicalLoad | item def |  |  |
| quasiStaticAcceleration | attribute | AccelerationValue | TethysInterfaces::MechanicalLoad |
| force | attribute | ForceValue | TethysInterfaces::MechanicalLoad |
| TethysInterfaces::Propellant | item def |  |  |
| mass | attribute | MassValue | TethysInterfaces::Propellant |
| TethysInterfaces::PowerOutlet | port def |  |  |
| supply | item | ElectricalPower | TethysInterfaces::PowerOutlet |
| TethysInterfaces::DataBusPort | port def |  |  |
| telemetry | item | Telemetry | TethysInterfaces::DataBusPort |
| telecommand | item | Telecommand | TethysInterfaces::DataBusPort |
| TethysInterfaces::RfPort | port def |  |  |
| carrier | item | RfCarrier | TethysInterfaces::RfPort |
| TethysInterfaces::ThermalPort | port def |  |  |
| heat | item | Heat | TethysInterfaces::ThermalPort |
| TethysInterfaces::MechanicalPort | port def |  |  |
| load | item | MechanicalLoad | TethysInterfaces::MechanicalPort |
| separable | attribute | Boolean | TethysInterfaces::MechanicalPort |
| TethysInterfaces::UmbilicalPort | port def |  |  |
| keepAlive | item | ElectricalPower | TethysInterfaces::UmbilicalPort |
| checkout | item | Telemetry | TethysInterfaces::UmbilicalPort |
| separationSignal | attribute | Boolean | TethysInterfaces::UmbilicalPort |
| TethysInterfaces::FluidPort | port def |  |  |
| propellantFlow | item | Propellant | TethysInterfaces::FluidPort |
| TethysInterfaces::DockingPort | port def |  |  |
| load | item | MechanicalLoad | TethysInterfaces::DockingPort |
| transfer | item | ElectricalPower | TethysInterfaces::DockingPort |
| data | item | Telemetry | TethysInterfaces::DockingPort |
| TethysInterfaces::TugInspectorInterface | interface def |  |  |
| tugSide | end port | UmbilicalPort | TethysInterfaces::TugInspectorInterface |
| inspectorSide | end port | ~UmbilicalPort | TethysInterfaces::TugInspectorInterface |
| TethysInterfaces::InspectorDispenserInterface | interface def |  |  |
| tugSide | end port | MechanicalPort | TethysInterfaces::InspectorDispenserInterface |
| inspectorSide | end port | ~MechanicalPort | TethysInterfaces::InspectorDispenserInterface |
| TethysInterfaces::InspectorThermalInterface | interface def |  |  |
| tugSide | end port | ThermalPort | TethysInterfaces::InspectorThermalInterface |
| inspectorSide | end port | ~ThermalPort | TethysInterfaces::InspectorThermalInterface |
| TethysInterfaces::PropellantFeedInterface | interface def |  |  |
| tankSide | end port | FluidPort | TethysInterfaces::PropellantFeedInterface |
| groundSide | end port | ~FluidPort | TethysInterfaces::PropellantFeedInterface |
| TethysInterfaces::SpacecraftLauncherInterface | interface def |  |  |
| spacecraftSide | end port | MechanicalPort | TethysInterfaces::SpacecraftLauncherInterface |
| launcherSide | end port | ~MechanicalPort | TethysInterfaces::SpacecraftLauncherInterface |
| TethysInterfaces::SpaceGroundLink | interface def |  |  |
| spacecraftSide | end port | RfPort | TethysInterfaces::SpaceGroundLink |
| groundSide | end port | ~RfPort | TethysInterfaces::SpaceGroundLink |
| TethysInterfaces::InspectorRelayLink | interface def |  |  |
| inspectorSide | end port | RfPort | TethysInterfaces::InspectorRelayLink |
| tugSide | end port | ~RfPort | TethysInterfaces::InspectorRelayLink |
| TethysInterfaces::CaptureInterface | interface def |  |  |
| tugSide | end port | MechanicalPort | TethysInterfaces::CaptureInterface |
| bodySide | end port | ~MechanicalPort | TethysInterfaces::CaptureInterface |
| contactSpeedLimit | attribute | SpeedValue | TethysInterfaces::CaptureInterface |
| cinchPreload | attribute | ForceValue | TethysInterfaces::CaptureInterface |
| maximumDespinTorque | attribute | TorqueValue | TethysInterfaces::CaptureInterface |
| slipTorqueLimit | attribute | TorqueValue | TethysInterfaces::CaptureInterface |
| minimumTemperature | attribute | ThermodynamicTemperatureValue | TethysInterfaces::CaptureInterface |
| maximumTemperature | attribute | ThermodynamicTemperatureValue | TethysInterfaces::CaptureInterface |
| TethysInterfaces::DockingInterface | interface def |  |  |
| tugSide | end port | DockingPort | TethysInterfaces::DockingInterface |
| visitorSide | end port | ~DockingPort | TethysInterfaces::DockingInterface |
| TethysInterfaces::PowerInterface | interface def |  |  |
| source | end port | PowerOutlet | TethysInterfaces::PowerInterface |
| load | end port | ~PowerOutlet | TethysInterfaces::PowerInterface |
| TethysInterfaces::DataBusInterface | interface def |  |  |
| a | end port | DataBusPort | TethysInterfaces::DataBusInterface |
| b | end port | ~DataBusPort | TethysInterfaces::DataBusInterface |
| TethysInterfaces::ThermalInterface | interface def |  |  |
| hot | end port | ThermalPort | TethysInterfaces::ThermalInterface |
| cold | end port | ~ThermalPort | TethysInterfaces::ThermalInterface |
