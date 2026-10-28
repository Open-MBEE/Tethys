"""Go emitter: one file per table in the ``argenttables`` package, positional struct literals.

The output is written in gofmt's canonical form (tabs, aligned struct fields) so ``gofmt -l`` is
empty on the generated tree without a Go toolchain in the generator's loop.
"""

from __future__ import annotations

import json

from emit_common import header_lines, upper

MODULE = "github.com/Open-MBEE/Tethys/software/generated/go"
PACKAGE = "argenttables"


def go_header(pin, sources) -> str:
    return "".join(f"// {l}\n" for l in header_lines(pin, sources)) + f"\npackage {PACKAGE}\n"


def s(v) -> str:
    """A Go string literal (JSON escaping is a subset of Go's)."""
    return json.dumps("" if v is None else str(v), ensure_ascii=True)


def f(v) -> str:
    """A Go float64 literal."""
    if v is None:
        return "0"
    return repr(float(v))


def opt(v) -> str:
    """An optional float: ``nil`` or ``F(x)``."""
    return "nil" if v is None else f"F({repr(float(v))})"


def i(v) -> str:
    return str(int(v))


def b(v) -> str:
    return "true" if v else "false"


def strs(vals) -> str:
    return "[]string{" + ", ".join(s(v) for v in vals) + "}"


def ints(vals) -> str:
    return "[]int{" + ", ".join(i(v) for v in vals) + "}"


def ident(literal: str) -> str:
    """A Go identifier for a model literal: `proximityOperations` → `ProximityOperations`,
    `CDH_NOOP` stays `CDH_NOOP`."""
    t = literal.replace("-", "_").replace(".", "_")
    return t[:1].upper() + t[1:]


def struct(name, fields) -> str:
    width = max(len(n) for n, _ in fields)
    lines = [f"type {name} struct {{"]
    for n, t in fields:
        lines.append(f"\t{n.ljust(width)} {t}")
    lines.append("}")
    return "\n".join(lines) + "\n"


def table(var, cls, rows) -> str:
    lines = [f"var {var} = []{cls}{{"]
    for r in rows:
        lines.append("\t{" + ", ".join(r) + "},")
    lines.append("}")
    return "\n".join(lines) + "\n"


def const_block(items) -> str:
    """``const ( Name Type = value )`` with the name column aligned as gofmt writes it."""
    width = max(len(n) for n, _, _ in items)
    twidth = max(len(t) for _, t, _ in items)
    lines = ["const ("]
    for n, t, v in items:
        lines.append(f"\t{n.ljust(width)} {t.ljust(twidth)} = {v}")
    lines.append(")")
    return "\n".join(lines) + "\n"


def file(pin, sources, imports, body) -> str:
    imp = ""
    if imports:
        imp = "\nimport (\n" + "".join(f"\t{s(x)}\n" for x in imports) + ")\n"
    return go_header(pin, sources) + imp + "\n" + body


def emit(data: dict, pin: dict) -> dict[str, str]:
    out = {}
    modes = data["enums"]["TugMode"]["literals"]

    # -- enums ------------------------------------------------------------------------------------
    body = ["// ModeMask is one bit per TugMode literal, in literal order (16 modes fit uint16).",
            "type ModeMask uint16\n",
            "// ModeBit is the mask bit of one mode.",
            "func ModeBit(m TugMode) ModeMask { return ModeMask(1) << uint(m) }\n",
            "// F boxes an optional float: a nil *float64 is a value the model leaves unbound.",
            "func F(v float64) *float64 { return &v }\n"]
    sources = []
    for enum, info in data["enums"].items():
        sources.append(info["source"])
        body.append(f"// {enum} is {info['source']}.")
        body.append(f"type {enum} int\n")
        values = info.get("values")
        items = []
        for k, l in enumerate(info["literals"]):
            items.append((f"{enum}{ident(l)}", enum, str(values[l] if values else k)))
        body.append(const_block(items))
        if not values:
            body.append(f"const {enum}Count = {len(info['literals'])}\n")
            body.append(f"var {enum}Names = [{enum}Count]string{{" + ", ".join(s(l) for l in info["literals"]) + "}\n")
        else:
            body.append(f"const {enum}Count = {len(info['literals'])}\n")
    body.append("// ModeMaskOf is the mask of the named modes.\n"
                "func ModeMaskOf(active []string) ModeMask {\n"
                "\tvar m ModeMask\n"
                "\tfor _, a := range active {\n"
                "\t\tfor k, n := range TugModeNames {\n"
                "\t\t\tif n == a {\n"
                "\t\t\t\tm |= ModeBit(TugMode(k))\n"
                "\t\t\t}\n"
                "\t\t}\n"
                "\t}\n"
                "\treturn m\n"
                "}\n")
    out["enums.go"] = file(pin, sources, [], "\n".join(body))

    # -- commands -----------------------------------------------------------------------------------
    body = struct("CommandArgument", [("Name", "string"), ("ValueType", "string"), ("Minimum", "*float64"),
                                      ("Maximum", "*float64"), ("WidthBits", "int"), ("Unit", "string")])
    body += "\n" + struct("Command", [("Opcode", "int"), ("Mnemonic", "string"), ("Item", "string"), ("Application", "string"),
                                      ("Apid", "int"), ("ApidClass", "string"), ("Criticality", "string"), ("Hazardous", "bool"),
                                      ("TwoStep", "bool"), ("AllowedModes", "[]string"), ("ArgumentBits", "int"),
                                      ("Arguments", "[]CommandArgument")])
    rows = []
    for c in data["commands"]:
        args = "[]CommandArgument{" + ", ".join(
            "{" + ", ".join([s(a["name"]), s(a["type"]), opt(a["minimum"]), opt(a["maximum"]), i(a["width_bits"]), s(a["unit"])]) + "}"
            for a in c["arguments"]) + "}"
        rows.append([i(c["opcode"]), s(c["mnemonic"]), s(c["item"]), s(c["application"]), i(c["apid"]), s(c["apid_class"]),
                     s(c["criticality"]), b(c["hazardous"]), b(c["two_step"]), strs(c["allowed_modes"]), i(c["argument_bits"]), args])
    body += "\n" + table("Commands", "Command", rows)
    body += f"\nconst CommandCount = {len(data['commands'])}\n"
    body += f"const HazardousCommandCount = {sum(1 for c in data['commands'] if c['hazardous'])}\n"
    out["commands.go"] = file(pin, ["TethysFlightDictionary::flightDictionary::commands", "TethysFlightDictionary::CommandDefinition",
                                    "TethysFlightDictionary::CommandArgument", "TethysTugStructure::TugMode"], [], body)

    # -- telemetry ---------------------------------------------------------------------------------------
    body = struct("TelemetryPoint", [("ID", "int"), ("Mnemonic", "string"), ("Item", "string"), ("PointType", "string"), ("Kind", "string"),
                                     ("Source", "string"), ("ApidClass", "string"), ("RateHz", "*float64"), ("WidthBits", "int"), ("Unit", "string"),
                                     ("ValueType", "string"), ("RedLow", "*float64"), ("YellowLow", "*float64"), ("YellowHigh", "*float64"),
                                     ("RedHigh", "*float64"), ("Packets", "[]string")])
    rows = [[i(t["id"]), s(t["mnemonic"]), s(t["item"]), s(t["point_type"]), s(t["kind"]), s(t["source"]), s(t["apid_class"]), opt(t["rate_hz"]),
             i(t["width_bits"]), s(t["unit"]), s(t["value_type"]), opt(t["red_low"]), opt(t["yellow_low"]), opt(t["yellow_high"]), opt(t["red_high"]),
             strs(t["packets"])] for t in data["telemetry"]]
    body += "\n" + table("TelemetryPoints", "TelemetryPoint", rows)
    body += "\n" + struct("ModeRateSet", [("Mode", "string"), ("Name", "string"), ("DownlinkBitS", "*float64"), ("UplinkBitS", "*float64"),
                                          ("HousekeepingPeriodS", "*float64")])
    rs = sorted(data["rate_sets"], key=lambda r: modes.index(r["mode"]))
    body += "\n" + table("ModeRateSets", "ModeRateSet", [[s(r["mode"]), s(r["name"]), opt(r["downlink_bit_s"]), opt(r["uplink_bit_s"]),
                                                          opt(r["housekeeping_period_s"])] for r in rs])
    body += f"\nconst TelemetryPointCount = {len(data['telemetry'])}\n"
    body += f"const HousekeepingPointCount = {sum(1 for t in data['telemetry'] if t['kind'] == 'housekeeping')}\n"
    body += ("\n// SampleRateHz is a point's sample rate in a mode: housekeeping points follow the mode's\n"
             "// housekeeping period, every other point its dictionary rate. ok is false without either.\n"
             "func SampleRateHz(p TelemetryPoint, mode string) (rate float64, ok bool) {\n"
             "\tif p.Kind == \"housekeeping\" {\n"
             "\t\tif r, found := RateSetByMode[mode]; found && r.HousekeepingPeriodS != nil && *r.HousekeepingPeriodS > 0 {\n"
             "\t\t\treturn 1.0 / *r.HousekeepingPeriodS, true\n"
             "\t\t}\n"
             "\t}\n"
             "\tif p.RateHz == nil {\n"
             "\t\treturn 0, false\n"
             "\t}\n"
             "\treturn *p.RateHz, true\n"
             "}\n")
    out["telemetry.go"] = file(pin, ["TethysFlightDictionary::flightDictionary::telemetryPoints", "TethysFlightDictionary::TelemetryPointDefinition",
                                     "TethysSoftwareIcds::SpaceLinkProfileIcd (LinkRateSet rows)"], [], body)

    # -- events -----------------------------------------------------------------------------------------------
    body = struct("Event", [("ID", "int"), ("Mnemonic", "string"), ("Item", "string"), ("Source", "string"), ("Severity", "string"),
                            ("Text", "string"), ("FdirRelevant", "bool"), ("IsFault", "bool"), ("Level", "string")])
    body += "\n" + table("Events", "Event", [[i(e["id"]), s(e["mnemonic"]), s(e["item"]), s(e["source"]), s(e["severity"]), s(e["text"]),
                                              b(e["fdir_relevant"]), b(e["is_fault"]), s(e["level"])] for e in data["events"]])
    body += f"\nconst EventCount = {len(data['events'])}\n"
    body += f"const FaultEventCount = {sum(1 for e in data['events'] if e['fdir_relevant'])}\n"
    out["events.go"] = file(pin, ["TethysFlightDictionary::flightDictionary::events", "TethysFlightDictionary::EventDefinition"], [], body)

    # -- packets ------------------------------------------------------------------------------------------------
    body = struct("PacketField", [("Name", "string"), ("Order", "int"), ("OffsetBits", "int"), ("WidthBits", "int"), ("Point", "string")])
    body += "\n" + struct("Packet", [("ID", "int"), ("Mnemonic", "string"), ("Item", "string"), ("Apid", "int"), ("ApidClass", "string"),
                                     ("Source", "string"), ("RateHz", "*float64"), ("HeaderBits", "int"), ("LengthOctets", "int"),
                                     ("Fields", "[]PacketField")])
    rows = []
    for p in data["packets"]:
        fs = "[]PacketField{" + ", ".join("{" + ", ".join([s(x["name"]), i(x["order"]), i(x["offset_bits"]), i(x["width_bits"]), s(x["point"])]) + "}"
                                          for x in p["fields"]) + "}"
        rows.append([i(p["id"]), s(p["mnemonic"]), s(p["item"]), i(p["apid"]), s(p["apid_class"]), s(p["source"]), opt(p["rate_hz"]),
                     i(p["header_bits"]), i(p["length_octets"]), fs])
    body += "\n" + table("Packets", "Packet", rows)
    body += "\n" + const_block([(f"PrimaryHeader{ident(r['name'])}", "int", i(r["value"])) for r in data["primary_header"]["rows"]])
    tc = []
    for r in data["time_code"]["rows"]:
        v = r["value"]
        if isinstance(v, bool):
            tc.append((f"TimeCode{ident(r['name'])}", "bool", b(v)))
        elif isinstance(v, int):
            tc.append((f"TimeCode{ident(r['name'])}", "int", i(v)))
        elif isinstance(v, float):
            tc.append((f"TimeCode{ident(r['name'])}", "float64", f(v)))
        else:
            tc.append((f"TimeCode{ident(r['name'])}", "string", s(v)))
    body += "\n" + const_block(tc)
    body += "\n" + const_block([(f"ApidBase{ident(a['name'])}", "int", i(a["base_apid"])) for a in data["apid_classes"]])
    body += f"\nconst PacketCount = {len(data['packets'])}\n"
    out["packets.go"] = file(pin, ["TethysFlightDictionary::flightDictionary::packets", "TethysFlightDictionary::PacketDefinition",
                                   "TethysFlightDictionary::PacketField", "TethysFlightDictionary::PrimaryHeaderLayout",
                                   "TethysFlightDictionary::TethysTimeCode", "TethysFlightDictionary::flightApids"], [], body)

    # -- parameters ----------------------------------------------------------------------------------------------------
    body = struct("Parameter", [("ID", "int"), ("Name", "string"), ("Owner", "string"), ("TableID", "int"), ("Value", "float64"),
                                ("Minimum", "float64"), ("Maximum", "float64"), ("Unit", "string")])
    prow = [[i(r["id"]), s(r["name"]), s(r["owner"]), i(t["table_id"]), f(r["value"]), f(r["minimum"]), f(r["maximum"]), s(r["unit"])]
            for t in data["parameter_tables"] for r in t["rows"]]
    body += "\n" + table("Parameters", "Parameter", prow)
    body += "\n" + struct("ParameterTable", [("TableID", "int"), ("Owner", "string"), ("Item", "string"), ("RowIDs", "[]int")])
    body += "\n" + table("ParameterTables", "ParameterTable", [[i(t["table_id"]), s(t["owner"]), s(t["item"]), ints(r["id"] for r in t["rows"])]
                                                               for t in data["parameter_tables"]])
    body += "\n" + struct("Limit", [("Name", "string"), ("Value", "float64"), ("Unit", "string")])
    body += "\n" + table("LimitTable", "Limit", [[s(r["name"]), f(r["value"]), s(r["unit"])] for r in data["limit_table"]["rows"]])
    body += "\n" + struct("MonitorLimit", [("LimitSet", "string"), ("Name", "string"), ("Value", "float64"), ("Unit", "string")])
    body += "\n" + table("MonitorLimits", "MonitorLimit", [[s(r["set"]), s(r["name"]), f(r["value"]), s(r["unit"])] for r in data["monitor_limits"]])
    body += "\n" + struct("FaultEventType", [("Name", "string"), ("Fields", "[][2]string")])
    body += "\n" + table("FaultEventTypes", "FaultEventType",
                         [[s(x["name"]), "[][2]string{" + ", ".join("{" + s(a) + ", " + s(c) + "}" for a, c in x["fields"]) + "}"] for x in data["fault_events"]])
    body += f"\nconst LimitTableID = {data['limit_table']['table_id']}\n"
    body += f"const ParameterCount = {len(prow)}\n"
    out["parameters.go"] = file(pin, ["TethysFlightDictionary::flightDictionary::parameterTables", "TethysFlightDictionary::ParameterRow",
                                      "TethysFlightDictionary::flightLimitTable", "TethysFlightDictionary::tableLimits", "TethysFdir::cruiseLimits",
                                      "TethysFdir::FaultEvent"], [], body)

    # -- modes -----------------------------------------------------------------------------------------------------------
    flag_names = sorted({k for r in data["mode_table"] for k in r["flags"]})
    bus_by_mode = {x["mode"]: x for x in data["bus_schedule"]["per_mode"]}
    body = struct("ModeRow", [("Index", "int"), ("Mode", "string"), ("Flags", "map[string]bool"), ("ActiveApplications", "[]string"),
                              ("RateSet", "string"), ("BusSlotsUsed", "int")])
    rows = []
    for r in data["mode_table"]:
        flags = "map[string]bool{" + ", ".join(f"{s(k)}: {b(r['flags'].get(k))}" for k in flag_names) + "}"
        rows.append([i(r["index"]), s(r["mode"]), flags, strs(r["active_applications"]), s(r["rate_set"]), i(bus_by_mode[r["mode"]]["slots_used"])])
    body += "\n" + table("ModeTable", "ModeRow", rows)
    body += "\n" + struct("Application", [("Name", "string"), ("Definition", "string"), ("RateHz", "*float64"), ("Priority", "int"),
                                          ("Layer", "string"), ("Criticality", "string"), ("ActiveModes", "[]string")])
    body += "\n" + table("Applications", "Application", [[s(a["name"]), s(a["definition"]), opt(a["rate_hz"]), i(a["priority"]), s(a["layer"]),
                                                          s(a["criticality"]), strs(a["active_modes"])] for a in data["applications"]])
    body += f"\nvar ModeFlagNames = {strs(flag_names)}\n"
    body += f"\nconst ModeRowCount = {len(rows)}\n"
    out["modes.go"] = file(pin, ["TethysModes::TugModeTable", "TethysModes::SubsystemConfiguration", "TethysFlightSoftware::ArgentFlightSoftware (Application parts)",
                                 "TethysSoftwareIcds::SpaceLinkProfileIcd (LinkRateSet rows)", "TethysFlightTiming::argentBus"], [], body)

    # -- state machines ------------------------------------------------------------------------------------------------------
    body = struct("State", [("Name", "string"), ("QualifiedName", "string"), ("Parent", "string"), ("InitialSubstate", "string"),
                            ("Leaf", "bool"), ("EntryAction", "string"), ("ExitAction", "string")])
    body += "\n" + struct("Transition", [("Source", "string"), ("Target", "string"), ("Event", "string"), ("Parameter", "string"),
                                         ("Port", "string"), ("Timed", "string"), ("Guard", "string"), ("Effect", "string"),
                                         ("Region", "string"), ("Line", "int")])
    body += "\n" + struct("NamedExpression", [("ID", "string"), ("Text", "string")])
    body += "\n" + struct("StateMachine", [("Name", "string"), ("Source", "string"), ("Initial", "string"), ("States", "[]State"),
                                           ("Transitions", "[]Transition"), ("Guards", "[]NamedExpression"), ("Effects", "[]NamedExpression")])
    names = []
    for m in data["machines"]:
        var = ident(m["name"])
        names.append(var)
        body += f"\nvar {var} = StateMachine{{\n\t{s(m['name'])}, {s(m['source'])}, {s(m['initial'])},\n"
        body += "\t[]State{\n"
        for st in m["states"]:
            entry = "; ".join(t for k, t in st["actions"] if k == "entry")
            exit_ = "; ".join(t for k, t in st["actions"] if k == "exit")
            body += "\t\t{" + ", ".join([s(st["name"]), s(st["id"]), s(st["parent"]), s(st["initial"]), b(st["leaf"]), s(entry), s(exit_)]) + "},\n"
        body += "\t},\n\t[]Transition{\n"
        for t in m["transitions"]:
            tr = t["trigger"]
            body += "\t\t{" + ", ".join([s(t["source"]), s(t["target"]), s(tr["event"]), s(tr["parameter"]), s(tr["port"]), s(tr["timed"]),
                                         s(t["guard"]), s(t["effect"]), s(t["region"]), i(t["line"] or 0)]) + "},\n"
        body += "\t},\n\t[]NamedExpression{" + ", ".join(f"{{{s(g['id'])}, {s(g['text'])}}}" for g in m["guards"]) + "},\n"
        body += "\t[]NamedExpression{" + ", ".join(f"{{{s(e['id'])}, {s(e['text'])}}}" for e in m["effects"]) + "},\n}\n"
    body += "\nvar StateMachines = []StateMachine{" + ", ".join(names) + "}\n"
    out["state_machines.go"] = file(pin, [m["source"] for m in data["machines"]], [], body)

    # -- schedule --------------------------------------------------------------------------------------------------------------
    sch = data["schedule"]
    body = struct("RateGroup", [("Name", "string"), ("RateHz", "float64"), ("PeriodS", "float64"), ("ActivationsPerMajorFrame", "int")])
    body += "\n" + table("RateGroups", "RateGroup", [[s(r["name"]), f(r["rate_hz"]), f(r["period_s"]), i(r["activations_per_major_frame"])] for r in sch["rate_groups"]])
    body += "\n" + struct("Partition", [("Name", "string"), ("WindowS", "float64"), ("MemoryBytes", "float64"), ("Criticality", "string"), ("Restartable", "bool")])
    body += "\n" + table("Partitions", "Partition", [[s(p["name"]), f(p["window_s"]), f(p["memory_bytes"]), s(p["criticality"]), b(p["restartable"])] for p in sch["partitions"]])
    body += "\n" + struct("ScheduledTask", [("Name", "string"), ("Schedule", "string"), ("Kind", "string"), ("Component", "string"), ("RateGroup", "string"),
                                            ("WcetS", "float64"), ("PeriodS", "float64"), ("DeadlineS", "float64"), ("FiringFrames", "[]int"), ("ActiveModes", "[]string")])
    body += "\n" + table("ScheduledTasks", "ScheduledTask", [[s(t["name"]), s(ps["name"]), s(t["kind"]), s(t["component"]), s(t["rate_group"]), f(t["wcet_s"]),
                                                              f(t["period_s"]), f(t["deadline_s"]), ints(t["firing_frames"]), strs(t["active_modes"])]
                                                             for ps in sch["partition_schedules"] for t in ps["tasks"]])
    body += "\n" + struct("FrameSlice", [("Name", "string"), ("DurationS", "float64")])
    body += "\n" + struct("PartitionSchedule", [("Name", "string"), ("Partition", "string"), ("Slices", "[]FrameSlice"), ("Tasks", "[]string")])
    body += "\n" + table("PartitionSchedules", "PartitionSchedule",
                         [[s(ps["name"]), s(ps["partition"]), "[]FrameSlice{" + ", ".join("{" + s(x["name"]) + ", " + f(x["duration_s"]) + "}" for x in ps["slices"]) + "}",
                           strs(t["name"] for t in ps["tasks"])] for ps in sch["partition_schedules"]])
    bus = data["bus_schedule"]
    body += "\n" + struct("BusStream", [("Name", "string"), ("Node", "string"), ("SlotsPerFrame", "int"), ("MessageLengthBytes", "float64"), ("ActiveModes", "[]string")])
    body += "\n" + table("BusStreams", "BusStream", [[s(x["name"]), s(x["node"]), i(x["slots_per_frame"]), f(x["message_length_bytes"]), strs(x["active_modes"])] for x in bus["streams"]])
    body += "\n" + struct("BusModeLoad", [("Mode", "string"), ("SlotsUsed", "int"), ("BytesPerFrame", "float64")])
    body += "\n" + table("BusModeLoads", "BusModeLoad", [[s(x["mode"]), i(x["slots_used"]), f(x["bytes_per_frame"])] for x in bus["per_mode"]])
    body += "\n" + const_block([("MinorFramePeriodS", "float64", f(sch["minor_frame_period_s"])), ("MajorFramePeriodS", "float64", f(sch["major_frame_period_s"])),
                                ("MinorFramesPerMajorFrame", "int", i(sch["minor_frames_per_major_frame"])), ("BusFrameSlots", "int", i(bus["frame_slots"])),
                                ("BusFramePeriodS", "float64", f(bus["frame_period_s"])), ("BusSlotLengthBytes", "float64", f(bus["slot_length_bytes"]))])
    out["schedule.go"] = file(pin, ["TethysFlightTiming::FlightTiming", "TethysFlightTiming::argentTiming", "TethysFlightTiming::ScheduledTask",
                                    "TethysFlightSoftware::ArgentFlightSoftware::executive", "TethysFlightTiming::argentBus"], [], body)

    # -- interfaces -------------------------------------------------------------------------------------------------------------
    body = struct("Message", [("Name", "string"), ("Type", "string"), ("Apid", "int"), ("LengthBytes", "float64"), ("PeriodS", "*float64")])
    body += "\n" + table("Messages", "Message", [[s(m["name"]), s(m["type"]), i(m["apid"]), f(m["length_bytes"]), opt(m["period_s"])] for m in data["messages"]])
    body += "\n" + struct("TopicEnd", [("End", "string"), ("Feature", "string")])
    body += "\n" + struct("Topic", [("Name", "string"), ("Kind", "string"), ("Payload", "string"), ("Ends", "[]TopicEnd")])
    body += "\n" + table("Topics", "Topic", [[s(t["name"]), s(t["kind"]), s(t["payload"]),
                                              "[]TopicEnd{" + ", ".join("{" + s(e["end"]) + ", " + s(e["feature"]) + "}" for e in t["ends"]) + "}"] for t in data["topics"]])
    body += "\n" + struct("IcdParameter", [("Icd", "string"), ("Name", "string"), ("Value", "string"), ("Number", "*float64"), ("Unit", "string")])
    prow = []
    for k in ("bus_protocol", "space_link", "relay_profile"):
        icd = data[k]["source"].rsplit("::", 1)[-1]
        for r in data[k]["rows"]:
            v = r["value"]
            num = opt(v) if isinstance(v, (int, float)) and not isinstance(v, bool) else "nil"
            text = ("true" if v else "false") if isinstance(v, bool) else str(v)
            prow.append([s(icd), s(r["name"]), s(text), num, s(r["unit"])])
    body += "\n" + table("IcdParameters", "IcdParameter", prow)
    body += "\n" + struct("Register", [("Map", "string"), ("Name", "string"), ("Address", "int"), ("WidthBits", "int"), ("Meaning", "string"), ("Access", "string")])
    body += "\n" + table("Registers", "Register", [[s(m["name"]), s(r["name"]), i(r["address"]), i(r["width_bits"]), s(r["meaning"]), s(r["access"])]
                                                   for m in data["register_maps"] for r in m["registers"]])
    body += "\n" + struct("RegisterMap", [("Name", "string"), ("Source", "string"), ("AddressLimit", "int"), ("DataWidthBits", "int"), ("RegisterCount", "int")])
    body += "\n" + table("RegisterMaps", "RegisterMap", [[s(m["name"]), s(m["source"]), i(m["address_limit"]), i(m["data_width_bits"]), i(len(m["registers"]))]
                                                         for m in data["register_maps"]])
    out["interfaces.go"] = file(pin, ["TethysSoftwareIcds::MessageCatalogue", "TethysSoftwareIcds::argentSoftwareIcds (topics)", "TethysSoftwareIcds::OnBoardBusProtocolIcd",
                                      "TethysSoftwareIcds::SpaceLinkProfileIcd", "TethysSoftwareIcds::InspectorRelaySoftwareIcd",
                                      "TethysSoftwareIcds::ThermalPropulsionRiuRegisterMap", "TethysSoftwareIcds::MechanismRiuRegisterMap"], [], body)

    # -- ground ----------------------------------------------------------------------------------------------------------------
    g = data["ground"]
    body = struct("Quantity", [("Value", "float64"), ("Unit", "string")])
    for enum, info in g["enums"].items():
        body += f"\n// {enum} is {info['source']}.\ntype {enum} int\n\n"
        body += const_block([(f"{enum}{ident(l)}", enum, str(k)) for k, l in enumerate(info["literals"])])
        body += f"\nvar {enum}Names = [{len(info['literals'])}]string{{" + ", ".join(s(l) for l in info["literals"]) + "}\n"
    body += "\n" + struct("RuleParameter", [("Name", "string"), ("Value", "float64"), ("Unit", "string")])
    body += "\n" + struct("FlightRule", [("ID", "string"), ("Name", "string"), ("Item", "string"), ("Text", "string"), ("Constraint", "string"),
                                         ("Expression", "string"), ("Inputs", "[]string"), ("Parameters", "[]RuleParameter")])
    body += "\n" + table("FlightRules", "FlightRule", [[s(r["id"]), s(r["name"]), s(r["item"]), s(r["text"]), s(r["constraint"]), s(r["expression"]), strs(r["inputs"]),
                                                       "[]RuleParameter{" + ", ".join("{" + s(x["name"]) + ", " + f(x["value"]) + ", " + s(x["unit"]) + "}" for x in r["parameters"]) + "}"]
                                                      for r in g["flight_rules"]])
    body += "\n" + struct("OnBoardSequence", [("SequenceID", "int"), ("Name", "string"), ("Item", "string"), ("TimeTagged", "bool"), ("Text", "string")])
    body += "\n" + table("OnBoardSequences", "OnBoardSequence", [[i(x["sequence_id"]), s(x["name"]), s(x["item"]), b(x["time_tagged"]), s(x["text"])] for x in g["sequences"]])
    c = g["check"]
    body += f"\nconst SequenceCheckSource = {s(c['source'])}\n"
    body += f"\nvar StoredSequences = {ints(c['stored_sequences'])}\n"
    body += "\nvar CheckLimits = map[string]Quantity{" + ", ".join(f"{s(k)}: {{{f(v['value'])}, {s(v['unit'])}}}" for k, v in c["limits"].items()) + "}\n"
    body += f"\nvar FlightModes = {strs(c['flight_modes'])}\n\nvar ThrustingModes = {strs(c['thrusting_modes'])}\n\nvar CheckReasons = {strs(c['reasons'])}\n"
    body += "\n" + struct("GroundComponent", [("SuitePart", "string"), ("Part", "string"), ("Path", "string"), ("Definition", "string"), ("ProductName", "string"),
                                              ("Version", "string"), ("Simulator", "bool"), ("FlightSoftwareInTheLoop", "bool"), ("HardwareInTheLoop", "bool"), ("Text", "string")])
    body += "\n" + table("GroundComponents", "GroundComponent", [[s(x["suite_part"]), s(x["part"]), s(x["path"]), s(x["definition"]), s(x["product_name"]), s(x["version"]),
                                                                 b(x["simulator"]), b(x["flight_software_in_the_loop"]), b(x["hardware_in_the_loop"]), s(x["text"])] for x in g["components"]])
    body += "\n" + struct("RetentionRule", [("Rule", "string"), ("Level", "string"), ("Retention", "float64"), ("Unit", "string"), ("Distributed", "bool")])
    body += "\n" + table("RetentionRules", "RetentionRule", [[s(x["rule"]), s(x["level"]), f(x["retention"]), s(x["unit"]), b(x["distributed"])] for x in g["archive"]["rules"]])
    body += f"\nconst ChecksumWidth = {g['archive']['checksum_width']}\n"
    pr = g["proximity"]
    body += "\n" + struct("RelativeNavigationProduct", [("Name", "string"), ("Range", "Quantity"), ("RangeRate", "Quantity"), ("RangeUncertainty", "Quantity")])
    body += "\n" + table("ProximityProducts", "RelativeNavigationProduct",
                         [[s(n), f"Quantity{{{f(v['range']['value'])}, {s(v['range']['unit'])}}}", f"Quantity{{{f(v['rangeRate']['value'])}, {s(v['rangeRate']['unit'])}}}",
                           f"Quantity{{{f(v['rangeUncertainty']['value'])}, {s(v['rangeUncertainty']['unit'])}}}"] for n, v in pr["products"].items()])
    body += "\nvar ProximityLimits = map[string]Quantity{" + ", ".join(f"{s(k)}: {{{f(pr[k]['value'])}, {s(pr[k]['unit'])}}}" for k in ("keep_out_radius", "abort_range_rate", "abort_range_uncertainty")) + "}\n"
    body += "\n" + const_block([("ChecklistItemsTotal", "int", i(pr["checklist"]["items_total"])), ("ChecklistItemsGo", "int", i(pr["checklist"]["items_go"]))])
    pp = g["pass_planning"]
    body += "\n" + struct("Station", [("Name", "string"), ("Longitude", "float64"), ("Unit", "string")])
    body += "\n" + table("Stations", "Station", [[s(x["name"]), f(x["longitude"]), s(x["unit"])] for x in pp["stations"]])
    body += "\n" + struct("StationPass", [("Name", "string"), ("Station", "string"), ("Duration", "float64"), ("Unit", "string")])
    body += "\n" + table("StationPasses", "StationPass", [[s(x["name"]), s(x["station"]), f(x["duration"]), s(x["unit"])] for x in pp["passes"]])
    body += "\n" + struct("DownlinkActivity", [("Name", "string"), ("Volume", "float64"), ("Unit", "string")])
    body += "\n" + table("DownlinkActivities", "DownlinkActivity", [[s(x["name"]), f(x["volume"]), s(x["unit"])] for x in pp["activities"]])
    body += "\n" + struct("PassAllocation", [("Name", "string"), ("Activity", "string"), ("StationPass", "string")])
    body += "\n" + table("PassAllocations", "PassAllocation", [[s(x["name"]), s(x["activity"]), s(x["pass"])] for x in pp["allocations"]])
    body += f"\nvar VisibilityHalfWidth = Quantity{{{f(pp['visibility_half_width']['value'])}, {s(pp['visibility_half_width']['unit'])}}}\n"
    body += f"\nvar LockUp = Quantity{{{f(pp['lock_up']['value'])}, {s(pp['lock_up']['unit'])}}}\n"
    body += "\n" + const_block([("PlannedRateSet", "string", s(pp["planned_rate_set"])), ("PlannedMode", "string", s(pp["planned_mode"]))])
    for m in g["machines"]:
        body += f"\nvar {ident(m['name'])} = StateMachine{{\n\t{s(m['name'])}, {s(m['source'])}, {s(m['initial'])},\n\t[]State{{\n"
        for st in m["states"]:
            body += "\t\t{" + ", ".join([s(st["name"]), s(st["id"]), s(st["parent"]), s(st["initial"]), b(st["leaf"]), '""', '""']) + "},\n"
        body += "\t},\n\t[]Transition{\n"
        for tr in m["transitions"]:
            g_ = tr["trigger"]
            body += "\t\t{" + ", ".join([s(tr["source"]), s(tr["target"]), s(g_["event"]), s(g_["parameter"]), s(g_["port"]), s(g_["timed"]), s(tr["guard"]), s(tr["effect"]), s(tr["region"]), i(tr["line"] or 0)]) + "},\n"
        body += "\t},\n\t[]NamedExpression{" + ", ".join(f"{{{s(x['id'])}, {s(x['text'])}}}" for x in m["guards"]) + "},\n"
        body += "\t[]NamedExpression{" + ", ".join(f"{{{s(x['id'])}, {s(x['text'])}}}" for x in m["effects"]) + "},\n}\n"
    out["ground.go"] = file(pin, ["TethysOperations::noThrustDuringRelay … batteryDepthOfDischarge (FR-001 … FR-004) and their constraint definitions",
                                  "TethysSequence::OnBoardSequence specialisations", "TethysGroundSoftware::GroundSequenceCheck, FlightRuleChecker, CheckFlightRules",
                                  "TethysTugStructure::allFlightModes, thrustingModes", "TethysGroundSoftware::MeridianOperationsSuite (components)",
                                  "TethysGroundSoftware::DataArchive, ProximityPlanner, PassPlanner, PlannedDailyPassPlan", "TethysMeridian::MeridianNetwork",
                                  "TethysOperations::DailyPassPlan", "TethysGroundSoftware::AlarmLifecycle, AnomalyLifecycle",
                                  "TethysGroundSoftware::CommandVerdict, SequenceVerdict, AlarmSeverity, AnomalyDisposition, DecisionAuthority"], [], body)

    # -- lookups ---------------------------------------------------------------------------------------------------------------
    body = ("// Index maps from the tables' keys to row positions, built once at package initialisation.\n"
            "var (\n"
            "\tCommandsByOpcode    = map[int]int{}\n"
            "\tCommandsByMnemonic  = map[string]int{}\n"
            "\tTelemetryByID       = map[int]int{}\n"
            "\tTelemetryByMnemonic = map[string]int{}\n"
            "\tEventsByID          = map[int]int{}\n"
            "\tPacketsByApid       = map[int]int{}\n"
            "\tPacketsByMnemonic   = map[string]int{}\n"
            "\tParametersByID      = map[int]int{}\n"
            "\tModeRowsByName      = map[string]int{}\n"
            "\tRateSetByMode       = map[string]ModeRateSet{}\n"
            "\tMessagesByApid      = map[int]int{}\n"
            "\tIcdParametersByName = map[[2]string]IcdParameter{}\n"
            "\tStateMachinesByName = map[string]int{}\n"
            "\tFlightRulesByID     = map[string]int{}\n"
            "\tSequencesByID       = map[int]int{}\n"
            "\tComponentsByProduct = map[string]int{}\n"
            "\tComponentsByPath    = map[string]int{}\n"
            "\tStationsByName      = map[string]int{}\n"
            ")\n\n"
            "func init() {\n"
            "\tfor k, c := range Commands {\n\t\tCommandsByOpcode[c.Opcode] = k\n\t\tCommandsByMnemonic[c.Mnemonic] = k\n\t}\n"
            "\tfor k, t := range TelemetryPoints {\n\t\tTelemetryByID[t.ID] = k\n\t\tTelemetryByMnemonic[t.Mnemonic] = k\n\t}\n"
            "\tfor k, e := range Events {\n\t\tEventsByID[e.ID] = k\n\t}\n"
            "\tfor k, p := range Packets {\n\t\tPacketsByApid[p.Apid] = k\n\t\tPacketsByMnemonic[p.Mnemonic] = k\n\t}\n"
            "\tfor k, p := range Parameters {\n\t\tParametersByID[p.ID] = k\n\t}\n"
            "\tfor k, r := range ModeTable {\n\t\tModeRowsByName[r.Mode] = k\n\t}\n"
            "\tfor _, r := range ModeRateSets {\n\t\tRateSetByMode[r.Mode] = r\n\t}\n"
            "\tfor k, m := range Messages {\n\t\tMessagesByApid[m.Apid] = k\n\t}\n"
            "\tfor _, p := range IcdParameters {\n\t\tIcdParametersByName[[2]string{p.Icd, p.Name}] = p\n\t}\n"
            "\tfor k, m := range StateMachines {\n\t\tStateMachinesByName[m.Name] = k\n\t}\n"
            "\tfor k, r := range FlightRules {\n\t\tFlightRulesByID[r.ID] = k\n\t}\n"
            "\tfor k, q := range OnBoardSequences {\n\t\tSequencesByID[q.SequenceID] = k\n\t}\n"
            "\tfor k, c := range GroundComponents {\n\t\tComponentsByProduct[c.ProductName] = k\n\t\tComponentsByPath[c.Path] = k\n\t}\n"
            "\tfor k, st := range Stations {\n\t\tStationsByName[st.Name] = k\n\t}\n"
            "}\n")
    body += f"\nconst GeneratorVersion = {s(pin.get('generator', ''))}\n"
    body += f"const ModelToolVersion = {s(pin.get('version', ''))}\n"
    body += f"const ModelToolCommit = {s(pin.get('commit', ''))}\n"
    out["lookup.go"] = file(pin, ["every table of this package"], [], body)
    return out


def emit_module(pin: dict) -> dict[str, str]:
    """The ``go.mod`` beside the package, so a consumer can ``replace`` the module by path."""
    text = "".join(f"// {l}\n" for l in header_lines(pin, ["software/generated/go/argenttables"]))
    text += f"\nmodule {MODULE}\n\ngo 1.22\n"
    return {"go.mod": text}
