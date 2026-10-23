/* The generic table-driven state-machine runner: one implementation for all twelve generated
 * machines of argent_state_machines.h (hierarchy, initial substates, entry/exit actions,
 * completion transitions to ARGENT_STATE_DONE, timed transitions, parallel regions). */
#ifndef ARGENT_SM_RUNNER_H
#define ARGENT_SM_RUNNER_H
#include <stdbool.h>
#include <stdint.h>
#include "argent_state_machines.h"
#include "exec/argent_time.h"

#define SM_MAX_STATES 64u
#define SM_MAX_TRANSITIONS 64u
#define SM_MAX_EXPRESSIONS 16u
#define SM_MAX_EVENT_ARGS 4u
#define SM_CONFIG_LEN 256u
#define SM_MAX_HELD 16u

typedef struct {
    const char *name;                 /* item definition name, e.g. "CaptureGo" */
    const char *port;                 /* "command" or NULL for any port */
    double arg[SM_MAX_EVENT_ARGS];    /* positional payload, documented per event in README */
    const char *text;                 /* string payload (a reason) or NULL */
} sm_event_t;

/* An item the machine may yet take (some row names it) but no active state takes now: it stays
 * in flight (SysML v2 7.17.8/7.18.3: a transfer is accepted when a receiver can take it) and is
 * re-offered, in send order, after every firing. An item no row names is discarded. */
typedef struct {
    char name[48];
    char port[24];
    double arg[SM_MAX_EVENT_ARGS];
    char text[48];
    bool has_port, has_text;
} sm_held_t;

typedef struct sm_instance sm_instance_t;
typedef bool (*sm_guard_fn)(sm_instance_t *sm, const sm_event_t *ev);
typedef void (*sm_effect_fn)(sm_instance_t *sm, const sm_event_t *ev);
typedef void (*sm_action_fn)(sm_instance_t *sm, int16_t state);
typedef bool (*sm_duration_fn)(sm_instance_t *sm, const char *symbol, argent_us_t *out);

struct sm_instance {
    const argent_state_machine_t *def;
    void *ctx;
    argent_us_t now;
    uint64_t active;
    uint64_t completed;               /* composite states whose child reached done */
    uint64_t leaf_pending;            /* leaves entered, completion transitions not yet tried */
    bool machine_done;
    argent_us_t timer_deadline[SM_MAX_TRANSITIONS];
    sm_guard_fn guards[SM_MAX_EXPRESSIONS];
    sm_effect_fn effects[SM_MAX_EXPRESSIONS];
    sm_action_fn entry[SM_MAX_STATES];
    sm_action_fn exit[SM_MAX_STATES];
    sm_duration_fn duration;
    uint32_t transitions_taken;
    uint32_t events_consumed;
    uint32_t events_ignored;
    uint32_t events_held;             /* items parked in flight because no active state took them yet */
    sm_held_t held[SM_MAX_HELD];
    uint8_t held_count;
    uint32_t last_fired;              /* transitions fired by the last dispatch/tick */
    uint8_t state_hits[SM_MAX_STATES];
    uint8_t transition_hits[SM_MAX_TRANSITIONS];
    uint8_t fault;                    /* set on a missing guard/effect/duration at run time */
};

bool sm_init(sm_instance_t *sm, const argent_state_machine_t *def, void *ctx);
bool sm_register_guard(sm_instance_t *sm, const char *id, sm_guard_fn fn);
bool sm_register_effect(sm_instance_t *sm, const char *id, sm_effect_fn fn);
bool sm_register_entry(sm_instance_t *sm, const char *qualified_name, sm_action_fn fn);
bool sm_register_exit(sm_instance_t *sm, const char *qualified_name, sm_action_fn fn);
void sm_set_duration_resolver(sm_instance_t *sm, sm_duration_fn fn);
/* Every guard/effect id of the table has a function and every entry/exit action text has one. */
bool sm_fully_bound(const sm_instance_t *sm, const char **missing);
void sm_start(sm_instance_t *sm, argent_us_t now);
/* Delivers one event to all orthogonal regions; returns the number of transitions fired. An
 * event some row of the machine names but no active state takes is held (SM_MAX_HELD deep) and
 * re-offered after later firings; one no row names is counted in events_ignored. */
uint32_t sm_dispatch(sm_instance_t *sm, const sm_event_t *ev, argent_us_t now);
/* Fires the timed transitions whose deadline has passed; returns the number fired. */
uint32_t sm_tick(sm_instance_t *sm, argent_us_t now);
/* Earliest pending timed deadline, or 0 when none is armed. */
argent_us_t sm_next_deadline(const sm_instance_t *sm);
bool sm_is_active(const sm_instance_t *sm, int16_t state);
/* "coast | standby | highGain | wheels | stowed": the deepest active leaf of each region. */
void sm_config(const sm_instance_t *sm, char *buf, uint32_t len);
int16_t sm_state_index(const argent_state_machine_t *def, const char *name, int16_t parent);
/* Parses "after 8.0 [h]" style literals; symbols go to the duration resolver. */
bool sm_parse_duration(const char *timed, double *seconds);

#endif
