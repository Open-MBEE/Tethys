/* Inspector handling application: InspectorHandler machine and the Wren relay status. */
#include "apps/apps.h"

static bool inspector_g1(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; return sys->app.checked_out; }
static void inspector_exit_checkout(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.checked_out = true; }
static void inspector_entry_relaying(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.imaging_campaigns++; }
/* passDuration := go.passDuration; the item carries hours, as InspectorImagingGo(passDuration = 4.0 [h]) renders. */
static void inspector_e1(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; sys->app.inspector_pass_duration_us = argent_s_to_us(ev->arg[0] * 3600.0); }

static void inspector_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    struct { uint8_t relaying; uint32_t campaigns; } status;
    (void)minor_frame;
    status.relaying = sm_is_active(&sys->sm[SM_INSPECTOR_HANDLER], sm_state_index(sys->sm[SM_INSPECTOR_HANDLER].def, "relayingImagery", ARGENT_STATE_NONE));
    status.campaigns = sys->app.imaging_campaigns;
    bus_publish(&sys->bus, "relayStatusTopic", &status, sizeof status);
}

void app_inspector_init(argent_system_t *sys)
{
    sm_instance_t *sm = &sys->sm[SM_INSPECTOR_HANDLER];
    sm_register_guard(sm, "INSPECTOR_HANDLER_G1", inspector_g1);
    sm_register_effect(sm, "INSPECTOR_HANDLER_E1", inspector_e1);
    sm_register_exit(sm, "TethysFlightBehaviour::InspectorHandler::checkout", inspector_exit_checkout);
    sm_register_entry(sm, "TethysFlightBehaviour::InspectorHandler::relayingImagery", inspector_entry_relaying);
    exec_bind_task(&sys->exec, "inspectorHandlingTask", inspector_task, sys);
}
