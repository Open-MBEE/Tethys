/* Autonomy/sequencing application: the sequencing engine runs the six on-board sequences as data
 * following the model's SequenceRun (load, constraint check, time-tagged dispatch, abort). */
#include "apps/apps.h"
#include <string.h>

#define AUTONOMY_RELEASE_DELAY_S 600.0  /* SequenceRun::releaseDelay as the model scenario runs it */
#define AUTONOMY_POWER_MARGIN_FRACTION 0.1

const system_sequence_t system_sequences[SYSTEM_SEQUENCE_COUNT] = {
    { 1, "ThrustArc", 2, { "SepThrust", "SepStandby" }, { 0.0, 7.0 * 86400.0 } },
    { 2, "DespinSequence", 2, { "DespinPulseTrain", "DespinComplete" }, { 0.0, 2.0 * 3600.0 } },
    { 3, "InspectorReleaseSequence", 3, { "InspectorCheckoutGo", "InspectorReleaseGo", "InspectorImagingGo" }, { 0.0, 12.0 * 3600.0, 3600.0 } },
    { 4, "DroInsertionSequence", 2, { "SepThrust", "DroHoldGo" }, { 0.0, 2.0 * 86400.0 } },
    { 5, "DroStationKeeping", 1, { "StationKeepingTrim" }, { 0.0 } },
    { 6, "MissionSequence", 1, { "SequenceStepReport" }, { 0.0 } },
};

static bool sequence_loaded(uint16_t id) { for (unsigned i = 0; i < SYSTEM_SEQUENCE_COUNT; i++) if (system_sequences[i].id == id) return true; return false; }

static void autonomy_start(argent_system_t *sys, uint16_t id)
{
    bool allowed_mode = sys->mode != (uint16_t)ARGENT_TUG_MODE_LAUNCH;  /* allowedModes = allFlightModes */
    bool passed = allowed_mode && AUTONOMY_POWER_MARGIN_FRACTION >= 0.0;
    if (!sequence_loaded(id) || !passed) {
        app_raise(sys, "AUT_EVT_SEQUENCE_FAILED", (double)id);
        return;
    }
    sys->app.running_sequence = id;
    sys->app.sequence_step = 0;
    sys->app.sequence_next_us = hal_timer_now() + argent_s_to_us(AUTONOMY_RELEASE_DELAY_S);
    app_raise(sys, "AUT_EVT_SEQUENCE_STARTED", (double)id);
}

static void autonomy_abort(argent_system_t *sys)
{
    if (sys->app.running_sequence != 0) app_raise(sys, "AUT_EVT_SEQUENCE_FAILED", (double)sys->app.running_sequence);
    sys->app.running_sequence = 0;
}

void system_on_item(argent_system_t *sys, const char *name, const char *port, const double *args, const char *text)
{
    (void)port; (void)text;
    if (strcmp(name, "SequenceStart") == 0) autonomy_start(sys, (uint16_t)args[0]);
    else if (strcmp(name, "SequenceAbort") == 0) autonomy_abort(sys);
}

static void autonomy_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    const system_sequence_t *seq = NULL;
    struct { uint16_t sequence; uint8_t step; uint32_t sent; } step_msg;
    (void)minor_frame;
    if (sys->app.running_sequence == 0) return;
    for (unsigned i = 0; i < SYSTEM_SEQUENCE_COUNT; i++) if (system_sequences[i].id == sys->app.running_sequence) seq = &system_sequences[i];
    if (seq == NULL || hal_timer_now() < sys->app.sequence_next_us) return;
    app_send(sys, seq->step_item[sys->app.sequence_step], "command", 0.0, NULL);
    sys->app.steps_sent++;
    step_msg.sequence = seq->id; step_msg.step = sys->app.sequence_step; step_msg.sent = sys->app.steps_sent;
    bus_publish(&sys->bus, "sequenceStepTopic", &step_msg, sizeof step_msg);
    sys->app.sequence_step++;
    if (sys->app.sequence_step >= seq->step_count) {
        sys->app.sequences_run++;
        sys->app.running_sequence = 0;
        app_raise(sys, "AUT_EVT_SEQUENCE_COMPLETE", (double)seq->id);
    } else {
        sys->app.sequence_next_us = hal_timer_now() + argent_s_to_us(seq->step_delay_s[sys->app.sequence_step]);
    }
}

void app_autonomy_init(argent_system_t *sys) { exec_bind_task(&sys->exec, "autonomyTask", autonomy_task, sys); }
