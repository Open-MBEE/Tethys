/* Capture-system control application: CaptureController machine with the three capture inhibits
 * (arm commanded, ground enable, capture mode) that the cinch fire checks. */
#include "apps/apps.h"
#include <string.h>

static bool capture_g1(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; return sys->app.fired; }
static bool capture_g2(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; return !sys->app.fired; }

static void capture_refresh_inhibits(argent_system_t *sys)
{
    command_set_inhibit(&sys->commands, INHIBIT_CAPTURE_ARM, !sys->app.arm_commanded);
    command_set_inhibit(&sys->commands, INHIBIT_GROUND_ENABLE, !sys->app.ground_enable);
    command_set_inhibit(&sys->commands, INHIBIT_CAPTURE_MODE, !sys->app.in_capture_mode);
}
static void capture_e1(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; sys->app.arm_commanded = true; capture_refresh_inhibits(sys); }
static void capture_e2(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; sys->app.ground_enable = true; capture_refresh_inhibits(sys); }
static void capture_e3(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; sys->app.in_capture_mode = true; capture_refresh_inhibits(sys); }
static void capture_clear(sm_instance_t *sm, const sm_event_t *ev)
{
    argent_system_t *sys = sm->ctx; (void)ev;
    sys->app.arm_commanded = false; sys->app.ground_enable = false; sys->app.in_capture_mode = false;
    capture_refresh_inhibits(sys);
}

static void capture_entry_cinching(sm_instance_t *sm, int16_t s)
{
    /* cinchFire: the fire action succeeds only with all three inhibits released. */
    argent_system_t *sys = sm->ctx; (void)s;
    sys->app.cinch_attempts++;
    sys->app.fired = sys->app.arm_commanded && sys->app.ground_enable && sys->app.in_capture_mode;
    app_raise(sys, sys->app.fired ? "CAP_EVT_LATCHED" : "CAP_EVT_CONTACT", sys->app.fired ? 1.0 : 0.0);
}
static void capture_entry_captured(sm_instance_t *sm, int16_t s)
{
    argent_system_t *sys = sm->ctx; (void)s;
    sys->app.captured = true;
    app_send(sys, "CaptureComplete", "command", 0.0, NULL);
}
static void capture_entry_inhibited(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; app_raise(sys, "CAP_EVT_CAPTURE_ABORTED", 0.0); }

static void capture_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    struct { uint8_t armed; uint8_t fired; uint8_t inhibits; uint32_t attempts; } state;
    (void)minor_frame;
    state.armed = sys->app.arm_commanded; state.fired = sys->app.fired;
    state.inhibits = (uint8_t)(sys->commands.inhibits & (INHIBIT_CAPTURE_ARM | INHIBIT_GROUND_ENABLE | INHIBIT_CAPTURE_MODE));
    state.attempts = sys->app.cinch_attempts;
    bus_publish(&sys->bus, "captureStateTopic", &state, sizeof state);
}

void app_capture_init(argent_system_t *sys)
{
    sm_instance_t *sm = &sys->sm[SM_CAPTURE_CONTROLLER];
    sm_register_guard(sm, "CAPTURE_CONTROLLER_G1", capture_g1);
    sm_register_guard(sm, "CAPTURE_CONTROLLER_G2", capture_g2);
    sm_register_effect(sm, "CAPTURE_CONTROLLER_E1", capture_e1);
    sm_register_effect(sm, "CAPTURE_CONTROLLER_E2", capture_e2);
    sm_register_effect(sm, "CAPTURE_CONTROLLER_E3", capture_e3);
    sm_register_effect(sm, "CAPTURE_CONTROLLER_E4", capture_clear);
    sm_register_effect(sm, "CAPTURE_CONTROLLER_E5", capture_clear);
    sm_register_effect(sm, "CAPTURE_CONTROLLER_E6", capture_clear);
    sm_register_entry(sm, "TethysFlightBehaviour::CaptureController::cinching", capture_entry_cinching);
    sm_register_entry(sm, "TethysFlightBehaviour::CaptureController::captured", capture_entry_captured);
    sm_register_entry(sm, "TethysFlightBehaviour::CaptureController::inhibited", capture_entry_inhibited);
    capture_refresh_inhibits(sys);
    exec_bind_task(&sys->exec, "captureControlTask", capture_task, sys);
}
