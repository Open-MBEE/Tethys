/* Telemetry service: samples the dictionary points at their rate, scaled by the mode's MLS-2 rate
 * set housekeeping period, and assembles packets per argent_packets[]/argent_packet_fields[] with
 * the CCSDS Space Packet primary header, a secondary header and the table's time code. */
#ifndef ARGENT_SVC_TELEMETRY_H
#define ARGENT_SVC_TELEMETRY_H
#include <stdbool.h>
#include <stdint.h>
#include "argent_packets.h"
#include "argent_telemetry.h"
#include "exec/argent_time.h"

#define TELEMETRY_PRIMARY_HEADER_OCTETS 6u
#define TELEMETRY_SECONDARY_HEADER_OCTETS 6u
#define TELEMETRY_MAX_PACKET_OCTETS 1024u
#define TELEMETRY_SEQUENCE_MODULO (1u << ARGENT_PRIMARY_HEADER_SEQUENCE_COUNT_WIDTH)

typedef double (*telemetry_sample_fn)(void *ctx, uint16_t index, const argent_telemetry_point_t *point);
typedef void (*telemetry_packet_fn)(void *ctx, const argent_packet_t *packet, uint16_t sequence_count, const uint8_t *octets, uint16_t length);

typedef struct {
    double value[ARGENT_TELEMETRY_POINT_COUNT];
    argent_us_t next_sample_us[ARGENT_TELEMETRY_POINT_COUNT];
    argent_us_t next_packet_us[ARGENT_PACKET_COUNT];
    uint16_t sequence_count[ARGENT_PACKET_COUNT];
    uint32_t packets_emitted[ARGENT_PACKET_COUNT];
    uint64_t samples, packets, octets;
    uint32_t red_alarms, yellow_alarms;
    telemetry_sample_fn sample; void *sample_ctx;
    telemetry_packet_fn emit; void *emit_ctx;
    uint8_t buffer[TELEMETRY_MAX_PACKET_OCTETS];
} telemetry_service_t;

void telemetry_init(telemetry_service_t *svc, telemetry_sample_fn sample, void *sample_ctx, telemetry_packet_fn emit, void *emit_ctx);
const argent_telemetry_point_t *telemetry_point(const char *mnemonic);
const argent_mode_rate_set_t *telemetry_rate_set(uint16_t mode);
/* Samples the points due at `now` (rate scaled by the mode's housekeeping period) and emits the due packets. */
void telemetry_cycle(telemetry_service_t *svc, uint16_t mode, argent_us_t now);
/* Builds one packet into svc->buffer; returns its total length in octets. */
uint16_t telemetry_build_packet(telemetry_service_t *svc, const argent_packet_t *packet, argent_us_t now);
void telemetry_set_value(telemetry_service_t *svc, const char *mnemonic, double value);
double telemetry_get_value(const telemetry_service_t *svc, const char *mnemonic);
uint32_t telemetry_time_code_coarse(argent_us_t now);
uint16_t telemetry_time_code_fine(argent_us_t now);

#endif
