/* Power management application: PowerManager machine; battery fraction reports from the simulation. */
#include "apps/apps.h"

#define POWER_TIER_ONE_FRACTION 0.45   /* PowerManager::tierOneFraction */
#define POWER_RESTORE_FRACTION 0.60    /* PowerManager::restoreFraction */

static double battery_low_fraction(void) { double v = 0.3; limit_get("batteryLowFraction", &v); return v; }

static bool power_g1(sm_instance_t *sm, const sm_event_t *ev) { (void)sm; return ev->arg[0] < POWER_TIER_ONE_FRACTION && ev->arg[0] >= battery_low_fraction(); }
static bool power_g2(sm_instance_t *sm, const sm_event_t *ev) { (void)sm; return ev->arg[0] < battery_low_fraction(); }
static bool power_g3(sm_instance_t *sm, const sm_event_t *ev) { (void)sm; return ev->arg[0] >= POWER_RESTORE_FRACTION; }

static void power_set_tier(sm_instance_t *sm, uint8_t tier, bool count)
{
    argent_system_t *sys = sm->ctx;
    sys->app.tier = tier;
    if (count) sys->app.shed_events++;
    sim_set_shed_tier(&sys->sim, tier);
}
static void power_entry_nominal(sm_instance_t *sm, int16_t s) { (void)s; power_set_tier(sm, 0, false); }
static void power_entry_tier_one(sm_instance_t *sm, int16_t s) { (void)s; power_set_tier(sm, 1, true); app_raise(sm->ctx, "EPS_EVT_LOAD_SHED", 1.0); }
static void power_entry_tier_two(sm_instance_t *sm, int16_t s) { (void)s; power_set_tier(sm, 2, true); app_raise(sm->ctx, "EPS_EVT_LOAD_SHED", 2.0); }
static void power_entry_survival(sm_instance_t *sm, int16_t s) { (void)s; power_set_tier(sm, 3, true); app_raise(sm->ctx, "EPS_EVT_LOAD_SHED", 3.0); }

static void power_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    struct { float soc; float array_w; float load_w; uint8_t tier; } state;
    if (minor_frame == 0) app_send(sys, "BatteryStateOfCharge", "command", sys->sim.state_of_charge, NULL);
    state.soc = (float)sys->sim.state_of_charge; state.array_w = (float)sys->sim.array_power_w;
    state.load_w = (float)sys->sim.load_w; state.tier = sys->app.tier;
    bus_publish(&sys->bus, "powerStateTopic", &state, sizeof state);
}

void app_power_init(argent_system_t *sys)
{
    sm_instance_t *sm = &sys->sm[SM_POWER_MANAGER];
    sm_register_guard(sm, "POWER_MANAGER_G1", power_g1);
    sm_register_guard(sm, "POWER_MANAGER_G2", power_g2);
    sm_register_guard(sm, "POWER_MANAGER_G3", power_g3);
    sm_register_entry(sm, "TethysFlightBehaviour::PowerManager::nominal", power_entry_nominal);
    sm_register_entry(sm, "TethysFlightBehaviour::PowerManager::tierOne", power_entry_tier_one);
    sm_register_entry(sm, "TethysFlightBehaviour::PowerManager::tierTwo", power_entry_tier_two);
    sm_register_entry(sm, "TethysFlightBehaviour::PowerManager::survival", power_entry_survival);
    exec_bind_task(&sys->exec, "powerManagementTask", power_task, sys);
}
