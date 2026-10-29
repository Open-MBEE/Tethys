/* The integrated system: machine order, every guard/effect bound, reachability, sequences, determinism. */
#include "tests/runner.h"
#include "apps/system.h"
#include "hal/hal.h"

static void test_machine_order_and_binding(void)
{
    static argent_system_t sys;
    system_init(&sys, NULL);
    CHECK(SM_INDEX_COUNT == ARGENT_STATE_MACHINE_COUNT);
    CHECK_EQ_STR(sys.sm[SM_TUG_MODES].def->name, "TugModes");
    CHECK_EQ_STR(sys.sm[SM_MODE_DISPATCHER].def->name, "ModeManagementDispatcher");
    CHECK_EQ_STR(sys.sm[SM_FDIR_SUPERVISOR].def->name, "FdirSupervisor");
    CHECK_EQ_STR(sys.sm[SM_SEP_STRING].def->name, "SepStringController");
    CHECK_EQ_STR(sys.sm[SM_CAPTURE_CONTROLLER].def->name, "CaptureController");
    CHECK_EQ_STR(sys.sm[SM_BOOT_UPDATE_MANAGER].def->name, "BootUpdateManager");
    CHECK_EQ_STR(sys.sm[SM_REDUNDANCY_MANAGER].def->name, "RedundancyManager");
    unsigned guards = 0, effects = 0, states = 0, transitions = 0;
    for (unsigned i = 0; i < SM_INDEX_COUNT; i++) {
        const char *missing = NULL;
        CHECK_EQ_STR(sys.sm[i].def->name, argent_state_machines[i].name);
        CHECK(sm_fully_bound(&sys.sm[i], &missing));
        if (missing) printf("  %s: unbound %s\n", sys.sm[i].def->name, missing);
        guards += sys.sm[i].def->guard_count; effects += sys.sm[i].def->effect_count;
        states += sys.sm[i].def->state_count; transitions += sys.sm[i].def->transition_count;
    }
    CHECK(states == 103u && transitions == 169u);   /* the generated totals */
    printf("  %u guards, %u effects bound over %u states / %u transitions\n", guards, effects, states, transitions);
}

/* Entering a state enters its ancestors and its initial substate chain; a transition is reachable when its source is. */
static void mark(const argent_state_machine_t *def, int16_t s, bool *reached)
{
    while (s >= 0 && !reached[s]) {
        reached[s] = true;
        int16_t sub = def->states[s].initial_substate;
        for (int16_t p = def->states[s].parent; p >= 0 && !reached[p]; p = def->states[p].parent) reached[p] = true;
        s = sub;
    }
}

static void test_every_state_and_transition_reachable(void)
{
    for (unsigned m = 0; m < ARGENT_STATE_MACHINE_COUNT; m++) {
        const argent_state_machine_t *def = &argent_state_machines[m];
        bool reached[SM_MAX_STATES] = { false };
        bool changed = true;
        /* As the runner starts: a parallel machine (no initial state) enters every top-level region. */
        if (def->initial_state == ARGENT_STATE_NONE) {
            for (unsigned s = 0; s < def->state_count; s++) if (def->states[s].parent == ARGENT_STATE_NONE) mark(def, (int16_t)s, reached);
        } else {
            mark(def, def->initial_state, reached);
        }
        while (changed) {
            changed = false;
            for (unsigned t = 0; t < def->transition_count; t++) {
                const argent_transition_t *tr = &def->transitions[t];
                if (tr->source < 0 || !reached[tr->source] || tr->target < 0 || reached[tr->target]) continue;
                mark(def, tr->target, reached);
                changed = true;
            }
        }
        for (unsigned s = 0; s < def->state_count; s++) {
            CHECK(reached[s]);
            if (!reached[s]) printf("  %s: state %s unreachable\n", def->name, def->states[s].qualified_name);
        }
        for (unsigned t = 0; t < def->transition_count; t++) {
            CHECK(def->transitions[t].source >= 0 && reached[def->transitions[t].source]);
            if (def->transitions[t].source < 0 || !reached[def->transitions[t].source]) printf("  %s: transition %u from %d unreachable\n", def->name, t, def->transitions[t].source);
        }
    }
}

static void run_seconds(argent_system_t *sys, double seconds)
{
    for (uint64_t f = 0; f < (uint64_t)(seconds * ARGENT_MINOR_FRAMES); f++) system_run_minor_frame(sys);
}

static void to_coast(argent_system_t *sys)
{
    /* Launch runs no application task (the tables' active-mode masks exclude it): separate and deploy first. */
    system_deliver_item(sys, "SeparationConfirmed", "command", NULL, NULL);
    system_deliver_item(sys, "ArraysDeployed", "command", NULL, NULL);
    system_deliver_queued(sys);
    system_refresh_mode(sys);
}

static void test_sequences_run_as_data(void)
{
    static argent_system_t sys;
    CHECK(SYSTEM_SEQUENCE_COUNT == 6u);
    for (unsigned i = 0; i < SYSTEM_SEQUENCE_COUNT; i++) {
        CHECK(system_sequences[i].id == i + 1u && system_sequences[i].step_count > 0);
        for (unsigned s = 0; s < system_sequences[i].step_count; s++) CHECK(system_sequences[i].step_item[s] != NULL);
    }
    for (unsigned i = 0; i < SYSTEM_SEQUENCE_COUNT; i++) {
        const system_sequence_t *seq = &system_sequences[i];
        double args[SM_MAX_EVENT_ARGS] = { (double)seq->id };
        system_init(&sys, NULL);
        to_coast(&sys);
        system_deliver_item_to(&sys, SM_TARGET_SERVICES, "SequenceStart", "command", args, NULL);
        /* Step delays run to days: the simulated clock is advanced over them, the engine fires on the next frames. */
        hal_timer_advance(argent_s_to_us(600.0));
        for (unsigned st = 0; st < seq->step_count; st++) {
            if (st > 0) {
                /* A ground pass half-way keeps the 7 d command-loss timer (model 62) from forcing safe mode. */
                hal_timer_advance(argent_s_to_us(seq->step_delay_s[st] / 2.0));
                run_seconds(&sys, 1.0);
                system_deliver_item(&sys, "GroundContact", "command", NULL, NULL);
                hal_timer_advance(argent_s_to_us(seq->step_delay_s[st] / 2.0));
            }
            run_seconds(&sys, 1.0);
            CHECK(sys.app.steps_sent == st + 1u);
        }
        CHECK(sys.app.sequences_run == 1 && sys.app.running_sequence == 0);
        if (sys.app.steps_sent != seq->step_count) printf("  sequence %s: %u of %u steps sent\n", seq->name, sys.app.steps_sent, seq->step_count);
    }
}

static bool in_state(const argent_system_t *sys, unsigned machine, const char *name)
{
    return sm_is_active(&sys->sm[machine], sm_state_index(sys->sm[machine].def, name, ARGENT_STATE_NONE));
}

static void pass_days(argent_system_t *sys, double days)
{
    /* Advance in ground-pass steps so the 7 d command-loss timer (model 62) never forces safe mode. */
    while (days > 0.0) {
        double step = days < 5.0 ? days : 5.0;
        hal_timer_advance(argent_s_to_us(step * 86400.0));
        run_seconds(sys, 1.0);
        system_deliver_item(sys, "GroundContact", "command", NULL, NULL);
        run_seconds(sys, 1.0);
        days -= step;
    }
}

static void test_far_field_range_update_keeps_thrusting(void)
{
    static argent_system_t sys;
    double range[SM_MAX_EVENT_ARGS] = { 500.0 };   /* RangeUpdate(range = 500.0 [km]) */
    char buf[SM_CONFIG_LEN];
    system_init(&sys, NULL);
    to_coast(&sys);
    system_deliver_item(&sys, "ProximityOperationsGo", "command", NULL, NULL);
    run_seconds(&sys, 1.0);
    CHECK(in_state(&sys, SM_SEP_STRING, "thrusting") && sys.sim.sep_thrusting);
    system_deliver_item(&sys, "RangeUpdate", "command", range, NULL);
    run_seconds(&sys, 1.0);
    sm_config(&sys.sm[SM_TUG_MODES], buf, sizeof buf);
    CHECK(strncmp(buf, "approach | thrusting", 20) == 0);
    CHECK(in_state(&sys, SM_SEP_STRING, "thrusting") && sys.sim.sep_thrusting);
    range[0] = 20.0;
    system_deliver_item(&sys, "RangeUpdate", "command", range, NULL);
    run_seconds(&sys, 1.0);
    sm_config(&sys.sm[SM_TUG_MODES], buf, sizeof buf);
    CHECK(strncmp(buf, "proximityOperations | standby", 29) == 0);
    CHECK(in_state(&sys, SM_SEP_STRING, "standby") && !sys.sim.sep_thrusting);
}

static void test_disposal_burn_ends_off(void)
{
    static argent_system_t sys;
    char buf[SM_CONFIG_LEN];
    system_init(&sys, NULL);
    to_coast(&sys);
    system_deliver_item(&sys, "DisposalGo", "command", NULL, NULL);
    run_seconds(&sys, 1.0);
    CHECK(in_state(&sys, SM_SEP_STRING, "disposalBurn") && sys.sim.sep_thrusting);
    CHECK(sys.app.sep_burn_duration_us == argent_s_to_us(30.0 * 86400.0));
    pass_days(&sys, 29.0);
    CHECK(in_state(&sys, SM_SEP_STRING, "disposalBurn") && sys.sim.sep_thrusting);
    pass_days(&sys, 1.5);
    sm_config(&sys.sm[SM_TUG_MODES], buf, sizeof buf);
    CHECK(strstr(buf, " | off | ") != NULL);   /* the mode machine's sepString region left disposalBurn too */
    CHECK(in_state(&sys, SM_SEP_STRING, "off") && !sys.sim.sep_thrusting);
}

/* Hour steps: the handler's checkout and pass timers and the sequence's step delays interleave as in flight. */
static void pass_hours(argent_system_t *sys, double hours)
{
    while (hours > 0.0) {
        double step = hours < 1.0 ? hours : 1.0;
        hal_timer_advance(argent_s_to_us(step * 3600.0));
        run_seconds(sys, 1.0);
        hours -= step;
    }
}

/* A flameout during the disposal burn restarts into the burn again for its full duration (model 65 restartingDisposal). */
static void test_disposal_burn_flameout_restarts_bounded(void)
{
    static argent_system_t sys;
    double thruster[SM_MAX_EVENT_ARGS] = { 2.0 };   /* ThrusterFlameout(thrusterId = 2) */
    uint32_t restarts;
    system_init(&sys, NULL);
    to_coast(&sys);
    system_deliver_item(&sys, "DisposalGo", "command", NULL, NULL);
    run_seconds(&sys, 1.0);
    CHECK(in_state(&sys, SM_SEP_STRING, "disposalBurn") && sys.sim.sep_thrusting);
    pass_days(&sys, 10.0);
    restarts = sys.app.restarts;
    system_deliver_item(&sys, "ThrusterFlameout", "command", thruster, NULL);
    run_seconds(&sys, 1.0);
    CHECK(in_state(&sys, SM_SEP_STRING, "restartingDisposal") && !sys.sim.sep_thrusting);
    CHECK(sys.app.restarts == restarts + 1);
    pass_days(&sys, 0.125);   /* 3 h: past the 2 h restartDelay */
    CHECK(in_state(&sys, SM_SEP_STRING, "disposalBurn") && sys.sim.sep_thrusting);
    pass_days(&sys, 29.0);    /* the burn runs its full 30 d again from the restart, not the 20 d that remained */
    CHECK(in_state(&sys, SM_SEP_STRING, "disposalBurn") && sys.sim.sep_thrusting);
    pass_days(&sys, 1.5);
    CHECK(in_state(&sys, SM_SEP_STRING, "off") && !sys.sim.sep_thrusting);
}

static void test_inspector_relays_the_requested_pass(void)
{
    static argent_system_t sys;
    double range[SM_MAX_EVENT_ARGS] = { 20.0 };
    double target[SM_MAX_EVENT_ARGS] = { 6.8, 362000.0 };   /* CaptureGo(estimatedDiameter, estimatedMass) */
    double pass[SM_MAX_EVENT_ARGS] = { 4.0 };               /* InspectorImagingGo(passDuration = 4.0 [h]) */
    system_init(&sys, NULL);
    to_coast(&sys);
    system_deliver_item(&sys, "ProximityOperationsGo", "command", NULL, NULL); run_seconds(&sys, 1.0);
    system_deliver_item(&sys, "RangeUpdate", "command", range, NULL); run_seconds(&sys, 1.0);
    system_deliver_item(&sys, "CaptureGo", "command", target, NULL); run_seconds(&sys, 1.0);   /* capture schedules the inspector task and starts sequence 3 */
    hal_timer_advance(argent_s_to_us(600.0)); run_seconds(&sys, 1.0);
    CHECK(in_state(&sys, SM_INSPECTOR_HANDLER, "checkout"));
    pass_hours(&sys, 12.0);   /* the sequence's InspectorReleaseGo after the 4 h checkout */
    CHECK(in_state(&sys, SM_INSPECTOR_HANDLER, "released") && sys.app.checked_out);
    pass_hours(&sys, 1.0);
    CHECK(in_state(&sys, SM_INSPECTOR_HANDLER, "relayingImagery"));
    CHECK(sys.app.inspector_pass_duration_us == argent_s_to_us(8.0 * 3600.0));   /* the sequence's step carries the campaign's 8 h */
    pass_hours(&sys, 7.9);
    CHECK(in_state(&sys, SM_INSPECTOR_HANDLER, "relayingImagery"));
    pass_hours(&sys, 0.2);
    CHECK(in_state(&sys, SM_INSPECTOR_HANDLER, "released"));
    system_deliver_item(&sys, "InspectorImagingGo", "command", pass, NULL);
    run_seconds(&sys, 1.0);
    CHECK(in_state(&sys, SM_INSPECTOR_HANDLER, "relayingImagery"));
    pass_hours(&sys, 3.9);
    CHECK(in_state(&sys, SM_INSPECTOR_HANDLER, "relayingImagery"));
    pass_hours(&sys, 0.2);
    CHECK(in_state(&sys, SM_INSPECTOR_HANDLER, "released"));
    CHECK(sys.app.imaging_campaigns == 2u);
}

static void test_deterministic(void)
{
    static argent_system_t sys;
    static char ja[4096], jb[4096];
    uint64_t packets[2], events[2];
    for (unsigned r = 0; r < 2; r++) {   /* the host HAL clock is a process singleton, so the runs are sequential */
        system_init(&sys, NULL);
        for (unsigned f = 0; f < 8u * 20u; f++) {
            if (f == 40) system_deliver_item(&sys, "SeparationConfirmed", "command", NULL, NULL);
            system_run_minor_frame(&sys);
        }
        system_machines_json(&sys, r == 0 ? ja : jb, sizeof ja);
        packets[r] = sys.telemetry.packets; events[r] = sys.events.raised;
        CHECK(system_now(&sys) == 8u * 20u * ARGENT_MINOR_FRAME_US);
    }
    CHECK_EQ_STR(ja, jb);
    CHECK(packets[0] == packets[1] && events[0] == events[1]);
    CHECK(strstr(ja, "SepStringController") != NULL);
}

const test_case_t system_tests[] = {
    { "system: twelve machines in table order, every guard/effect/entry/exit id bound", "TF-019", test_machine_order_and_binding },
    { "system: every generated state and transition reachable", "model 65 state machines", test_every_state_and_transition_reachable },
    { "system: the six on-board sequences execute as data", "model 65 sequencing engine", test_sequences_run_as_data },
    { "system: a far-field RangeUpdate keeps the SEP controller thrusting; the rendezvous one stops it", "model 60/65 rendezvousRange gate", test_far_field_range_update_keeps_thrusting },
    { "system: the disposal burn leaves the SEP controller off after disposalBurnDuration", "model 60/65 disposal burn", test_disposal_burn_ends_off },
    { "system: a flameout during the disposal burn restarts into a bounded burn that still ends off", "model 65 restartingDisposal", test_disposal_burn_flameout_restarts_bounded },
    { "system: the inspector handler relays for the pass each InspectorImagingGo carries", "model 65 passDuration", test_inspector_relays_the_requested_pass },
    { "system: two systems with the same stimulus produce the same trace state", "TF-021 determinism", test_deterministic },
};
const unsigned system_test_count = sizeof system_tests / sizeof system_tests[0];
