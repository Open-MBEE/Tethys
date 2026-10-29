/* The AABP-1 software bus: 13 streams on the 64-slot frame with per-mode slot allocation, the
 * inter-application message catalogue as publish/subscribe topics, and the reserve check that
 * reports the full-mode load against the 50 % reserve rule (it fails in the 36-slot modes). */
#ifndef ARGENT_BUS_H
#define ARGENT_BUS_H
#include <stdbool.h>
#include <stdint.h>
#include "argent_interfaces.h"
#include "argent_schedule.h"

#define BUS_MAX_TOPICS 16u
#define BUS_MAX_SUBSCRIBERS 8u
#define BUS_QUEUE_DEPTH 8u
#define BUS_PAYLOAD_BYTES 64u
#define BUS_RESERVE_SLOTS (ARGENT_BUS_FRAME_SLOTS / 2u)

typedef struct {
    uint16_t topic;
    uint16_t length;
    uint8_t payload[BUS_PAYLOAD_BYTES];
} bus_message_t;

typedef void (*bus_subscriber_fn)(void *ctx, const bus_message_t *msg);

typedef struct {
    const argent_topic_t *def;
    const argent_message_t *message;
    bus_subscriber_fn subscribers[BUS_MAX_SUBSCRIBERS];
    void *subscriber_ctx[BUS_MAX_SUBSCRIBERS];
    uint8_t subscriber_count;
    uint32_t published;
    uint32_t delivered;
    uint32_t overflowed;
} bus_topic_t;

typedef struct {
    bus_topic_t topics[BUS_MAX_TOPICS];
    uint16_t topic_count;
    uint32_t slot_load;              /* slots allocated to the active streams in this frame */
    uint32_t octets_this_frame;      /* message octets moved in this frame */
    uint32_t octet_overflows;        /* frames whose message octets exceeded the slot capacity */
    uint32_t frames;
    bool locked;                     /* subscriptions close at the end of initialisation */
} bus_t;

void bus_init(bus_t *bus);
bool bus_subscribe(bus_t *bus, const char *topic_name, bus_subscriber_fn fn, void *ctx);
void bus_lock(bus_t *bus);
/* Delivers synchronously to every subscriber end of the topic; returns false on an unknown topic. */
bool bus_publish(bus_t *bus, const char *topic_name, const void *payload, uint16_t length);
/* Allocates the frame's slots to the streams active in `mode` per the table; returns the load. */
uint32_t bus_begin_frame(bus_t *bus, uint16_t mode);
uint32_t bus_slot_load(uint16_t mode);
uint32_t bus_table_load(uint16_t mode);
/* TF-011/TF-012: the mode's slot load leaves the 50 % reserve. False in the 36-slot modes. */
bool bus_reserve_check(uint16_t mode);
const bus_topic_t *bus_topic(const bus_t *bus, const char *topic_name);

#endif
