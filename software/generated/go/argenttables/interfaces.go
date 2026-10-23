// Argent flight software tables. Generated; edit the model or the generator, not this file.
// Generator: software/gen/generate.py 1.0.0
// Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
// Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
// Source elements:
//   TethysSoftwareIcds::MessageCatalogue
//   TethysSoftwareIcds::argentSoftwareIcds (topics)
//   TethysSoftwareIcds::OnBoardBusProtocolIcd
//   TethysSoftwareIcds::SpaceLinkProfileIcd
//   TethysSoftwareIcds::InspectorRelaySoftwareIcd
//   TethysSoftwareIcds::ThermalPropulsionRiuRegisterMap
//   TethysSoftwareIcds::MechanismRiuRegisterMap

package argenttables

type Message struct {
	Name        string
	Type        string
	Apid        int
	LengthBytes float64
	PeriodS     *float64
}

var Messages = []Message{
	{"attitudeState", "AttitudeStateMessage", 16, 128.0, F(0.1)},
	{"navigationState", "NavigationStateMessage", 17, 160.0, F(1.0)},
	{"thrusterStatus", "ThrusterStatusMessage", 18, 96.0, F(1.0)},
	{"powerState", "PowerStateMessage", 19, 112.0, F(1.0)},
	{"thermalState", "ThermalStateMessage", 20, 256.0, F(10.0)},
	{"linkStatus", "LinkStatusMessage", 21, 48.0, F(1.0)},
	{"captureState", "CaptureStateMessage", 22, 144.0, F(0.1)},
	{"relayStatus", "RelayStatusMessage", 23, 80.0, F(1.0)},
	{"faultReport", "FaultReportMessage", 24, 64.0, F(0.0)},
	{"modeChange", "ModeChangeMessage", 25, 32.0, F(0.0)},
	{"sequenceStep", "SequenceStepMessage", 26, 48.0, F(0.0)},
	{"timeTick", "TimeTickMessage", 27, 16.0, F(1.0)},
}

type TopicEnd struct {
	End     string
	Feature string
}

type Topic struct {
	Name    string
	Kind    string
	Payload string
	Ends    []TopicEnd
}

var Topics = []Topic{
	{"attitudeStateTopic", "FanoutTopic", "AttitudeStateMessage", []TopicEnd{{"publisher", "software.gnc.bus"}, {"subscriberA", "software.autonomy.bus"}, {"subscriberB", "software.sepControl.bus"}}},
	{"navigationStateTopic", "FanoutTopic", "NavigationStateMessage", []TopicEnd{{"publisher", "software.gnc.bus"}, {"subscriberA", "software.autonomy.bus"}, {"subscriberB", "software.inspectorHandling.bus"}}},
	{"thrusterStatusTopic", "FanoutTopic", "ThrusterStatusMessage", []TopicEnd{{"publisher", "software.sepControl.bus"}, {"subscriberA", "software.powerManagement.bus"}, {"subscriberB", "software.fdir.bus"}}},
	{"powerStateTopic", "BroadcastTopic", "PowerStateMessage", []TopicEnd{{"publisher", "software.powerManagement.bus"}, {"subscriberA", "software.modeManagement.bus"}, {"subscriberB", "software.thermalControl.bus"}, {"subscriberC", "software.fdir.bus"}}},
	{"thermalStateTopic", "FanoutTopic", "ThermalStateMessage", []TopicEnd{{"publisher", "software.thermalControl.bus"}, {"subscriberA", "software.powerManagement.bus"}, {"subscriberB", "software.fdir.bus"}}},
	{"linkStatusTopic", "FanoutTopic", "LinkStatusMessage", []TopicEnd{{"publisher", "software.telecom.bus"}, {"subscriberA", "software.modeManagement.bus"}, {"subscriberB", "software.fdir.bus"}}},
	{"captureStateTopic", "FanoutTopic", "CaptureStateMessage", []TopicEnd{{"publisher", "software.captureControl.bus"}, {"subscriberA", "software.gnc.bus"}, {"subscriberB", "software.autonomy.bus"}}},
	{"relayStatusTopic", "FanoutTopic", "RelayStatusMessage", []TopicEnd{{"publisher", "software.inspectorHandling.bus"}, {"subscriberA", "software.autonomy.bus"}, {"subscriberB", "software.telecom.bus"}}},
	{"faultReportTopic", "FanoutTopic", "FaultReportMessage", []TopicEnd{{"publisher", "software.fdir.bus"}, {"subscriberA", "software.modeManagement.bus"}, {"subscriberB", "software.autonomy.bus"}}},
	{"modeChangeTopic", "BroadcastTopic", "ModeChangeMessage", []TopicEnd{{"publisher", "software.modeManagement.bus"}, {"subscriberA", "software.gnc.bus"}, {"subscriberB", "software.sepControl.bus"}, {"subscriberC", "software.telecom.bus"}}},
	{"sequenceStepTopic", "BroadcastTopic", "SequenceStepMessage", []TopicEnd{{"publisher", "software.autonomy.bus"}, {"subscriberA", "software.gnc.bus"}, {"subscriberB", "software.sepControl.bus"}, {"subscriberC", "software.captureControl.bus"}}},
	{"timeTickTopic", "FanoutTopic", "TimeTickMessage", []TopicEnd{{"publisher", "software.time.bus"}, {"subscriberA", "software.cdh.bus"}, {"subscriberB", "software.housekeeping.bus"}}},
}

type IcdParameter struct {
	Icd    string
	Name   string
	Value  string
	Number *float64
	Unit   string
}

var IcdParameters = []IcdParameter{
	{"OnBoardBusProtocolIcd", "designation", "AABP-1", nil, ""},
	{"OnBoardBusProtocolIcd", "frameHeaderLength", "8.0", F(8.0), "B"},
	{"OnBoardBusProtocolIcd", "frameTrailerLength", "2.0", F(2.0), "B"},
	{"OnBoardBusProtocolIcd", "maximumFrameLength", "1024.0", F(1024.0), "B"},
	{"OnBoardBusProtocolIcd", "addressWidth", "5", F(5.0), ""},
	{"OnBoardBusProtocolIcd", "nodeCount", "32", F(32.0), ""},
	{"OnBoardBusProtocolIcd", "broadcastAddress", "31", F(31.0), ""},
	{"OnBoardBusProtocolIcd", "controllerAddress", "0", F(0.0), ""},
	{"OnBoardBusProtocolIcd", "majorFrame", "0.125", F(0.125), "s"},
	{"OnBoardBusProtocolIcd", "scheduleSlotCount", "64", F(64.0), ""},
	{"OnBoardBusProtocolIcd", "slotDuration", "0.001953125", F(0.001953125), "s"},
	{"OnBoardBusProtocolIcd", "checksumWidth", "16", F(16.0), ""},
	{"OnBoardBusProtocolIcd", "retryLimit", "2", F(2.0), ""},
	{"OnBoardBusProtocolIcd", "checksumFailure", "requestRetry", nil, ""},
	{"OnBoardBusProtocolIcd", "retryExhausted", "raiseFault", nil, ""},
	{"OnBoardBusProtocolIcd", "unknownAddress", "discardAndCount", nil, ""},
	{"SpaceLinkProfileIcd", "designation", "MLS-2", nil, ""},
	{"SpaceLinkProfileIcd", "packetStandard", "CCSDS Space Packet, version 1", nil, ""},
	{"SpaceLinkProfileIcd", "transferFrameLength", "1115.0", F(1115.0), "B"},
	{"SpaceLinkProfileIcd", "frameHeaderLength", "6.0", F(6.0), "B"},
	{"SpaceLinkProfileIcd", "frameTrailerLength", "4.0", F(4.0), "B"},
	{"SpaceLinkProfileIcd", "secondaryHeaderLength", "10.0", F(10.0), "B"},
	{"SpaceLinkProfileIcd", "timeCode", "unsegmented, 32-bit seconds and 16-bit fraction", nil, ""},
	{"SpaceLinkProfileIcd", "timeCorrelationPeriod", "60.0", F(60.0), "s"},
	{"SpaceLinkProfileIcd", "dictionaryVersionWidth", "16", F(16.0), ""},
	{"SpaceLinkProfileIcd", "virtualChannelCount", "8", F(8.0), ""},
	{"SpaceLinkProfileIcd", "realTimeVirtualChannel", "0", F(0.0), ""},
	{"SpaceLinkProfileIcd", "playbackVirtualChannel", "1", F(1.0), ""},
	{"SpaceLinkProfileIcd", "eventVirtualChannel", "2", F(2.0), ""},
	{"SpaceLinkProfileIcd", "fileTransferVirtualChannel", "3", F(3.0), ""},
	{"SpaceLinkProfileIcd", "idleVirtualChannel", "7", F(7.0), ""},
	{"SpaceLinkProfileIcd", "minimumDownlinkRate", "2000.0", F(2000.0), "bit/s"},
	{"SpaceLinkProfileIcd", "maximumDownlinkRate", "4000000.0", F(4000000.0), "bit/s"},
	{"SpaceLinkProfileIcd", "uplinkRateFloor", "2000.0", F(2000.0), "bit/s"},
	{"InspectorRelaySoftwareIcd", "designation", "AABP-1 over TI-004", nil, ""},
	{"InspectorRelaySoftwareIcd", "forwardCommandRate", "9600.0", F(9600.0), "bit/s"},
	{"InspectorRelaySoftwareIcd", "returnTelemetryRate", "1000000.0", F(1000000.0), "bit/s"},
	{"InspectorRelaySoftwareIcd", "relayApidBase", "128", F(128.0), ""},
	{"InspectorRelaySoftwareIcd", "relayApidCount", "32", F(32.0), ""},
	{"InspectorRelaySoftwareIcd", "storeAndForwardCapacity", "200000000.0", F(200000000.0), "B"},
	{"InspectorRelaySoftwareIcd", "acknowledgementTimeout", "2.0", F(2.0), "s"},
	{"InspectorRelaySoftwareIcd", "retryLimit", "3", F(3.0), ""},
	{"InspectorRelaySoftwareIcd", "maximumRelayLatency", "5.0", F(5.0), "s"},
}

type Register struct {
	Map       string
	Name      string
	Address   int
	WidthBits int
	Meaning   string
	Access    string
}

var Registers = []Register{
	{"ThermalPropulsionRiuRegisterMap", "status", 0, 16, "unit status and fault flags", "readOnly"},
	{"ThermalPropulsionRiuRegisterMap", "control", 1, 16, "unit control: reset, self-test, watchdog enable", "readWrite"},
	{"ThermalPropulsionRiuRegisterMap", "thermistorBank", 16, 16, "first of 64 thermistor readings, one register each", "readOnly"},
	{"ThermalPropulsionRiuRegisterMap", "heaterEnable", 96, 16, "heater enable bits, one per heater circuit", "readWrite"},
	{"ThermalPropulsionRiuRegisterMap", "heaterDuty", 97, 16, "first of 16 heater duty-cycle settings", "readWrite"},
	{"ThermalPropulsionRiuRegisterMap", "valveCommand", 128, 16, "latch-valve open and close pulses", "writeOnly"},
	{"ThermalPropulsionRiuRegisterMap", "valvePosition", 129, 16, "latch-valve position indicators", "readOnly"},
	{"ThermalPropulsionRiuRegisterMap", "tankPressure", 130, 16, "xenon tank pressure transducer reading", "readOnly"},
	{"MechanismRiuRegisterMap", "status", 0, 16, "unit status and fault flags", "readOnly"},
	{"MechanismRiuRegisterMap", "control", 1, 16, "unit control: reset, self-test, watchdog enable", "readWrite"},
	{"MechanismRiuRegisterMap", "armMotorCommand", 32, 16, "first of 4 capture-arm motor rate commands", "readWrite"},
	{"MechanismRiuRegisterMap", "armPosition", 36, 16, "first of 4 capture-arm resolver positions", "readOnly"},
	{"MechanismRiuRegisterMap", "contactForce", 40, 16, "first of 4 contact-pad force readings", "readOnly"},
	{"MechanismRiuRegisterMap", "dispenserCommand", 64, 16, "dispenser release and retention pulses", "writeOnly"},
	{"MechanismRiuRegisterMap", "dockingRingCommand", 80, 16, "docking ring extend, retract and latch", "readWrite"},
	{"MechanismRiuRegisterMap", "dockingRingStatus", 81, 16, "docking ring position and latch indicators", "readOnly"},
}

type RegisterMap struct {
	Name          string
	Source        string
	AddressLimit  int
	DataWidthBits int
	RegisterCount int
}

var RegisterMaps = []RegisterMap{
	{"ThermalPropulsionRiuRegisterMap", "TethysSoftwareIcds::ThermalPropulsionRiuRegisterMap", 256, 16, 8},
	{"MechanismRiuRegisterMap", "TethysSoftwareIcds::MechanismRiuRegisterMap", 256, 16, 8},
}
