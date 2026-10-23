/* AABP-1 bus: streams, per-mode slot load, the deliberate reserve failure, topic fan-out. */
#include "tests/runner.h"
#include "bus/bus.h"

static void test_mode_loads_match_table(void)
{
    unsigned failing = 0, worst = 0;
    for (unsigned m = 0; m < ARGENT_TUG_MODE_COUNT; m++) {
        CHECK((unsigned)argent_bus_mode_loads[m].mode == m);
        CHECK(bus_slot_load((uint16_t)m) == argent_bus_mode_loads[m].slots_used);
        CHECK(bus_table_load((uint16_t)m) == argent_bus_mode_loads[m].slots_used);
        CHECK(bus_reserve_check((uint16_t)m) == (argent_bus_mode_loads[m].slots_used <= ARGENT_BUS_FRAME_SLOTS / 2u));
        if (!bus_reserve_check((uint16_t)m)) failing++;
        if (argent_bus_mode_loads[m].slots_used > worst) worst = argent_bus_mode_loads[m].slots_used;
    }
    CHECK(failing == 3);   /* proximityOperations, capture, despin: the deliberate TF-011 failure stays visible */
    CHECK(worst == 36);
}

static void test_streams(void)
{
    CHECK(ARGENT_BUS_STREAM_COUNT == 13u);
    for (unsigned i = 0; i < ARGENT_BUS_STREAM_COUNT; i++) {
        CHECK(argent_bus_streams[i].name != NULL && argent_bus_streams[i].slots_per_frame > 0);
        CHECK(argent_bus_streams[i].active_modes != 0);
    }
    for (unsigned m = 0; m < ARGENT_TUG_MODE_COUNT; m++) {
        unsigned sum = 0;
        for (unsigned i = 0; i < ARGENT_BUS_STREAM_COUNT; i++)
            if (argent_bus_streams[i].active_modes & (argent_mode_mask_t)(1u << m)) sum += argent_bus_streams[i].slots_per_frame;
        CHECK(sum == argent_bus_mode_loads[m].slots_used);
    }
}

static unsigned deliveries[ARGENT_TOPIC_COUNT];
static void on_message(void *ctx, const bus_message_t *msg) { deliveries[*(unsigned *)ctx]++; (void)msg; }

static void test_topic_fanout(void)
{
    static bus_t bus;
    static unsigned ids[ARGENT_TOPIC_COUNT];
    unsigned three = 0, four = 0;
    bus_init(&bus);
    for (unsigned t = 0; t < ARGENT_TOPIC_COUNT; t++) {
        ids[t] = t;
        /* one end publishes, the others subscribe */
        for (unsigned e = 1; e < argent_topics[t].end_count; e++) CHECK(bus_subscribe(&bus, argent_topics[t].name, on_message, &ids[t]));
        CHECK(!bus_subscribe(&bus, argent_topics[t].name, on_message, &ids[t]));
        if (argent_topics[t].end_count == 3) three++;
        if (argent_topics[t].end_count == 4) four++;
    }
    CHECK(three > 0 && four > 0);
    bus_lock(&bus);
    CHECK(!bus_subscribe(&bus, argent_topics[0].name, on_message, &ids[0]));
    for (unsigned t = 0; t < ARGENT_TOPIC_COUNT; t++) {
        uint8_t payload[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
        CHECK(bus_publish(&bus, argent_topics[t].name, payload, sizeof payload));
        CHECK(deliveries[t] == argent_topics[t].end_count - 1u);
        CHECK(bus_topic(&bus, argent_topics[t].name)->delivered == argent_topics[t].end_count - 1u);
    }
    CHECK(!bus_publish(&bus, "noSuchTopic", NULL, 0));
    CHECK(bus_begin_frame(&bus, 0) == argent_bus_mode_loads[0].slots_used);
}

const test_case_t bus_tests[] = {
    { "bus: per-mode slot load equals the table and the reserve check fails in three modes", "TF-011", test_mode_loads_match_table },
    { "bus: thirteen streams sum to the per-mode load", "model 66 slot schedule", test_streams },
    { "bus: every catalogue topic fans out to all its ends", "model 68 message catalogue", test_topic_fanout },
};
const unsigned bus_test_count = sizeof bus_tests / sizeof bus_tests[0];
