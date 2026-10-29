#include "svc/command.h"
#include <math.h>
#include <string.h>

void command_init(command_service_t *svc, argent_us_t arm_window_us)
{
    memset(svc, 0, sizeof(*svc));
    svc->inhibits = INHIBIT_ALL;
    svc->arm_window_us = arm_window_us;
}

const argent_command_t *command_lookup(uint16_t opcode)
{
    uint16_t lo = 0, hi = ARGENT_COMMAND_COUNT;
    while (lo < hi) {
        uint16_t mid = (uint16_t)(lo + (hi - lo) / 2u);
        if (argent_commands[mid].opcode == opcode) return &argent_commands[mid];
        if (argent_commands[mid].opcode < opcode) lo = (uint16_t)(mid + 1u); else hi = mid;
    }
    return NULL;
}

const argent_command_t *command_lookup_mnemonic(const char *mnemonic)
{
    for (uint16_t i = 0; i < ARGENT_COMMAND_COUNT; i++)
        if (strcmp(argent_commands[i].mnemonic, mnemonic) == 0) return &argent_commands[i];
    return NULL;
}

inhibit_group_t command_inhibit_group(const argent_command_t *cmd)
{
    if (!cmd->hazardous) return INHIBIT_GROUP_NONE;
    if (cmd->application == ARGENT_APPLICATION_NAME_CAPTURE_CONTROL) return INHIBIT_GROUP_CAPTURE_CHAIN;
    if (cmd->application == ARGENT_APPLICATION_NAME_SEP_CONTROL || cmd->application == ARGENT_APPLICATION_NAME_GNC) return INHIBIT_GROUP_THRUSTER_HOLD;
    return INHIBIT_GROUP_TWO_STEP;
}

uint8_t command_required_clear(const argent_command_t *cmd)
{
    switch (command_inhibit_group(cmd)) {
    case INHIBIT_GROUP_CAPTURE_CHAIN: return INHIBIT_CAPTURE_ARM | INHIBIT_CAPTURE_MODE | INHIBIT_GROUND_ENABLE;
    case INHIBIT_GROUP_THRUSTER_HOLD: return INHIBIT_THRUSTER_HOLD;
    default: return 0;
    }
}

void command_set_inhibit(command_service_t *svc, uint8_t bit, bool asserted)
{
    if (asserted) svc->inhibits |= bit; else svc->inhibits &= (uint8_t)~bit;
    svc->inhibits |= INHIBIT_TWO_STEP;   /* the two-step bit is only ever cleared per opcode, transiently */
}

static bool integral_type(const char *value_type)
{
    return strstr(value_type, "Natural") != NULL || strstr(value_type, "Integer") != NULL || strstr(value_type, "Boolean") != NULL;
}

static command_verdict_t check_arguments(const argent_command_t *cmd, const double *args, uint8_t arg_count)
{
    if (arg_count != cmd->argument_count) return COMMAND_REJECT_ARGUMENT_COUNT;
    for (uint8_t i = 0; i < arg_count; i++) {
        const argent_command_argument_t *a = &argent_command_arguments[cmd->first_argument + i];
        double v = args[i];
        if (v != v) return COMMAND_REJECT_ARGUMENT_TYPE;
        if (integral_type(a->value_type) && v != floor(v)) return COMMAND_REJECT_ARGUMENT_TYPE;
        if (strstr(a->value_type, "Boolean") != NULL && v != 0.0 && v != 1.0) return COMMAND_REJECT_ARGUMENT_TYPE;
        if (v < a->minimum || v > a->maximum) return COMMAND_REJECT_ARGUMENT_RANGE;
        if (integral_type(a->value_type) && a->width_bits < 64u && v >= ldexp(1.0, (int)a->width_bits)) return COMMAND_REJECT_ARGUMENT_RANGE;
    }
    return COMMAND_ACCEPTED;
}

static command_arm_t *find_arm(command_service_t *svc, uint16_t opcode)
{
    for (uint8_t i = 0; i < COMMAND_ARMED_SLOTS; i++)
        if (svc->armed[i].used && svc->armed[i].opcode == opcode) return &svc->armed[i];
    return NULL;
}

static command_verdict_t record(command_service_t *svc, const argent_command_t *cmd, command_verdict_t v)
{
    svc->last_opcode = cmd != NULL ? cmd->opcode : 0u;
    svc->last_verdict = v;
    svc->by_verdict[v]++;
    if (v == COMMAND_ACCEPTED) svc->accepted++;
    else if (v == COMMAND_ARMED) svc->armed_count++;
    else svc->rejected++;
    return v;
}

command_verdict_t command_process(command_service_t *svc, const argent_command_t *cmd, const double *args, uint8_t arg_count,
                                  uint16_t mode, bool execute_step, argent_us_t now)
{
    command_verdict_t v;
    if (cmd == NULL) return record(svc, NULL, COMMAND_REJECT_UNKNOWN_OPCODE);
    v = check_arguments(cmd, args, arg_count);
    if (v != COMMAND_ACCEPTED) return record(svc, cmd, v);
    if (((cmd->allowed_modes >> mode) & 1u) == 0) return record(svc, cmd, COMMAND_REJECT_MODE);
    if (!cmd->hazardous && !cmd->two_step) return record(svc, cmd, COMMAND_ACCEPTED);
    if ((svc->inhibits & command_required_clear(cmd)) != 0) return record(svc, cmd, COMMAND_REJECT_INHIBITED);
    if (!execute_step) {
        command_arm_t *slot = find_arm(svc, cmd->opcode);
        if (slot == NULL) {
            for (uint8_t i = 0; i < COMMAND_ARMED_SLOTS && slot == NULL; i++) if (!svc->armed[i].used) slot = &svc->armed[i];
        }
        if (slot == NULL) return record(svc, cmd, COMMAND_REJECT_ARM_TABLE_FULL);
        slot->used = 1; slot->opcode = cmd->opcode; slot->armed_at = now;
        return record(svc, cmd, COMMAND_ARMED);
    }
    {
        command_arm_t *slot = find_arm(svc, cmd->opcode);
        if (slot == NULL) return record(svc, cmd, COMMAND_REJECT_NOT_ARMED);
        slot->used = 0;
        if (now - slot->armed_at > svc->arm_window_us) return record(svc, cmd, COMMAND_REJECT_ARM_EXPIRED);
    }
    svc->hazardous_executed++;
    return record(svc, cmd, COMMAND_ACCEPTED);
}

const char *command_verdict_name(command_verdict_t v)
{
    static const char *const names[COMMAND_VERDICT_COUNT] = {
        "accepted", "armed", "unknownOpcode", "argumentCount", "argumentType", "argumentRange",
        "modeNotAllowed", "inhibited", "notArmed", "armExpired", "armTableFull"
    };
    return v < COMMAND_VERDICT_COUNT ? names[v] : "unknown";
}
