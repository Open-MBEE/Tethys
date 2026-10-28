/* Thermal control application: ThermalController machine (set-point selection || heater loop). */
#include "apps/apps.h"

#define THERMAL_OPERATIONAL_SETPOINT_K 293.15  /* ThermalController::operationalSetpoint */
#define THERMAL_SURVIVAL_SETPOINT_K 263.15     /* ThermalController::survivalSetpoint */
#define THERMAL_HYSTERESIS_K 2.0               /* ThermalController::hysteresis */

static bool thermal_g1(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; return ev->arg[0] < sys->app.setpoint - THERMAL_HYSTERESIS_K; }
static bool thermal_g2(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; return ev->arg[0] > sys->app.setpoint + THERMAL_HYSTERESIS_K; }
static void thermal_entry_operational(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.setpoint = THERMAL_OPERATIONAL_SETPOINT_K; sys->sim.setpoint_k = sys->app.setpoint; }
static void thermal_entry_survival(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.setpoint = THERMAL_SURVIVAL_SETPOINT_K; sys->sim.setpoint_k = sys->app.setpoint; }
static void thermal_entry_heater_on(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.heater_cycles++; sim_set_heater(&sys->sim, true); }
static void thermal_entry_heater_off(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sim_set_heater(&sys->sim, false); }

static void thermal_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    struct { float temperature_k; float setpoint_k; uint8_t heater_on; } state;
    if (minor_frame == 4) app_send(sys, "TemperatureReport", "command", sys->sim.zone_temperature_k, NULL);
    state.temperature_k = (float)sys->sim.zone_temperature_k; state.setpoint_k = (float)sys->app.setpoint; state.heater_on = sys->sim.heater_on;
    bus_publish(&sys->bus, "thermalStateTopic", &state, sizeof state);
}

void app_thermal_init(argent_system_t *sys)
{
    sm_instance_t *sm = &sys->sm[SM_THERMAL_CONTROLLER];
    sm_register_guard(sm, "THERMAL_CONTROLLER_G1", thermal_g1);
    sm_register_guard(sm, "THERMAL_CONTROLLER_G2", thermal_g2);
    sm_register_entry(sm, "TethysFlightBehaviour::ThermalController::setpointSelection::operational", thermal_entry_operational);
    sm_register_entry(sm, "TethysFlightBehaviour::ThermalController::setpointSelection::survival", thermal_entry_survival);
    sm_register_entry(sm, "TethysFlightBehaviour::ThermalController::heaterLoop::heaterOn", thermal_entry_heater_on);
    sm_register_entry(sm, "TethysFlightBehaviour::ThermalController::heaterLoop::heaterOff", thermal_entry_heater_off);
    exec_bind_task(&sys->exec, "thermalControlTask", thermal_task, sys);
}
