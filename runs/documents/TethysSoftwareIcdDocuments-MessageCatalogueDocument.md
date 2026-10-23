# SCD-019 Inter-application message catalogue

Every message between the flight applications and services is a space packet on the AABP-1 software bus; its application identifier is the topic, its publisher and subscribers are the ends of the topic interface.

## Message types

*Message item definitions*

| name | documentation |
| --- | --- |
| TelemetryMessage | A bus message carrying state or housekeeping from one component to its<br>subscribers: a space packet on the software bus that is also telemetry, so it can<br>be routed to the ground unchanged (a TelemetryPacket on the bus). |
| CommandMessage | A bus message that directs a component: a space packet on the software bus that<br>is also a telecommand, so a routed ground command and an on-board request share<br>one shape (a CommandPacket on the bus). |
| AttitudeStateMessage | Estimated attitude quaternion, body rates and attitude-control status, published by<br>the guidance, navigation and control application at 10 Hz for the autonomy<br>application and the electric-propulsion control application. |
| NavigationStateMessage | Position and velocity relative to the target or the Moon and the current<br>ephemeris epoch, published by the guidance, navigation and control application at<br>1 Hz for the autonomy and inspector-handling applications. |
| ThrusterStatusMessage | Discharge current, anode voltage, flow-controller state and accumulated impulse of<br>each Hall thruster, published by the electric-propulsion control application at<br>1 Hz for the power-management and fault-protection applications. |
| PowerStateMessage | Bus voltage, array current, battery state of charge and load-switch states,<br>published by the power-management application at 1 Hz for the mode-management,<br>thermal-control and fault-protection applications. |
| ThermalStateMessage | Zone temperatures, heater duty cycles and limit flags, published by the<br>thermal-control application every 10 s for the power-management and<br>fault-protection applications. |
| LinkStatusMessage | Carrier lock, received signal level, current virtual-channel rate set and<br>frame-count, published by the telecom application at 1 Hz for the mode-management<br>and fault-protection applications. |
| CaptureStateMessage | Capture-mechanism arm positions, contact-force readings and the despin phase,<br>published by the capture-control application at 10 Hz for the guidance,<br>navigation and control and autonomy applications. |
| RelayStatusMessage | Relay link state with Wren, store-and-forward backlog and the last inspector<br>event, published by the inspector-handling application at 1 Hz for the autonomy<br>and telecom applications. |
| FaultReportMessage | A detected fault with its level and the response the fault-protection<br>application has chosen, published on detection (no period) for the<br>mode-management and autonomy applications. |
| ModeChangeMessage | The commanded tug mode and the time it takes effect, published by the<br>mode-management application on each transition for every application. |
| SequenceStepMessage | One step of a stored sequence released by the autonomy application to the<br>application that executes it: guidance, electric propulsion or capture control. |
| TimeTickMessage | The one-second tick with the correlated spacecraft time, published by the time<br>service for every component. |
| MessageCatalogue | The catalogue of inter-application messages: one item per message type, the bus<br>figures they must fit, and the checks that every application identifier lies in<br>the bus topic range above the identifiers the space-link profile reserves and that<br>no message exceeds the bus maximum. |
| FanoutTopic | One message type from its publisher to two subscribers: a three-ended interface,<br>which the standard permits for any interface not typed by BinaryInterface. |
| BroadcastTopic | One message type from its publisher to three subscribers: a four-ended interface. |
| OnBoardBusProtocolIcd | The AABP-1 protocol between the software bus controller in the board support<br>package and each remote terminal on the on-board data bus: frame layout,<br>addressing, the time-slot schedule within one polling period and the handling of<br>check failures. The bus electrical and rate figures are those of TI-013. |
| SpaceLinkProfileIcd | The MLS-2 profile of the TI-010 packet interface between the telecom application<br>and the Meridian packet gateway: CCSDS Space Packets with a time-code secondary<br>header, carried in fixed-length transfer frames on eight virtual channels, with a<br>rate set per tug mode and a safe rate set that every mode falls back to. The RF<br>carrier beneath it is TI-003. |
| InspectorRelaySoftwareIcd | The software profile of the proximity relay between the inspector-handling<br>application and Wren: AABP-1 frames tunnelled over the TI-004 GMSK link, the<br>identifier block the relayed inspector packets use, the store-and-forward depth<br>on the tug and the acknowledgement rules. |
| RegisterMap | The register map of one remote interface unit: the address space and the data<br>width every register respects. |
| ThermalPropulsionRiuRegisterMap | The register map of the remote interface unit that gathers the thermistors and<br>drives the heaters and the propellant valves. |
| MechanismRiuRegisterMap | The register map of the remote interface unit that drives the capture mechanism,<br>the dispenser and the docking ring and reads their position and force sensors. |
| RemoteInterfaceUnitRegisterIcd | The register-level ICD between the remote-interface-unit driver of the board<br>support package and each remote interface unit: the register access frame AABP-1<br>carries, the address and data widths, and the two register maps. |
| BusRemoteInterfaceUnit | A remote interface unit seen from the bus: the unit of the tug structure with its<br>remote-terminal port on the on-board data bus. |
| MeridianPacketGateway | The Meridian ground entry point of the packet interface: where transfer frames<br>from the stations become space packets for the operations centre and commands<br>become frames. |
| WrenRelayEndpoint | Wren's end of the relay profile: its software bus node behind the proximity<br>transceiver. |

## Identifiers, lengths and periods

*Figures per catalogue message*

| name | type | apid | length | period |
| --- | --- | --- | --- | --- |
| attitudeState | TethysSoftwareIcds::AttitudeStateMessage | 16 | 128 \[B\] | 0.1 \[s\] |
| navigationState | TethysSoftwareIcds::NavigationStateMessage | 17 | 160 \[B\] | 1 \[s\] |
| thrusterStatus | TethysSoftwareIcds::ThrusterStatusMessage | 18 | 96 \[B\] | 1 \[s\] |
| powerState | TethysSoftwareIcds::PowerStateMessage | 19 | 112 \[B\] | 1 \[s\] |
| thermalState | TethysSoftwareIcds::ThermalStateMessage | 20 | 256 \[B\] | 10 \[s\] |
| linkStatus | TethysSoftwareIcds::LinkStatusMessage | 21 | 48 \[B\] | 1 \[s\] |
| captureState | TethysSoftwareIcds::CaptureStateMessage | 22 | 144 \[B\] | 0.1 \[s\] |
| relayStatus | TethysSoftwareIcds::RelayStatusMessage | 23 | 80 \[B\] | 1 \[s\] |
| faultReport | TethysSoftwareIcds::FaultReportMessage | 24 | 64 \[B\] | 0 \[s\] |
| modeChange | TethysSoftwareIcds::ModeChangeMessage | 25 | 32 \[B\] | 0 \[s\] |
| sequenceStep | TethysSoftwareIcds::SequenceStepMessage | 26 | 48 \[B\] | 0 \[s\] |
| timeTick | TethysSoftwareIcds::TimeTickMessage | 27 | 16 \[B\] | 1 \[s\] |

<a id="topics"></a>

## Topics and ICD attachments

*Interfaces attached to the flight software*

| name | type | documentation |
| --- | --- | --- |
| attitudeStateTopic | TethysSoftwareIcds::FanoutTopic | Guidance publishes the attitude state to autonomy and electric propulsion. |
| navigationStateTopic | TethysSoftwareIcds::FanoutTopic | Guidance publishes the navigation state to autonomy and inspector handling. |
| thrusterStatusTopic | TethysSoftwareIcds::FanoutTopic | Electric propulsion publishes thruster status to power management and fault protection. |
| powerStateTopic | TethysSoftwareIcds::BroadcastTopic | Power management publishes the power state to mode management, thermal control and fault protection. |
| thermalStateTopic | TethysSoftwareIcds::FanoutTopic | Thermal control publishes the thermal state to power management and fault protection. |
| linkStatusTopic | TethysSoftwareIcds::FanoutTopic | Telecom publishes link status to mode management and fault protection. |
| captureStateTopic | TethysSoftwareIcds::FanoutTopic | Capture control publishes the capture state to guidance and autonomy. |
| relayStatusTopic | TethysSoftwareIcds::FanoutTopic | Inspector handling publishes relay status to autonomy and telecom. |
| faultReportTopic | TethysSoftwareIcds::FanoutTopic | Fault protection publishes fault reports to mode management and autonomy. |
| modeChangeTopic | TethysSoftwareIcds::BroadcastTopic | Mode management publishes mode changes; guidance, electric propulsion and telecom are the subscribers that change their rate sets. |
| sequenceStepTopic | TethysSoftwareIcds::BroadcastTopic | Autonomy releases sequence steps to guidance, electric propulsion and capture control. |
| timeTickTopic | TethysSoftwareIcds::FanoutTopic | The time service publishes the tick; command and data handling stamps packets with it and housekeeping paces its sampling. |
| thermalPropulsionRiuBus | TethysSoftwareIcds::OnBoardBusProtocolIcd | AABP-1 between the bus controller and the thermal and propulsion remote interface unit. |
| mechanismRiuBus | TethysSoftwareIcds::OnBoardBusProtocolIcd | AABP-1 between the bus controller and the mechanism remote interface unit. |
| thermalPropulsionRiuRegisters | TethysSoftwareIcds::RemoteInterfaceUnitRegisterIcd | Register access to the thermal and propulsion remote interface unit. |
| mechanismRiuRegisters | TethysSoftwareIcds::RemoteInterfaceUnitRegisterIcd | Register access to the mechanism remote interface unit. |
| spaceLinkProfile | TethysSoftwareIcds::SpaceLinkProfileIcd | MLS-2 between the telecom application and the Meridian packet gateway. |
| inspectorRelayProfile | TethysSoftwareIcds::InspectorRelaySoftwareIcd | The relay profile between inspector handling and Wren. |
