#include "tests/runner.h"
#include "sm/sm_runner.h"

static const argent_state_machine_t *machine(const char *name)
{
    for (unsigned i = 0; i < ARGENT_STATE_MACHINE_COUNT; i++)
        if (strcmp(argent_state_machines[i].name, name) == 0) return &argent_state_machines[i];
    return NULL;
}

typedef struct { bool fired; bool captured; int flameout_retries; } ctx_t;

static bool g_fired(sm_instance_t *sm, const sm_event_t *ev) { (void)ev; return ((ctx_t *)sm->ctx)->fired; }
static bool g_not_fired(sm_instance_t *sm, const sm_event_t *ev) { (void)ev; return !((ctx_t *)sm->ctx)->fired; }
static void e_noop(sm_instance_t *sm, const sm_event_t *ev) { (void)sm; (void)ev; }
static void a_cinch(sm_instance_t *sm, int16_t s) { (void)s; ctx_t *c = sm->ctx; c->fired = sm->ctx != NULL && c->captured; }
static bool dur(sm_instance_t *sm, const char *sym, argent_us_t *out)
{
    (void)sm;
    if (strcmp(sym, "despinDuration") == 0) { *out = argent_s_to_us(2.0 * 3600.0); return true; }
    if (strcmp(sym, "limits.commandLossTimeout") == 0) { *out = argent_s_to_us(7.0 * 86400.0); return true; }
    if (strcmp(sym, "limits.thrusterRestartDelay") == 0) { *out = argent_s_to_us(2.0 * 3600.0); return true; }
    if (strcmp(sym, "arraysDeploymentTimeout") == 0) { *out = argent_s_to_us(2.0 * 3600.0); return true; }
    if (strcmp(sym, "disposalBurnDuration") == 0) { *out = argent_s_to_us(30.0 * 86400.0); return true; }
    if (strcmp(sym, "restartDelay") == 0) { *out = argent_s_to_us(2.0 * 3600.0); return true; }
    if (strcmp(sym, "passDuration") == 0) { *out = argent_s_to_us(8.0 * 3600.0); return true; }
    if (strcmp(sym, "checkoutDuration") == 0) { *out = argent_s_to_us(4.0 * 3600.0); return true; }
    if (strcmp(sym, "heartbeatTimeout") == 0) { *out = argent_s_to_us(60.0); return true; }
    if (strcmp(sym, "switchoverDuration") == 0) { *out = argent_s_to_us(30.0); return true; }
    if (strcmp(sym, "bootTimeout") == 0) { *out = argent_s_to_us(120.0); return true; }
    return false;
}

static void bind_all_noop(sm_instance_t *sm)
{
    const argent_state_machine_t *d = sm->def;
    for (uint16_t i = 0; i < d->guard_count; i++) if (d->guards[i].id && !sm->guards[i]) sm_register_guard(sm, d->guards[i].id, g_not_fired);
    for (uint16_t i = 0; i < d->effect_count; i++) if (d->effects[i].id && !sm->effects[i]) sm_register_effect(sm, d->effects[i].id, e_noop);
    for (uint16_t i = 0; i < d->state_count; i++) {
        if (d->states[i].entry_action[0] && !sm->entry[i]) sm_register_entry(sm, d->states[i].qualified_name, a_cinch);
        if (d->states[i].exit_action[0] && !sm->exit[i]) sm_register_exit(sm, d->states[i].qualified_name, a_cinch);
    }
    sm_set_duration_resolver(sm, dur);
}

static void send(sm_instance_t *sm, const char *name, double t_s)
{
    sm_event_t ev = { name, "command", { 0, 0, 0, 0 }, NULL };
    sm_tick(sm, argent_s_to_us(t_s));
    sm_dispatch(sm, &ev, argent_s_to_us(t_s));
}

static void test_capture_nominal(void)
{
    sm_instance_t sm; ctx_t c = { false, true, 0 }; char buf[SM_CONFIG_LEN]; const char *missing;
    CHECK(sm_init(&sm, machine("CaptureController"), &c));
    sm_register_guard(&sm, "CAPTURE_CONTROLLER_G1", g_fired);
    sm_register_guard(&sm, "CAPTURE_CONTROLLER_G2", g_not_fired);
    bind_all_noop(&sm);
    CHECK(sm_fully_bound(&sm, &missing));
    sm_start(&sm, 0);
    sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "characterising");
    send(&sm, "CaptureArm", 60); sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "armed");
    send(&sm, "GroundEnable", 120); sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "armed");
    send(&sm, "CaptureGo", 180); sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "committed");
    send(&sm, "ContactDetected", 3780); sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "despinning");
    sm_tick(&sm, argent_s_to_us(3780 + 7200)); sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "captured");
    CHECK(sm.fault == 0);
}

static void test_capture_inhibited(void)
{
    sm_instance_t sm; ctx_t c = { false, false, 0 }; char buf[SM_CONFIG_LEN];
    sm_init(&sm, machine("CaptureController"), &c);
    sm_register_guard(&sm, "CAPTURE_CONTROLLER_G1", g_fired);
    sm_register_guard(&sm, "CAPTURE_CONTROLLER_G2", g_not_fired);
    bind_all_noop(&sm);
    sm_start(&sm, 0);
    send(&sm, "CaptureArm", 60);
    send(&sm, "ContactDetected", 120);
    sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "inhibited");
    sm_tick(&sm, argent_s_to_us(20000)); sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "inhibited");
}

static void test_tug_modes_early_ops(void)
{
    sm_instance_t sm; ctx_t c = { false, false, 0 }; char buf[SM_CONFIG_LEN]; const char *missing;
    sm_init(&sm, machine("TugModes"), &c);
    bind_all_noop(&sm);
    CHECK(sm_fully_bound(&sm, &missing));
    sm_start(&sm, 0);
    sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "onLauncher | off | lowGain | thrusters | stowed");
    send(&sm, "SeparationConfirmed", 4320);
    sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "deploying | off | lowGain | thrusters | stowed");
    send(&sm, "ArraysDeployed", 8640);
    sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "coast | standby | highGain | wheels | stowed");
    sm_tick(&sm, argent_s_to_us(17280));
    sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "coast | standby | highGain | wheels | stowed");
    {
        sm_event_t ev = { "SafeModeRequest", NULL, { 0, 0, 0, 0 }, "command-loss timer expired" };
        sm_dispatch(&sm, &ev, argent_s_to_us(604800));
    }
    sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "safe | off | lowGain | thrusters | stowed");
    send(&sm, "SafeModeExit", 700000);
    sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "coast | standby | highGain | wheels | stowed");
    CHECK(sm.fault == 0);
}

static void test_fdir_supervisor(void)
{
    sm_instance_t sm; ctx_t c = { false, false, 0 }; char buf[SM_CONFIG_LEN];
    sm_init(&sm, machine("FdirSupervisor"), &c);
    bind_all_noop(&sm);
    sm_start(&sm, 0);
    sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "armed | nominal | nominal | nominal | nominal | monitoring");
    send(&sm, "GroundContact", 86400);
    sm_tick(&sm, argent_s_to_us(86400 + 604800 - 1)); sm_config(&sm, buf, sizeof buf);
    CHECK_EQ_STR(buf, "armed | nominal | nominal | nominal | nominal | monitoring");
    sm_tick(&sm, argent_s_to_us(86400 + 604800)); sm_config(&sm, buf, sizeof buf);
    CHECK_EQ_STR(buf, "expired | nominal | nominal | nominal | nominal | monitoring");
    send(&sm, "GroundContact", 800000); sm_config(&sm, buf, sizeof buf);
    CHECK_EQ_STR(buf, "armed | nominal | nominal | nominal | nominal | monitoring");
    CHECK(sm_next_deadline(&sm) == argent_s_to_us(800000 + 604800));
}

static void test_every_machine_starts(void)
{
    for (unsigned i = 0; i < ARGENT_STATE_MACHINE_COUNT; i++) {
        sm_instance_t sm; ctx_t c = { false, false, 0 }; char buf[SM_CONFIG_LEN]; const char *missing;
        CHECK(sm_init(&sm, &argent_state_machines[i], &c));
        bind_all_noop(&sm);
        CHECK(sm_fully_bound(&sm, &missing));
        sm_start(&sm, 0);
        sm_config(&sm, buf, sizeof buf);
        CHECK(buf[0] != '\0');
        CHECK(sm.fault == 0);
    }
}

static void test_held_items(void)
{
    /* SysML v2 7.17.8/7.18.3: an item no active state takes stays in flight until one does; an
     * item no row of the machine names is discarded. */
    sm_instance_t sm; ctx_t c = { false, false, 0 }; char buf[SM_CONFIG_LEN]; const char *missing;
    CHECK(sm_init(&sm, machine("SepStringController"), &c));
    bind_all_noop(&sm);
    CHECK(sm_fully_bound(&sm, &missing));
    sm_start(&sm, 0);
    sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "off");
    send(&sm, "SepThrust", 10);
    sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "off");
    CHECK(sm.held_count == 1 && sm.events_held == 1 && sm.events_ignored == 0);
    send(&sm, "CaptureGo", 11);
    CHECK(sm.held_count == 1 && sm.events_ignored == 1);
    send(&sm, "SepStandby", 20);
    sm_config(&sm, buf, sizeof buf); CHECK_EQ_STR(buf, "thrusting");
    CHECK(sm.held_count == 0 && sm.events_consumed == 2 && sm.transitions_taken == 2);
}

const test_case_t sm_tests[] = {
    { "sm: capture controller nominal reaches captured", "runs/sw-capture-controller.txt", test_capture_nominal },
    { "sm: capture controller premature contact stays inhibited", "runs/sw-capture-controller-inhibited.txt", test_capture_inhibited },
    { "sm: TugModes early operations and safe mode", "runs/sw-mode-manager-early-ops.txt", test_tug_modes_early_ops },
    { "sm: FdirSupervisor command-loss timer", "runs/sw-fdir-command-loss-expired.txt", test_fdir_supervisor },
    { "sm: every generated machine starts", "TF-019", test_every_machine_starts },
    { "sm: an item no active state takes stays in flight until one does", "F-SW1301", test_held_items },
};
const unsigned sm_test_count = sizeof sm_tests / sizeof sm_tests[0];
