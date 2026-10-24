#include "svc/parameter.h"
#include <string.h>

static uint32_t crc_table(const parameter_service_t *svc, uint16_t table_id)
{
    uint32_t crc = 0xffffffffu;
    for (uint16_t i = 0; i < ARGENT_PARAMETER_ROW_COUNT; i++) {
        const unsigned char *b;
        if (argent_parameters[i].table_id != table_id) continue;
        b = (const unsigned char *)&svc->value[i];
        for (unsigned k = 0; k < sizeof(double); k++) {
            crc ^= b[k];
            for (unsigned bit = 0; bit < 8; bit++) crc = (crc >> 1) ^ (0xedb88320u & (0u - (crc & 1u)));
        }
    }
    return ~crc;
}

void parameter_init(parameter_service_t *svc)
{
    memset(svc, 0, sizeof(*svc));
    for (uint16_t i = 0; i < ARGENT_PARAMETER_ROW_COUNT; i++) svc->value[i] = argent_parameters[i].value;
    for (uint16_t t = 0; t < ARGENT_PARAMETER_TABLE_COUNT; t++) svc->table_crc[t] = crc_table(svc, argent_parameter_tables[t].table_id);
}

const argent_parameter_t *parameter_lookup(const char *name)
{
    for (uint16_t i = 0; i < ARGENT_PARAMETER_ROW_COUNT; i++)
        if (strcmp(argent_parameters[i].name, name) == 0) return &argent_parameters[i];
    return NULL;
}

bool parameter_get(const parameter_service_t *svc, const char *name, double *value)
{
    const argent_parameter_t *p = parameter_lookup(name);
    if (p == NULL) return false;
    *value = svc->value[p - argent_parameters];
    return true;
}

bool parameter_set(parameter_service_t *svc, const char *name, double value)
{
    const argent_parameter_t *p = parameter_lookup(name);
    if (p == NULL || value < p->minimum || value > p->maximum) { svc->rejected_writes++; return false; }
    svc->value[p - argent_parameters] = value;
    svc->writes++;
    for (uint16_t t = 0; t < ARGENT_PARAMETER_TABLE_COUNT; t++)
        if (argent_parameter_tables[t].table_id == p->table_id) svc->table_crc[t] = crc_table(svc, p->table_id);
    return true;
}

uint32_t parameter_table_crc(const parameter_service_t *svc, uint16_t table_id)
{
    for (uint16_t t = 0; t < ARGENT_PARAMETER_TABLE_COUNT; t++)
        if (argent_parameter_tables[t].table_id == table_id) return svc->table_crc[t];
    return 0;
}

bool limit_get(const char *name, double *value)
{
    for (uint16_t i = 0; i < ARGENT_LIMIT_ROW_COUNT; i++)
        if (strcmp(argent_limit_table[i].name, name) == 0) { *value = argent_limit_table[i].value; return true; }
    return false;
}

bool monitor_limit_get(const char *limit_set, const char *name, double *value)
{
    for (uint16_t i = 0; i < ARGENT_MONITOR_LIMIT_COUNT; i++)
        if (strcmp(argent_monitor_limits[i].limit_set, limit_set) == 0 && strcmp(argent_monitor_limits[i].name, name) == 0) {
            *value = argent_monitor_limits[i].value;
            return true;
        }
    return false;
}

monitor_verdict_t monitor_check(const argent_telemetry_point_t *point, double value)
{
    if (!point->has_limits) return MONITOR_NOMINAL;
    if (value < point->red_low) return MONITOR_RED_LOW;
    if (value > point->red_high) return MONITOR_RED_HIGH;
    if (value < point->yellow_low) return MONITOR_YELLOW_LOW;
    if (value > point->yellow_high) return MONITOR_YELLOW_HIGH;
    return MONITOR_NOMINAL;
}

const char *monitor_verdict_name(monitor_verdict_t v)
{
    static const char *const names[] = { "nominal", "yellowLow", "yellowHigh", "redLow", "redHigh" };
    return names[v];
}
