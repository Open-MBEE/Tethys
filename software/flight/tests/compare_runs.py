#!/usr/bin/env python3
"""Compare the host build against the pinned OpenSysML runs.

For every `run sw-* ... -instantiate <scenario> -state "<machine> <object>" -advance N` in
scripts/runs.sh (the `-engine check` runs excepted) this script
  * reads the final `Current state:` line of runs/<name>.txt as the oracle,
  * derives the stimulus from the pinned sequence rendering of the same scenario (messages sent by
    the external driver — operations / injector / conductor — to the top-level object), falling back
    to the scenario's model script (`accept after X [s]` + `send new Name(args) via uplink`),
  * writes the derived scenario to build/software/flight/scenarios/<name>.stim, runs argent_host
    with --fast-forward to the same horizon and lets its trailing `expect` line judge the state.
Nothing model-derived is copied into this file by hand.
"""
import math
import os
import shutil
import re
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
RUNS = os.path.join(ROOT, "runs")
BUILD = os.path.join(ROOT, "build", "software", "flight")
HOST = os.path.join(BUILD, "argent_host")
OUT = os.path.join(BUILD, "scenarios")

# Machine usage in the run command -> machine name in the generated tables / trace.
MACHINES = {
    "ModeManagementSoftware::modes": "TugModes",
    "ModeManagementSoftware::dispatcher": "ModeManagementDispatcher",
    "FdirSoftware::supervisor": "FdirSupervisor",
    "SepControlSoftware::controller": "SepStringController",
    "CaptureControlSoftware::controller": "CaptureController",
    "ParameterBootUpdateSoftware::manager": "BootUpdateManager",
    "BehaviouralCdh::redundancy": "RedundancyManager",
}

RUN_RE = re.compile(r'^run (sw-[\w-]+) .*?-instantiate (\S+) -state "(\S+) (\S+)" -advance (\d+)')
NUM = r"[0-9]+(?:\.[0-9]+)?(?:e[-+]?[0-9]+)?"
MSG_RE = re.compile(r"^\s*(\S+) => (\S+): t=(" + NUM + r")(?:\.\." + NUM + r")? (\w+)(?: \(([^)]*)\))?( \(not accepted\))?")
NUM_RE = re.compile(r"=\s*(-?[0-9.]+(?:e[-+]?\d+)?)")


def runs_sh():
    with open(os.path.join(ROOT, "scripts", "runs.sh")) as f:
        for line in f:
            m = RUN_RE.match(line)
            if m and "-engine check" not in line:
                yield m.group(1), m.group(2), m.group(3), m.group(4), int(m.group(5))


def current_states(name):
    with open(os.path.join(RUNS, name + ".txt")) as f:
        return [l.split("Current state:", 1)[1].strip() for l in f if "Current state:" in l]


def args_of(text):
    return [float(v) for v in NUM_RE.findall(text or "")]


def script_quantum(scenario):
    """The gcd (in whole seconds) of every `accept after` delay in the scenario's driver scripts.

    The sequence render prints times with six significant digits, so a campaign time such as
    19880640 appears as 1.98806e+07; every delay of a driver script is a multiple of this
    quantum, so a printed time is snapped back to the nearest multiple when it lies within the
    print rounding error."""
    models = [os.path.join(ROOT, "model", f) for f in sorted(os.listdir(os.path.join(ROOT, "model"))) if f.endswith(".sysml")]
    text = "\n".join(open(p).read() for p in models)
    m = re.search(r"part %s : (\w+)\b" % re.escape(scenario), text)
    if not m:
        return 0
    body = re.search(r"part def %s\b[^{]*\{(.*?)\n    \}" % re.escape(m.group(1)), text, re.S)
    if not body:
        return 0
    delays = []
    for d in re.findall(r"part \w+ : (\w+);", body.group(1)):
        driver = re.search(r"part def %s\b[^{]*\{(.*?)\n    \}" % re.escape(d), text, re.S)
        if not driver:
            continue
        for a, unit in re.findall(r"accept after ([0-9.e+]+) \[(s|min|h|d)\]", driver.group(1)):
            delays.append(int(round(float(a) * {"s": 1.0, "min": 60.0, "h": 3600.0, "d": 86400.0}[unit])))
    return math.gcd(*delays) if delays else 0


def snap(t, quantum):
    if quantum <= 0:
        return t
    exact = round(t / quantum) * quantum
    return float(exact) if abs(exact - t) <= abs(t) * 5e-6 else t


def stimuli_from_sequence(scenario, obj):
    """Messages from the external driver to `obj`, the top-level part the run's machine lives in,
    in the scenario's sequence render; messages to other top-level parts (the inspector's own
    uplink) are not stimuli of this host."""
    quantum = script_quantum(scenario)
    stim = []
    for fn in sorted(os.listdir(RUNS)):
        if not fn.endswith("-sequence.txt"):
            continue
        with open(os.path.join(RUNS, fn)) as f:
            text = f.read()
        if ("::" + scenario + ".") not in text and ("::" + scenario + " ") not in text:
            continue
        seen = set()
        for line in text.splitlines():
            m = MSG_RE.match(line)
            if not m:
                continue
            sender, receiver = m.group(1), m.group(2)
            if sender == receiver:
                continue  # self-sent (internal) message, not a stimulus
            sender_short = sender.split("::")[-1].split(".")
            receiver_short = receiver.split("::")[-1].split(".")
            if len(sender_short) != 2 or receiver_short != obj:
                continue  # only driver -> this top-level object messages are stimuli
            key = (snap(float(m.group(3)), quantum), m.group(4))
            if key in seen:
                continue
            seen.add(key)
            stim.append((key[0], key[1], args_of(m.group(5))))
        if stim:
            return stim
    return stim


def stimuli_from_model(scenario):
    """Fallback: the driver part's script in the model (accumulated `accept after` + `send new`)."""
    models = [os.path.join(ROOT, "model", f) for f in sorted(os.listdir(os.path.join(ROOT, "model"))) if f.endswith(".sysml")]
    text = "\n".join(open(p).read() for p in models)
    m = re.search(r"part %s\b[^{]*\{(.*?)\n    \}" % re.escape(scenario), text, re.S)
    if not m:
        return []
    drivers = re.findall(r"part :>> \w+ : (\w+);", m.group(1))
    stim = []
    for d in drivers:
        body = re.search(r"part def %s\b[^{]*\{(.*?)\n    \}" % re.escape(d), text, re.S)
        if not body:
            continue
        t = 0.0
        for line in body.group(1).splitlines():
            a = re.search(r"accept after ([0-9.e+]+) \[(s|min|h|d)\]", line)
            s = re.search(r"send new (\w+)\(([^)]*)\)", line)
            if a:
                t += float(a.group(1)) * {"s": 1.0, "min": 60.0, "h": 3600.0, "d": 86400.0}[a.group(2)]
            if s:
                stim.append((t, s.group(1), args_of(s.group(2))))
    return stim


# Regions where the pinned run and the table-driven runner are known to disagree; each names the
# finding that records the oracle evidence. The region is compared as '*' and the divergence printed.
# Empty since the runner keeps unaccepted items in flight as the model does (attitudeControl, once
# F-SW1201, now agrees in every run).
KNOWN_DIVERGENCES = {}


def fmt_time(t):
    return f"{t:.0f}" if float(t).is_integer() else f"{t:.6f}".rstrip("0").rstrip(".")


def main():
    global HOST, OUT
    import argparse
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--host", default=HOST, help="argent_host binary")
    ap.add_argument("--out", default=OUT, help="directory for the derived .stim files and traces")
    ap.add_argument("--shipped", default=None,
                    help="directory of shipped .stim files; each derived file must be byte-identical to it")
    ap.add_argument("--write-shipped", action="store_true", help="copy the derived .stim files into --shipped")
    opts = ap.parse_args()
    HOST, OUT = opts.host, opts.out
    os.makedirs(OUT, exist_ok=True)
    shipped_mismatch = 0
    failures = 0
    total = 0
    for name, scenario, machine, _obj, advance in runs_sh():
        key = machine.split("::", 1)[1] if "::" in machine else machine
        trace_name = MACHINES.get(key)
        states = current_states(name)
        if trace_name is None or len(states) < 2:
            print(f"skip {name}: machine {machine} not mapped or no final state")
            continue
        short = scenario.split("::")[-1]
        # The sequence render stops at its own horizon; the model script carries the whole campaign.
        obj = _obj.split("::")[-1].split(".")[:2]
        from_seq, from_model = stimuli_from_sequence(short, obj), stimuli_from_model(short)
        stim = from_model if len(from_model) > len(from_seq) else from_seq
        total += 1
        path = os.path.join(OUT, name + ".stim")
        with open(path, "w") as f:
            f.write(f"# derived from runs/{name}.txt and the {scenario} scenario; horizon {advance} s\n")
            for t, item, args in stim:
                f.write(f"t={fmt_time(t)} item {item} " + " ".join(f"{a:g}" for a in args) + "\n")
            expected = states[-1]
            regions = expected.split(" | ")
            for (run, machine_name, region), finding in KNOWN_DIVERGENCES.items():
                if run == name and machine_name == trace_name and region < len(regions):
                    print(f"note {name}: region {region} of {trace_name} ('{regions[region]}') not compared; {finding}")
                    regions[region] = "*"
            expected = " | ".join(regions)
            f.write(f"t={advance} expect {trace_name}={expected}\n")
        if opts.shipped:
            shipped = os.path.join(opts.shipped, os.path.basename(path))
            if opts.write_shipped:
                os.makedirs(opts.shipped, exist_ok=True)
                shutil.copyfile(path, shipped)
            elif not os.path.exists(shipped) or open(shipped, "rb").read() != open(path, "rb").read():
                print(f"FAIL {name}: shipped scenario {shipped} differs from the one derived from runs/ (re-run with --write-shipped)")
                shipped_mismatch += 1
        cmd = [HOST, "--scenario", path, "--major-frames", str(advance), "--fast-forward", "--trace", os.path.join(OUT, name + ".jsonl")]
        r = subprocess.run(cmd, capture_output=True, text=True)
        verdict = "ok  " if r.returncode == 0 else "FAIL"
        if r.returncode != 0:
            failures += 1
        print(f"{verdict} {name}: {len(stim)} stimuli, horizon {advance} s, expect {trace_name} = '{expected}'")
        if r.returncode != 0:
            print("     " + r.stderr.strip().replace("\n", "\n     "))
    failures += shipped_mismatch
    print(f"{total - failures}/{total} pinned runs reproduced")
    return 1 if failures or total == 0 else 0


if __name__ == "__main__":
    sys.exit(main())
