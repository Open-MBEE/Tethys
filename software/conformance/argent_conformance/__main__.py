"""``python -m argent_conformance [trace|calc|cases|all] [--write-expected]``.

Each tier writes its outputs under ``build/software/conformance/expected/<tier>/`` and compares
them byte for byte with the committed files under ``software/conformance/expected/<tier>/``.
``--write-expected`` copies the fresh outputs over the committed ones instead (review the diff:
every changed line is a conformance movement that needs an adjudication)."""
import argparse
import filecmp
import os
import shutil
import sys

from . import EVIDENCE, EXPECTED, OUT
from .measure import Measurements

TIERS = ("trace", "calc", "cases")


def compare_tree(tier: str, write: bool) -> list[str]:
    fresh = os.path.join(OUT, "expected", tier)
    committed = EVIDENCE if tier == "cases" else os.path.join(EXPECTED, tier)
    problems = []
    if write:
        os.makedirs(committed, exist_ok=True)
        for fn in sorted(os.listdir(fresh)):
            shutil.copyfile(os.path.join(fresh, fn), os.path.join(committed, fn))
        return problems
    names = sorted(set(os.listdir(fresh)) | set(os.listdir(committed) if os.path.isdir(committed) else []))
    for fn in names:
        a, b = os.path.join(fresh, fn), os.path.join(committed, fn)
        if not os.path.exists(b):
            problems.append(f"{tier}/{fn}: produced but not committed under {os.path.relpath(committed, os.path.dirname(EXPECTED))}/")
        elif not os.path.exists(a):
            problems.append(f"{tier}/{fn}: committed but no longer produced")
        elif not filecmp.cmp(a, b, shallow=False):
            problems.append(f"{tier}/{fn}: differs from the committed expectation (diff {b} {a})")
    return problems


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(prog="argent_conformance", description=__doc__)
    ap.add_argument("tier", nargs="?", default="all", choices=TIERS + ("all",))
    ap.add_argument("--write-expected", action="store_true", help="refresh software/conformance/expected/ from this run")
    opts = ap.parse_args(argv)
    tiers = TIERS if opts.tier == "all" else (opts.tier,)
    sys.path[:0] = [os.path.join(os.path.dirname(__file__), "..", "..", "ground"),
                    os.path.join(os.path.dirname(__file__), "..", "..", "generated", "python")]
    from meridian.modelbridge import ModelBridge  # the ground package's pinned-client bridge

    m = Measurements()
    with m.measure("sysml-grpc start + model parse"):
        bridge = ModelBridge().open()
    problems = []
    try:
        if "trace" in tiers:
            from . import trace_check
            print(trace_check.run_all(bridge, m), end="")
            problems += compare_tree("trace", opts.write_expected)
        if "calc" in tiers:
            from . import calc_check
            print(calc_check.run_all(bridge, m), end="")
            problems += compare_tree("calc", opts.write_expected)
        if "cases" in tiers:
            from . import case_check
            print(case_check.run_all(bridge, m), end="")
            problems += compare_tree("cases", opts.write_expected)
    finally:
        bridge.close()
    report = m.report()
    print(report, end="")
    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, "measurements.txt"), "w") as f:
        f.write(report)
    for p in problems:
        print("FAIL " + p)
    print(("software-conformance-check: " + ("FAIL" if problems else "OK")) + ("" if not opts.write_expected else " (expectations written)"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
