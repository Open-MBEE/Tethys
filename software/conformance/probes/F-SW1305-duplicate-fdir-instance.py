"""F-SW1305 probe: ExecuteState on TethysFdir::earthImpactScenario.tug.fdir through sysml-grpc traces two
FdirSupervisor instances. Run from the repository root with the pinned tools built:
PYTHONPATH=software/conformance:software/ground:software/generated/python OPENSYSML_BINARY=build/opensysml/sysml-grpc \\
  build/software/venv/bin/python software/conformance/probes/F-SW1305-duplicate-fdir-instance.py
Expected at the pin: two (element, object) keys — TethysFdir::FaultScenario::tug, whose command-loss timer
fires at t=604800 and sends SafeModeRequest, and TethysFdir::FdirTug::fdir, which receives every uplink item and
aborts at t=2427840. The CLI pinned run fdir-earth-impact-abort-hold ends in abortHold, not safe."""
from meridian.modelbridge import ModelBridge
from argent_conformance import modeltrace, scenarios

run = next(r for r in scenarios.RUNS if r.name == "vc-final-targeting")
bridge = ModelBridge().open()
result, _ = modeltrace.execute(bridge, run)
seen = {}
for ev in result["trace"]:
    if ev.kind == "transition" and ev.machine == "fdir":
        element = ev.object.element.id if ev.object is not None and ev.object.element is not None else "?"
        seen.setdefault(element, []).append((round(modeltrace._magnitude(ev.time)), f"{ev.from_state}->{ev.to_state}"))
for element, transitions in seen.items():
    print(element, len(transitions), "transitions, last:", transitions[-1])
bridge.close()
