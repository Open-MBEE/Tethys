#include "trace/trace.h"
#include <string.h>

void trace_init(trace_t *tr, FILE *out) { memset(tr, 0, sizeof(*tr)); tr->out = out; }

void trace_begin_frame(trace_t *tr) { tr->item_count = 0; }

void trace_add(trace_t *tr, const char *key, const char *json_fragment)
{
    char *slot;
    if (tr->item_count >= TRACE_MAX_ITEMS) { tr->dropped++; return; }
    slot = tr->items[tr->item_count++];
    snprintf(slot, TRACE_ITEM_LEN, "%s\x1f%s", key, json_fragment);
}

void trace_json_escape(const char *in, char *out, uint32_t len)
{
    uint32_t o = 0;
    for (; *in != '\0' && o + 2 < len; in++) {
        if (*in == '"' || *in == '\\') { out[o++] = '\\'; out[o++] = *in; }
        else if (*in == '\n') { out[o++] = '\\'; out[o++] = 'n'; }
        else out[o++] = *in;
    }
    out[o] = '\0';
}

static void write_group(trace_t *tr, const char *key)
{
    bool first = true;
    fprintf(tr->out, ",\"%s\":[", key);
    for (uint32_t i = 0; i < tr->item_count; i++) {
        const char *sep = strchr(tr->items[i], '\x1f');
        if (sep == NULL || strncmp(tr->items[i], key, (size_t)(sep - tr->items[i])) != 0 || strlen(key) != (size_t)(sep - tr->items[i])) continue;
        fprintf(tr->out, "%s%s", first ? "" : ",", sep + 1);
        first = false;
    }
    fputc(']', tr->out);
}

void trace_end_frame(trace_t *tr, uint64_t frame_index, uint32_t minor, argent_us_t now, const char *mode,
                     const char *machines_json, uint32_t bus_slots, uint32_t bus_slot_capacity, bool reserve_ok,
                     uint32_t task_overruns, uint32_t frame_overruns, uint32_t inhibit_register,
                     argent_us_t charged_us, uint32_t tasks_fired)
{
    if (tr->out == NULL) return;
    fprintf(tr->out, "{\"frame\":%llu,\"minor\":%u,\"t_us\":%llu,\"mode\":\"%s\",\"machines\":%s",
            (unsigned long long)frame_index, minor, (unsigned long long)now, mode, machines_json);
    write_group(tr, "events");
    write_group(tr, "commands");
    write_group(tr, "packets");
    write_group(tr, "faults");
    fprintf(tr->out, ",\"bus\":{\"slots\":%u,\"capacity\":%u,\"reserve_ok\":%s}", bus_slots, bus_slot_capacity, reserve_ok ? "true" : "false");
    fprintf(tr->out, ",\"exec\":{\"charged_us\":%llu,\"tasks\":%u,\"task_overruns\":%u,\"frame_overruns\":%u}",
            (unsigned long long)charged_us, tasks_fired, task_overruns, frame_overruns);
    fprintf(tr->out, ",\"inhibits\":%u", inhibit_register);
    if (tr->dropped > 0) fprintf(tr->out, ",\"dropped\":%u", tr->dropped);
    fputs("}\n", tr->out);
    tr->lines++;
    tr->dropped = 0;
}

void trace_skip(trace_t *tr, uint64_t from_frame, uint64_t to_frame, argent_us_t from_us, argent_us_t to_us)
{
    if (tr->out == NULL) return;
    fprintf(tr->out, "{\"skip\":{\"from_frame\":%llu,\"to_frame\":%llu,\"from_us\":%llu,\"to_us\":%llu}}\n",
            (unsigned long long)from_frame, (unsigned long long)to_frame, (unsigned long long)from_us, (unsigned long long)to_us);
    tr->lines++;
}
