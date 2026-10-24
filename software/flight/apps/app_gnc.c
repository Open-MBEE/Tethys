/* GN&C application: attitude and navigation state from the host simulation; the attitude-control
 * actuator follows the TugModes attitudeControl region (thrusters | wheels). */
#include "apps/apps.h"

#define GNC_ATTITUDE_LOSS_RATE_RAD_S 0.1  /* host threshold: rate above which attitude knowledge is declared lost */

static void gnc_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    const sm_instance_t *modes = &sys->sm[SM_TUG_MODES];
    struct { float rate_rad_s; uint8_t wheels; } att;
    struct { double range_m; float range_rate; } nav;
    sys->sim.wheels_active = sm_is_active(modes, sm_state_index(modes->def, "wheels", sm_state_index(modes->def, "attitudeControl", ARGENT_STATE_NONE)));
    sys->sim.rcs_active = !sys->sim.wheels_active;
    if (sys->sim.body_rate_rad_s > GNC_ATTITUDE_LOSS_RATE_RAD_S && minor_frame == 0) app_raise(sys, "GNC_EVT_ESTIMATOR_DIVERGED", sys->sim.body_rate_rad_s);
    att.rate_rad_s = (float)sys->sim.body_rate_rad_s; att.wheels = sys->sim.wheels_active;
    nav.range_m = sys->sim.range_m; nav.range_rate = (float)sys->sim.range_rate_m_s;
    bus_publish(&sys->bus, "attitudeStateTopic", &att, sizeof att);
    if (minor_frame == 0) bus_publish(&sys->bus, "navigationStateTopic", &nav, sizeof nav);
}

void app_gnc_init(argent_system_t *sys) { exec_bind_task(&sys->exec, "gncTask", gnc_task, sys); }
