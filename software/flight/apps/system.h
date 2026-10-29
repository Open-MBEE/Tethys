/* The Argent flight software system object: the executive, the bus, the services, the trace and
 * one state-machine instance per generated machine, all in static storage (no allocation after
 * initialisation). Applications attach to it through apps/apps.h. */
#ifndef ARGENT_SYSTEM_H
#define ARGENT_SYSTEM_H
#include <stdbool.h>
#include <stdint.h>
#include "argent_modes.h"
#include "argent_state_machines.h"
#include "bus/bus.h"
#include "exec/executive.h"
#include "hal/sim/sim.h"
#include "sm/sm_runner.h"
#include "svc/command.h"
#include "svc/event.h"
#include "svc/image.h"
#include "svc/parameter.h"
#include "svc/telemetry.h"
#include "trace/trace.h"

#define SYSTEM_ITEM_QUEUE_DEPTH 32u
#define SYSTEM_SEQUENCE_COUNT 6u
#define SYSTEM_SEQUENCE_STEPS 8u

/* Generated machine indices (table order of argent_state_machines[]). */
enum {
    SM_SEP_STRING = 0, SM_POWER_MANAGER, SM_THERMAL_CONTROLLER, SM_TELECOM_MANAGER, SM_INSPECTOR_HANDLER,
    SM_CAPTURE_CONTROLLER, SM_REDUNDANCY_MANAGER, SM_BOOT_UPDATE_MANAGER, SM_TUG_MODES, SM_MODE_DISPATCHER,
    SM_FDIR_SUPERVISOR, SM_FDIR_RELAY, SM_INDEX_COUNT
};

/* Send targets: every machine, or only the services (sequence engine, trace) that have no machine. */
#define SM_TARGET_ALL ((int8_t)-1)
#define SM_TARGET_SERVICES ((int8_t)SM_INDEX_COUNT)

typedef struct {
    char name[48];
    char port[24];
    double arg[SM_MAX_EVENT_ARGS];
    char text[48];
    int8_t target;  /* machine index the send is addressed to, -1 = every machine */
} system_item_t;

typedef struct {
    uint16_t id;
    const char *name;
    uint8_t step_count;
    const char *step_item[SYSTEM_SEQUENCE_STEPS];   /* application-command item sent per step */
    double step_delay_s[SYSTEM_SEQUENCE_STEPS];
    double step_arg0[SYSTEM_SEQUENCE_STEPS];        /* first payload argument of the step item, in the unit the uplink item carries */
} system_sequence_t;

typedef struct {
    executive_t exec;
    bus_t bus;
    event_service_t events;
    command_service_t commands;
    telemetry_service_t telemetry;
    parameter_service_t params;
    image_service_t images;
    trace_t trace;
    sim_state_t sim;
    sm_instance_t sm[SM_INDEX_COUNT];
    system_item_t item_queue[SYSTEM_ITEM_QUEUE_DEPTH];
    uint32_t item_head, item_count, items_dropped;
    uint16_t mode;                    /* current TugMode row index */
    uint32_t mode_changes;
    uint32_t unhandled_faults;
    uint32_t assertion_failures;
    bool halted;
    char last_fault[64];
    /* Application counters mirrored from the model's attributes (see docs/coverage). */
    struct {
        uint32_t arcs_started, restarts, shed_events, heater_cycles, safe_rate_entries, passes;
        uint32_t imaging_campaigns, cinch_attempts, switchovers, boots, fallbacks, dispatched, relayed;
        uint32_t flameout_retries, healthy_thrusters, ppu_trips, segments_received;
        uint32_t thrust_arcs_started, safe_mode_entries, abort_entries, application_commands, safe_mode_requests;
        char last_application_command[96];
        bool captured, fired, checked_out, upload_verified, prime_healthy, redundant_healthy;
        bool arm_commanded, ground_enable, in_capture_mode;
        char last_safe_mode_reason[48];
        uint8_t tier, active_slot;
        double setpoint, last_earth_closest_approach, last_impact_probability;
        uint16_t running_sequence; uint8_t sequence_step; argent_us_t sequence_next_us; uint32_t sequences_run, steps_sent;
        argent_us_t sep_burn_duration_us, inspector_pass_duration_us;   /* durations the SepDisposalBurn / InspectorImagingGo items carried */
    } app;
} argent_system_t;

extern const system_sequence_t system_sequences[SYSTEM_SEQUENCE_COUNT];

void system_init(argent_system_t *sys, FILE *trace_out);
/* Queues an application-command item for delivery at the next command-ingest task. */
bool system_post_item_to(argent_system_t *sys, int8_t target, const char *name, const char *port, const double *args, uint8_t arg_count, const char *text);
uint32_t system_deliver_item_to(argent_system_t *sys, int8_t target, const char *name, const char *port, const double *args, const char *text);
bool system_post_item(argent_system_t *sys, const char *name, const char *port, const double *args, uint8_t arg_count, const char *text);
/* Delivers one item to every machine now (used by effects that send items within a step). */
uint32_t system_deliver_item(argent_system_t *sys, const char *name, const char *port, const double *args, const char *text);
void system_deliver_queued(argent_system_t *sys);
void system_tick_machines(argent_system_t *sys);
/* Maps the TugModes leaf to the mode table row and refreshes the executive, bus and inhibits. */
void system_refresh_mode(argent_system_t *sys);
const char *system_mode_name(const argent_system_t *sys);
void system_machines_json(const argent_system_t *sys, char *buf, uint32_t len);
void system_run_minor_frame(argent_system_t *sys);
void system_fault(argent_system_t *sys, const char *what);
void system_on_item(argent_system_t *sys, const char *name, const char *port, const double *args, const char *text);
argent_us_t system_now(const argent_system_t *sys);

#endif
