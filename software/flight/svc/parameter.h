/* Parameter and limit service: the 48 parameter rows in 12 tables (writable within the table's
 * min/max), the 6 flight limits and the 12 monitor limits with red/yellow monitoring. */
#ifndef ARGENT_SVC_PARAMETER_H
#define ARGENT_SVC_PARAMETER_H
#include <stdbool.h>
#include <stdint.h>
#include "argent_parameters.h"
#include "argent_telemetry.h"

typedef enum { MONITOR_NOMINAL = 0, MONITOR_YELLOW_LOW, MONITOR_YELLOW_HIGH, MONITOR_RED_LOW, MONITOR_RED_HIGH } monitor_verdict_t;

typedef struct {
    double value[ARGENT_PARAMETER_ROW_COUNT];
    uint32_t writes, rejected_writes;
    uint32_t table_crc[ARGENT_PARAMETER_TABLE_COUNT];
} parameter_service_t;

void parameter_init(parameter_service_t *svc);
const argent_parameter_t *parameter_lookup(const char *name);
bool parameter_get(const parameter_service_t *svc, const char *name, double *value);
/* Rejects a value outside the row's [minimum, maximum]; returns false and counts the rejection. */
bool parameter_set(parameter_service_t *svc, const char *name, double value);
uint32_t parameter_table_crc(const parameter_service_t *svc, uint16_t table_id);
bool limit_get(const char *name, double *value);
bool monitor_limit_get(const char *limit_set, const char *name, double *value);
/* Red/yellow verdict of a telemetry point's value against its dictionary limits. */
monitor_verdict_t monitor_check(const argent_telemetry_point_t *point, double value);
const char *monitor_verdict_name(monitor_verdict_t v);

#endif
