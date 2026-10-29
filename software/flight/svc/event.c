#include "svc/event.h"
#include <string.h>

void event_init(event_service_t *svc) { memset(svc, 0, sizeof(*svc)); }
void event_set_fdir_sink(event_service_t *svc, event_sink_fn fn, void *ctx) { svc->fdir_sink = fn; svc->fdir_ctx = ctx; }
void event_set_trace_sink(event_service_t *svc, event_sink_fn fn, void *ctx) { svc->trace_sink = fn; svc->trace_ctx = ctx; }

const argent_event_t *event_lookup(const char *mnemonic)
{
    for (uint16_t i = 0; i < ARGENT_EVENT_COUNT; i++)
        if (strcmp(argent_events[i].mnemonic, mnemonic) == 0) return &argent_events[i];
    return NULL;
}

const argent_event_t *event_lookup_id(uint16_t id)
{
    /* Ids are sorted ascending in the table: binary search. */
    uint16_t lo = 0, hi = ARGENT_EVENT_COUNT;
    while (lo < hi) {
        uint16_t mid = (uint16_t)(lo + (hi - lo) / 2u);
        if (argent_events[mid].id == id) return &argent_events[mid];
        if (argent_events[mid].id < id) lo = (uint16_t)(mid + 1u); else hi = mid;
    }
    return NULL;
}

bool event_raise(event_service_t *svc, const char *mnemonic, argent_us_t now, double value)
{
    const argent_event_t *def = event_lookup(mnemonic);
    if (def == NULL) return false;
    svc->raised++;
    if (def->severity < ARGENT_EVENT_SEVERITY_COUNT) svc->by_severity[def->severity]++;
    if (def->is_fault) svc->faults++;
    if (svc->count < EVENT_LOG_DEPTH) {
        event_record_t *r = &svc->log[(svc->head + svc->count) % EVENT_LOG_DEPTH];
        r->def = def; r->time = now; r->value = value;
        svc->count++;
    } else {
        svc->dropped++;
    }
    if (svc->trace_sink != NULL) svc->trace_sink(svc->trace_ctx, def, now, value);
    if (def->fdir_relevant && svc->fdir_sink != NULL) svc->fdir_sink(svc->fdir_ctx, def, now, value);
    return true;
}

bool event_pop(event_service_t *svc, event_record_t *out)
{
    if (svc->count == 0) return false;
    *out = svc->log[svc->head];
    svc->head = (svc->head + 1u) % EVENT_LOG_DEPTH;
    svc->count--;
    return true;
}
