"""Python emitter: one module per table under the ``argent_tables`` package, NamedTuple rows."""

from __future__ import annotations

from emit_common import py_header, py_val, upper


def rows_block(name, cls, fields, rows):
    """A NamedTuple class and a tuple of its rows."""
    lines = [f"class {cls}(NamedTuple):"]
    for f, t in fields:
        lines.append(f"    {f}: {t}")
    lines.append("")
    lines.append(f"{name}: tuple[{cls}, ...] = (")
    for r in rows:
        lines.append(f"    {cls}({', '.join(py_val(v) for v in r)}),")
    lines.append(")")
    return "\n".join(lines) + "\n"


def module(pin, sources, imports, body):
    return py_header(pin, sources) + "\n" + imports + "\n\n" + body


def emit(data: dict, pin: dict) -> dict[str, str]:
    out = {}
    modes = data["enums"]["TugMode"]["literals"]

    # -- enums --------------------------------------------------------------------------------------
    body = []
    sources = []
    for enum, info in data["enums"].items():
        sources.append(info["source"])
        body.append(f"class {enum}(IntEnum):")
        if info.get("values"):
            for l in info["literals"]:
                body.append(f"    {upper(l)} = {info['values'][l]}")
        else:
            for i, l in enumerate(info["literals"]):
                body.append(f"    {upper(l)} = {i}")
        body.append("")
        body.append("")
    body.append("def mode_mask(active: list[str] | tuple[str, ...]) -> int:\n    return sum(1 << TugMode[upper_name(m)] for m in active)\n\n")
    body.append("def upper_name(literal: str) -> str:\n    return _UPPER.sub('_', literal).replace('-', '_').replace('.', '_').upper()\n")
    out["enums.py"] = module(pin, sources, "import re\nfrom enum import IntEnum\n\n_UPPER = re.compile(r'(?<=[a-z0-9])(?=[A-Z])')", "\n".join(body))

    # -- commands -------------------------------------------------------------------------------------
    arg_fields = [("name", "str"), ("value_type", "str"), ("minimum", "float | None"), ("maximum", "float | None"), ("width_bits", "int"), ("unit", "str")]
    cmd_fields = [("opcode", "int"), ("mnemonic", "str"), ("item", "str"), ("application", "str"), ("apid", "int"), ("apid_class", "str"),
                  ("criticality", "str"), ("hazardous", "bool"), ("two_step", "bool"), ("allowed_modes", "tuple[str, ...]"),
                  ("argument_bits", "int"), ("arguments", "tuple[CommandArgument, ...]")]
    rows = []
    for c in data["commands"]:
        args = "(" + "".join(f"CommandArgument({', '.join(py_val(a[k]) for k in ('name', 'type', 'minimum', 'maximum', 'width_bits', 'unit'))}), " for a in c["arguments"]) + ")"
        rows.append([c["opcode"], c["mnemonic"], c["item"], c["application"], c["apid"], c["apid_class"], c["criticality"], c["hazardous"],
                     c["two_step"], tuple(c["allowed_modes"]), c["argument_bits"], _Raw(args)])
    body = rows_block("COMMANDS", "Command", cmd_fields, rows)
    body = "class CommandArgument(NamedTuple):\n" + "".join(f"    {f}: {t}\n" for f, t in arg_fields) + "\n\n" + body
    body += f"\nCOMMAND_COUNT = {len(data['commands'])}\nHAZARDOUS_COMMAND_COUNT = {sum(1 for c in data['commands'] if c['hazardous'])}\n"
    body += "COMMANDS_BY_OPCODE = {c.opcode: c for c in COMMANDS}\nCOMMANDS_BY_MNEMONIC = {c.mnemonic: c for c in COMMANDS}\n"
    out["commands.py"] = module(pin, ["TethysFlightDictionary::flightDictionary::commands", "TethysFlightDictionary::CommandDefinition",
                                      "TethysFlightDictionary::CommandArgument", "TethysTugStructure::TugMode"], "from typing import NamedTuple", body)

    # -- telemetry ---------------------------------------------------------------------------------------
    tm_fields = [("id", "int"), ("mnemonic", "str"), ("item", "str"), ("point_type", "str"), ("kind", "str"), ("source", "str"), ("apid_class", "str"),
                 ("rate_hz", "float | None"), ("width_bits", "int"), ("unit", "str"), ("value_type", "str"), ("red_low", "float | None"),
                 ("yellow_low", "float | None"), ("yellow_high", "float | None"), ("red_high", "float | None"), ("packets", "tuple[str, ...]")]
    rows = [[t[k] if k != "packets" else tuple(t[k]) for k, _ in tm_fields] for t in data["telemetry"]]
    body = rows_block("TELEMETRY_POINTS", "TelemetryPoint", tm_fields, rows)
    rs_fields = [("mode", "str"), ("name", "str"), ("downlink_bit_s", "float | None"), ("uplink_bit_s", "float | None"), ("housekeeping_period_s", "float | None")]
    rs = sorted(data["rate_sets"], key=lambda r: modes.index(r["mode"]))
    body += "\n" + rows_block("MODE_RATE_SETS", "ModeRateSet", rs_fields, [[r[k] for k, _ in rs_fields] for r in rs])
    body += f"\nTELEMETRY_POINT_COUNT = {len(data['telemetry'])}\nHOUSEKEEPING_POINT_COUNT = {sum(1 for t in data['telemetry'] if t['kind'] == 'housekeeping')}\n"
    body += "TELEMETRY_BY_ID = {t.id: t for t in TELEMETRY_POINTS}\nTELEMETRY_BY_MNEMONIC = {t.mnemonic: t for t in TELEMETRY_POINTS}\n"
    body += "RATE_SET_BY_MODE = {r.mode: r for r in MODE_RATE_SETS}\n\n\n"
    body += ("def sample_rate_hz(point: TelemetryPoint, mode: str) -> float | None:\n"
             "    rate_set = RATE_SET_BY_MODE[mode]\n"
             "    if point.kind == 'housekeeping' and rate_set.housekeeping_period_s:\n"
             "        return 1.0 / rate_set.housekeeping_period_s\n"
             "    return point.rate_hz\n")
    out["telemetry.py"] = module(pin, ["TethysFlightDictionary::flightDictionary::telemetryPoints", "TethysFlightDictionary::TelemetryPointDefinition",
                                       "TethysSoftwareIcds::SpaceLinkProfileIcd (LinkRateSet rows)"], "from typing import NamedTuple", body)

    # -- events -----------------------------------------------------------------------------------------------
    ev_fields = [("id", "int"), ("mnemonic", "str"), ("item", "str"), ("source", "str"), ("severity", "str"), ("text", "str"),
                 ("fdir_relevant", "bool"), ("is_fault", "bool"), ("level", "str")]
    body = rows_block("EVENTS", "Event", ev_fields, [[e[k] for k, _ in ev_fields] for e in data["events"]])
    body += f"\nEVENT_COUNT = {len(data['events'])}\nFAULT_EVENT_COUNT = {sum(1 for e in data['events'] if e['fdir_relevant'])}\n"
    body += "EVENTS_BY_ID = {e.id: e for e in EVENTS}\n"
    out["events.py"] = module(pin, ["TethysFlightDictionary::flightDictionary::events", "TethysFlightDictionary::EventDefinition"], "from typing import NamedTuple", body)

    # -- packets ------------------------------------------------------------------------------------------------
    pf_fields = [("name", "str"), ("order", "int"), ("offset_bits", "int"), ("width_bits", "int"), ("point", "str")]
    pk_fields = [("id", "int"), ("mnemonic", "str"), ("item", "str"), ("apid", "int"), ("apid_class", "str"), ("source", "str"), ("rate_hz", "float | None"),
                 ("header_bits", "int"), ("length_octets", "int"), ("fields", "tuple[PacketField, ...]")]
    rows = []
    for p in data["packets"]:
        fs = "(" + "".join(f"PacketField({', '.join(py_val(f[k]) for k, _ in pf_fields)}), " for f in p["fields"]) + ")"
        rows.append([p[k] if k != "fields" else _Raw(fs) for k, _ in pk_fields])
    body = "class PacketField(NamedTuple):\n" + "".join(f"    {f}: {t}\n" for f, t in pf_fields) + "\n\n" + rows_block("PACKETS", "Packet", pk_fields, rows)
    body += "\nPRIMARY_HEADER = {\n" + "".join(f"    {py_val(r['name'])}: {py_val(r['value'])},\n" for r in data["primary_header"]["rows"]) + "}\n"
    body += "TIME_CODE = {\n" + "".join(f"    {py_val(r['name'])}: {py_val(r['value'])},\n" for r in data["time_code"]["rows"]) + "}\n"
    body += "APID_BASES = {\n" + "".join(f"    {py_val(a['name'])}: {py_val(a['base_apid'])},\n" for a in data["apid_classes"]) + "}\n"
    body += f"PACKET_COUNT = {len(data['packets'])}\nPACKETS_BY_APID = {{p.apid: p for p in PACKETS}}\n"
    out["packets.py"] = module(pin, ["TethysFlightDictionary::flightDictionary::packets", "TethysFlightDictionary::PacketDefinition",
                                     "TethysFlightDictionary::PacketField", "TethysFlightDictionary::PrimaryHeaderLayout",
                                     "TethysFlightDictionary::TethysTimeCode", "TethysFlightDictionary::flightApids"], "from typing import NamedTuple", body)

    # -- parameters ----------------------------------------------------------------------------------------------------
    pr_fields = [("id", "int"), ("name", "str"), ("owner", "str"), ("table_id", "int"), ("value", "float"), ("minimum", "float"), ("maximum", "float"), ("unit", "str")]
    rows = [[r["id"], r["name"], r["owner"], t["table_id"], r["value"], r["minimum"], r["maximum"], r["unit"]] for t in data["parameter_tables"] for r in t["rows"]]
    body = rows_block("PARAMETERS", "Parameter", pr_fields, rows)
    pt_fields = [("table_id", "int"), ("owner", "str"), ("item", "str"), ("row_ids", "tuple[int, ...]")]
    body += "\n" + rows_block("PARAMETER_TABLES", "ParameterTable", pt_fields, [[t["table_id"], t["owner"], t["item"], tuple(r["id"] for r in t["rows"])] for t in data["parameter_tables"]])
    lim_fields = [("name", "str"), ("value", "float"), ("unit", "str")]
    body += "\n" + rows_block("LIMIT_TABLE", "Limit", lim_fields, [[r["name"], r["value"], r["unit"]] for r in data["limit_table"]["rows"]])
    ml_fields = [("limit_set", "str"), ("name", "str"), ("value", "float"), ("unit", "str")]
    body += "\n" + rows_block("MONITOR_LIMITS", "MonitorLimit", ml_fields, [[r["set"], r["name"], r["value"], r["unit"]] for r in data["monitor_limits"]])
    fe_fields = [("name", "str"), ("fields", "tuple[tuple[str, str], ...]")]
    body += "\n" + rows_block("FAULT_EVENT_TYPES", "FaultEventType", fe_fields, [[f["name"], tuple(tuple(x) for x in f["fields"])] for f in data["fault_events"]])
    body += f"\nLIMIT_TABLE_ID = {data['limit_table']['table_id']}\nPARAMETER_COUNT = {len(rows)}\nPARAMETERS_BY_ID = {{p.id: p for p in PARAMETERS}}\n"
    out["parameters.py"] = module(pin, ["TethysFlightDictionary::flightDictionary::parameterTables", "TethysFlightDictionary::ParameterRow",
                                        "TethysFlightDictionary::flightLimitTable", "TethysFlightDictionary::tableLimits", "TethysFdir::cruiseLimits",
                                        "TethysFdir::FaultEvent"], "from typing import NamedTuple", body)

    # -- modes -----------------------------------------------------------------------------------------------------------
    flag_names = sorted({k for r in data["mode_table"] for k in r["flags"]})
    bus_by_mode = {b["mode"]: b for b in data["bus_schedule"]["per_mode"]}
    mr_fields = [("index", "int"), ("mode", "str"), ("flags", "dict[str, bool]"), ("active_applications", "tuple[str, ...]"), ("rate_set", "str | None"), ("bus_slots_used", "int")]
    rows = [[r["index"], r["mode"], {f: bool(r["flags"].get(f)) for f in flag_names}, tuple(r["active_applications"]), r["rate_set"], bus_by_mode[r["mode"]]["slots_used"]]
            for r in data["mode_table"]]
    body = rows_block("MODE_TABLE", "ModeRow", mr_fields, rows)
    ap_fields = [("name", "str"), ("definition", "str"), ("rate_hz", "float | None"), ("priority", "int"), ("layer", "str"), ("criticality", "str"), ("active_modes", "tuple[str, ...]")]
    body += "\n" + rows_block("APPLICATIONS", "Application", ap_fields, [[a[k] if k != "active_modes" else tuple(a[k]) for k, _ in ap_fields] for a in data["applications"]])
    body += f"\nMODE_FLAG_NAMES = {tuple(flag_names)!r}\nMODE_ROW_COUNT = {len(rows)}\nMODE_ROWS_BY_NAME = {{r.mode: r for r in MODE_TABLE}}\n"
    out["modes.py"] = module(pin, ["TethysModes::TugModeTable", "TethysModes::SubsystemConfiguration", "TethysFlightSoftware::ArgentFlightSoftware (Application parts)",
                                   "TethysSoftwareIcds::SpaceLinkProfileIcd (LinkRateSet rows)", "TethysFlightTiming::argentBus"], "from typing import NamedTuple", body)

    # -- state machines ------------------------------------------------------------------------------------------------------
    st_fields = [("name", "str"), ("qualified_name", "str"), ("parent", "str | None"), ("initial_substate", "str | None"), ("leaf", "bool"), ("entry_action", "str"), ("exit_action", "str")]
    tr_fields = [("source", "str | None"), ("target", "str"), ("event", "str | None"), ("parameter", "str | None"), ("port", "str | None"), ("timed", "str | None"), ("guard", "str | None"), ("effect", "str | None")]
    body = ("class State(NamedTuple):\n" + "".join(f"    {f}: {t}\n" for f, t in st_fields) + "\n\n"
            "class Transition(NamedTuple):\n" + "".join(f"    {f}: {t}\n" for f, t in tr_fields) + "\n\n"
            "class NamedExpression(NamedTuple):\n    id: str\n    text: str\n\n\n"
            "class StateMachine(NamedTuple):\n    name: str\n    source: str\n    initial: str | None\n    states: tuple[State, ...]\n"
            "    transitions: tuple[Transition, ...]\n    guards: tuple[NamedExpression, ...]\n    effects: tuple[NamedExpression, ...]\n\n\n")
    names = []
    for m in data["machines"]:
        var = upper(m["name"])
        names.append(var)
        body += f"{var} = StateMachine(\n    {py_val(m['name'])}, {py_val(m['source'])}, {py_val(m['initial'])},\n    (\n"
        for s in m["states"]:
            entry = "; ".join(t for k, t in s["actions"] if k == "entry")
            exit_ = "; ".join(t for k, t in s["actions"] if k == "exit")
            body += f"        State({py_val(s['name'])}, {py_val(s['id'])}, {py_val(s['parent'])}, {py_val(s['initial'])}, {py_val(s['leaf'])}, {py_val(entry)}, {py_val(exit_)}),\n"
        body += "    ),\n    (\n"
        for t in m["transitions"]:
            tr = t["trigger"]
            body += f"        Transition({py_val(t['source'])}, {py_val(t['target'])}, {py_val(tr['event'])}, {py_val(tr['parameter'])}, {py_val(tr['port'])}, {py_val(tr['timed'])}, {py_val(t['guard'])}, {py_val(t['effect'])}),\n"
        body += "    ),\n    (\n" + "".join(f"        NamedExpression({py_val(g['id'])}, {py_val(g['text'])}),\n" for g in m["guards"])
        body += "    ),\n    (\n" + "".join(f"        NamedExpression({py_val(e['id'])}, {py_val(e['text'])}),\n" for e in m["effects"]) + "    ),\n)\n\n"
    body += "STATE_MACHINES: tuple[StateMachine, ...] = (\n" + "".join(f"    {n},\n" for n in names) + ")\n"
    body += "STATE_MACHINES_BY_NAME = {m.name: m for m in STATE_MACHINES}\n"
    out["state_machines.py"] = module(pin, [m["source"] for m in data["machines"]], "from typing import NamedTuple", body)

    # -- schedule --------------------------------------------------------------------------------------------------------------
    sch = data["schedule"]
    body = rows_block("RATE_GROUPS", "RateGroup", [("name", "str"), ("rate_hz", "float"), ("period_s", "float"), ("activations_per_major_frame", "int")],
                      [[r["name"], r["rate_hz"], r["period_s"], r["activations_per_major_frame"]] for r in sch["rate_groups"]])
    body += "\n" + rows_block("PARTITIONS", "Partition", [("name", "str"), ("window_s", "float"), ("memory_bytes", "float"), ("criticality", "str"), ("restartable", "bool")],
                              [[p["name"], p["window_s"], p["memory_bytes"], p["criticality"], p["restartable"]] for p in sch["partitions"]])
    task_fields = [("name", "str"), ("schedule", "str"), ("kind", "str"), ("component", "str"), ("rate_group", "str"), ("wcet_s", "float"), ("period_s", "float"),
                   ("deadline_s", "float"), ("firing_frames", "tuple[int, ...]"), ("active_modes", "tuple[str, ...]")]
    trows = [[t["name"], s["name"], t["kind"], t["component"], t["rate_group"], t["wcet_s"], t["period_s"], t["deadline_s"], tuple(t["firing_frames"]), tuple(t["active_modes"])]
             for s in sch["partition_schedules"] for t in s["tasks"]]
    body += "\n" + rows_block("SCHEDULED_TASKS", "ScheduledTask", task_fields, trows)
    body += "\n" + rows_block("PARTITION_SCHEDULES", "PartitionSchedule", [("name", "str"), ("partition", "str"), ("slices", "tuple[tuple[str, float], ...]"), ("tasks", "tuple[str, ...]")],
                              [[s["name"], s["partition"], tuple((x["name"], x["duration_s"]) for x in s["slices"]), tuple(t["name"] for t in s["tasks"])] for s in sch["partition_schedules"]])
    bus = data["bus_schedule"]
    body += "\n" + rows_block("BUS_STREAMS", "BusStream", [("name", "str"), ("node", "str"), ("slots_per_frame", "int"), ("message_length_bytes", "float"), ("active_modes", "tuple[str, ...]")],
                              [[s["name"], s["node"], s["slots_per_frame"], s["message_length_bytes"], tuple(s["active_modes"])] for s in bus["streams"]])
    body += "\n" + rows_block("BUS_MODE_LOADS", "BusModeLoad", [("mode", "str"), ("slots_used", "int"), ("bytes_per_frame", "float")],
                              [[p["mode"], p["slots_used"], float(p["bytes_per_frame"])] for p in bus["per_mode"]])
    body += (f"\nMINOR_FRAME_PERIOD_S = {py_val(sch['minor_frame_period_s'])}\nMAJOR_FRAME_PERIOD_S = {py_val(sch['major_frame_period_s'])}\n"
             f"MINOR_FRAMES_PER_MAJOR_FRAME = {sch['minor_frames_per_major_frame']}\nBUS_FRAME_SLOTS = {bus['frame_slots']}\n"
             f"BUS_FRAME_PERIOD_S = {py_val(bus['frame_period_s'])}\nBUS_SLOT_LENGTH_BYTES = {py_val(bus['slot_length_bytes'])}\n")
    out["schedule.py"] = module(pin, ["TethysFlightTiming::FlightTiming", "TethysFlightTiming::argentTiming", "TethysFlightTiming::ScheduledTask",
                                      "TethysFlightSoftware::ArgentFlightSoftware::executive", "TethysFlightTiming::argentBus"], "from typing import NamedTuple", body)

    # -- interfaces -------------------------------------------------------------------------------------------------------------
    body = rows_block("MESSAGES", "Message", [("name", "str"), ("type", "str"), ("apid", "int"), ("length_bytes", "float"), ("period_s", "float | None")],
                      [[m["name"], m["type"], m["apid"], m["length_bytes"], m["period_s"]] for m in data["messages"]])
    body += "\n" + rows_block("TOPICS", "Topic", [("name", "str"), ("kind", "str"), ("payload", "str"), ("ends", "tuple[tuple[str, str], ...]")],
                              [[t["name"], t["kind"], t["payload"], tuple((e["end"], e["feature"]) for e in t["ends"])] for t in data["topics"]])
    prow = [[data[k]["source"].rsplit("::", 1)[-1], r["name"], r["value"], r["unit"]] for k in ("bus_protocol", "space_link", "relay_profile") for r in data[k]["rows"]]
    body += "\n" + rows_block("ICD_PARAMETERS", "IcdParameter", [("icd", "str"), ("name", "str"), ("value", "str | int | float | bool"), ("unit", "str")], prow)
    body += "\n" + rows_block("REGISTERS", "Register", [("map", "str"), ("name", "str"), ("address", "int"), ("width_bits", "int"), ("meaning", "str"), ("access", "str")],
                              [[m["name"], r["name"], r["address"], r["width_bits"], r["meaning"], r["access"]] for m in data["register_maps"] for r in m["registers"]])
    body += "\n" + rows_block("REGISTER_MAPS", "RegisterMap", [("name", "str"), ("source", "str"), ("address_limit", "int"), ("data_width_bits", "int"), ("register_count", "int")],
                              [[m["name"], m["source"], m["address_limit"], m["data_width_bits"], len(m["registers"])] for m in data["register_maps"]])
    body += "\nICD_PARAMETERS_BY_NAME = {(p.icd, p.name): p for p in ICD_PARAMETERS}\nMESSAGES_BY_APID = {m.apid: m for m in MESSAGES}\n"
    out["interfaces.py"] = module(pin, ["TethysSoftwareIcds::MessageCatalogue", "TethysSoftwareIcds::argentSoftwareIcds (topics)", "TethysSoftwareIcds::OnBoardBusProtocolIcd",
                                        "TethysSoftwareIcds::SpaceLinkProfileIcd", "TethysSoftwareIcds::InspectorRelaySoftwareIcd",
                                        "TethysSoftwareIcds::ThermalPropulsionRiuRegisterMap", "TethysSoftwareIcds::MechanismRiuRegisterMap"], "from typing import NamedTuple", body)

    mods = ["enums", "commands", "telemetry", "events", "packets", "parameters", "modes", "state_machines", "schedule", "interfaces"]
    out["__init__.py"] = py_header(pin, ["every module of this package"]) + "\n" + "".join(f"from . import {m}\n" for m in mods) + \
        f"\nGENERATOR_VERSION = {py_val(pin.get('generator', ''))}\nMODEL_TOOL_VERSION = {py_val(pin.get('version', ''))}\nMODEL_TOOL_COMMIT = {py_val(pin.get('commit', ''))}\n" + \
        f"__all__ = {mods!r}\n"
    return out


class _Raw(str):
    """A pre-rendered Python expression; ``py_val`` writes it as is."""
    __slots__ = ()

    def __repr__(self):
        return str.__str__(self)
