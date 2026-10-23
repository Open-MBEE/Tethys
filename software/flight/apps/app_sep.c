/* SEP string control application: SepStringController machine over the generated tables. */
#include "apps/apps.h"
#include <string.h>

static void sep_entry_thrusting(sm_instance_t *sm, int16_t state)
{
    argent_system_t *sys = sm->ctx; (void)state;
    sys->app.arcs_started++;
    sim_set_thrusting(&sys->sim, true);
    command_set_inhibit(&sys->commands, INHIBIT_THRUSTER_HOLD, false);
    app_raise(sys, "SEP_EVT_ARC_STARTED", 0.0);
}
static void sep_exit_thrusting(sm_instance_t *sm, int16_t state)
{
    argent_system_t *sys = sm->ctx; (void)state;
    sim_set_thrusting(&sys->sim, false);
}
static void sep_entry_restarting(sm_instance_t *sm, int16_t state)
{
    argent_system_t *sys = sm->ctx; (void)state;
    sys->app.restarts++;
}
static void sep_entry_off(sm_instance_t *sm, int16_t state)
{
    argent_system_t *sys = sm->ctx; (void)state;
    command_set_inhibit(&sys->commands, INHIBIT_THRUSTER_HOLD, true);
}

static void sep_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    struct { uint8_t thrusting; uint8_t healthy; float thrust_n; } status;
    (void)minor_frame;
    status.thrusting = sys->sim.sep_thrusting;
    status.healthy = sys->sim.healthy_thrusters;
    status.thrust_n = (float)sys->sim.thrust_n;
    bus_publish(&sys->bus, "thrusterStatusTopic", &status, sizeof status);
}

void app_sep_init(argent_system_t *sys)
{
    sm_instance_t *sm = &sys->sm[SM_SEP_STRING];
    sm_register_entry(sm, "TethysFlightBehaviour::SepStringController::thrusting", sep_entry_thrusting);
    sm_register_exit(sm, "TethysFlightBehaviour::SepStringController::thrusting", sep_exit_thrusting);
    sm_register_entry(sm, "TethysFlightBehaviour::SepStringController::restarting", sep_entry_restarting);
    sm_register_entry(sm, "TethysFlightBehaviour::SepStringController::off", sep_entry_off);
    exec_bind_task(&sys->exec, "sepControlTask", sep_task, sys);
}
