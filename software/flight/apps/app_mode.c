/* Mode management application: the TugModes machine (five parallel regions) and the mode
 * dispatcher that turns mode transitions into application commands; it also maps the active
 * flight mode onto the generated mode table for the executive, bus and telemetry. */
#include "apps/apps.h"
#include <stdio.h>
#include <string.h>

#define MODES_RENDEZVOUS_RANGE_M 50000.0        /* TugModes::rendezvousRange = 50.0 [km] */
#define MODES_MAX_BODY_MASS_KG 542485.809768173  /* TethysBudgets::captureCommitEnvelope.maximumBodyMass (returnable mass, runs/fdir-thruster-restarting.txt) */
#define MODES_MAX_BODY_DIAMETER_M 10.0          /* CaptureSystem::maximumBodyDiameter = 10.0 [m] */

static bool modes_g1(sm_instance_t *sm, const sm_event_t *ev) { (void)sm; return ev->arg[0] <= MODES_RENDEZVOUS_RANGE_M; }
static bool modes_g2(sm_instance_t *sm, const sm_event_t *ev) { (void)sm; return ev->arg[1] <= MODES_MAX_BODY_MASS_KG && ev->arg[0] <= MODES_MAX_BODY_DIAMETER_M; /* args in message order: estimatedDiameter, estimatedMass */ }
static bool modes_g3(sm_instance_t *sm, const sm_event_t *ev) { (void)sm; return !modes_g2(sm, ev); }
static bool modes_g4(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; return sys->app.captured; }
static bool modes_g5(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; return !sys->app.captured; }
static void modes_e1(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; sys->app.captured = true; }
static void modes_e_reason(sm_instance_t *sm, const sm_event_t *ev)
{
    argent_system_t *sys = sm->ctx;
    snprintf(sys->app.last_safe_mode_reason, sizeof sys->app.last_safe_mode_reason, "%s", ev->text != NULL ? ev->text : "");
}

static void modes_app_command(argent_system_t *sys, const char *text)
{
    snprintf(sys->app.last_application_command, sizeof sys->app.last_application_command, "%s", text);
    sys->app.application_commands++;
}
static void modes_entry_thrust(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.thrust_arcs_started++; modes_app_command(sys, "SepControlApplication: start thrust arc"); }
static void modes_exit_thrust(sm_instance_t *sm, int16_t s) { (void)s; modes_app_command(sm->ctx, "SepControlApplication: end thrust arc"); }
static void modes_entry_prox(sm_instance_t *sm, int16_t s) { (void)s; modes_app_command(sm->ctx, "TelecomApplication, InspectorHandlingApplication: proximity relay on"); }
static void modes_entry_capture(sm_instance_t *sm, int16_t s) { (void)s; modes_app_command(sm->ctx, "CaptureControlApplication: arm"); }
static void modes_exit_capture(sm_instance_t *sm, int16_t s) { (void)s; modes_app_command(sm->ctx, "CaptureControlApplication: disarm"); }
static void modes_entry_stack_thrust(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.thrust_arcs_started++; modes_app_command(sys, "SepControlApplication: start return arc"); }
static void modes_entry_safe(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.safe_mode_entries++; modes_app_command(sys, "PowerManagementApplication: shed loads; TelecomApplication: low-gain safe rate"); app_raise(sys, "FDR_EVT_SAFE_MODE_ENTERED", (double)sys->app.safe_mode_entries); }
static void modes_entry_abort(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.abort_entries++; modes_app_command(sys, "AutonomyApplication: abort sequence; SepControlApplication: thrust inhibited"); app_raise(sys, "FDR_EVT_ABORT_RETREAT", (double)sys->app.abort_entries); }

/* Dispatcher effects: each sends the model's application commands and counts the dispatch. */
static void dispatch_report(argent_system_t *sys, const char *report) { app_raise(sys, "MOD_EVT_MODE_ENTERED", 0.0); (void)report; sys->app.dispatched++; }
static void disp_e1(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_SEP_STRING, "SepStandby", "command", 0, NULL); app_send_to(sys, SM_TELECOM_MANAGER, "HighGainSelect", "command", 0, NULL); app_send_to(sys, SM_POWER_MANAGER, "LoadRestore", "command", 0, NULL); dispatch_report(sys, "early operations"); }
static void disp_e2(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_SEP_STRING, "SepThrust", "command", 0, NULL); app_send_to(sys, SM_TELECOM_MANAGER, "LowGainSelect", "command", 0, NULL); dispatch_report(sys, "thrust arc"); }
static void disp_e3(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_SEP_STRING, "SepStandby", "command", 0, NULL); app_send_to(sys, SM_TELECOM_MANAGER, "HighGainSelect", "command", 0, NULL); dispatch_report(sys, "coast"); }
static void disp_e4(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_SEP_STRING, "SepThrust", "command", 0, NULL); dispatch_report(sys, "approach"); }
static void disp_e5(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_SEP_STRING, "SepStandby", "command", 0, NULL); app_send_to(sys, SM_TELECOM_MANAGER, "RelayEnable", "command", 0, NULL); dispatch_report(sys, "proximity operations"); }
static void disp_e6(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_CAPTURE_CONTROLLER, "CaptureArm", "command", 0, NULL); app_send_to(sys, SM_TARGET_SERVICES, "SequenceStart", "command", 3.0, NULL); dispatch_report(sys, "capture"); }
static void disp_e7(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_CAPTURE_CONTROLLER, "CaptureDisarm", "command", 0, NULL); app_send_to(sys, SM_TELECOM_MANAGER, "RelayDisable", "command", 0, NULL); dispatch_report(sys, "despin"); }
static void disp_e8(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_SEP_STRING, "SepThrust", "command", 0, NULL); app_send_to(sys, SM_TELECOM_MANAGER, "LowGainSelect", "command", 0, NULL); dispatch_report(sys, "stack thrust"); }
static void disp_e9(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_TELECOM_MANAGER, "RelayEnable", "command", 0, NULL); dispatch_report(sys, "docking"); }
static void disp_e10(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_SEP_STRING, "SepThrust", "command", 0, NULL); app_send_to(sys, SM_TELECOM_MANAGER, "RelayDisable", "command", 0, NULL); dispatch_report(sys, "disposal"); }
static void disp_e11(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_INSPECTOR_HANDLER, "InspectorCheckoutGo", "command", 0, NULL); sys->app.dispatched++; }
static void disp_e12(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_INSPECTOR_HANDLER, "InspectorReleaseGo", "command", 0, NULL); app_send_to(sys, SM_TELECOM_MANAGER, "RelayEnable", "command", 0, NULL); sys->app.dispatched++; }
static void disp_e13(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_INSPECTOR_HANDLER, "InspectorRetireGo", "command", 0, NULL); app_send_to(sys, SM_TELECOM_MANAGER, "RelayDisable", "command", 0, NULL); sys->app.dispatched++; }
static void disp_e14(sm_instance_t *sm, const sm_event_t *ev)
{
    argent_system_t *sys = sm->ctx;
    app_send_to(sys, SM_TUG_MODES, "SafeModeRequest", "modes", 0, ev->text);
    app_send_to(sys, SM_SEP_STRING, "SepOff", "command", 0, NULL); app_send_to(sys, SM_TELECOM_MANAGER, "LowGainSelect", "command", 0, NULL);
    app_send_to(sys, SM_POWER_MANAGER, "LoadShed", "command", 0, NULL); app_send_to(sys, SM_THERMAL_CONTROLLER, "LoadShed", "command", 0, NULL); app_send_to(sys, SM_CAPTURE_CONTROLLER, "CaptureDisarm", "command", 0, NULL); app_send_to(sys, SM_TARGET_SERVICES, "SequenceAbort", "command", 0, NULL);
    dispatch_report(sys, "safe mode");
}
static void disp_e15(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; app_send_to(sys, SM_SEP_STRING, "SepStandby", "command", 0, NULL); app_send_to(sys, SM_TELECOM_MANAGER, "HighGainSelect", "command", 0, NULL); app_send_to(sys, SM_POWER_MANAGER, "LoadRestore", "command", 0, NULL); app_send_to(sys, SM_THERMAL_CONTROLLER, "LoadRestore", "command", 0, NULL); app_send_to(sys, SM_THERMAL_CONTROLLER, "LoadRestore", "command", 0, NULL); dispatch_report(sys, "recover"); }
static void disp_e16(sm_instance_t *sm, const sm_event_t *ev)
{
    argent_system_t *sys = sm->ctx;
    app_send_to(sys, SM_TUG_MODES, "AbortReturn", "modes", 0, ev->text);
    app_send_to(sys, SM_SEP_STRING, "SepOff", "command", 0, NULL); app_send_to(sys, SM_TELECOM_MANAGER, "HighGainSelect", "command", 0, NULL); app_send_to(sys, SM_TARGET_SERVICES, "SequenceAbort", "command", 0, NULL);
    dispatch_report(sys, "abort hold");
}

/* flightMode leaf -> mode table row. The two launch substates map onto launch/earlyOperations. */
void system_refresh_mode(argent_system_t *sys)
{
    const sm_instance_t *sm = &sys->sm[SM_TUG_MODES];
    const argent_state_machine_t *def = sm->def;
    uint16_t row = sys->mode;
    for (int16_t s = 0; s < (int16_t)def->state_count; s++) {
        const argent_state_t *st = &argent_tug_modes_states[s];
        const char *name;
        if (!st->leaf || !sm_is_active(sm, s)) continue;
        if (st->parent == ARGENT_STATE_NONE) continue;
        if (argent_tug_modes_states[st->parent].parent != ARGENT_STATE_NONE && argent_tug_modes_states[argent_tug_modes_states[st->parent].parent].parent != ARGENT_STATE_NONE) continue;
        name = st->name;
        if (strcmp(name, "onLauncher") == 0) name = "launch";
        else if (strcmp(name, "deploying") == 0) name = "earlyOperations";
        for (uint16_t m = 0; m < ARGENT_MODE_ROW_COUNT; m++) if (strcmp(argent_mode_table[m].name, name) == 0) { row = m; break; }
        if (strcmp(st->name, "thrust") == 0 || strcmp(st->name, "stackThrust") == 0 || strcmp(st->name, "approach") == 0 || strcmp(st->name, "disposal") == 0) {
            /* flight modes in which the SEP string may thrust */
        }
        break;
    }
    command_set_inhibit(&sys->commands, INHIBIT_CAPTURE_MODE, strcmp(argent_mode_table[row].name, "capture") != 0);
    if (row != sys->mode) {
        struct { uint16_t from; uint16_t to; } change = { sys->mode, row };
        sys->mode = row;
        sys->mode_changes++;
        sys->exec.mode = row;
        bus_publish(&sys->bus, "modeChangeTopic", &change, sizeof change);
        app_raise(sys, "MOD_EVT_MODE_CHANGE_SEEN", (double)row);
    }
}

static void mode_task(void *ctx, uint32_t minor_frame) { argent_system_t *sys = ctx; (void)minor_frame; system_deliver_queued(sys); system_refresh_mode(sys); }

void app_mode_init(argent_system_t *sys)
{
    sm_instance_t *sm = &sys->sm[SM_TUG_MODES];
    sm_instance_t *disp = &sys->sm[SM_MODE_DISPATCHER];
    static const sm_effect_fn disp_fns[16] = { disp_e1, disp_e2, disp_e3, disp_e4, disp_e5, disp_e6, disp_e7, disp_e8, disp_e9, disp_e10, disp_e11, disp_e12, disp_e13, disp_e14, disp_e15, disp_e16 };
    char id[40];
    sm_register_guard(sm, "TUG_MODES_G1", modes_g1);
    sm_register_guard(sm, "TUG_MODES_G2", modes_g2);
    sm_register_guard(sm, "TUG_MODES_G3", modes_g3);
    sm_register_guard(sm, "TUG_MODES_G4", modes_g4);
    sm_register_guard(sm, "TUG_MODES_G5", modes_g5);
    sm_register_effect(sm, "TUG_MODES_E1", modes_e1);
    sm_register_effect(sm, "TUG_MODES_E2", modes_e_reason);
    sm_register_effect(sm, "TUG_MODES_E3", modes_e_reason);
    sm_register_entry(sm, "TethysModes::TugModes::flightMode::freeFlight::thrust", modes_entry_thrust);
    sm_register_exit(sm, "TethysModes::TugModes::flightMode::freeFlight::thrust", modes_exit_thrust);
    sm_register_entry(sm, "TethysModes::TugModes::flightMode::freeFlight::proximityOperations", modes_entry_prox);
    sm_register_entry(sm, "TethysModes::TugModes::flightMode::freeFlight::capture", modes_entry_capture);
    sm_register_exit(sm, "TethysModes::TugModes::flightMode::freeFlight::capture", modes_exit_capture);
    sm_register_entry(sm, "TethysModes::TugModes::flightMode::stacked::stackThrust", modes_entry_stack_thrust);
    sm_register_entry(sm, "TethysModes::TugModes::flightMode::safe", modes_entry_safe);
    sm_register_entry(sm, "TethysModes::TugModes::flightMode::abortHold", modes_entry_abort);
    for (unsigned i = 0; i < 16u; i++) { snprintf(id, sizeof id, "MODE_MANAGEMENT_DISPATCHER_E%u", i + 1u); sm_register_effect(disp, id, disp_fns[i]); }
    exec_bind_task(&sys->exec, "modeManagementTask", mode_task, sys);
}
