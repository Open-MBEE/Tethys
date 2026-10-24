#include "apps/system.h"
#include "apps/apps.h"
#include <stdio.h>
#include <string.h>

argent_us_t system_now(const argent_system_t *sys) { (void)sys; return hal_timer_now(); }

void system_fault(argent_system_t *sys, const char *what)
{
    char frag[TRACE_ITEM_LEN], esc[64];
    sys->unhandled_faults++;
    snprintf(sys->last_fault, sizeof sys->last_fault, "%s", what);
    trace_json_escape(what, esc, sizeof esc);
    snprintf(frag, sizeof frag, "{\"fault\":\"%s\"}", esc);
    trace_add(&sys->trace, "faults", frag);
}

static void on_event_trace(void *ctx, const argent_event_t *ev, argent_us_t now, double value)
{
    argent_system_t *sys = ctx;
    char frag[TRACE_ITEM_LEN];
    (void)now;
    snprintf(frag, sizeof frag, "{\"id\":%u,\"name\":\"%s\",\"severity\":%u,\"fault\":%s,\"value\":%.6g}",
             ev->id, ev->mnemonic, (unsigned)ev->severity, ev->is_fault ? "true" : "false", value);
    trace_add(&sys->trace, "events", frag);
}

static void on_packet(void *ctx, const argent_packet_t *packet, uint16_t sequence_count, const uint8_t *octets, uint16_t length)
{
    argent_system_t *sys = ctx;
    char frag[TRACE_ITEM_LEN];
    (void)octets;
    hal_link_downlink(length);
    snprintf(frag, sizeof frag, "{\"apid\":%u,\"seq\":%u,\"len\":%u}", packet->apid, sequence_count, length);
    trace_add(&sys->trace, "packets", frag);
}

static double sample_point(void *ctx, uint16_t index, const argent_telemetry_point_t *point)
{
    /* Sampling: the host simulation's state projected by point type; the dictionary mnemonic picks the source. */
    const argent_system_t *sys = ctx;
    const sim_state_t *s = &sys->sim;
    if (strcmp(point->point_type, "TemperaturePoint") == 0) return s->zone_temperature_k;
    if (strstr(point->mnemonic, "_SOC") != NULL || strstr(point->mnemonic, "BATT") != NULL) return s->state_of_charge * 100.0;
    if (strstr(point->mnemonic, "RATE") != NULL) return s->body_rate_rad_s;
    if (strstr(point->mnemonic, "THRUST") != NULL) return s->thrust_n;
    if (strstr(point->mnemonic, "RANGE") != NULL) return s->range_m;
    if (strstr(point->mnemonic, "MODE") != NULL) return (double)sys->mode;
    return sys->telemetry.value[index];
}

void system_init(argent_system_t *sys, FILE *trace_out)
{
    memset(sys, 0, sizeof(*sys));
    hal_init();
    exec_init(&sys->exec);
    bus_init(&sys->bus);
    event_init(&sys->events);
    event_set_trace_sink(&sys->events, on_event_trace, sys);
    command_init(&sys->commands, argent_s_to_us(60.0));
    telemetry_init(&sys->telemetry, sample_point, sys, on_packet, sys);
    parameter_init(&sys->params);
    image_init(&sys->images);
    trace_init(&sys->trace, trace_out);
    sim_init(&sys->sim);
    for (unsigned i = 0; i < SM_INDEX_COUNT; i++) sm_init(&sys->sm[i], &argent_state_machines[i], sys);
    sys->app.prime_healthy = true;
    sys->app.redundant_healthy = true;
    sys->app.healthy_thrusters = 3;
    sys->app.setpoint = 293.15;
    sys->app.tier = 0;
    sys->app.active_slot = ARGENT_IMAGE_SLOT_PRIMARY;
    apps_init(sys);
    bus_lock(&sys->bus);
    exec_init_complete(&sys->exec);
    for (unsigned i = 0; i < SM_INDEX_COUNT; i++) sm_start(&sys->sm[i], hal_timer_now());
    system_refresh_mode(sys);
}

bool system_post_item(argent_system_t *sys, const char *name, const char *port, const double *args, uint8_t arg_count, const char *text)
{
    return system_post_item_to(sys, -1, name, port, args, arg_count, text);
}

bool system_post_item_to(argent_system_t *sys, int8_t target, const char *name, const char *port, const double *args, uint8_t arg_count, const char *text)
{
    system_item_t *it;
    if (sys->item_count >= SYSTEM_ITEM_QUEUE_DEPTH) { sys->items_dropped++; return false; }
    it = &sys->item_queue[(sys->item_head + sys->item_count) % SYSTEM_ITEM_QUEUE_DEPTH];
    memset(it, 0, sizeof(*it));
    snprintf(it->name, sizeof it->name, "%s", name);
    snprintf(it->port, sizeof it->port, "%s", port != NULL ? port : "");
    for (uint8_t i = 0; i < arg_count && i < SM_MAX_EVENT_ARGS; i++) it->arg[i] = args[i];
    if (text != NULL) snprintf(it->text, sizeof it->text, "%s", text);
    it->target = target;
    sys->item_count++;
    return true;
}

uint32_t system_deliver_item(argent_system_t *sys, const char *name, const char *port, const double *args, const char *text)
{
    return system_deliver_item_to(sys, -1, name, port, args, text);
}

uint32_t system_deliver_item_to(argent_system_t *sys, int8_t target, const char *name, const char *port, const double *args, const char *text)
{
    /* "command" is the ground/uplink side: it reaches every port (the runner treats a NULL port as a wildcard). */
    if (port != NULL && strcmp(port, "command") == 0) port = NULL;
    sm_event_t ev;
    uint32_t fired = 0;
    argent_us_t now = hal_timer_now();
    memset(&ev, 0, sizeof ev);
    ev.name = name; ev.port = port; ev.text = text;
    if (args != NULL) for (unsigned i = 0; i < SM_MAX_EVENT_ARGS; i++) ev.arg[i] = args[i];
    for (unsigned i = 0; i < SM_INDEX_COUNT; i++)
        if (target < 0 || (unsigned)target == i) fired += sm_dispatch(&sys->sm[i], &ev, now);
    system_on_item(sys, name, port, ev.arg, text);
    return fired;
}

void system_deliver_queued(argent_system_t *sys)
{
    /* Items sent by effects during delivery are appended and drained in the same pass. */
    for (unsigned guard = 0; guard < SYSTEM_ITEM_QUEUE_DEPTH * 2u && sys->item_count > 0; guard++) {
        system_item_t it = sys->item_queue[sys->item_head];
        sys->item_head = (sys->item_head + 1u) % SYSTEM_ITEM_QUEUE_DEPTH;
        sys->item_count--;
        system_deliver_item_to(sys, it.target, it.name, it.port[0] != '\0' ? it.port : NULL, it.arg, it.text[0] != '\0' ? it.text : NULL);
        system_refresh_mode(sys);
    }
}

void system_tick_machines(argent_system_t *sys)
{
    argent_us_t now = hal_timer_now();
    for (unsigned i = 0; i < SM_INDEX_COUNT; i++) {
        sm_tick(&sys->sm[i], now);
        if (sys->sm[i].fault) { system_fault(sys, sys->sm[i].def->name); sys->sm[i].fault = 0; }
    }
}

const char *system_mode_name(const argent_system_t *sys) { return argent_mode_table[sys->mode].name; }

void system_machines_json(const argent_system_t *sys, char *buf, uint32_t len)
{
    uint32_t pos = 0;
    pos += (uint32_t)snprintf(buf + pos, len - pos, "{");
    for (unsigned i = 0; i < SM_INDEX_COUNT && pos < len; i++) {
        char cfg[SM_CONFIG_LEN];
        sm_config(&sys->sm[i], cfg, sizeof cfg);
        pos += (uint32_t)snprintf(buf + pos, len - pos, "%s\"%s\":\"%s\"", i == 0 ? "" : ",", sys->sm[i].def->name, cfg);
    }
    if (pos < len) snprintf(buf + pos, len - pos, "}");
}

void system_run_minor_frame(argent_system_t *sys)
{
    char machines[1024];
    trace_begin_frame(&sys->trace);
    bus_begin_frame(&sys->bus, sys->mode);
    exec_run_minor_frame(&sys->exec);
    sim_step(&sys->sim, ARGENT_MINOR_FRAME_US);
    system_machines_json(sys, machines, sizeof machines);
    trace_end_frame(&sys->trace, sys->exec.frame_index - 1u, (sys->exec.minor_frame + ARGENT_MINOR_FRAMES - 1u) % ARGENT_MINOR_FRAMES,
                    hal_timer_now() - ARGENT_MINOR_FRAME_US, system_mode_name(sys), machines, sys->bus.slot_load, ARGENT_BUS_FRAME_SLOTS,
                    bus_reserve_check(sys->mode), sys->exec.task_overruns, sys->exec.frame_overruns, sys->commands.inhibits,
                    sys->exec.frame_budget_used_us, sys->exec.tasks_fired_this_frame);
}
