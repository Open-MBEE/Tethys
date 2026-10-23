#!/usr/bin/env python3
"""Generate the Argent flight-software tables from the Tethys SysML v2 model.

Usage: generate.py [--sysml PATH] [--model-dir DIR] [--out DIR] [--cache FILE] [--keep-cache]

The pinned OpenSysML tool converts the model to its api-json element form; the generator
streams the packages it needs out of that, normalises them (``extract``) and writes the C and
Python tables (``emit_c``, ``emit_py``).  Output is a pure function of the model and the tool pin:
rows are sorted on their identifiers, nothing carries a timestamp or a path of this machine.
"""

from __future__ import annotations

import argparse
import glob
import hashlib
import os
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import apijson  # noqa: E402
import emit_c  # noqa: E402
import emit_py  # noqa: E402
import extract  # noqa: E402
from emit_common import GENERATOR_VERSION  # noqa: E402
from libids import library_ids  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def tool_pin(sysml: str) -> dict:
    out = subprocess.run([sysml, "-version"], check=True, capture_output=True, text=True).stdout
    version, commit = "", ""
    for line in out.splitlines():
        if line.startswith("sysml "):
            version = line.split()[1]
        if "Commit:" in line:
            commit = line.split()[-1]
    return {"version": version, "commit": commit}


def model_files(model_dir: str) -> list[str]:
    files = sorted(glob.glob(os.path.join(model_dir, "*.kerml"))) + sorted(glob.glob(os.path.join(model_dir, "*.sysml")))
    return files


def write_tree(out_dir: str, files: dict[str, str]) -> int:
    os.makedirs(out_dir, exist_ok=True)
    total = 0
    for name, text in sorted(files.items()):
        path = os.path.join(out_dir, name)
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
        total += len(text.encode("utf-8"))
    return total


def manifest(out_dir: str, rel_files: list[str]) -> str:
    lines = []
    for rel in sorted(rel_files):
        with open(os.path.join(out_dir, rel), "rb") as f:
            lines.append(f"{hashlib.sha256(f.read()).hexdigest()}  {rel}")
    return "\n".join(lines) + "\n"


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--sysml", default=os.path.join(ROOT, "build", "opensysml", "sysml"))
    ap.add_argument("--model-dir", default=os.path.join(ROOT, "model"))
    ap.add_argument("--stdlib", default=os.path.join(ROOT, "build", "opensysml-src", "internal", "workspace", "libs", "stdlib"))
    ap.add_argument("--out", default=os.path.join(ROOT, "software", "generated"))
    ap.add_argument("--cache", default=os.path.join(ROOT, "build", "gen", "model.api.json"),
                    help="where the api-json conversion is kept; reused when present and --keep-cache is set")
    ap.add_argument("--keep-cache", action="store_true", help="reuse an existing api-json conversion instead of converting")
    ap.add_argument("--quiet", action="store_true")
    args = ap.parse_args(argv)

    t0 = time.monotonic()
    pin = tool_pin(args.sysml)
    pin["generator"] = GENERATOR_VERSION
    files = model_files(args.model_dir)
    pin["files"] = f"{len(files)} files under model/ ({os.path.basename(files[0])} … {os.path.basename(files[-1])})"
    os.makedirs(os.path.dirname(args.cache), exist_ok=True)
    if not (args.keep_cache and os.path.exists(args.cache)):
        apijson.convert(args.sysml, files, args.cache)
    t1 = time.monotonic()
    idx = apijson.read(args.cache, extract.PACKAGES)
    lib = library_ids(args.stdlib)
    data = extract.extract(extract.Reader(idx, lib))
    t2 = time.monotonic()
    c_files = emit_c.emit(data, pin)
    py_files = emit_py.emit(data, pin)
    c_dir = os.path.join(args.out, "c")
    py_dir = os.path.join(args.out, "python", "argent_tables")
    size = write_tree(c_dir, c_files) + write_tree(py_dir, py_files)
    rels = [f"c/{n}" for n in c_files] + [f"python/argent_tables/{n}" for n in py_files]
    with open(os.path.join(args.out, "MANIFEST.sha256"), "w", encoding="utf-8", newline="\n") as f:
        f.write(manifest(args.out, rels))
    t3 = time.monotonic()
    if not args.quiet:
        print(f"model tool sysml {pin['version']} ({pin['commit']}); {len(files)} model files")
        print(f"convert {t1 - t0:.1f} s, extract {t2 - t1:.1f} s ({len(idx.elements)} elements kept), emit {t3 - t2:.1f} s; total {t3 - t0:.1f} s")
        print(f"wrote {len(rels)} files, {size} bytes under {args.out}")
        print(f"commands {len(data['commands'])}, telemetry {len(data['telemetry'])}, events {len(data['events'])}, packets {len(data['packets'])}, "
              f"parameter rows {sum(len(t['rows']) for t in data['parameter_tables'])}, mode rows {len(data['mode_table'])}, "
              f"machines {len(data['machines'])} ({sum(len(m['states']) for m in data['machines'])} states, {sum(len(m['transitions']) for m in data['machines'])} transitions), "
              f"tasks {sum(len(s['tasks']) for s in data['schedule']['partition_schedules'])}, bus streams {len(data['bus_schedule']['streams'])}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
