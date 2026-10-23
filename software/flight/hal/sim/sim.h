/* Host simulation of the vehicle the flight software controls: attitude, SEP string, power,
 * thermal and the asteroid approach. Simple first-order models; every parameter is a model value
 * (see docs/coverage for the element each comes from). */
#ifndef ARGENT_SIM_H
#define ARGENT_SIM_H
#include <stdbool.h>
#include <stdint.h>
#include "exec/argent_time.h"

typedef struct {
    /* attitude: body rate magnitude [rad/s], wheel momentum fraction of capacity */
    double body_rate_rad_s, wheel_momentum_fraction;
    bool wheels_active, rcs_active;
    /* SEP: string state, thrust [N], PPU power draw [W] */
    bool sep_thrusting; double thrust_n, sep_power_w; uint8_t healthy_thrusters;
    /* power: battery state-of-charge fraction, array power [W], load [W] */
    double state_of_charge, array_power_w, load_w; uint8_t load_shed_tier; bool in_eclipse;
    /* thermal: controlled zone temperature [K], heater state */
    double zone_temperature_k, setpoint_k; bool heater_on;
    /* navigation: range to the target body [m], Earth closest approach [km], impact probability */
    double range_m, range_rate_m_s, earth_closest_approach_km, impact_probability;
    /* link */
    bool link_up; double downlink_bit_s;
    uint64_t steps;
} sim_state_t;

/* Model values the simulation uses (model element in the comment). */
#define SIM_BATTERY_CAPACITY_WH 5000.0       /* power budget: battery capacity */
#define SIM_ARRAY_POWER_W 24000.0            /* power budget: array end-of-life power */
#define SIM_BASE_LOAD_W 1800.0               /* power budget: platform load */
#define SIM_THRUST_LOAD_W 20000.0            /* SEP string: PPU input power */
#define SIM_THRUST_N 0.9                     /* SEP string: thrust per string */
#define SIM_ZONE_TIME_CONSTANT_S 3600.0      /* thermal: first-order zone time constant */
#define SIM_HEATER_RATE_K_S (6.0 / 3600.0)   /* thermal: heater warming rate */
#define SIM_COLD_SINK_K 150.0                /* thermal: radiative sink */
#define SIM_WHEEL_RATE_DECAY_S 600.0         /* GN&C: rate damping time constant on wheels */

void sim_init(sim_state_t *s);
void sim_step(sim_state_t *s, argent_us_t dt);
void sim_set_thrusting(sim_state_t *s, bool on);
void sim_set_heater(sim_state_t *s, bool on);
void sim_set_shed_tier(sim_state_t *s, uint8_t tier);

#endif
