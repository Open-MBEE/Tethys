#include "sm/sm_runner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BIT(i) ((uint64_t)1u << (unsigned)(i))

static bool parallel(const sm_instance_t *sm) { return sm->def->initial_state == ARGENT_STATE_NONE; }

static int16_t region_of(const sm_instance_t *sm, int16_t s)
{
    /* The top-level ancestor; a non-parallel machine is one region (ARGENT_STATE_NONE). */
    if (!parallel(sm)) return ARGENT_STATE_NONE;
    for (unsigned depth = 0; depth < SM_MAX_STATES && sm->def->states[s].parent != ARGENT_STATE_NONE; depth++)
        s = sm->def->states[s].parent;
    return s;
}

static unsigned depth_of(const sm_instance_t *sm, int16_t s)
{
    unsigned d = 0;
    while (s != ARGENT_STATE_NONE && d < SM_MAX_STATES) { s = sm->def->states[s].parent; d++; }
    return d;
}

static bool is_self_or_descendant(const sm_instance_t *sm, int16_t s, int16_t ancestor)
{
    for (unsigned d = 0; s != ARGENT_STATE_NONE && d < SM_MAX_STATES; d++) {
        if (s == ancestor) return true;
        s = sm->def->states[s].parent;
    }
    return false;
}

static bool expression_index(const argent_named_expression_t *table, uint16_t count, const char *id, int16_t *out)
{
    for (uint16_t i = 0; i < count; i++) {
        if (table[i].id != NULL && strcmp(table[i].id, id) == 0) { *out = (int16_t)i; return true; }
    }
    return false;
}

bool sm_init(sm_instance_t *sm, const argent_state_machine_t *def, void *ctx)
{
    memset(sm, 0, sizeof(*sm));
    if (def->state_count > SM_MAX_STATES || def->transition_count > SM_MAX_TRANSITIONS
        || def->guard_count > SM_MAX_EXPRESSIONS || def->effect_count > SM_MAX_EXPRESSIONS) return false;
    sm->def = def;
    sm->ctx = ctx;
    return true;
}

bool sm_register_guard(sm_instance_t *sm, const char *id, sm_guard_fn fn)
{
    int16_t i;
    if (!expression_index(sm->def->guards, sm->def->guard_count, id, &i)) return false;
    sm->guards[i] = fn;
    return true;
}

bool sm_register_effect(sm_instance_t *sm, const char *id, sm_effect_fn fn)
{
    int16_t i;
    if (!expression_index(sm->def->effects, sm->def->effect_count, id, &i)) return false;
    sm->effects[i] = fn;
    return true;
}

int16_t sm_state_index(const argent_state_machine_t *def, const char *name, int16_t parent)
{
    for (uint16_t i = 0; i < def->state_count; i++) {
        if (strcmp(def->states[i].name, name) == 0 && (parent == ARGENT_STATE_NONE || def->states[i].parent == parent))
            return (int16_t)i;
    }
    return ARGENT_STATE_NONE;
}

static int16_t qualified_index(const argent_state_machine_t *def, const char *qualified)
{
    for (uint16_t i = 0; i < def->state_count; i++)
        if (strcmp(def->states[i].qualified_name, qualified) == 0) return (int16_t)i;
    return ARGENT_STATE_NONE;
}

bool sm_register_entry(sm_instance_t *sm, const char *qualified_name, sm_action_fn fn)
{
    int16_t i = qualified_index(sm->def, qualified_name);
    if (i < 0) return false;
    sm->entry[i] = fn;
    return true;
}

bool sm_register_exit(sm_instance_t *sm, const char *qualified_name, sm_action_fn fn)
{
    int16_t i = qualified_index(sm->def, qualified_name);
    if (i < 0) return false;
    sm->exit[i] = fn;
    return true;
}

void sm_set_duration_resolver(sm_instance_t *sm, sm_duration_fn fn) { sm->duration = fn; }

bool sm_fully_bound(const sm_instance_t *sm, const char **missing)
{
    const argent_state_machine_t *d = sm->def;
    for (uint16_t i = 0; i < d->guard_count; i++)
        if (d->guards[i].id != NULL && sm->guards[i] == NULL) { *missing = d->guards[i].id; return false; }
    for (uint16_t i = 0; i < d->effect_count; i++)
        if (d->effects[i].id != NULL && sm->effects[i] == NULL) { *missing = d->effects[i].id; return false; }
    for (uint16_t i = 0; i < d->state_count; i++) {
        if (d->states[i].entry_action[0] != '\0' && sm->entry[i] == NULL) { *missing = d->states[i].qualified_name; return false; }
        if (d->states[i].exit_action[0] != '\0' && sm->exit[i] == NULL) { *missing = d->states[i].qualified_name; return false; }
    }
    for (uint16_t i = 0; i < d->transition_count; i++) {
        const argent_transition_t *t = &d->transitions[i];
        double seconds;
        if (t->trigger_kind == ARGENT_TRIGGER_TIMED && !sm_parse_duration(t->timed, &seconds) && sm->duration == NULL) {
            *missing = t->timed;
            return false;
        }
    }
    *missing = NULL;
    return true;
}

bool sm_parse_duration(const char *timed, double *seconds)
{
    const char *p = timed;
    char *end;
    double value;
    if (strncmp(p, "after ", 6) != 0) return false;
    p += 6;
    value = strtod(p, &end);
    if (end == p) return false;
    while (*end == ' ') end++;
    if (strncmp(end, "[s]", 3) == 0) { *seconds = value; return true; }
    if (strncmp(end, "[min]", 5) == 0) { *seconds = value * 60.0; return true; }
    if (strncmp(end, "[h]", 3) == 0) { *seconds = value * 3600.0; return true; }
    if (strncmp(end, "[d]", 3) == 0) { *seconds = value * 86400.0; return true; }
    if (*end == '\0') { *seconds = value; return true; }
    return false;
}

static argent_us_t resolve_duration(sm_instance_t *sm, const char *timed)
{
    double seconds;
    argent_us_t us = 0;
    if (sm_parse_duration(timed, &seconds)) return argent_s_to_us(seconds);
    if (sm->duration != NULL && sm->duration(sm, timed + (strncmp(timed, "after ", 6) == 0 ? 6 : 0), &us)) return us;
    sm->fault = 1;
    return 0;
}

static void arm_timers(sm_instance_t *sm, int16_t state)
{
    for (uint16_t i = 0; i < sm->def->transition_count; i++) {
        const argent_transition_t *t = &sm->def->transitions[i];
        if (t->source == state && t->trigger_kind == ARGENT_TRIGGER_TIMED)
            sm->timer_deadline[i] = sm->now + resolve_duration(sm, t->timed);
    }
}

static void disarm_timers(sm_instance_t *sm, int16_t state)
{
    for (uint16_t i = 0; i < sm->def->transition_count; i++)
        if (sm->def->transitions[i].source == state) sm->timer_deadline[i] = 0;
}

static void enter_chain(sm_instance_t *sm, int16_t state)
{
    /* Enters a state and then its initial substates down to a leaf, without recursion. */
    for (unsigned d = 0; state != ARGENT_STATE_NONE && d < SM_MAX_STATES; d++) {
        const argent_state_t *s = &sm->def->states[state];
        sm->active |= BIT(state);
        sm->completed &= ~BIT(state);
        if (sm->state_hits[state] < 255u) sm->state_hits[state]++;
        if (sm->entry[state] != NULL) sm->entry[state](sm, state);
        arm_timers(sm, state);
        if (s->leaf) sm->leaf_pending |= BIT(state);
        state = s->initial_substate;
    }
}

static void exit_subtree(sm_instance_t *sm, int16_t root)
{
    /* Deepest states first: reverse table order keeps children after parents in the tables. */
    for (int i = (int)sm->def->state_count - 1; i >= 0; i--) {
        if ((sm->active & BIT(i)) != 0 && is_self_or_descendant(sm, (int16_t)i, root)) {
            if (sm->exit[i] != NULL) sm->exit[i](sm, (int16_t)i);
            sm->active &= ~BIT(i);
            sm->leaf_pending &= ~BIT(i);
            sm->completed &= ~BIT(i);
            disarm_timers(sm, (int16_t)i);
        }
    }
}

static int16_t lca_child_on_source_side(const sm_instance_t *sm, int16_t source, int16_t target)
{
    /* The ancestor-or-self of source that is a sibling of target's chain: what must be exited. */
    int16_t s = source;
    for (unsigned d = 0; d < SM_MAX_STATES; d++) {
        int16_t p = sm->def->states[s].parent;
        if (is_self_or_descendant(sm, target, s) && s != source) return ARGENT_STATE_NONE;
        if (p == ARGENT_STATE_NONE || is_self_or_descendant(sm, target, p)) return s;
        s = p;
    }
    return source;
}

static bool guard_ok(sm_instance_t *sm, const argent_transition_t *t, const sm_event_t *ev)
{
    if (t->guard < 0) return true;
    if (sm->guards[t->guard] == NULL) { sm->fault = 1; return false; }
    return sm->guards[t->guard](sm, ev);
}

static void fire(sm_instance_t *sm, uint16_t index, const sm_event_t *ev)
{
    const argent_transition_t *t = &sm->def->transitions[index];
    int16_t source = t->source;
    if (sm->transition_hits[index] < 255u) sm->transition_hits[index]++;
    sm->transitions_taken++;
    sm->last_fired++;
    if (t->target == ARGENT_STATE_DONE) {
        int16_t parent = sm->def->states[source].parent;
        exit_subtree(sm, source);
        if (t->effect >= 0 && sm->effects[t->effect] != NULL) sm->effects[t->effect](sm, ev);
        else if (t->effect >= 0) sm->fault = 1;
        if (parent == ARGENT_STATE_NONE) sm->machine_done = true;
        else sm->completed |= BIT(parent);
        return;
    }
    if (t->target == source) {
        exit_subtree(sm, source);
    } else {
        int16_t to_exit = lca_child_on_source_side(sm, source, t->target);
        if (to_exit != ARGENT_STATE_NONE) exit_subtree(sm, to_exit);
    }
    if (t->effect >= 0 && sm->effects[t->effect] != NULL) sm->effects[t->effect](sm, ev);
    else if (t->effect >= 0) sm->fault = 1;
    /* Entering a target whose ancestors are not yet active activates them top-down first. */
    {
        int16_t chain[SM_MAX_STATES];
        unsigned n = 0;
        int16_t s = t->target;
        while (s != ARGENT_STATE_NONE && (sm->active & BIT(s)) == 0 && n < SM_MAX_STATES) { chain[n++] = s; s = sm->def->states[s].parent; }
        while (n > 1) {
            n--;
            sm->active |= BIT(chain[n]);
            sm->completed &= ~BIT(chain[n]);
            if (sm->state_hits[chain[n]] < 255u) sm->state_hits[chain[n]]++;
            if (sm->entry[chain[n]] != NULL) sm->entry[chain[n]](sm, chain[n]);
            arm_timers(sm, chain[n]);
        }
    }
    enter_chain(sm, t->target);
}

static void run_completions(sm_instance_t *sm)
{
    /* Run-to-completion: completion transitions of finished composites and freshly entered leaves. */
    for (unsigned rounds = 0; rounds < 2u * SM_MAX_STATES; rounds++) {
        bool fired = false;
        for (uint16_t i = 0; i < sm->def->transition_count && !fired; i++) {
            const argent_transition_t *t = &sm->def->transitions[i];
            if (t->trigger_kind != ARGENT_TRIGGER_NONE || (sm->active & BIT(t->source)) == 0) continue;
            if ((sm->completed & BIT(t->source)) == 0 && (sm->leaf_pending & BIT(t->source)) == 0) continue;
            if (!guard_ok(sm, t, NULL)) continue;
            fire(sm, i, NULL);
            fired = true;
        }
        if (!fired) break;
    }
    sm->leaf_pending = 0;
}

void sm_start(sm_instance_t *sm, argent_us_t now)
{
    sm->now = now;
    sm->last_fired = 0;
    if (parallel(sm)) {
        for (uint16_t i = 0; i < sm->def->state_count; i++)
            if (sm->def->states[i].parent == ARGENT_STATE_NONE) enter_chain(sm, (int16_t)i);
    } else {
        enter_chain(sm, sm->def->initial_state);
    }
    run_completions(sm);
}

static bool event_matches(const argent_transition_t *t, const sm_event_t *ev)
{
    if (t->trigger_kind != ARGENT_TRIGGER_EVENT || strcmp(t->event, ev->name) != 0) return false;
    if (ev->port != NULL && t->port[0] != '\0' && strcmp(t->port, ev->port) != 0) return false;
    return true;
}

static unsigned dispatch_core(sm_instance_t *sm, const sm_event_t *ev)
{
    int16_t chosen[SM_MAX_STATES];
    int16_t chosen_region[SM_MAX_STATES];
    unsigned chosen_count = 0;
    /* Per orthogonal region, the enabled transition with the deepest source wins; ties by table order. */
    for (uint16_t i = 0; i < sm->def->transition_count; i++) {
        const argent_transition_t *t = &sm->def->transitions[i];
        int16_t region;
        unsigned k;
        if (!event_matches(t, ev) || (sm->active & BIT(t->source)) == 0 || !guard_ok(sm, t, ev)) continue;
        region = region_of(sm, t->source);
        for (k = 0; k < chosen_count; k++) if (chosen_region[k] == region) break;
        if (k == chosen_count) { chosen[k] = (int16_t)i; chosen_region[k] = region; chosen_count++; }
        else if (depth_of(sm, t->source) > depth_of(sm, sm->def->transitions[chosen[k]].source)) chosen[k] = (int16_t)i;
    }
    for (unsigned k = 0; k < chosen_count; k++) {
        /* An earlier firing in this dispatch may have left the source; re-check before firing. */
        if ((sm->active & BIT(sm->def->transitions[chosen[k]].source)) != 0) fire(sm, (uint16_t)chosen[k], ev);
    }
    if (chosen_count > 0) run_completions(sm);
    return chosen_count;
}

static bool may_take(const sm_instance_t *sm, const sm_event_t *ev)
{
    /* Some row of the machine, active or not, names this event on a compatible port. */
    for (uint16_t i = 0; i < sm->def->transition_count; i++)
        if (event_matches(&sm->def->transitions[i], ev)) return true;
    return false;
}

static void hold(sm_instance_t *sm, const sm_event_t *ev)
{
    sm_held_t *h;
    if (sm->held_count >= SM_MAX_HELD) { sm->events_ignored++; return; }
    h = &sm->held[sm->held_count++];
    memset(h, 0, sizeof(*h));
    snprintf(h->name, sizeof h->name, "%s", ev->name);
    if (ev->port != NULL) { snprintf(h->port, sizeof h->port, "%s", ev->port); h->has_port = true; }
    if (ev->text != NULL) { snprintf(h->text, sizeof h->text, "%s", ev->text); h->has_text = true; }
    memcpy(h->arg, ev->arg, sizeof h->arg);
    sm->events_held++;
}

static void offer_held(sm_instance_t *sm)
{
    /* After a firing, the oldest held item an active state now takes fires; its firing may enable another. */
    for (unsigned rounds = 0; rounds < SM_MAX_HELD * SM_MAX_HELD && sm->held_count > 0; rounds++) {
        bool fired = false;
        for (uint8_t i = 0; i < sm->held_count && !fired; i++) {
            sm_held_t h = sm->held[i];
            sm_event_t ev = { h.name, h.has_port ? h.port : NULL, { 0, 0, 0, 0 }, h.has_text ? h.text : NULL };
            memcpy(ev.arg, h.arg, sizeof ev.arg);
            if (dispatch_core(sm, &ev) == 0) continue;
            memmove(&sm->held[i], &sm->held[i + 1], (size_t)(sm->held_count - i - 1u) * sizeof(sm_held_t));
            sm->held_count--;
            sm->events_consumed++;
            fired = true;
        }
        if (!fired) break;
    }
}

uint32_t sm_dispatch(sm_instance_t *sm, const sm_event_t *ev, argent_us_t now)
{
    sm->now = now;
    sm->last_fired = 0;
    if (dispatch_core(sm, ev) > 0) { sm->events_consumed++; offer_held(sm); }
    else if (may_take(sm, ev)) hold(sm, ev);
    else sm->events_ignored++;
    return sm->last_fired;
}

uint32_t sm_tick(sm_instance_t *sm, argent_us_t now)
{
    sm->now = now;
    sm->last_fired = 0;
    for (unsigned rounds = 0; rounds < SM_MAX_TRANSITIONS; rounds++) {
        bool fired = false;
        for (uint16_t i = 0; i < sm->def->transition_count && !fired; i++) {
            const argent_transition_t *t = &sm->def->transitions[i];
            if (t->trigger_kind != ARGENT_TRIGGER_TIMED || sm->timer_deadline[i] == 0 || sm->timer_deadline[i] > now) continue;
            if ((sm->active & BIT(t->source)) == 0) { sm->timer_deadline[i] = 0; continue; }
            if (!guard_ok(sm, t, NULL)) continue;
            fire(sm, i, NULL);
            fired = true;
        }
        if (!fired) break;
    }
    run_completions(sm);
    if (sm->last_fired > 0) offer_held(sm);
    return sm->last_fired;
}

argent_us_t sm_next_deadline(const sm_instance_t *sm)
{
    argent_us_t best = 0;
    for (uint16_t i = 0; i < sm->def->transition_count; i++) {
        argent_us_t d = sm->timer_deadline[i];
        if (d != 0 && (best == 0 || d < best)) best = d;
    }
    return best;
}

bool sm_is_active(const sm_instance_t *sm, int16_t state) { return state >= 0 && (sm->active & BIT(state)) != 0; }

static void append(char *buf, uint32_t len, uint32_t *pos, const char *s)
{
    while (*s != '\0' && *pos + 1 < len) buf[(*pos)++] = *s++;
    buf[*pos] = '\0';
}

static const char *deepest_leaf(const sm_instance_t *sm, int16_t region)
{
    /* The active state in this region that has no active child. */
    for (uint16_t i = 0; i < sm->def->state_count; i++) {
        bool has_active_child = false;
        if ((sm->active & BIT(i)) == 0 || (region != ARGENT_STATE_NONE && !is_self_or_descendant(sm, (int16_t)i, region))) continue;
        for (uint16_t j = 0; j < sm->def->state_count && !has_active_child; j++)
            if (sm->def->states[j].parent == (int16_t)i && (sm->active & BIT(j)) != 0) has_active_child = true;
        if (!has_active_child) return sm->def->states[i].name;
    }
    return "done";
}

void sm_config(const sm_instance_t *sm, char *buf, uint32_t len)
{
    uint32_t pos = 0;
    if (len == 0) return;
    buf[0] = '\0';
    if (!parallel(sm)) { append(buf, len, &pos, deepest_leaf(sm, ARGENT_STATE_NONE)); return; }
    for (uint16_t i = 0; i < sm->def->state_count; i++) {
        if (sm->def->states[i].parent != ARGENT_STATE_NONE) continue;
        if (pos > 0) append(buf, len, &pos, " | ");
        append(buf, len, &pos, deepest_leaf(sm, (int16_t)i));
    }
}
