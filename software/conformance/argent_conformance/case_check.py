"""As-run software verification cases: the ``planned`` cases of ``TethysSoftwareAssurance`` (model 88)
whose level is ``flightSoftwareInTheLoop`` or ``modelInTheLoop`` and whose subject the harness
can drive (the flight host, the model through ``sysml-grpc`` and the ground suite). One evidence
file per case: inputs, both sides' outputs, the case's own pass criterion applied, the tool pin.
A case the harness cannot drive stays planned and is listed with the reason."""
import os
import sys

from . import OUT, ROOT, TOOL_PIN
from .scenarios import RUNS

CASES = (
    ("finalTargetingFlightSoftwareInTheLoop", "FinalTargetingTest", "trajectoryTool", "PassIf(abortRaisedInsideCorridor)"),
    ("thrustArcFlightSoftwareInTheLoop", "ThrustArcControlTest", "trajectoryTool", "PassIf(stringLossHandled and thrustHeldDuringRelay)"),
    ("captureSequenceFlightSoftwareInTheLoop", "CaptureSequenceTest", "captureRig", "PassIf(firedWhenArmed and heldWhenInhibited)"),
    ("faultDetectionFlightSoftwareInTheLoop", "FaultDetectionTest", "trajectoryTool", "PassIf(measuredDetection <= 0.5 [s] and safeConfigurationReached)"),
    ("groundTwoStepIntegration", "GroundCommandTwoStepTest", "trajectoryTool", "PassIf(sequenceRefusedOnRuleViolation and secondApprovalRequired)"),
)

# The 26 other planned cases and why this harness cannot run them: their test level needs a bench
# the repository does not hold (developer unit benches, integration benches, flatsat, hardware).
NOT_RUNNABLE = {
    "unit": "a unit-level case runs on the developer workstation bench against the flight unit tests, not against the model",
    "integration": "an integration-level case needs the dynamics simulator or integration bench",
    "hardwareInTheLoop": "needs the flatsat or capture rig hardware",
    "flatsat": "needs the flatsat",
}


def fmt_t(t: float) -> str:
    t = round(float(t), 6)
    return f"{t:.0f}" if t.is_integer() else f"{t:.6f}".rstrip("0").rstrip(".")


def sequence(changes) -> str:
    return "; ".join(f"t={fmt_t(t)} {c}" for t, c in changes)


def machine_both(results, name: str, lines: list[str]) -> tuple[list, list]:
    host, model, _ = results
    h, rb = host.changes.get(name, []), model.get(name)
    m = rb.changes if rb else []
    lines.append(f"  host  {name}: {sequence(h)}")
    lines.append(f"  model {name}: {sequence(m)}" + ("" if h == m else "  (DIVERGE)"))
    return h, m


def final(changes) -> str:
    return changes[-1][1] if changes else ""


def region(config: str, index: int) -> str:
    parts = config.split(" | ")
    return parts[index] if index < len(parts) else ""


def case_final_targeting(bridge, m, lines):
    from .trace_check import results_for
    lines.append("inputs: software/conformance/scenarios/vc-final-targeting.stim (TethysFdir::earthImpactScenario: nominal solution 384400 km / 1e-7, then 12000 km / 2e-3 inside the 63781.37 km exclusion sphere)")
    r = results_for("vc-final-targeting", bridge, m)
    h, mm = machine_both(r, "FdirSupervisor", lines)
    host_abort = region(final(h), 5) == "aborted" and region(h[-2][1] if len(h) > 1 else "", 5) == "monitoring"
    model_abort = region(final(mm), 5) == "aborted"
    lines.append(f"  abortRaisedInsideCorridor: host={str(host_abort).lower()} model={str(model_abort).lower()} (nominal solution left monitoring, violating one aborted)")
    return host_abort and model_abort and h == mm


def case_thrust_arc(bridge, m, lines):
    from .trace_check import results_for
    sys.path[:0] = [os.path.join(ROOT, "software", "ground"), os.path.join(ROOT, "software", "generated", "python")]
    from meridian.warden.checker import PlannedSequence, check_flight_rules
    lines.append("inputs: software/conformance/scenarios/vc-thrust-arc.stim (sw-sep-string-restarting run on to 1300000 s: ThrusterFlameout 2 at t=872640 during the first arc, restartDelay 2 h) and sw-fdir-thruster-restarting; a thrust-arc sequence planned into a relay pass")
    r = results_for("vc-thrust-arc", bridge, m)
    h, mm = machine_both(r, "SepStringController", lines)
    r2 = results_for("sw-fdir-thruster-restarting", bridge, m)
    h2, mm2 = machine_both(r2, "FdirSupervisor", lines)
    restarted = any(c == "restarting" for _, c in h) and final(h) == "thrusting"
    lines.append(f"  stringLossHandled: host={str(restarted and h == mm).lower()} model={str(any(c == 'restarting' for _, c in mm) and final(mm) == 'thrusting').lower()} (controller restarts the string and thrusts again; FDIR agrees: {str(h2 == mm2).lower()})")
    c = PlannedSequence(1, "thrust", True, True, 1.0e5, True, 90.0, False, 0.8)
    rules, flight_mode = check_flight_rules(c)
    ground_refuses = not rules.get("FR-001", True)
    from argent_tables import ground
    lim = ground.CHECK_LIMITS
    model = bridge.eval(f"CheckFlightRules(true, true, 100000.0 [m], true, 90.0 ['°'], false, 0.8, TugMode::thrust, {lim['keepOutRadius'].value!r} [m], "
                        f"{lim['exclusionHalfAngle'].value!r} ['°'], {lim['stateOfChargeFloor'].value!r})", context="TethysGroundSoftware")
    model_refuses = not bool(model[0] if isinstance(model, list) else model)
    lines.append(f"  thrustHeldDuringRelay: ground FR-001 noThrustDuringRelay={str(rules.get('FR-001')).lower()} model CheckFlightRules={str(not model_refuses).lower()} -> held={str(ground_refuses and model_refuses).lower()}")
    return restarted and h == mm and h2 == mm2 and ground_refuses and model_refuses


def case_capture(bridge, m, lines):
    from .trace_check import results_for
    lines.append("inputs: sw-capture-controller (armed, every inhibit removed) and sw-capture-controller-inhibited (premature contact) scenarios")
    r = results_for("sw-capture-controller", bridge, m)
    h, mm = machine_both(r, "CaptureController", lines)
    r2 = results_for("sw-capture-controller-inhibited", bridge, m)
    h2, mm2 = machine_both(r2, "CaptureController", lines)
    fired = final(h) == "captured" and final(mm) == "captured"
    held = final(h2) == "inhibited" and final(mm2) == "inhibited"
    lines.append(f"  firedWhenArmed: {str(fired).lower()} (final state captured on both sides); heldWhenInhibited: {str(held).lower()} (final state inhibited on both sides)")
    return fired and held and h == mm and h2 == mm2


def latency_after(changes, t0: float) -> float | None:
    later = [t for t, _ in changes if t >= t0]
    return (min(later) - t0) if later else None


def case_fault_detection(bridge, m, lines):
    from .trace_check import results_for
    lines.append("inputs: sw-fdir-thruster-restarting (ThrusterFlameout 2 at t=872640) and sw-mode-manager-safe (command loss, no ground contact until the timer expires)")
    r = results_for("sw-fdir-thruster-restarting", bridge, m)
    host, model, _ = r
    h, mm = machine_both(r, "FdirSupervisor", lines)
    lat_h = latency_after(h, 872640.0)
    lat_m = latency_after(mm, 872640.0)
    lines.append(f"  measuredDetection: host={fmt_t(lat_h) if lat_h is not None else 'none'} s model={fmt_t(lat_m) if lat_m is not None else 'none'} s (first FdirSupervisor configuration change after the fault; host minor frame 0.125 s)")
    r2 = results_for("sw-mode-manager-safe", bridge, m)
    h2, mm2 = machine_both(r2, "TugModes", lines)
    safe = region(final(h2), 0) == "safe" and region(final(mm2), 0) == "safe"
    lines.append(f"  safeConfigurationReached: {str(safe).lower()} (TugModes main region safe on both sides)")
    return lat_h is not None and lat_m is not None and lat_h <= 0.5 and lat_m <= 0.5 and safe and h == mm and h2 == mm2


def case_ground_two_step(bridge, m, lines):
    sys.path[:0] = [os.path.join(ROOT, "software", "ground"), os.path.join(ROOT, "software", "generated", "python")]
    from meridian.forge.builder import CommandBuilder, CommandRequest
    from meridian.warden.checker import PlannedSequence, UplinkExchange
    from meridian.modelbridge import magnitude
    lines.append("inputs: TethysGroundSoftware::CommandBuilder::resetWithOneApproval and thrustArcRequest; TethysGroundSoftware::nominalUplink and relayConflictUplink exchanges")

    def request(name, argument):
        base = f"TethysGroundSoftware::CommandBuilder::{name}"
        return CommandRequest(bridge.eval(f"{base}.mnemonic"), float(bridge.eval(f"{base}.argumentValue")),
                              str(bridge.eval(f"{base}.modeAtExecution")).rsplit("::", 1)[-1], int(bridge.eval(f"{base}.approvals")), argument)

    def model_verdict(name, command, argument):
        v = bridge.eval(f"ValidateCommand(CommandBuilder::{name}, {command}, {command}.{argument})", context="TethysGroundSoftware")
        return str(getattr(v[0], "name", v[0])).rsplit("::", 1)[-1]

    forge = CommandBuilder()
    one = forge.validate(request("resetWithOneApproval", "confirmKey"))
    two = forge.validate(request("thrustArcRequest", "throttle"))
    mv1, mv2 = model_verdict("resetWithOneApproval", "cdhResetProcessor", "confirmKey"), model_verdict("thrustArcRequest", "sepStartThrustArc", "throttle")
    lines.append(f"  ground forge: resetWithOneApproval -> {one.verdict.name} (approvals_sufficient={str(one.approvals_sufficient).lower()}); thrustArcRequest -> {two.verdict.name}")
    lines.append(f"  model ValidateCommand: resetWithOneApproval -> {mv1}; thrustArcRequest -> {mv2}")
    second = (not one.approvals_sufficient) and one.verdict.name.lower().replace("_", "") == mv1.lower() and two.verdict.name.lower() == mv2.lower() == "accepted"

    def planned(name):
        base = f"TethysGroundSoftware::{name}"
        q = lambda attr: bridge.eval(f"{base}.{attr}")  # noqa: E731
        return PlannedSequence(int(q("sequenceId")), str(q("plannedMode")).rsplit("::", 1)[-1], bool(q("thrusting")), bool(q("relayPassActive")),
                               float(magnitude(bridge.eval(f"{base}.rangeToTarget / 1 [m]", context="TethysGroundSoftware"))), bool(q("approachAuthorised")),
                               float(magnitude(bridge.eval(f"{base}.sunAngle / 1 ['°']", context="TethysGroundSoftware"))), bool(q("coverOpen")), float(q("stateOfCharge")))

    import re
    from argent_tables import ground
    lim = ground.CHECK_LIMITS
    with open(os.path.join(ROOT, "runs", "sw-ground-sequencer-check.txt")) as f:
        pinned_text = f.read()
    refused = {}
    for exchange, candidate in (("nominalUplink", "thrustArcInCoast"), ("relayConflictUplink", "thrustArcDuringRelay")):
        c = planned(candidate)
        result = UplinkExchange().run(c)
        pin = {}
        for k in ("verdict", "reason"):  # the pinned run executes FlightRuleChecker::check on the exchange; Model.eval cannot run an action
            mo = re.search(rf"TethysGroundSoftware::{exchange}\.checker\.check\.{k}\n\s*= (.*)", pinned_text)
            pin[k] = mo.group(1).strip().strip('"').rsplit("::", 1)[-1] if mo else "?"
        call = (f"CheckFlightRules({str(c.thrusting).lower()}, {str(c.relay_pass_active).lower()}, {c.range_to_target_m!r} [m], {str(c.approach_authorised).lower()}, "
                f"{c.sun_angle_deg!r} ['°'], {str(c.cover_open).lower()}, {c.state_of_charge!r}, TugMode::{c.planned_mode}, "
                f"{lim['keepOutRadius'].value!r} [m], {lim['exclusionHalfAngle'].value!r} ['°'], {lim['stateOfChargeFloor'].value!r})")
        live = bridge.eval(call, context="TethysGroundSoftware")
        live = bool(live[0] if isinstance(live, list) else live)
        lines.append(f"  {exchange}: ground {result.verdict.name.lower()} ({result.reason or 'no reason'}); model pinned run {pin['verdict']} ({pin['reason']}), live CheckFlightRules allPassed={str(live).lower()}")
        refused[exchange] = (result.verdict.name.lower(), result.reason, pin["verdict"].lower(), pin["reason"], live)
    g, r = refused["relayConflictUplink"], refused["nominalUplink"]
    refusal = g[0] == "refused" and g[2] == "refused" and g[1] == g[3] and not g[4] and r[0] == r[2] == "cleared" and r[4]
    lines.append(f"  sequenceRefusedOnRuleViolation: {str(refusal).lower()}; secondApprovalRequired: {str(second).lower()}")
    return refusal and second


RUNNERS = {
    "finalTargetingFlightSoftwareInTheLoop": case_final_targeting,
    "thrustArcFlightSoftwareInTheLoop": case_thrust_arc,
    "captureSequenceFlightSoftwareInTheLoop": case_capture,
    "faultDetectionFlightSoftwareInTheLoop": case_fault_detection,
    "groundTwoStepIntegration": case_ground_two_step,
}


def run_all(bridge, measurements, out_dir: str | None = None) -> str:
    out_dir = out_dir or os.path.join(OUT, "expected", "cases")
    os.makedirs(out_dir, exist_ok=True)
    summary = ["as-run verification cases (TethysSoftwareAssurance, level flightSoftwareInTheLoop): host + model + ground"]
    verdicts = {}
    for name, definition, bed, criterion in CASES:
        lines = [f"case {name} : {definition}", f"level: flightSoftwareInTheLoop; test bed as planned: {bed}; run on: flight host (argent_host --trace), model (sysml-grpc ExecuteState trace, Model.eval) and the ground suite",
                 f"tool pin: OpenSysML {TOOL_PIN}", f"criterion: {criterion}"]
        with measurements.measure(f"case {name}") as t:
            try:
                ok = RUNNERS[name](bridge, measurements, lines)
                verdict = "pass" if ok else "fail"
            except Exception as e:  # the failure is the evidence
                lines.append(f"  error: {type(e).__name__}: {str(e).splitlines()[0][:200]}")
                verdict = "fail"
            lines.append(f"verdict: {verdict}")
            text = "\n".join(lines) + "\n"
            t.output_bytes = len(text)
        with open(os.path.join(out_dir, name + ".txt"), "w") as f:
            f.write(text)
        verdicts[name] = verdict
        summary.append(f"{name}: {verdict}")
    summary.append(f"run {len(CASES)}: pass {sum(v == 'pass' for v in verdicts.values())}, fail {sum(v == 'fail' for v in verdicts.values())}; "
                   f"26 planned cases not runnable here (12 unit, 4 integration, 4 hardwareInTheLoop, 6 flatsat)")
    text = "\n".join(summary) + "\n"
    with open(os.path.join(out_dir, "summary.txt"), "w") as f:
        f.write(text)
    return text
