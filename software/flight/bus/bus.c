#include "bus/bus.h"
#include <string.h>

static const argent_message_t *message_for(const argent_topic_t *topic)
{
    for (uint16_t i = 0; i < ARGENT_MESSAGE_COUNT; i++)
        if (strcmp(argent_messages[i].type, topic->payload) == 0) return &argent_messages[i];
    return NULL;
}

void bus_init(bus_t *bus)
{
    memset(bus, 0, sizeof(*bus));
    for (uint16_t i = 0; i < ARGENT_TOPIC_COUNT && i < BUS_MAX_TOPICS; i++) {
        bus->topics[i].def = &argent_topics[i];
        bus->topics[i].message = message_for(&argent_topics[i]);
        bus->topic_count++;
    }
}

static bus_topic_t *find_topic(bus_t *bus, const char *name)
{
    for (uint16_t i = 0; i < bus->topic_count; i++)
        if (strcmp(bus->topics[i].def->name, name) == 0) return &bus->topics[i];
    return NULL;
}

const bus_topic_t *bus_topic(const bus_t *bus, const char *topic_name)
{
    for (uint16_t i = 0; i < bus->topic_count; i++)
        if (strcmp(bus->topics[i].def->name, topic_name) == 0) return &bus->topics[i];
    return NULL;
}

bool bus_subscribe(bus_t *bus, const char *topic_name, bus_subscriber_fn fn, void *ctx)
{
    bus_topic_t *t = find_topic(bus, topic_name);
    /* The catalogue fixes the subscriber ends per topic: one subscription per subscriber end. */
    if (t == NULL || bus->locked || t->subscriber_count >= BUS_MAX_SUBSCRIBERS || t->subscriber_count + 1u >= t->def->end_count) return false;
    t->subscribers[t->subscriber_count] = fn;
    t->subscriber_ctx[t->subscriber_count] = ctx;
    t->subscriber_count++;
    return true;
}

void bus_lock(bus_t *bus) { bus->locked = true; }

bool bus_publish(bus_t *bus, const char *topic_name, const void *payload, uint16_t length)
{
    bus_topic_t *t = find_topic(bus, topic_name);
    bus_message_t msg;
    if (t == NULL || length > BUS_PAYLOAD_BYTES) return false;
    msg.topic = (uint16_t)(t - bus->topics);
    msg.length = length;
    memset(msg.payload, 0, sizeof msg.payload);
    if (payload != NULL && length > 0) memcpy(msg.payload, payload, length);
    t->published++;
    if (t->message != NULL) bus->octets_this_frame += (uint32_t)t->message->length_bytes * (uint32_t)t->subscriber_count;
    for (uint8_t i = 0; i < t->subscriber_count; i++) { t->subscribers[i](t->subscriber_ctx[i], &msg); t->delivered++; }
    return true;
}

uint32_t bus_slot_load(uint16_t mode)
{
    uint32_t slots = 0;
    for (uint16_t i = 0; i < ARGENT_BUS_STREAM_COUNT; i++)
        if (((argent_bus_streams[i].active_modes >> mode) & 1u) != 0) slots += argent_bus_streams[i].slots_per_frame;
    return slots;
}

uint32_t bus_table_load(uint16_t mode)
{
    for (uint16_t i = 0; i < ARGENT_TUG_MODE_COUNT; i++)
        if ((uint16_t)argent_bus_mode_loads[i].mode == mode) return argent_bus_mode_loads[i].slots_used;
    return 0;
}

bool bus_reserve_check(uint16_t mode) { return bus_slot_load(mode) <= BUS_RESERVE_SLOTS; }

uint32_t bus_begin_frame(bus_t *bus, uint16_t mode)
{
    uint32_t capacity_octets;
    bus->slot_load = bus_slot_load(mode);
    capacity_octets = bus->slot_load * (uint32_t)ARGENT_BUS_SLOT_LENGTH_BYTES;
    if (bus->octets_this_frame > capacity_octets) bus->octet_overflows++;
    bus->octets_this_frame = 0;
    bus->frames++;
    return bus->slot_load;
}
