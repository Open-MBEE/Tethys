/*
 * Argent flight software tables. Generated; edit the model or the generator, not this file.
 * Generator: software/gen/generate.py 1.0.0
 * Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
 * Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
 * Source elements:
 *   TethysModes::TugModeTable
 *   TethysModes::SubsystemConfiguration
 *   TethysFlightSoftware::ArgentFlightSoftware (Application parts)
 *   TethysFlightSoftware::Application::activeModes
 *   TethysSoftwareIcds::SpaceLinkProfileIcd (LinkRateSet rows)
 *   TethysFlightTiming::argentBus
 */
#ifndef ARGENT_MODES_H
#define ARGENT_MODES_H

#include <stdint.h>
#include "argent_enums.h"

#define ARGENT_MODE_FLAG_CAPTURE_SYSTEM_ARMED ((uint16_t)1u << 0)
#define ARGENT_MODE_FLAG_HIGH_GAIN_ANTENNA_ON ((uint16_t)1u << 1)
#define ARGENT_MODE_FLAG_HIGH_VOLTAGE_BUS_ON ((uint16_t)1u << 2)
#define ARGENT_MODE_FLAG_PROXIMITY_LINK_ON ((uint16_t)1u << 3)
#define ARGENT_MODE_FLAG_SENSORS_ON ((uint16_t)1u << 4)
#define ARGENT_MODE_FLAG_SEP_THRUSTING ((uint16_t)1u << 5)
#define ARGENT_MODE_FLAG_WHEEL_CONTROL ((uint16_t)1u << 6)

typedef struct {
    argent_tug_mode_t mode;
    const char *name;
    uint16_t configuration_flags;
    argent_application_mask_t active_applications;
    uint16_t rate_set;
    uint16_t bus_slots_used;
} argent_mode_row_t;

typedef struct {
    argent_application_name_t application;
    const char *name;
    const char *definition;
    double rate_hz;
    uint16_t priority;
    argent_software_layer_t layer;
    argent_software_criticality_t criticality;
    argent_mode_mask_t active_modes;
} argent_application_t;

#define ARGENT_MODE_ROW_COUNT 16u
#define ARGENT_MODE_FLAG_COUNT 7u
#define ARGENT_APPLICATION_COUNT 12u

static const char *const argent_mode_flag_names[7] = {
    "captureSystemArmed",
    "highGainAntennaOn",
    "highVoltageBusOn",
    "proximityLinkOn",
    "sensorsOn",
    "sepThrusting",
    "wheelControl",
};

static const argent_mode_row_t argent_mode_table[16] = {
    { ARGENT_TUG_MODE_LAUNCH, "launch", 0x0000u, 0x0000u, 0u, 0u },
    { ARGENT_TUG_MODE_EARLY_OPERATIONS, "earlyOperations", 0x0040u, 0x0f7fu, 1u, 32u },
    { ARGENT_TUG_MODE_COAST, "coast", 0x0042u, 0x0f7fu, 2u, 32u },
    { ARGENT_TUG_MODE_THRUST, "thrust", 0x0064u, 0x0f7fu, 3u, 32u },
    { ARGENT_TUG_MODE_APPROACH, "approach", 0x0076u, 0x0f7fu, 4u, 32u },
    { ARGENT_TUG_MODE_PROXIMITY_OPERATIONS, "proximityOperations", 0x001au, 0x0fffu, 5u, 36u },
    { ARGENT_TUG_MODE_RETREAT, "retreat", 0x001au, 0x0f7fu, 6u, 32u },
    { ARGENT_TUG_MODE_CAPTURE, "capture", 0x0019u, 0x0fffu, 7u, 36u },
    { ARGENT_TUG_MODE_DESPIN, "despin", 0x0000u, 0x0fffu, 8u, 36u },
    { ARGENT_TUG_MODE_STACK_COAST, "stackCoast", 0x0042u, 0x0f7fu, 9u, 32u },
    { ARGENT_TUG_MODE_STACK_THRUST, "stackThrust", 0x0064u, 0x0f7fu, 10u, 32u },
    { ARGENT_TUG_MODE_DRO_HOLD, "droHold", 0x0042u, 0x0f7fu, 11u, 32u },
    { ARGENT_TUG_MODE_DOCKED_PASSIVE, "dockedPassive", 0x000au, 0x0f7fu, 12u, 32u },
    { ARGENT_TUG_MODE_DISPOSAL, "disposal", 0x0064u, 0x0f7fu, 13u, 32u },
    { ARGENT_TUG_MODE_SAFE, "safe", 0x0000u, 0x0f7fu, 14u, 32u },
    { ARGENT_TUG_MODE_ABORT_HOLD, "abortHold", 0x0042u, 0x0f7fu, 15u, 32u },
};

static const argent_application_t argent_applications[12] = {
    { ARGENT_APPLICATION_NAME_CDH, "cdh", "CdhApplication", 1.0, 2u, ARGENT_SOFTWARE_LAYER_APPLICATION, ARGENT_SOFTWARE_CRITICALITY_MISSION_CRITICAL, 0xfffeu },
    { ARGENT_APPLICATION_NAME_GNC, "gnc", "GncApplication", 16.0, 3u, ARGENT_SOFTWARE_LAYER_APPLICATION, ARGENT_SOFTWARE_CRITICALITY_SAFETY_CRITICAL, 0xfffeu },
    { ARGENT_APPLICATION_NAME_SEP_CONTROL, "sepControl", "SepControlApplication", 1.0, 5u, ARGENT_SOFTWARE_LAYER_APPLICATION, ARGENT_SOFTWARE_CRITICALITY_MISSION_CRITICAL, 0xfffeu },
    { ARGENT_APPLICATION_NAME_POWER_MANAGEMENT, "powerManagement", "PowerManagementApplication", 1.0, 4u, ARGENT_SOFTWARE_LAYER_APPLICATION, ARGENT_SOFTWARE_CRITICALITY_MISSION_CRITICAL, 0xfffeu },
    { ARGENT_APPLICATION_NAME_THERMAL_CONTROL, "thermalControl", "ThermalControlApplication", 1.0, 8u, ARGENT_SOFTWARE_LAYER_APPLICATION, ARGENT_SOFTWARE_CRITICALITY_MISSION_CRITICAL, 0xfffeu },
    { ARGENT_APPLICATION_NAME_TELECOM, "telecom", "TelecomApplication", 1.0, 6u, ARGENT_SOFTWARE_LAYER_APPLICATION, ARGENT_SOFTWARE_CRITICALITY_MISSION_CRITICAL, 0xfffeu },
    { ARGENT_APPLICATION_NAME_INSPECTOR_HANDLING, "inspectorHandling", "InspectorHandlingApplication", 1.0, 9u, ARGENT_SOFTWARE_LAYER_APPLICATION, ARGENT_SOFTWARE_CRITICALITY_MISSION_CRITICAL, 0xfffeu },
    { ARGENT_APPLICATION_NAME_CAPTURE_CONTROL, "captureControl", "CaptureControlApplication", 16.0, 7u, ARGENT_SOFTWARE_LAYER_APPLICATION, ARGENT_SOFTWARE_CRITICALITY_SAFETY_CRITICAL, 0x01a0u },
    { ARGENT_APPLICATION_NAME_AUTONOMY, "autonomy", "AutonomyApplication", 1.0, 11u, ARGENT_SOFTWARE_LAYER_APPLICATION, ARGENT_SOFTWARE_CRITICALITY_SAFETY_CRITICAL, 0xfffeu },
    { ARGENT_APPLICATION_NAME_FDIR, "fdir", "FdirApplication", 16.0, 1u, ARGENT_SOFTWARE_LAYER_APPLICATION, ARGENT_SOFTWARE_CRITICALITY_SAFETY_CRITICAL, 0xfffeu },
    { ARGENT_APPLICATION_NAME_MODE_MANAGEMENT, "modeManagement", "ModeManagementApplication", 1.0, 1u, ARGENT_SOFTWARE_LAYER_APPLICATION, ARGENT_SOFTWARE_CRITICALITY_SAFETY_CRITICAL, 0xfffeu },
    { ARGENT_APPLICATION_NAME_PARAMETER_BOOT_UPDATE, "parameterBootUpdate", "ParameterBootUpdateApplication", 1.0, 12u, ARGENT_SOFTWARE_LAYER_APPLICATION, ARGENT_SOFTWARE_CRITICALITY_MISSION_CRITICAL, 0xfffeu },
};

#endif /* ARGENT_MODES_H */
