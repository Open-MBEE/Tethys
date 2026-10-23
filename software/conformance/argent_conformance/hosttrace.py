"""The host side of trace conformance: runs ``argent_host --trace --fast-forward`` for a pinned
run's scenario file and reduces the JSONL trace (one record per minor frame) to every machine's
configuration changes, the flight-software events raised and the frame counters."""
from __future__ import annotations

import json
import os
import subprocess
import time
from dataclasses import dataclass, field

from . import HOST, OUT, ROOT

SCENARIOS = os.path.join(ROOT, "software", "flight", "scenarios")


@dataclass
class HostTrace:
    changes: dict[str, list] = field(default_factory=dict)   # machine -> [(t, config)]
    events: list = field(default_factory=list)               # (t, mnemonic, value)
    commands: list = field(default_factory=list)
    skips: int = 0
    records: int = 0
    final_mode: str = ""
    counters: dict = field(default_factory=dict)
    size: int = 0


def run_host(run, out_dir: str | None = None) -> tuple[str, float, int]:
    """Runs the host for ``run``; returns (trace path, seconds, return code)."""
    out_dir = out_dir or os.path.join(OUT, "trace")
    os.makedirs(out_dir, exist_ok=True)
    path = os.path.join(out_dir, run.name + ".host.jsonl")
    cmd = [HOST, "--scenario", os.path.join(os.path.join(ROOT, run.stim_dir) if run.stim_dir else SCENARIOS, run.name + ".stim"), "--major-frames", str(run.advance),
           "--fast-forward", "--trace", path]
    t0 = time.monotonic()
    proc = subprocess.run(cmd, capture_output=True, text=True)
    return path, time.monotonic() - t0, proc.returncode


def parse(path: str) -> HostTrace:
    tr = HostTrace()
    tr.size = os.path.getsize(path)
    last: dict[str, str] = {}
    with open(path) as f:
        for line in f:
            rec = json.loads(line)
            if "skip" in rec:
                tr.skips += 1
                continue
            tr.records += 1
            t = rec["t_us"] / 1e6
            for machine, config in rec["machines"].items():
                if last.get(machine) != config:
                    last[machine] = config
                    tr.changes.setdefault(machine, []).append((t, config))
            for ev in rec.get("events", ()):
                tr.events.append((t, ev["name"], ev.get("value")))
            for c in rec.get("commands", ()):
                tr.commands.append((t, c))
            tr.final_mode = rec["mode"]
            tr.counters = {"exec": rec.get("exec"), "bus": rec.get("bus"), "inhibits": rec.get("inhibits")}
    return tr
