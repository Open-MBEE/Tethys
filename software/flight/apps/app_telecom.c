/* Telecom application: TelecomManager machine; MLS-2 link availability from the HAL. */
#include "apps/apps.h"

static void telecom_entry_safe_rate(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.safe_rate_entries++; }
static void telecom_entry_pass(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.passes++; }

static void telecom_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    bool up = hal_link_available();
    struct { uint8_t link_up; uint16_t rate_set; uint32_t downlink_kbit; } status;
    if (up != sys->sim.link_up) {
        sys->sim.link_up = up;
        app_send(sys, up ? "PassStart" : "PassEnd", "command", 0.0, NULL);
        if (up) { app_send(sys, "GroundContact", "command", 0.0, NULL); app_raise(sys, "COM_EVT_CARRIER_ACQUIRED", 1.0); }
        else app_raise(sys, "COM_EVT_CARRIER_LOST", 0.0);
    }
    status.link_up = up; status.rate_set = argent_mode_table[sys->mode].rate_set;
    status.downlink_kbit = (uint32_t)(hal_link_downlink_octets() * 8u / 1000u);
    (void)minor_frame;
    bus_publish(&sys->bus, "linkStatusTopic", &status, sizeof status);
}

void app_telecom_init(argent_system_t *sys)
{
    sm_instance_t *sm = &sys->sm[SM_TELECOM_MANAGER];
    sm_register_entry(sm, "TethysFlightBehaviour::TelecomManager::safeRate", telecom_entry_safe_rate);
    sm_register_entry(sm, "TethysFlightBehaviour::TelecomManager::pass", telecom_entry_pass);
    exec_bind_task(&sys->exec, "telecomTask", telecom_task, sys);
}
