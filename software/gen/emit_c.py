"""C11 emitter: one header per table, ``static const`` data only."""

from __future__ import annotations

from emit_common import c_bool, c_header, c_num, c_str, mode_mask, upper

ENUM_SOURCES = {
    "TugMode": "TethysTugStructure::TugMode", "InspectorMode": "TethysModes::InspectorModes",
}


def guard(name):
    return f"ARGENT_{upper(name)}_H"


def enum_block(enum, lits, values=None):
    tag = f"argent_{upper(enum).lower()}_t"
    lines = ["typedef enum {"]
    for i, l in enumerate(lits):
        v = values[l] if values else i
        lines.append(f"    ARGENT_{upper(enum)}_{upper(l)} = {v},")
    if not values:
        lines.append(f"    ARGENT_{upper(enum)}_COUNT = {len(lits)}")
    else:
        lines[-1] = lines[-1].rstrip(",")
    lines.append(f"}} {tag};")
    lines.append(f"#define ARGENT_{upper(enum)}_LITERAL_COUNT {len(lits)}")
    return "\n".join(lines) + "\n"


def names_array(enum, lits):
    return (f"static const char *const argent_{upper(enum).lower()}_names[{len(lits)}] = {{\n"
            + "".join(f"    {c_str(l)},\n" for l in lits) + "};\n")


def file(name, pin, sources, includes, body):
    g = guard(name)
    inc = "".join(f"#include {i}\n" for i in includes)
    return f"{c_header(pin, sources)}#ifndef {g}\n#define {g}\n\n{inc}\n{body}\n#endif /* {g} */\n"


def emit(data: dict, pin: dict) -> dict[str, str]:
    modes = data["enums"]["TugMode"]["literals"]
    apps = data["enums"]["ApplicationName"]["literals"]
    out = {}

    # -- enums ------------------------------------------------------------------------------------
    body = ["#define ARGENT_MODE_BIT(m) ((argent_mode_mask_t)1u << (m))",
            "typedef uint16_t argent_mode_mask_t;",
            "typedef uint16_t argent_application_mask_t;", ""]
    sources = []
    for enum, info in data["enums"].items():
        sources.append(info["source"])
        if enum in ("Opcode", "EventId", "ParameterId"):
            continue
        body.append(enum_block(enum, info["literals"]))
        body.append(names_array(enum, info["literals"]))
    op = data["enums"]["Opcode"]
    body.append(enum_block("Opcode", op["literals"], op["values"]))
    body.append(f"#define ARGENT_OPCODE_COUNT {len(op['literals'])}\n")
    for enum, prefix in (("EventId", "ARGENT_EVENT"), ("ParameterId", "ARGENT_PARAMETER")):
        info = data["enums"][enum]
        body.append("".join(f"#define {prefix}_{upper(l)} {info['values'][l]}\n" for l in info["literals"]))
        body.append(f"#define {prefix}_ID_COUNT {len(info['literals'])}\n")
    out["argent_enums.h"] = file("enums", pin, sources, ["<stdint.h>"], "\n".join(body))

    # -- commands -----------------------------------------------------------------------------------
    cmds = data["commands"]
    args = []
    rows = []
    for c in cmds:
        first = len(args)
        for a in c["arguments"]:
            args.append(f"    {{ {c_str(a['name'])}, {c_str(a['type'])}, {c_num(a['minimum'])}, {c_num(a['maximum'])}, "
                        f"{a['width_bits']}u, {c_str(a['unit'])} }},")
        rows.append(f"    {{ ARGENT_OPCODE_{upper(c['mnemonic'])}, {c_str(c['mnemonic'])}, ARGENT_APPLICATION_NAME_{upper(c['application'])}, "
                    f"{c['apid']}u, ARGENT_APID_CLASS_{upper(c['apid_class'])}, ARGENT_COMMAND_CRITICALITY_{upper(c['criticality'])}, "
                    f"{c_bool(c['hazardous'])}, {c_bool(c['two_step'])}, 0x{mode_mask(c['allowed_modes'], modes):04x}u, "
                    f"{c['argument_bits']}u, {first}u, {len(c['arguments'])}u }},")
    body = f"""typedef struct {{
    const char *name;
    const char *value_type;
    double minimum;
    double maximum;
    uint16_t width_bits;
    const char *unit;
}} argent_command_argument_t;

typedef struct {{
    uint16_t opcode;
    const char *mnemonic;
    argent_application_name_t application;
    uint16_t apid;
    argent_apid_class_t apid_class;
    argent_command_criticality_t criticality;
    uint8_t hazardous;
    uint8_t two_step;
    argent_mode_mask_t allowed_modes;
    uint16_t argument_bits;
    uint16_t first_argument;
    uint16_t argument_count;
}} argent_command_t;

#define ARGENT_COMMAND_COUNT {len(cmds)}u
#define ARGENT_COMMAND_ARGUMENT_COUNT {len(args)}u
#define ARGENT_HAZARDOUS_COMMAND_COUNT {sum(1 for c in cmds if c['hazardous'])}u

static const argent_command_argument_t argent_command_arguments[{max(len(args), 1)}] = {{
{chr(10).join(args) if args else "    { 0, 0, 0.0, 0.0, 0u, 0 },"}
}};

static const argent_command_t argent_commands[{len(cmds)}] = {{
{chr(10).join(rows)}
}};
"""
    out["argent_commands.h"] = file("commands", pin, ["TethysFlightDictionary::flightDictionary::commands",
                                    "TethysFlightDictionary::CommandDefinition", "TethysFlightDictionary::CommandArgument",
                                    "TethysFlightSoftware::ArgentFlightSoftware", "TethysTugStructure::TugMode"],
                                    ["<stdint.h>", "\"argent_enums.h\""], body)

    # -- telemetry -------------------------------------------------------------------------------------
    tms = data["telemetry"]
    pk_index = {p["mnemonic"]: i for i, p in enumerate(data["packets"])}
    members, rows = [], []
    for t in tms:
        first = len(members)
        for pk in t["packets"]:
            members.append(f"    {pk_index[pk]}u,")
        has = t["red_low"] is not None
        rows.append(f"    {{ {t['id']}u, {c_str(t['mnemonic'])}, {c_str(t['point_type'])}, ARGENT_TELEMETRY_KIND_{upper(t['kind'])}, "
                    f"ARGENT_APPLICATION_NAME_{upper(t['source'])}, ARGENT_APID_CLASS_{upper(t['apid_class'])}, {c_num(t['rate_hz'])}, "
                    f"{t['width_bits']}u, {c_str(t['unit'])}, {c_str(t['value_type'])}, {c_bool(has)}, {c_num(t['red_low'])}, "
                    f"{c_num(t['yellow_low'])}, {c_num(t['yellow_high'])}, {c_num(t['red_high'])}, {first}u, {len(t['packets'])}u }},")
    rs = data["rate_sets"]
    rs_rows = [f"    {{ ARGENT_TUG_MODE_{upper(r['mode'])}, {c_str(r['name'])}, {c_num(r['downlink_bit_s'])}, {c_num(r['uplink_bit_s'])}, "
               f"{c_num(r['housekeeping_period_s'])} }}," for r in sorted(rs, key=lambda r: modes.index(r["mode"]))]
    body = f"""typedef struct {{
    uint16_t id;
    const char *mnemonic;
    const char *point_type;
    argent_telemetry_kind_t kind;
    argent_application_name_t source;
    argent_apid_class_t apid_class;
    double rate_hz;
    uint16_t width_bits;
    const char *unit;
    const char *value_type;
    uint8_t has_limits;
    double red_low;
    double yellow_low;
    double yellow_high;
    double red_high;
    uint16_t first_packet;
    uint16_t packet_count;
}} argent_telemetry_point_t;

typedef struct {{
    argent_tug_mode_t mode;
    const char *rate_set;
    double downlink_bit_s;
    double uplink_bit_s;
    double housekeeping_period_s;
}} argent_mode_rate_set_t;

#define ARGENT_TELEMETRY_POINT_COUNT {len(tms)}u
#define ARGENT_TELEMETRY_PACKET_MEMBERSHIP_COUNT {len(members)}u
#define ARGENT_HOUSEKEEPING_POINT_COUNT {sum(1 for t in tms if t['kind'] == 'housekeeping')}u
#define ARGENT_MODE_RATE_SET_COUNT {len(rs_rows)}u

static const uint16_t argent_telemetry_packet_membership[{max(len(members), 1)}] = {{
{chr(10).join(members)}
}};

static const argent_telemetry_point_t argent_telemetry_points[{len(tms)}] = {{
{chr(10).join(rows)}
}};

static const argent_mode_rate_set_t argent_mode_rate_sets[{len(rs_rows)}] = {{
{chr(10).join(rs_rows)}
}};
"""
    out["argent_telemetry.h"] = file("telemetry", pin, ["TethysFlightDictionary::flightDictionary::telemetryPoints",
                                     "TethysFlightDictionary::TelemetryPointDefinition", "TethysFlightDictionary::flightDictionary::packets",
                                     "TethysSoftwareIcds::SpaceLinkProfileIcd (LinkRateSet rows)"],
                                     ["<stdint.h>", "\"argent_enums.h\""], body)

    # -- events --------------------------------------------------------------------------------------------
    evs = data["events"]
    rows = [f"    {{ {e['id']}u, {c_str(e['mnemonic'])}, ARGENT_APPLICATION_NAME_{upper(e['source'])}, ARGENT_EVENT_SEVERITY_{upper(e['severity'])}, "
            f"{c_str(e['text'])}, {c_bool(e['fdir_relevant'])}, {c_bool(e['is_fault'])}, ARGENT_FDIR_LEVEL_{upper(e['level'])} }}," for e in evs]
    body = f"""typedef struct {{
    uint16_t id;
    const char *mnemonic;
    argent_application_name_t source;
    argent_event_severity_t severity;
    const char *text;
    uint8_t fdir_relevant;
    uint8_t is_fault;
    argent_fdir_level_t level;
}} argent_event_t;

#define ARGENT_EVENT_COUNT {len(evs)}u
#define ARGENT_FAULT_EVENT_COUNT {sum(1 for e in evs if e['fdir_relevant'])}u

static const argent_event_t argent_events[{len(evs)}] = {{
{chr(10).join(rows)}
}};
"""
    out["argent_events.h"] = file("events", pin, ["TethysFlightDictionary::flightDictionary::events",
                                  "TethysFlightDictionary::EventDefinition", "TethysFdir::FdirLevel"],
                                  ["<stdint.h>", "\"argent_enums.h\""], body)

    # -- packets --------------------------------------------------------------------------------------------
    pks = data["packets"]
    tm_index = {t["mnemonic"]: t["id"] for t in tms}
    fields, rows = [], []
    for p in pks:
        first = len(fields)
        for f in p["fields"]:
            fields.append(f"    {{ {f['order']}u, {f['offset_bits']}u, {f['width_bits']}u, {c_str(f['point'])}, {tm_index.get(f['point'], 0)}u }},")
        rows.append(f"    {{ {p['id']}u, {c_str(p['mnemonic'])}, {p['apid']}u, ARGENT_APID_CLASS_{upper(p['apid_class'])}, "
                    f"ARGENT_APPLICATION_NAME_{upper(p['source'])}, {c_num(p['rate_hz'])}, {p['header_bits']}u, {p['length_octets']}u, "
                    f"{first}u, {len(p['fields'])}u }},")
    defs = "".join(f"#define ARGENT_PRIMARY_HEADER_{upper(r['name'])} {r['value']}u\n" for r in data["primary_header"]["rows"])
    for r in data["time_code"]["rows"]:
        v = r["value"]
        defs += f"#define ARGENT_TIME_CODE_{upper(r['name'])} " + (c_str(v) if isinstance(v, str) else (f"{v}u" if isinstance(v, int) else c_num(v))) + "\n"
    defs += "".join(f"#define ARGENT_APID_BASE_{upper(a['name'])} {a['base_apid']}u\n" for a in data["apid_classes"])
    body = f"""{defs}
typedef struct {{
    uint16_t order;
    uint16_t offset_bits;
    uint16_t width_bits;
    const char *point;
    uint16_t point_id;
}} argent_packet_field_t;

typedef struct {{
    uint16_t id;
    const char *mnemonic;
    uint16_t apid;
    argent_apid_class_t apid_class;
    argent_application_name_t source;
    double rate_hz;
    uint16_t header_bits;
    uint16_t length_octets;
    uint16_t first_field;
    uint16_t field_count;
}} argent_packet_t;

#define ARGENT_PACKET_COUNT {len(pks)}u
#define ARGENT_PACKET_FIELD_COUNT {len(fields)}u

static const argent_packet_field_t argent_packet_fields[{len(fields)}] = {{
{chr(10).join(fields)}
}};

static const argent_packet_t argent_packets[{len(pks)}] = {{
{chr(10).join(rows)}
}};
"""
    out["argent_packets.h"] = file("packets", pin, ["TethysFlightDictionary::flightDictionary::packets", "TethysFlightDictionary::PacketDefinition",
                                   "TethysFlightDictionary::PacketField", "TethysFlightDictionary::PrimaryHeaderLayout",
                                   "TethysFlightDictionary::TethysTimeCode", "TethysFlightDictionary::flightApids", "TethysOperations::ApidClass"],
                                   ["<stdint.h>", "\"argent_enums.h\""], body)

    # -- parameters and limits ---------------------------------------------------------------------------------
    prow, ptab = [], []
    for t in data["parameter_tables"]:
        first = len(prow)
        for r in t["rows"]:
            prow.append(f"    {{ {r['id']}u, {c_str(r['name'])}, ARGENT_APPLICATION_NAME_{upper(r['owner'])}, {t['table_id']}u, "
                        f"{c_num(r['value'])}, {c_num(r['minimum'])}, {c_num(r['maximum'])}, {c_str(r['unit'])} }},")
        ptab.append(f"    {{ {t['table_id']}u, ARGENT_APPLICATION_NAME_{upper(t['owner'])}, {first}u, {len(t['rows'])}u }},")
    lim = data["limit_table"]
    lrows = [f"    {{ {c_str(r['name'])}, {c_num(r['value'])}, {c_str(r['unit'])} }}," for r in lim["rows"]]
    mrows = [f"    {{ {c_str(r['set'])}, {c_str(r['name'])}, {c_num(r['value'])}, {c_str(r['unit'])} }}," for r in data["monitor_limits"]]
    frows = [f"    {{ {c_str(f['name'])}, {c_str(f['level'] or '')} }}," for f in data["fault_events"]]
    body = f"""typedef struct {{
    uint16_t id;
    const char *name;
    argent_application_name_t owner;
    uint16_t table_id;
    double value;
    double minimum;
    double maximum;
    const char *unit;
}} argent_parameter_t;

typedef struct {{
    uint16_t table_id;
    argent_application_name_t owner;
    uint16_t first_row;
    uint16_t row_count;
}} argent_parameter_table_t;

typedef struct {{
    const char *name;
    double value;
    const char *unit;
}} argent_limit_t;

typedef struct {{
    const char *limit_set;
    const char *name;
    double value;
    const char *unit;
}} argent_monitor_limit_t;

typedef struct {{
    const char *name;
    const char *level;
}} argent_fault_event_t;

#define ARGENT_PARAMETER_TABLE_COUNT {len(ptab)}u
#define ARGENT_PARAMETER_ROW_COUNT {len(prow)}u
#define ARGENT_LIMIT_TABLE_ID {lim['table_id']}u
#define ARGENT_LIMIT_ROW_COUNT {len(lrows)}u
#define ARGENT_MONITOR_LIMIT_COUNT {len(mrows)}u
#define ARGENT_FAULT_EVENT_TYPE_COUNT {len(frows)}u

static const argent_parameter_t argent_parameters[{len(prow)}] = {{
{chr(10).join(prow)}
}};

static const argent_parameter_table_t argent_parameter_tables[{len(ptab)}] = {{
{chr(10).join(ptab)}
}};

static const argent_limit_t argent_limit_table[{len(lrows)}] = {{
{chr(10).join(lrows)}
}};

static const argent_monitor_limit_t argent_monitor_limits[{len(mrows)}] = {{
{chr(10).join(mrows)}
}};

static const argent_fault_event_t argent_fault_event_types[{len(frows)}] = {{
{chr(10).join(frows)}
}};
"""
    out["argent_parameters.h"] = file("parameters", pin, ["TethysFlightDictionary::flightDictionary::parameterTables",
                                      "TethysFlightDictionary::FlightParameterTable", "TethysFlightDictionary::ParameterRow",
                                      "TethysFlightDictionary::flightLimitTable", "TethysFlightDictionary::tableLimits",
                                      "TethysFdir::cruiseLimits", "TethysFdir::FaultEvent", "TethysFdir::FaultResponse"],
                                      ["<stdint.h>", "\"argent_enums.h\""], body)

    # -- modes ---------------------------------------------------------------------------------------------------
    flag_names = sorted({k for r in data["mode_table"] for k in r["flags"]})
    bus_by_mode = {b["mode"]: b for b in data["bus_schedule"]["per_mode"]}
    rs_by_mode = {r["mode"]: i for i, r in enumerate(sorted(rs, key=lambda r: modes.index(r["mode"])))}
    rows = []
    for r in data["mode_table"]:
        flags = sum(1 << i for i, f in enumerate(flag_names) if r["flags"].get(f))
        amask = sum(1 << apps.index(a) for a in r["active_applications"] if a in apps)
        rows.append(f"    {{ ARGENT_TUG_MODE_{upper(r['mode'])}, {c_str(r['mode'])}, 0x{flags:04x}u, 0x{amask:04x}u, "
                    f"{rs_by_mode.get(r['mode'], 0)}u, {bus_by_mode[r['mode']]['slots_used']}u }},")
    arows = [f"    {{ ARGENT_APPLICATION_NAME_{upper(a['name'])}, {c_str(a['name'])}, {c_str(a['definition'])}, {c_num(a['rate_hz'])}, {a['priority']}u, "
             f"ARGENT_SOFTWARE_LAYER_{upper(a['layer'])}, ARGENT_SOFTWARE_CRITICALITY_{upper(a['criticality'])}, 0x{mode_mask(a['active_modes'], modes):04x}u }},"
             for a in data["applications"]]
    body = f"""{"".join(f"#define ARGENT_MODE_FLAG_{upper(f)} ((uint16_t)1u << {i})" + chr(10) for i, f in enumerate(flag_names))}
typedef struct {{
    argent_tug_mode_t mode;
    const char *name;
    uint16_t configuration_flags;
    argent_application_mask_t active_applications;
    uint16_t rate_set;
    uint16_t bus_slots_used;
}} argent_mode_row_t;

typedef struct {{
    argent_application_name_t application;
    const char *name;
    const char *definition;
    double rate_hz;
    uint16_t priority;
    argent_software_layer_t layer;
    argent_software_criticality_t criticality;
    argent_mode_mask_t active_modes;
}} argent_application_t;

#define ARGENT_MODE_ROW_COUNT {len(rows)}u
#define ARGENT_MODE_FLAG_COUNT {len(flag_names)}u
#define ARGENT_APPLICATION_COUNT {len(arows)}u

static const char *const argent_mode_flag_names[{len(flag_names)}] = {{
{chr(10).join(f"    {c_str(f)}," for f in flag_names)}
}};

static const argent_mode_row_t argent_mode_table[{len(rows)}] = {{
{chr(10).join(rows)}
}};

static const argent_application_t argent_applications[{len(arows)}] = {{
{chr(10).join(arows)}
}};
"""
    out["argent_modes.h"] = file("modes", pin, ["TethysModes::TugModeTable", "TethysModes::SubsystemConfiguration",
                                 "TethysFlightSoftware::ArgentFlightSoftware (Application parts)", "TethysFlightSoftware::Application::activeModes",
                                 "TethysSoftwareIcds::SpaceLinkProfileIcd (LinkRateSet rows)", "TethysFlightTiming::argentBus"],
                                 ["<stdint.h>", "\"argent_enums.h\""], body)

    # -- state machines ---------------------------------------------------------------------------------------------
    sm_body = ["""typedef enum {
    ARGENT_TRIGGER_NONE = 0,
    ARGENT_TRIGGER_EVENT = 1,
    ARGENT_TRIGGER_TIMED = 2
} argent_trigger_kind_t;

typedef struct {
    const char *name;
    const char *qualified_name;
    int16_t parent;
    int16_t initial_substate;
    uint8_t leaf;
    const char *entry_action;
    const char *exit_action;
} argent_state_t;

typedef struct {
    int16_t source;
    int16_t target;
    argent_trigger_kind_t trigger_kind;
    const char *event;
    const char *port;
    const char *timed;
    int16_t guard;
    int16_t effect;
} argent_transition_t;

typedef struct {
    const char *id;
    const char *text;
} argent_named_expression_t;

typedef struct {
    const char *name;
    const char *source;
    int16_t initial_state;
    const argent_state_t *states;
    uint16_t state_count;
    const argent_transition_t *transitions;
    uint16_t transition_count;
    const argent_named_expression_t *guards;
    uint16_t guard_count;
    const argent_named_expression_t *effects;
    uint16_t effect_count;
} argent_state_machine_t;

#define ARGENT_STATE_DONE (-2)
#define ARGENT_STATE_NONE (-1)
"""]
    machines = data["machines"]
    sources = []
    for m in machines:
        sources.append(m["source"])
        mn = upper(m["name"]).lower()
        sid = {s["id"]: i for i, s in enumerate(m["states"])}
        gid = {g["id"]: i for i, g in enumerate(m["guards"])}
        eid = {e["id"]: i for i, e in enumerate(m["effects"])}

        def st(ref):
            if ref is None:
                return "ARGENT_STATE_NONE"
            if ref == "done":
                return "ARGENT_STATE_DONE"
            return str(sid[ref])
        srows = []
        for s in m["states"]:
            entry = "; ".join(t for k, t in s["actions"] if k == "entry")
            exit_ = "; ".join(t for k, t in s["actions"] if k == "exit")
            srows.append(f"    {{ {c_str(s['name'])}, {c_str(s['id'])}, {st(s['parent'])}, {st(s['initial'])}, {c_bool(s['leaf'])}, {c_str(entry)}, {c_str(exit_)} }},")
        trows = []
        for t in m["transitions"]:
            tr = t["trigger"]
            kind = "ARGENT_TRIGGER_EVENT" if tr["event"] else ("ARGENT_TRIGGER_TIMED" if tr["timed"] else "ARGENT_TRIGGER_NONE")
            trows.append(f"    {{ {st(t['source'])}, {st(t['target'])}, {kind}, {c_str(tr['event'] or '')}, {c_str(tr['port'] or '')}, "
                         f"{c_str(tr['timed'] or '')}, {gid[t['guard']] if t['guard'] else -1}, {eid[t['effect']] if t['effect'] else -1} }},")
        sm_body.append(f"""
/* {m['source']} */
typedef enum {{
{chr(10).join(f"    ARGENT_{upper(m['name'])}_STATE_{upper(s['name'])}{'_' + str(i) if [x['name'] for x in m['states']].count(s['name']) > 1 else ''} = {i}," for i, s in enumerate(m['states']))}
    ARGENT_{upper(m['name'])}_STATE_COUNT = {len(m['states'])}
}} argent_{mn}_state_t;

#define ARGENT_{upper(m['name'])}_TRANSITION_COUNT {len(m['transitions'])}u

static const argent_state_t argent_{mn}_states[{len(m['states'])}] = {{
{chr(10).join(srows)}
}};

static const argent_transition_t argent_{mn}_transitions[{len(m['transitions'])}] = {{
{chr(10).join(trows)}
}};

static const argent_named_expression_t argent_{mn}_guards[{max(len(m['guards']), 1)}] = {{
{chr(10).join(f"    {{ {c_str(g['id'])}, {c_str(g['text'])} }}," for g in m['guards']) or "    { 0, 0 },"}
}};

static const argent_named_expression_t argent_{mn}_effects[{max(len(m['effects']), 1)}] = {{
{chr(10).join(f"    {{ {c_str(e['id'])}, {c_str(e['text'])} }}," for e in m['effects']) or "    { 0, 0 },"}
}};
""")
    sm_body.append(f"""
#define ARGENT_STATE_MACHINE_COUNT {len(machines)}u

static const argent_state_machine_t argent_state_machines[{len(machines)}] = {{
{chr(10).join(f"    {{ {c_str(m['name'])}, {c_str(m['source'])}, {('ARGENT_STATE_NONE' if m['initial'] is None else str({s['id']: i for i, s in enumerate(m['states'])}[m['initial']]))}, argent_{upper(m['name']).lower()}_states, {len(m['states'])}u, argent_{upper(m['name']).lower()}_transitions, {len(m['transitions'])}u, argent_{upper(m['name']).lower()}_guards, {len(m['guards'])}u, argent_{upper(m['name']).lower()}_effects, {len(m['effects'])}u }}," for m in machines)}
}};
""")
    out["argent_state_machines.h"] = file("state_machines", pin, sources, ["<stdint.h>"], "\n".join(sm_body))

    # -- schedule ----------------------------------------------------------------------------------------------------------
    sch = data["schedule"]
    rg_rows = [f"    {{ {c_str(r['name'])}, {c_num(r['rate_hz'])}, {c_num(r['period_s'])}, {r['activations_per_major_frame']}u }}," for r in sch["rate_groups"]]
    rg_index = {r["name"]: i for i, r in enumerate(sch["rate_groups"])}
    part_rows = [f"    {{ {c_str(p['name'])}, {c_num(p['window_s'])}, {c_num(p['memory_bytes'])}, ARGENT_SOFTWARE_CRITICALITY_{upper(p['criticality'])}, {c_bool(p['restartable'])} }},"
                 for p in sch["partitions"]]
    part_index = {p["name"]: i for i, p in enumerate(sch["partitions"])}
    slices, tasks, scheds = [], [], []
    for s in sch["partition_schedules"]:
        sf, tf = len(slices), len(tasks)
        for sl in s["slices"]:
            slices.append(f"    {{ {c_str(sl['name'])}, {c_num(sl['duration_s'])} }},")
        for t in s["tasks"]:
            frames = sum(1 << f for f in t["firing_frames"])
            tasks.append(f"    {{ {c_str(t['name'])}, {c_str(t['kind'])}, {c_str(t['component'])}, {rg_index.get(t['rate_group'], 0)}u, {c_num(t['wcet_s'])}, "
                         f"{c_num(t['period_s'])}, {c_num(t['deadline_s'])}, 0x{frames:02x}u, 0x{mode_mask(t['active_modes'], modes):04x}u }},")
        scheds.append(f"    {{ {c_str(s['name'])}, {part_index.get(s['partition'].rsplit('.', 1)[-1], 0)}u, {sf}u, {len(s['slices'])}u, {tf}u, {len(s['tasks'])}u }},")
    bus = data["bus_schedule"]
    streams = [f"    {{ {c_str(s['name'])}, {c_str(s['node'])}, {s['slots_per_frame']}u, {c_num(s['message_length_bytes'])}, 0x{mode_mask(s['active_modes'], modes):04x}u }},"
               for s in bus["streams"]]
    per_mode = [f"    {{ ARGENT_TUG_MODE_{upper(p['mode'])}, {p['slots_used']}u, {c_num(p['bytes_per_frame'])} }}," for p in bus["per_mode"]]
    body = f"""#define ARGENT_MINOR_FRAME_PERIOD_S {c_num(sch['minor_frame_period_s'])}
#define ARGENT_MAJOR_FRAME_PERIOD_S {c_num(sch['major_frame_period_s'])}
#define ARGENT_MINOR_FRAMES_PER_MAJOR_FRAME {sch['minor_frames_per_major_frame']}u
#define ARGENT_BUS_FRAME_SLOTS {bus['frame_slots']}u
#define ARGENT_BUS_FRAME_PERIOD_S {c_num(bus['frame_period_s'])}
#define ARGENT_BUS_SLOT_LENGTH_BYTES {c_num(bus['slot_length_bytes'])}

typedef struct {{
    const char *name;
    double rate_hz;
    double period_s;
    uint16_t activations_per_major_frame;
}} argent_rate_group_t;

typedef struct {{
    const char *name;
    double window_s;
    double memory_bytes;
    argent_software_criticality_t criticality;
    uint8_t restartable;
}} argent_partition_t;

typedef struct {{
    const char *name;
    double duration_s;
}} argent_frame_slice_t;

typedef struct {{
    const char *name;
    const char *kind;
    const char *component;
    uint16_t rate_group;
    double wcet_s;
    double period_s;
    double deadline_s;
    uint8_t firing_frames;
    argent_mode_mask_t active_modes;
}} argent_scheduled_task_t;

typedef struct {{
    const char *name;
    uint16_t partition;
    uint16_t first_slice;
    uint16_t slice_count;
    uint16_t first_task;
    uint16_t task_count;
}} argent_partition_schedule_t;

typedef struct {{
    const char *name;
    const char *node;
    uint16_t slots_per_frame;
    double message_length_bytes;
    argent_mode_mask_t active_modes;
}} argent_bus_stream_t;

typedef struct {{
    argent_tug_mode_t mode;
    uint16_t slots_used;
    double bytes_per_frame;
}} argent_bus_mode_load_t;

#define ARGENT_RATE_GROUP_COUNT {len(rg_rows)}u
#define ARGENT_PARTITION_COUNT {len(part_rows)}u
#define ARGENT_FRAME_SLICE_COUNT {len(slices)}u
#define ARGENT_SCHEDULED_TASK_COUNT {len(tasks)}u
#define ARGENT_PARTITION_SCHEDULE_COUNT {len(scheds)}u
#define ARGENT_BUS_STREAM_COUNT {len(streams)}u

static const argent_rate_group_t argent_rate_groups[{len(rg_rows)}] = {{
{chr(10).join(rg_rows)}
}};

static const argent_partition_t argent_partitions[{len(part_rows)}] = {{
{chr(10).join(part_rows)}
}};

static const argent_frame_slice_t argent_frame_slices[{len(slices)}] = {{
{chr(10).join(slices)}
}};

static const argent_scheduled_task_t argent_scheduled_tasks[{len(tasks)}] = {{
{chr(10).join(tasks)}
}};

static const argent_partition_schedule_t argent_partition_schedules[{len(scheds)}] = {{
{chr(10).join(scheds)}
}};

static const argent_bus_stream_t argent_bus_streams[{len(streams)}] = {{
{chr(10).join(streams)}
}};

static const argent_bus_mode_load_t argent_bus_mode_loads[{len(per_mode)}] = {{
{chr(10).join(per_mode)}
}};
"""
    out["argent_schedule.h"] = file("schedule", pin, ["TethysFlightTiming::FlightTiming (rate groups, frame periods)", "TethysFlightTiming::argentTiming",
                                    "TethysFlightTiming::PartitionSchedule", "TethysFlightTiming::ScheduledTask", "TethysFlightTiming::ApplicationTask",
                                    "TethysFlightSoftware::ArgentFlightSoftware::executive", "TethysFlightTiming::argentBus", "TethysFlightTiming::BusSlotAssignment"],
                                    ["<stdint.h>", "\"argent_enums.h\""], body)

    # -- interfaces -----------------------------------------------------------------------------------------------------------------
    msgs = [f"    {{ {c_str(m['name'])}, {c_str(m['type'])}, {m['apid']}u, {c_num(m['length_bytes'])}, {c_num(m['period_s'])} }}," for m in data["messages"]]
    ends, topics = [], []
    for t in data["topics"]:
        first = len(ends)
        for e in t["ends"]:
            ends.append(f"    {{ {c_str(e['end'])}, {c_str(e['feature'])} }},")
        topics.append(f"    {{ {c_str(t['name'])}, {c_str(t['kind'])}, {c_str(t['payload'])}, {first}u, {len(t['ends'])}u }},")
    params = []
    for key in ("bus_protocol", "space_link", "relay_profile"):
        for r in data[key]["rows"]:
            v = r["value"]
            params.append(f"    {{ {c_str(data[key]['source'].rsplit('::', 1)[-1])}, {c_str(r['name'])}, {c_str(v) if isinstance(v, str) else '0'}, "
                          f"{c_num(v) if not isinstance(v, str) else '0.0'}, {c_str(r['unit'])} }},")
    regs, maps = [], []
    for m in data["register_maps"]:
        first = len(regs)
        for r in m["registers"]:
            regs.append(f"    {{ {c_str(r['name'])}, {r['address']}u, {r['width_bits']}u, {c_str(r['meaning'])}, ARGENT_REGISTER_ACCESS_{upper(r['access'])} }},")
        maps.append(f"    {{ {c_str(m['name'])}, {m['address_limit']}u, {m['data_width_bits']}u, {first}u, {len(m['registers'])}u }},")
    body = f"""typedef struct {{
    const char *name;
    const char *type;
    uint16_t apid;
    double length_bytes;
    double period_s;
}} argent_message_t;

typedef struct {{
    const char *end;
    const char *feature;
}} argent_topic_end_t;

typedef struct {{
    const char *name;
    const char *kind;
    const char *payload;
    uint16_t first_end;
    uint16_t end_count;
}} argent_topic_t;

typedef struct {{
    const char *icd;
    const char *name;
    const char *text;
    double value;
    const char *unit;
}} argent_icd_parameter_t;

typedef struct {{
    const char *name;
    uint16_t address;
    uint16_t width_bits;
    const char *meaning;
    argent_register_access_t access;
}} argent_register_t;

typedef struct {{
    const char *name;
    uint16_t address_limit;
    uint16_t data_width_bits;
    uint16_t first_register;
    uint16_t register_count;
}} argent_register_map_t;

#define ARGENT_MESSAGE_COUNT {len(msgs)}u
#define ARGENT_TOPIC_COUNT {len(topics)}u
#define ARGENT_TOPIC_END_COUNT {len(ends)}u
#define ARGENT_ICD_PARAMETER_COUNT {len(params)}u
#define ARGENT_REGISTER_COUNT {len(regs)}u
#define ARGENT_REGISTER_MAP_COUNT {len(maps)}u

static const argent_message_t argent_messages[{len(msgs)}] = {{
{chr(10).join(msgs)}
}};

static const argent_topic_end_t argent_topic_ends[{len(ends)}] = {{
{chr(10).join(ends)}
}};

static const argent_topic_t argent_topics[{len(topics)}] = {{
{chr(10).join(topics)}
}};

static const argent_icd_parameter_t argent_icd_parameters[{len(params)}] = {{
{chr(10).join(params)}
}};

static const argent_register_t argent_registers[{len(regs)}] = {{
{chr(10).join(regs)}
}};

static const argent_register_map_t argent_register_maps[{len(maps)}] = {{
{chr(10).join(maps)}
}};
"""
    out["argent_interfaces.h"] = file("interfaces", pin, ["TethysSoftwareIcds::MessageCatalogue", "TethysSoftwareIcds::argentSoftwareIcds (topics)",
                                      "TethysSoftwareIcds::OnBoardBusProtocolIcd", "TethysSoftwareIcds::SpaceLinkProfileIcd",
                                      "TethysSoftwareIcds::InspectorRelaySoftwareIcd", "TethysSoftwareIcds::ThermalPropulsionRiuRegisterMap",
                                      "TethysSoftwareIcds::MechanismRiuRegisterMap", "TethysSoftwareIcds::RegisterEntry"],
                                      ["<stdint.h>", "\"argent_enums.h\""], body)
    return out
