#include "svc/telemetry.h"
#include <math.h>
#include <string.h>

void telemetry_init(telemetry_service_t *svc, telemetry_sample_fn sample, void *sample_ctx, telemetry_packet_fn emit, void *emit_ctx)
{
    memset(svc, 0, sizeof(*svc));
    svc->sample = sample; svc->sample_ctx = sample_ctx;
    svc->emit = emit; svc->emit_ctx = emit_ctx;
}

const argent_telemetry_point_t *telemetry_point(const char *mnemonic)
{
    for (uint16_t i = 0; i < ARGENT_TELEMETRY_POINT_COUNT; i++)
        if (strcmp(argent_telemetry_points[i].mnemonic, mnemonic) == 0) return &argent_telemetry_points[i];
    return NULL;
}

const argent_mode_rate_set_t *telemetry_rate_set(uint16_t mode)
{
    for (uint16_t i = 0; i < ARGENT_MODE_RATE_SET_COUNT; i++)
        if ((uint16_t)argent_mode_rate_sets[i].mode == mode) return &argent_mode_rate_sets[i];
    return NULL;
}

uint32_t telemetry_time_code_coarse(argent_us_t now) { return (uint32_t)(now / ARGENT_US_PER_S); }
uint16_t telemetry_time_code_fine(argent_us_t now)
{
    /* 16-bit fine field: 1/65536 s resolution per the table. */
    return (uint16_t)(((now % ARGENT_US_PER_S) << ARGENT_TIME_CODE_FINE_WIDTH) / ARGENT_US_PER_S);
}

static void put_bits(uint8_t *buf, uint32_t bit_offset, uint32_t width, uint64_t value)
{
    for (uint32_t i = 0; i < width; i++) {
        uint32_t bit = bit_offset + i;
        uint64_t v = (value >> (width - 1u - i)) & 1u;
        if (v) buf[bit / 8u] |= (uint8_t)(0x80u >> (bit % 8u)); else buf[bit / 8u] &= (uint8_t)~(0x80u >> (bit % 8u));
    }
}

static uint64_t encode_field(const argent_telemetry_point_t *p, double value, uint16_t width)
{
    /* Fixed-point encoding across the point's limit span when it has limits, else integer truncation. */
    double scaled = value;
    uint64_t max = width >= 64u ? UINT64_MAX : ((uint64_t)1u << width) - 1u;
    if (p != NULL && p->has_limits && p->red_high > p->red_low) scaled = (value - p->red_low) / (p->red_high - p->red_low) * (double)max;
    if (scaled < 0.0) return 0;
    if (scaled > (double)max) return max;
    return (uint64_t)scaled;
}

uint16_t telemetry_build_packet(telemetry_service_t *svc, const argent_packet_t *packet, argent_us_t now)
{
    uint16_t length = packet->length_octets;
    uint32_t bit = 0;
    uint16_t seq = svc->sequence_count[packet - argent_packets];
    if (length > TELEMETRY_MAX_PACKET_OCTETS) length = TELEMETRY_MAX_PACKET_OCTETS;
    memset(svc->buffer, 0, length);
    /* CCSDS primary header: version, type (telemetry = 0), secondary header flag, APID, sequence flags (unsegmented), count, data length. */
    put_bits(svc->buffer, bit, ARGENT_PRIMARY_HEADER_VERSION_WIDTH, 0); bit += ARGENT_PRIMARY_HEADER_VERSION_WIDTH;
    put_bits(svc->buffer, bit, ARGENT_PRIMARY_HEADER_TYPE_WIDTH, 0); bit += ARGENT_PRIMARY_HEADER_TYPE_WIDTH;
    put_bits(svc->buffer, bit, ARGENT_PRIMARY_HEADER_SECONDARY_HEADER_FLAG_WIDTH, 1); bit += ARGENT_PRIMARY_HEADER_SECONDARY_HEADER_FLAG_WIDTH;
    put_bits(svc->buffer, bit, ARGENT_PRIMARY_HEADER_APID_WIDTH, packet->apid); bit += ARGENT_PRIMARY_HEADER_APID_WIDTH;
    put_bits(svc->buffer, bit, ARGENT_PRIMARY_HEADER_SEQUENCE_FLAGS_WIDTH, 3); bit += ARGENT_PRIMARY_HEADER_SEQUENCE_FLAGS_WIDTH;
    put_bits(svc->buffer, bit, ARGENT_PRIMARY_HEADER_SEQUENCE_COUNT_WIDTH, seq); bit += ARGENT_PRIMARY_HEADER_SEQUENCE_COUNT_WIDTH;
    put_bits(svc->buffer, bit, ARGENT_PRIMARY_HEADER_DATA_LENGTH_WIDTH, (uint64_t)(length - TELEMETRY_PRIMARY_HEADER_OCTETS - 1u)); bit += ARGENT_PRIMARY_HEADER_DATA_LENGTH_WIDTH;
    put_bits(svc->buffer, bit, ARGENT_TIME_CODE_COARSE_WIDTH, telemetry_time_code_coarse(now)); bit += ARGENT_TIME_CODE_COARSE_WIDTH;
    put_bits(svc->buffer, bit, ARGENT_TIME_CODE_FINE_WIDTH, telemetry_time_code_fine(now)); bit += ARGENT_TIME_CODE_FINE_WIDTH;
    for (uint16_t f = 0; f < packet->field_count; f++) {
        const argent_packet_field_t *field = &argent_packet_fields[packet->first_field + f];
        const argent_telemetry_point_t *p = NULL;
        uint32_t at = packet->header_bits + field->offset_bits;
        uint16_t idx = 0;
        for (uint16_t i = 0; i < ARGENT_TELEMETRY_POINT_COUNT; i++) if (argent_telemetry_points[i].id == field->point_id) { p = &argent_telemetry_points[i]; idx = i; break; }
        if (at + field->width_bits > (uint32_t)length * 8u) break;
        put_bits(svc->buffer, at, field->width_bits, encode_field(p, p != NULL ? svc->value[idx] : 0.0, field->width_bits));
    }
    return length;
}

static double rate_scale(uint16_t mode, const argent_telemetry_point_t *p)
{
    /* Housekeeping follows the mode's rate set period; the other kinds keep their dictionary rate. */
    const argent_mode_rate_set_t *rs = telemetry_rate_set(mode);
    if (rs == NULL || p == NULL || p->kind != ARGENT_TELEMETRY_KIND_HOUSEKEEPING || rs->housekeeping_period_s <= 0.0) return 1.0;
    return 1.0 / rs->housekeeping_period_s / (p->rate_hz > 0.0 ? p->rate_hz : 1.0);
}

void telemetry_cycle(telemetry_service_t *svc, uint16_t mode, argent_us_t now)
{
    for (uint16_t i = 0; i < ARGENT_TELEMETRY_POINT_COUNT; i++) {
        const argent_telemetry_point_t *p = &argent_telemetry_points[i];
        double hz;
        if (now < svc->next_sample_us[i]) continue;
        hz = p->rate_hz * rate_scale(mode, p);
        if (hz <= 0.0) hz = 1.0;
        if (svc->sample != NULL) svc->value[i] = svc->sample(svc->sample_ctx, i, p);
        svc->samples++;
        svc->next_sample_us[i] = now + argent_s_to_us(1.0 / hz);
    }
    for (uint16_t k = 0; k < ARGENT_PACKET_COUNT; k++) {
        const argent_packet_t *pk = &argent_packets[k];
        const argent_mode_rate_set_t *rs = telemetry_rate_set(mode);
        double hz = pk->rate_hz;
        uint16_t length;
        if (pk->apid_class == ARGENT_APID_CLASS_HOUSEKEEPING && rs != NULL && rs->housekeeping_period_s > 0.0) hz = 1.0 / rs->housekeeping_period_s;
        if (hz <= 0.0 || now < svc->next_packet_us[k]) continue;
        length = telemetry_build_packet(svc, pk, now);
        if (svc->emit != NULL) svc->emit(svc->emit_ctx, pk, svc->sequence_count[k], svc->buffer, length);
        svc->sequence_count[k] = (uint16_t)((svc->sequence_count[k] + 1u) % TELEMETRY_SEQUENCE_MODULO);
        svc->packets_emitted[k]++;
        svc->packets++;
        svc->octets += length;
        svc->next_packet_us[k] = now + argent_s_to_us(1.0 / hz);
    }
}

void telemetry_set_value(telemetry_service_t *svc, const char *mnemonic, double value)
{
    const argent_telemetry_point_t *p = telemetry_point(mnemonic);
    if (p != NULL) svc->value[p - argent_telemetry_points] = value;
}

double telemetry_get_value(const telemetry_service_t *svc, const char *mnemonic)
{
    const argent_telemetry_point_t *p = telemetry_point(mnemonic);
    return p != NULL ? svc->value[p - argent_telemetry_points] : NAN;
}
