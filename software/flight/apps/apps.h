/* The twelve applications of the Argent flight software, one module each. apps_init() attaches
 * every application to the system: machine guards/effects/actions by id, executive tasks by
 * name, bus subscriptions per the message catalogue. */
#ifndef ARGENT_APPS_H
#define ARGENT_APPS_H
#include "apps/system.h"

void apps_init(argent_system_t *sys);
void app_cdh_init(argent_system_t *sys);
void app_gnc_init(argent_system_t *sys);
void app_sep_init(argent_system_t *sys);
void app_power_init(argent_system_t *sys);
void app_thermal_init(argent_system_t *sys);
void app_telecom_init(argent_system_t *sys);
void app_inspector_init(argent_system_t *sys);
void app_capture_init(argent_system_t *sys);
void app_autonomy_init(argent_system_t *sys);
void app_fdir_init(argent_system_t *sys);
void app_mode_init(argent_system_t *sys);
void app_pbu_init(argent_system_t *sys);
/* Shared helpers for the application modules. */
void app_raise(argent_system_t *sys, const char *event_mnemonic, double value);
void app_send(argent_system_t *sys, const char *item, const char *port, double arg0, const char *text);
void app_send_to(argent_system_t *sys, int8_t target, const char *item, const char *port, double arg0, const char *text);
bool app_duration(argent_system_t *sys, const char *symbol, argent_us_t *out);
bool app_duration_resolver(sm_instance_t *sm, const char *symbol, argent_us_t *out);

#endif
