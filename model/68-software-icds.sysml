// Software interface control: the messages the flight applications and services exchange over
// the AABP-1 software bus, the AABP-1 on-board bus protocol down to the remote interface units,
// the MLS-2 space-link profile over CCSDS Space Packets between the telecom application and the
// Meridian packet gateway, the relay profile between the tug and Wren, and the register maps of
// the remote interface units. Every ICD here specialises a TethysInterfaces interface def, keeps
// its ends typed PacketPort or DataBusPort, carries an InterfaceControl annotation with a TI-02x
// id and is tied to the flight software of 63 by argentSoftwareIcds. AABP-1, MLS-2 and the
// register maps are fictional; the CCSDS Space Packet is the one real standard the profile cites.
package TethysSoftwareIcds {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysInterfaces::Telemetry;
    private import TethysInterfaces::Telecommand;
    private import TethysInterfaces::DataBusPort;
    private import TethysInterfaces::DataBusInterface;
    private import TethysIcds::*;
    private import TethysFlightSoftware::*;
    private import TethysTugStructure::TugMode;
    private import TethysTugStructure::RemoteInterfaceUnit;
    private import TethysRequirements::Verification;
    private import TethysRequirements::VerificationLevel;
    private import TethysRequirements::VerificationStage;
    private import VerificationCases::VerificationMethodKind;

    // ---- 1. Inter-application message catalogue ----------------------------------------------
    item def TelemetryMessage :> BusMessage, TelemetryPacket {
        doc /* A bus message carrying state or housekeeping from one component to its
             * subscribers: a space packet on the software bus that is also telemetry, so it can
             * be routed to the ground unchanged (a TelemetryPacket on the bus). */
    }
    item def CommandMessage :> BusMessage, CommandPacket {
        doc /* A bus message that directs a component: a space packet on the software bus that
             * is also a telecommand, so a routed ground command and an on-board request share
             * one shape (a CommandPacket on the bus). */
    }

    item def AttitudeStateMessage :> TelemetryMessage {
        doc /* Estimated attitude quaternion, body rates and attitude-control status, published by
             * the guidance, navigation and control application at 10 Hz for the autonomy
             * application and the electric-propulsion control application. */
        attribute :>> apid = 16;
        attribute :>> length = 128.0 [B];
        attribute :>> period = 0.1 [s];
    }
    item def NavigationStateMessage :> TelemetryMessage {
        doc /* Position and velocity relative to the target or the Moon and the current
             * ephemeris epoch, published by the guidance, navigation and control application at
             * 1 Hz for the autonomy and inspector-handling applications. */
        attribute :>> apid = 17;
        attribute :>> length = 160.0 [B];
        attribute :>> period = 1.0 [s];
    }
    item def ThrusterStatusMessage :> TelemetryMessage {
        doc /* Discharge current, anode voltage, flow-controller state and accumulated impulse of
             * each Hall thruster, published by the electric-propulsion control application at
             * 1 Hz for the power-management and fault-protection applications. */
        attribute :>> apid = 18;
        attribute :>> length = 96.0 [B];
        attribute :>> period = 1.0 [s];
    }
    item def PowerStateMessage :> TelemetryMessage {
        doc /* Bus voltage, array current, battery state of charge and load-switch states,
             * published by the power-management application at 1 Hz for the mode-management,
             * thermal-control and fault-protection applications. */
        attribute :>> apid = 19;
        attribute :>> length = 112.0 [B];
        attribute :>> period = 1.0 [s];
    }
    item def ThermalStateMessage :> TelemetryMessage {
        doc /* Zone temperatures, heater duty cycles and limit flags, published by the
             * thermal-control application every 10 s for the power-management and
             * fault-protection applications. */
        attribute :>> apid = 20;
        attribute :>> length = 256.0 [B];
        attribute :>> period = 10.0 [s];
    }
    item def LinkStatusMessage :> TelemetryMessage {
        doc /* Carrier lock, received signal level, current virtual-channel rate set and
             * frame-count, published by the telecom application at 1 Hz for the mode-management
             * and fault-protection applications. */
        attribute :>> apid = 21;
        attribute :>> length = 48.0 [B];
        attribute :>> period = 1.0 [s];
    }
    item def CaptureStateMessage :> TelemetryMessage {
        doc /* Capture-mechanism arm positions, contact-force readings and the despin phase,
             * published by the capture-control application at 10 Hz for the guidance,
             * navigation and control and autonomy applications. */
        attribute :>> apid = 22;
        attribute :>> length = 144.0 [B];
        attribute :>> period = 0.1 [s];
    }
    item def RelayStatusMessage :> TelemetryMessage {
        doc /* Relay link state with Wren, store-and-forward backlog and the last inspector
             * event, published by the inspector-handling application at 1 Hz for the autonomy
             * and telecom applications. */
        attribute :>> apid = 23;
        attribute :>> length = 80.0 [B];
        attribute :>> period = 1.0 [s];
    }
    item def FaultReportMessage :> CommandMessage {
        doc /* A detected fault with its level and the response the fault-protection
             * application has chosen, published on detection (no period) for the
             * mode-management and autonomy applications. */
        attribute :>> apid = 24;
        attribute :>> length = 64.0 [B];
        attribute :>> period = 0.0 [s];
        attribute :>> opcode = "FAULT_REPORT";
    }
    item def ModeChangeMessage :> CommandMessage {
        doc /* The commanded tug mode and the time it takes effect, published by the
             * mode-management application on each transition for every application. */
        attribute :>> apid = 25;
        attribute :>> length = 32.0 [B];
        attribute :>> period = 0.0 [s];
        attribute :>> opcode = "MODE_CHANGE";
    }
    item def SequenceStepMessage :> CommandMessage {
        doc /* One step of a stored sequence released by the autonomy application to the
             * application that executes it: guidance, electric propulsion or capture control. */
        attribute :>> apid = 26;
        attribute :>> length = 48.0 [B];
        attribute :>> period = 0.0 [s];
        attribute :>> opcode = "SEQUENCE_STEP";
    }
    item def TimeTickMessage :> TelemetryMessage {
        doc /* The one-second tick with the correlated spacecraft time, published by the time
             * service for every component. */
        attribute :>> apid = 27;
        attribute :>> length = 16.0 [B];
        attribute :>> period = 1.0 [s];
    }

    part def MessageCatalogue {
        doc /* The catalogue of inter-application messages: one item per message type, the bus
             * figures they must fit, and the checks that every application identifier lies in
             * the bus topic range above the identifiers the space-link profile reserves and that
             * no message exceeds the bus maximum. */
        attribute topicCount : Natural = 256;
        attribute reservedApids : Natural = 16;
        attribute maximumMessageLength : StorageCapacityValue = 1024.0 [B];
        item attitudeState : AttitudeStateMessage;
        item navigationState : NavigationStateMessage;
        item thrusterStatus : ThrusterStatusMessage;
        item powerState : PowerStateMessage;
        item thermalState : ThermalStateMessage;
        item linkStatus : LinkStatusMessage;
        item captureState : CaptureStateMessage;
        item relayStatus : RelayStatusMessage;
        item faultReport : FaultReportMessage;
        item modeChange : ModeChangeMessage;
        item sequenceStep : SequenceStepMessage;
        item timeTick : TimeTickMessage;
        assert constraint apidsAboveReservation {
            doc /* Catalogue identifiers start above the identifiers reserved for the link. */
            attitudeState.apid >= reservedApids and timeTick.apid >= reservedApids
        }
        assert constraint apidsWithinTopics {
            doc /* The highest catalogue identifier is a bus topic. */
            timeTick.apid < topicCount
        }
        assert constraint messagesFitTheBus {
            doc /* The largest message fits one bus frame. */
            thermalState.length <= maximumMessageLength
        }
    }

    // ---- 2. Topics: the interfaces between application bus ports ------------------------------
    interface def FanoutTopic {
        doc /* One message type from its publisher to two subscribers: a three-ended interface,
             * which the standard permits for any interface not typed by BinaryInterface. */
        ref item payload : BusMessage;
        end publisher : BusPort;
        end subscriberA : BusPort;
        end subscriberB : BusPort;
        flow of BusMessage from publisher.publish to subscriberA.subscribe;
        flow of BusMessage from publisher.publish to subscriberB.subscribe;
    }
    interface def BroadcastTopic {
        doc /* One message type from its publisher to three subscribers: a four-ended interface. */
        ref item payload : BusMessage;
        end publisher : BusPort;
        end subscriberA : BusPort;
        end subscriberB : BusPort;
        end subscriberC : BusPort;
        flow of BusMessage from publisher.publish to subscriberA.subscribe;
        flow of BusMessage from publisher.publish to subscriberB.subscribe;
        flow of BusMessage from publisher.publish to subscriberC.subscribe;
    }

    // ---- 3. TI-020 AABP-1 on-board bus protocol -----------------------------------------------
    enum def BusErrorResponse {
        doc /* What a bus node does with a frame that fails its check. */
        enum discardAndCount;
        enum requestRetry;
        enum raiseFault;
    }
    interface def <'TI-020'> OnBoardBusProtocolIcd :> DataBusInterface {
        doc /* The AABP-1 protocol between the software bus controller in the board support
             * package and each remote terminal on the on-board data bus: frame layout,
             * addressing, the time-slot schedule within one polling period and the handling of
             * check failures. The bus electrical and rate figures are those of TI-013. */
        @InterfaceControl { authority = "flight software"; document = "SCD-020"; revision = "A"; status = IcdStatus::draft; }
        attribute designation : String = "AABP-1";
        attribute frameHeaderLength : StorageCapacityValue = 8.0 [B];
        attribute frameTrailerLength : StorageCapacityValue = 2.0 [B];
        attribute maximumFrameLength : StorageCapacityValue = 1024.0 [B];
        attribute addressWidth : Natural = 5;
        attribute nodeCount : Natural = 32;
        attribute broadcastAddress : Natural = 31;
        attribute controllerAddress : Natural = 0;
        attribute majorFrame : DurationValue = 0.125 [s];
        attribute scheduleSlotCount : Natural = 64;
        attribute slotDuration : DurationValue = 1.953125e-3 [s];
        attribute checksumWidth : Natural = 16;
        attribute retryLimit : Natural = 2;
        attribute checksumFailure : BusErrorResponse = BusErrorResponse::requestRetry;
        attribute retryExhausted : BusErrorResponse = BusErrorResponse::raiseFault;
        attribute unknownAddress : BusErrorResponse = BusErrorResponse::discardAndCount;
        assert constraint addressesFit {
            doc /* The broadcast address is the last of the addressable nodes. */
            broadcastAddress == nodeCount - 1 and controllerAddress < nodeCount
        }
        assert constraint slotsFillTheFrame {
            doc /* The schedule slots tile the polling period exactly. */
            slotDuration * scheduleSlotCount == majorFrame
        }
        bind a.telemetry.dataRate = b.telemetry.dataRate;
        flow of Telemetry from b.telemetry to a.telemetry;
        flow of Telecommand from a.telecommand to b.telecommand;
    }

    // ---- 4. TI-021 MLS-2 space-link profile over CCSDS Space Packets --------------------------
    attribute def LinkRateSet {
        doc /* The downlink and uplink rates and the housekeeping period the profile uses in one
             * tug mode. */
        attribute mode : TugMode;
        attribute downlinkRate : BinaryDigitRateValue;
        attribute uplinkRate : BinaryDigitRateValue;
        attribute housekeepingPeriod : DurationValue;
    }
    interface def <'TI-021'> SpaceLinkProfileIcd :> PacketInterface {
        doc /* The MLS-2 profile of the TI-010 packet interface between the telecom application
             * and the Meridian packet gateway: CCSDS Space Packets with a time-code secondary
             * header, carried in fixed-length transfer frames on eight virtual channels, with a
             * rate set per tug mode and a safe rate set that every mode falls back to. The RF
             * carrier beneath it is TI-003. */
        @InterfaceControl { authority = "operations centre"; document = "SCD-021"; revision = "A"; status = IcdStatus::draft; }
        attribute designation : String = "MLS-2";
        attribute packetStandard : String = "CCSDS Space Packet, version 1";
        attribute transferFrameLength : StorageCapacityValue = 1115.0 [B];
        attribute frameHeaderLength : StorageCapacityValue = 6.0 [B];
        attribute frameTrailerLength : StorageCapacityValue = 4.0 [B];
        attribute secondaryHeaderLength : StorageCapacityValue = 10.0 [B];
        attribute timeCode : String = "unsegmented, 32-bit seconds and 16-bit fraction";
        attribute timeCorrelationPeriod : DurationValue = 60.0 [s];
        attribute dictionaryVersionWidth : Natural = 16;
        attribute virtualChannelCount : Natural = 8;
        attribute realTimeVirtualChannel : Natural = 0;
        attribute playbackVirtualChannel : Natural = 1;
        attribute eventVirtualChannel : Natural = 2;
        attribute fileTransferVirtualChannel : Natural = 3;
        attribute idleVirtualChannel : Natural = 7;
        attribute minimumDownlinkRate : BinaryDigitRateValue = 2.0e3 [bit/s];
        attribute maximumDownlinkRate : BinaryDigitRateValue = 4.0e6 [bit/s];
        attribute safeRates : LinkRateSet {
            :>> mode = TugMode::safe;
            :>> downlinkRate = 2.0e3 [bit/s];
            :>> uplinkRate = 2.0e3 [bit/s];
            :>> housekeepingPeriod = 60.0 [s];
        }
        attribute launchRates : LinkRateSet { :>> mode = TugMode::launch; :>> downlinkRate = 2.0e3 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 10.0 [s]; }
        attribute earlyOperationsRates : LinkRateSet { :>> mode = TugMode::earlyOperations; :>> downlinkRate = 1.0e5 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 1.0 [s]; }
        attribute coastRates : LinkRateSet { :>> mode = TugMode::coast; :>> downlinkRate = 3.2e4 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 10.0 [s]; }
        attribute thrustRates : LinkRateSet { :>> mode = TugMode::thrust; :>> downlinkRate = 3.2e4 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 10.0 [s]; }
        attribute approachRates : LinkRateSet { :>> mode = TugMode::approach; :>> downlinkRate = 2.56e5 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 1.0 [s]; }
        attribute proximityOperationsRates : LinkRateSet { :>> mode = TugMode::proximityOperations; :>> downlinkRate = 4.0e6 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 1.0 [s]; }
        attribute retreatRates : LinkRateSet { :>> mode = TugMode::retreat; :>> downlinkRate = 2.56e5 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 1.0 [s]; }
        attribute captureRates : LinkRateSet { :>> mode = TugMode::capture; :>> downlinkRate = 4.0e6 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 1.0 [s]; }
        attribute despinRates : LinkRateSet { :>> mode = TugMode::despin; :>> downlinkRate = 2.56e5 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 1.0 [s]; }
        attribute stackCoastRates : LinkRateSet { :>> mode = TugMode::stackCoast; :>> downlinkRate = 3.2e4 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 10.0 [s]; }
        attribute stackThrustRates : LinkRateSet { :>> mode = TugMode::stackThrust; :>> downlinkRate = 3.2e4 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 10.0 [s]; }
        attribute droHoldRates : LinkRateSet { :>> mode = TugMode::droHold; :>> downlinkRate = 1.0e5 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 10.0 [s]; }
        attribute dockedPassiveRates : LinkRateSet { :>> mode = TugMode::dockedPassive; :>> downlinkRate = 3.2e4 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 60.0 [s]; }
        attribute disposalRates : LinkRateSet { :>> mode = TugMode::disposal; :>> downlinkRate = 8.0e3 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 60.0 [s]; }
        attribute abortHoldRates : LinkRateSet { :>> mode = TugMode::abortHold; :>> downlinkRate = 2.0e3 [bit/s]; :>> uplinkRate = 2.0e3 [bit/s]; :>> housekeepingPeriod = 60.0 [s]; }
        assert constraint safeRatesWithinEnvelope {
            doc /* The safe rate set is the floor of the TI-003 rate envelope. */
            safeRates.downlinkRate == minimumDownlinkRate and safeRates.uplinkRate == uplinkRateFloor
        }
        attribute uplinkRateFloor : BinaryDigitRateValue = 2.0e3 [bit/s];
        assert constraint modeRatesWithinEnvelope {
            doc /* The fastest and slowest mode rate sets stay within the TI-003 envelope. */
            proximityOperationsRates.downlinkRate <= maximumDownlinkRate and disposalRates.downlinkRate >= minimumDownlinkRate
        }
        assert constraint virtualChannelsAddressable {
            doc /* Every named virtual channel is one of the channels the frame header can carry. */
            idleVirtualChannel < virtualChannelCount and fileTransferVirtualChannel < idleVirtualChannel
        }
        assert constraint packetsFitTheFrame {
            doc /* A frame header, one secondary header and the trailer leave room for a packet. */
            frameHeaderLength + secondaryHeaderLength + frameTrailerLength < transferFrameLength
        }
    }

    // ---- 5. TI-022 flight ↔ Wren relay software profile ---------------------------------------
    interface def <'TI-022'> InspectorRelaySoftwareIcd :> DataBusInterface {
        doc /* The software profile of the proximity relay between the inspector-handling
             * application and Wren: AABP-1 frames tunnelled over the TI-004 GMSK link, the
             * identifier block the relayed inspector packets use, the store-and-forward depth
             * on the tug and the acknowledgement rules. */
        @InterfaceControl { authority = "flight software"; document = "SCD-022"; revision = "A"; status = IcdStatus::draft; }
        attribute designation : String = "AABP-1 over TI-004";
        attribute forwardCommandRate : BinaryDigitRateValue = 9.6e3 [bit/s];
        attribute returnTelemetryRate : BinaryDigitRateValue = 1.0e6 [bit/s];
        attribute relayApidBase : Natural = 128;
        attribute relayApidCount : Natural = 32;
        attribute storeAndForwardCapacity : StorageCapacityValue = 2.0e8 [B];
        attribute acknowledgementTimeout : DurationValue = 2.0 [s];
        attribute retryLimit : Natural = 3;
        attribute maximumRelayLatency : DurationValue = 5.0 [s];
        assert constraint relayApidsWithinTopics {
            doc /* The relayed identifier block lies inside the bus topic range. */
            relayApidBase + relayApidCount <= 256
        }
        bind a.telemetry.dataRate = b.telemetry.dataRate;
        flow of Telemetry from b.telemetry to a.telemetry;
        flow of Telecommand from a.telecommand to b.telecommand;
    }

    // ---- 6. TI-023 remote interface unit register maps ----------------------------------------
    enum def RegisterAccess {
        doc /* How the bus controller may use a register. */
        enum readOnly;
        enum readWrite;
        enum writeOnly;
    }
    attribute def RegisterEntry {
        doc /* One register of a remote interface unit: its address on the unit, its width in
             * bits, what it holds and how it may be accessed. */
        attribute address : Natural;
        attribute width : Natural;
        attribute meaning : String;
        attribute access : RegisterAccess;
    }
    part def RegisterMap {
        doc /* The register map of one remote interface unit: the address space and the data
             * width every register respects. */
        attribute addressLimit : Natural = 256;
        attribute dataWidth : Natural = 16;
    }
    part def ThermalPropulsionRiuRegisterMap :> RegisterMap {
        doc /* The register map of the remote interface unit that gathers the thermistors and
             * drives the heaters and the propellant valves. */
        attribute status : RegisterEntry { :>> address = 0; :>> width = 16; :>> meaning = "unit status and fault flags"; :>> access = RegisterAccess::readOnly; }
        attribute control : RegisterEntry { :>> address = 1; :>> width = 16; :>> meaning = "unit control: reset, self-test, watchdog enable"; :>> access = RegisterAccess::readWrite; }
        attribute thermistorBank : RegisterEntry { :>> address = 16; :>> width = 16; :>> meaning = "first of 64 thermistor readings, one register each"; :>> access = RegisterAccess::readOnly; }
        attribute heaterEnable : RegisterEntry { :>> address = 96; :>> width = 16; :>> meaning = "heater enable bits, one per heater circuit"; :>> access = RegisterAccess::readWrite; }
        attribute heaterDuty : RegisterEntry { :>> address = 97; :>> width = 16; :>> meaning = "first of 16 heater duty-cycle settings"; :>> access = RegisterAccess::readWrite; }
        attribute valveCommand : RegisterEntry { :>> address = 128; :>> width = 16; :>> meaning = "latch-valve open and close pulses"; :>> access = RegisterAccess::writeOnly; }
        attribute valvePosition : RegisterEntry { :>> address = 129; :>> width = 16; :>> meaning = "latch-valve position indicators"; :>> access = RegisterAccess::readOnly; }
        attribute tankPressure : RegisterEntry { :>> address = 130; :>> width = 16; :>> meaning = "xenon tank pressure transducer reading"; :>> access = RegisterAccess::readOnly; }
        assert constraint addressesInMap {
            doc /* The last register the map names lies inside the address space. */
            tankPressure.address < addressLimit and status.address < control.address
        }
        assert constraint widthsAreTheDataWidth {
            doc /* Every register is one data word wide. */
            status.width == dataWidth and heaterDuty.width == dataWidth and tankPressure.width == dataWidth
        }
    }
    part def MechanismRiuRegisterMap :> RegisterMap {
        doc /* The register map of the remote interface unit that drives the capture mechanism,
             * the dispenser and the docking ring and reads their position and force sensors. */
        attribute status : RegisterEntry { :>> address = 0; :>> width = 16; :>> meaning = "unit status and fault flags"; :>> access = RegisterAccess::readOnly; }
        attribute control : RegisterEntry { :>> address = 1; :>> width = 16; :>> meaning = "unit control: reset, self-test, watchdog enable"; :>> access = RegisterAccess::readWrite; }
        attribute armMotorCommand : RegisterEntry { :>> address = 32; :>> width = 16; :>> meaning = "first of 4 capture-arm motor rate commands"; :>> access = RegisterAccess::readWrite; }
        attribute armPosition : RegisterEntry { :>> address = 36; :>> width = 16; :>> meaning = "first of 4 capture-arm resolver positions"; :>> access = RegisterAccess::readOnly; }
        attribute contactForce : RegisterEntry { :>> address = 40; :>> width = 16; :>> meaning = "first of 4 contact-pad force readings"; :>> access = RegisterAccess::readOnly; }
        attribute dispenserCommand : RegisterEntry { :>> address = 64; :>> width = 16; :>> meaning = "dispenser release and retention pulses"; :>> access = RegisterAccess::writeOnly; }
        attribute dockingRingCommand : RegisterEntry { :>> address = 80; :>> width = 16; :>> meaning = "docking ring extend, retract and latch"; :>> access = RegisterAccess::readWrite; }
        attribute dockingRingStatus : RegisterEntry { :>> address = 81; :>> width = 16; :>> meaning = "docking ring position and latch indicators"; :>> access = RegisterAccess::readOnly; }
        assert constraint addressesInMap {
            doc /* The last register the map names lies inside the address space. */
            dockingRingStatus.address < addressLimit and armPosition.address == armMotorCommand.address + 4
        }
        assert constraint widthsAreTheDataWidth {
            doc /* Every register is one data word wide. */
            status.width == dataWidth and contactForce.width == dataWidth and dockingRingStatus.width == dataWidth
        }
    }
    interface def <'TI-023'> RemoteInterfaceUnitRegisterIcd :> DataBusInterface {
        doc /* The register-level ICD between the remote-interface-unit driver of the board
             * support package and each remote interface unit: the register access frame AABP-1
             * carries, the address and data widths, and the two register maps. */
        @InterfaceControl { authority = "avionics"; document = "SCD-023"; revision = "A"; status = IcdStatus::draft; }
        attribute registerAddressWidth : Natural = 8;
        attribute registerDataWidth : Natural = 16;
        attribute registerCount : Natural = 256;
        attribute accessFrameLength : StorageCapacityValue = 14.0 [B];
        attribute burstLength : Natural = 64;
        part thermalPropulsionMap : ThermalPropulsionRiuRegisterMap;
        part mechanismMap : MechanismRiuRegisterMap;
        assert constraint mapsFitTheAddressWidth {
            doc /* Both maps use the address space the access frame addresses. */
            thermalPropulsionMap.addressLimit == registerCount and mechanismMap.addressLimit == registerCount
        }
        assert constraint burstsAreRegisterBlocks {
            doc /* A burst reads at most the thermistor bank in one access. */
            burstLength <= registerCount
        }
        bind a.telemetry.dataRate = b.telemetry.dataRate;
        flow of Telemetry from b.telemetry to a.telemetry;
        flow of Telecommand from a.telecommand to b.telecommand;
    }

    // ---- 7. The far ends and the tie to the flight software ----------------------------------
    part def BusRemoteInterfaceUnit :> RemoteInterfaceUnit {
        doc /* A remote interface unit seen from the bus: the unit of the tug structure with its
             * remote-terminal port on the on-board data bus. */
        port bus : ~DataBusPort;
    }
    part def MeridianPacketGateway {
        doc /* The Meridian ground entry point of the packet interface: where transfer frames
             * from the stations become space packets for the operations centre and commands
             * become frames. */
        port packets : ~PacketPort;
    }
    part def WrenRelayEndpoint {
        doc /* Wren's end of the relay profile: its software bus node behind the proximity
             * transceiver. */
        port relay : ~DataBusPort;
    }

    part argentSoftwareIcds {
        doc /* The flight software of Argent with every software ICD attached: the message
             * topics between its applications, the AABP-1 protocol to the two remote interface
             * units, the MLS-2 profile to the Meridian gateway, the relay profile to Wren and the
             * register maps of the remote interface units. */
        part software : ArgentFlightSoftware;
        part catalogue : MessageCatalogue;
        part thermalPropulsionRiu : BusRemoteInterfaceUnit;
        part mechanismRiu : BusRemoteInterfaceUnit;
        part gateway : MeridianPacketGateway;
        part wren : WrenRelayEndpoint;

        interface attitudeStateTopic : FanoutTopic connect (publisher ::> software.gnc.bus, subscriberA ::> software.autonomy.bus, subscriberB ::> software.sepControl.bus) {
            doc /* Guidance publishes the attitude state to autonomy and electric propulsion. */
            ref item :>> payload : AttitudeStateMessage;
        }
        interface navigationStateTopic : FanoutTopic connect (publisher ::> software.gnc.bus, subscriberA ::> software.autonomy.bus, subscriberB ::> software.inspectorHandling.bus) {
            doc /* Guidance publishes the navigation state to autonomy and inspector handling. */
            ref item :>> payload : NavigationStateMessage;
        }
        interface thrusterStatusTopic : FanoutTopic connect (publisher ::> software.sepControl.bus, subscriberA ::> software.powerManagement.bus, subscriberB ::> software.fdir.bus) {
            doc /* Electric propulsion publishes thruster status to power management and fault protection. */
            ref item :>> payload : ThrusterStatusMessage;
        }
        interface powerStateTopic : BroadcastTopic connect (publisher ::> software.powerManagement.bus, subscriberA ::> software.modeManagement.bus, subscriberB ::> software.thermalControl.bus, subscriberC ::> software.fdir.bus) {
            doc /* Power management publishes the power state to mode management, thermal control and fault protection. */
            ref item :>> payload : PowerStateMessage;
        }
        interface thermalStateTopic : FanoutTopic connect (publisher ::> software.thermalControl.bus, subscriberA ::> software.powerManagement.bus, subscriberB ::> software.fdir.bus) {
            doc /* Thermal control publishes the thermal state to power management and fault protection. */
            ref item :>> payload : ThermalStateMessage;
        }
        interface linkStatusTopic : FanoutTopic connect (publisher ::> software.telecom.bus, subscriberA ::> software.modeManagement.bus, subscriberB ::> software.fdir.bus) {
            doc /* Telecom publishes link status to mode management and fault protection. */
            ref item :>> payload : LinkStatusMessage;
        }
        interface captureStateTopic : FanoutTopic connect (publisher ::> software.captureControl.bus, subscriberA ::> software.gnc.bus, subscriberB ::> software.autonomy.bus) {
            doc /* Capture control publishes the capture state to guidance and autonomy. */
            ref item :>> payload : CaptureStateMessage;
        }
        interface relayStatusTopic : FanoutTopic connect (publisher ::> software.inspectorHandling.bus, subscriberA ::> software.autonomy.bus, subscriberB ::> software.telecom.bus) {
            doc /* Inspector handling publishes relay status to autonomy and telecom. */
            ref item :>> payload : RelayStatusMessage;
        }
        interface faultReportTopic : FanoutTopic connect (publisher ::> software.fdir.bus, subscriberA ::> software.modeManagement.bus, subscriberB ::> software.autonomy.bus) {
            doc /* Fault protection publishes fault reports to mode management and autonomy. */
            ref item :>> payload : FaultReportMessage;
        }
        interface modeChangeTopic : BroadcastTopic connect (publisher ::> software.modeManagement.bus, subscriberA ::> software.gnc.bus, subscriberB ::> software.sepControl.bus, subscriberC ::> software.telecom.bus) {
            doc /* Mode management publishes mode changes; guidance, electric propulsion and telecom are the subscribers that change their rate sets. */
            ref item :>> payload : ModeChangeMessage;
        }
        interface sequenceStepTopic : BroadcastTopic connect (publisher ::> software.autonomy.bus, subscriberA ::> software.gnc.bus, subscriberB ::> software.sepControl.bus, subscriberC ::> software.captureControl.bus) {
            doc /* Autonomy releases sequence steps to guidance, electric propulsion and capture control. */
            ref item :>> payload : SequenceStepMessage;
        }
        interface timeTickTopic : FanoutTopic connect (publisher ::> software.time.bus, subscriberA ::> software.cdh.bus, subscriberB ::> software.housekeeping.bus) {
            doc /* The time service publishes the tick; command and data handling stamps packets with it and housekeeping paces its sampling. */
            ref item :>> payload : TimeTickMessage;
        }

        interface thermalPropulsionRiuBus : OnBoardBusProtocolIcd connect software.boardSupport.deviceBus to thermalPropulsionRiu.bus {
            doc /* AABP-1 between the bus controller and the thermal and propulsion remote interface unit. */
        }
        interface mechanismRiuBus : OnBoardBusProtocolIcd connect software.boardSupport.deviceBus to mechanismRiu.bus {
            doc /* AABP-1 between the bus controller and the mechanism remote interface unit. */
        }
        interface thermalPropulsionRiuRegisters : RemoteInterfaceUnitRegisterIcd connect software.boardSupport.deviceBus to thermalPropulsionRiu.bus {
            doc /* Register access to the thermal and propulsion remote interface unit. */
        }
        interface mechanismRiuRegisters : RemoteInterfaceUnitRegisterIcd connect software.boardSupport.deviceBus to mechanismRiu.bus {
            doc /* Register access to the mechanism remote interface unit. */
        }
        interface spaceLinkProfile : SpaceLinkProfileIcd connect software.telecom.spaceLink to gateway.packets {
            doc /* MLS-2 between the telecom application and the Meridian packet gateway. */
        }
        interface inspectorRelayProfile : InspectorRelaySoftwareIcd connect software.inspectorHandling.relay to wren.relay {
            doc /* The relay profile between inspector handling and Wren. */
        }
    }

    // ---- 8. Interface requirements and their verification -------------------------------------
    requirement <'TI-120'> busProtocolConformance : InterfaceRequirement {
        doc /* The board support package and every remote terminal shall conform to SCD-020:
             * AABP-1 frames of at most 1 024 B with an 8 B header and a 16-bit checksum, 32
             * addresses, 64 schedule slots per 125 ms polling period, two retries before a
             * fault is raised. */
        attribute :>> icdDocument = "SCD-020";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
    }
    requirement <'TI-121'> spaceLinkProfileConformance : InterfaceRequirement {
        doc /* The telecom application and the Meridian packet gateway shall conform to
             * SCD-021: CCSDS Space Packets with a 10 B time-code secondary header in 1 115 B
             * transfer frames on eight virtual channels, the rate set of the current tug mode,
             * and the 2 000 bit/s safe rate set in safe and abort-hold modes. */
        attribute :>> icdDocument = "SCD-021";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::acceptance; }
    }
    requirement <'TI-122'> relayProfileConformance : InterfaceRequirement {
        doc /* The inspector-handling application and Wren shall conform to SCD-022: AABP-1
             * frames tunnelled over the proximity link, identifiers 128–159, acknowledgement
             * within 2 s, three retries, 200 MB store-and-forward on the tug. */
        attribute :>> icdDocument = "SCD-022";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::acceptance; }
    }
    requirement <'TI-123'> registerMapConformance : InterfaceRequirement {
        doc /* The remote-interface-unit driver and both remote interface units shall conform
             * to SCD-023: 8-bit register addresses, 16-bit data words, the register maps of the
             * thermal and propulsion unit and of the mechanism unit. */
        attribute :>> icdDocument = "SCD-023";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
    }

    verification busProtocolTest : InterfaceVerification {
        doc /* Bus protocol test on the avionics test bench with the flight bus controller and
             * both remote interface units. */
        attribute :>> icdDocument = "SCD-020";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify busProtocolConformance { doc /* The ICD requirement this case verifies. */ } }
    }
    verification spaceLinkProfileTest : InterfaceVerification {
        doc /* End-to-end packet test through a Meridian station to the operations centre,
             * running every rate set and the fallback to the safe rate set. */
        attribute :>> icdDocument = "SCD-021";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify spaceLinkProfileConformance { doc /* The ICD requirement this case verifies. */ } }
    }
    verification relayProfileTest : InterfaceVerification {
        doc /* Relay profile test with flight Wren on the proximity link in the anechoic
             * chamber, including a store-and-forward backlog. */
        attribute :>> icdDocument = "SCD-022";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify relayProfileConformance { doc /* The ICD requirement this case verifies. */ } }
    }
    verification registerMapTest : InterfaceVerification {
        doc /* Register read-back test of every mapped register on both remote interface units. */
        attribute :>> icdDocument = "SCD-023";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify registerMapConformance { doc /* The ICD requirement this case verifies. */ } }
    }
}
