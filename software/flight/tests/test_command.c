/* Command service: sorted lookup, argument/mode checks, hazardous two-step and the inhibit register. */
#include "tests/runner.h"
#include "svc/command.h"

static uint16_t first_allowed_mode(const argent_command_t *cmd)
{
    for (uint16_t m = 0; m < ARGENT_TUG_MODE_COUNT; m++) if (cmd->allowed_modes & (argent_mode_mask_t)(1u << m)) return m;
    return 0;
}

static void test_lookup(void)
{
    unsigned hazardous = 0;
    for (unsigned i = 0; i < ARGENT_COMMAND_COUNT; i++) {
        if (i > 0) CHECK(argent_commands[i].opcode > argent_commands[i - 1].opcode);
        CHECK(command_lookup(argent_commands[i].opcode)->opcode == argent_commands[i].opcode);
        CHECK(strcmp(command_lookup_mnemonic(argent_commands[i].mnemonic)->mnemonic, argent_commands[i].mnemonic) == 0);
        if (argent_commands[i].hazardous) hazardous++;
    }
    CHECK(hazardous == ARGENT_HAZARDOUS_COMMAND_COUNT);
    CHECK(command_lookup(0xffffu) == NULL);
    CHECK(command_lookup_mnemonic("NoSuchCommand") == NULL);
}

/* Model 88: the cinch chain holds arm/ground-enable/capture-mode inhibits, SEP and GN&C firing holds the
 * high-voltage hold timer, every other hazardous command is a two-step command whose arm step is the inhibit. */
static void test_every_hazardous_command_is_inhibited(void)
{
    static command_service_t svc;
    double args[16] = { 0 };
    unsigned chain = 0, hold = 0, two_step = 0;
    command_init(&svc, argent_s_to_us(10.0));
    CHECK(svc.inhibits == INHIBIT_ALL);
    for (unsigned i = 0; i < ARGENT_COMMAND_COUNT; i++) {
        const argent_command_t *cmd = &argent_commands[i];
        if (!cmd->hazardous) continue;
        uint16_t mode = first_allowed_mode(cmd);
        inhibit_group_t group = command_inhibit_group(cmd);
        CHECK(group != INHIBIT_GROUP_NONE);
        if (group == INHIBIT_GROUP_TWO_STEP) {
            /* The arm step is the inhibit: an execute step with no arm pending is refused. */
            command_verdict_t run = command_process(&svc, cmd, args, (uint8_t)cmd->argument_count, mode, true, 0);
            two_step++;
            CHECK(cmd->two_step);
            CHECK(run != COMMAND_ACCEPTED && run != COMMAND_ARMED);
            if (cmd->argument_count == 0) CHECK(run == COMMAND_REJECT_NOT_ARMED);
        } else {
            command_verdict_t arm = command_process(&svc, cmd, args, (uint8_t)cmd->argument_count, mode, false, 0);
            command_verdict_t run = command_process(&svc, cmd, args, (uint8_t)cmd->argument_count, mode, true, 0);
            if (group == INHIBIT_GROUP_CAPTURE_CHAIN) chain++; else hold++;
            CHECK(command_required_clear(cmd) != 0);
            CHECK(arm != COMMAND_ARMED && arm != COMMAND_ACCEPTED && run != COMMAND_ACCEPTED);
            /* Argument checks run first, so only argument-less commands reach the inhibit verdict itself. */
            if (cmd->argument_count == 0) CHECK(arm == COMMAND_REJECT_INHIBITED && run == COMMAND_REJECT_INHIBITED);
        }
        CHECK(svc.hazardous_executed == 0);
    }
    CHECK(chain + hold + two_step == ARGENT_HAZARDOUS_COMMAND_COUNT);
    printf("  %u cinch-chain, %u high-voltage-hold, %u two-step hazardous commands refused\n", chain, hold, two_step);
}

static const argent_command_t *find(bool hazardous, bool restricted_modes)
{
    for (unsigned i = 0; i < ARGENT_COMMAND_COUNT; i++) {
        const argent_command_t *cmd = &argent_commands[i];
        if ((cmd->hazardous != 0) == hazardous && cmd->argument_count == 0 &&
            (!restricted_modes || cmd->allowed_modes != 0xffffu)) return cmd;
    }
    return NULL;
}

static void test_arm_execute_once_inhibits_clear(void)
{
    static command_service_t svc;
    const argent_command_t *cmd = find(true, false);
    uint16_t mode;
    command_init(&svc, argent_s_to_us(10.0));
    CHECK(cmd != NULL);
    if (cmd == NULL) return;
    mode = first_allowed_mode(cmd);
    for (uint8_t bit = 0; bit < 4; bit++) command_set_inhibit(&svc, (uint8_t)(1u << bit), false);
    CHECK(svc.inhibits == INHIBIT_TWO_STEP);   /* the two-step bit is only ever cleared per opcode by its arm step */
    CHECK(command_process(&svc, cmd, NULL, 0, mode, true, 0) == COMMAND_REJECT_NOT_ARMED);
    CHECK(command_process(&svc, cmd, NULL, 0, mode, false, 0) == COMMAND_ARMED);
    CHECK(command_process(&svc, cmd, NULL, 0, mode, true, argent_s_to_us(1.0)) == COMMAND_ACCEPTED);
    CHECK(svc.hazardous_executed == 1);
    CHECK(command_process(&svc, cmd, NULL, 0, mode, false, argent_s_to_us(2.0)) == COMMAND_ARMED);
    CHECK(command_process(&svc, cmd, NULL, 0, mode, true, argent_s_to_us(13.0)) == COMMAND_REJECT_ARM_EXPIRED);
    CHECK(svc.hazardous_executed == 1);
    if (command_required_clear(cmd) != 0) {
        command_set_inhibit(&svc, command_required_clear(cmd), true);   /* one inhibit back: independent of the arm */
        CHECK(command_process(&svc, cmd, NULL, 0, mode, false, argent_s_to_us(14.0)) == COMMAND_REJECT_INHIBITED);
    }
}

static void test_mode_and_argument_checks(void)
{
    static command_service_t svc;
    const argent_command_t *cmd = find(false, true);
    double arg = 0;
    command_init(&svc, argent_s_to_us(10.0));
    CHECK(cmd != NULL);
    if (cmd == NULL) return;
    for (uint16_t m = 0; m < ARGENT_TUG_MODE_COUNT; m++) {
        command_verdict_t v = command_process(&svc, cmd, NULL, 0, m, true, 0);
        CHECK(v == ((cmd->allowed_modes & (argent_mode_mask_t)(1u << m)) ? COMMAND_ACCEPTED : COMMAND_REJECT_MODE));
    }
    CHECK(command_process(&svc, cmd, &arg, 1, first_allowed_mode(cmd), true, 0) == COMMAND_REJECT_ARGUMENT_COUNT);
    CHECK(strcmp(command_verdict_name(COMMAND_REJECT_MODE), "") != 0);
}

const test_case_t command_tests[] = {
    { "command: 344 opcodes sorted and found by binary search", "model 64 dictionary", test_lookup },
    { "command: all 51 hazardous commands refused while their inhibits are set", "model 88 inhibit register", test_every_hazardous_command_is_inhibited },
    { "command: hazardous arm/execute once the inhibits are clear, arm window expires", "model 88 two-step", test_arm_execute_once_inhibits_clear },
    { "command: allowed-mode mask and argument count", "model 64 allowedModes", test_mode_and_argument_checks },
};
const unsigned command_test_count = sizeof command_tests / sizeof command_tests[0];
