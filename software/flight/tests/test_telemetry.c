/* Telemetry service: CCSDS primary header, sequence counts, packet lengths, per-mode rate sets, time code. */
#include "tests/runner.h"
#include "svc/telemetry.h"

typedef struct { uint32_t packets; uint16_t last_seq, last_len; uint8_t head[8]; const argent_packet_t *last; } emit_ctx_t;

static double sample(void *ctx, uint16_t index, const argent_telemetry_point_t *point) { (void)ctx; (void)point; return (double)index; }
static void emit(void *ctx, const argent_packet_t *packet, uint16_t sequence_count, const uint8_t *octets, uint16_t length)
{
    emit_ctx_t *e = ctx;
    e->packets++; e->last = packet; e->last_seq = sequence_count; e->last_len = length;
    memcpy(e->head, octets, length < 8 ? length : 8);
}

static void test_every_packet_builds(void)
{
    static telemetry_service_t svc;
    static emit_ctx_t e;
    telemetry_init(&svc, sample, NULL, emit, &e);
    for (unsigned i = 0; i < ARGENT_PACKET_COUNT; i++) {
        const argent_packet_t *p = &argent_packets[i];
        const uint8_t *h = svc.buffer;
        uint16_t len = telemetry_build_packet(&svc, p, argent_s_to_us(1.5));
        CHECK(len == p->length_octets);
        /* CCSDS Space Packet primary header: version 000, type 0 (TM), secondary header flag 1, 11-bit APID. */
        CHECK((h[0] >> 5) == 0);
        CHECK(((h[0] >> 4) & 1u) == 0);
        CHECK(((h[0] >> 3) & 1u) == 1);
        CHECK(((unsigned)(h[0] & 0x07u) << 8 | h[1]) == p->apid);
        CHECK((h[2] >> 6) == 3);                                    /* unsegmented */
        CHECK((((unsigned)(h[2] & 0x3fu) << 8) | h[3]) == 0);       /* sequence count */
        CHECK(((unsigned)h[4] << 8 | h[5]) == (unsigned)len - 7u);  /* packet data length */
        CHECK(telemetry_build_packet(&svc, p, argent_s_to_us(2.5)) == len);
        CHECK((((unsigned)(h[2] & 0x3fu) << 8) | h[3]) == 1);
        CHECK(svc.sequence_count[i] == 2);
    }
    CHECK(e.packets == 0);   /* building does not emit; the cycle does */
}

static void test_sequence_count_wraps(void)
{
    static telemetry_service_t svc;
    telemetry_init(&svc, sample, NULL, NULL, NULL);
    for (unsigned n = 0; n < (1u << ARGENT_PRIMARY_HEADER_SEQUENCE_COUNT_WIDTH); n++) telemetry_build_packet(&svc, &argent_packets[0], 0);
    telemetry_build_packet(&svc, &argent_packets[0], 0);
    CHECK(((((unsigned)svc.buffer[2] & 0x3fu) << 8) | svc.buffer[3]) == 0);
}

static void test_rate_sets_and_points(void)
{
    for (uint16_t m = 0; m < ARGENT_TUG_MODE_COUNT; m++) {
        const argent_mode_rate_set_t *rs = telemetry_rate_set(m);
        CHECK(rs != NULL && rs->mode == (argent_tug_mode_t)m && rs->housekeeping_period_s > 0 && rs->downlink_bit_s > 0);
    }
    CHECK(telemetry_rate_set(ARGENT_TUG_MODE_COUNT) == NULL);
    unsigned hk = 0;
    for (unsigned i = 0; i < ARGENT_TELEMETRY_POINT_COUNT; i++) {
        CHECK(telemetry_point(argent_telemetry_points[i].mnemonic)->id == argent_telemetry_points[i].id);
        CHECK(argent_telemetry_points[i].packet_count >= 1);
        if ((argent_telemetry_points[i].kind == ARGENT_TELEMETRY_KIND_HOUSEKEEPING)) hk++;
    }
    CHECK(hk == ARGENT_HOUSEKEEPING_POINT_COUNT);
    CHECK(telemetry_point("NoSuchPoint") == NULL);
}

static void test_cycle_and_time_code(void)
{
    static telemetry_service_t svc;
    static emit_ctx_t e;
    telemetry_init(&svc, sample, NULL, emit, &e);
    for (unsigned f = 0; f < 8u * 60u; f++) telemetry_cycle(&svc, 1, (argent_us_t)f * ARGENT_MINOR_FRAME_US);
    CHECK(svc.packets > 0 && svc.samples > 0 && e.packets == svc.packets);
    telemetry_set_value(&svc, argent_telemetry_points[3].mnemonic, 42.5);
    CHECK(telemetry_get_value(&svc, argent_telemetry_points[3].mnemonic) == 42.5);
    CHECK(telemetry_time_code_coarse(argent_s_to_us(1.5)) == 1);
    CHECK(telemetry_time_code_fine(argent_s_to_us(1.5)) == 32768);
    CHECK(telemetry_time_code_fine(argent_s_to_us(2.0)) == 0);
}

const test_case_t telemetry_tests[] = {
    { "telemetry: all 51 packets build with the CCSDS primary header and the table length", "model 68 MLS-2 packet profile", test_every_packet_builds },
    { "telemetry: 14-bit sequence count wraps", "CCSDS Space Packet Protocol", test_sequence_count_wraps },
    { "telemetry: 16 per-mode rate sets and 961 points (320 housekeeping)", "model 68 rate sets", test_rate_sets_and_points },
    { "telemetry: a minute of cycling emits packets; CUC time code", "model 66 telemetry task", test_cycle_and_time_code },
};
const unsigned telemetry_test_count = sizeof telemetry_tests / sizeof telemetry_tests[0];
