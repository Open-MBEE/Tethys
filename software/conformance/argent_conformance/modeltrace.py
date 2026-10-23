"""The model side of trace conformance: the pinned ``sysml-grpc`` executes a scenario's machine
with ``trace=True`` and this module rebuilds, from the entry/exit/transition records, every
machine's active configuration in the ``Current state:`` form the host writes (region leaves in
declaration order, separated by `` | ``). The region structure comes from the generated
``argent_tables`` so the rebuild is driven by the same tables the host runs."""
from __future__ import annotations

import time
from dataclasses import dataclass, field

from argent_tables import state_machines as tables

from .scenarios import MACHINE_MAP


def _magnitude(value):
    for attr in ("magnitude", "value"):
        if hasattr(value, attr):
            return float(getattr(value, attr))
    return float(value)


TABLES = {m.name: m for m in vars(tables).values() if isinstance(m, tables.StateMachine)}


def region_root(machine: tables.StateMachine, fqn: str) -> str:
    by_fqn = {s.qualified_name: s for s in machine.states}
    while by_fqn[fqn].parent is not None:
        fqn = by_fqn[fqn].parent
    return fqn


@dataclass
class Rebuild:
    """One machine instance's configuration rebuilt from its trace records."""
    machine: tables.StateMachine
    active: list = field(default_factory=list)
    changes: list = field(default_factory=list)     # (t, config)
    transitions: list = field(default_factory=list)  # (t, from, to, event)
    accepts: list = field(default_factory=list)      # (t, event)
    problems: list = field(default_factory=list)
    pseudo: list = field(default_factory=list)       # final states entered, which the tables do not carry

    def regions(self) -> list[str]:
        """Region roots in declaration order: every top-level state of a machine without an
        initial state of its own (orthogonal regions), else the machine itself (one region)."""
        if self.machine.initial is None:
            return [s.qualified_name for s in self.machine.states if s.parent is None]
        return [self.machine.source]

    def is_region(self, fqn: str) -> bool:
        return self.machine.initial is None and fqn in self.regions()

    def config(self) -> str:
        by_fqn = {s.qualified_name: s for s in self.machine.states}
        parts = []
        for root in self.regions():
            leaves = [a for a in self.active if (region_root(self.machine, a) == root if self.machine.initial is None else True)
                      and not any(by_fqn[b].parent == a for b in self.active)]
            parts.append(by_fqn[leaves[0]].name if leaves else "-")
        return " | ".join(parts)

    def enter(self, name: str):
        for s in self.machine.states:
            if s.name == name and s.qualified_name not in self.active and not self.is_region(s.qualified_name) \
                    and (s.parent is None or s.parent in self.active or self.is_region(s.parent)):
                self.active.append(s.qualified_name)
                return
        if not any(s.name == name for s in self.machine.states):
            self.pseudo.append(name)  # a final state: the generated tables carry no row for it
            return
        self.problems.append(f"entry of unknown or already active state {name!r}")

    def exit(self, name: str, hint_target: str | None):
        candidates = [a for a in self.active if a.rsplit("::", 1)[-1] == name]
        if len(candidates) > 1 and hint_target is not None:
            targets = [s for s in self.machine.states if s.name == hint_target]
            if targets:
                roots = {region_root(self.machine, t.qualified_name) for t in targets}
                narrowed = [c for c in candidates if region_root(self.machine, c) in roots]
                candidates = narrowed or candidates
        if not candidates:
            if name not in self.pseudo:
                self.problems.append(f"exit of inactive state {name!r}")
            return
        gone = candidates[0]
        self.active = [a for a in self.active if a != gone and not a.startswith(gone + "::")]


def rebuild(events, pinned_final: dict[str, str] | None = None) -> dict[str, Rebuild]:
    """Rebuild every mapped machine of a traced run; keys are host machine names."""
    machines: dict[str, Rebuild] = {}
    pending: dict[str, float] = {}

    def key(ev):
        element = ev.object.element.id if ev.object is not None and ev.object.element is not None else ""
        owner = element.rsplit("::", 1)[-1]
        return MACHINE_MAP.get((owner, ev.machine)), element

    def t_of(ev):
        return round(_magnitude(ev.time), 6) if ev.time is not None else 0.0

    next_transition_target = {}
    for i, ev in enumerate(events):
        if ev.kind == "exit":
            for later in events[i + 1:i + 4]:
                if later.kind == "transition" and later.from_state == ev.state and later.object is ev.object:
                    next_transition_target[i] = later.to_state
                    break
    seen_elements: dict[str, str] = {}
    for i, ev in enumerate(events):
        name, element = key(ev)
        if name is None:
            continue
        if name in seen_elements and seen_elements[name] != element:
            continue  # the system-level copy of a machine the software also runs
        seen_elements.setdefault(name, element)
        rb = machines.setdefault(name, Rebuild(TABLES[name]))
        t = t_of(ev)
        before = rb.config()
        if ev.kind == "entry":
            rb.enter(ev.state)
        elif ev.kind == "exit":
            rb.exit(ev.state, next_transition_target.get(i))
        elif ev.kind == "transition":
            rb.transitions.append((t, ev.from_state, ev.to_state, ev.event))
        elif ev.kind == "accept":
            rb.accepts.append((t, ev.event))
        after = rb.config()
        if after != before:
            if rb.changes and rb.changes[-1][0] == t:
                rb.changes[-1] = (t, after)
                if len(rb.changes) > 1 and rb.changes[-2][1] == after:
                    rb.changes.pop()  # a self-transition or a chain that returned to the configuration it left
            else:
                rb.changes.append((t, after))
    for name, rb in machines.items():
        if pinned_final and name in pinned_final and rb.changes and rb.changes[-1][1] != pinned_final[name]:
            rb.problems.append(f"rebuilt final configuration {rb.changes[-1][1]!r} differs from the pinned run's {pinned_final[name]!r}")
    return machines


def execute(bridge, run, trace_dir: str | None = None):
    """Run the pinned run on the model with a trace; returns (result dict, seconds)."""
    t0 = time.monotonic()
    result = bridge.model.execute_state(run.machine, performer=run.performer, trace=True, advance=float(run.advance))
    return result, time.monotonic() - t0
