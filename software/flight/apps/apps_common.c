#include "apps/apps.h"
#include <stdio.h>
#include <string.h>

void apps_init(argent_system_t *sys)
{
    app_cdh_init(sys);
    app_gnc_init(sys);
    app_sep_init(sys);
    app_power_init(sys);
    app_thermal_init(sys);
    app_telecom_init(sys);
    app_inspector_init(sys);
    app_capture_init(sys);
    app_autonomy_init(sys);
    app_fdir_init(sys);
    app_mode_init(sys);
    app_pbu_init(sys);
    for (unsigned i = 0; i < SM_INDEX_COUNT; i++) {
        const char *missing = NULL;
        sm_set_duration_resolver(&sys->sm[i], app_duration_resolver);
        if (!sm_fully_bound(&sys->sm[i], &missing)) system_fault(sys, missing != NULL ? missing : "unbound expression");
    }
}

void app_raise(argent_system_t *sys, const char *event_mnemonic, double value)
{
    if (!event_raise(&sys->events, event_mnemonic, hal_timer_now(), value)) system_fault(sys, event_mnemonic);
}

void app_send(argent_system_t *sys, const char *item, const char *port, double arg0, const char *text)
{
    app_send_to(sys, -1, item, port, arg0, text);
}

void app_send_to(argent_system_t *sys, int8_t target, const char *item, const char *port, double arg0, const char *text)
{
    double args[SM_MAX_EVENT_ARGS] = { arg0, 0.0, 0.0, 0.0 };
    system_post_item_to(sys, target, item, port, args, 1, text);
}

/* Model durations referenced by name in the generated transition tables (model 62/65 values). */
static const struct { const char *symbol; double seconds; } app_durations[] = {
    { "restartDelay", 2.0 * 3600.0 },               /* SepStringController::restartDelay = 2.0 [h] */
    { "passDuration", 8.0 * 3600.0 },               /* TelecomManager::passDuration = 8.0 [h] */
    { "heartbeatTimeout", 60.0 },                   /* RedundancyManager::heartbeatTimeout = 60.0 [s] */
    { "switchoverDuration", 30.0 },                 /* RedundancyManager::switchoverDuration = 30.0 [s] */
    { "bootTimeout", 120.0 },                       /* BootUpdateManager::bootTimeout = 120.0 [s] */
    { "checkoutDuration", 4.0 * 3600.0 },           /* InspectorHandler::checkoutDuration = 4.0 [h] */
    { "despinDuration", 2.0 * 3600.0 },             /* CaptureController::despinDuration = 2.0 [h] */
    { "arraysDeploymentTimeout", 2.0 * 3600.0 },    /* TugModes::arraysDeploymentTimeout = 2.0 [h] */
    { "disposalBurnDuration", 30.0 * 86400.0 },     /* TugModes::disposalBurnDuration = 30.0 [d] */
    { "limits.commandLossTimeout", 7.0 * 86400.0 }, /* FdirLimits::commandLossTimeout = 7.0 [d] */
    { "limits.thrusterRestartDelay", 2.0 * 3600.0 },/* FdirLimits::thrusterRestartDelay = 2.0 [h] */
};

bool app_duration_resolver(sm_instance_t *sm, const char *symbol, argent_us_t *out)
{
    (void)sm;
    for (unsigned i = 0; i < sizeof app_durations / sizeof app_durations[0]; i++) {
        if (strcmp(app_durations[i].symbol, symbol) == 0) { *out = argent_s_to_us(app_durations[i].seconds); return true; }
    }
    return false;
}

bool app_duration(argent_system_t *sys, const char *symbol, argent_us_t *out) { (void)sys; return app_duration_resolver(NULL, symbol, out); }
