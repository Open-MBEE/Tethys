/*
 * Argent flight software tables. Generated; edit the model or the generator, not this file.
 * Generator: software/gen/generate.py 1.0.0
 * Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
 * Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
 * Source elements:
 *   TethysFlightBehaviour::SepStringController
 *   TethysFlightBehaviour::PowerManager
 *   TethysFlightBehaviour::ThermalController
 *   TethysFlightBehaviour::TelecomManager
 *   TethysFlightBehaviour::InspectorHandler
 *   TethysFlightBehaviour::CaptureController
 *   TethysFlightBehaviour::RedundancyManager
 *   TethysFlightBehaviour::BootUpdateManager
 *   TethysModes::TugModes
 *   TethysFlightBehaviour::ModeManagementSoftware::dispatcher
 *   TethysFdir::FdirSupervisor
 *   TethysFlightBehaviour::FdirSoftware::responseRelay
 */
#ifndef ARGENT_STATE_MACHINES_H
#define ARGENT_STATE_MACHINES_H

#include <stdint.h>

typedef enum {
    ARGENT_TRIGGER_NONE = 0,
    ARGENT_TRIGGER_EVENT = 1,
    ARGENT_TRIGGER_TIMED = 2
} argent_trigger_kind_t;

typedef struct {
    const char *name;
    const char *qualified_name;
    int16_t parent;
    int16_t initial_substate;
    uint8_t leaf;
    const char *entry_action;
    const char *exit_action;
} argent_state_t;

typedef struct {
    int16_t source;
    int16_t target;
    argent_trigger_kind_t trigger_kind;
    const char *event;
    const char *port;
    const char *timed;
    int16_t guard;
    int16_t effect;
} argent_transition_t;

typedef struct {
    const char *id;
    const char *text;
} argent_named_expression_t;

typedef struct {
    const char *name;
    const char *source;
    int16_t initial_state;
    const argent_state_t *states;
    uint16_t state_count;
    const argent_transition_t *transitions;
    uint16_t transition_count;
    const argent_named_expression_t *guards;
    uint16_t guard_count;
    const argent_named_expression_t *effects;
    uint16_t effect_count;
} argent_state_machine_t;

#define ARGENT_STATE_DONE (-2)
#define ARGENT_STATE_NONE (-1)


/* TethysFlightBehaviour::SepStringController */
typedef enum {
    ARGENT_SEP_STRING_CONTROLLER_STATE_OFF = 0,
    ARGENT_SEP_STRING_CONTROLLER_STATE_STANDBY = 1,
    ARGENT_SEP_STRING_CONTROLLER_STATE_THRUSTING = 2,
    ARGENT_SEP_STRING_CONTROLLER_STATE_DISPOSAL_BURN = 3,
    ARGENT_SEP_STRING_CONTROLLER_STATE_RESTARTING = 4,
    ARGENT_SEP_STRING_CONTROLLER_STATE_RESTARTING_DISPOSAL = 5,
    ARGENT_SEP_STRING_CONTROLLER_STATE_COUNT = 6
} argent_sep_string_controller_state_t;

#define ARGENT_SEP_STRING_CONTROLLER_TRANSITION_COUNT 14u

static const argent_state_t argent_sep_string_controller_states[6] = {
    { "off", "TethysFlightBehaviour::SepStringController::off", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "standby", "TethysFlightBehaviour::SepStringController::standby", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "thrusting", "TethysFlightBehaviour::SepStringController::thrusting", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "arcsStarted := arcsStarted + 1", "" },
    { "disposalBurn", "TethysFlightBehaviour::SepStringController::disposalBurn", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "restarting", "TethysFlightBehaviour::SepStringController::restarting", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "restarts := restarts + 1", "" },
    { "restartingDisposal", "TethysFlightBehaviour::SepStringController::restartingDisposal", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "restarts := restarts + 1", "" },
};

static const argent_transition_t argent_sep_string_controller_transitions[14] = {
    { 0, 1, ARGENT_TRIGGER_EVENT, "SepStandby", "command", "", -1, -1 },
    { 1, 2, ARGENT_TRIGGER_EVENT, "SepThrust", "command", "", -1, -1 },
    { 2, 1, ARGENT_TRIGGER_EVENT, "SepStandby", "command", "", -1, -1 },
    { 2, 4, ARGENT_TRIGGER_EVENT, "ThrusterFlameout", "command", "", -1, -1 },
    { 4, 2, ARGENT_TRIGGER_TIMED, "", "", "after restartDelay", -1, -1 },
    { 1, 3, ARGENT_TRIGGER_EVENT, "SepDisposalBurn", "command", "", -1, 0 },
    { 3, 0, ARGENT_TRIGGER_TIMED, "", "", "after burnDuration", -1, -1 },
    { 3, 5, ARGENT_TRIGGER_EVENT, "ThrusterFlameout", "command", "", -1, -1 },
    { 5, 3, ARGENT_TRIGGER_TIMED, "", "", "after restartDelay", -1, -1 },
    { 1, 0, ARGENT_TRIGGER_EVENT, "SepOff", "command", "", -1, -1 },
    { 2, 0, ARGENT_TRIGGER_EVENT, "SepOff", "command", "", -1, -1 },
    { 3, 0, ARGENT_TRIGGER_EVENT, "SepOff", "command", "", -1, -1 },
    { 4, 0, ARGENT_TRIGGER_EVENT, "SepOff", "command", "", -1, -1 },
    { 5, 0, ARGENT_TRIGGER_EVENT, "SepOff", "command", "", -1, -1 },
};

static const argent_named_expression_t argent_sep_string_controller_guards[1] = {
    { 0, 0 },
};

static const argent_named_expression_t argent_sep_string_controller_effects[1] = {
    { "SEP_STRING_CONTROLLER_E1", "burnDuration := b.duration" },
};


/* TethysFlightBehaviour::PowerManager */
typedef enum {
    ARGENT_POWER_MANAGER_STATE_NOMINAL = 0,
    ARGENT_POWER_MANAGER_STATE_TIER_ONE = 1,
    ARGENT_POWER_MANAGER_STATE_TIER_TWO = 2,
    ARGENT_POWER_MANAGER_STATE_SURVIVAL = 3,
    ARGENT_POWER_MANAGER_STATE_COUNT = 4
} argent_power_manager_state_t;

#define ARGENT_POWER_MANAGER_TRANSITION_COUNT 9u

static const argent_state_t argent_power_manager_states[4] = {
    { "nominal", "TethysFlightBehaviour::PowerManager::nominal", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "tier := LoadShedTier::none", "" },
    { "tierOne", "TethysFlightBehaviour::PowerManager::tierOne", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "shedOne: tier := LoadShedTier::tierOne; shedEvents := shedEvents + 1", "" },
    { "tierTwo", "TethysFlightBehaviour::PowerManager::tierTwo", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "shedTwo: tier := LoadShedTier::tierTwo; shedEvents := shedEvents + 1", "" },
    { "survival", "TethysFlightBehaviour::PowerManager::survival", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "shedAll: tier := LoadShedTier::survival; shedEvents := shedEvents + 1", "" },
};

static const argent_transition_t argent_power_manager_transitions[9] = {
    { 0, 1, ARGENT_TRIGGER_EVENT, "BatteryStateOfCharge", "command", "", 0, -1 },
    { 0, 2, ARGENT_TRIGGER_EVENT, "BatteryStateOfCharge", "command", "", 1, -1 },
    { 1, 2, ARGENT_TRIGGER_EVENT, "BatteryStateOfCharge", "command", "", 1, -1 },
    { 1, 0, ARGENT_TRIGGER_EVENT, "BatteryStateOfCharge", "command", "", 2, -1 },
    { 2, 0, ARGENT_TRIGGER_EVENT, "BatteryStateOfCharge", "command", "", 2, -1 },
    { 0, 3, ARGENT_TRIGGER_EVENT, "LoadShed", "command", "", -1, -1 },
    { 1, 3, ARGENT_TRIGGER_EVENT, "LoadShed", "command", "", -1, -1 },
    { 2, 3, ARGENT_TRIGGER_EVENT, "LoadShed", "command", "", -1, -1 },
    { 3, 0, ARGENT_TRIGGER_EVENT, "LoadRestore", "command", "", -1, -1 },
};

static const argent_named_expression_t argent_power_manager_guards[3] = {
    { "POWER_MANAGER_G1", "b.fraction < tierOneFraction and b.fraction >= limits.batteryLowFraction" },
    { "POWER_MANAGER_G2", "b.fraction < limits.batteryLowFraction" },
    { "POWER_MANAGER_G3", "b.fraction >= restoreFraction" },
};

static const argent_named_expression_t argent_power_manager_effects[1] = {
    { 0, 0 },
};


/* TethysFlightBehaviour::ThermalController */
typedef enum {
    ARGENT_THERMAL_CONTROLLER_STATE_SETPOINT_SELECTION = 0,
    ARGENT_THERMAL_CONTROLLER_STATE_OPERATIONAL = 1,
    ARGENT_THERMAL_CONTROLLER_STATE_SURVIVAL = 2,
    ARGENT_THERMAL_CONTROLLER_STATE_HEATER_LOOP = 3,
    ARGENT_THERMAL_CONTROLLER_STATE_HEATER_OFF = 4,
    ARGENT_THERMAL_CONTROLLER_STATE_HEATER_ON = 5,
    ARGENT_THERMAL_CONTROLLER_STATE_COUNT = 6
} argent_thermal_controller_state_t;

#define ARGENT_THERMAL_CONTROLLER_TRANSITION_COUNT 4u

static const argent_state_t argent_thermal_controller_states[6] = {
    { "setpointSelection", "TethysFlightBehaviour::ThermalController::setpointSelection", ARGENT_STATE_NONE, 1, 0, "", "" },
    { "operational", "TethysFlightBehaviour::ThermalController::setpointSelection::operational", 0, ARGENT_STATE_NONE, 1, "setpoint := operationalSetpoint", "" },
    { "survival", "TethysFlightBehaviour::ThermalController::setpointSelection::survival", 0, ARGENT_STATE_NONE, 1, "setpoint := survivalSetpoint", "" },
    { "heaterLoop", "TethysFlightBehaviour::ThermalController::heaterLoop", ARGENT_STATE_NONE, 4, 0, "", "" },
    { "heaterOff", "TethysFlightBehaviour::ThermalController::heaterLoop::heaterOff", 3, ARGENT_STATE_NONE, 1, "", "" },
    { "heaterOn", "TethysFlightBehaviour::ThermalController::heaterLoop::heaterOn", 3, ARGENT_STATE_NONE, 1, "heaterCycles := heaterCycles + 1", "" },
};

static const argent_transition_t argent_thermal_controller_transitions[4] = {
    { 1, 2, ARGENT_TRIGGER_EVENT, "LoadShed", "command", "", -1, -1 },
    { 2, 1, ARGENT_TRIGGER_EVENT, "LoadRestore", "command", "", -1, -1 },
    { 4, 5, ARGENT_TRIGGER_EVENT, "TemperatureReport", "command", "", 0, -1 },
    { 5, 4, ARGENT_TRIGGER_EVENT, "TemperatureReport", "command", "", 1, -1 },
};

static const argent_named_expression_t argent_thermal_controller_guards[2] = {
    { "THERMAL_CONTROLLER_G1", "t.temperature < setpoint - hysteresis" },
    { "THERMAL_CONTROLLER_G2", "t.temperature > setpoint + hysteresis" },
};

static const argent_named_expression_t argent_thermal_controller_effects[1] = {
    { 0, 0 },
};


/* TethysFlightBehaviour::TelecomManager */
typedef enum {
    ARGENT_TELECOM_MANAGER_STATE_SAFE_RATE = 0,
    ARGENT_TELECOM_MANAGER_STATE_HIGH_GAIN_IDLE = 1,
    ARGENT_TELECOM_MANAGER_STATE_PASS = 2,
    ARGENT_TELECOM_MANAGER_STATE_RELAYING = 3,
    ARGENT_TELECOM_MANAGER_STATE_COUNT = 4
} argent_telecom_manager_state_t;

#define ARGENT_TELECOM_MANAGER_TRANSITION_COUNT 9u

static const argent_state_t argent_telecom_manager_states[4] = {
    { "safeRate", "TethysFlightBehaviour::TelecomManager::safeRate", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "safeRateEntries := safeRateEntries + 1", "" },
    { "highGainIdle", "TethysFlightBehaviour::TelecomManager::highGainIdle", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "pass", "TethysFlightBehaviour::TelecomManager::pass", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "passes := passes + 1", "" },
    { "relaying", "TethysFlightBehaviour::TelecomManager::relaying", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
};

static const argent_transition_t argent_telecom_manager_transitions[9] = {
    { 0, 1, ARGENT_TRIGGER_EVENT, "HighGainSelect", "command", "", -1, -1 },
    { 1, 2, ARGENT_TRIGGER_EVENT, "PassStart", "command", "", -1, -1 },
    { 2, 1, ARGENT_TRIGGER_EVENT, "PassEnd", "command", "", -1, -1 },
    { 2, 1, ARGENT_TRIGGER_TIMED, "", "", "after passDuration", -1, -1 },
    { 1, 3, ARGENT_TRIGGER_EVENT, "RelayEnable", "command", "", -1, -1 },
    { 3, 1, ARGENT_TRIGGER_EVENT, "RelayDisable", "command", "", -1, -1 },
    { 1, 0, ARGENT_TRIGGER_EVENT, "LowGainSelect", "command", "", -1, -1 },
    { 2, 0, ARGENT_TRIGGER_EVENT, "LowGainSelect", "command", "", -1, -1 },
    { 3, 0, ARGENT_TRIGGER_EVENT, "LowGainSelect", "command", "", -1, -1 },
};

static const argent_named_expression_t argent_telecom_manager_guards[1] = {
    { 0, 0 },
};

static const argent_named_expression_t argent_telecom_manager_effects[1] = {
    { 0, 0 },
};


/* TethysFlightBehaviour::InspectorHandler */
typedef enum {
    ARGENT_INSPECTOR_HANDLER_STATE_STOWED = 0,
    ARGENT_INSPECTOR_HANDLER_STATE_CHECKOUT = 1,
    ARGENT_INSPECTOR_HANDLER_STATE_RELEASED = 2,
    ARGENT_INSPECTOR_HANDLER_STATE_RELAYING_IMAGERY = 3,
    ARGENT_INSPECTOR_HANDLER_STATE_RETIRED = 4,
    ARGENT_INSPECTOR_HANDLER_STATE_COUNT = 5
} argent_inspector_handler_state_t;

#define ARGENT_INSPECTOR_HANDLER_TRANSITION_COUNT 7u

static const argent_state_t argent_inspector_handler_states[5] = {
    { "stowed", "TethysFlightBehaviour::InspectorHandler::stowed", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "checkout", "TethysFlightBehaviour::InspectorHandler::checkout", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "checkedOut := true" },
    { "released", "TethysFlightBehaviour::InspectorHandler::released", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "relayingImagery", "TethysFlightBehaviour::InspectorHandler::relayingImagery", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "imagingCampaigns := imagingCampaigns + 1", "" },
    { "retired", "TethysFlightBehaviour::InspectorHandler::retired", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
};

static const argent_transition_t argent_inspector_handler_transitions[7] = {
    { 0, 1, ARGENT_TRIGGER_EVENT, "InspectorCheckoutGo", "command", "", -1, -1 },
    { 1, 0, ARGENT_TRIGGER_TIMED, "", "", "after checkoutDuration", -1, -1 },
    { 0, 2, ARGENT_TRIGGER_EVENT, "InspectorReleaseGo", "command", "", 0, -1 },
    { 2, 3, ARGENT_TRIGGER_EVENT, "InspectorImagingGo", "command", "", -1, 0 },
    { 3, 2, ARGENT_TRIGGER_TIMED, "", "", "after passDuration", -1, -1 },
    { 2, 4, ARGENT_TRIGGER_EVENT, "InspectorRetireGo", "command", "", -1, -1 },
    { 3, 4, ARGENT_TRIGGER_EVENT, "InspectorRetireGo", "command", "", -1, -1 },
};

static const argent_named_expression_t argent_inspector_handler_guards[1] = {
    { "INSPECTOR_HANDLER_G1", "checkedOut" },
};

static const argent_named_expression_t argent_inspector_handler_effects[1] = {
    { "INSPECTOR_HANDLER_E1", "passDuration := go.passDuration" },
};


/* TethysFlightBehaviour::CaptureController */
typedef enum {
    ARGENT_CAPTURE_CONTROLLER_STATE_CHARACTERISING = 0,
    ARGENT_CAPTURE_CONTROLLER_STATE_ARMED = 1,
    ARGENT_CAPTURE_CONTROLLER_STATE_COMMITTED = 2,
    ARGENT_CAPTURE_CONTROLLER_STATE_CINCHING = 3,
    ARGENT_CAPTURE_CONTROLLER_STATE_INHIBITED = 4,
    ARGENT_CAPTURE_CONTROLLER_STATE_DESPINNING = 5,
    ARGENT_CAPTURE_CONTROLLER_STATE_CAPTURED = 6,
    ARGENT_CAPTURE_CONTROLLER_STATE_COUNT = 7
} argent_capture_controller_state_t;

#define ARGENT_CAPTURE_CONTROLLER_TRANSITION_COUNT 13u

static const argent_state_t argent_capture_controller_states[7] = {
    { "characterising", "TethysFlightBehaviour::CaptureController::characterising", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "armed", "TethysFlightBehaviour::CaptureController::armed", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "committed", "TethysFlightBehaviour::CaptureController::committed", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "cinching", "TethysFlightBehaviour::CaptureController::cinching", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "cinchFire: cinchAttempts := cinchAttempts + 1; fire; fired := fire.fired", "" },
    { "inhibited", "TethysFlightBehaviour::CaptureController::inhibited", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "despinning", "TethysFlightBehaviour::CaptureController::despinning", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "captured", "TethysFlightBehaviour::CaptureController::captured", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
};

static const argent_transition_t argent_capture_controller_transitions[13] = {
    { 0, 1, ARGENT_TRIGGER_EVENT, "CaptureArm", "command", "", -1, 0 },
    { 1, 1, ARGENT_TRIGGER_EVENT, "GroundEnable", "command", "", -1, 1 },
    { 1, 2, ARGENT_TRIGGER_EVENT, "CaptureGo", "command", "", -1, 2 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "GroundEnable", "command", "", -1, 1 },
    { 0, 3, ARGENT_TRIGGER_EVENT, "ContactDetected", "command", "", -1, -1 },
    { 1, 3, ARGENT_TRIGGER_EVENT, "ContactDetected", "command", "", -1, -1 },
    { 2, 3, ARGENT_TRIGGER_EVENT, "ContactDetected", "command", "", -1, -1 },
    { 3, 5, ARGENT_TRIGGER_NONE, "", "", "", 0, -1 },
    { 3, 4, ARGENT_TRIGGER_NONE, "", "", "", 1, -1 },
    { 5, 6, ARGENT_TRIGGER_TIMED, "", "", "after despinDuration", -1, -1 },
    { 4, 0, ARGENT_TRIGGER_EVENT, "CaptureDisarm", "command", "", -1, 3 },
    { 1, 0, ARGENT_TRIGGER_EVENT, "CaptureDisarm", "command", "", -1, 4 },
    { 2, 0, ARGENT_TRIGGER_EVENT, "CaptureDisarm", "command", "", -1, 5 },
};

static const argent_named_expression_t argent_capture_controller_guards[2] = {
    { "CAPTURE_CONTROLLER_G1", "fired" },
    { "CAPTURE_CONTROLLER_G2", "not fired" },
};

static const argent_named_expression_t argent_capture_controller_effects[6] = {
    { "CAPTURE_CONTROLLER_E1", "armCommanded := true" },
    { "CAPTURE_CONTROLLER_E2", "groundEnable := true" },
    { "CAPTURE_CONTROLLER_E3", "inCaptureMode := true" },
    { "CAPTURE_CONTROLLER_E4", "clear: armCommanded := false; groundEnable := false; inCaptureMode := false" },
    { "CAPTURE_CONTROLLER_E5", "clearArmed: armCommanded := false; groundEnable := false; inCaptureMode := false" },
    { "CAPTURE_CONTROLLER_E6", "clearCommitted: armCommanded := false; groundEnable := false; inCaptureMode := false" },
};


/* TethysFlightBehaviour::RedundancyManager */
typedef enum {
    ARGENT_REDUNDANCY_MANAGER_STATE_PRIME_ACTIVE = 0,
    ARGENT_REDUNDANCY_MANAGER_STATE_SWITCHING_TO_REDUNDANT = 1,
    ARGENT_REDUNDANCY_MANAGER_STATE_REDUNDANT_ACTIVE = 2,
    ARGENT_REDUNDANCY_MANAGER_STATE_SWITCHING_TO_PRIME = 3,
    ARGENT_REDUNDANCY_MANAGER_STATE_LAST_COMPUTER = 4,
    ARGENT_REDUNDANCY_MANAGER_STATE_COUNT = 5
} argent_redundancy_manager_state_t;

#define ARGENT_REDUNDANCY_MANAGER_TRANSITION_COUNT 11u

static const argent_state_t argent_redundancy_manager_states[5] = {
    { "primeActive", "TethysFlightBehaviour::RedundancyManager::primeActive", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "switchingToRedundant", "TethysFlightBehaviour::RedundancyManager::switchingToRedundant", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "switchovers := switchovers + 1", "" },
    { "redundantActive", "TethysFlightBehaviour::RedundancyManager::redundantActive", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "switchingToPrime", "TethysFlightBehaviour::RedundancyManager::switchingToPrime", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "switchovers := switchovers + 1", "" },
    { "lastComputer", "TethysFlightBehaviour::RedundancyManager::lastComputer", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
};

static const argent_transition_t argent_redundancy_manager_transitions[11] = {
    { 0, 0, ARGENT_TRIGGER_EVENT, "Heartbeat", "command", "", -1, -1 },
    { 0, 1, ARGENT_TRIGGER_EVENT, "ProcessorReset", "faults", "", -1, 0 },
    { 0, 1, ARGENT_TRIGGER_EVENT, "SwitchToRedundant", "command", "", -1, -1 },
    { 0, 1, ARGENT_TRIGGER_TIMED, "", "", "after heartbeatTimeout", -1, 0 },
    { 1, 2, ARGENT_TRIGGER_TIMED, "", "", "after switchoverDuration", -1, -1 },
    { 2, 2, ARGENT_TRIGGER_EVENT, "Heartbeat", "command", "", -1, -1 },
    { 2, 3, ARGENT_TRIGGER_EVENT, "ProcessorReset", "faults", "", 0, 1 },
    { 2, 4, ARGENT_TRIGGER_EVENT, "ProcessorReset", "faults", "", 1, 1 },
    { 2, 3, ARGENT_TRIGGER_TIMED, "", "", "after heartbeatTimeout", 0, 1 },
    { 2, 4, ARGENT_TRIGGER_TIMED, "", "", "after heartbeatTimeout", 1, 1 },
    { 3, 0, ARGENT_TRIGGER_TIMED, "", "", "after switchoverDuration", -1, -1 },
};

static const argent_named_expression_t argent_redundancy_manager_guards[2] = {
    { "REDUNDANCY_MANAGER_G1", "primeHealthy" },
    { "REDUNDANCY_MANAGER_G2", "not primeHealthy" },
};

static const argent_named_expression_t argent_redundancy_manager_effects[2] = {
    { "REDUNDANCY_MANAGER_E1", "primeHealthy := false" },
    { "REDUNDANCY_MANAGER_E2", "redundantHealthy := false" },
};


/* TethysFlightBehaviour::BootUpdateManager */
typedef enum {
    ARGENT_BOOT_UPDATE_MANAGER_STATE_BOOT_ROM = 0,
    ARGENT_BOOT_UPDATE_MANAGER_STATE_LOADING_IMAGE = 1,
    ARGENT_BOOT_UPDATE_MANAGER_STATE_RUNNING = 2,
    ARGENT_BOOT_UPDATE_MANAGER_STATE_SAFE_IMAGE = 3,
    ARGENT_BOOT_UPDATE_MANAGER_STATE_RECEIVING_UPDATE = 4,
    ARGENT_BOOT_UPDATE_MANAGER_STATE_UPLOAD_VERIFIED_IDLE = 5,
    ARGENT_BOOT_UPDATE_MANAGER_STATE_COUNT = 6
} argent_boot_update_manager_state_t;

#define ARGENT_BOOT_UPDATE_MANAGER_TRANSITION_COUNT 10u

static const argent_state_t argent_boot_update_manager_states[6] = {
    { "bootRom", "TethysFlightBehaviour::BootUpdateManager::bootRom", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "boots := boots + 1", "" },
    { "loadingImage", "TethysFlightBehaviour::BootUpdateManager::loadingImage", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "running", "TethysFlightBehaviour::BootUpdateManager::running", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "safeImage", "TethysFlightBehaviour::BootUpdateManager::safeImage", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "fallBack: activeSlot := ImageSlot::safe; fallbacks := fallbacks + 1", "" },
    { "receivingUpdate", "TethysFlightBehaviour::BootUpdateManager::receivingUpdate", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
    { "uploadVerifiedIdle", "TethysFlightBehaviour::BootUpdateManager::uploadVerifiedIdle", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
};

static const argent_transition_t argent_boot_update_manager_transitions[10] = {
    { 0, 1, ARGENT_TRIGGER_TIMED, "", "", "after 5.0 [s]", -1, -1 },
    { 1, 2, ARGENT_TRIGGER_EVENT, "ImageVerify", "command", "", -1, -1 },
    { 1, 3, ARGENT_TRIGGER_TIMED, "", "", "after bootTimeout", -1, -1 },
    { 2, 4, ARGENT_TRIGGER_EVENT, "ImageSegment", "update", "", -1, 0 },
    { 4, 4, ARGENT_TRIGGER_EVENT, "ImageSegment", "update", "", -1, 0 },
    { 4, 5, ARGENT_TRIGGER_EVENT, "ImageVerify", "command", "", -1, 1 },
    { 5, 0, ARGENT_TRIGGER_EVENT, "ImageActivate", "command", "", -1, 2 },
    { 2, 0, ARGENT_TRIGGER_EVENT, "RebootCommand", "command", "", -1, -1 },
    { 3, 0, ARGENT_TRIGGER_EVENT, "ImageRollback", "command", "", -1, 3 },
    { 3, 0, ARGENT_TRIGGER_EVENT, "RebootCommand", "command", "", -1, -1 },
};

static const argent_named_expression_t argent_boot_update_manager_guards[1] = {
    { 0, 0 },
};

static const argent_named_expression_t argent_boot_update_manager_effects[4] = {
    { "BOOT_UPDATE_MANAGER_E1", "segmentsReceived := segmentsReceived + 1" },
    { "BOOT_UPDATE_MANAGER_E2", "uploadVerified := true" },
    { "BOOT_UPDATE_MANAGER_E3", "activeSlot := ImageSlot::backup" },
    { "BOOT_UPDATE_MANAGER_E4", "activeSlot := ImageSlot::primary" },
};


/* TethysModes::TugModes */
typedef enum {
    ARGENT_TUG_MODES_STATE_FLIGHT_MODE = 0,
    ARGENT_TUG_MODES_STATE_LAUNCH = 1,
    ARGENT_TUG_MODES_STATE_ON_LAUNCHER = 2,
    ARGENT_TUG_MODES_STATE_DEPLOYING = 3,
    ARGENT_TUG_MODES_STATE_FREE_FLIGHT = 4,
    ARGENT_TUG_MODES_STATE_COAST = 5,
    ARGENT_TUG_MODES_STATE_THRUST = 6,
    ARGENT_TUG_MODES_STATE_APPROACH = 7,
    ARGENT_TUG_MODES_STATE_PROXIMITY_OPERATIONS = 8,
    ARGENT_TUG_MODES_STATE_RETREAT = 9,
    ARGENT_TUG_MODES_STATE_CAPTURE = 10,
    ARGENT_TUG_MODES_STATE_STACKED = 11,
    ARGENT_TUG_MODES_STATE_DESPIN = 12,
    ARGENT_TUG_MODES_STATE_STACK_COAST = 13,
    ARGENT_TUG_MODES_STATE_STACK_THRUST = 14,
    ARGENT_TUG_MODES_STATE_DRO_HOLD = 15,
    ARGENT_TUG_MODES_STATE_DOCKED_PASSIVE = 16,
    ARGENT_TUG_MODES_STATE_DISPOSAL = 17,
    ARGENT_TUG_MODES_STATE_SAFE = 18,
    ARGENT_TUG_MODES_STATE_ABORT_HOLD = 19,
    ARGENT_TUG_MODES_STATE_SEP_STRING = 20,
    ARGENT_TUG_MODES_STATE_OFF = 21,
    ARGENT_TUG_MODES_STATE_STANDBY = 22,
    ARGENT_TUG_MODES_STATE_THRUSTING = 23,
    ARGENT_TUG_MODES_STATE_DISPOSAL_BURN = 24,
    ARGENT_TUG_MODES_STATE_TELECOM = 25,
    ARGENT_TUG_MODES_STATE_LOW_GAIN = 26,
    ARGENT_TUG_MODES_STATE_HIGH_GAIN = 27,
    ARGENT_TUG_MODES_STATE_RELAYING = 28,
    ARGENT_TUG_MODES_STATE_ATTITUDE_CONTROL = 29,
    ARGENT_TUG_MODES_STATE_THRUSTERS = 30,
    ARGENT_TUG_MODES_STATE_WHEELS = 31,
    ARGENT_TUG_MODES_STATE_CAPTURE_MECHANISM = 32,
    ARGENT_TUG_MODES_STATE_STOWED = 33,
    ARGENT_TUG_MODES_STATE_DEPLOYED = 34,
    ARGENT_TUG_MODES_STATE_CINCHED = 35,
    ARGENT_TUG_MODES_STATE_RELEASED = 36,
    ARGENT_TUG_MODES_STATE_COUNT = 37
} argent_tug_modes_state_t;

#define ARGENT_TUG_MODES_TRANSITION_COUNT 57u

static const argent_state_t argent_tug_modes_states[37] = {
    { "flightMode", "TethysModes::TugModes::flightMode", ARGENT_STATE_NONE, 1, 0, "", "" },
    { "launch", "TethysModes::TugModes::flightMode::launch", 0, 2, 0, "", "" },
    { "onLauncher", "TethysModes::TugModes::flightMode::launch::onLauncher", 1, ARGENT_STATE_NONE, 1, "", "" },
    { "deploying", "TethysModes::TugModes::flightMode::launch::deploying", 1, ARGENT_STATE_NONE, 1, "", "" },
    { "freeFlight", "TethysModes::TugModes::flightMode::freeFlight", 0, 5, 0, "", "" },
    { "coast", "TethysModes::TugModes::flightMode::freeFlight::coast", 4, ARGENT_STATE_NONE, 1, "", "" },
    { "thrust", "TethysModes::TugModes::flightMode::freeFlight::thrust", 4, ARGENT_STATE_NONE, 1, "startArc: thrustArcsStarted := thrustArcsStarted + 1; lastApplicationCommand := \"SepControlApplication: start thrust arc\"; applicationCommands := applicationCommands + 1", "endArc: lastApplicationCommand := \"SepControlApplication: end thrust arc\"; applicationCommands := applicationCommands + 1" },
    { "approach", "TethysModes::TugModes::flightMode::freeFlight::approach", 4, ARGENT_STATE_NONE, 1, "", "" },
    { "proximityOperations", "TethysModes::TugModes::flightMode::freeFlight::proximityOperations", 4, ARGENT_STATE_NONE, 1, "relayOn: lastApplicationCommand := \"TelecomApplication, InspectorHandlingApplication: proximity relay on\"; applicationCommands := applicationCommands + 1", "" },
    { "retreat", "TethysModes::TugModes::flightMode::freeFlight::retreat", 4, ARGENT_STATE_NONE, 1, "", "" },
    { "capture", "TethysModes::TugModes::flightMode::freeFlight::capture", 4, ARGENT_STATE_NONE, 1, "armCapture: lastApplicationCommand := \"CaptureControlApplication: arm\"; applicationCommands := applicationCommands + 1", "disarmCapture: lastApplicationCommand := \"CaptureControlApplication: disarm\"; applicationCommands := applicationCommands + 1" },
    { "stacked", "TethysModes::TugModes::flightMode::stacked", 0, 12, 0, "", "" },
    { "despin", "TethysModes::TugModes::flightMode::stacked::despin", 11, ARGENT_STATE_NONE, 1, "", "" },
    { "stackCoast", "TethysModes::TugModes::flightMode::stacked::stackCoast", 11, ARGENT_STATE_NONE, 1, "", "" },
    { "stackThrust", "TethysModes::TugModes::flightMode::stacked::stackThrust", 11, ARGENT_STATE_NONE, 1, "startReturnArc: thrustArcsStarted := thrustArcsStarted + 1; lastApplicationCommand := \"SepControlApplication: start return arc\"; applicationCommands := applicationCommands + 1", "" },
    { "droHold", "TethysModes::TugModes::flightMode::stacked::droHold", 11, ARGENT_STATE_NONE, 1, "", "" },
    { "dockedPassive", "TethysModes::TugModes::flightMode::stacked::dockedPassive", 11, ARGENT_STATE_NONE, 1, "", "" },
    { "disposal", "TethysModes::TugModes::flightMode::stacked::disposal", 11, ARGENT_STATE_NONE, 1, "", "" },
    { "safe", "TethysModes::TugModes::flightMode::safe", 0, ARGENT_STATE_NONE, 1, "shedToSafe: safeModeEntries := safeModeEntries + 1; lastApplicationCommand := \"PowerManagementApplication: shed loads; TelecomApplication: low-gain safe rate\"; applicationCommands := applicationCommands + 1", "" },
    { "abortHold", "TethysModes::TugModes::flightMode::abortHold", 0, ARGENT_STATE_NONE, 1, "abortSequences: abortEntries := abortEntries + 1; lastApplicationCommand := \"AutonomyApplication: abort sequence; SepControlApplication: thrust inhibited\"; applicationCommands := applicationCommands + 1", "" },
    { "sepString", "TethysModes::TugModes::sepString", ARGENT_STATE_NONE, 21, 0, "", "" },
    { "off", "TethysModes::TugModes::sepString::off", 20, ARGENT_STATE_NONE, 1, "", "" },
    { "standby", "TethysModes::TugModes::sepString::standby", 20, ARGENT_STATE_NONE, 1, "", "" },
    { "thrusting", "TethysModes::TugModes::sepString::thrusting", 20, ARGENT_STATE_NONE, 1, "", "" },
    { "disposalBurn", "TethysModes::TugModes::sepString::disposalBurn", 20, ARGENT_STATE_NONE, 1, "", "" },
    { "telecom", "TethysModes::TugModes::telecom", ARGENT_STATE_NONE, 26, 0, "", "" },
    { "lowGain", "TethysModes::TugModes::telecom::lowGain", 25, ARGENT_STATE_NONE, 1, "", "" },
    { "highGain", "TethysModes::TugModes::telecom::highGain", 25, ARGENT_STATE_NONE, 1, "", "" },
    { "relaying", "TethysModes::TugModes::telecom::relaying", 25, ARGENT_STATE_NONE, 1, "", "" },
    { "attitudeControl", "TethysModes::TugModes::attitudeControl", ARGENT_STATE_NONE, 30, 0, "", "" },
    { "thrusters", "TethysModes::TugModes::attitudeControl::thrusters", 29, ARGENT_STATE_NONE, 1, "", "" },
    { "wheels", "TethysModes::TugModes::attitudeControl::wheels", 29, ARGENT_STATE_NONE, 1, "", "" },
    { "captureMechanism", "TethysModes::TugModes::captureMechanism", ARGENT_STATE_NONE, 33, 0, "", "" },
    { "stowed", "TethysModes::TugModes::captureMechanism::stowed", 32, ARGENT_STATE_NONE, 1, "", "" },
    { "deployed", "TethysModes::TugModes::captureMechanism::deployed", 32, ARGENT_STATE_NONE, 1, "", "" },
    { "cinched", "TethysModes::TugModes::captureMechanism::cinched", 32, ARGENT_STATE_NONE, 1, "", "" },
    { "released", "TethysModes::TugModes::captureMechanism::released", 32, ARGENT_STATE_NONE, 1, "", "" },
};

static const argent_transition_t argent_tug_modes_transitions[57] = {
    { 2, 3, ARGENT_TRIGGER_EVENT, "SeparationConfirmed", "command", "", -1, -1 },
    { 3, ARGENT_STATE_DONE, ARGENT_TRIGGER_EVENT, "ArraysDeployed", "command", "", -1, -1 },
    { 3, ARGENT_STATE_DONE, ARGENT_TRIGGER_TIMED, "", "", "after arraysDeploymentTimeout", -1, -1 },
    { 5, 6, ARGENT_TRIGGER_EVENT, "ThrustArcGo", "command", "", -1, -1 },
    { 6, 5, ARGENT_TRIGGER_EVENT, "ThrustArcEnd", "command", "", -1, -1 },
    { 5, 7, ARGENT_TRIGGER_EVENT, "ProximityOperationsGo", "command", "", -1, -1 },
    { 7, 8, ARGENT_TRIGGER_EVENT, "RangeUpdate", "command", "", 0, -1 },
    { 8, 10, ARGENT_TRIGGER_EVENT, "CaptureGo", "command", "", 1, -1 },
    { 8, 9, ARGENT_TRIGGER_EVENT, "CaptureGo", "command", "", 2, -1 },
    { 9, 8, ARGENT_TRIGGER_EVENT, "ProximityOperationsGo", "command", "", -1, -1 },
    { 10, ARGENT_STATE_DONE, ARGENT_TRIGGER_EVENT, "CaptureComplete", "command", "", -1, 0 },
    { 12, 13, ARGENT_TRIGGER_EVENT, "DespinComplete", "command", "", -1, -1 },
    { 13, 14, ARGENT_TRIGGER_EVENT, "ReturnThrustGo", "command", "", -1, -1 },
    { 14, 13, ARGENT_TRIGGER_EVENT, "ThrustArcEnd", "command", "", -1, -1 },
    { 13, 15, ARGENT_TRIGGER_EVENT, "DroHoldGo", "command", "", -1, -1 },
    { 15, 16, ARGENT_TRIGGER_EVENT, "DockingGo", "command", "", -1, -1 },
    { 16, 17, ARGENT_TRIGGER_EVENT, "DisposalGo", "command", "", -1, -1 },
    { 17, ARGENT_STATE_DONE, ARGENT_TRIGGER_TIMED, "", "", "after disposalBurnDuration", -1, -1 },
    { 1, 4, ARGENT_TRIGGER_NONE, "", "", "", -1, -1 },
    { 4, 11, ARGENT_TRIGGER_NONE, "", "", "", 3, -1 },
    { 11, ARGENT_STATE_DONE, ARGENT_TRIGGER_NONE, "", "", "", -1, -1 },
    { 1, 18, ARGENT_TRIGGER_EVENT, "SafeModeRequest", "", "", -1, 1 },
    { 4, 18, ARGENT_TRIGGER_EVENT, "SafeModeRequest", "", "", -1, 1 },
    { 11, 18, ARGENT_TRIGGER_EVENT, "SafeModeRequest", "", "", -1, 1 },
    { 18, 4, ARGENT_TRIGGER_EVENT, "SafeModeExit", "command", "", 4, -1 },
    { 18, 11, ARGENT_TRIGGER_EVENT, "SafeModeExit", "command", "", 3, -1 },
    { 11, 19, ARGENT_TRIGGER_EVENT, "AbortReturn", "", "", -1, 2 },
    { 19, 11, ARGENT_TRIGGER_EVENT, "SafeModeExit", "command", "", -1, -1 },
    { 21, 22, ARGENT_TRIGGER_EVENT, "ArraysDeployed", "command", "", -1, -1 },
    { 22, 23, ARGENT_TRIGGER_EVENT, "ThrustArcGo", "command", "", -1, -1 },
    { 22, 23, ARGENT_TRIGGER_EVENT, "ProximityOperationsGo", "command", "", -1, -1 },
    { 23, 22, ARGENT_TRIGGER_EVENT, "RangeUpdate", "command", "", 0, -1 },
    { 22, 23, ARGENT_TRIGGER_EVENT, "ReturnThrustGo", "command", "", -1, -1 },
    { 22, 24, ARGENT_TRIGGER_EVENT, "DisposalGo", "command", "", -1, -1 },
    { 24, 21, ARGENT_TRIGGER_TIMED, "", "", "after disposalBurnDuration", -1, -1 },
    { 23, 22, ARGENT_TRIGGER_EVENT, "ThrustArcEnd", "command", "", -1, -1 },
    { 22, 21, ARGENT_TRIGGER_EVENT, "SafeModeRequest", "", "", -1, -1 },
    { 23, 21, ARGENT_TRIGGER_EVENT, "SafeModeRequest", "", "", -1, -1 },
    { 24, 21, ARGENT_TRIGGER_EVENT, "SafeModeRequest", "", "", -1, -1 },
    { 23, 21, ARGENT_TRIGGER_EVENT, "AbortReturn", "", "", -1, -1 },
    { 21, 22, ARGENT_TRIGGER_EVENT, "SafeModeExit", "command", "", -1, -1 },
    { 26, 27, ARGENT_TRIGGER_EVENT, "ArraysDeployed", "command", "", -1, -1 },
    { 27, 28, ARGENT_TRIGGER_EVENT, "InspectorReleaseGo", "command", "", -1, -1 },
    { 28, 27, ARGENT_TRIGGER_EVENT, "InspectorRetireGo", "command", "", -1, -1 },
    { 27, 26, ARGENT_TRIGGER_EVENT, "SafeModeRequest", "", "", -1, -1 },
    { 28, 26, ARGENT_TRIGGER_EVENT, "SafeModeRequest", "", "", -1, -1 },
    { 26, 27, ARGENT_TRIGGER_EVENT, "SafeModeExit", "command", "", -1, -1 },
    { 30, 31, ARGENT_TRIGGER_EVENT, "ArraysDeployed", "command", "", -1, -1 },
    { 31, 30, ARGENT_TRIGGER_EVENT, "ProximityOperationsGo", "command", "", -1, -1 },
    { 30, 31, ARGENT_TRIGGER_EVENT, "DespinComplete", "command", "", -1, -1 },
    { 31, 30, ARGENT_TRIGGER_EVENT, "DockingGo", "command", "", -1, -1 },
    { 30, 31, ARGENT_TRIGGER_EVENT, "DisposalGo", "command", "", -1, -1 },
    { 31, 30, ARGENT_TRIGGER_EVENT, "SafeModeRequest", "", "", -1, -1 },
    { 30, 31, ARGENT_TRIGGER_EVENT, "SafeModeExit", "command", "", -1, -1 },
    { 33, 34, ARGENT_TRIGGER_EVENT, "CaptureGo", "command", "", 1, -1 },
    { 34, 35, ARGENT_TRIGGER_EVENT, "CaptureComplete", "command", "", -1, -1 },
    { 35, 36, ARGENT_TRIGGER_EVENT, "DisposalGo", "command", "", -1, -1 },
};

static const argent_named_expression_t argent_tug_modes_guards[5] = {
    { "TUG_MODES_G1", "u.range <= rendezvousRange" },
    { "TUG_MODES_G2", "go.estimatedMass <= envelope.maximumBodyMass and go.estimatedDiameter <= envelope.maximumBodyDiameter" },
    { "TUG_MODES_G3", "go.estimatedMass > envelope.maximumBodyMass or go.estimatedDiameter > envelope.maximumBodyDiameter" },
    { "TUG_MODES_G4", "captured" },
    { "TUG_MODES_G5", "not captured" },
};

static const argent_named_expression_t argent_tug_modes_effects[3] = {
    { "TUG_MODES_E1", "captured := true" },
    { "TUG_MODES_E2", "lastSafeModeReason := r.reason" },
    { "TUG_MODES_E3", "lastSafeModeReason := a.reason" },
};


/* TethysFlightBehaviour::ModeManagementSoftware::dispatcher */
typedef enum {
    ARGENT_MODE_MANAGEMENT_DISPATCHER_STATE_DISPATCHING = 0,
    ARGENT_MODE_MANAGEMENT_DISPATCHER_STATE_COUNT = 1
} argent_mode_management_dispatcher_state_t;

#define ARGENT_MODE_MANAGEMENT_DISPATCHER_TRANSITION_COUNT 16u

static const argent_state_t argent_mode_management_dispatcher_states[1] = {
    { "dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
};

static const argent_transition_t argent_mode_management_dispatcher_transitions[16] = {
    { 0, 0, ARGENT_TRIGGER_EVENT, "ArraysDeployed", "dispatch", "", -1, 0 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "ThrustArcGo", "dispatch", "", -1, 1 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "ThrustArcEnd", "dispatch", "", -1, 2 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "ProximityOperationsGo", "dispatch", "", -1, 3 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "RangeUpdate", "dispatch", "", 0, 4 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "CaptureGo", "dispatch", "", -1, 5 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "CaptureComplete", "dispatch", "", -1, 6 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "ReturnThrustGo", "dispatch", "", -1, 7 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "DockingGo", "dispatch", "", -1, 8 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "DisposalGo", "dispatch", "", -1, 9 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "InspectorCheckoutGo", "dispatch", "", -1, 10 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "InspectorReleaseGo", "dispatch", "", -1, 11 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "InspectorRetireGo", "dispatch", "", -1, 12 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "SafeModeRequest", "fdirRequests", "", -1, 13 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "SafeModeExit", "dispatch", "", -1, 14 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "AbortReturn", "fdirRequests", "", -1, 15 },
};

static const argent_named_expression_t argent_mode_management_dispatcher_guards[1] = {
    { "MODE_MANAGEMENT_DISPATCHER_G1", "u.range <= modes.rendezvousRange" },
};

static const argent_named_expression_t argent_mode_management_dispatcher_effects[16] = {
    { "MODE_MANAGEMENT_DISPATCHER_E1", "earlyOperations: send new SepStandby() via sepCommands; send new HighGainSelect() via telecomCommands; send new LoadRestore() via powerCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"early operations\") via events; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E2", "thrustArc: send new SepThrust() via sepCommands; send new LowGainSelect() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"thrust arc\") via events; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E3", "coast: send new SepStandby() via sepCommands; send new HighGainSelect() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"coast\") via events; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E4", "approach: send new SepThrust() via sepCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"approach\") via events; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E5", "proximityOperations: send new SepStandby() via sepCommands; send new RelayEnable() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"proximity operations\") via events; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E6", "capture: send new CaptureArm() via captureCommands; send new SequenceStart(sequenceId = 3) via autonomyCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"capture\") via events; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E7", "despin: send new CaptureDisarm() via captureCommands; send new RelayDisable() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"despin\") via events; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E8", "stackThrust: send new SepThrust() via sepCommands; send new LowGainSelect() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"stack thrust\") via events; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E9", "docking: send new RelayEnable() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"docking\") via events; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E10", "disposal: send new SepDisposalBurn(duration = modes.disposalBurnDuration) via sepCommands; send new RelayDisable() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"disposal\") via events; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E11", "inspectorCheckout: send new InspectorCheckoutGo() via inspectorCommands; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E12", "inspectorRelease: send new InspectorReleaseGo() via inspectorCommands; send new RelayEnable() via telecomCommands; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E13", "inspectorRetire: send new InspectorRetireGo() via inspectorCommands; send new RelayDisable() via telecomCommands; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E14", "safe: send new SafeModeRequest(reason = r.reason); send new SepOff() via sepCommands; send new LowGainSelect() via telecomCommands; send new LoadShed() via powerCommands; send new LoadShed() via thermalCommands; send new CaptureDisarm() via captureCommands; send new SequenceAbort() via autonomyCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"safe mode\") via events; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E15", "recover: send new SepStandby() via sepCommands; send new HighGainSelect() via telecomCommands; send new LoadRestore() via powerCommands; send new LoadRestore() via thermalCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"safe mode exit\") via events; dispatched := dispatched + 1" },
    { "MODE_MANAGEMENT_DISPATCHER_E16", "abortHold: send new AbortReturn(reason = a.reason); send new SepOff() via sepCommands; send new HighGainSelect() via telecomCommands; send new SequenceAbort() via autonomyCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"abort hold\") via events; dispatched := dispatched + 1" },
};


/* TethysFdir::FdirSupervisor */
typedef enum {
    ARGENT_FDIR_SUPERVISOR_STATE_COMMAND_LOSS_TIMER = 0,
    ARGENT_FDIR_SUPERVISOR_STATE_ARMED = 1,
    ARGENT_FDIR_SUPERVISOR_STATE_EXPIRED = 2,
    ARGENT_FDIR_SUPERVISOR_STATE_THRUSTER_HEALTH = 3,
    ARGENT_FDIR_SUPERVISOR_STATE_NOMINAL_4 = 4,
    ARGENT_FDIR_SUPERVISOR_STATE_RESTARTING = 5,
    ARGENT_FDIR_SUPERVISOR_STATE_ON_SPARE = 6,
    ARGENT_FDIR_SUPERVISOR_STATE_STRING_LOST = 7,
    ARGENT_FDIR_SUPERVISOR_STATE_PPU_HEALTH = 8,
    ARGENT_FDIR_SUPERVISOR_STATE_NOMINAL_9 = 9,
    ARGENT_FDIR_SUPERVISOR_STATE_CROSS_STRAPPED = 10,
    ARGENT_FDIR_SUPERVISOR_STATE_PPU_LOST = 11,
    ARGENT_FDIR_SUPERVISOR_STATE_POWER_HEALTH = 12,
    ARGENT_FDIR_SUPERVISOR_STATE_NOMINAL_13 = 13,
    ARGENT_FDIR_SUPERVISOR_STATE_LOAD_SHED = 14,
    ARGENT_FDIR_SUPERVISOR_STATE_ATTITUDE_HEALTH = 15,
    ARGENT_FDIR_SUPERVISOR_STATE_NOMINAL_16 = 16,
    ARGENT_FDIR_SUPERVISOR_STATE_SUN_ACQUISITION = 17,
    ARGENT_FDIR_SUPERVISOR_STATE_EARTH_IMPACT_EXCLUSION = 18,
    ARGENT_FDIR_SUPERVISOR_STATE_MONITORING = 19,
    ARGENT_FDIR_SUPERVISOR_STATE_ABORTED = 20,
    ARGENT_FDIR_SUPERVISOR_STATE_COUNT = 21
} argent_fdir_supervisor_state_t;

#define ARGENT_FDIR_SUPERVISOR_TRANSITION_COUNT 17u

static const argent_state_t argent_fdir_supervisor_states[21] = {
    { "commandLossTimer", "TethysFdir::FdirSupervisor::commandLossTimer", ARGENT_STATE_NONE, 1, 0, "", "" },
    { "armed", "TethysFdir::FdirSupervisor::commandLossTimer::armed", 0, ARGENT_STATE_NONE, 1, "", "" },
    { "expired", "TethysFdir::FdirSupervisor::commandLossTimer::expired", 0, ARGENT_STATE_NONE, 1, "callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = \"command-loss timer expired\")", "" },
    { "thrusterHealth", "TethysFdir::FdirSupervisor::thrusterHealth", ARGENT_STATE_NONE, 4, 0, "", "" },
    { "nominal", "TethysFdir::FdirSupervisor::thrusterHealth::nominal", 3, ARGENT_STATE_NONE, 1, "", "" },
    { "restarting", "TethysFdir::FdirSupervisor::thrusterHealth::restarting", 3, ARGENT_STATE_NONE, 1, "", "" },
    { "onSpare", "TethysFdir::FdirSupervisor::thrusterHealth::onSpare", 3, ARGENT_STATE_NONE, 1, "", "" },
    { "stringLost", "TethysFdir::FdirSupervisor::thrusterHealth::stringLost", 3, ARGENT_STATE_NONE, 1, "callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = \"thruster string lost: operating set not available\")", "" },
    { "ppuHealth", "TethysFdir::FdirSupervisor::ppuHealth", ARGENT_STATE_NONE, 9, 0, "", "" },
    { "nominal", "TethysFdir::FdirSupervisor::ppuHealth::nominal", 8, ARGENT_STATE_NONE, 1, "", "" },
    { "crossStrapped", "TethysFdir::FdirSupervisor::ppuHealth::crossStrapped", 8, ARGENT_STATE_NONE, 1, "", "" },
    { "ppuLost", "TethysFdir::FdirSupervisor::ppuHealth::ppuLost", 8, ARGENT_STATE_NONE, 1, "callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = \"second PPU trip: thrust profile replan needed\")", "" },
    { "powerHealth", "TethysFdir::FdirSupervisor::powerHealth", ARGENT_STATE_NONE, 13, 0, "", "" },
    { "nominal", "TethysFdir::FdirSupervisor::powerHealth::nominal", 12, ARGENT_STATE_NONE, 1, "", "" },
    { "loadShed", "TethysFdir::FdirSupervisor::powerHealth::loadShed", 12, ARGENT_STATE_NONE, 1, "callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = \"battery state of charge below load-shed fraction\")", "" },
    { "attitudeHealth", "TethysFdir::FdirSupervisor::attitudeHealth", ARGENT_STATE_NONE, 16, 0, "", "" },
    { "nominal", "TethysFdir::FdirSupervisor::attitudeHealth::nominal", 15, ARGENT_STATE_NONE, 1, "", "" },
    { "sunAcquisition", "TethysFdir::FdirSupervisor::attitudeHealth::sunAcquisition", 15, ARGENT_STATE_NONE, 1, "callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = \"attitude loss\")", "" },
    { "earthImpactExclusion", "TethysFdir::FdirSupervisor::earthImpactExclusion", ARGENT_STATE_NONE, 19, 0, "", "" },
    { "monitoring", "TethysFdir::FdirSupervisor::earthImpactExclusion::monitoring", 18, ARGENT_STATE_NONE, 1, "", "" },
    { "aborted", "TethysFdir::FdirSupervisor::earthImpactExclusion::aborted", 18, ARGENT_STATE_NONE, 1, "send new AbortReturn(reason = \"Earth-impact exclusion violated\")", "" },
};

static const argent_transition_t argent_fdir_supervisor_transitions[17] = {
    { 1, 1, ARGENT_TRIGGER_EVENT, "GroundContact", "command", "", -1, -1 },
    { 1, 1, ARGENT_TRIGGER_EVENT, "ProcessorReset", "command", "", -1, -1 },
    { 1, 2, ARGENT_TRIGGER_TIMED, "", "", "after limits.commandLossTimeout", -1, -1 },
    { 2, 1, ARGENT_TRIGGER_EVENT, "GroundContact", "command", "", -1, -1 },
    { 4, 5, ARGENT_TRIGGER_EVENT, "ThrusterFlameout", "command", "", 0, 0 },
    { 5, 4, ARGENT_TRIGGER_TIMED, "", "", "after limits.thrusterRestartDelay", -1, -1 },
    { 4, 6, ARGENT_TRIGGER_EVENT, "ThrusterFlameout", "command", "", 1, 1 },
    { 6, 7, ARGENT_TRIGGER_EVENT, "ThrusterFlameout", "command", "", -1, 1 },
    { 9, 10, ARGENT_TRIGGER_EVENT, "PpuTrip", "command", "", -1, 2 },
    { 10, 11, ARGENT_TRIGGER_EVENT, "PpuTrip", "command", "", -1, 2 },
    { 13, 14, ARGENT_TRIGGER_EVENT, "BatteryLow", "command", "", 2, -1 },
    { 14, 13, ARGENT_TRIGGER_EVENT, "SafeModeExit", "command", "", -1, -1 },
    { 16, 17, ARGENT_TRIGGER_EVENT, "AttitudeLoss", "command", "", -1, -1 },
    { 17, 16, ARGENT_TRIGGER_EVENT, "SafeModeExit", "command", "", -1, -1 },
    { 19, 19, ARGENT_TRIGGER_EVENT, "TrajectoryUpdate", "command", "", 3, 3 },
    { 19, 20, ARGENT_TRIGGER_EVENT, "TrajectoryUpdate", "command", "", 4, 3 },
    { 20, 19, ARGENT_TRIGGER_EVENT, "SafeModeExit", "command", "", -1, -1 },
};

static const argent_named_expression_t argent_fdir_supervisor_guards[5] = {
    { "FDIR_SUPERVISOR_G1", "flameoutRetries < limits.maximumFlameoutRetries" },
    { "FDIR_SUPERVISOR_G2", "flameoutRetries >= limits.maximumFlameoutRetries" },
    { "FDIR_SUPERVISOR_G3", "b.stateOfCharge < limits.batteryLowFraction" },
    { "FDIR_SUPERVISOR_G4", "t.earthClosestApproach > limits.earthExclusionRadius and t.impactProbability <= limits.maximumImpactProbability" },
    { "FDIR_SUPERVISOR_G5", "t.earthClosestApproach <= limits.earthExclusionRadius or t.impactProbability > limits.maximumImpactProbability" },
};

static const argent_named_expression_t argent_fdir_supervisor_effects[4] = {
    { "FDIR_SUPERVISOR_E1", "flameoutRetries := flameoutRetries + 1" },
    { "FDIR_SUPERVISOR_E2", "healthyThrusters := healthyThrusters - 1" },
    { "FDIR_SUPERVISOR_E3", "ppuTrips := ppuTrips + 1" },
    { "FDIR_SUPERVISOR_E4", "record: lastEarthClosestApproach := t.earthClosestApproach; lastImpactProbability := t.impactProbability" },
};


/* TethysFlightBehaviour::FdirSoftware::responseRelay */
typedef enum {
    ARGENT_FDIR_RESPONSE_RELAY_STATE_RELAYING = 0,
    ARGENT_FDIR_RESPONSE_RELAY_STATE_COUNT = 1
} argent_fdir_response_relay_state_t;

#define ARGENT_FDIR_RESPONSE_RELAY_TRANSITION_COUNT 2u

static const argent_state_t argent_fdir_response_relay_states[1] = {
    { "relaying", "TethysFlightBehaviour::FdirSoftware::responseRelay::relaying", ARGENT_STATE_NONE, ARGENT_STATE_NONE, 1, "", "" },
};

static const argent_transition_t argent_fdir_response_relay_transitions[2] = {
    { 0, 0, ARGENT_TRIGGER_EVENT, "SafeModeRequest", "", "", -1, 0 },
    { 0, 0, ARGENT_TRIGGER_EVENT, "AbortReturn", "", "", -1, 1 },
};

static const argent_named_expression_t argent_fdir_response_relay_guards[1] = {
    { 0, 0 },
};

static const argent_named_expression_t argent_fdir_response_relay_effects[2] = {
    { "FDIR_RESPONSE_RELAY_E1", "relaySafeMode: send new SafeModeRequest(reason = r.reason) via supervisorRequests; relayed := relayed + 1" },
    { "FDIR_RESPONSE_RELAY_E2", "relayAbort: send new AbortReturn(reason = a.reason) via supervisorRequests; relayed := relayed + 1" },
};


#define ARGENT_STATE_MACHINE_COUNT 12u

static const argent_state_machine_t argent_state_machines[12] = {
    { "SepStringController", "TethysFlightBehaviour::SepStringController", 0, argent_sep_string_controller_states, 6u, argent_sep_string_controller_transitions, 14u, argent_sep_string_controller_guards, 0u, argent_sep_string_controller_effects, 1u },
    { "PowerManager", "TethysFlightBehaviour::PowerManager", 0, argent_power_manager_states, 4u, argent_power_manager_transitions, 9u, argent_power_manager_guards, 3u, argent_power_manager_effects, 0u },
    { "ThermalController", "TethysFlightBehaviour::ThermalController", ARGENT_STATE_NONE, argent_thermal_controller_states, 6u, argent_thermal_controller_transitions, 4u, argent_thermal_controller_guards, 2u, argent_thermal_controller_effects, 0u },
    { "TelecomManager", "TethysFlightBehaviour::TelecomManager", 0, argent_telecom_manager_states, 4u, argent_telecom_manager_transitions, 9u, argent_telecom_manager_guards, 0u, argent_telecom_manager_effects, 0u },
    { "InspectorHandler", "TethysFlightBehaviour::InspectorHandler", 0, argent_inspector_handler_states, 5u, argent_inspector_handler_transitions, 7u, argent_inspector_handler_guards, 1u, argent_inspector_handler_effects, 1u },
    { "CaptureController", "TethysFlightBehaviour::CaptureController", 0, argent_capture_controller_states, 7u, argent_capture_controller_transitions, 13u, argent_capture_controller_guards, 2u, argent_capture_controller_effects, 6u },
    { "RedundancyManager", "TethysFlightBehaviour::RedundancyManager", 0, argent_redundancy_manager_states, 5u, argent_redundancy_manager_transitions, 11u, argent_redundancy_manager_guards, 2u, argent_redundancy_manager_effects, 2u },
    { "BootUpdateManager", "TethysFlightBehaviour::BootUpdateManager", 0, argent_boot_update_manager_states, 6u, argent_boot_update_manager_transitions, 10u, argent_boot_update_manager_guards, 0u, argent_boot_update_manager_effects, 4u },
    { "TugModes", "TethysModes::TugModes", ARGENT_STATE_NONE, argent_tug_modes_states, 37u, argent_tug_modes_transitions, 57u, argent_tug_modes_guards, 5u, argent_tug_modes_effects, 3u },
    { "ModeManagementDispatcher", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher", 0, argent_mode_management_dispatcher_states, 1u, argent_mode_management_dispatcher_transitions, 16u, argent_mode_management_dispatcher_guards, 1u, argent_mode_management_dispatcher_effects, 16u },
    { "FdirSupervisor", "TethysFdir::FdirSupervisor", ARGENT_STATE_NONE, argent_fdir_supervisor_states, 21u, argent_fdir_supervisor_transitions, 17u, argent_fdir_supervisor_guards, 5u, argent_fdir_supervisor_effects, 4u },
    { "FdirResponseRelay", "TethysFlightBehaviour::FdirSoftware::responseRelay", 0, argent_fdir_response_relay_states, 1u, argent_fdir_response_relay_transitions, 2u, argent_fdir_response_relay_guards, 0u, argent_fdir_response_relay_effects, 2u },
};

#endif /* ARGENT_STATE_MACHINES_H */
