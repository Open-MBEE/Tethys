"""Trace conformance: every pinned run on the host and on the model, every machine's
configuration changes compared in order and in time, written as one expectation file per run."""
from __future__ import annotations

import os
import re

from . import EXPECTED, OUT, ROOT
from .hosttrace import parse, run_host
from .modeltrace import execute, rebuild
from .scenarios import ADJUDICATED, HOST_MACHINES, RUNS


def pinned_final(run) -> dict[str, str]:
    """``Current state:`` lines of the pinned run, keyed by host machine name where known."""
    path = os.path.join(ROOT, "runs", run.name + ".txt")
    out = {}
    if os.path.exists(path):
        with open(path) as f:
            for line in f:
                m = re.match(r"\s*Current state:\s*(.*)$", line)
                if m:
                    out["__pinned__"] = m.group(1).strip()
    return out


def fmt_t(t: float) -> str:
    t = round(float(t), 6)
    return f"{t:.0f}" if t.is_integer() else f"{t:.6f}".rstrip("0").rstrip(".")


def compare_run(run, bridge, measurements) -> tuple[str, dict]:
    stats = {"machines": 0, "agree": 0, "diverge": 0, "host_only": 0, "changes": 0, "transitions": 0, "accepts": 0}
    lines = [f"run {run.name}: scenario {run.scenario}, machine {run.machine} on {run.performer}, horizon {run.advance} s"]
    with measurements.measure(f"host {run.name}") as m:
        path, _, rc = run_host(run)
        m.output_bytes = os.path.getsize(path)
    host = parse(path)
    lines.append(f"host: {host.records} traced frames, {host.skips} skips, {len(host.events)} events, {len(host.commands)} commands, final mode {host.final_mode}, rc {rc}")
    with measurements.measure(f"model {run.name}") as m:
        result, _ = execute(bridge, run)
        m.output_bytes = sum(len(ev.text or "") for ev in result["trace"])
    model = rebuild(result["trace"])
    lines.append(f"model: {len(result['trace'])} trace events, {result.get('trace_dropped', 0)} dropped, final time {fmt_t(result['final_time'])} s, "
                 f"states visited {len(result['states_visited'])}")
    for name in HOST_MACHINES:
        h = host.changes.get(name, [])
        rb = model.get(name)
        if rb is None:
            stats["host_only"] += 1
            lines.append(f"machine {name}: host-only ({len(h)} changes; the model scenario does not run it)")
            continue
        stats["machines"] += 1
        stats["changes"] += max(len(h), len(rb.changes))
        stats["transitions"] += len(rb.transitions)
        stats["accepts"] += len(rb.accepts)
        note = ADJUDICATED.get((run.name, name)) or ADJUDICATED.get(("*", name))
        if rb.changes == h:
            stats["agree"] += 1
            lines.append(f"machine {name}: agree ({len(h)} changes, {len(rb.transitions)} model transitions, {len(rb.accepts)} model accepts)")
            lines.extend(f"  t={fmt_t(t)} {c}" for t, c in h)
        else:
            stats["diverge"] += 1
            lines.append(f"machine {name}: diverge ({len(rb.changes)} model changes vs {len(h)} host changes)" + (f" -- {note}" if note else ""))
            for t, c in rb.changes:
                lines.append(f"  model t={fmt_t(t)} {c}")
            for t, c in h:
                lines.append(f"  host  t={fmt_t(t)} {c}")
        for p in rb.problems:
            lines.append(f"  rebuild problem: {p}")
    return "\n".join(lines) + "\n", stats


def run_all(bridge, measurements, out_dir: str | None = None) -> str:
    out_dir = out_dir or os.path.join(OUT, "expected", "trace")
    os.makedirs(out_dir, exist_ok=True)
    totals = {}
    summary = ["trace conformance: pinned runs, host (--fast-forward --trace) vs model (ExecuteState trace=true)"]
    for run in RUNS:
        text, stats = compare_run(run, bridge, measurements)
        with open(os.path.join(out_dir, run.name + ".txt"), "w") as f:
            f.write(text)
        for k, v in stats.items():
            totals[k] = totals.get(k, 0) + v
        summary.append(f"{run.name}: {stats['machines']} machines compared, {stats['agree']} agree, {stats['diverge']} diverge, "
                       f"{stats['host_only']} host-only, {stats['changes']} configuration changes")
    summary.append(f"total: {totals['machines']} machine-runs compared, {totals['agree']} agree, {totals['diverge']} diverge, "
                   f"{totals['host_only']} host-only, {totals['changes']} configuration changes, "
                   f"{totals['transitions']} model transitions, {totals['accepts']} model accepts")
    text = "\n".join(summary) + "\n"
    with open(os.path.join(out_dir, "summary.txt"), "w") as f:
        f.write(text)
    return text
