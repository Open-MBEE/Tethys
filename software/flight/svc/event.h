/* Event service: the 181 dictionary events with severities and fault flags; fault events are
 * forwarded to FDIR through a registered sink, every event goes to the trace and the event log. */
#ifndef ARGENT_SVC_EVENT_H
#define ARGENT_SVC_EVENT_H
#include <stdbool.h>
#include <stdint.h>
#include "argent_events.h"
#include "exec/argent_time.h"

#define EVENT_LOG_DEPTH 64u

typedef struct {
    const argent_event_t *def;
    argent_us_t time;
    double value;
} event_record_t;

typedef void (*event_sink_fn)(void *ctx, const argent_event_t *ev, argent_us_t now, double value);

typedef struct {
    event_record_t log[EVENT_LOG_DEPTH];
    uint32_t head, count;
    uint32_t raised;
    uint32_t faults;
    uint32_t dropped;
    uint32_t by_severity[ARGENT_EVENT_SEVERITY_COUNT];
    event_sink_fn fdir_sink, trace_sink;
    void *fdir_ctx, *trace_ctx;
} event_service_t;

void event_init(event_service_t *svc);
void event_set_fdir_sink(event_service_t *svc, event_sink_fn fn, void *ctx);
void event_set_trace_sink(event_service_t *svc, event_sink_fn fn, void *ctx);
const argent_event_t *event_lookup(const char *mnemonic);
const argent_event_t *event_lookup_id(uint16_t id);
bool event_raise(event_service_t *svc, const char *mnemonic, argent_us_t now, double value);
bool event_pop(event_service_t *svc, event_record_t *out);

#endif
