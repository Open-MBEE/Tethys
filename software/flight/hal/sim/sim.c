#include "hal/sim/sim.h"
#include <string.h>

void sim_init(sim_state_t *s)
{
    memset(s, 0, sizeof(*s));
    s->body_rate_rad_s = 0.02;
    s->wheels_active = false;
    s->rcs_active = true;
    s->healthy_thrusters = 3;
    s->state_of_charge = 0.95;
    s->array_power_w = 0.0;          /* arrays stowed until deployment */
    s->load_w = SIM_BASE_LOAD_W;
    s->zone_temperature_k = 293.15;
    s->setpoint_k = 293.15;
    s->range_m = 5.0e8;
    s->range_rate_m_s = -50.0;
    s->earth_closest_approach_km = 50000.0;
    s->impact_probability = 1.0e-9;
    s->link_up = true;
}

void sim_set_thrusting(sim_state_t *s, bool on) { s->sep_thrusting = on; }
void sim_set_heater(sim_state_t *s, bool on) { s->heater_on = on; }
void sim_set_shed_tier(sim_state_t *s, uint8_t tier) { s->load_shed_tier = tier; }

void sim_step(sim_state_t *s, argent_us_t dt_us)
{
    double dt = (double)dt_us / 1.0e6;
    double net_w, shed_fraction;
    /* attitude: wheels damp the body rate; RCS holds it. */
    if (s->wheels_active) s->body_rate_rad_s *= 1.0 - dt / SIM_WHEEL_RATE_DECAY_S;
    if (s->body_rate_rad_s < 1.0e-6) s->body_rate_rad_s = 1.0e-6;
    /* SEP: thrust and power while thrusting; range closes with the range rate. */
    s->thrust_n = s->sep_thrusting ? SIM_THRUST_N : 0.0;
    s->sep_power_w = s->sep_thrusting ? SIM_THRUST_LOAD_W : 0.0;
    if (s->sep_thrusting) s->range_rate_m_s -= 1.0e-5 * dt;
    s->range_m += s->range_rate_m_s * dt;
    if (s->range_m < 10.0) { s->range_m = 10.0; s->range_rate_m_s = 0.0; }
    /* power: load shedding removes a share of the platform load per tier. */
    shed_fraction = s->load_shed_tier == 0 ? 0.0 : s->load_shed_tier == 1 ? 0.25 : s->load_shed_tier == 2 ? 0.5 : 0.75;
    s->load_w = SIM_BASE_LOAD_W * (1.0 - shed_fraction) + s->sep_power_w + (s->heater_on ? 400.0 : 0.0);
    net_w = (s->in_eclipse ? 0.0 : s->array_power_w) - s->load_w;
    s->state_of_charge += net_w * dt / 3600.0 / SIM_BATTERY_CAPACITY_WH;
    if (s->state_of_charge > 1.0) s->state_of_charge = 1.0;
    if (s->state_of_charge < 0.0) s->state_of_charge = 0.0;
    /* thermal: first-order relaxation toward the sink, heater adds a fixed rate. */
    s->zone_temperature_k += (SIM_COLD_SINK_K - s->zone_temperature_k) * dt / SIM_ZONE_TIME_CONSTANT_S;
    if (s->heater_on) s->zone_temperature_k += SIM_HEATER_RATE_K_S * dt;
    s->steps++;
}
