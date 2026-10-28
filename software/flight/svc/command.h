/* Command service: opcode lookup by binary search over the sorted argent_commands[], argument
 * type/range/width checks, allowed-mode mask, criticality, and the hazardous two-step arm/execute
 * protected by the inhibit register of the software-assurance model (capture chain: three
 * independent inhibits; thruster/high-voltage: hold plus two-step; all others: two-step confirm). */
#ifndef ARGENT_SVC_COMMAND_H
#define ARGENT_SVC_COMMAND_H
#include <stdbool.h>
#include <stdint.h>
#include "argent_commands.h"
#include "exec/argent_time.h"

#define COMMAND_MAX_ARGS 8u
#define COMMAND_ARMED_SLOTS 8u

/* Inhibit register bits: a set bit blocks the hazardous functions it protects. */
#define INHIBIT_CAPTURE_ARM 0x01u     /* capture controller not armed (autonomy partition) */
#define INHIBIT_CAPTURE_MODE 0x02u    /* mode manager not in capture (platform partition) */
#define INHIBIT_GROUND_ENABLE 0x04u   /* ground enable not received (ground) */
#define INHIBIT_THRUSTER_HOLD 0x08u   /* SEP hold timer running (subsystem partition) */
#define INHIBIT_TWO_STEP 0x10u        /* no valid arm step pending for the opcode (ground) */
#define INHIBIT_ALL 0x1fu

typedef enum {
    COMMAND_ACCEPTED = 0,
    COMMAND_ARMED,                   /* first step of a hazardous command accepted */
    COMMAND_REJECT_UNKNOWN_OPCODE,
    COMMAND_REJECT_ARGUMENT_COUNT,
    COMMAND_REJECT_ARGUMENT_TYPE,
    COMMAND_REJECT_ARGUMENT_RANGE,
    COMMAND_REJECT_MODE,
    COMMAND_REJECT_INHIBITED,
    COMMAND_REJECT_NOT_ARMED,
    COMMAND_REJECT_ARM_EXPIRED,
    COMMAND_REJECT_ARM_TABLE_FULL,
    COMMAND_VERDICT_COUNT
} command_verdict_t;

typedef enum { INHIBIT_GROUP_NONE = 0, INHIBIT_GROUP_CAPTURE_CHAIN, INHIBIT_GROUP_THRUSTER_HOLD, INHIBIT_GROUP_TWO_STEP } inhibit_group_t;

typedef struct { uint16_t opcode; argent_us_t armed_at; uint8_t used; } command_arm_t;

typedef struct {
    uint8_t inhibits;                /* the register, INHIBIT_* bits; starts fully inhibited */
    command_arm_t armed[COMMAND_ARMED_SLOTS];
    argent_us_t arm_window_us;
    uint32_t accepted, rejected, armed_count, hazardous_executed;
    uint32_t by_verdict[COMMAND_VERDICT_COUNT];
    uint16_t last_opcode;
    command_verdict_t last_verdict;
} command_service_t;

void command_init(command_service_t *svc, argent_us_t arm_window_us);
const argent_command_t *command_lookup(uint16_t opcode);
const argent_command_t *command_lookup_mnemonic(const char *mnemonic);
inhibit_group_t command_inhibit_group(const argent_command_t *cmd);
/* The inhibit bits that must be clear for this command to execute (two-step excluded). */
uint8_t command_required_clear(const argent_command_t *cmd);
void command_set_inhibit(command_service_t *svc, uint8_t bit, bool asserted);
/* Validates and, for hazardous commands, arms (first step) or executes (second step). */
command_verdict_t command_process(command_service_t *svc, const argent_command_t *cmd, const double *args, uint8_t arg_count,
                                  uint16_t mode, bool execute_step, argent_us_t now);
const char *command_verdict_name(command_verdict_t v);

#endif
