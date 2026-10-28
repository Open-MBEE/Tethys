"""Calc conformance: the model's interpretation of each calc def (``Model.eval`` through
``sysml-grpc``) against its compiled C and Go forms (``sysml -compile -target c|go -source`` at
the pin, built with the system C compiler and the pinned Go toolchain) over the grid in
``calcs.py``. Every calc lands in one bucket: ``agree``, ``disagree``, ``does-not-compile-at-pin``
(with the pin's reason) or ``not-driveable`` (no grid can be written; the reason names what covers
it instead). The pin has no Python target (``-target`` takes ``c`` or ``go``); the ground suite's
hand-written Python is compared with the interpretation by ``software-ground-check``."""
import math
import os
import subprocess
from concurrent.futures import ThreadPoolExecutor

from . import OUT, ROOT, SYSML
from .calcs import BUDGETS, CALCS

MODEL_FILES = sorted(os.path.join(ROOT, "model", f) for f in os.listdir(os.path.join(ROOT, "model")) if f.endswith((".kerml", ".sysml")))
GOTOOLCHAIN = os.environ.get("GOTOOLCHAIN", "go1.25.11")


def literal(v) -> str:
    """A grid value as the model/compiled programs read it (Reals always in Real notation)."""
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, int):
        return str(v)
    if isinstance(v, float):
        return repr(v)
    return v


def normalise(v) -> str:
    """One text for a result whichever side produced it."""
    if isinstance(v, (list, tuple)):
        return "[" + ", ".join(normalise(x) for x in v) + "]"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(float(v)) if isinstance(v, float) else str(v)
    lit = getattr(v, "literal_id", None)
    if lit:
        return "::".join(lit.split("::")[-2:])
    return str(v)


def parse_compiled(text: str):
    text = text.strip()
    if text.startswith("[") and text.endswith("]"):
        text = text[1:-1]
    if text in ("true", "false"):
        return text == "true"
    try:
        return int(text)
    except ValueError:
        pass
    try:
        return float(text)
    except ValueError:
        return text


def same(kind: str, tol: float, a, b) -> bool:
    if kind == "real" and isinstance(a, (int, float)) and isinstance(b, (int, float)):
        a, b = float(a), float(b)
        if math.isnan(a) and math.isnan(b):
            return True
        return abs(a - b) <= max(tol * max(abs(a), abs(b)), 1e-12)
    return normalise(a) == normalise(b)


def compile_calc(name: str, target: str, workdir: str, measurements):
    """(executable path or None, reason)."""
    slug = name.replace("::", "__")
    src = os.path.join(workdir, f"{slug}.{target}")
    exe = os.path.join(workdir, f"{slug}-{target}")
    with measurements.measure(f"compile {name} {target}") as t:
        r = subprocess.run([SYSML, "-quiet", "-compile", name, "-target", target, "-source", "-o", src] + MODEL_FILES,
                           capture_output=True, text=True)
        if r.returncode != 0 or not os.path.exists(src):
            reason = " ".join(line for line in (r.stderr + r.stdout).splitlines() if "not compilable" in line or "error" in line.lower()).strip()
            return None, reason or "sysml -compile failed"
        t.output_bytes = os.path.getsize(src)
        if target == "c":
            b = subprocess.run(["cc", "-O2", "-std=c11", "-o", exe, src, "-lm"], capture_output=True, text=True)
        else:
            env = dict(os.environ, GOTOOLCHAIN=GOTOOLCHAIN, GOFLAGS="-mod=mod", GO111MODULE="off")
            b = subprocess.run(["go", "build", "-o", exe, src], capture_output=True, text=True, env=env, cwd=workdir)
        if b.returncode != 0:
            return None, f"{target} build failed: {b.stderr.strip()[:300]}"
    return exe, ""


def run_compiled(exe: str, point) -> object:
    r = subprocess.run([exe] + [literal(v) for v in point], capture_output=True, text=True)
    if r.returncode != 0:
        return "error: " + r.stderr.strip().splitlines()[-1][:200]
    return parse_compiled(r.stdout)


def interpret(bridge, calc, point) -> object:
    pkg, short = calc.name.rsplit("::", 1)
    expr = f"{short}({', '.join(literal(v) for v in point)})"
    try:
        v = bridge.eval(expr, context=pkg)
    except Exception as e:  # the pin's message is the evidence
        return "error: " + str(e).splitlines()[0][:200]
    if isinstance(v, list) and len(v) == 1:
        v = v[0]
    return v


def compiled_point(point) -> bool:
    return all(not isinstance(v, str) for v in point)


def precompile(calcs, workdir, measurements) -> dict:
    """Every driveable calc compiled to C, then to Go where the front end accepted it; each
    ``sysml -compile`` loads the whole model (~5 s), so the invocations run in parallel."""
    names = [c.name for c in calcs if not c.skip]
    with ThreadPoolExecutor(max_workers=os.cpu_count() or 2) as pool:
        c_results = dict(zip(names, pool.map(lambda n: compile_calc(n, "c", workdir, measurements), names)))
        go_names = [n for n in names if c_results[n][0] is not None or "not compilable" not in c_results[n][1]]
        go_results = dict(zip(go_names, pool.map(lambda n: compile_calc(n, "go", workdir, measurements), go_names)))
    compiled = {}
    for n in names:
        compiled[n] = {"c": c_results[n], "go": go_results.get(n, (None, c_results[n][1]))}
    return compiled


def check_calc(calc, bridge, compiled, measurements):
    lines = [f"calc {calc.name}({', '.join(calc.params)}) kind={calc.kind}" + (f" tol={calc.tol:g} relative" if calc.kind == "real" else " exact")]
    if calc.source:
        lines.append(f"  grid: {calc.source}")
    if calc.skip:
        lines.append(f"  not-driveable: {calc.skip}")
        return "not-driveable", lines
    exes = {t: compiled[calc.name][t][0] for t in ("c", "go")}
    reasons = {t: compiled[calc.name][t][1] for t in ("c", "go")}
    for target in ("c", "go"):
        if exes[target] is None:
            lines.append(f"  {target}: does-not-compile-at-pin: {reasons[target]}")
    disagree = 0
    with measurements.measure(f"evaluate {calc.name}") as t:
        for point in calc.grid:
            args = ", ".join(f"{p}={literal(v)}" for p, v in zip(calc.params, point))
            model = interpret(bridge, calc, point)
            row = [f"  ({args})", f"model={normalise(model)}"]
            for target in ("c", "go"):
                if exes[target] is None or not compiled_point(point):
                    continue
                got = run_compiled(exes[target], point)
                ok = same(calc.kind, calc.tol, model, got)
                disagree += 0 if ok else 1
                row.append(f"{target}={normalise(got)}" + ("" if ok else " DISAGREE"))
            lines.append(" ".join(row))
        t.output_bytes = sum(len(l) + 1 for l in lines)
    if all(e is None for e in exes.values()):
        return "does-not-compile-at-pin", lines
    return ("disagree" if disagree else "agree"), lines


def check_budgets(bridge, lines: list[str]) -> list[str]:
    import sys
    sys.path.insert(0, os.path.join(ROOT, "software", "generated", "python"))
    from argent_tables import modes as gen_modes
    out = ["budgets: model interpretation vs the generated tables, held against the policy"]
    for title, expr, ctx, policy in BUDGETS:
        try:
            v = bridge.eval(expr, context=ctx)
        except Exception as e:
            out.append(f"  {title}: model error: {str(e).splitlines()[0][:200]}")
            continue
        if title == "bus slots by mode":
            gen = [row.bus_slots_used for row in gen_modes.MODE_TABLE]
            model = [int(x) for x in v]
            verdict = "identical" if gen == model else "DIFFER"
            worst = max(model)
            out.append(f"  {title}: model={model} generated={gen} {verdict}; policy {policy}: {'pass' if worst <= 32 else f'FAIL (max {worst})'}")
        elif title == "array power margin":
            out.append(f"  {title}: model={normalise(v)} ({float(v) * 100:.1f} %); policy {policy}: {'pass' if float(v) >= 0.15 else 'FAIL'}; no generated table carries it")
        else:
            out.append(f"  {title}: model={normalise(v)}")
    return out


def run_all(bridge, measurements, out_dir: str | None = None) -> str:
    out_dir = out_dir or os.path.join(OUT, "expected", "calc")
    workdir = os.path.join(OUT, "calc-build")
    os.makedirs(out_dir, exist_ok=True)
    os.makedirs(workdir, exist_ok=True)
    buckets: dict[str, list[str]] = {}
    with measurements.measure("compile all calcs (parallel wall)"):
        compiled = precompile(CALCS, workdir, measurements)
    for calc in CALCS:
        bucket, lines = check_calc(calc, bridge, compiled, measurements)
        buckets.setdefault(bucket, []).append(calc.name)
        with open(os.path.join(out_dir, calc.name.replace("::", "__") + ".txt"), "w") as f:
            f.write("\n".join(lines) + "\n")
    summary = ["calc conformance: model interpretation (Model.eval at the pin) vs compiled C and Go (sysml -compile at the pin); no Python target at the pin"]
    for bucket in ("agree", "disagree", "does-not-compile-at-pin", "not-driveable"):
        names = buckets.get(bucket, [])
        summary.append(f"{bucket}: {len(names)}" + (" — " + ", ".join(n.split('::')[-1] for n in names) if names else ""))
    summary += check_budgets(bridge, summary)
    text = "\n".join(summary) + "\n"
    with open(os.path.join(out_dir, "summary.txt"), "w") as f:
        f.write(text)
    return text
