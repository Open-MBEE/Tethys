/* C&DH application: board support, scheduler bookkeeping, command ingest, telemetry output,
 * housekeeping, time, events, data store and the RedundancyManager (two flight computers). */
#include "apps/apps.h"
#include <stdio.h>
#include <string.h>

static bool red_g1(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; return sys->app.prime_healthy; }
static bool red_g2(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; return !sys->app.prime_healthy; }
static void red_e1(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; sys->app.prime_healthy = false; }
static void red_e2(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; sys->app.redundant_healthy = false; }
static void red_entry_switching(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.switchovers++; app_raise(sys, "CDH_EVT_PRIME_SWITCHED", (double)sys->app.switchovers); }

static void trace_command(argent_system_t *sys, const char *mnemonic, command_verdict_t v)
{
    char frag[TRACE_ITEM_LEN];
    snprintf(frag, sizeof frag, "{\"cmd\":\"%.32s\",\"verdict\":\"%.20s\",\"inhibits\":%u}", mnemonic, command_verdict_name(v), sys->commands.inhibits);
    trace_add(&sys->trace, "commands", frag);
}

/* Uplink items: 'c' = dictionary command (mnemonic + args, optional two-step execute), 'i' = application-command item. */
static void command_ingest_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    hal_uplink_t up;
    (void)minor_frame;
    while (hal_link_uplink_pop(&up)) {
        if (up.kind == 'i') {
            system_post_item(sys, up.name, up.text[0] != '\0' ? up.text : "command", up.arg, up.arg_count, NULL);
            continue;
        }
        {
            const argent_command_t *cmd = command_lookup_mnemonic(up.name);
            command_verdict_t v;
            if (cmd == NULL) { v = COMMAND_REJECT_UNKNOWN_OPCODE; trace_command(sys, up.name, v); app_raise(sys, "CDH_EVT_CMD_REJECTED", 0.0); continue; }
            v = command_process(&sys->commands, cmd, up.arg, up.arg_count, sys->mode, up.two_step_execute != 0, hal_timer_now());
            trace_command(sys, cmd->mnemonic, v);
            if (v == COMMAND_ACCEPTED) {
                app_raise(sys, "CDH_EVT_CMD_ACCEPTED", (double)cmd->opcode);
                if (up.text[0] != '\0') system_post_item(sys, up.text, "command", up.arg, up.arg_count, NULL);
            } else if (v != COMMAND_ARMED) {
                app_raise(sys, "CDH_EVT_CMD_REJECTED", (double)cmd->opcode);
            }
        }
    }
    system_deliver_queued(sys);
}

static void telemetry_output_task(void *ctx, uint32_t minor_frame) { argent_system_t *sys = ctx; (void)minor_frame; telemetry_cycle(&sys->telemetry, sys->mode, hal_timer_now()); }
static void housekeeping_task(void *ctx, uint32_t minor_frame) { argent_system_t *sys = ctx; (void)minor_frame; telemetry_set_value(&sys->telemetry, "CDH_HK_MODE", (double)sys->mode); }
static void time_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    struct { uint32_t coarse; uint16_t fine; } tick = { telemetry_time_code_coarse(hal_timer_now()), telemetry_time_code_fine(hal_timer_now()) };
    (void)minor_frame;
    bus_publish(&sys->bus, "timeTickTopic", &tick, sizeof tick);
}
static void event_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    event_record_t rec;
    (void)minor_frame;
    while (event_pop(&sys->events, &rec)) { /* drained into the recorder; the trace sink saw them when raised */ }
}
static void board_support_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    /* Heartbeats come from the redundant computer (the model's failover conductor); the host scenario supplies them. */
    (void)minor_frame;
    if (hal_watchdog_expired(hal_timer_now(), ARGENT_MAJOR_FRAME_US * 2u)) app_raise(sys, "CDH_EVT_WATCHDOG_MISSED", 0.0);
}
static void scheduler_task(void *ctx, uint32_t minor_frame) { argent_system_t *sys = ctx; (void)minor_frame; system_tick_machines(sys); system_deliver_queued(sys); }
static void cdh_task(void *ctx, uint32_t minor_frame) { (void)ctx; (void)minor_frame; }
static void data_store_task(void *ctx, uint32_t minor_frame) { (void)ctx; (void)minor_frame; }

void app_cdh_init(argent_system_t *sys)
{
    sm_instance_t *sm = &sys->sm[SM_REDUNDANCY_MANAGER];
    sm_register_guard(sm, "REDUNDANCY_MANAGER_G1", red_g1);
    sm_register_guard(sm, "REDUNDANCY_MANAGER_G2", red_g2);
    sm_register_effect(sm, "REDUNDANCY_MANAGER_E1", red_e1);
    sm_register_effect(sm, "REDUNDANCY_MANAGER_E2", red_e2);
    sm_register_entry(sm, "TethysFlightBehaviour::RedundancyManager::switchingToRedundant", red_entry_switching);
    sm_register_entry(sm, "TethysFlightBehaviour::RedundancyManager::switchingToPrime", red_entry_switching);
    exec_bind_task(&sys->exec, "boardSupportTask", board_support_task, sys);
    exec_bind_task(&sys->exec, "schedulerTask", scheduler_task, sys);
    exec_bind_task(&sys->exec, "cdhTask", cdh_task, sys);
    exec_bind_task(&sys->exec, "commandIngestTask", command_ingest_task, sys);
    exec_bind_task(&sys->exec, "telemetryOutputTask", telemetry_output_task, sys);
    exec_bind_task(&sys->exec, "housekeepingTask", housekeeping_task, sys);
    exec_bind_task(&sys->exec, "timeTask", time_task, sys);
    exec_bind_task(&sys->exec, "eventTask", event_task, sys);
    exec_bind_task(&sys->exec, "dataStoreTask", data_store_task, sys);
}
