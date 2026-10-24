"""Formatting shared by the C and Python emitters."""

from __future__ import annotations

import re

GENERATOR_VERSION = "1.0.0"
_UPPER = re.compile(r"(?<=[a-z0-9])(?=[A-Z])")


def upper(name: str) -> str:
    return _UPPER.sub("_", str(name)).replace("-", "_").replace(".", "_").upper()


def snake(name: str) -> str:
    return upper(name).lower()


def c_str(s) -> str:
    if s is None:
        return "\"\""
    s = str(s).replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n")
    return f"\"{s}\""


def c_num(v) -> str:
    if v is None:
        return "0.0"
    if isinstance(v, bool):
        return "1" if v else "0"
    if isinstance(v, int):
        return str(v)
    r = repr(float(v))
    return r if ("." in r or "e" in r or "n" in r) else r + ".0"


def c_bool(v) -> str:
    return "1" if v else "0"


def py_val(v) -> str:
    if isinstance(v, float):
        return repr(v)
    return repr(v)


def mode_mask(active: list[str], modes: list[str]) -> int:
    return sum(1 << modes.index(m) for m in active if m in modes)


def header_lines(pin: dict, sources: list[str]) -> list[str]:
    lines = [
        "Argent flight software tables. Generated; edit the model or the generator, not this file.",
        f"Generator: software/gen/generate.py {GENERATOR_VERSION}",
        f"Model tool: OpenSysML {pin.get('version', '')} (commit {pin.get('commit', '')})",
        f"Model files: {pin.get('files', '')}",
    ]
    lines.append("Source elements:")
    lines.extend(f"  {s}" for s in sources)
    return lines


def c_header(pin, sources) -> str:
    return "/*\n" + "".join(f" * {l}\n" for l in header_lines(pin, sources)) + " */\n"


def py_header(pin, sources) -> str:
    return "".join(f"# {l}\n" for l in header_lines(pin, sources))
