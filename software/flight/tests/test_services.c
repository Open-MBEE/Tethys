/* Event, parameter/limit/monitor and image services against the generated tables. */
#include "tests/runner.h"
#include "svc/event.h"
#include "svc/parameter.h"
#include "svc/image.h"

static unsigned fdir_seen;
static void fdir_sink(void *ctx, const argent_event_t *ev, argent_us_t now, double value) { (void)ctx; (void)now; (void)value; if (ev->fdir_relevant) fdir_seen++; }

static void test_events(void)
{
    static event_service_t svc;
    unsigned faults = 0, fdir = 0;
    event_init(&svc);
    event_set_fdir_sink(&svc, fdir_sink, NULL);
    for (unsigned i = 0; i < ARGENT_EVENT_COUNT; i++) {
        const argent_event_t *ev = &argent_events[i];
        CHECK(event_lookup(ev->mnemonic)->id == ev->id);   /* tables are static const per translation unit: compare ids, not addresses */
        CHECK(strcmp(event_lookup_id(ev->id)->mnemonic, ev->mnemonic) == 0);
        CHECK(event_raise(&svc, ev->mnemonic, argent_s_to_us((double)i), (double)i));
        if (ev->is_fault) faults++;
        if (ev->fdir_relevant) fdir++;
    }
    CHECK(faults == ARGENT_FAULT_EVENT_COUNT);
    CHECK(svc.raised == ARGENT_EVENT_COUNT && svc.faults == ARGENT_FAULT_EVENT_COUNT);
    CHECK(fdir_seen == fdir && fdir >= ARGENT_FAULT_EVENT_COUNT);
    CHECK(!event_raise(&svc, "NoSuchEvent", 0, 0));
    event_record_t rec;
    unsigned popped = 0;
    while (event_pop(&svc, &rec)) popped++;
    CHECK(popped + svc.dropped == ARGENT_EVENT_COUNT);
}

static void test_parameters_and_limits(void)
{
    static parameter_service_t svc;
    parameter_init(&svc);
    for (unsigned i = 0; i < ARGENT_PARAMETER_ROW_COUNT; i++) {
        const argent_parameter_t *p = &argent_parameters[i];
        double v = -1;
        CHECK(parameter_lookup(p->name)->id == p->id);
        CHECK(parameter_get(&svc, p->name, &v) && v == p->value);
        CHECK(p->minimum <= p->value && p->value <= p->maximum);
    }
    const argent_parameter_t *p0 = &argent_parameters[0];
    uint32_t crc_before = parameter_table_crc(&svc, p0->table_id);
    CHECK(parameter_set(&svc, p0->name, p0->minimum));
    CHECK(!parameter_set(&svc, p0->name, p0->maximum + 1.0));
    CHECK(svc.rejected_writes == 1 && svc.writes == 1);
    CHECK(parameter_table_crc(&svc, p0->table_id) != crc_before || p0->minimum == p0->value);
    unsigned rows = 0;
    for (unsigned t = 0; t < ARGENT_PARAMETER_TABLE_COUNT; t++) rows += argent_parameter_tables[t].row_count;
    CHECK(rows == ARGENT_PARAMETER_ROW_COUNT);
    for (unsigned i = 0; i < ARGENT_LIMIT_ROW_COUNT; i++) {
        double v = 0;
        CHECK(limit_get(argent_limit_table[i].name, &v) && v == argent_limit_table[i].value);
    }
    for (unsigned i = 0; i < ARGENT_MONITOR_LIMIT_COUNT; i++) {
        double v = 0;
        CHECK(monitor_limit_get(argent_monitor_limits[i].limit_set, argent_monitor_limits[i].name, &v) && v == argent_monitor_limits[i].value);
    }
    CHECK(!limit_get("noSuchLimit", NULL));
}

static void test_monitors(void)
{
    unsigned limited = 0;
    for (unsigned i = 0; i < ARGENT_TELEMETRY_POINT_COUNT; i++) {
        const argent_telemetry_point_t *pt = &argent_telemetry_points[i];
        if (!pt->has_limits) { CHECK(monitor_check(pt, 1e300) == MONITOR_NOMINAL); continue; }
        limited++;
        CHECK(monitor_check(pt, (pt->yellow_low + pt->yellow_high) / 2) == MONITOR_NOMINAL);
        CHECK(monitor_check(pt, pt->red_high + 1.0) == MONITOR_RED_HIGH);
        CHECK(monitor_check(pt, pt->red_low - 1.0) == MONITOR_RED_LOW);
        if (pt->yellow_high < pt->red_high) CHECK(monitor_check(pt, (pt->yellow_high + pt->red_high) / 2) == MONITOR_YELLOW_HIGH);
        if (pt->red_low < pt->yellow_low) CHECK(monitor_check(pt, (pt->red_low + pt->yellow_low) / 2) == MONITOR_YELLOW_LOW);
    }
    CHECK(limited > 0);
    CHECK(strcmp(monitor_verdict_name(MONITOR_RED_HIGH), monitor_verdict_name(MONITOR_NOMINAL)) != 0);
}

static void test_images(void)
{
    static image_service_t svc;
    image_init(&svc);
    uint8_t active = svc.active_slot;
    CHECK(svc.staging_slot != active);
    CHECK(image_receive_segment(&svc, 0, 1024));
    CHECK(image_receive_segment(&svc, 1024, 1024));
    CHECK(!image_receive_segment(&svc, 0xffffffffu, 1));   /* outside the slot */
    CHECK(svc.segments_received == 2 && svc.octets_received == 2048);
    CHECK(!image_activate(&svc));            /* not verified yet */
    CHECK(image_verify(&svc) && svc.verify_passes == 1);
    CHECK(image_activate(&svc) && svc.active_slot != active && svc.previous_slot == active);
    CHECK(image_rollback(&svc) && svc.active_slot == active && svc.rollbacks == 1);
    CHECK(image_slot_name(svc.active_slot) != NULL);
}

const test_case_t services_tests[] = {
    { "events: all 181 events raise, 65 faults flagged, FDIR sink sees the relevant ones", "model 64 event dictionary", test_events },
    { "parameters: 48 rows in 12 tables, range-checked writes, 6 limits, 12 monitor limits", "model 64 parameter tables", test_parameters_and_limits },
    { "monitors: red/yellow verdicts for every limited point", "model 64 limits", test_monitors },
    { "images: segments, verify, activate, rollback", "model 65 boot/update", test_images },
};
const unsigned services_test_count = sizeof services_tests / sizeof services_tests[0];
