/*
 * Argent flight software tables. Generated; edit the model or the generator, not this file.
 * Generator: software/gen/generate.py 1.0.0
 * Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
 * Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
 * Source elements:
 *   TethysFlightDictionary::flightDictionary::parameterTables
 *   TethysFlightDictionary::FlightParameterTable
 *   TethysFlightDictionary::ParameterRow
 *   TethysFlightDictionary::flightLimitTable
 *   TethysFlightDictionary::tableLimits
 *   TethysFdir::cruiseLimits
 *   TethysFdir::FaultEvent
 *   TethysFdir::FaultResponse
 */
#ifndef ARGENT_PARAMETERS_H
#define ARGENT_PARAMETERS_H

#include <stdint.h>
#include "argent_enums.h"

typedef struct {
    uint16_t id;
    const char *name;
    argent_application_name_t owner;
    uint16_t table_id;
    double value;
    double minimum;
    double maximum;
    const char *unit;
} argent_parameter_t;

typedef struct {
    uint16_t table_id;
    argent_application_name_t owner;
    uint16_t first_row;
    uint16_t row_count;
} argent_parameter_table_t;

typedef struct {
    const char *name;
    double value;
    const char *unit;
} argent_limit_t;

typedef struct {
    const char *limit_set;
    const char *name;
    double value;
    const char *unit;
} argent_monitor_limit_t;

typedef struct {
    const char *name;
    const char *level;
} argent_fault_event_t;

#define ARGENT_PARAMETER_TABLE_COUNT 12u
#define ARGENT_PARAMETER_ROW_COUNT 48u
#define ARGENT_LIMIT_TABLE_ID 13u
#define ARGENT_LIMIT_ROW_COUNT 6u
#define ARGENT_MONITOR_LIMIT_COUNT 12u
#define ARGENT_FAULT_EVENT_TYPE_COUNT 5u

static const argent_parameter_t argent_parameters[48] = {
    { 1u, "watchdogPeriod", ARGENT_APPLICATION_NAME_CDH, 1u, 5.0, 0.1, 30.0, "s" },
    { 2u, "recorderHighWater", ARGENT_APPLICATION_NAME_CDH, 1u, 0.9, 0.5, 0.99, "1" },
    { 3u, "clockSlewLimit", ARGENT_APPLICATION_NAME_CDH, 1u, 1.0, 0.01, 10.0, "s" },
    { 4u, "downlinkQueueDepth", ARGENT_APPLICATION_NAME_CDH, 1u, 64.0, 8.0, 512.0, "1" },
    { 5u, "slewRateLimit", ARGENT_APPLICATION_NAME_GNC, 2u, 0.01, 0.0001, 0.02, "rad/s" },
    { 6u, "pointingTolerance", ARGENT_APPLICATION_NAME_GNC, 2u, 0.001, 0.0001, 0.1, "rad" },
    { 7u, "wheelSpeedLimit", ARGENT_APPLICATION_NAME_GNC, 2u, 600.0, 100.0, 650.0, "rad/s" },
    { 8u, "desatThreshold", ARGENT_APPLICATION_NAME_GNC, 2u, 0.8, 0.5, 0.95, "1" },
    { 9u, "throttleMinimum", ARGENT_APPLICATION_NAME_SEP_CONTROL, 3u, 0.2, 0.1, 0.5, "1" },
    { 10u, "restartDelay", ARGENT_APPLICATION_NAME_SEP_CONTROL, 3u, 7200.0, 60.0, 86400.0, "s" },
    { 11u, "dischargeTrip", ARGENT_APPLICATION_NAME_SEP_CONTROL, 3u, 32.0, 5.0, 40.0, "A" },
    { 12u, "tankHeaterSetpoint", ARGENT_APPLICATION_NAME_SEP_CONTROL, 3u, 293.0, 273.0, 323.0, "K" },
    { 13u, "endOfChargeVoltage", ARGENT_APPLICATION_NAME_POWER_MANAGEMENT, 4u, 33.0, 28.0, 33.6, "V" },
    { 14u, "busLowTrip", ARGENT_APPLICATION_NAME_POWER_MANAGEMENT, 4u, 26.0, 24.0, 28.0, "V" },
    { 15u, "busHighTrip", ARGENT_APPLICATION_NAME_POWER_MANAGEMENT, 4u, 30.0, 28.0, 32.0, "V" },
    { 16u, "loadShedSoc", ARGENT_APPLICATION_NAME_POWER_MANAGEMENT, 4u, 0.3, 0.1, 0.6, "1" },
    { 17u, "deadband", ARGENT_APPLICATION_NAME_THERMAL_CONTROL, 5u, 2.0, 0.5, 10.0, "K" },
    { 18u, "survivalLow", ARGENT_APPLICATION_NAME_THERMAL_CONTROL, 5u, 243.0, 233.0, 283.0, "K" },
    { 19u, "survivalHigh", ARGENT_APPLICATION_NAME_THERMAL_CONTROL, 5u, 253.0, 243.0, 293.0, "K" },
    { 20u, "heaterPowerCap", ARGENT_APPLICATION_NAME_THERMAL_CONTROL, 5u, 800.0, 50.0, 900.0, "W" },
    { 21u, "defaultDownlinkRate", ARGENT_APPLICATION_NAME_TELECOM, 6u, 2000000.0, 10.0, 4000000.0, "Hz" },
    { 22u, "defaultUplinkRate", ARGENT_APPLICATION_NAME_TELECOM, 6u, 2000.0, 7.8125, 4000.0, "Hz" },
    { 23u, "hgaSlewLimit", ARGENT_APPLICATION_NAME_TELECOM, 6u, 0.005, 0.0001, 0.02, "rad/s" },
    { 24u, "transmitPower", ARGENT_APPLICATION_NAME_TELECOM, 6u, 60.0, 5.0, 100.0, "W" },
    { 25u, "releaseSpeed", ARGENT_APPLICATION_NAME_INSPECTOR_HANDLING, 7u, 0.05, 0.02, 0.2, "m/s" },
    { 26u, "imagingCadence", ARGENT_APPLICATION_NAME_INSPECTOR_HANDLING, 7u, 10.0, 1.0, 600.0, "s" },
    { 27u, "relayRate", ARGENT_APPLICATION_NAME_INSPECTOR_HANDLING, 7u, 1000000.0, 1000.0, 2000000.0, "Hz" },
    { 28u, "contactTimeout", ARGENT_APPLICATION_NAME_INSPECTOR_HANDLING, 7u, 7200.0, 600.0, 86400.0, "s" },
    { 29u, "approachRateLimit", ARGENT_APPLICATION_NAME_CAPTURE_CONTROL, 8u, 0.1, 0.01, 0.5, "m/s" },
    { 30u, "contactForceLimit", ARGENT_APPLICATION_NAME_CAPTURE_CONTROL, 8u, 200.0, 1.0, 500.0, "N" },
    { 31u, "cinchTension", ARGENT_APPLICATION_NAME_CAPTURE_CONTROL, 8u, 1000.0, 10.0, 2000.0, "N" },
    { 32u, "despinTorqueLimit", ARGENT_APPLICATION_NAME_CAPTURE_CONTROL, 8u, 0.5, 0.0, 1.0, "1" },
    { 33u, "planHorizon", ARGENT_APPLICATION_NAME_AUTONOMY, 9u, 86400.0, 3600.0, 604800.0, "s" },
    { 34u, "autonomyLevel", ARGENT_APPLICATION_NAME_AUTONOMY, 9u, 1.0, 0.0, 3.0, "1" },
    { 35u, "waypointHoldDefault", ARGENT_APPLICATION_NAME_AUTONOMY, 9u, 600.0, 0.0, 86400.0, "s" },
    { 36u, "ruleCooldown", ARGENT_APPLICATION_NAME_AUTONOMY, 9u, 60.0, 1.0, 3600.0, "s" },
    { 37u, "commandLossTimeout", ARGENT_APPLICATION_NAME_FDIR, 10u, 604800.0, 3600.0, 2592000.0, "s" },
    { 38u, "flameoutRetries", ARGENT_APPLICATION_NAME_FDIR, 10u, 2.0, 0.0, 5.0, "1" },
    { 39u, "batteryLowFraction", ARGENT_APPLICATION_NAME_FDIR, 10u, 0.3, 0.1, 0.6, "1" },
    { 40u, "impactProbabilityLimit", ARGENT_APPLICATION_NAME_FDIR, 10u, 0.0001, 1e-07, 0.001, "1" },
    { 41u, "transitionTimeout", ARGENT_APPLICATION_NAME_MODE_MANAGEMENT, 11u, 300.0, 1.0, 3600.0, "s" },
    { 42u, "twoStepWindow", ARGENT_APPLICATION_NAME_MODE_MANAGEMENT, 11u, 600.0, 10.0, 3600.0, "s" },
    { 43u, "modeTableId", ARGENT_APPLICATION_NAME_MODE_MANAGEMENT, 11u, 11.0, 0.0, 11.0, "1" },
    { 44u, "autoTransitionDefault", ARGENT_APPLICATION_NAME_MODE_MANAGEMENT, 11u, 1.0, 0.0, 1.0, "1" },
    { 45u, "stagingBufferSize", ARGENT_APPLICATION_NAME_PARAMETER_BOOT_UPDATE, 12u, 65536.0, 4096.0, 65536.0, "1" },
    { 46u, "bootRetryLimit", ARGENT_APPLICATION_NAME_PARAMETER_BOOT_UPDATE, 12u, 3.0, 1.0, 5.0, "1" },
    { 47u, "eepromCycleLimit", ARGENT_APPLICATION_NAME_PARAMETER_BOOT_UPDATE, 12u, 100000.0, 1000.0, 100000.0, "1" },
    { 48u, "tableCount", ARGENT_APPLICATION_NAME_PARAMETER_BOOT_UPDATE, 12u, 12.0, 1.0, 12.0, "1" },
};

static const argent_parameter_table_t argent_parameter_tables[12] = {
    { 1u, ARGENT_APPLICATION_NAME_CDH, 0u, 4u },
    { 2u, ARGENT_APPLICATION_NAME_GNC, 4u, 4u },
    { 3u, ARGENT_APPLICATION_NAME_SEP_CONTROL, 8u, 4u },
    { 4u, ARGENT_APPLICATION_NAME_POWER_MANAGEMENT, 12u, 4u },
    { 5u, ARGENT_APPLICATION_NAME_THERMAL_CONTROL, 16u, 4u },
    { 6u, ARGENT_APPLICATION_NAME_TELECOM, 20u, 4u },
    { 7u, ARGENT_APPLICATION_NAME_INSPECTOR_HANDLING, 24u, 4u },
    { 8u, ARGENT_APPLICATION_NAME_CAPTURE_CONTROL, 28u, 4u },
    { 9u, ARGENT_APPLICATION_NAME_AUTONOMY, 32u, 4u },
    { 10u, ARGENT_APPLICATION_NAME_FDIR, 36u, 4u },
    { 11u, ARGENT_APPLICATION_NAME_MODE_MANAGEMENT, 40u, 4u },
    { 12u, ARGENT_APPLICATION_NAME_PARAMETER_BOOT_UPDATE, 44u, 4u },
};

static const argent_limit_t argent_limit_table[6] = {
    { "commandLossTimeout", 7.0, "d" },
    { "thrusterRestartDelay", 2.0, "h" },
    { "maximumFlameoutRetries", 2.0, "" },
    { "batteryLowFraction", 0.3, "" },
    { "earthExclusionRadius", 63781.37, "km" },
    { "maximumImpactProbability", 0.0001, "" },
};

static const argent_monitor_limit_t argent_monitor_limits[12] = {
    { "TethysFdir::cruiseLimits", "commandLossTimeout", 7.0, "d" },
    { "TethysFdir::cruiseLimits", "thrusterRestartDelay", 2.0, "h" },
    { "TethysFdir::cruiseLimits", "maximumFlameoutRetries", 2.0, "" },
    { "TethysFdir::cruiseLimits", "batteryLowFraction", 0.3, "" },
    { "TethysFdir::cruiseLimits", "earthExclusionRadius", 63781.37, "km" },
    { "TethysFdir::cruiseLimits", "maximumImpactProbability", 0.0001, "" },
    { "TethysFlightDictionary::tableLimits", "commandLossTimeout", 7.0, "d" },
    { "TethysFlightDictionary::tableLimits", "thrusterRestartDelay", 2.0, "h" },
    { "TethysFlightDictionary::tableLimits", "maximumFlameoutRetries", 2.0, "" },
    { "TethysFlightDictionary::tableLimits", "batteryLowFraction", 0.3, "" },
    { "TethysFlightDictionary::tableLimits", "earthExclusionRadius", 63781.37, "km" },
    { "TethysFlightDictionary::tableLimits", "maximumImpactProbability", 0.0001, "" },
};

static const argent_fault_event_t argent_fault_event_types[5] = {
    { "ThrusterFlameout", "" },
    { "PpuTrip", "" },
    { "AttitudeLoss", "" },
    { "BatteryLow", "" },
    { "ProcessorReset", "" },
};

#endif /* ARGENT_PARAMETERS_H */
