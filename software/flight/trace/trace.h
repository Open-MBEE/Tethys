/* The per-minor-frame JSON-lines trace of the host build. The schema is the contract documented
 * in software/flight/README.md; names are the model's as the generated tables carry them. */
#ifndef ARGENT_TRACE_H
#define ARGENT_TRACE_H
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include "exec/argent_time.h"

#define TRACE_MAX_ITEMS 64u
#define TRACE_ITEM_LEN 96u

typedef struct {
    FILE *out;
    uint32_t item_count;
    char items[TRACE_MAX_ITEMS][TRACE_ITEM_LEN];   /* JSON fragments collected during the frame */
    uint32_t dropped;
    uint64_t lines;
} trace_t;

void trace_init(trace_t *tr, FILE *out);
/* Collects one JSON fragment (already valid JSON) under the frame's "events"/"commands"/... keys. */
void trace_add(trace_t *tr, const char *key, const char *json_fragment);
void trace_begin_frame(trace_t *tr);
/* Writes the frame object: header fields plus the collected fragments grouped by key. */
void trace_end_frame(trace_t *tr, uint64_t frame_index, uint32_t minor, argent_us_t now, const char *mode,
                     const char *machines_json, uint32_t bus_slots, uint32_t bus_slot_capacity, bool reserve_ok,
                     uint32_t task_overruns, uint32_t frame_overruns, uint32_t inhibit_register,
                     argent_us_t charged_us, uint32_t tasks_fired);
void trace_skip(trace_t *tr, uint64_t from_frame, uint64_t to_frame, argent_us_t from_us, argent_us_t to_us);
void trace_json_escape(const char *in, char *out, uint32_t len);

#endif
