"""Shared fixtures: the generated tables and the package on the path, the pinned runs as oracles,
one model connection per session with its timings reported."""

import pathlib
import re
import sys

import pytest

ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "software" / "generated" / "python"))
sys.path.insert(0, str(ROOT / "software" / "ground"))


def run_results(name: str) -> dict[str, str]:
    """``path → value`` of a pinned run's ``✓ path`` / ``= value`` pairs."""
    text = (ROOT / "runs" / f"{name}.txt").read_text(encoding="utf-8")
    out, key = {}, None
    for line in text.splitlines():
        if line.startswith("✓ ") and "::" in line:
            key = line[2:].strip()
        elif line.strip().startswith("= ") and key:
            out[key] = line.strip()[2:].strip()
            key = None
    return out


def run_text(name: str) -> str:
    return (ROOT / "runs" / f"{name}.txt").read_text(encoding="utf-8")


def number(text: str) -> float:
    """The first number of a run value, a rational ``p/q`` evaluated."""
    m = re.match(r"\[?(-?[0-9.]+(?:e[-+]?[0-9]+)?)(?:/([0-9.]+))?", text.strip())
    v = float(m.group(1))
    return v / float(m.group(2)) if m.group(2) else v


def literal(text: str) -> str:
    """``[CommandVerdict::accepted]`` → ``accepted``."""
    return text.strip("[] ").rsplit("::", 1)[-1]


@pytest.fixture(scope="session")
def structure():
    return run_results("sw-ground-structure")


@pytest.fixture(scope="session")
def bridge():
    from meridian.modelbridge import ModelBridge

    with ModelBridge() as mb:
        yield mb
    total = mb.total_seconds()
    print(f"\nmodel bridge: {len(mb.timings)} calls, {total:.2f} s total; "
          + ", ".join(f"{t.operation} {t.seconds:.2f} s" for t in mb.timings[:2]))
    (ROOT / "build" / "software").mkdir(parents=True, exist_ok=True)
    (ROOT / "build" / "software" / "ground-model-timings.txt").write_text(
        "".join(f"{t.operation}\t{t.seconds:.3f}\t{t.target}\n" for t in mb.timings), encoding="utf-8")
