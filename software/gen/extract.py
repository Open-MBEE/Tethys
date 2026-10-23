"""Normalise the selected model packages into plain table data.

Everything the emitters write comes out of ``extract``: one dictionary of lists and
dictionaries, every value a Python scalar, string or list, every list in a stated order, so the
emitters are formatting only.  Model values are read through the api-json element graph: a
feature's ``value`` is an expression element, and literal, reference, quantity (``[``), sequence
(``,``) and chain expressions are the forms the generated tables need.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field

from apijson import Element, ModelIndex

PACKAGES = (
    "TethysTugStructure", "TethysOperations", "TethysModes", "TethysFdir", "TethysFlightSoftware",
    "TethysFlightDictionary", "TethysFlightBehaviour", "TethysFlightTiming", "TethysSoftwareIcds",
    "TethysSequence", "TethysGroundSoftware", "TethysMeridian",
)

APP_MACHINES = (
    "SepStringController", "PowerManager", "ThermalController", "TelecomManager",
    "InspectorHandler", "CaptureController", "RedundancyManager", "BootUpdateManager",
)
ENUM_DEFS = (
    "TethysTugStructure__TugMode", "TethysOperations__ApidClass", "TethysFdir__FdirLevel",
    "TethysFdir__FaultResponse", "TethysFlightSoftware__SoftwareLayer",
    "TethysFlightSoftware__SchedulingPolicy", "TethysFlightSoftware__SoftwareCriticality",
    "TethysFlightDictionary__ApplicationName", "TethysFlightDictionary__CommandCriticality",
    "TethysFlightDictionary__EventSeverity", "TethysFlightDictionary__TelemetryKind",
    "TethysFlightBehaviour__LoadShedTier", "TethysFlightBehaviour__ImageSlot",
    "TethysSoftwareIcds__BusErrorResponse", "TethysSoftwareIcds__RegisterAccess",
)


def esc(name: str) -> str:
    """Spell a declared name as the tool's ids do (``_`` is ``_5f``)."""
    return name.replace("_", "_5f")


def qname(eid: str) -> str:
    """The qualified name an id stands for."""
    return eid.replace("__", "::").replace("_5f", "_")


@dataclass
class Quantity:
    value: float
    unit: str


@dataclass
class EnumRef:
    enum: str
    literal: str


@dataclass
class Ref:
    id: str

    @property
    def name(self):
        return qname(self.id).rsplit("::", 1)[-1]


@dataclass
class Expr:
    text: str


class Reader:
    """Typed reads over a ModelIndex."""

    def __init__(self, idx: ModelIndex, lib: dict[str, str]):
        self.idx = idx
        self.lib = lib

    # -- element access -------------------------------------------------------------------
    def el(self, eid) -> Element | None:
        return self.idx.elements.get(eid)

    def kids(self, eid, *types):
        return [k for k in self.idx.kids(eid) if not types or k.type in types]

    def member(self, eid, name) -> Element | None:
        return self.el(f"{eid}__{esc(name)}")

    def type_name(self, tid) -> str:
        if tid in self.lib:
            return self.lib[tid]
        return qname(tid)

    def types(self, eid) -> list[str]:
        return [self.type_name(t) for t in self.idx.types_of(eid)]

    # -- values -------------------------------------------------------------------------------
    def ev(self, eid, depth=0):
        e = self.el(eid)
        if e is None:
            return Ref(eid)
        t = e.type
        if t in ("LiteralInteger", "LiteralRational", "LiteralBoolean", "LiteralString"):
            return e.get("value")
        if t == "LiteralInfinity":
            return None
        if t == "FeatureReferenceExpression":
            r = e.get("referent")
            target = self.el(r)
            if target is None:
                return Expr(e.text or qname(r))
            if target.type == "EnumerationUsage":
                return EnumRef(qname(target.owner), target.name)
            if target.get("value") and depth < 4:
                return self.ev(target.get("value"), depth + 1)
            return Ref(r)
        if t == "OperatorExpression":
            op = e.get("operator")
            args = e.get("argument", [])
            if op == "[" and len(args) == 2:
                v = self.ev(args[0], depth)
                unit = self.el(args[1])
                return Quantity(float(v), unit.text if unit else "")
            if op == ",":
                return [self.ev(a, depth) for a in args]
            if op == "-" and len(args) == 1:
                v = self.ev(args[0], depth)
                if isinstance(v, (int, float)):
                    return -v
                if isinstance(v, Quantity):
                    return Quantity(-v.value, v.unit)
            return Expr(e.text or op)
        if t == "FeatureChainExpression" and e.get("targetFeature") and depth < 4:
            target = self.el(e.get("targetFeature"))
            if target is not None and target.get("value"):
                return self.ev(target.get("value"), depth + 1)
            return Expr(e.text or qname(e.get("targetFeature")))
        if t == "TriggerInvocationExpression":
            inner = [self.el(a) for a in e.get("argument", [])]
            kind = e.get("kind") or "after"
            return Expr(f"{kind} " + " ".join(i.text or "" for i in inner if i))
        return Expr(e.text or t)

    def attr(self, eid, name, default=None):
        """The value of a member, falling back to the value its classifiers declare."""
        m = self.member(eid, name)
        if m is not None and m.get("value"):
            return self.ev(m.get("value"))
        for t in self.idx.supertypes(eid):
            d = self.member(t, name)
            if d is not None and d.get("value"):
                return self.ev(d.get("value"))
        return default

    def text_of(self, eid) -> str:
        e = self.el(eid)
        return (e.text if e else None) or ""


# -- helpers -----------------------------------------------------------------------------------

def lit(v):
    """An EnumRef as its literal name, a Ref as its short name, else the value itself."""
    if isinstance(v, EnumRef):
        return v.literal
    if isinstance(v, Ref):
        return v.name
    if isinstance(v, Expr):
        return v.text
    return v


def qty(v, default_unit=""):
    if isinstance(v, Quantity):
        return v.value, v.unit
    if isinstance(v, (int, float)):
        return float(v), default_unit
    return None, default_unit


def mode_list(v, all_modes):
    """A mode set as literal names in TugMode order; an unreadable default means every mode."""
    def flat(x):
        if isinstance(x, list):
            for y in x:
                yield from flat(y)
        elif isinstance(x, EnumRef):
            yield x.literal
    if v is None:
        return []
    if isinstance(v, (list, EnumRef)):
        found = set(flat(v))
        return [m for m in all_modes if m in found]
    return list(all_modes)


UPPER = re.compile(r"(?<=[a-z0-9])(?=[A-Z])")


def snake(name: str) -> str:
    return UPPER.sub("_", name).replace("-", "_").lower()


def upper(name: str) -> str:
    return snake(name).upper()


# -- extraction ----------------------------------------------------------------------------------

def extract(rd: Reader) -> dict:
    out = {}
    enums = out["enums"] = {}
    for d in ENUM_DEFS:
        lits = [k.name for k in rd.kids(d, "EnumerationUsage")]
        enums[qname(d).rsplit("::", 1)[-1]] = {"source": qname(d), "literals": lits}
    modes = enums["TugMode"]["literals"]
    out["inspector_modes"] = inspector = machine(rd, "TethysModes__InspectorModes", "InspectorModes")
    enums["InspectorMode"] = {"source": "TethysModes::InspectorModes (leaf states)",
                              "literals": [s["name"] for s in inspector["states"] if s["leaf"]]}

    out["apid_classes"] = apids(rd)
    out["commands"] = commands(rd, modes)
    enums["Opcode"] = {"source": "TethysFlightDictionary::Opcode",
                       "literals": [k.name for k in rd.kids("TethysFlightDictionary__Opcode", "EnumerationUsage")],
                       "values": {c["mnemonic"]: c["opcode"] for c in out["commands"]}}
    out["telemetry"] = telemetry(rd)
    out["events"] = events(rd)
    enums["EventId"] = {"source": "TethysFlightDictionary::EventDefinition::eventId",
                        "literals": [e["mnemonic"] for e in out["events"]],
                        "values": {e["mnemonic"]: e["id"] for e in out["events"]}}
    out["packets"], out["primary_header"], out["time_code"] = packets(rd)
    point_packets = {}
    for p in out["packets"]:
        for f in p["fields"]:
            point_packets.setdefault(f["point"], []).append(p["mnemonic"])
    for t in out["telemetry"]:
        t["packets"] = point_packets.get(t["mnemonic"], [])
    out["parameter_tables"] = parameter_tables(rd)
    enums["ParameterId"] = {"source": "TethysFlightDictionary::ParameterRow::parameterId",
                            "literals": [], "values": {}}
    for tb in out["parameter_tables"]:
        for r in tb["rows"]:
            key = f"{upper(tb['owner'])}_{upper(r['name'])}"
            enums["ParameterId"]["literals"].append(key)
            enums["ParameterId"]["values"][key] = r["id"]
    out["limit_table"] = limit_table(rd)
    out["monitor_limits"] = monitor_limits(rd)
    out["fault_events"] = fault_events(rd)
    out["applications"] = applications(rd, modes)
    out["rate_sets"] = rate_sets(rd)
    out["mode_table"] = mode_table(rd, modes, out["applications"], out["rate_sets"])
    out["machines"] = [machine(rd, f"TethysFlightBehaviour__{n}", n) for n in APP_MACHINES]
    out["machines"].append(machine(rd, "TethysModes__TugModes", "TugModes"))
    out["machines"].append(machine(rd, "TethysFlightBehaviour__ModeManagementSoftware__dispatcher", "ModeManagementDispatcher"))
    out["machines"].append(machine(rd, "TethysFdir__FdirSupervisor", "FdirSupervisor"))
    out["machines"].append(machine(rd, "TethysFlightBehaviour__FdirSoftware__responseRelay", "FdirResponseRelay"))
    out["schedule"] = schedule(rd, modes, out["applications"])
    out["bus_schedule"] = bus_schedule(rd, modes)
    out["messages"], out["topics"] = messages(rd)
    out["bus_protocol"] = literal_attributes(rd, "TethysSoftwareIcds__OnBoardBusProtocolIcd")
    out["space_link"] = literal_attributes(rd, "TethysSoftwareIcds__SpaceLinkProfileIcd")
    out["relay_profile"] = literal_attributes(rd, "TethysSoftwareIcds__InspectorRelaySoftwareIcd")
    out["register_maps"] = register_maps(rd)
    out["ground"] = ground(rd, out["rate_sets"])
    return out


def apids(rd):
    rows = []
    for k in rd.kids("TethysOperations__ApidClass", "EnumerationUsage"):
        base = rd.attr("TethysFlightDictionary__flightApids", k.name)
        rows.append({"name": k.name, "base_apid": int(lit(base)) if base is not None else None})
    return rows


def commands(rd, modes):
    rows = []
    cmds = rd.attr("TethysFlightDictionary__flightDictionary", "commands") or []
    for ref in cmds:
        cid = ref.id
        args = []
        for a in rd.kids(cid, "AttributeUsage"):
            tys = rd.types(a.id)
            vt = [t for t in tys if not t.endswith("CommandArgument")]
            args.append({
                "name": a.name,
                "type": vt[0] if vt else "",
                "minimum": rd.attr(a.id, "minimum"),
                "maximum": rd.attr(a.id, "maximum"),
                "width_bits": int(rd.attr(a.id, "widthBits") or 0),
                "unit": lit(rd.attr(a.id, "unitSymbol", "")),
            })
        crit = lit(rd.attr(cid, "criticality"))
        rows.append({
            "item": qname(cid), "opcode": int(rd.attr(cid, "opcodeNumber")),
            "opcode_literal": lit(rd.attr(cid, "opcodeLiteral")), "mnemonic": rd.attr(cid, "mnemonic"),
            "application": lit(rd.attr(cid, "application")), "apid": int(rd.attr(cid, "apid")),
            "apid_class": lit(rd.attr(cid, "apidClass")), "criticality": crit,
            "hazardous": bool(rd.attr(cid, "hazardous")), "two_step": crit in ("critical", "hazardous"),
            "allowed_modes": mode_list(rd.attr(cid, "allowedModes"), modes),
            "argument_bits": int(rd.attr(cid, "argumentBits") or 0), "arguments": args,
        })
    rows.sort(key=lambda r: r["opcode"])
    return rows


LIMITS = ("redLow", "yellowLow", "yellowHigh", "redHigh")


def telemetry(rd):
    rows = []
    pts = rd.attr("TethysFlightDictionary__flightDictionary", "telemetryPoints") or []
    for ref in pts:
        pid = ref.id
        tys = rd.types(pid)
        rate, _ = qty(rd.attr(pid, "rate"), "Hz")
        row = {
            "item": qname(pid), "id": int(rd.attr(pid, "pointId")), "mnemonic": rd.attr(pid, "mnemonic"),
            "point_type": tys[0].rsplit("::", 1)[-1] if tys else "", "kind": lit(rd.attr(pid, "kind")),
            "source": lit(rd.attr(pid, "source")), "apid_class": lit(rd.attr(pid, "apidClass")),
            "rate_hz": rate, "width_bits": int(rd.attr(pid, "widthBits") or 0),
            "unit": lit(rd.attr(pid, "unitSymbol", "")),
        }
        vt = rd.member(pid, "value") or next((rd.member(t, "value") for t in rd.idx.supertypes(pid) if rd.member(t, "value")), None)
        row["value_type"] = rd.types(vt.id)[0] if vt is not None and rd.types(vt.id) else ""
        for lim in LIMITS:
            v, _ = qty(rd.attr(pid, lim))
            row[snake(lim)] = v
        rows.append(row)
    rows.sort(key=lambda r: r["id"])
    return rows


def events(rd):
    rows = []
    evs = rd.attr("TethysFlightDictionary__flightDictionary", "events") or []
    for ref in evs:
        eid = ref.id
        rows.append({
            "item": qname(eid), "id": int(rd.attr(eid, "eventId")), "mnemonic": rd.attr(eid, "mnemonic"),
            "source": lit(rd.attr(eid, "source")), "severity": lit(rd.attr(eid, "severity")),
            "text": rd.attr(eid, "text"), "fdir_relevant": bool(rd.attr(eid, "fdirRelevant")),
            "is_fault": bool(rd.attr(eid, "isFault")), "level": lit(rd.attr(eid, "level")),
        })
    rows.sort(key=lambda r: r["id"])
    return rows


def packets(rd):
    rows = []
    pks = rd.attr("TethysFlightDictionary__flightDictionary", "packets") or []
    for ref in pks:
        pid = ref.id
        fields = []
        for f in rd.kids(pid, "AttributeUsage"):
            if "PacketField" not in "".join(rd.types(f.id)):
                continue
            fields.append({"name": f.name, "order": int(rd.attr(f.id, "order")), "offset_bits": int(rd.attr(f.id, "offset")),
                           "width_bits": int(rd.attr(f.id, "width")), "point": rd.attr(f.id, "point")})
        fields.sort(key=lambda x: x["order"])
        rate, _ = qty(rd.attr(pid, "rate"), "Hz")
        rows.append({
            "item": qname(pid), "id": int(rd.attr(pid, "packetId")), "mnemonic": rd.attr(pid, "mnemonic"),
            "apid": int(rd.attr(pid, "apid")), "apid_class": lit(rd.attr(pid, "apidClass")),
            "source": lit(rd.attr(pid, "source")), "rate_hz": rate,
            "field_count": int(rd.attr(pid, "fieldCount")), "length_octets": int(rd.attr(pid, "lengthOctets")),
            "header_bits": min(f["offset_bits"] for f in fields) if fields else 0,
            "fields": fields,
        })
    rows.sort(key=lambda r: r["id"])
    header = literal_attributes(rd, "TethysFlightDictionary__PrimaryHeaderLayout")
    time_code = literal_attributes(rd, "TethysFlightDictionary__TethysTimeCode")
    return rows, header, time_code


def parameter_tables(rd):
    tables = []
    refs = rd.attr("TethysFlightDictionary__flightDictionary", "parameterTables") or []
    for ref in refs:
        tid = ref.id
        rows = []
        for r in rd.kids(tid, "AttributeUsage"):
            if "ParameterRow" not in "".join(rd.types(r.id)):
                continue
            rows.append({"id": int(rd.attr(r.id, "parameterId")), "name": rd.attr(r.id, "name"),
                         "owner": lit(rd.attr(r.id, "owner")), "value": float(rd.attr(r.id, "value")),
                         "minimum": float(rd.attr(r.id, "minimum")), "maximum": float(rd.attr(r.id, "maximum")),
                         "unit": rd.attr(r.id, "unitSymbol", "")})
        rows.sort(key=lambda x: x["id"])
        tables.append({"item": qname(tid), "table_id": int(rd.attr(tid, "tableId")),
                       "owner": lit(rd.attr(tid, "owner")), "rows": rows})
    tables.sort(key=lambda t: t["table_id"])
    return tables


def limit_table(rd):
    tid = "TethysFlightDictionary__flightLimitTable"
    rows = []
    for k in rd.kids(tid, "ReferenceUsage", "AttributeUsage"):
        name = qname(k.id).rsplit("::", 1)[-1]
        if name == "tableId" or not k.get("value"):
            continue
        v = rd.ev(k.get("value"))
        val, unit = qty(v)
        rows.append({"name": name, "value": val if val is not None else lit(v), "unit": unit})
    return {"item": qname(tid), "table_id": int(rd.attr(tid, "tableId")), "rows": rows}


def monitor_limits(rd):
    rows = []
    for owner in ("TethysFdir__cruiseLimits", "TethysFlightDictionary__tableLimits"):
        if rd.el(owner) is None:
            continue
        for k in rd.kids(owner, "ReferenceUsage", "AttributeUsage"):
            if not k.get("value"):
                continue
            v = rd.ev(k.get("value"))
            val, unit = qty(v)
            rows.append({"set": qname(owner), "name": qname(k.id).rsplit("::", 1)[-1],
                         "value": val if val is not None else lit(v), "unit": unit, "text": rd.text_of(k.get("value"))})
    return rows


def fault_events(rd):
    rows = []
    for k in rd.kids("TethysFdir", "ItemDefinition"):
        gens = [qname(g) for g in rd.idx.generals.get(k.id, [])]
        if "TethysFdir::FaultEvent" not in gens:
            continue
        fields = [(a.name, rd.types(a.id)[0] if rd.types(a.id) else "") for a in rd.kids(k.id, "AttributeUsage")]
        rows.append({"name": k.name, "level": lit(rd.attr(k.id, "level")), "fields": fields})
    return rows


def applications(rd, modes):
    rows = []
    for k in rd.kids("TethysFlightSoftware__ArgentFlightSoftware", "PartUsage"):
        tys = rd.idx.supertypes(k.id)
        if "TethysFlightSoftware__Application" not in tys:
            continue
        rate, _ = qty(rd.attr(k.id, "rate"), "Hz")
        rows.append({
            "name": k.name, "definition": qname(tys[0]).rsplit("::", 1)[-1], "rate_hz": rate,
            "priority": int(rd.attr(k.id, "priority") or 0), "layer": lit(rd.attr(k.id, "layer")),
            "criticality": lit(rd.attr(k.id, "criticality")),
            "active_modes": mode_list(rd.attr(k.id, "activeModes"), modes),
        })
    return rows


def rate_sets(rd):
    rows = []
    for k in rd.kids("TethysSoftwareIcds__SpaceLinkProfileIcd", "AttributeUsage"):
        if "TethysSoftwareIcds::LinkRateSet" not in rd.types(k.id):
            continue
        dl, _ = qty(rd.attr(k.id, "downlinkRate"))
        ul, _ = qty(rd.attr(k.id, "uplinkRate"))
        hk, _ = qty(rd.attr(k.id, "housekeepingPeriod"))
        rows.append({"name": k.name, "mode": lit(rd.attr(k.id, "mode")), "downlink_bit_s": dl,
                     "uplink_bit_s": ul, "housekeeping_period_s": hk})
    return rows


def mode_table(rd, modes, apps, rate_sets):
    by_mode = {r["mode"]: r for r in rate_sets}
    rows = []
    for i, m in enumerate(modes):
        rid = f"TethysModes__TugModeTable__{esc(m)}"
        flags = {}
        for k in rd.kids(rid, "ReferenceUsage", "AttributeUsage"):
            name = qname(k.id).rsplit("::", 1)[-1]
            if name == "mode" or not k.get("value"):
                continue
            v = rd.ev(k.get("value"))
            if isinstance(v, bool):
                flags[name] = v
        rs = by_mode.get(m)
        rows.append({"index": i, "mode": m, "flags": flags,
                     "active_applications": [a["name"] for a in apps if m in a["active_modes"]],
                     "rate_set": rs["name"] if rs else None})
    return rows


# -- state machines ----------------------------------------------------------------------------------

def action_text(rd, eid) -> str:
    e = rd.el(eid)
    if e is None:
        return ""
    if e.type == "AssignmentActionUsage":
        target = rd.el(f"{eid}_ptarget")
        tt = target.text if target is not None and target.text else qname((target.get("referent") if target else "") or "").rsplit("::", 1)[-1]
        return f"{tt} := {rd.text_of(e.get('value'))}"
    if e.type == "SendActionUsage":
        payload = rd.text_of(f"{eid}_ppayload")
        receiver = rd.text_of(f"{eid}_preceiver")
        return f"send {payload}" + (f" via {receiver}" if receiver else "")
    steps = [action_text(rd, k.id) for k in rd.kids(eid) if k.type.endswith("ActionUsage")]
    steps = [s for s in steps if s]
    if e.name and steps:
        return f"{e.name}: " + "; ".join(steps)
    if steps:
        return "; ".join(steps)
    return e.name or e.text or e.type


def machine(rd, root, name) -> dict:
    states, transitions = [], []
    guards: dict[str, str] = {}
    effects: dict[str, str] = {}

    def walk(sid, parent, depth):
        subs = rd.kids(sid, "StateUsage")
        init = None
        entry_actions = []
        for k in rd.kids(sid, "SuccessionAsUsage"):
            if k.get("sysx:sourceMember") and k.get("targetFeature"):
                init = qname(k.get("targetFeature")[0])
        for k in rd.kids(sid, "StateSubactionMembership"):
            act = k.get("ownedMemberElement")
            if act:
                entry_actions.append((k.get("kind"), action_text(rd, act)))
        if sid != root:
            states.append({"id": qname(sid), "name": rd.el(sid).name, "parent": parent, "depth": depth,
                           "initial": init, "leaf": not subs, "actions": entry_actions})
        else:
            states_meta["initial"] = init
        for s in subs:
            walk(s.id, qname(sid) if sid != root else None, depth + 1)
        for t in rd.kids(sid, "TransitionUsage"):
            transitions.append(transition(rd, t, qname(sid) if sid != root else None, guards, effects, name))

    states_meta = {"initial": None}
    walk(root, None, 0)
    return {"name": name, "source": qname(root), "kind": rd.el(root).type if rd.el(root) else "",
            "initial": states_meta["initial"], "states": states, "transitions": transitions,
            "guards": [{"id": gid, "text": txt} for txt, gid in guards.items()],
            "effects": [{"id": fid, "text": txt} for txt, fid in effects.items()]}


def transition(rd, t, region, guards, effects, mname):
    trig = {"event": None, "parameter": None, "port": None, "timed": None}
    for a in t.get("triggerAction", []) or []:
        acc = rd.el(a)
        if acc is None:
            continue
        pp = rd.el(acc.get("payloadParameter") or "")
        if pp is not None:
            tys = rd.types(pp.id)
            trig["event"] = tys[0].rsplit("::", 1)[-1] if tys else None
            trig["parameter"] = pp.name
        if acc.get("payloadArgument"):
            v = rd.ev(acc.get("payloadArgument"))
            trig["timed"] = v.text if isinstance(v, Expr) else str(lit(v))
        if acc.get("receiverArgument"):
            v = rd.ev(acc.get("receiverArgument"))
            trig["port"] = lit(v) if not isinstance(v, Expr) else v.text
    guard = None
    for g in t.get("guardExpression", []) or []:
        text = rd.text_of(g) or qname(g)
        guard = guards.setdefault(text, f"{upper(mname)}_G{len(guards) + 1}")
    effect = None
    for f in t.get("effectAction", []) or []:
        text = action_text(rd, f)
        effect = effects.setdefault(text, f"{upper(mname)}_E{len(effects) + 1}")
    return {"region": region, "source": qname(t.get("source")) if t.get("source") else None,
            "target": qname(t.get("target")) if t.get("target") else "done", "line": t.line,
            "trigger": trig, "guard": guard, "effect": effect}


# -- timing, bus, interfaces -----------------------------------------------------------------------------

def schedule(rd, modes, apps):
    ft = "TethysFlightTiming__FlightTiming"
    minor, _ = qty(rd.attr(ft, "minorFramePeriod"))
    major, _ = qty(rd.attr(ft, "majorFramePeriod"))
    rgs = []
    for k in rd.kids(ft, "PartUsage"):
        if "TethysFlightTiming::RateGroup" not in rd.types(k.id) or k.get("value"):
            continue
        rate, _ = qty(rd.attr(k.id, "rate"))
        period, _ = qty(rd.attr(k.id, "period"))
        rgs.append({"name": k.name, "rate_hz": rate, "period_s": period,
                    "activations_per_major_frame": int(rd.attr(k.id, "activationsPerMajorFrame") or 0)})
    exe = "TethysFlightSoftware__ArgentFlightSoftware__executive"
    partitions = []
    for k in rd.kids(exe, "PartUsage"):
        window, _ = qty(rd.attr(k.id, "windowDuration"))
        mem, _ = qty(rd.attr(k.id, "memoryBudget"))
        partitions.append({"name": k.name, "window_s": window, "memory_bytes": mem,
                           "criticality": lit(rd.attr(k.id, "criticality")), "restartable": bool(rd.attr(k.id, "restartable"))})
    schedules = []
    at = "TethysFlightTiming__argentTiming"
    for s in rd.kids(at, "PartUsage"):
        if "TethysFlightTiming::PartitionSchedule" not in rd.types(s.id):
            continue
        slices, tasks = [], []
        for k in rd.kids(s.id, "PartUsage"):
            tys = rd.types(k.id)
            if "TethysFlightTiming::FrameSlice" in tys:
                d, _ = qty(rd.attr(k.id, "duration"))
                slices.append({"name": k.name, "duration_s": d})
            elif any(x in tys for x in ("TethysFlightTiming::ScheduledTask", "TethysFlightTiming::ApplicationTask")):
                wcet, _ = qty(rd.attr(k.id, "wcet"))
                period, _ = qty(rd.attr(k.id, "period"))
                deadline, _ = qty(rd.attr(k.id, "deadline"))
                ff = rd.attr(k.id, "firingFrames")
                rg_name = rd.text_of((rd.member(k.id, "rateGroup") or Element("", "", None, 0, 0, None)).get("value") or "")
                rg = next((r for r in rgs if r["name"] == rg_name), None)
                if period is None and rg:
                    period = rg["period_s"]
                if deadline is None:
                    deadline = period
                am = rd.attr(k.id, "activeModes")
                comp = rd.text_of((rd.member(k.id, "component") or Element("", "", None, 0, 0, None)).get("value") or "")
                if isinstance(am, Expr):
                    app = next((a for a in apps if a["name"] == comp.rsplit(".", 1)[-1]), None)
                    active = list(app["active_modes"]) if app else list(modes)
                else:
                    active = mode_list(am, modes)
                tasks.append({
                    "name": k.name, "kind": tys[0].rsplit("::", 1)[-1],
                    "component": comp, "rate_group": rg_name,
                    "wcet_s": wcet, "period_s": period, "deadline_s": deadline,
                    "firing_frames": [int(x) for x in ff] if isinstance(ff, list) else ([int(ff)] if isinstance(ff, (int, float)) else []),
                    "active_modes": active,
                })
        schedules.append({"name": s.name, "partition": rd.text_of((rd.member(s.id, "partition") or Element("", "", None, 0, 0, None)).get("value") or ""),
                          "slices": slices, "tasks": tasks})
    exec_def = "TethysFlightSoftware__KestrelExecutive"
    frames = rd.attr(exec_def, "minorFramesPerMajorFrame")
    return {"minor_frame_period_s": minor, "major_frame_period_s": major,
            "minor_frames_per_major_frame": int(frames) if isinstance(frames, (int, float)) else None,
            "rate_groups": rgs, "partitions": partitions, "partition_schedules": schedules}


def bus_schedule(rd, modes):
    b = "TethysFlightTiming__argentBus"
    fp, _ = qty(rd.attr(b, "framePeriod"))
    sl, _ = qty(rd.attr(b, "slotLength"))
    streams = []
    for k in rd.kids(b, "PartUsage"):
        if "TethysFlightTiming::BusSlotAssignment" not in rd.types(k.id):
            continue
        ml, _ = qty(rd.attr(k.id, "messageLength"))
        streams.append({"name": k.name, "node": rd.attr(k.id, "node"), "slots_per_frame": int(rd.attr(k.id, "slotsPerFrame") or 0),
                        "message_length_bytes": ml, "active_modes": mode_list(rd.attr(k.id, "activeModes"), modes)})
    per_mode = [{"mode": m, "slots_used": sum(s["slots_per_frame"] for s in streams if m in s["active_modes"]),
                 "bytes_per_frame": sum(s["slots_per_frame"] * (s["message_length_bytes"] or 0) for s in streams if m in s["active_modes"])}
                for m in modes]
    return {"item": qname(b), "frame_slots": int(rd.attr(b, "frameSlots") or 0), "frame_period_s": fp,
            "slot_length_bytes": sl, "streams": streams, "per_mode": per_mode}


def messages(rd):
    rows = []
    cat = "TethysSoftwareIcds__MessageCatalogue"
    for k in rd.kids(cat, "ItemUsage"):
        tys = rd.types(k.id)
        if not tys:
            continue
        length, _ = qty(rd.attr(k.id, "length"))
        period, _ = qty(rd.attr(k.id, "period"))
        rows.append({"name": k.name, "type": tys[0].rsplit("::", 1)[-1], "apid": int(rd.attr(k.id, "apid") or 0),
                     "length_bytes": length, "period_s": period})
    rows.sort(key=lambda r: r["apid"])
    topics = []
    for k in rd.kids("TethysSoftwareIcds__argentSoftwareIcds", "InterfaceUsage"):
        tys = rd.types(k.id)
        if not tys or not tys[0].endswith("Topic"):
            continue
        payload = rd.member(k.id, "payload")
        ends = []
        for e in rd.kids(k.id):
            if not e.type.endswith("Usage") or e.name is None or e.name == "payload":
                continue
            chain = [rd.el(c.id) for c in rd.kids(f"{e.id}_pchain", "FeatureChaining")]
            names = [qname(c.get("target")[0]).rsplit("::", 1)[-1] for c in chain if c.get("target")]
            ends.append({"end": e.name, "feature": ".".join(names)})
        topics.append({"name": k.name, "kind": tys[0].rsplit("::", 1)[-1],
                       "payload": rd.types(payload.id)[0].rsplit("::", 1)[-1] if payload is not None and rd.types(payload.id) else "",
                       "ends": ends})
    return rows, topics


def literal_attributes(rd, eid):
    rows = []
    for k in rd.kids(eid, "AttributeUsage", "ReferenceUsage"):
        if not k.get("value"):
            continue
        v = rd.ev(k.get("value"))
        if isinstance(v, Expr) or isinstance(v, list) or isinstance(v, Ref):
            continue
        val, unit = qty(v)
        name = qname(k.id).rsplit("::", 1)[-1]
        if isinstance(v, Quantity):
            rows.append({"name": name, "value": val, "unit": unit})
        else:
            rows.append({"name": name, "value": lit(v), "unit": ""})
    return {"source": qname(eid), "rows": rows}


def register_maps(rd):
    maps = []
    for d in ("TethysSoftwareIcds__ThermalPropulsionRiuRegisterMap", "TethysSoftwareIcds__MechanismRiuRegisterMap"):
        regs = []
        for k in rd.kids(d, "AttributeUsage"):
            if "TethysSoftwareIcds::RegisterEntry" not in rd.types(k.id):
                continue
            regs.append({"name": k.name, "address": int(rd.attr(k.id, "address")), "width_bits": int(rd.attr(k.id, "width")),
                         "meaning": rd.attr(k.id, "meaning"), "access": lit(rd.attr(k.id, "access"))})
        regs.sort(key=lambda r: r["address"])
        maps.append({"name": qname(d).rsplit("::", 1)[-1], "source": qname(d),
                     "address_limit": int(rd.attr(d, "addressLimit") or 0), "data_width_bits": int(rd.attr(d, "dataWidth") or 0),
                     "registers": regs})
    return maps


# -- ground software ---------------------------------------------------------------------------

def doc_of(rd, eid) -> str:
    """The element's documentation body, whitespace-collapsed."""
    for k in rd.kids(eid, "Documentation"):
        return " ".join((k.get("body") or "").split())
    return ""


def result_text(rd, eid) -> str:
    """The source text of a constraint or calc definition's result expression."""
    for k in rd.kids(eid):
        if k.type.endswith("Expression") and (k.text or "").strip():
            return " ".join(k.text.split())
    return ""


def literal_members(rd, eid) -> dict:
    """``name → (value, unit)`` of the literal-valued attributes of an element."""
    rows = {}
    for r in literal_attributes(rd, eid)["rows"]:
        rows[r["name"]] = (r["value"], r["unit"])
    return rows


def chain_tail(v) -> str:
    """The last segment of a feature-chain expression (``a.b.c`` → ``c``)."""
    return lit(v).replace("::", ".").rsplit(".", 1)[-1] if isinstance(v, (Expr, Ref)) else str(v)


def ground(rd, rate_sets) -> dict:
    """The ground-software tables: flight rules (53), on-board sequences (61), the checker's
    constants, the suite's components, retention, proximity and pass-planning data (69, 50)."""
    ops = "TethysOperations"
    constraints = {}
    for k in rd.kids(ops, "ConstraintDefinition"):
        m = re.match(r"(FR-\d+):", doc_of(rd, k.id))
        if m:
            constraints[m.group(1)] = k
    rules = []
    for k in rd.kids(ops, "RequirementUsage"):
        short = k.get("declaredShortName") or ""
        if not short.startswith("FR-"):
            continue
        c = constraints.get(short)
        params = [{"name": n, "value": v, "unit": u} for n, (v, u) in literal_members(rd, k.id).items()]
        rules.append({"id": short, "name": k.name, "item": qname(k.id), "text": doc_of(rd, k.id),
                      "constraint": qname(c.id) if c else "", "expression": result_text(rd, c.id) if c else "",
                      "inputs": [x.name for x in rd.kids(c.id, "ReferenceUsage", "AttributeUsage")] if c else [],
                      "parameters": params})
    rules.sort(key=lambda r: r["id"])

    sequences = []
    for k in rd.kids("TethysSequence", "ActionDefinition"):
        if "TethysSequence__OnBoardSequence" not in rd.idx.supertypes(k.id) or k.id == "TethysSequence__OnBoardSequence":
            continue
        sequences.append({"sequence_id": int(rd.attr(k.id, "sequenceId") or 0), "name": k.name, "item": qname(k.id),
                          "time_tagged": bool(rd.attr(k.id, "timeTagged", True)), "text": doc_of(rd, k.id)})
    sequences.sort(key=lambda s_: s_["sequence_id"])

    gs = "TethysGroundSoftware"
    stored = rd.attr(f"{gs}__FlightRuleChecker", "storedSequences") or []
    limits = {}
    for name in ("keepOutRadius", "exclusionHalfAngle", "stateOfChargeFloor"):
        v, u = qty(rd.attr(f"{gs}__GroundSequenceCheck__rules", name))
        limits[name] = {"value": v, "unit": u}
    flight_modes = [lit(m) for group in (rd.attr("TethysTugStructure", "allFlightModes") or []) for m in (group if isinstance(group, list) else [group])]
    thrusting_modes = [lit(m) for m in (rd.attr("TethysTugStructure", "thrustingModes") or [])]
    check = {"source": f"{gs}::GroundSequenceCheck", "stored_sequences": [int(x) for x in stored], "limits": limits,
             "flight_modes": flight_modes, "thrusting_modes": thrusting_modes,
             "reasons": [], "verdicts": [x.name for x in rd.kids(f"{gs}__SequenceVerdict", "EnumerationUsage")]}
    check["reasons"] = re.findall(r'"([^"]*)"', result_text(rd, f"{gs}__CheckFlightRules__violated") or rd.text_of(f"{gs}__CheckFlightRules__violated_pvalue"))

    suite_parts = {}
    for p in rd.kids(f"{gs}__MeridianOperationsSuite", "PartUsage"):
        for tname in rd.idx.types_of(p.id):
            suite_parts[tname] = p.name
    components = []
    for container in ("SoftwareOperationsCentre", "SoftwareFlightDynamics", "SoftwareScienceDataSystem", "SimulatedTestBedSet"):
        cid = f"{gs}__{container}"
        suite_part = suite_parts.get(cid, "")
        for p in sorted(rd.kids(cid, "PartUsage"), key=lambda x: x.index):
            for tid in rd.idx.types_of(p.id):
                if rd.attr(tid, "productName") is None:
                    continue
                pname = p.name or qname(p.id).rsplit("::", 1)[-1]
                components.append({"suite_part": suite_part, "part": pname, "path": f"{suite_part}.{pname}", "definition": qname(tid),
                                   "product_name": lit(rd.attr(tid, "productName")), "version": lit(rd.attr(tid, "version")),
                                   "simulator": container == "SimulatedTestBedSet",
                                   "flight_software_in_the_loop": bool(rd.attr(tid, "flightSoftwareInTheLoop", False)),
                                   "hardware_in_the_loop": bool(rd.attr(tid, "hardwareInTheLoop", False)),
                                   "text": doc_of(rd, tid)})

    retention = []
    for k in sorted(rd.kids(f"{gs}__DataArchive", "AttributeUsage"), key=lambda x: x.index):
        if f"{gs}__RetentionRule" not in rd.idx.types_of(k.id) or rd.attr(k.id, "level") is None:
            continue
        v, u = qty(rd.attr(k.id, "retention"))
        retention.append({"rule": k.name, "level": lit(rd.attr(k.id, "level")), "retention": v, "unit": u,
                          "distributed": bool(rd.attr(k.id, "distributed"))})
    archive = {"checksum_width": int(rd.attr(f"{gs}__DataArchive", "checksumWidth") or 0), "rules": retention}

    pp = f"{gs}__ProximityPlanner"
    products = {}
    for k in rd.kids(pp, "AttributeUsage"):
        if f"{gs}__RelativeNavigationProduct" in rd.idx.types_of(k.id):
            products[k.name] = {n: {"value": v, "unit": u} for n, (v, u) in literal_members(rd, k.id).items()}
    checklist = literal_members(rd, f"{pp}__checklist")
    proximity = {"keep_out_radius": dict(zip(("value", "unit"), qty(rd.attr(pp, "keepOutRadius")))),
                 "abort_range_rate": dict(zip(("value", "unit"), qty(rd.attr(pp, "abortRangeRate")))),
                 "abort_range_uncertainty": dict(zip(("value", "unit"), qty(rd.attr(pp, "abortRangeUncertainty")))),
                 "products": products,
                 "checklist": {"items_total": int(checklist.get("itemsTotal", (0, ""))[0] or 0), "items_go": int(checklist.get("itemsGo", (0, ""))[0] or 0)}}

    stations = []
    for k in sorted(rd.kids("TethysMeridian__MeridianNetwork", "PartUsage"), key=lambda x: x.index):
        lon = rd.attr(k.id, "longitude")
        if lon is None:
            continue
        v, u = qty(lon)
        stations.append({"name": k.name, "longitude": v, "unit": u})
    passes = []
    for k in sorted(rd.kids(f"{ops}__DailyPassPlan", "OccurrenceUsage"), key=lambda x: x.index):
        members = {qname(c.id).rsplit("::", 1)[-1]: rd.ev(c.get("value")) for c in rd.kids(k.id) if c.get("value")}
        if "passDuration" not in members:
            continue
        d, du = qty(members["passDuration"])
        passes.append({"name": k.name, "station": chain_tail(members.get("station", "")), "duration": d, "unit": du})
    activities = []
    for k in sorted(rd.kids(f"{ops}__DailyPassPlan", "PerformActionUsage"), key=lambda x: x.index):
        members = {qname(c.id).rsplit("::", 1)[-1]: rd.ev(c.get("value")) for c in rd.kids(k.id) if c.get("value")}
        if "volume" not in members:
            continue
        v, u = qty(members["volume"])
        activities.append({"name": k.name, "volume": v, "unit": u})
    allocations = []
    for k in rd.kids(f"{ops}__DailyPassPlan", "AllocationUsage"):
        ends = [qname(rs.get("referencedFeature")).rsplit("::", 1)[-1] for e in rd.kids(k.id, "ReferenceUsage")
                for rs in rd.kids(e.id, "ReferenceSubsetting") if rs.get("referencedFeature")]
        if k.name and len(ends) == 2:
            allocations.append({"name": k.name, "activity": ends[0], "pass": ends[1]})
    rate_name = chain_tail(rd.attr(f"{gs}__PassPlanner__plannedDay", "rateSet") or rd.attr(f"{gs}__PassPlanner", "proximityRates") or "")
    planned_mode = next((r["mode"] for r in rate_sets if r["name"] == rate_name), "")
    hw, hu = qty(rd.attr(f"{gs}__PassPlanner", "visibilityHalfWidth"))
    lu, luu = qty(rd.attr(f"{gs}__PlannedDailyPassPlan", "lockUp"))
    pass_planning = {"visibility_half_width": {"value": hw, "unit": hu}, "lock_up": {"value": lu, "unit": luu},
                     "planned_rate_set": rate_name, "planned_mode": planned_mode, "stations": stations, "passes": passes,
                     "activities": activities, "allocations": allocations}

    machines = [machine(rd, f"{gs}__AlarmLifecycle", "AlarmLifecycle"), machine(rd, f"{gs}__AnomalyLifecycle", "AnomalyLifecycle")]
    enums = {}
    for e in ("CommandVerdict", "SequenceVerdict", "AlarmSeverity", "AnomalyDisposition", "DecisionAuthority"):
        enums[e] = {"source": f"{gs}::{e}", "literals": [x.name for x in rd.kids(f"{gs}__{e}", "EnumerationUsage")]}
    return {"flight_rules": rules, "sequences": sequences, "check": check, "components": components, "archive": archive,
            "proximity": proximity, "pass_planning": pass_planning, "machines": machines, "enums": enums}
