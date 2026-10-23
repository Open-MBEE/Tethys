/* argent_host: runs the Argent flight software on the host for N major frames against a scripted
 * stimulus file and writes the per-minor-frame JSONL trace. Exit codes: 0 ok, 1 usage, 2 task
 * overrun, 3 expectation failed, 4 unhandled fault, 5 stimulus error. */
#define _POSIX_C_SOURCE 200809L
#include "apps/apps.h"
#include "apps/system.h"
#include "svc/telemetry.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static bool config_matches(const char *actual, const char *expected);

#define HOST_MAX_STIMULI 512u
#define HOST_TEXT HAL_UPLINK_TEXT

typedef struct {
    double t_s;
    char kind[8];          /* item | cmd | link | fault | expect | rate */
    char name[SM_CONFIG_LEN + 32u];
    char port[24];
    char text[HOST_TEXT];
    double arg[HAL_UPLINK_ARGS];
    uint8_t arg_count;
    uint8_t execute;
} host_stimulus_t;

static host_stimulus_t stimuli[HOST_MAX_STIMULI];
static uint32_t stimulus_count;
static argent_system_t system_instance;

static int parse_stimulus_file(const char *path)
{
    FILE *f = fopen(path, "r");
    char line[256];
    if (f == NULL) { fprintf(stderr, "argent_host: cannot open %s\n", path); return -1; }
    while (fgets(line, sizeof line, f) != NULL) {
        host_stimulus_t *st;
        char *tok, *save = NULL;
        if (line[0] == '#' || line[0] == '\n') continue;
        if (stimulus_count >= HOST_MAX_STIMULI) { fclose(f); return -1; }
        st = &stimuli[stimulus_count];
        memset(st, 0, sizeof(*st));
        tok = strtok_r(line, " \t\r\n", &save);
        if (tok == NULL || strncmp(tok, "t=", 2) != 0) { fclose(f); return -1; }
        st->t_s = atof(tok + 2);
        tok = strtok_r(NULL, " \t\r\n", &save);
        if (tok == NULL) { fclose(f); return -1; }
        snprintf(st->kind, sizeof st->kind, "%s", tok);
        tok = strtok_r(NULL, " \t\r\n", &save);
        if (tok == NULL) { fclose(f); return -1; }
        snprintf(st->name, sizeof st->name, "%s", tok);
        while ((tok = strtok_r(NULL, " \t\r\n", &save)) != NULL) {
            if (strncmp(tok, "port=", 5) == 0) snprintf(st->port, sizeof st->port, "%s", tok + 5);
            else if (strncmp(tok, "item=", 5) == 0 || strncmp(tok, "text=", 5) == 0) snprintf(st->text, sizeof st->text, "%s", tok + 5);
            else if (strcmp(tok, "execute") == 0) st->execute = 1;
            else if (strcmp(st->kind, "expect") == 0) { strncat(st->name, " ", sizeof st->name - strlen(st->name) - 1u); strncat(st->name, tok, sizeof st->name - strlen(st->name) - 1u); }
            else if (st->arg_count < HAL_UPLINK_ARGS) st->arg[st->arg_count++] = atof(tok);
        }
        stimulus_count++;
    }
    fclose(f);
    return 0;
}

static int apply_stimulus(argent_system_t *sys, const host_stimulus_t *st)
{
    if (strcmp(st->kind, "item") == 0 || strcmp(st->kind, "cmd") == 0) {
        hal_uplink_t up;
        memset(&up, 0, sizeof up);
        up.kind = st->kind[0] == 'i' ? 'i' : 'c';
        snprintf(up.name, sizeof up.name, "%.*s", (int)sizeof up.name - 1, st->name);
        snprintf(up.text, sizeof up.text, "%s", up.kind == 'i' ? st->port : st->text);
        memcpy(up.arg, st->arg, sizeof up.arg);
        up.arg_count = st->arg_count;
        up.two_step_execute = st->execute;
        if (!hal_link_uplink_push(&up)) { fprintf(stderr, "argent_host: uplink queue full at t=%g\n", st->t_s); return 5; }
    } else if (strcmp(st->kind, "link") == 0) {
        hal_link_set_available(strcmp(st->name, "up") == 0);
    } else if (strcmp(st->kind, "fault") == 0) {
        if (!event_raise(&sys->events, st->name, hal_timer_now(), st->arg_count > 0 ? st->arg[0] : 0.0)) { fprintf(stderr, "argent_host: unknown event %s\n", st->name); return 5; }
    } else if (strcmp(st->kind, "expect") == 0) {
        char cfg[SM_CONFIG_LEN];
        const char *eq = strchr(st->name, '=');
        int found = 0;
        if (eq == NULL) return 5;
        for (unsigned i = 0; i < SM_INDEX_COUNT; i++) {
            if (strncmp(sys->sm[i].def->name, st->name, (size_t)(eq - st->name)) != 0 || sys->sm[i].def->name[eq - st->name] != '\0') continue;
            found = 1;
            sm_config(&sys->sm[i], cfg, sizeof cfg);
            if (!config_matches(cfg, eq + 1)) {
                fprintf(stderr, "argent_host: t=%g expectation failed: %s is '%s', expected '%s'\n", st->t_s, sys->sm[i].def->name, cfg, eq + 1);
                return 3;
            }
        }
        if (!found) { fprintf(stderr, "argent_host: unknown machine in %s\n", st->name); return 5; }
    } else {
        fprintf(stderr, "argent_host: unknown stimulus kind %s\n", st->kind);
        return 5;
    }
    return 0;
}

/* Region-wise comparison of an active configuration ("a | b | c"); a '*' region in the expectation matches anything. */
static bool config_matches(const char *actual, const char *expected)
{
    while (*actual != '\0' || *expected != '\0') {
        const char *ae = strstr(actual, " | "), *ee = strstr(expected, " | ");
        size_t al = ae != NULL ? (size_t)(ae - actual) : strlen(actual);
        size_t el = ee != NULL ? (size_t)(ee - expected) : strlen(expected);
        if (!(el == 1 && expected[0] == '*') && (al != el || strncmp(actual, expected, al) != 0)) return false;
        if ((ae == NULL) != (ee == NULL)) return false;
        if (ae == NULL) return true;
        actual = ae + 3; expected = ee + 3;
    }
    return true;
}

static argent_us_t next_deadline(const argent_system_t *sys, argent_us_t limit)
{
    argent_us_t next = limit;
    argent_us_t now = hal_timer_now();
    for (unsigned i = 0; i < SM_INDEX_COUNT; i++) {
        argent_us_t d = sm_next_deadline(&sys->sm[i]);
        /* A deadline already in the past belongs to a machine whose task is not scheduled in the current mode; it fires when the task next runs. */
        if (d > now && d < next) next = d;
    }
    return next;
}

/* Golden packets: `value <point> <engineering>` lines set points, `packet <mnemonic> <seq> <coarse> <fine>` builds
 * one packet from them and prints `<mnemonic> <hex>`; the ground fixture is compared by tests/golden_packets.py. */
static int run_golden(const char *path)
{
    static telemetry_service_t svc;
    FILE *f = fopen(path, "r");
    char line[256];
    if (f == NULL) { fprintf(stderr, "argent_host: cannot read %s\n", path); return 1; }
    telemetry_init(&svc, NULL, NULL, NULL, NULL);
    while (fgets(line, sizeof line, f) != NULL) {
        char kind[16], name[64];
        double a = 0, b = 0, c = 0;
        int n = sscanf(line, "%15s %63s %lf %lf %lf", kind, name, &a, &b, &c);
        if (n >= 3 && strcmp(kind, "value") == 0) telemetry_set_value(&svc, name, a);
        else if (n == 5 && strcmp(kind, "packet") == 0) {
            argent_us_t now = (argent_us_t)a * ARGENT_US_PER_S + ((argent_us_t)b * ARGENT_US_PER_S) / 65536u;
            uint16_t len = telemetry_build_golden(&svc, name, (uint16_t)c, now);
            if (len == 0) { fprintf(stderr, "argent_host: unknown packet %s\n", name); fclose(f); return 5; }
            printf("%s ", name);
            for (uint16_t k = 0; k < len; k++) printf("%02x", svc.buffer[k]);
            printf("\n");
            telemetry_init(&svc, NULL, NULL, NULL, NULL);
        }
    }
    fclose(f);
    return 0;
}

int main(int argc, char **argv)
{
    const char *scenario = NULL, *trace_path = NULL;
    uint64_t major_frames = 10, frame;
    int fast_forward = 0, rc = 0;
    uint32_t next_stimulus = 0;
    FILE *trace_out = stdout;
    argent_system_t *sys = &system_instance;
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--scenario") == 0 && i + 1 < argc) scenario = argv[++i];
        else if (strcmp(argv[i], "--major-frames") == 0 && i + 1 < argc) major_frames = strtoull(argv[++i], NULL, 10);
        else if (strcmp(argv[i], "--trace") == 0 && i + 1 < argc) trace_path = argv[++i];
        else if (strcmp(argv[i], "--fast-forward") == 0) fast_forward = 1;
        else if (strcmp(argv[i], "--golden") == 0 && i + 1 < argc) return run_golden(argv[++i]);
        else { fprintf(stderr, "usage: argent_host [--scenario file] [--major-frames N] [--trace out.jsonl] [--fast-forward] | --golden file\n"); return 1; }
    }
    if (scenario != NULL && parse_stimulus_file(scenario) != 0) return 5;
    if (trace_path != NULL) { trace_out = fopen(trace_path, "w"); if (trace_out == NULL) { fprintf(stderr, "argent_host: cannot write %s\n", trace_path); return 1; } }
    system_init(sys, trace_out);
    for (frame = 0; frame < major_frames && rc == 0; frame++) {
        argent_us_t frame_start = hal_timer_now();
        argent_us_t frame_end = frame_start + ARGENT_MAJOR_FRAME_US;
        while (next_stimulus < stimulus_count && argent_s_to_us(stimuli[next_stimulus].t_s) < frame_end) {
            rc = apply_stimulus(sys, &stimuli[next_stimulus++]);
            if (rc != 0) break;
        }
        if (rc != 0) break;
        /* On the launcher the model schedules no task (launch is outside every task's active modes): the
         * umbilical path delivers the stimuli until separation moves the vehicle into early operations. */
        if (sys->mode == (uint16_t)ARGENT_TUG_MODE_LAUNCH) {
            hal_uplink_t up;
            while (hal_link_uplink_pop(&up)) system_post_item(sys, up.name, up.kind == 'i' && up.text[0] != '\0' ? up.text : "command", up.arg, up.arg_count, NULL);
            system_deliver_queued(sys);
            system_tick_machines(sys);
            system_refresh_mode(sys);
        }
        for (unsigned minor = 0; minor < ARGENT_MINOR_FRAMES; minor++) system_run_minor_frame(sys);
        if (sys->exec.task_overruns > 0 || sys->exec.frame_overruns > 0) { fprintf(stderr, "argent_host: task overrun in frame %llu\n", (unsigned long long)frame); rc = 2; }
        if (sys->unhandled_faults > 0) { fprintf(stderr, "argent_host: unhandled fault in frame %llu: %s\n", (unsigned long long)frame, sys->last_fault); rc = 4; }
        if (rc == 0 && fast_forward) system_deliver_queued(sys);
        if (rc == 0 && fast_forward && sys->item_count == 0) {
            /* Idle: jump to the major frame before the next stimulus or machine deadline. */
            argent_us_t limit = argent_s_to_us((double)major_frames) ;
            argent_us_t target = next_stimulus < stimulus_count ? argent_s_to_us(stimuli[next_stimulus].t_s) : limit;
            if (target > limit) target = limit;
            argent_us_t now = hal_timer_now();
            target = next_deadline(sys, target);
            if (target > now + 2u * ARGENT_MAJOR_FRAME_US && target <= limit) {
                uint64_t skip = (target - now) / ARGENT_MAJOR_FRAME_US - 1u;
                trace_skip(&sys->trace, sys->exec.frame_index, sys->exec.frame_index + skip * ARGENT_MINOR_FRAMES, now, now + skip * ARGENT_MAJOR_FRAME_US);
                hal_timer_advance(skip * ARGENT_MAJOR_FRAME_US);
                sys->exec.frame_index += skip * ARGENT_MINOR_FRAMES;
                frame += skip;
            }
        }
    }
    while (rc == 0 && next_stimulus < stimulus_count && strcmp(stimuli[next_stimulus].kind, "expect") == 0) rc = apply_stimulus(sys, &stimuli[next_stimulus++]);
    fprintf(stderr, "argent_host: %llu major frames, t=%.3f s, mode=%s, commands accepted=%u rejected=%u, packets=%llu, events=%u, items dropped=%u, rc=%d\n",
            (unsigned long long)frame, (double)hal_timer_now() / 1.0e6, system_mode_name(sys), sys->commands.accepted, sys->commands.rejected,
            (unsigned long long)sys->telemetry.packets, sys->events.raised, sys->items_dropped, rc);
    if (trace_out != stdout) fclose(trace_out);
    return rc;
}
