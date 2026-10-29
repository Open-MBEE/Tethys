/* Executive: task binding, firing frames, WCET accounting, overrun detection, pools closed after init. */
#include "tests/runner.h"
#include "apps/system.h"

static unsigned popcount8(uint8_t v) { unsigned n = 0; while (v) { n += v & 1u; v >>= 1; } return n; }

static void test_tasks_bound_and_fired(void)
{
    static argent_system_t sys;
    const char *missing = NULL;
    system_init(&sys, NULL);
    CHECK(sys.exec.task_count == ARGENT_SCHEDULED_TASK_COUNT);
    CHECK(exec_all_tasks_bound(&sys.exec, &missing));
    if (missing) printf("  unbound task %s\n", missing);
    sys.exec.mode = ARGENT_TUG_MODE_COAST;
    uint64_t before[EXEC_MAX_TASKS];
    for (unsigned t = 0; t < sys.exec.task_count; t++) before[t] = sys.exec.tasks[t].firings;
    for (unsigned f = 0; f < ARGENT_MINOR_FRAMES; f++) exec_run_minor_frame(&sys.exec);
    for (unsigned t = 0; t < sys.exec.task_count; t++) {
        const exec_task_t *task = &sys.exec.tasks[t];
        unsigned expected = (task->def->active_modes & (argent_mode_mask_t)(1u << ARGENT_TUG_MODE_COAST)) ? popcount8(task->def->firing_frames) : 0;
        CHECK(task->firings - before[t] == expected);
        CHECK(task->wcet_us == argent_s_to_us(task->def->wcet_s));
        CHECK(task->modelled_cost_us == task->wcet_us);
    }
    CHECK(sys.exec.task_overruns == 0 && sys.exec.frame_overruns == 0);
}

static void test_overrun_detected(void)
{
    static argent_system_t sys;
    system_init(&sys, NULL);
    sys.exec.mode = ARGENT_TUG_MODE_COAST;
    const exec_task_t *task = exec_task(&sys.exec, argent_scheduled_tasks[0].name);
    CHECK(task != NULL);
    exec_set_task_cost(&sys.exec, argent_scheduled_tasks[0].name, task->wcet_us + 1u);
    for (unsigned f = 0; f < ARGENT_MINOR_FRAMES; f++) exec_run_minor_frame(&sys.exec);
    CHECK(sys.exec.task_overruns > 0);
    CHECK(task->host_ns_total > 0 || task->firings == 0);   /* host time is recorded, never used as WCET */
}

static void test_pools_closed_after_init(void)
{
    static argent_system_t sys;
    system_init(&sys, NULL);
    CHECK(sys.exec.initialised);
    CHECK(sys.exec.pool_count == ARGENT_PARTITION_COUNT);
    CHECK(exec_pool_alloc(&sys.exec, argent_partitions[0].name, 16) == NULL);
    for (unsigned p = 0; p < sys.exec.pool_count; p++) {
        CHECK_EQ_STR(sys.exec.pools[p].def->name, argent_partitions[p].name);
        CHECK(sys.exec.pools[p].used_bytes <= EXEC_POOL_HOST_BYTES);
        CHECK(exec_partition_window_us(&sys.exec, (uint8_t)p) > 0);
    }
}

const test_case_t exec_tests[] = {
    { "exec: all 22 tasks bound; each fires on its frames in its modes with the model WCET", "model 66 task table", test_tasks_bound_and_fired },
    { "exec: a task costing more than its WCET is an overrun", "TF-004", test_overrun_detected },
    { "exec: five partition pools, no allocation after initialisation", "SW-012 partitioning", test_pools_closed_after_init },
};
const unsigned exec_test_count = sizeof exec_tests / sizeof exec_tests[0];
