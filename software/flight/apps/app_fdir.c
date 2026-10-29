/* FDIR application: FdirSupervisor (five parallel monitors) and the response relay, fed by the
 * fault-flagged events of the event service. */
#include "apps/apps.h"
#include <string.h>

static double limit_or(const char *name, double fallback) { double v = fallback; limit_get(name, &v); return v; }

static bool fdir_g1(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; return sys->app.flameout_retries < (uint32_t)limit_or("maximumFlameoutRetries", 2.0); }
static bool fdir_g2(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; return sys->app.flameout_retries >= (uint32_t)limit_or("maximumFlameoutRetries", 2.0); }
static bool fdir_g3(sm_instance_t *sm, const sm_event_t *ev) { (void)sm; return ev->arg[0] < limit_or("batteryLowFraction", 0.3); }
static bool fdir_g4(sm_instance_t *sm, const sm_event_t *ev) { (void)sm; return ev->arg[0] > limit_or("earthExclusionRadius", 63781.37) && ev->arg[1] <= limit_or("maximumImpactProbability", 1.0e-4); }
static bool fdir_g5(sm_instance_t *sm, const sm_event_t *ev) { (void)sm; return !fdir_g4(sm, ev); }

static void fdir_e1(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; sys->app.flameout_retries++; }
static void fdir_e2(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; if (sys->app.healthy_thrusters > 0) sys->app.healthy_thrusters--; sys->sim.healthy_thrusters = (uint8_t)sys->app.healthy_thrusters; }
static void fdir_e3(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; sys->app.ppu_trips++; }
static void fdir_e4(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; sys->app.last_earth_closest_approach = ev->arg[0]; sys->app.last_impact_probability = ev->arg[1]; }

static void fdir_call_safe(argent_system_t *sys, const char *reason)
{
    sys->app.safe_mode_requests++;
    app_send_to(sys, SM_FDIR_RELAY, "SafeModeRequest", NULL, 0.0, reason);
}
static void fdir_entry_expired(sm_instance_t *sm, int16_t s) { (void)s; fdir_call_safe(sm->ctx, "command-loss timer expired"); }
static void fdir_entry_string_lost(sm_instance_t *sm, int16_t s) { (void)s; fdir_call_safe(sm->ctx, "thruster string lost: operating set not available"); }
static void fdir_entry_ppu_lost(sm_instance_t *sm, int16_t s) { (void)s; fdir_call_safe(sm->ctx, "second PPU trip: thrust profile replan needed"); }
static void fdir_entry_load_shed(sm_instance_t *sm, int16_t s) { (void)s; fdir_call_safe(sm->ctx, "battery state of charge below load-shed fraction"); }
static void fdir_entry_sun_acquisition(sm_instance_t *sm, int16_t s) { (void)s; fdir_call_safe(sm->ctx, "attitude loss"); }
static void fdir_entry_aborted(sm_instance_t *sm, int16_t s) { (void)s; app_send_to(sm->ctx, SM_FDIR_RELAY, "AbortReturn", NULL, 0.0, "Earth-impact exclusion violated"); }

static void relay_e1(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; sys->app.relayed++; app_send_to(sys, SM_MODE_DISPATCHER, "SafeModeRequest", "fdirRequests", 0.0, ev->text); }
static void relay_e2(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; sys->app.relayed++; app_send_to(sys, SM_MODE_DISPATCHER, "AbortReturn", "fdirRequests", 0.0, ev->text); }

/* Fault events feed the supervisor as the model's FDIR items. */
static void fdir_on_fault(void *ctx, const argent_event_t *ev, argent_us_t now, double value)
{
    argent_system_t *sys = ctx;
    (void)now;
    if (strstr(ev->mnemonic, "FLAMEOUT") != NULL) app_send(sys, "ThrusterFlameout", "command", value, NULL);
    else if (strstr(ev->mnemonic, "PPU") != NULL) app_send(sys, "PpuTrip", "command", value, NULL);
    else if (strstr(ev->mnemonic, "BATT") != NULL && strstr(ev->mnemonic, "LOW") != NULL) app_send(sys, "BatteryLow", "command", value, NULL);
    else if (strstr(ev->mnemonic, "STAR_TRACKER_LOST") != NULL || strstr(ev->mnemonic, "ESTIMATOR_DIVERGED") != NULL) app_send(sys, "AttitudeLoss", "command", value, NULL);
    else if (strstr(ev->mnemonic, "PROCESSOR_RESET") != NULL || strstr(ev->mnemonic, "WATCHDOG") != NULL) app_send(sys, "ProcessorReset", "faults", value, NULL);
}

static void fdir_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    struct { uint32_t safe_requests; uint32_t flameout_retries; uint32_t ppu_trips; uint8_t healthy; } report;
    (void)minor_frame;
    report.safe_requests = sys->app.safe_mode_requests; report.flameout_retries = sys->app.flameout_retries;
    report.ppu_trips = sys->app.ppu_trips; report.healthy = (uint8_t)sys->app.healthy_thrusters;
    bus_publish(&sys->bus, "faultReportTopic", &report, sizeof report);
}

void app_fdir_init(argent_system_t *sys)
{
    sm_instance_t *sm = &sys->sm[SM_FDIR_SUPERVISOR];
    sm_instance_t *relay = &sys->sm[SM_FDIR_RELAY];
    sm_register_guard(sm, "FDIR_SUPERVISOR_G1", fdir_g1);
    sm_register_guard(sm, "FDIR_SUPERVISOR_G2", fdir_g2);
    sm_register_guard(sm, "FDIR_SUPERVISOR_G3", fdir_g3);
    sm_register_guard(sm, "FDIR_SUPERVISOR_G4", fdir_g4);
    sm_register_guard(sm, "FDIR_SUPERVISOR_G5", fdir_g5);
    sm_register_effect(sm, "FDIR_SUPERVISOR_E1", fdir_e1);
    sm_register_effect(sm, "FDIR_SUPERVISOR_E2", fdir_e2);
    sm_register_effect(sm, "FDIR_SUPERVISOR_E3", fdir_e3);
    sm_register_effect(sm, "FDIR_SUPERVISOR_E4", fdir_e4);
    sm_register_entry(sm, "TethysFdir::FdirSupervisor::commandLossTimer::expired", fdir_entry_expired);
    sm_register_entry(sm, "TethysFdir::FdirSupervisor::thrusterHealth::stringLost", fdir_entry_string_lost);
    sm_register_entry(sm, "TethysFdir::FdirSupervisor::ppuHealth::ppuLost", fdir_entry_ppu_lost);
    sm_register_entry(sm, "TethysFdir::FdirSupervisor::powerHealth::loadShed", fdir_entry_load_shed);
    sm_register_entry(sm, "TethysFdir::FdirSupervisor::attitudeHealth::sunAcquisition", fdir_entry_sun_acquisition);
    sm_register_entry(sm, "TethysFdir::FdirSupervisor::earthImpactExclusion::aborted", fdir_entry_aborted);
    sm_register_effect(relay, "FDIR_RESPONSE_RELAY_E1", relay_e1);
    sm_register_effect(relay, "FDIR_RESPONSE_RELAY_E2", relay_e2);
    event_set_fdir_sink(&sys->events, fdir_on_fault, sys);
    exec_bind_task(&sys->exec, "fdirTask", fdir_task, sys);
}
