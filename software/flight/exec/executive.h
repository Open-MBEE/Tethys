/* The Kestrel time/space-partitioned cyclic executive: partitions, rate groups and tasks from
 * argent_schedule.h, a major frame of ARGENT_MINOR_FRAMES minor frames, WCET budget accounting per
 * task and per frame (model budgets; host time is measured separately and never schedules). */
#ifndef ARGENT_EXECUTIVE_H
#define ARGENT_EXECUTIVE_H
#include <stdbool.h>
#include <stdint.h>
#include "argent_schedule.h"
#include "exec/argent_time.h"

#define EXEC_MAX_TASKS 32u
#define EXEC_MAX_PARTITIONS 8u
#define EXEC_POOL_HOST_BYTES (256u * 1024u)

typedef void (*exec_task_fn)(void *ctx, uint32_t minor_frame);

typedef struct {
    const argent_partition_t *def;
    uint64_t budget_bytes;           /* the model's memoryBudget, reported not resized */
    uint32_t used_bytes;             /* host backing actually handed out at initialisation */
    uint8_t backing[EXEC_POOL_HOST_BYTES];
} exec_pool_t;

typedef struct {
    const argent_scheduled_task_t *def;
    exec_task_fn fn;
    void *ctx;
    uint8_t partition;
    argent_us_t wcet_us;             /* model WCET budget */
    argent_us_t modelled_cost_us;    /* cost charged per firing (defaults to the WCET budget) */
    uint64_t firings;
    uint64_t host_ns_total;          /* host-measured, informational */
    uint64_t host_ns_max;
    uint32_t overruns;
} exec_task_t;

typedef struct {
    exec_task_t tasks[EXEC_MAX_TASKS];
    uint32_t task_count;
    exec_pool_t pools[EXEC_MAX_PARTITIONS];
    uint32_t pool_count;
    bool initialised;                /* after this no pool allocation is accepted */
    uint64_t frame_index;            /* minor frames executed since start */
    uint32_t minor_frame;            /* 0..7 within the major frame */
    uint16_t mode;                   /* current TugMode row, set by the mode manager */
    argent_us_t frame_budget_used_us;/* sum of modelled task costs charged in this minor frame */
    uint32_t frame_overruns;         /* minor frames whose charged cost exceeded the period */
    uint32_t task_overruns;
    uint32_t tasks_fired_this_frame;
    uint32_t partition_window_overruns;
} executive_t;

void exec_init(executive_t *ex);
bool exec_bind_task(executive_t *ex, const char *task_name, exec_task_fn fn, void *ctx);
bool exec_all_tasks_bound(const executive_t *ex, const char **missing);
void *exec_pool_alloc(executive_t *ex, const char *partition_name, uint32_t bytes);
void exec_init_complete(executive_t *ex);
/* Runs one minor frame: fires every bound task of every partition slice due in this frame. */
void exec_run_minor_frame(executive_t *ex);
void exec_set_task_cost(executive_t *ex, const char *task_name, argent_us_t cost_us);
const exec_task_t *exec_task(const executive_t *ex, const char *task_name);
/* Partition window in microseconds: share of the minor frame per the model's slice table. */
argent_us_t exec_partition_window_us(const executive_t *ex, uint8_t partition);

#endif
