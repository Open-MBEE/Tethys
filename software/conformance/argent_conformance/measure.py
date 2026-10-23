"""Wall-clock, peak RSS and output size for every harness step."""
from __future__ import annotations

import os
import resource
import time
from dataclasses import dataclass, field


def grpc_peak_rss_kb() -> int:
    """Peak RSS (VmHWM) of the running sysml-grpc processes, from /proc; 0 if none is visible."""
    peak = 0
    for pid in os.listdir("/proc"):
        if not pid.isdigit():
            continue
        try:
            with open(f"/proc/{pid}/comm") as f:
                if f.read().strip() != "sysml-grpc":
                    continue
            with open(f"/proc/{pid}/status") as f:
                for line in f:
                    if line.startswith("VmHWM:"):
                        peak = max(peak, int(line.split()[1]))
        except OSError:
            continue
    return peak


@dataclass
class Step:
    name: str
    seconds: float
    children_peak_rss_kb: int
    grpc_peak_rss_kb: int
    output_bytes: int


@dataclass
class Measurements:
    steps: list = field(default_factory=list)

    def measure(self, name: str):
        return _Timer(self, name)

    def report(self) -> str:
        lines = [f"{'step':40} {'wall s':>8} {'children peak RSS':>18} {'sysml-grpc peak RSS':>20} {'output':>10}"]
        for s in self.steps:
            lines.append(f"{s.name:40} {s.seconds:8.2f} {s.children_peak_rss_kb / 1024:15.0f} MB {s.grpc_peak_rss_kb / 1024:17.0f} MB {s.output_bytes:10d}")
        lines.append(f"{'total':40} {sum(s.seconds for s in self.steps):8.2f}")
        return "\n".join(lines) + "\n"


class _Timer:
    def __init__(self, m: Measurements, name: str):
        self.m, self.name, self.output_bytes = m, name, 0

    def __enter__(self):
        self.t0 = time.monotonic()
        return self

    def __exit__(self, *exc):
        self.m.steps.append(Step(self.name, time.monotonic() - self.t0,
                                 resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss, grpc_peak_rss_kb(), self.output_bytes))
