#include "exec/executive.h"
#include "hal/hal.h"
#include <string.h>

void exec_init(executive_t *ex)
{
    memset(ex, 0, sizeof(*ex));
    for (uint16_t i = 0; i < ARGENT_PARTITION_COUNT && i < EXEC_MAX_PARTITIONS; i++) {
        ex->pools[i].def = &argent_partitions[i];
        ex->pools[i].budget_bytes = (uint64_t)argent_partitions[i].memory_bytes;
        ex->pool_count++;
    }
    for (uint16_t p = 0; p < ARGENT_PARTITION_SCHEDULE_COUNT; p++) {
        const argent_partition_schedule_t *ps = &argent_partition_schedules[p];
        for (uint16_t t = 0; t < ps->task_count && ex->task_count < EXEC_MAX_TASKS; t++) {
            exec_task_t *task = &ex->tasks[ex->task_count++];
            task->def = &argent_scheduled_tasks[ps->first_task + t];
            task->partition = (uint8_t)ps->partition;
            task->wcet_us = argent_s_to_us(task->def->wcet_s);
            task->modelled_cost_us = task->wcet_us;
        }
    }
}

static exec_task_t *find_task(executive_t *ex, const char *name)
{
    for (uint32_t i = 0; i < ex->task_count; i++)
        if (strcmp(ex->tasks[i].def->name, name) == 0) return &ex->tasks[i];
    return NULL;
}

bool exec_bind_task(executive_t *ex, const char *task_name, exec_task_fn fn, void *ctx)
{
    exec_task_t *t = find_task(ex, task_name);
    if (t == NULL || ex->initialised) return false;
    t->fn = fn;
    t->ctx = ctx;
    return true;
}

bool exec_all_tasks_bound(const executive_t *ex, const char **missing)
{
    for (uint32_t i = 0; i < ex->task_count; i++)
        if (ex->tasks[i].fn == NULL) { *missing = ex->tasks[i].def->name; return false; }
    *missing = NULL;
    return true;
}

void *exec_pool_alloc(executive_t *ex, const char *partition_name, uint32_t bytes)
{
    if (ex->initialised) return NULL;
    for (uint32_t i = 0; i < ex->pool_count; i++) {
        exec_pool_t *pool = &ex->pools[i];
        uint32_t aligned = (bytes + 15u) & ~15u;
        if (strcmp(pool->def->name, partition_name) != 0) continue;
        if (pool->used_bytes + aligned > EXEC_POOL_HOST_BYTES || pool->used_bytes + aligned > pool->budget_bytes) return NULL;
        pool->used_bytes += aligned;
        return &pool->backing[pool->used_bytes - aligned];
    }
    return NULL;
}

void exec_init_complete(executive_t *ex) { ex->initialised = true; }

void exec_set_task_cost(executive_t *ex, const char *task_name, argent_us_t cost_us)
{
    exec_task_t *t = find_task(ex, task_name);
    if (t != NULL) t->modelled_cost_us = cost_us;
}

const exec_task_t *exec_task(const executive_t *ex, const char *task_name)
{
    for (uint32_t i = 0; i < ex->task_count; i++)
        if (strcmp(ex->tasks[i].def->name, task_name) == 0) return &ex->tasks[i];
    return NULL;
}

argent_us_t exec_partition_window_us(const executive_t *ex, uint8_t partition)
{
    (void)ex;
    for (uint16_t p = 0; p < ARGENT_PARTITION_SCHEDULE_COUNT; p++) {
        const argent_partition_schedule_t *ps = &argent_partition_schedules[p];
        argent_us_t total = 0;
        if (ps->partition != partition) continue;
        for (uint16_t s = 0; s < ps->slice_count; s++) total += argent_s_to_us(argent_frame_slices[ps->first_slice + s].duration_s);
        return total;
    }
    return 0;
}

void exec_run_minor_frame(executive_t *ex)
{
    uint32_t minor = ex->minor_frame;
    ex->frame_budget_used_us = 0;
    ex->tasks_fired_this_frame = 0;
    hal_watchdog_kick(hal_timer_now());
    for (uint16_t p = 0; p < ARGENT_PARTITION_SCHEDULE_COUNT; p++) {
        const argent_partition_schedule_t *ps = &argent_partition_schedules[p];
        argent_us_t window_used = 0;
        for (uint32_t i = 0; i < ex->task_count; i++) {
            exec_task_t *t = &ex->tasks[i];
            uint64_t start;
            if (t->partition != ps->partition) continue;
            if (((t->def->firing_frames >> minor) & 1u) == 0) continue;
            if (((t->def->active_modes >> ex->mode) & 1u) == 0) continue;
            start = hal_host_nanoseconds();
            if (t->fn != NULL) t->fn(t->ctx, minor);
            {
                uint64_t ns = hal_host_nanoseconds() - start;
                t->host_ns_total += ns;
                if (ns > t->host_ns_max) t->host_ns_max = ns;
            }
            t->firings++;
            if (t->modelled_cost_us > t->wcet_us) { t->overruns++; ex->task_overruns++; }
            window_used += t->modelled_cost_us;
            ex->frame_budget_used_us += t->modelled_cost_us;
            ex->tasks_fired_this_frame++;
        }
        /* Partition windows are fixed slices of the minor frame; the model's slice table bounds them. */
        if (window_used > exec_partition_window_us(ex, (uint8_t)ps->partition)) ex->partition_window_overruns++;
    }
    if (ex->frame_budget_used_us > ARGENT_MINOR_FRAME_US) ex->frame_overruns++;
    ex->frame_index++;
    ex->minor_frame = (minor + 1u) % ARGENT_MINOR_FRAMES;
    hal_timer_advance(ARGENT_MINOR_FRAME_US);
}
