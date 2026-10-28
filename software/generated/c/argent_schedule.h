/*
 * Argent flight software tables. Generated; edit the model or the generator, not this file.
 * Generator: software/gen/generate.py 1.0.0
 * Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
 * Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
 * Source elements:
 *   TethysFlightTiming::FlightTiming (rate groups, frame periods)
 *   TethysFlightTiming::argentTiming
 *   TethysFlightTiming::PartitionSchedule
 *   TethysFlightTiming::ScheduledTask
 *   TethysFlightTiming::ApplicationTask
 *   TethysFlightSoftware::ArgentFlightSoftware::executive
 *   TethysFlightTiming::argentBus
 *   TethysFlightTiming::BusSlotAssignment
 */
#ifndef ARGENT_SCHEDULE_H
#define ARGENT_SCHEDULE_H

#include <stdint.h>
#include "argent_enums.h"

#define ARGENT_MINOR_FRAME_PERIOD_S 0.125
#define ARGENT_MAJOR_FRAME_PERIOD_S 1.0
#define ARGENT_MINOR_FRAMES_PER_MAJOR_FRAME 8u
#define ARGENT_BUS_FRAME_SLOTS 64u
#define ARGENT_BUS_FRAME_PERIOD_S 0.125
#define ARGENT_BUS_SLOT_LENGTH_BYTES 1024.0

typedef struct {
    const char *name;
    double rate_hz;
    double period_s;
    uint16_t activations_per_major_frame;
} argent_rate_group_t;

typedef struct {
    const char *name;
    double window_s;
    double memory_bytes;
    argent_software_criticality_t criticality;
    uint8_t restartable;
} argent_partition_t;

typedef struct {
    const char *name;
    double duration_s;
} argent_frame_slice_t;

typedef struct {
    const char *name;
    const char *kind;
    const char *component;
    uint16_t rate_group;
    double wcet_s;
    double period_s;
    double deadline_s;
    uint8_t firing_frames;
    argent_mode_mask_t active_modes;
} argent_scheduled_task_t;

typedef struct {
    const char *name;
    uint16_t partition;
    uint16_t first_slice;
    uint16_t slice_count;
    uint16_t first_task;
    uint16_t task_count;
} argent_partition_schedule_t;

typedef struct {
    const char *name;
    const char *node;
    uint16_t slots_per_frame;
    double message_length_bytes;
    argent_mode_mask_t active_modes;
} argent_bus_stream_t;

typedef struct {
    argent_tug_mode_t mode;
    uint16_t slots_used;
    double bytes_per_frame;
} argent_bus_mode_load_t;

#define ARGENT_RATE_GROUP_COUNT 4u
#define ARGENT_PARTITION_COUNT 5u
#define ARGENT_FRAME_SLICE_COUNT 7u
#define ARGENT_SCHEDULED_TASK_COUNT 22u
#define ARGENT_PARTITION_SCHEDULE_COUNT 5u
#define ARGENT_BUS_STREAM_COUNT 13u

static const argent_rate_group_t argent_rate_groups[4] = {
    { "rg16", 16.0, 0.0625, 16u },
    { "rg8", 8.0, 0.125, 8u },
    { "rg2", 2.0, 0.5, 2u },
    { "rg1", 1.0, 1.0, 1u },
};

static const argent_partition_t argent_partitions[5] = {
    { "platformPartition", 0.25, 256000000.0, ARGENT_SOFTWARE_CRITICALITY_SAFETY_CRITICAL, 0 },
    { "gncPartition", 0.25, 256000000.0, ARGENT_SOFTWARE_CRITICALITY_SAFETY_CRITICAL, 1 },
    { "subsystemPartition", 0.25, 256000000.0, ARGENT_SOFTWARE_CRITICALITY_MISSION_CRITICAL, 1 },
    { "autonomyPartition", 0.125, 128000000.0, ARGENT_SOFTWARE_CRITICALITY_SAFETY_CRITICAL, 1 },
    { "payloadPartition", 0.125, 128000000.0, ARGENT_SOFTWARE_CRITICALITY_NON_CRITICAL, 1 },
};

static const argent_frame_slice_t argent_frame_slices[7] = {
    { "sliceA", 0.015625 },
    { "sliceB", 0.015625 },
    { "sliceA", 0.015625 },
    { "sliceB", 0.015625 },
    { "slice", 0.03125 },
    { "slice", 0.015625 },
    { "slice", 0.015625 },
};

static const argent_scheduled_task_t argent_scheduled_tasks[22] = {
    { "boardSupportTask", "ScheduledTask", "software.boardSupport", 0u, 0.001, 0.0625, 0.0625, 0xffu, 0xfffeu },
    { "schedulerTask", "ScheduledTask", "software.scheduler", 0u, 0.001, 0.0625, 0.0625, 0xffu, 0xfffeu },
    { "fdirTask", "ApplicationTask", "software.fdir", 0u, 0.003, 0.0625, 0.0625, 0xffu, 0xfffeu },
    { "modeManagementTask", "ApplicationTask", "software.modeManagement", 1u, 0.003, 0.125, 0.125, 0xffu, 0xfffeu },
    { "cdhTask", "ApplicationTask", "software.cdh", 1u, 0.004, 0.125, 0.125, 0xffu, 0xfffeu },
    { "commandIngestTask", "ScheduledTask", "software.commandIngest", 1u, 0.002, 0.125, 0.125, 0xffu, 0xfffeu },
    { "telemetryOutputTask", "ScheduledTask", "software.telemetryOutput", 1u, 0.003, 0.125, 0.125, 0xffu, 0xfffeu },
    { "telecomTask", "ApplicationTask", "software.telecom", 1u, 0.005, 0.125, 0.125, 0xffu, 0xfffeu },
    { "housekeepingTask", "ScheduledTask", "software.housekeeping", 3u, 0.003, 1.0, 1.0, 0x01u, 0xfffeu },
    { "timeTask", "ScheduledTask", "software.time", 3u, 0.001, 1.0, 1.0, 0x02u, 0xfffeu },
    { "eventTask", "ScheduledTask", "software.events", 3u, 0.001, 1.0, 1.0, 0x04u, 0xfffeu },
    { "tableTask", "ScheduledTask", "software.tables", 3u, 0.001, 1.0, 1.0, 0x08u, 0xfffeu },
    { "dataStoreTask", "ScheduledTask", "software.dataStore", 3u, 0.002, 1.0, 1.0, 0x10u, 0xfffeu },
    { "bootUpdateTask", "ScheduledTask", "software.bootUpdate", 3u, 0.001, 1.0, 1.0, 0x20u, 0xfffeu },
    { "parameterBootUpdateTask", "ApplicationTask", "software.parameterBootUpdate", 3u, 0.004, 1.0, 1.0, 0x40u, 0xfffeu },
    { "gncTask", "ApplicationTask", "software.gnc", 0u, 0.012, 0.0625, 0.0625, 0xffu, 0xfffeu },
    { "sepControlTask", "ApplicationTask", "software.sepControl", 1u, 0.005, 0.125, 0.125, 0xffu, 0xfffeu },
    { "powerManagementTask", "ApplicationTask", "software.powerManagement", 1u, 0.005, 0.125, 0.125, 0xffu, 0xfffeu },
    { "thermalControlTask", "ApplicationTask", "software.thermalControl", 2u, 0.006, 0.5, 0.5, 0x22u, 0xfffeu },
    { "autonomyTask", "ApplicationTask", "software.autonomy", 1u, 0.01, 0.125, 0.125, 0xffu, 0xfffeu },
    { "captureControlTask", "ApplicationTask", "software.captureControl", 0u, 0.006, 0.0625, 0.0625, 0xffu, 0xfffeu },
    { "inspectorHandlingTask", "ApplicationTask", "software.inspectorHandling", 2u, 0.003, 0.5, 0.5, 0x44u, 0xfffeu },
};

static const argent_partition_schedule_t argent_partition_schedules[5] = {
    { "platformSchedule", 0u, 0u, 2u, 0u, 15u },
    { "gncSchedule", 1u, 2u, 2u, 15u, 2u },
    { "subsystemSchedule", 2u, 4u, 1u, 17u, 2u },
    { "autonomySchedule", 3u, 5u, 1u, 19u, 1u },
    { "payloadSchedule", 4u, 6u, 1u, 20u, 2u },
};

static const argent_bus_stream_t argent_bus_streams[13] = {
    { "timeBroadcast", "broadcast", 1u, 16.0, 0xfffeu },
    { "thermalPropulsionPoll", "thermal and propulsion unit", 2u, 256.0, 0xfffeu },
    { "thermalPropulsionCommand", "thermal and propulsion unit", 1u, 64.0, 0xfffeu },
    { "thermalZoneSweep", "thermal and propulsion unit", 1u, 512.0, 0xfffeu },
    { "mechanismStatus", "mechanism unit", 1u, 128.0, 0xfffeu },
    { "mechanismPoll", "mechanism unit", 2u, 256.0, 0x01a0u },
    { "mechanismCommand", "mechanism unit", 2u, 64.0, 0x01a0u },
    { "gncSensorPoll", "star trackers and inertial units", 8u, 128.0, 0xfffeu },
    { "gncActuatorCommand", "reaction wheels", 4u, 64.0, 0xfffeu },
    { "massMemoryWrite", "mass memories", 8u, 1024.0, 0xfffeu },
    { "transponderUplink", "transponders", 1u, 1024.0, 0xfffeu },
    { "transponderDownlink", "transponders", 3u, 1024.0, 0xfffeu },
    { "retryReserve", "any", 2u, 1024.0, 0xfffeu },
};

static const argent_bus_mode_load_t argent_bus_mode_loads[16] = {
    { ARGENT_TUG_MODE_LAUNCH, 0u, 0 },
    { ARGENT_TUG_MODE_EARLY_OPERATIONS, 32u, 16848.0 },
    { ARGENT_TUG_MODE_COAST, 32u, 16848.0 },
    { ARGENT_TUG_MODE_THRUST, 32u, 16848.0 },
    { ARGENT_TUG_MODE_APPROACH, 32u, 16848.0 },
    { ARGENT_TUG_MODE_PROXIMITY_OPERATIONS, 36u, 17488.0 },
    { ARGENT_TUG_MODE_RETREAT, 32u, 16848.0 },
    { ARGENT_TUG_MODE_CAPTURE, 36u, 17488.0 },
    { ARGENT_TUG_MODE_DESPIN, 36u, 17488.0 },
    { ARGENT_TUG_MODE_STACK_COAST, 32u, 16848.0 },
    { ARGENT_TUG_MODE_STACK_THRUST, 32u, 16848.0 },
    { ARGENT_TUG_MODE_DRO_HOLD, 32u, 16848.0 },
    { ARGENT_TUG_MODE_DOCKED_PASSIVE, 32u, 16848.0 },
    { ARGENT_TUG_MODE_DISPOSAL, 32u, 16848.0 },
    { ARGENT_TUG_MODE_SAFE, 32u, 16848.0 },
    { ARGENT_TUG_MODE_ABORT_HOLD, 32u, 16848.0 },
};

#endif /* ARGENT_SCHEDULE_H */
