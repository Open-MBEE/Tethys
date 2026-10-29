/* Self-test of the generated Argent tables: compiles every header under the strict C11 flags
 * and checks the structural invariants the flight software will rely on. Hand-written; not
 * regenerated. Exit status 0 means every check passed. */
#include <stdio.h>
#include <string.h>

#include "argent_commands.h"
#include "argent_enums.h"
#include "argent_events.h"
#include "argent_interfaces.h"
#include "argent_modes.h"
#include "argent_packets.h"
#include "argent_parameters.h"
#include "argent_schedule.h"
#include "argent_state_machines.h"
#include "argent_telemetry.h"

static unsigned failures;

#define CHECK(cond) \
    do { \
        if (!(cond)) { \
            failures++; \
            printf("selftest: FAILED %s (%s:%d)\n", #cond, __FILE__, __LINE__); \
        } \
    } while (0)

static void check_enums(void)
{
    CHECK(ARGENT_TUG_MODE_COUNT == 16);
    CHECK(ARGENT_TUG_MODE_COUNT <= 16); /* every mode fits an argent_mode_mask_t bit */
    CHECK(ARGENT_APPLICATION_NAME_COUNT <= 16);
    CHECK(ARGENT_OPCODE_COUNT == ARGENT_COMMAND_COUNT);
    CHECK(ARGENT_EVENT_ID_COUNT == ARGENT_EVENT_COUNT);
    CHECK(ARGENT_PARAMETER_ID_COUNT == ARGENT_PARAMETER_ROW_COUNT);
    CHECK(strcmp(argent_tug_mode_names[ARGENT_TUG_MODE_SAFE], "safe") == 0);
}

static void check_commands(void)
{
    unsigned i, hazardous = 0;
    for (i = 0; i < ARGENT_COMMAND_COUNT; i++) {
        const argent_command_t *c = &argent_commands[i];
        if (i > 0) {
            CHECK(argent_commands[i - 1].opcode < c->opcode); /* sorted and unique */
        }
        CHECK(c->allowed_modes != 0); /* every command has a mode precondition */
        CHECK(c->first_argument + c->argument_count <= ARGENT_COMMAND_ARGUMENT_COUNT);
        CHECK(c->application < ARGENT_APPLICATION_NAME_COUNT);
        CHECK(!c->hazardous || c->two_step); /* hazardous commands are two-step */
        if (c->hazardous) {
            hazardous++;
        }
        {
            unsigned a, bits = 0;
            for (a = 0; a < c->argument_count; a++) {
                const argent_command_argument_t *arg = &argent_command_arguments[c->first_argument + a];
                CHECK(arg->minimum <= arg->maximum);
                bits += arg->width_bits;
            }
            CHECK(bits == c->argument_bits);
        }
    }
    CHECK(hazardous == ARGENT_HAZARDOUS_COMMAND_COUNT);
}

static void check_telemetry(void)
{
    unsigned i, housekeeping = 0;
    for (i = 0; i < ARGENT_TELEMETRY_POINT_COUNT; i++) {
        const argent_telemetry_point_t *t = &argent_telemetry_points[i];
        if (i > 0) {
            CHECK(argent_telemetry_points[i - 1].id < t->id);
        }
        CHECK(t->source < ARGENT_APPLICATION_NAME_COUNT);
        CHECK(t->first_packet + t->packet_count <= ARGENT_TELEMETRY_PACKET_MEMBERSHIP_COUNT);
        if (t->has_limits) {
            CHECK(t->red_low <= t->yellow_low && t->yellow_low <= t->yellow_high && t->yellow_high <= t->red_high);
        }
        if (t->kind == ARGENT_TELEMETRY_KIND_HOUSEKEEPING) {
            housekeeping++;
        }
    }
    CHECK(housekeeping == ARGENT_HOUSEKEEPING_POINT_COUNT);
    CHECK(ARGENT_MODE_RATE_SET_COUNT == ARGENT_TUG_MODE_COUNT);
    for (i = 0; i < ARGENT_MODE_RATE_SET_COUNT; i++) {
        CHECK(argent_mode_rate_sets[i].mode == (argent_tug_mode_t)i);
        CHECK(argent_mode_rate_sets[i].housekeeping_period_s > 0.0);
    }
}

static void check_events(void)
{
    unsigned i, faults = 0;
    for (i = 0; i < ARGENT_EVENT_COUNT; i++) {
        if (i > 0) {
            CHECK(argent_events[i - 1].id < argent_events[i].id);
        }
        CHECK(argent_events[i].text[0] != '\0');
        if (argent_events[i].fdir_relevant) {
            faults++;
        }
    }
    CHECK(faults == ARGENT_FAULT_EVENT_COUNT);
}

static void check_packets(void)
{
    unsigned i;
    CHECK(ARGENT_PRIMARY_HEADER_VERSION_WIDTH + ARGENT_PRIMARY_HEADER_TYPE_WIDTH + ARGENT_PRIMARY_HEADER_SECONDARY_HEADER_FLAG_WIDTH
          + ARGENT_PRIMARY_HEADER_APID_WIDTH + ARGENT_PRIMARY_HEADER_SEQUENCE_FLAGS_WIDTH + ARGENT_PRIMARY_HEADER_SEQUENCE_COUNT_WIDTH
          + ARGENT_PRIMARY_HEADER_DATA_LENGTH_WIDTH == 48u);
    for (i = 0; i < ARGENT_PACKET_COUNT; i++) {
        const argent_packet_t *p = &argent_packets[i];
        unsigned f, bits = 0;
        unsigned j;
        if (i > 0) {
            CHECK(argent_packets[i - 1].id < p->id);
        }
        for (j = 0; j < i; j++) {
            CHECK(argent_packets[j].apid != p->apid); /* APIDs are unique across the six classes */
        }
        CHECK(p->header_bits == 48u + ARGENT_TIME_CODE_COARSE_WIDTH + ARGENT_TIME_CODE_FINE_WIDTH);
        CHECK(p->first_field + p->field_count <= ARGENT_PACKET_FIELD_COUNT);
        for (f = 0; f < p->field_count; f++) {
            const argent_packet_field_t *fld = &argent_packet_fields[p->first_field + f];
            CHECK(fld->order == f + 1);
            CHECK(fld->offset_bits == p->header_bits + bits);
            CHECK(fld->point_id != 0); /* every field names a dictionary point */
            bits += fld->width_bits;
        }
        CHECK(p->header_bits + bits == p->length_octets * 8u);
    }
}

static void check_parameters(void)
{
    unsigned i;
    for (i = 0; i < ARGENT_PARAMETER_ROW_COUNT; i++) {
        const argent_parameter_t *p = &argent_parameters[i];
        if (i > 0) {
            CHECK(argent_parameters[i - 1].id < p->id);
        }
        CHECK(p->minimum <= p->value && p->value <= p->maximum);
    }
    for (i = 0; i < ARGENT_PARAMETER_TABLE_COUNT; i++) {
        CHECK(argent_parameter_tables[i].first_row + argent_parameter_tables[i].row_count <= ARGENT_PARAMETER_ROW_COUNT);
    }
    CHECK(ARGENT_LIMIT_ROW_COUNT == 6u);
}

static void check_modes(void)
{
    unsigned i;
    CHECK(ARGENT_MODE_ROW_COUNT == ARGENT_TUG_MODE_COUNT);
    for (i = 0; i < ARGENT_MODE_ROW_COUNT; i++) {
        CHECK(argent_mode_table[i].mode == (argent_tug_mode_t)i);
        CHECK(argent_mode_table[i].bus_slots_used <= ARGENT_BUS_FRAME_SLOTS);
    }
    for (i = 0; i < ARGENT_APPLICATION_COUNT; i++) {
        CHECK(argent_applications[i].application == (argent_application_name_t)i);
        CHECK(argent_applications[i].active_modes != 0);
    }
}

static void check_state_machines(void)
{
    unsigned m;
    for (m = 0; m < ARGENT_STATE_MACHINE_COUNT; m++) {
        const argent_state_machine_t *sm = &argent_state_machines[m];
        unsigned i;
        CHECK(sm->state_count > 0);
        for (i = 0; i < sm->state_count; i++) {
            const argent_state_t *s = &sm->states[i];
            CHECK(s->parent == ARGENT_STATE_NONE || (s->parent >= 0 && (unsigned)s->parent < sm->state_count));
            CHECK(s->initial_substate == ARGENT_STATE_NONE || (s->initial_substate >= 0 && (unsigned)s->initial_substate < sm->state_count));
            CHECK(s->leaf || s->initial_substate != ARGENT_STATE_NONE); /* every composite names its initial substate */
        }
        for (i = 0; i < sm->transition_count; i++) {
            const argent_transition_t *t = &sm->transitions[i];
            CHECK(t->source >= 0 && (unsigned)t->source < sm->state_count);
            CHECK(t->target == ARGENT_STATE_DONE || (t->target >= 0 && (unsigned)t->target < sm->state_count));
            CHECK(t->guard == -1 || (unsigned)t->guard < sm->guard_count);
            CHECK(t->effect == -1 || (unsigned)t->effect < sm->effect_count);
            CHECK(t->trigger_kind != ARGENT_TRIGGER_EVENT || t->event[0] != '\0');
            CHECK(t->trigger_kind != ARGENT_TRIGGER_TIMED || t->timed[0] != '\0');
        }
    }
}

static void check_schedule(void)
{
    unsigned i;
    double windows = 0.0;
    CHECK(ARGENT_MINOR_FRAMES_PER_MAJOR_FRAME == 8u);
    for (i = 0; i < ARGENT_PARTITION_COUNT; i++) {
        windows += argent_partitions[i].window_s;
    }
    CHECK(windows == ARGENT_MAJOR_FRAME_PERIOD_S);
    for (i = 0; i < ARGENT_SCHEDULED_TASK_COUNT; i++) {
        const argent_scheduled_task_t *t = &argent_scheduled_tasks[i];
        CHECK(t->rate_group < ARGENT_RATE_GROUP_COUNT);
        CHECK(t->wcet_s <= t->deadline_s && t->deadline_s <= t->period_s);
        CHECK(t->firing_frames != 0);
    }
    for (i = 0; i < ARGENT_PARTITION_SCHEDULE_COUNT; i++) {
        const argent_partition_schedule_t *s = &argent_partition_schedules[i];
        CHECK(s->partition < ARGENT_PARTITION_COUNT);
        CHECK(s->first_task + s->task_count <= ARGENT_SCHEDULED_TASK_COUNT);
        CHECK(s->first_slice + s->slice_count <= ARGENT_FRAME_SLICE_COUNT);
    }
    for (i = 0; i < ARGENT_TUG_MODE_COUNT; i++) {
        CHECK(argent_bus_mode_loads[i].mode == (argent_tug_mode_t)i);
        CHECK(argent_bus_mode_loads[i].slots_used <= ARGENT_BUS_FRAME_SLOTS);
    }
}

static void check_interfaces(void)
{
    unsigned i;
    for (i = 0; i < ARGENT_MESSAGE_COUNT; i++) {
        if (i > 0) {
            CHECK(argent_messages[i - 1].apid < argent_messages[i].apid);
        }
        CHECK(argent_messages[i].length_bytes > 0.0);
    }
    for (i = 0; i < ARGENT_TOPIC_COUNT; i++) {
        CHECK(argent_topics[i].first_end + argent_topics[i].end_count <= ARGENT_TOPIC_END_COUNT);
        CHECK(argent_topics[i].end_count >= 3u);
    }
    for (i = 0; i < ARGENT_REGISTER_MAP_COUNT; i++) {
        const argent_register_map_t *m = &argent_register_maps[i];
        unsigned r;
        for (r = 0; r < m->register_count; r++) {
            const argent_register_t *reg = &argent_registers[m->first_register + r];
            CHECK(reg->address < m->address_limit);
            CHECK(reg->width_bits == m->data_width_bits);
        }
    }
}

int main(void)
{
    check_enums();
    check_commands();
    check_telemetry();
    check_events();
    check_packets();
    check_parameters();
    check_modes();
    check_state_machines();
    check_schedule();
    check_interfaces();
    if (failures != 0) {
        printf("selftest: %u check(s) failed\n", failures);
        return 1;
    }
    printf("selftest: ok (%u commands, %u telemetry points, %u events, %u packets, %u parameters, %u mode rows, %u state machines)\n",
           (unsigned)ARGENT_COMMAND_COUNT, (unsigned)ARGENT_TELEMETRY_POINT_COUNT, (unsigned)ARGENT_EVENT_COUNT,
           (unsigned)ARGENT_PACKET_COUNT, (unsigned)ARGENT_PARAMETER_ROW_COUNT, (unsigned)ARGENT_MODE_ROW_COUNT,
           (unsigned)ARGENT_STATE_MACHINE_COUNT);
    return 0;
}
