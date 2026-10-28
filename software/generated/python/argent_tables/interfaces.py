# Argent flight software tables. Generated; edit the model or the generator, not this file.
# Generator: software/gen/generate.py 1.0.0
# Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
# Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
# Source elements:
#   TethysSoftwareIcds::MessageCatalogue
#   TethysSoftwareIcds::argentSoftwareIcds (topics)
#   TethysSoftwareIcds::OnBoardBusProtocolIcd
#   TethysSoftwareIcds::SpaceLinkProfileIcd
#   TethysSoftwareIcds::InspectorRelaySoftwareIcd
#   TethysSoftwareIcds::ThermalPropulsionRiuRegisterMap
#   TethysSoftwareIcds::MechanismRiuRegisterMap

from typing import NamedTuple

class Message(NamedTuple):
    name: str
    type: str
    apid: int
    length_bytes: float
    period_s: float | None

MESSAGES: tuple[Message, ...] = (
    Message('attitudeState', 'AttitudeStateMessage', 16, 128.0, 0.1),
    Message('navigationState', 'NavigationStateMessage', 17, 160.0, 1.0),
    Message('thrusterStatus', 'ThrusterStatusMessage', 18, 96.0, 1.0),
    Message('powerState', 'PowerStateMessage', 19, 112.0, 1.0),
    Message('thermalState', 'ThermalStateMessage', 20, 256.0, 10.0),
    Message('linkStatus', 'LinkStatusMessage', 21, 48.0, 1.0),
    Message('captureState', 'CaptureStateMessage', 22, 144.0, 0.1),
    Message('relayStatus', 'RelayStatusMessage', 23, 80.0, 1.0),
    Message('faultReport', 'FaultReportMessage', 24, 64.0, 0.0),
    Message('modeChange', 'ModeChangeMessage', 25, 32.0, 0.0),
    Message('sequenceStep', 'SequenceStepMessage', 26, 48.0, 0.0),
    Message('timeTick', 'TimeTickMessage', 27, 16.0, 1.0),
)

class Topic(NamedTuple):
    name: str
    kind: str
    payload: str
    ends: tuple[tuple[str, str], ...]

TOPICS: tuple[Topic, ...] = (
    Topic('attitudeStateTopic', 'FanoutTopic', 'AttitudeStateMessage', (('publisher', 'software.gnc.bus'), ('subscriberA', 'software.autonomy.bus'), ('subscriberB', 'software.sepControl.bus'))),
    Topic('navigationStateTopic', 'FanoutTopic', 'NavigationStateMessage', (('publisher', 'software.gnc.bus'), ('subscriberA', 'software.autonomy.bus'), ('subscriberB', 'software.inspectorHandling.bus'))),
    Topic('thrusterStatusTopic', 'FanoutTopic', 'ThrusterStatusMessage', (('publisher', 'software.sepControl.bus'), ('subscriberA', 'software.powerManagement.bus'), ('subscriberB', 'software.fdir.bus'))),
    Topic('powerStateTopic', 'BroadcastTopic', 'PowerStateMessage', (('publisher', 'software.powerManagement.bus'), ('subscriberA', 'software.modeManagement.bus'), ('subscriberB', 'software.thermalControl.bus'), ('subscriberC', 'software.fdir.bus'))),
    Topic('thermalStateTopic', 'FanoutTopic', 'ThermalStateMessage', (('publisher', 'software.thermalControl.bus'), ('subscriberA', 'software.powerManagement.bus'), ('subscriberB', 'software.fdir.bus'))),
    Topic('linkStatusTopic', 'FanoutTopic', 'LinkStatusMessage', (('publisher', 'software.telecom.bus'), ('subscriberA', 'software.modeManagement.bus'), ('subscriberB', 'software.fdir.bus'))),
    Topic('captureStateTopic', 'FanoutTopic', 'CaptureStateMessage', (('publisher', 'software.captureControl.bus'), ('subscriberA', 'software.gnc.bus'), ('subscriberB', 'software.autonomy.bus'))),
    Topic('relayStatusTopic', 'FanoutTopic', 'RelayStatusMessage', (('publisher', 'software.inspectorHandling.bus'), ('subscriberA', 'software.autonomy.bus'), ('subscriberB', 'software.telecom.bus'))),
    Topic('faultReportTopic', 'FanoutTopic', 'FaultReportMessage', (('publisher', 'software.fdir.bus'), ('subscriberA', 'software.modeManagement.bus'), ('subscriberB', 'software.autonomy.bus'))),
    Topic('modeChangeTopic', 'BroadcastTopic', 'ModeChangeMessage', (('publisher', 'software.modeManagement.bus'), ('subscriberA', 'software.gnc.bus'), ('subscriberB', 'software.sepControl.bus'), ('subscriberC', 'software.telecom.bus'))),
    Topic('sequenceStepTopic', 'BroadcastTopic', 'SequenceStepMessage', (('publisher', 'software.autonomy.bus'), ('subscriberA', 'software.gnc.bus'), ('subscriberB', 'software.sepControl.bus'), ('subscriberC', 'software.captureControl.bus'))),
    Topic('timeTickTopic', 'FanoutTopic', 'TimeTickMessage', (('publisher', 'software.time.bus'), ('subscriberA', 'software.cdh.bus'), ('subscriberB', 'software.housekeeping.bus'))),
)

class IcdParameter(NamedTuple):
    icd: str
    name: str
    value: str | int | float | bool
    unit: str

ICD_PARAMETERS: tuple[IcdParameter, ...] = (
    IcdParameter('OnBoardBusProtocolIcd', 'designation', 'AABP-1', ''),
    IcdParameter('OnBoardBusProtocolIcd', 'frameHeaderLength', 8.0, 'B'),
    IcdParameter('OnBoardBusProtocolIcd', 'frameTrailerLength', 2.0, 'B'),
    IcdParameter('OnBoardBusProtocolIcd', 'maximumFrameLength', 1024.0, 'B'),
    IcdParameter('OnBoardBusProtocolIcd', 'addressWidth', 5, ''),
    IcdParameter('OnBoardBusProtocolIcd', 'nodeCount', 32, ''),
    IcdParameter('OnBoardBusProtocolIcd', 'broadcastAddress', 31, ''),
    IcdParameter('OnBoardBusProtocolIcd', 'controllerAddress', 0, ''),
    IcdParameter('OnBoardBusProtocolIcd', 'majorFrame', 0.125, 's'),
    IcdParameter('OnBoardBusProtocolIcd', 'scheduleSlotCount', 64, ''),
    IcdParameter('OnBoardBusProtocolIcd', 'slotDuration', 0.001953125, 's'),
    IcdParameter('OnBoardBusProtocolIcd', 'checksumWidth', 16, ''),
    IcdParameter('OnBoardBusProtocolIcd', 'retryLimit', 2, ''),
    IcdParameter('OnBoardBusProtocolIcd', 'checksumFailure', 'requestRetry', ''),
    IcdParameter('OnBoardBusProtocolIcd', 'retryExhausted', 'raiseFault', ''),
    IcdParameter('OnBoardBusProtocolIcd', 'unknownAddress', 'discardAndCount', ''),
    IcdParameter('SpaceLinkProfileIcd', 'designation', 'MLS-2', ''),
    IcdParameter('SpaceLinkProfileIcd', 'packetStandard', 'CCSDS Space Packet, version 1', ''),
    IcdParameter('SpaceLinkProfileIcd', 'transferFrameLength', 1115.0, 'B'),
    IcdParameter('SpaceLinkProfileIcd', 'frameHeaderLength', 6.0, 'B'),
    IcdParameter('SpaceLinkProfileIcd', 'frameTrailerLength', 4.0, 'B'),
    IcdParameter('SpaceLinkProfileIcd', 'secondaryHeaderLength', 10.0, 'B'),
    IcdParameter('SpaceLinkProfileIcd', 'timeCode', 'unsegmented, 32-bit seconds and 16-bit fraction', ''),
    IcdParameter('SpaceLinkProfileIcd', 'timeCorrelationPeriod', 60.0, 's'),
    IcdParameter('SpaceLinkProfileIcd', 'dictionaryVersionWidth', 16, ''),
    IcdParameter('SpaceLinkProfileIcd', 'virtualChannelCount', 8, ''),
    IcdParameter('SpaceLinkProfileIcd', 'realTimeVirtualChannel', 0, ''),
    IcdParameter('SpaceLinkProfileIcd', 'playbackVirtualChannel', 1, ''),
    IcdParameter('SpaceLinkProfileIcd', 'eventVirtualChannel', 2, ''),
    IcdParameter('SpaceLinkProfileIcd', 'fileTransferVirtualChannel', 3, ''),
    IcdParameter('SpaceLinkProfileIcd', 'idleVirtualChannel', 7, ''),
    IcdParameter('SpaceLinkProfileIcd', 'minimumDownlinkRate', 2000.0, 'bit/s'),
    IcdParameter('SpaceLinkProfileIcd', 'maximumDownlinkRate', 4000000.0, 'bit/s'),
    IcdParameter('SpaceLinkProfileIcd', 'uplinkRateFloor', 2000.0, 'bit/s'),
    IcdParameter('InspectorRelaySoftwareIcd', 'designation', 'AABP-1 over TI-004', ''),
    IcdParameter('InspectorRelaySoftwareIcd', 'forwardCommandRate', 9600.0, 'bit/s'),
    IcdParameter('InspectorRelaySoftwareIcd', 'returnTelemetryRate', 1000000.0, 'bit/s'),
    IcdParameter('InspectorRelaySoftwareIcd', 'relayApidBase', 128, ''),
    IcdParameter('InspectorRelaySoftwareIcd', 'relayApidCount', 32, ''),
    IcdParameter('InspectorRelaySoftwareIcd', 'storeAndForwardCapacity', 200000000.0, 'B'),
    IcdParameter('InspectorRelaySoftwareIcd', 'acknowledgementTimeout', 2.0, 's'),
    IcdParameter('InspectorRelaySoftwareIcd', 'retryLimit', 3, ''),
    IcdParameter('InspectorRelaySoftwareIcd', 'maximumRelayLatency', 5.0, 's'),
)

class Register(NamedTuple):
    map: str
    name: str
    address: int
    width_bits: int
    meaning: str
    access: str

REGISTERS: tuple[Register, ...] = (
    Register('ThermalPropulsionRiuRegisterMap', 'status', 0, 16, 'unit status and fault flags', 'readOnly'),
    Register('ThermalPropulsionRiuRegisterMap', 'control', 1, 16, 'unit control: reset, self-test, watchdog enable', 'readWrite'),
    Register('ThermalPropulsionRiuRegisterMap', 'thermistorBank', 16, 16, 'first of 64 thermistor readings, one register each', 'readOnly'),
    Register('ThermalPropulsionRiuRegisterMap', 'heaterEnable', 96, 16, 'heater enable bits, one per heater circuit', 'readWrite'),
    Register('ThermalPropulsionRiuRegisterMap', 'heaterDuty', 97, 16, 'first of 16 heater duty-cycle settings', 'readWrite'),
    Register('ThermalPropulsionRiuRegisterMap', 'valveCommand', 128, 16, 'latch-valve open and close pulses', 'writeOnly'),
    Register('ThermalPropulsionRiuRegisterMap', 'valvePosition', 129, 16, 'latch-valve position indicators', 'readOnly'),
    Register('ThermalPropulsionRiuRegisterMap', 'tankPressure', 130, 16, 'xenon tank pressure transducer reading', 'readOnly'),
    Register('MechanismRiuRegisterMap', 'status', 0, 16, 'unit status and fault flags', 'readOnly'),
    Register('MechanismRiuRegisterMap', 'control', 1, 16, 'unit control: reset, self-test, watchdog enable', 'readWrite'),
    Register('MechanismRiuRegisterMap', 'armMotorCommand', 32, 16, 'first of 4 capture-arm motor rate commands', 'readWrite'),
    Register('MechanismRiuRegisterMap', 'armPosition', 36, 16, 'first of 4 capture-arm resolver positions', 'readOnly'),
    Register('MechanismRiuRegisterMap', 'contactForce', 40, 16, 'first of 4 contact-pad force readings', 'readOnly'),
    Register('MechanismRiuRegisterMap', 'dispenserCommand', 64, 16, 'dispenser release and retention pulses', 'writeOnly'),
    Register('MechanismRiuRegisterMap', 'dockingRingCommand', 80, 16, 'docking ring extend, retract and latch', 'readWrite'),
    Register('MechanismRiuRegisterMap', 'dockingRingStatus', 81, 16, 'docking ring position and latch indicators', 'readOnly'),
)

class RegisterMap(NamedTuple):
    name: str
    source: str
    address_limit: int
    data_width_bits: int
    register_count: int

REGISTER_MAPS: tuple[RegisterMap, ...] = (
    RegisterMap('ThermalPropulsionRiuRegisterMap', 'TethysSoftwareIcds::ThermalPropulsionRiuRegisterMap', 256, 16, 8),
    RegisterMap('MechanismRiuRegisterMap', 'TethysSoftwareIcds::MechanismRiuRegisterMap', 256, 16, 8),
)

ICD_PARAMETERS_BY_NAME = {(p.icd, p.name): p for p in ICD_PARAMETERS}
MESSAGES_BY_APID = {m.apid: m for m in MESSAGES}
