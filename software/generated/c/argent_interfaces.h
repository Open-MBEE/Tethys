/*
 * Argent flight software tables. Generated; edit the model or the generator, not this file.
 * Generator: software/gen/generate.py 1.0.0
 * Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
 * Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
 * Source elements:
 *   TethysSoftwareIcds::MessageCatalogue
 *   TethysSoftwareIcds::argentSoftwareIcds (topics)
 *   TethysSoftwareIcds::OnBoardBusProtocolIcd
 *   TethysSoftwareIcds::SpaceLinkProfileIcd
 *   TethysSoftwareIcds::InspectorRelaySoftwareIcd
 *   TethysSoftwareIcds::ThermalPropulsionRiuRegisterMap
 *   TethysSoftwareIcds::MechanismRiuRegisterMap
 *   TethysSoftwareIcds::RegisterEntry
 */
#ifndef ARGENT_INTERFACES_H
#define ARGENT_INTERFACES_H

#include <stdint.h>
#include "argent_enums.h"

typedef struct {
    const char *name;
    const char *type;
    uint16_t apid;
    double length_bytes;
    double period_s;
} argent_message_t;

typedef struct {
    const char *end;
    const char *feature;
} argent_topic_end_t;

typedef struct {
    const char *name;
    const char *kind;
    const char *payload;
    uint16_t first_end;
    uint16_t end_count;
} argent_topic_t;

typedef struct {
    const char *icd;
    const char *name;
    const char *text;
    double value;
    const char *unit;
} argent_icd_parameter_t;

typedef struct {
    const char *name;
    uint16_t address;
    uint16_t width_bits;
    const char *meaning;
    argent_register_access_t access;
} argent_register_t;

typedef struct {
    const char *name;
    uint16_t address_limit;
    uint16_t data_width_bits;
    uint16_t first_register;
    uint16_t register_count;
} argent_register_map_t;

#define ARGENT_MESSAGE_COUNT 12u
#define ARGENT_TOPIC_COUNT 12u
#define ARGENT_TOPIC_END_COUNT 39u
#define ARGENT_ICD_PARAMETER_COUNT 43u
#define ARGENT_REGISTER_COUNT 16u
#define ARGENT_REGISTER_MAP_COUNT 2u

static const argent_message_t argent_messages[12] = {
    { "attitudeState", "AttitudeStateMessage", 16u, 128.0, 0.1 },
    { "navigationState", "NavigationStateMessage", 17u, 160.0, 1.0 },
    { "thrusterStatus", "ThrusterStatusMessage", 18u, 96.0, 1.0 },
    { "powerState", "PowerStateMessage", 19u, 112.0, 1.0 },
    { "thermalState", "ThermalStateMessage", 20u, 256.0, 10.0 },
    { "linkStatus", "LinkStatusMessage", 21u, 48.0, 1.0 },
    { "captureState", "CaptureStateMessage", 22u, 144.0, 0.1 },
    { "relayStatus", "RelayStatusMessage", 23u, 80.0, 1.0 },
    { "faultReport", "FaultReportMessage", 24u, 64.0, 0.0 },
    { "modeChange", "ModeChangeMessage", 25u, 32.0, 0.0 },
    { "sequenceStep", "SequenceStepMessage", 26u, 48.0, 0.0 },
    { "timeTick", "TimeTickMessage", 27u, 16.0, 1.0 },
};

static const argent_topic_end_t argent_topic_ends[39] = {
    { "publisher", "software.gnc.bus" },
    { "subscriberA", "software.autonomy.bus" },
    { "subscriberB", "software.sepControl.bus" },
    { "publisher", "software.gnc.bus" },
    { "subscriberA", "software.autonomy.bus" },
    { "subscriberB", "software.inspectorHandling.bus" },
    { "publisher", "software.sepControl.bus" },
    { "subscriberA", "software.powerManagement.bus" },
    { "subscriberB", "software.fdir.bus" },
    { "publisher", "software.powerManagement.bus" },
    { "subscriberA", "software.modeManagement.bus" },
    { "subscriberB", "software.thermalControl.bus" },
    { "subscriberC", "software.fdir.bus" },
    { "publisher", "software.thermalControl.bus" },
    { "subscriberA", "software.powerManagement.bus" },
    { "subscriberB", "software.fdir.bus" },
    { "publisher", "software.telecom.bus" },
    { "subscriberA", "software.modeManagement.bus" },
    { "subscriberB", "software.fdir.bus" },
    { "publisher", "software.captureControl.bus" },
    { "subscriberA", "software.gnc.bus" },
    { "subscriberB", "software.autonomy.bus" },
    { "publisher", "software.inspectorHandling.bus" },
    { "subscriberA", "software.autonomy.bus" },
    { "subscriberB", "software.telecom.bus" },
    { "publisher", "software.fdir.bus" },
    { "subscriberA", "software.modeManagement.bus" },
    { "subscriberB", "software.autonomy.bus" },
    { "publisher", "software.modeManagement.bus" },
    { "subscriberA", "software.gnc.bus" },
    { "subscriberB", "software.sepControl.bus" },
    { "subscriberC", "software.telecom.bus" },
    { "publisher", "software.autonomy.bus" },
    { "subscriberA", "software.gnc.bus" },
    { "subscriberB", "software.sepControl.bus" },
    { "subscriberC", "software.captureControl.bus" },
    { "publisher", "software.time.bus" },
    { "subscriberA", "software.cdh.bus" },
    { "subscriberB", "software.housekeeping.bus" },
};

static const argent_topic_t argent_topics[12] = {
    { "attitudeStateTopic", "FanoutTopic", "AttitudeStateMessage", 0u, 3u },
    { "navigationStateTopic", "FanoutTopic", "NavigationStateMessage", 3u, 3u },
    { "thrusterStatusTopic", "FanoutTopic", "ThrusterStatusMessage", 6u, 3u },
    { "powerStateTopic", "BroadcastTopic", "PowerStateMessage", 9u, 4u },
    { "thermalStateTopic", "FanoutTopic", "ThermalStateMessage", 13u, 3u },
    { "linkStatusTopic", "FanoutTopic", "LinkStatusMessage", 16u, 3u },
    { "captureStateTopic", "FanoutTopic", "CaptureStateMessage", 19u, 3u },
    { "relayStatusTopic", "FanoutTopic", "RelayStatusMessage", 22u, 3u },
    { "faultReportTopic", "FanoutTopic", "FaultReportMessage", 25u, 3u },
    { "modeChangeTopic", "BroadcastTopic", "ModeChangeMessage", 28u, 4u },
    { "sequenceStepTopic", "BroadcastTopic", "SequenceStepMessage", 32u, 4u },
    { "timeTickTopic", "FanoutTopic", "TimeTickMessage", 36u, 3u },
};

static const argent_icd_parameter_t argent_icd_parameters[43] = {
    { "OnBoardBusProtocolIcd", "designation", "AABP-1", 0.0, "" },
    { "OnBoardBusProtocolIcd", "frameHeaderLength", 0, 8.0, "B" },
    { "OnBoardBusProtocolIcd", "frameTrailerLength", 0, 2.0, "B" },
    { "OnBoardBusProtocolIcd", "maximumFrameLength", 0, 1024.0, "B" },
    { "OnBoardBusProtocolIcd", "addressWidth", 0, 5, "" },
    { "OnBoardBusProtocolIcd", "nodeCount", 0, 32, "" },
    { "OnBoardBusProtocolIcd", "broadcastAddress", 0, 31, "" },
    { "OnBoardBusProtocolIcd", "controllerAddress", 0, 0, "" },
    { "OnBoardBusProtocolIcd", "majorFrame", 0, 0.125, "s" },
    { "OnBoardBusProtocolIcd", "scheduleSlotCount", 0, 64, "" },
    { "OnBoardBusProtocolIcd", "slotDuration", 0, 0.001953125, "s" },
    { "OnBoardBusProtocolIcd", "checksumWidth", 0, 16, "" },
    { "OnBoardBusProtocolIcd", "retryLimit", 0, 2, "" },
    { "OnBoardBusProtocolIcd", "checksumFailure", "requestRetry", 0.0, "" },
    { "OnBoardBusProtocolIcd", "retryExhausted", "raiseFault", 0.0, "" },
    { "OnBoardBusProtocolIcd", "unknownAddress", "discardAndCount", 0.0, "" },
    { "SpaceLinkProfileIcd", "designation", "MLS-2", 0.0, "" },
    { "SpaceLinkProfileIcd", "packetStandard", "CCSDS Space Packet, version 1", 0.0, "" },
    { "SpaceLinkProfileIcd", "transferFrameLength", 0, 1115.0, "B" },
    { "SpaceLinkProfileIcd", "frameHeaderLength", 0, 6.0, "B" },
    { "SpaceLinkProfileIcd", "frameTrailerLength", 0, 4.0, "B" },
    { "SpaceLinkProfileIcd", "secondaryHeaderLength", 0, 10.0, "B" },
    { "SpaceLinkProfileIcd", "timeCode", "unsegmented, 32-bit seconds and 16-bit fraction", 0.0, "" },
    { "SpaceLinkProfileIcd", "timeCorrelationPeriod", 0, 60.0, "s" },
    { "SpaceLinkProfileIcd", "dictionaryVersionWidth", 0, 16, "" },
    { "SpaceLinkProfileIcd", "virtualChannelCount", 0, 8, "" },
    { "SpaceLinkProfileIcd", "realTimeVirtualChannel", 0, 0, "" },
    { "SpaceLinkProfileIcd", "playbackVirtualChannel", 0, 1, "" },
    { "SpaceLinkProfileIcd", "eventVirtualChannel", 0, 2, "" },
    { "SpaceLinkProfileIcd", "fileTransferVirtualChannel", 0, 3, "" },
    { "SpaceLinkProfileIcd", "idleVirtualChannel", 0, 7, "" },
    { "SpaceLinkProfileIcd", "minimumDownlinkRate", 0, 2000.0, "bit/s" },
    { "SpaceLinkProfileIcd", "maximumDownlinkRate", 0, 4000000.0, "bit/s" },
    { "SpaceLinkProfileIcd", "uplinkRateFloor", 0, 2000.0, "bit/s" },
    { "InspectorRelaySoftwareIcd", "designation", "AABP-1 over TI-004", 0.0, "" },
    { "InspectorRelaySoftwareIcd", "forwardCommandRate", 0, 9600.0, "bit/s" },
    { "InspectorRelaySoftwareIcd", "returnTelemetryRate", 0, 1000000.0, "bit/s" },
    { "InspectorRelaySoftwareIcd", "relayApidBase", 0, 128, "" },
    { "InspectorRelaySoftwareIcd", "relayApidCount", 0, 32, "" },
    { "InspectorRelaySoftwareIcd", "storeAndForwardCapacity", 0, 200000000.0, "B" },
    { "InspectorRelaySoftwareIcd", "acknowledgementTimeout", 0, 2.0, "s" },
    { "InspectorRelaySoftwareIcd", "retryLimit", 0, 3, "" },
    { "InspectorRelaySoftwareIcd", "maximumRelayLatency", 0, 5.0, "s" },
};

static const argent_register_t argent_registers[16] = {
    { "status", 0u, 16u, "unit status and fault flags", ARGENT_REGISTER_ACCESS_READ_ONLY },
    { "control", 1u, 16u, "unit control: reset, self-test, watchdog enable", ARGENT_REGISTER_ACCESS_READ_WRITE },
    { "thermistorBank", 16u, 16u, "first of 64 thermistor readings, one register each", ARGENT_REGISTER_ACCESS_READ_ONLY },
    { "heaterEnable", 96u, 16u, "heater enable bits, one per heater circuit", ARGENT_REGISTER_ACCESS_READ_WRITE },
    { "heaterDuty", 97u, 16u, "first of 16 heater duty-cycle settings", ARGENT_REGISTER_ACCESS_READ_WRITE },
    { "valveCommand", 128u, 16u, "latch-valve open and close pulses", ARGENT_REGISTER_ACCESS_WRITE_ONLY },
    { "valvePosition", 129u, 16u, "latch-valve position indicators", ARGENT_REGISTER_ACCESS_READ_ONLY },
    { "tankPressure", 130u, 16u, "xenon tank pressure transducer reading", ARGENT_REGISTER_ACCESS_READ_ONLY },
    { "status", 0u, 16u, "unit status and fault flags", ARGENT_REGISTER_ACCESS_READ_ONLY },
    { "control", 1u, 16u, "unit control: reset, self-test, watchdog enable", ARGENT_REGISTER_ACCESS_READ_WRITE },
    { "armMotorCommand", 32u, 16u, "first of 4 capture-arm motor rate commands", ARGENT_REGISTER_ACCESS_READ_WRITE },
    { "armPosition", 36u, 16u, "first of 4 capture-arm resolver positions", ARGENT_REGISTER_ACCESS_READ_ONLY },
    { "contactForce", 40u, 16u, "first of 4 contact-pad force readings", ARGENT_REGISTER_ACCESS_READ_ONLY },
    { "dispenserCommand", 64u, 16u, "dispenser release and retention pulses", ARGENT_REGISTER_ACCESS_WRITE_ONLY },
    { "dockingRingCommand", 80u, 16u, "docking ring extend, retract and latch", ARGENT_REGISTER_ACCESS_READ_WRITE },
    { "dockingRingStatus", 81u, 16u, "docking ring position and latch indicators", ARGENT_REGISTER_ACCESS_READ_ONLY },
};

static const argent_register_map_t argent_register_maps[2] = {
    { "ThermalPropulsionRiuRegisterMap", 256u, 16u, 0u, 8u },
    { "MechanismRiuRegisterMap", 256u, 16u, 8u, 8u },
};

#endif /* ARGENT_INTERFACES_H */
