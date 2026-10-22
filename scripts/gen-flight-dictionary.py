#!/usr/bin/env python3
"""Generate model/64-flight-dictionary.sysml, the Tethys flight dictionary.

Deterministic: the same script always writes the same file. The .sysml is the committed
artifact; edit this script, re-run it, and commit both. Everything here is fictional —
mnemonics, opcodes, application ids and limits are invented for the Tethys Retrieval model.
Only the CCSDS Space Packet primary header layout is real (CCSDS 133.0-B-2 §4.1.3).
"""
from __future__ import annotations

import math
import os
import sys

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "model", "64-flight-dictionary.sysml")

# ---- applications: one row per TethysFlightSoftware application definition --------------
# (enum literal, backbone definition, mnemonic prefix, APID class, command APID, opcode block)
APPS = [
    ("cdh", "CdhApplication", "CDH", "housekeeping", 960, 0x0100),
    ("gnc", "GncApplication", "GNC", "guidance", 961, 0x0200),
    ("sepControl", "SepControlApplication", "SEP", "propulsion", 962, 0x0300),
    ("powerManagement", "PowerManagementApplication", "EPS", "housekeeping", 963, 0x0400),
    ("thermalControl", "ThermalControlApplication", "THM", "housekeeping", 964, 0x0500),
    ("telecom", "TelecomApplication", "COM", "relay", 965, 0x0600),
    ("inspectorHandling", "InspectorHandlingApplication", "INS", "imaging", 966, 0x0700),
    ("captureControl", "CaptureControlApplication", "CAP", "capture", 967, 0x0800),
    ("autonomy", "AutonomyApplication", "AUT", "guidance", 968, 0x0900),
    ("fdir", "FdirApplication", "FDR", "housekeeping", 969, 0x0A00),
    ("modeManagement", "ModeManagementApplication", "MOD", "housekeeping", 970, 0x0B00),
    ("parameterBootUpdate", "ParameterBootUpdateApplication", "PBU", "housekeeping", 971, 0x0C00),
]
APP_BY_PREFIX = {a[2]: a for a in APPS}

# APID class bases: the telemetry APID space is carved per class, 11-bit (max 2047).
APID_CLASS_BASE = {"housekeeping": 16, "guidance": 64, "propulsion": 128, "capture": 192, "relay": 256, "imaging": 320}

# ---- mode preconditions (TethysTugStructure vocabulary) ------------------------------------
ALL = "allFlightModes"
THRUST = "thrustingModes"
COAST = "coastingModes"
PROX = "proximityModes"
SAFE = "safeModes"
def modes(*lits: str) -> str:
    return "(" + ", ".join(f"TugMode::{m}" for m in lits) + ")"
CAPTURE_MODES = modes("proximityOperations", "capture", "despin")
NOT_SAFE = "(TugMode::earlyOperations, thrustingModes, coastingModes, proximityModes, TugMode::capture, TugMode::despin, TugMode::droHold)"
GROUND_ONLY = modes("earlyOperations", "coast", "droHold", "safe")

# ---- argument kinds: (ISQ type, unit literal suffix or None) ------------------------------
ARG_KINDS = {
    "duration": ("DurationValue", "[s]"),
    "angle": ("AngularMeasureValue", "[rad]"),
    "rate": ("AngularVelocityValue", "[rad/s]"),
    "temperature": ("ThermodynamicTemperatureValue", "[K]"),
    "voltage": ("ElectricPotentialValue", "[V]"),
    "current": ("ElectricCurrentValue", "[A]"),
    "power": ("PowerValue", "[W]"),
    "length": ("LengthValue", "[m]"),
    "speed": ("SpeedValue", "[m/s]"),
    "frequency": ("FrequencyValue", "[Hz]"),
    "force": ("ForceValue", "[N]"),
    "fraction": ("Real", None),
    "count": ("Natural", None),
}

# ---- telemetry kinds: (definition, ISQ type, unit suffix, unit symbol, width bits) ----------
TM_KINDS = {
    "temperature": ("TemperaturePoint", "ThermodynamicTemperatureValue", "[K]", "K", 16),
    "voltage": ("VoltagePoint", "ElectricPotentialValue", "[V]", "V", 16),
    "current": ("CurrentPoint", "ElectricCurrentValue", "[A]", "A", 16),
    "power": ("PowerPoint", "PowerValue", "[W]", "W", 16),
    "pressure": ("PressurePoint", "PressureValue", "[Pa]", "Pa", 16),
    "angle": ("AnglePoint", "AngularMeasureValue", "[rad]", "rad", 32),
    "rate": ("AngularRatePoint", "AngularVelocityValue", "[rad/s]", "rad/s", 32),
    "length": ("LengthPoint", "LengthValue", "[m]", "m", 32),
    "speed": ("SpeedPoint", "SpeedValue", "[m/s]", "m/s", 32),
    "duration": ("DurationPoint", "DurationValue", "[s]", "s", 32),
    "mass": ("MassPoint", "MassValue", "[kg]", "kg", 32),
    "force": ("ForcePoint", "ForceValue", "[N]", "N", 16),
    "fraction": ("FractionPoint", "Real", "", "1", 16),
    "count": ("CountPoint", "Natural", "", "1", 32),
    "status": ("StatusPoint", "Natural", "", "1", 8),
}


def nat(v: int) -> str:
    """A Natural literal; values past 2^31-1 are spelt as a product so the pilot's reader accepts them."""
    if v > 2147483647:
        return f"{v // 65536} * 65536 + {v % 65536}" if v % 65536 else f"{v // 65536} * 65536"
    return str(v)


def lit(kind: str, v: float) -> str:
    """A literal of the kind's value type: quantity, Real or Natural."""
    if kind in ("count", "status"):
        return nat(int(v))
    if kind == "fraction":
        return f"{v:.4g}" if isinstance(v, float) and v != int(v) else f"{float(v):.1f}"
    s = f"{v:.10g}"
    if "." not in s and "e" not in s:
        s += ".0"
    return f"{s} {TM_KINDS[kind][2]}" if kind in TM_KINDS else s


def arg_lit(kind: str, v: float) -> str:
    t, u = ARG_KINDS[kind]
    if t == "Natural":
        return nat(int(v))
    s = f"{v:.10g}"
    if "." not in s and "e" not in s:
        s += ".0"
    return f"{s} {u}" if u else s


# ---- command catalogue -------------------------------------------------------------------
# Each command: (verb, doc, criticality, hazardous, modes, [(arg name, kind, min, max, bits)])
def cmd(verb, doc, crit="routine", hazardous=False, modes_=ALL, args=()):
    return (verb, doc, crit, hazardous, modes_, list(args))

COMMANDS: dict[str, list] = {}

COMMANDS["CDH"] = [
    cmd("NOOP", "No operation; exercises the command path and increments the accept counter."),
    cmd("RESET_PROCESSOR", "Warm-reset the flight computer; all applications restart from their tables.", "critical", True, GROUND_ONLY,
        [("confirmKey", "count", 0, 65535, 16)]),
    cmd("SELECT_PRIME_COMPUTER", "Make the named computer prime and the other hot spare.", "critical", False, ALL,
        [("computer", "count", 0, 1, 8)]),
    cmd("SET_CLOCK", "Set the spacecraft clock coarse and fine fields.", "critical", False, ALL,
        [("coarseTime", "count", 0, 4294967295, 32), ("fineTime", "count", 0, 65535, 16)]),
    cmd("ADJUST_CLOCK", "Slew the spacecraft clock by a signed correction applied over the next pass.", "routine", False, ALL,
        [("correction", "duration", -10.0, 10.0, 32), ("slewPeriod", "duration", 1.0, 86400.0, 32)]),
    cmd("DUMP_MEMORY", "Downlink a memory region of the given address and length.", "routine", False, ALL,
        [("address", "count", 0, 4294967295, 32), ("byteCount", "count", 1, 1048576, 32)]),
    cmd("LOAD_MEMORY", "Write a memory region; the image follows in the data field.", "critical", True, GROUND_ONLY,
        [("address", "count", 0, 4294967295, 32), ("byteCount", "count", 1, 65536, 32), ("checksum", "count", 0, 4294967295, 32)]),
    cmd("START_RECORDING", "Start recording the named telemetry packet class to the recorder.", "routine", False, ALL,
        [("apidClassCode", "count", 0, 5, 8)]),
    cmd("STOP_RECORDING", "Stop recording the named telemetry packet class.", "routine", False, ALL,
        [("apidClassCode", "count", 0, 5, 8)]),
    cmd("DOWNLINK_FILE", "Queue a recorder file for downlink at the given priority.", "routine", False, ALL,
        [("fileId", "count", 0, 1048575, 32), ("priority", "count", 0, 7, 8)]),
    cmd("DELETE_FILE", "Delete a recorder file after its downlink is confirmed.", "critical", False, ALL,
        [("fileId", "count", 0, 1048575, 32)]),
    cmd("SET_DOWNLINK_PRIORITY", "Set the downlink priority of a telemetry packet class.", "routine", False, ALL,
        [("apidClassCode", "count", 0, 5, 8), ("priority", "count", 0, 7, 8)]),
    cmd("SET_WATCHDOG_PERIOD", "Set the hardware watchdog kick period.", "critical", False, GROUND_ONLY,
        [("period", "duration", 0.1, 30.0, 32)]),
    cmd("CLEAR_COUNTERS", "Zero the command accept and reject counters.", "routine"),
] + [cmd(f"SET_APP_RATE_{a[2]}", f"Set the scheduling rate of the {a[2]} application.", "critical", False, ALL,
         [("rate", "frequency", 0.1, 100.0, 16)]) for a in APPS]

COMMANDS["GNC"] = [
    cmd("SET_ATTITUDE_TARGET", "Command a target quaternion; the controller slews to it at the rate limit.", "critical", False, NOT_SAFE,
        [("q1", "fraction", -1.0, 1.0, 32), ("q2", "fraction", -1.0, 1.0, 32), ("q3", "fraction", -1.0, 1.0, 32), ("q4", "fraction", -1.0, 1.0, 32)]),
    cmd("SET_RATE_TARGET", "Command a body rate target.", "critical", False, NOT_SAFE,
        [("rateX", "rate", -0.05, 0.05, 32), ("rateY", "rate", -0.05, 0.05, 32), ("rateZ", "rate", -0.05, 0.05, 32)]),
    cmd("SLEW_TO", "Slew about the given axis by the given angle.", "critical", False, NOT_SAFE,
        [("axis", "count", 0, 2, 8), ("angle", "angle", -3.14159, 3.14159, 32), ("slewRate", "rate", 0.0001, 0.02, 32)]),
    cmd("HOLD_ATTITUDE", "Hold the current attitude inertially.", "routine", False, NOT_SAFE),
    cmd("SELECT_STAR_TRACKER", "Select the star tracker used by the estimator.", "critical", False, ALL,
        [("tracker", "count", 0, 1, 8)]),
    cmd("SELECT_IMU", "Select the inertial measurement unit used by the estimator.", "critical", False, ALL,
        [("imu", "count", 0, 1, 8)]),
    cmd("DESATURATE_WHEELS", "Dump wheel momentum with the reaction control thrusters.", "critical", True, NOT_SAFE,
        [("targetMomentumFraction", "fraction", 0.0, 0.5, 16)]),
    cmd("SET_WHEEL_SPEED", "Command a wheel to a speed; for ground testing and bias management.", "critical", False, GROUND_ONLY,
        [("wheel", "count", 0, 3, 8), ("speed", "rate", -628.3, 628.3, 32)]),
    cmd("ENABLE_RCS_CONTROL", "Allow the controller to fire reaction control thrusters.", "critical", True, NOT_SAFE),
    cmd("DISABLE_RCS_CONTROL", "Inhibit all reaction control thruster firing.", "critical", False, ALL),
    cmd("UPLOAD_EPHEMERIS", "Load an ephemeris block for the tug, the Earth, the Moon or the target.", "routine", False, ALL,
        [("body", "count", 0, 3, 8), ("epochCoarse", "count", 0, 4294967295, 32), ("validity", "duration", 3600.0, 7776000.0, 32)]),
    cmd("SET_GUIDANCE_MODE", "Select the guidance law: inertial hold, sun point, thrust vector or target track.", "critical", False, NOT_SAFE,
        [("law", "count", 0, 3, 8)]),
    cmd("START_TCM", "Execute a trajectory correction with the reaction control system.", "critical", True, modes("coast", "stackCoast", "approach"),
        [("deltaV", "speed", 0.001, 5.0, 32), ("direction", "angle", -3.14159, 3.14159, 32), ("startDelay", "duration", 0.0, 86400.0, 32)]),
    cmd("ABORT_TCM", "Stop a running trajectory correction immediately.", "critical", False, ALL),
    cmd("SET_POINTING_TOLERANCE", "Set the attitude error at which a slew is declared complete.", "routine", False, ALL,
        [("tolerance", "angle", 0.0001, 0.1, 32)]),
    cmd("RESET_ESTIMATOR", "Reinitialise the attitude estimator from the star tracker.", "critical", False, ALL),
] + [cmd(f"RCS_THRUSTER_{v}_{n:02d}", f"{'Enable' if v == 'ENABLE' else 'Disable'} reaction control thruster {n}.", "critical", v == "ENABLE", ALL)
     for n in range(1, 9) for v in ("ENABLE", "DISABLE")] \
  + [cmd(f"WHEEL_{v}_{n}", f"{'Power on' if v == 'ON' else 'Power off'} reaction wheel {n}.", "critical", False, ALL) for n in range(1, 5) for v in ("ON", "OFF")]

COMMANDS["SEP"] = [
    cmd("START_THRUST_ARC", "Begin a thrust arc of the given duration at the given throttle.", "critical", True, THRUST,
        [("duration", "duration", 60.0, 2592000.0, 32), ("throttle", "fraction", 0.2, 1.0, 16)]),
    cmd("STOP_THRUST", "Stop thrusting immediately and close the flow.", "critical", False, ALL),
    cmd("SET_THROTTLE", "Change the throttle of a running arc.", "critical", False, THRUST,
        [("throttle", "fraction", 0.2, 1.0, 16)]),
    cmd("SELECT_THRUSTER", "Select the thruster the next arc fires.", "critical", False, ALL,
        [("thruster", "count", 0, 2, 8)]),
    cmd("PRIME_FEED", "Open the feed system and bring the regulator to pressure.", "critical", True, NOT_SAFE),
    cmd("VENT_FEED", "Vent the feed lines downstream of the latch valves.", "critical", True, GROUND_ONLY),
    cmd("SET_FLOW_RATE", "Set the anode flow set point.", "critical", False, THRUST,
        [("flowFraction", "fraction", 0.5, 1.2, 16)]),
    cmd("THRUSTER_RESTART", "Attempt a restart after a flameout, after the restart delay.", "critical", True, THRUST,
        [("delay", "duration", 60.0, 86400.0, 32)]),
    cmd("OPEN_LATCH_VALVE", "Open a latch valve.", "critical", True, ALL, [("valve", "count", 0, 5, 8)]),
    cmd("CLOSE_LATCH_VALVE", "Close a latch valve.", "critical", False, ALL, [("valve", "count", 0, 5, 8)]),
    cmd("GIMBAL_SET", "Point a thruster gimbal.", "critical", False, NOT_SAFE,
        [("thruster", "count", 0, 2, 8), ("alpha", "angle", -0.2, 0.2, 32), ("beta", "angle", -0.2, 0.2, 32)]),
    cmd("GIMBAL_HOME", "Drive a thruster gimbal to its mechanical home.", "routine", False, ALL, [("thruster", "count", 0, 2, 8)]),
    cmd("SET_DISCHARGE_LIMIT", "Set the discharge current trip limit for the power processing units.", "critical", False, GROUND_ONLY,
        [("limit", "current", 5.0, 40.0, 16)]),
    cmd("TANK_HEATER_SETPOINT", "Set the xenon tank heater set point.", "routine", False, ALL,
        [("setpoint", "temperature", 273.0, 323.0, 16)]),
] + [cmd(f"PPU_{v}_{n}", f"{'Power on' if v == 'ON' else 'Power off'} power processing unit {n}.", "critical", v == "ON", ALL) for n in range(1, 4) for v in ("ON", "OFF")] \
  + [cmd(f"CATHODE_HEATER_{v}_{n}", f"{'Enable' if v == 'ON' else 'Disable'} the cathode heater of thruster {n}.", "routine", False, ALL) for n in range(1, 4) for v in ("ON", "OFF")]

COMMANDS["EPS"] = [
    cmd("SET_BATTERY_CHARGE_LIMIT", "Set the battery end-of-charge voltage.", "critical", False, ALL,
        [("voltage", "voltage", 28.0, 33.6, 16)]),
    cmd("SET_LOAD_SHED_LEVEL", "Set the load-shed tier the power manager applies at low state of charge.", "critical", False, ALL,
        [("level", "count", 0, 3, 8)]),
    cmd("SELECT_BATTERY", "Select the battery that carries the bus; the other floats.", "critical", False, ALL,
        [("battery", "count", 0, 1, 8)]),
    cmd("SADA_SET_ANGLE", "Drive a solar array drive to an angle.", "critical", False, NOT_SAFE,
        [("drive", "count", 0, 1, 8), ("angle", "angle", -3.14159, 3.14159, 32)]),
    cmd("SADA_TRACK_SUN", "Return a solar array drive to sun tracking.", "routine", False, ALL, [("drive", "count", 0, 1, 8)]),
    cmd("SADA_HOLD", "Hold a solar array drive at its current angle.", "routine", False, ALL, [("drive", "count", 0, 1, 8)]),
    cmd("SET_BUS_VOLTAGE_LIMITS", "Set the regulated bus under- and over-voltage trips.", "critical", False, GROUND_ONLY,
        [("lowTrip", "voltage", 24.0, 28.0, 16), ("highTrip", "voltage", 28.0, 32.0, 16)]),
    cmd("BALANCE_CELLS", "Start a cell balancing cycle on a battery.", "routine", False, ALL, [("battery", "count", 0, 1, 8)]),
    cmd("RESET_SWITCH_TRIPS", "Clear every latched over-current trip.", "critical", False, ALL),
    cmd("SET_ARRAY_STRING_MASK", "Mask solar array strings out of the regulator.", "critical", False, ALL,
        [("wing", "count", 0, 3, 8), ("mask", "count", 0, 63, 8)]),
] + [cmd(f"SWITCH_{v}_{n:02d}", f"{'Close' if v == 'ON' else 'Open'} power switch {n}.", "critical", False, ALL) for n in range(1, 25) for v in ("ON", "OFF")]

COMMANDS["THM"] = [
    cmd("SET_CONTROL_MODE", "Select the heater control law: bang-bang, proportional or open loop.", "critical", False, ALL,
        [("law", "count", 0, 2, 8)]),
    cmd("LOUVER_SET", "Set a radiator louver position.", "routine", False, ALL,
        [("louver", "count", 0, 3, 8), ("position", "fraction", 0.0, 1.0, 16)]),
    cmd("LOUVER_AUTO", "Return a radiator louver to passive control.", "routine", False, ALL, [("louver", "count", 0, 3, 8)]),
    cmd("SET_SURVIVAL_SETPOINTS", "Set the survival heater set points applied in safe mode.", "critical", False, GROUND_ONLY,
        [("low", "temperature", 233.0, 283.0, 16), ("high", "temperature", 243.0, 293.0, 16)]),
    cmd("SET_DEADBAND", "Set the control deadband of every zone.", "routine", False, ALL,
        [("deadband", "temperature", 0.5, 10.0, 16)]),
    cmd("ENABLE_ALL_HEATERS", "Enable every heater zone under its set point.", "critical", False, ALL),
    cmd("DISABLE_ALL_HEATERS", "Disable every heater zone; survival heaters stay on their thermostats.", "critical", True, ALL),
    cmd("SET_HEATER_POWER_CAP", "Cap the total heater power the thermal application may draw.", "critical", False, ALL,
        [("cap", "power", 50.0, 900.0, 16)]),
] + [cmd(f"HEATER_{v}_{n:02d}", f"{'Enable' if v == 'ENABLE' else 'Disable'} heater zone {n}.", "routine", False, ALL) for n in range(1, 17) for v in ("ENABLE", "DISABLE")] \
  + [cmd(f"HEATER_SETPOINT_{n:02d}", f"Set the control set point of heater zone {n}.", "routine", False, ALL,
         [("setpoint", "temperature", 233.0, 323.0, 16)]) for n in range(1, 17)]

COMMANDS["COM"] = [
    cmd("TRANSMITTER_ON", "Enable the transmitter on the selected transponder.", "critical", True, ALL, [("transponder", "count", 0, 1, 8)]),
    cmd("TRANSMITTER_OFF", "Disable the transmitter.", "critical", False, ALL, [("transponder", "count", 0, 1, 8)]),
    cmd("SELECT_TRANSPONDER", "Select the prime transponder.", "critical", False, ALL, [("transponder", "count", 0, 1, 8)]),
    cmd("SELECT_ANTENNA", "Route the transmitter to the high-gain or a low-gain antenna.", "critical", False, ALL, [("antenna", "count", 0, 2, 8)]),
    cmd("SET_DOWNLINK_RATE", "Set the downlink symbol rate.", "routine", False, ALL, [("rate", "frequency", 10.0, 4000000.0, 32)]),
    cmd("SET_UPLINK_RATE", "Set the expected uplink bit rate.", "routine", False, ALL, [("rate", "frequency", 7.8125, 4000.0, 32)]),
    cmd("RANGING_ON", "Enable the ranging channel turn-around.", "routine", False, ALL),
    cmd("RANGING_OFF", "Disable the ranging channel turn-around.", "routine", False, ALL),
    cmd("HGA_POINT", "Point the high-gain antenna.", "critical", False, NOT_SAFE,
        [("azimuth", "angle", -1.5708, 1.5708, 32), ("elevation", "angle", -0.7854, 0.7854, 32)]),
    cmd("HGA_TRACK_EARTH", "Return the high-gain antenna to Earth tracking.", "routine", False, ALL),
    cmd("HGA_STOW", "Stow the high-gain antenna.", "critical", False, ALL),
    cmd("SET_PASS_WINDOW", "Load the next ground pass window.", "routine", False, ALL,
        [("windowStart", "count", 0, 4294967295, 32), ("duration", "duration", 600.0, 43200.0, 32)]),
    cmd("SET_CODING", "Select the downlink coding: convolutional, Reed–Solomon, turbo or LDPC.", "routine", False, ALL, [("code", "count", 0, 3, 8)]),
    cmd("SET_TRANSMIT_POWER", "Set the transmitter output power.", "critical", False, ALL, [("power", "power", 5.0, 100.0, 16)]),
] + [cmd(f"DOWNLINK_RATE_PRESET_{n}", f"Select downlink rate preset {n} of the link table.", "routine", False, ALL) for n in range(1, 7)]

COMMANDS["INS"] = [
    cmd("ARM_RELEASE", "Arm the inspector release mechanism.", "critical", True, modes("proximityOperations"), [("armKey", "count", 0, 65535, 16)]),
    cmd("SAFE_RELEASE", "Disarm the inspector release mechanism.", "critical", False, ALL),
    cmd("RELEASE_INSPECTOR", "Release the inspector; irreversible.", "hazardous", True, modes("proximityOperations"),
        [("releaseSpeed", "speed", 0.02, 0.2, 16), ("confirmKey", "count", 0, 65535, 16)]),
    cmd("FORWARD_COMMAND", "Forward a command block to the inspector over the relay link.", "critical", False, PROX,
        [("inspectorOpcode", "count", 0, 65535, 16), ("byteCount", "count", 0, 1024, 16)]),
    cmd("START_IMAGING_SESSION", "Start an inspector imaging session of the given duration.", "routine", False, PROX,
        [("duration", "duration", 60.0, 7200.0, 32), ("cadence", "duration", 1.0, 600.0, 16)]),
    cmd("STOP_IMAGING_SESSION", "Stop the inspector imaging session.", "routine", False, ALL),
    cmd("SET_IMAGE_COMPRESSION", "Set the image compression ratio relayed to the inspector.", "routine", False, ALL, [("ratio", "count", 1, 20, 8)]),
    cmd("SELECT_RELAY_RATE", "Set the relay link data rate.", "routine", False, ALL, [("rate", "frequency", 1000.0, 2000000.0, 32)]),
    cmd("STORE_IMAGE_SEGMENT", "Store a relayed image segment in the recorder.", "routine", False, ALL,
        [("imageId", "count", 0, 65535, 16), ("segment", "count", 0, 4095, 16)]),
    cmd("DOWNLINK_IMAGE", "Queue a stored inspector image for downlink.", "routine", False, ALL, [("imageId", "count", 0, 65535, 16)]),
    cmd("RETIRE_INSPECTOR", "Command the inspector to its disposal state; irreversible.", "hazardous", True, modes("capture", "despin", "stackCoast"),
        [("confirmKey", "count", 0, 65535, 16)]),
    cmd("SET_RELAY_WINDOW", "Load the next relay contact window.", "routine", False, ALL,
        [("windowStart", "count", 0, 4294967295, 32), ("duration", "duration", 60.0, 86400.0, 32)]),
    cmd("ENABLE_RELAY", "Enable the relay receiver.", "routine", False, ALL),
    cmd("DISABLE_RELAY", "Disable the relay receiver.", "routine", False, ALL),
]

COMMANDS["CAP"] = [
    cmd("ARM_CAPTURE", "Arm the capture mechanism.", "critical", True, CAPTURE_MODES, [("armKey", "count", 0, 65535, 16)]),
    cmd("DISARM_CAPTURE", "Disarm the capture mechanism.", "critical", False, ALL),
    cmd("DEPLOY_BAG", "Deploy the capture bag.", "hazardous", True, modes("proximityOperations", "capture"), [("confirmKey", "count", 0, 65535, 16)]),
    cmd("CLOSE_BAG", "Close the capture bag around the body.", "hazardous", True, modes("capture"), [("confirmKey", "count", 0, 65535, 16)]),
    cmd("CINCH_BAG", "Cinch the bag to the commanded tension.", "critical", True, modes("capture", "despin"), [("tension", "force", 10.0, 2000.0, 16)]),
    cmd("START_DESPIN", "Start the despin controller.", "critical", True, modes("despin"), [("torqueLimit", "fraction", 0.1, 1.0, 16)]),
    cmd("STOP_DESPIN", "Stop the despin controller.", "critical", False, ALL),
    cmd("SET_DESPIN_TORQUE", "Set the despin torque fraction.", "critical", False, modes("despin"), [("torque", "fraction", 0.0, 1.0, 16)]),
    cmd("LATCH_BODY", "Engage the body latches.", "critical", True, modes("capture", "despin"), [("latchMask", "count", 0, 15, 8)]),
    cmd("RELEASE_BODY", "Release the body latches and the bag; irreversible for the mission.", "hazardous", True, modes("droHold", "abortHold"),
        [("confirmKey", "count", 0, 65535, 16)]),
    cmd("ABORT_CAPTURE", "Abort the capture: open the bag and retreat.", "critical", True, CAPTURE_MODES),
    cmd("SET_APPROACH_RATE", "Set the closing rate limit for the final approach.", "critical", False, PROX, [("rate", "speed", 0.01, 0.5, 16)]),
    cmd("ENABLE_PROXIMITY_SENSORS", "Power and enable the proximity sensor suite.", "routine", False, ALL),
    cmd("DISABLE_PROXIMITY_SENSORS", "Disable the proximity sensor suite.", "routine", False, ALL),
    cmd("SET_CONTACT_FORCE_LIMIT", "Set the contact force at which the controller backs off.", "critical", False, CAPTURE_MODES,
        [("limit", "force", 1.0, 500.0, 16)]),
    cmd("SET_BODY_MASS_ESTIMATE", "Load the ground estimate of the body mass into the controller.", "routine", False, ALL,
        [("massTonnes", "fraction", 1.0, 2000.0, 32)]),
] + [cmd(f"PETAL_{v}_{n}", f"{'Open' if v == 'OPEN' else 'Close'} bag petal {n}.", "critical", True, CAPTURE_MODES) for n in range(1, 5) for v in ("OPEN", "CLOSE")]

COMMANDS["AUT"] = [
    cmd("LOAD_SEQUENCE", "Load a command sequence into an engine.", "routine", False, ALL,
        [("engine", "count", 0, 3, 8), ("sequenceId", "count", 0, 65535, 16), ("byteCount", "count", 1, 4096, 16)]),
    cmd("START_SEQUENCE", "Start the sequence loaded in an engine.", "critical", False, ALL, [("engine", "count", 0, 3, 8)]),
    cmd("STOP_SEQUENCE", "Stop and unload the sequence in an engine.", "critical", False, ALL, [("engine", "count", 0, 3, 8)]),
    cmd("PAUSE_SEQUENCE", "Pause the sequence in an engine.", "routine", False, ALL, [("engine", "count", 0, 3, 8)]),
    cmd("RESUME_SEQUENCE", "Resume a paused sequence.", "routine", False, ALL, [("engine", "count", 0, 3, 8)]),
    cmd("SET_SEQUENCE_PARAMETER", "Set a sequence parameter by index.", "routine", False, ALL,
        [("engine", "count", 0, 3, 8), ("index", "count", 0, 255, 8), ("value", "fraction", -1.0e9, 1.0e9, 32)]),
    cmd("ENABLE_AUTONOMY", "Enable on-board autonomy at the given level.", "critical", False, ALL, [("level", "count", 0, 3, 8)]),
    cmd("DISABLE_AUTONOMY", "Disable on-board autonomy; sequences run but rules do not fire.", "critical", False, ALL),
    cmd("SET_RULE_ENABLE", "Enable or disable an autonomy rule.", "critical", False, ALL,
        [("rule", "count", 0, 15, 8), ("enabled", "count", 0, 1, 8)]),
    cmd("CLEAR_RULE_HISTORY", "Clear the rule firing history.", "routine", False, ALL),
    cmd("SET_WAYPOINT", "Add a proximity-operations waypoint.", "critical", False, PROX,
        [("index", "count", 0, 31, 8), ("rangeMetres", "length", 50.0, 5000.0, 32), ("holdTime", "duration", 0.0, 86400.0, 32)]),
    cmd("CLEAR_WAYPOINTS", "Clear the waypoint list.", "critical", False, ALL),
    cmd("SET_PLAN_HORIZON", "Set the planning horizon of the autonomy executive.", "routine", False, ALL, [("horizon", "duration", 3600.0, 604800.0, 32)]),
] + [cmd(f"ENGINE_{v}_{n}", f"{'Enable' if v == 'ENABLE' else 'Disable'} sequence engine {n}.", "routine", False, ALL) for n in range(1, 5) for v in ("ENABLE", "DISABLE")]

COMMANDS["FDR"] = [
    cmd("ENABLE_MONITOR", "Enable a fault monitor.", "critical", False, ALL, [("monitor", "count", 0, 47, 8)]),
    cmd("DISABLE_MONITOR", "Disable a fault monitor.", "critical", True, ALL, [("monitor", "count", 0, 47, 8)]),
    cmd("SET_LIMIT", "Set the red and yellow limits of a monitored point.", "critical", False, ALL,
        [("pointId", "count", 0, 65535, 16), ("redLow", "fraction", -1.0e9, 1.0e9, 32), ("yellowLow", "fraction", -1.0e9, 1.0e9, 32),
         ("yellowHigh", "fraction", -1.0e9, 1.0e9, 32), ("redHigh", "fraction", -1.0e9, 1.0e9, 32)]),
    cmd("RESET_LIMIT", "Return a monitored point to its table limits.", "routine", False, ALL, [("pointId", "count", 0, 65535, 16)]),
    cmd("CLEAR_FAULT", "Clear a latched fault.", "critical", False, ALL, [("faultId", "count", 0, 65535, 16)]),
    cmd("ACKNOWLEDGE_FAULT", "Acknowledge a fault so its response may re-arm.", "routine", False, ALL, [("faultId", "count", 0, 65535, 16)]),
    cmd("MASK_RESPONSE", "Mask a fault response.", "critical", True, ALL, [("response", "count", 0, 4, 8)]),
    cmd("UNMASK_RESPONSE", "Unmask a fault response.", "critical", False, ALL, [("response", "count", 0, 4, 8)]),
    cmd("FORCE_SAFE_MODE", "Command safe mode directly.", "critical", True, ALL),
    cmd("SET_COMMAND_LOSS_TIMER", "Set the command-loss timer that calls safe mode when no command arrives.", "critical", False, ALL,
        [("timeout", "duration", 3600.0, 2592000.0, 32)]),
    cmd("RESET_COMMAND_LOSS_TIMER", "Restart the command-loss timer.", "routine", False, ALL),
    cmd("ABORT_TO_RETREAT", "Abort proximity operations and retreat to the hold point.", "critical", True, CAPTURE_MODES),
    cmd("SET_FLAMEOUT_RETRIES", "Set the thruster restarts tried before a switchover.", "critical", False, ALL, [("retries", "count", 0, 5, 8)]),
    cmd("SET_BATTERY_LOW_FRACTION", "Set the state of charge at which load shedding starts.", "critical", False, ALL, [("fraction", "fraction", 0.1, 0.6, 16)]),
    cmd("SET_IMPACT_PROBABILITY_LIMIT", "Set the Earth impact probability above which the supervisor aborts.", "critical", False, ALL,
        [("limit", "fraction", 1.0e-7, 1.0e-3, 32)]),
    cmd("SET_EXCLUSION_RADIUS", "Set the Earth exclusion radius.", "critical", False, GROUND_ONLY, [("radius", "length", 1.0e7, 1.0e8, 32)]),
] + [cmd(f"MONITOR_RESPONSE_{n:02d}", f"Set the response of monitor {n}.", "critical", False, ALL, [("response", "count", 0, 4, 8)]) for n in range(1, 13)]

COMMANDS["MOD"] = [
    cmd("SET_MODE", "Transition the tug to a commanded mode.", "critical", True, ALL, [("mode", "count", 0, 15, 8)]),
    cmd("CONFIRM_MODE", "Confirm a pending two-step mode transition.", "critical", False, ALL, [("mode", "count", 0, 15, 8), ("confirmKey", "count", 0, 65535, 16)]),
    cmd("CANCEL_PENDING_MODE", "Cancel a pending two-step mode transition.", "routine", False, ALL),
    cmd("LOAD_MODE_TABLE", "Load the mode × subsystem table.", "critical", False, GROUND_ONLY, [("tableId", "count", 0, 11, 8)]),
    cmd("ENABLE_AUTO_TRANSITION", "Allow on-board events to drive mode transitions.", "critical", False, ALL),
    cmd("DISABLE_AUTO_TRANSITION", "Only ground commands may drive mode transitions.", "critical", False, ALL),
    cmd("HOLD_MODE", "Hold the current mode against events.", "routine", False, ALL),
    cmd("RESUME_MODE", "Release a mode hold.", "routine", False, ALL),
    cmd("SET_TRANSITION_TIMEOUT", "Set the time a transition may take before it is declared failed.", "routine", False, ALL,
        [("timeout", "duration", 1.0, 3600.0, 32)]),
]

COMMANDS["PBU"] = [
    cmd("LOAD_TABLE", "Load a parameter table into the staging buffer.", "critical", False, ALL, [("tableId", "count", 0, 11, 8), ("byteCount", "count", 1, 65536, 32)]),
    cmd("DUMP_TABLE", "Downlink a parameter table.", "routine", False, ALL, [("tableId", "count", 0, 11, 8)]),
    cmd("ACTIVATE_TABLE", "Activate a staged table after validation.", "critical", True, ALL, [("tableId", "count", 0, 11, 8), ("crc", "count", 0, 4294967295, 32)]),
    cmd("VERIFY_TABLE", "Recompute and report a table checksum.", "routine", False, ALL, [("tableId", "count", 0, 11, 8)]),
    cmd("SET_PARAMETER", "Set one parameter by id.", "critical", False, ALL, [("parameterId", "count", 0, 65535, 16), ("value", "fraction", -1.0e9, 1.0e9, 32)]),
    cmd("GET_PARAMETER", "Report one parameter by id.", "routine", False, ALL, [("parameterId", "count", 0, 65535, 16)]),
    cmd("START_BOOT_UPDATE", "Start receiving a boot image.", "critical", True, GROUND_ONLY, [("image", "count", 0, 1, 8), ("byteCount", "count", 1, 8388608, 32)]),
    cmd("ABORT_BOOT_UPDATE", "Abort a boot image transfer.", "critical", False, ALL),
    cmd("SELECT_BOOT_IMAGE", "Select the boot image used at the next reset.", "critical", True, GROUND_ONLY, [("image", "count", 0, 1, 8), ("confirmKey", "count", 0, 65535, 16)]),
    cmd("COMMIT_BOOT_IMAGE", "Mark the running image good so the boot loader stops falling back.", "critical", True, GROUND_ONLY),
] + [cmd(f"TABLE_RESET_{n:02d}", f"Reset parameter table {n} to its flight defaults.", "critical", False, GROUND_ONLY) for n in range(1, 13)]

# ---- telemetry catalogue -----------------------------------------------------------------
# families: (suffix, kind, count, rate Hz, housekeeping?, (redLow, yellowLow, yellowHigh, redHigh))
def fam(suffix, kind, count=1, rate=1.0, hk=False, limits=None):
    if limits is None:
        limits = {
            "temperature": (233.0, 253.0, 313.0, 333.0), "voltage": (0.0, 0.5, 32.0, 36.0), "current": (0.0, 0.0, 8.0, 10.0),
            "power": (0.0, 0.0, 500.0, 600.0), "pressure": (0.0, 1.0e4, 2.0e6, 2.5e6), "angle": (-3.1416, -3.0, 3.0, 3.1416),
            "rate": (-0.1, -0.05, 0.05, 0.1), "length": (0.0, 10.0, 1.0e8, 1.0e9), "speed": (-100.0, -50.0, 50.0, 100.0),
            "duration": (0.0, 0.0, 1.0e7, 1.0e8), "mass": (0.0, 10.0, 2000.0, 2500.0), "force": (0.0, 0.0, 500.0, 1000.0),
            "fraction": (0.0, 0.1, 0.9, 1.0), "count": (0, 0, 4000000000, 4294967295), "status": (0, 0, 254, 255),
        }[kind]
    return (suffix, kind, count, rate, hk, limits)

TELEMETRY: dict[str, list] = {
    "CDH": [fam("T_BOARD", "temperature", 4, 0.1, True), fam("CPU_LOAD", "fraction", 2, 1.0, True), fam("MEM_USED", "fraction", 2, 1.0, True),
            fam("RECORDER_FILL", "fraction", 1, 0.1, True), fam("UPTIME", "duration", 1, 1.0, True), fam("CMD_ACCEPT_COUNT", "count", 1, 1.0, True),
            fam("CMD_REJECT_COUNT", "count", 1, 1.0, True, (0, 0, 10, 100)), fam("BUS_MSG_RATE", "count", 1, 1.0), fam("FILE_COUNT", "count", 1, 0.1),
            fam("CLOCK_COARSE", "count", 1, 1.0, True), fam("CLOCK_FINE", "count", 1, 1.0, True), fam("APP_RATE", "count", 12, 0.1),
            fam("APP_LOAD", "fraction", 12, 0.1), fam("PARTITION_STATUS", "status", 4, 1.0, True), fam("BUS_RT_ERRORS", "count", 16, 0.1, False, (0, 0, 10, 100)),
            fam("WATCHDOG_MARGIN", "duration", 1, 1.0, True, (0.0, 0.5, 30.0, 60.0))],
    "GNC": [fam("Q", "fraction", 4, 1.0, True, (-1.0, -1.0, 1.0, 1.0)), fam("RATE", "rate", 3, 1.0, True), fam("ATT_ERR", "angle", 3, 1.0, True, (-0.1, -0.02, 0.02, 0.1)),
            fam("RATE_ERR", "rate", 3, 1.0), fam("ST_T", "temperature", 2, 0.1), fam("ST_STATUS", "status", 2, 1.0, True), fam("IMU_GYRO", "rate", 6, 10.0),
            fam("IMU_ACCEL", "speed", 6, 10.0, False, (-10.0, -5.0, 5.0, 10.0)), fam("IMU_T", "temperature", 2, 0.1), fam("WHEEL_SPEED", "rate", 4, 1.0, True, (-650.0, -600.0, 600.0, 650.0)),
            fam("WHEEL_I", "current", 4, 1.0), fam("WHEEL_T", "temperature", 4, 0.1), fam("RCS_ON_TIME", "duration", 8, 0.1), fam("RCS_PULSES", "count", 8, 0.1),
            fam("SUN_SENSOR", "fraction", 6, 1.0), fam("RANGE_TO_TARGET", "length", 1, 1.0, True), fam("RANGE_RATE", "speed", 1, 1.0, True), fam("BEARING", "angle", 2, 1.0),
            fam("EPHEMERIS_AGE", "duration", 1, 0.1, True, (0.0, 0.0, 2592000.0, 7776000.0)), fam("GUIDANCE_MODE", "status", 1, 1.0, True), fam("MOMENTUM", "fraction", 3, 1.0, True, (-1.0, -0.8, 0.8, 1.0))],
    "SEP": [fam("DISCHARGE_I", "current", 3, 1.0, True, (0.0, 0.0, 30.0, 40.0)), fam("DISCHARGE_V", "voltage", 3, 1.0, True, (0.0, 200.0, 400.0, 450.0)), fam("ANODE_FLOW", "fraction", 3, 1.0),
            fam("CATHODE_FLOW", "fraction", 3, 1.0), fam("KEEPER_I", "current", 3, 1.0), fam("MAGNET_I", "current", 3, 1.0), fam("CATHODE_HTR_I", "current", 3, 1.0), fam("THRUSTER_T", "temperature", 3, 0.1, False, (233.0, 253.0, 523.0, 573.0)),
            fam("PPU_IN_POWER", "power", 3, 1.0, True, (0.0, 0.0, 7000.0, 7500.0)), fam("PPU_T", "temperature", 3, 0.1), fam("PPU_STATUS", "status", 3, 1.0, True), fam("PPU_EFFICIENCY", "fraction", 3, 0.1),
            fam("TANK_P", "pressure", 2, 0.1, True, (0.0, 2.0e5, 1.5e7, 1.8e7)), fam("TANK_T", "temperature", 2, 0.1, True), fam("XENON_REMAINING", "mass", 1, 0.01, True, (0.0, 50.0, 5000.0, 6000.0)),
            fam("FLOW_TOTAL", "mass", 1, 0.01), fam("REG_P", "pressure", 2, 1.0, True, (0.0, 1.0e5, 3.0e5, 3.5e5)), fam("LATCH_VALVE", "status", 6, 1.0, True, (0, 0, 1, 1)),
            fam("GIMBAL_ANGLE", "angle", 6, 1.0, False, (-0.25, -0.2, 0.2, 0.25)), fam("THRUST_EST", "force", 1, 1.0, True, (0.0, 0.0, 1.0, 1.2)), fam("ISP_EST", "duration", 1, 0.1, False, (0.0, 1500.0, 3000.0, 3500.0)),
            fam("ARC_ELAPSED", "duration", 1, 1.0, True), fam("ARC_REMAINING", "duration", 1, 1.0, True)],
    "EPS": [fam("BATT_CELL_V", "voltage", 32, 0.1, False, (2.5, 3.0, 4.1, 4.25)), fam("BATT_T", "temperature", 4, 0.1, True, (263.0, 273.0, 308.0, 318.0)), fam("BATT_SOC", "fraction", 2, 1.0, True, (0.3, 0.4, 1.0, 1.0)),
            fam("BATT_I", "current", 2, 1.0, True, (-60.0, -50.0, 50.0, 60.0)), fam("ARRAY_STRING_I", "current", 24, 0.1), fam("ARRAY_T", "temperature", 8, 0.1, False, (173.0, 193.0, 373.0, 393.0)),
            fam("ARRAY_V", "voltage", 4, 1.0, True, (0.0, 60.0, 120.0, 130.0)), fam("BUS_V", "voltage", 2, 1.0, True, (26.0, 27.0, 29.0, 30.0)), fam("BUS_I", "current", 2, 1.0, True, (0.0, 0.0, 150.0, 180.0)),
            fam("SW_STATE", "status", 24, 1.0, True, (0, 0, 1, 1)), fam("SW_I", "current", 24, 1.0), fam("SADA_ANGLE", "angle", 2, 1.0, True), fam("SADA_RATE", "rate", 2, 1.0),
            fam("PCU_T", "temperature", 2, 0.1, True), fam("LOAD_SHED_LEVEL", "status", 1, 1.0, True, (0, 0, 3, 3)), fam("TOTAL_LOAD", "power", 1, 1.0, True, (0.0, 0.0, 9000.0, 10000.0)),
            fam("ARRAY_POWER", "power", 1, 1.0, True, (0.0, 0.0, 12000.0, 13000.0))],
    "THM": [fam("ZONE_T", "temperature", 192, 0.1), fam("HTR_STATE", "status", 16, 1.0, True, (0, 0, 1, 1)), fam("HTR_DUTY", "fraction", 16, 0.1), fam("HTR_I", "current", 16, 0.1),
            fam("SETPOINT", "temperature", 16, 0.01), fam("LOUVER_POS", "fraction", 4, 0.1), fam("HEAT_PIPE_T", "temperature", 8, 0.1), fam("RADIATOR_T", "temperature", 4, 0.1, True, (173.0, 193.0, 323.0, 343.0)),
            fam("HTR_POWER_TOTAL", "power", 1, 1.0, True, (0.0, 0.0, 800.0, 900.0)), fam("CONTROL_MODE", "status", 1, 1.0, True, (0, 0, 2, 2))],
    "COM": [fam("TX_POWER", "power", 2, 1.0, True, (0.0, 0.0, 100.0, 110.0)), fam("RX_AGC", "fraction", 2, 1.0, True), fam("RX_LOCK", "status", 2, 1.0, True, (0, 0, 1, 1)), fam("CARRIER_LOCK", "status", 1, 1.0, True, (0, 0, 1, 1)),
            fam("SYMBOL_RATE", "count", 1, 0.1, True), fam("UPLINK_RATE", "count", 1, 0.1), fam("FRAME_COUNT", "count", 1, 1.0), fam("FRAME_ERRORS", "count", 1, 1.0, False, (0, 0, 100, 1000)),
            fam("SSPA_T", "temperature", 2, 0.1, True, (233.0, 253.0, 343.0, 353.0)), fam("SSPA_I", "current", 2, 1.0), fam("HGA_AZ", "angle", 1, 1.0, True, (-1.6, -1.5708, 1.5708, 1.6)), fam("HGA_EL", "angle", 1, 1.0, True, (-0.8, -0.7854, 0.7854, 0.8)),
            fam("ANTENNA_SEL", "status", 1, 1.0, True, (0, 0, 2, 2)), fam("RANGING_STATE", "status", 1, 1.0, True, (0, 0, 1, 1)), fam("DOPPLER", "fraction", 1, 1.0), fam("TWO_WAY_RANGE", "length", 1, 0.1),
            fam("LINK_MARGIN", "fraction", 1, 1.0, True, (0.0, 3.0, 30.0, 40.0)), fam("PASS_REMAINING", "duration", 1, 1.0), fam("EXCITER_T", "temperature", 2, 0.1), fam("XPDR_STATE", "status", 2, 1.0, True),
            fam("HGA_T", "temperature", 2, 0.1), fam("RELAY_RX_LOCK", "status", 1, 1.0, True, (0, 0, 1, 1)), fam("RELAY_RATE", "count", 1, 0.1), fam("RELAY_FRAME_COUNT", "count", 1, 1.0),
            fam("RELAY_LINK_MARGIN", "fraction", 1, 1.0, True, (0.0, 3.0, 30.0, 40.0)), fam("CODING_SEL", "status", 1, 0.1), fam("HGA_MOTOR_I", "current", 2, 1.0)],
    "INS": [fam("INSP_RANGE", "length", 1, 1.0, True, (0.0, 20.0, 5000.0, 10000.0)), fam("INSP_BEARING", "angle", 2, 1.0, True), fam("INSP_RANGE_RATE", "speed", 1, 1.0, True, (-2.0, -1.0, 1.0, 2.0)),
            fam("INSP_STATE", "status", 1, 1.0, True), fam("INSP_BATT_V", "voltage", 1, 0.1, True, (20.0, 22.0, 29.4, 30.0)), fam("INSP_BATT_SOC", "fraction", 1, 0.1, True, (0.2, 0.3, 1.0, 1.0)),
            fam("INSP_T", "temperature", 8, 0.1), fam("IMAGE_COUNT", "count", 1, 0.1), fam("IMAGE_QUEUE", "count", 1, 0.1, False, (0, 0, 200, 256)), fam("SEGMENTS_RX", "count", 1, 1.0),
            fam("SEGMENT_ERRORS", "count", 1, 1.0, False, (0, 0, 50, 500)), fam("RELAY_MARGIN", "fraction", 1, 1.0, True, (0.0, 3.0, 30.0, 40.0)), fam("CAM_T", "temperature", 2, 0.1),
            fam("CAM_STATE", "status", 2, 1.0), fam("INSP_PROPELLANT", "fraction", 1, 0.1, True, (0.0, 0.1, 1.0, 1.0)), fam("INSP_THR_PULSES", "count", 8, 0.1), fam("RELEASE_MECH_STATE", "status", 1, 1.0, True, (0, 0, 3, 3)),
            fam("RELEASE_ARMED", "status", 1, 1.0, True, (0, 0, 1, 1)), fam("LAST_CONTACT_AGE", "duration", 1, 0.1, True, (0.0, 0.0, 7200.0, 86400.0)), fam("IMAGE_COMPRESSION", "status", 1, 0.1)],
    "CAP": [fam("BAG_DEPLOY_POS", "fraction", 4, 1.0, True), fam("PETAL_ANGLE", "angle", 4, 1.0, True, (-0.1, 0.0, 2.0, 2.1)), fam("PETAL_MOTOR_I", "current", 4, 1.0, False, (0.0, 0.0, 4.0, 5.0)),
            fam("PETAL_T", "temperature", 4, 0.1), fam("CINCH_TENSION", "force", 2, 1.0, True, (0.0, 0.0, 2000.0, 2500.0)), fam("LATCH_STATE", "status", 4, 1.0, True, (0, 0, 1, 1)),
            fam("PROX_RANGE", "length", 8, 10.0, False, (0.0, 0.5, 1000.0, 2000.0)), fam("PROX_STATE", "status", 8, 1.0), fam("BODY_SPIN_RATE", "rate", 3, 1.0, True, (-0.6, -0.5, 0.5, 0.6)),
            fam("DESPIN_TORQUE", "fraction", 1, 1.0, True), fam("DESPIN_PROGRESS", "fraction", 1, 0.1, True), fam("CAPTURE_ARMED", "status", 1, 1.0, True, (0, 0, 1, 1)), fam("CAPTURE_STATE", "status", 1, 1.0, True),
            fam("CONTACT_FORCE", "force", 3, 10.0, True, (-500.0, -400.0, 400.0, 500.0)), fam("BODY_MASS_EST", "mass", 1, 0.01, True, (0.0, 1000.0, 2000000.0, 2500000.0)), fam("APPROACH_RATE", "speed", 1, 1.0, True, (-1.0, -0.5, 0.5, 1.0)),
            fam("MECHANISM_T", "temperature", 4, 0.1)],
    "AUT": [fam("SEQ_STATE", "status", 4, 1.0, True), fam("SEQ_STEP", "count", 4, 1.0, True), fam("SEQ_ID", "count", 4, 1.0, True), fam("SEQ_TIME_TO_NEXT", "duration", 4, 1.0),
            fam("RULE_FIRED_COUNT", "count", 16, 0.1), fam("RULE_ENABLED", "status", 16, 0.1, False, (0, 0, 1, 1)), fam("WAYPOINT_INDEX", "count", 1, 1.0, True, (0, 0, 31, 31)),
            fam("WAYPOINT_RANGE", "length", 1, 1.0, True), fam("AUTONOMY_LEVEL", "status", 1, 1.0, True, (0, 0, 3, 3)), fam("PLAN_HORIZON", "duration", 1, 0.1), fam("ENGINE_ENABLED", "status", 4, 1.0, True, (0, 0, 1, 1))],
    "FDR": [fam("MON_STATE", "status", 48, 1.0, True, (0, 0, 3, 3)), fam("MON_TRIP_COUNT", "count", 48, 0.1, False, (0, 0, 100, 1000)), fam("FAULT_COUNT", "count", 1, 1.0, True, (0, 0, 10, 100)),
            fam("LAST_FAULT_ID", "count", 1, 1.0, True), fam("SAFE_MODE_COUNT", "count", 1, 0.1, True, (0, 0, 2, 5)), fam("CMD_LOSS_TIMER", "duration", 1, 1.0, True, (0.0, 0.0, 518400.0, 604800.0)),
            fam("RESPONSE_MASK", "count", 1, 1.0, True), fam("FLAMEOUT_RETRIES", "count", 1, 1.0, True, (0, 0, 2, 2)), fam("RESPONSE_STATE", "status", 1, 1.0, True), fam("ACTIVE_FAULTS", "count", 1, 1.0, True, (0, 0, 3, 10)),
            fam("IMPACT_PROBABILITY", "fraction", 1, 0.1, True, (0.0, 0.0, 5.0e-5, 1.0e-4)), fam("EARTH_RANGE", "length", 1, 0.1, True, (6.378137e7, 7.0e7, 1.0e12, 1.0e13))],
    "MOD": [fam("CURRENT_MODE", "status", 1, 1.0, True, (0, 0, 15, 15)), fam("PREVIOUS_MODE", "status", 1, 1.0, True, (0, 0, 15, 15)), fam("MODE_TIME", "duration", 1, 1.0, True),
            fam("TRANSITION_COUNT", "count", 1, 1.0, True), fam("PENDING_MODE", "status", 1, 1.0, True, (0, 0, 15, 15)), fam("AUTO_TRANSITION_EN", "status", 1, 1.0, True, (0, 0, 1, 1)),
            fam("MODE_TABLE_ID", "count", 1, 0.1, True), fam("MODE_TABLE_CRC", "count", 1, 0.1), fam("SUBSYSTEM_STATE", "status", 12, 1.0, True), fam("MODE_HOLD", "status", 1, 1.0, True, (0, 0, 1, 1)),
            fam("TRANSITION_TIMEOUT", "duration", 1, 0.1)],
    "PBU": [fam("TABLE_ID", "count", 12, 0.1, True), fam("TABLE_CRC", "count", 12, 0.1), fam("TABLE_STATE", "status", 12, 0.1, True, (0, 0, 3, 3)), fam("BOOT_IMAGE_SEL", "status", 1, 0.1, True, (0, 0, 1, 1)),
            fam("BOOT_IMAGE_CRC", "count", 2, 0.1), fam("UPDATE_PROGRESS", "fraction", 1, 1.0, True), fam("UPDATE_STATE", "status", 1, 1.0, True), fam("PARAM_WRITE_COUNT", "count", 1, 0.1),
            fam("PARAM_REJECT_COUNT", "count", 1, 0.1, False, (0, 0, 10, 100)), fam("EEPROM_WRITE_CYCLES", "count", 1, 0.01, False, (0, 0, 90000, 100000))],
}

# ---- event catalogue: (name, severity, text) per application plus common events -------------
COMMON_EVENTS = [
    ("STARTED", "info", "application started"), ("STOPPED", "warning", "application stopped"),
    ("CMD_ACCEPTED", "info", "command accepted"), ("CMD_REJECTED", "warning", "command rejected"),
    ("TABLE_LOADED", "info", "parameter table loaded"), ("TABLE_INVALID", "fault", "parameter table failed validation"),
    ("WATCHDOG_MISSED", "fault", "application missed its watchdog window"), ("MODE_CHANGE_SEEN", "info", "application applied a mode change"),
]
EVENTS: dict[str, list] = {
    "CDH": [("PROCESSOR_RESET", "critical", "flight computer reset"), ("PRIME_SWITCHED", "critical", "prime computer switched"), ("CLOCK_SET", "info", "spacecraft clock set"),
            ("RECORDER_FULL", "warning", "recorder at capacity; oldest files overwritten"), ("FILE_DOWNLINKED", "info", "file downlink complete"), ("MEMORY_SCRUB_ERROR", "fault", "uncorrectable memory error scrubbed")],
    "GNC": [("SLEW_COMPLETE", "info", "slew complete within tolerance"), ("STAR_TRACKER_LOST", "fault", "star tracker lost lock"), ("IMU_FAULT", "fault", "inertial measurement unit fault"),
            ("WHEEL_SATURATION", "warning", "reaction wheel near saturation"), ("DESAT_COMPLETE", "info", "momentum dump complete"), ("TCM_COMPLETE", "info", "trajectory correction complete"),
            ("ESTIMATOR_DIVERGED", "critical", "attitude estimator diverged"), ("EPHEMERIS_STALE", "warning", "ephemeris past validity")],
    "SEP": [("ARC_STARTED", "info", "thrust arc started"), ("ARC_COMPLETE", "info", "thrust arc complete"), ("FLAMEOUT", "fault", "thruster flameout"), ("RESTART_OK", "info", "thruster restarted"),
            ("RESTART_FAILED", "critical", "thruster restart failed; switchover requested"), ("TANK_LOW", "warning", "xenon below reserve"), ("PPU_OVERCURRENT", "fault", "power processing unit over-current trip"),
            ("GIMBAL_STALL", "fault", "gimbal stalled")],
    "EPS": [("LOAD_SHED", "warning", "load shed tier applied"), ("BATTERY_LOW", "fault", "battery below low fraction"), ("BUS_UNDERVOLTAGE", "critical", "bus under-voltage trip"),
            ("SWITCH_TRIP", "fault", "power switch over-current trip"), ("ARRAY_STRING_LOST", "warning", "solar array string open"), ("SADA_STALL", "fault", "solar array drive stalled"),
            ("CHARGE_COMPLETE", "info", "battery charge complete")],
    "THM": [("ZONE_COLD", "warning", "zone below yellow low"), ("ZONE_HOT", "warning", "zone above yellow high"), ("ZONE_RED", "fault", "zone outside red limits"),
            ("HEATER_FAILED", "fault", "heater did not raise its zone"), ("SURVIVAL_ACTIVE", "warning", "survival heaters active"), ("POWER_CAP_HIT", "warning", "heater power cap reached")],
    "COM": [("CARRIER_ACQUIRED", "info", "uplink carrier acquired"), ("CARRIER_LOST", "warning", "uplink carrier lost"), ("PASS_START", "info", "ground pass started"), ("PASS_END", "info", "ground pass ended"),
            ("TX_OVERTEMP", "fault", "transmitter over temperature"), ("HGA_POINTING_ERROR", "warning", "high-gain pointing error"), ("RELAY_ACQUIRED", "info", "relay link acquired"), ("RELAY_LOST", "warning", "relay link lost")],
    "INS": [("RELEASE_ARMED", "warning", "inspector release armed"), ("RELEASED", "critical", "inspector released"), ("IMAGE_RECEIVED", "info", "inspector image complete"),
            ("SEGMENT_LOST", "warning", "image segment lost"), ("INSPECTOR_SAFE", "fault", "inspector reported safe mode"), ("INSPECTOR_RETIRED", "critical", "inspector retired"),
            ("CONTACT_LOST", "fault", "inspector contact overdue")],
    "CAP": [("CAPTURE_ARMED", "warning", "capture armed"), ("BAG_DEPLOYED", "critical", "capture bag deployed"), ("BAG_CLOSED", "critical", "capture bag closed"), ("CONTACT", "warning", "body contact detected"),
            ("CONTACT_FORCE_HIGH", "fault", "contact force above limit"), ("DESPIN_COMPLETE", "info", "despin complete"), ("LATCHED", "critical", "body latched"), ("CAPTURE_ABORTED", "critical", "capture aborted"),
            ("PETAL_STALL", "fault", "petal motor stalled"), ("PROXIMITY_SENSOR_FAULT", "fault", "proximity sensor fault")],
    "AUT": [("SEQUENCE_STARTED", "info", "sequence started"), ("SEQUENCE_COMPLETE", "info", "sequence complete"), ("SEQUENCE_FAILED", "fault", "sequence step failed"),
            ("RULE_FIRED", "warning", "autonomy rule fired"), ("WAYPOINT_REACHED", "info", "waypoint reached"), ("PLAN_INFEASIBLE", "fault", "plan infeasible within horizon")],
    "FDR": [("MONITOR_TRIP", "fault", "monitor tripped"), ("RESPONSE_TAKEN", "critical", "fault response taken"), ("SAFE_MODE_ENTERED", "critical", "safe mode entered"),
            ("COMMAND_LOSS", "critical", "command-loss timer expired"), ("ABORT_RETREAT", "critical", "abort to retreat commanded"), ("FAULT_CLEARED", "info", "fault cleared"),
            ("IMPACT_PROBABILITY_HIGH", "critical", "Earth impact probability above limit"), ("EXCLUSION_VIOLATION", "critical", "trajectory enters Earth exclusion radius")],
    "MOD": [("MODE_ENTERED", "info", "mode entered"), ("MODE_PENDING", "info", "two-step transition pending"), ("MODE_REJECTED", "warning", "transition rejected by table"),
            ("TRANSITION_TIMEOUT", "fault", "transition did not complete"), ("AUTO_TRANSITION", "warning", "event-driven transition")],
    "PBU": [("TABLE_ACTIVATED", "info", "table activated"), ("TABLE_CRC_MISMATCH", "fault", "table checksum mismatch"), ("BOOT_UPDATE_STARTED", "warning", "boot image transfer started"),
            ("BOOT_UPDATE_COMPLETE", "critical", "boot image written"), ("BOOT_FALLBACK", "critical", "boot loader fell back to the previous image"), ("PARAMETER_REJECTED", "warning", "parameter outside its range")],
}

# ---- parameter tables: four rows per application --------------------------------------------
PARAMETERS: dict[str, list] = {
    "CDH": [("watchdogPeriod", 5.0, 0.1, 30.0, "s"), ("recorderHighWater", 0.9, 0.5, 0.99, "1"), ("clockSlewLimit", 1.0, 0.01, 10.0, "s"), ("downlinkQueueDepth", 64.0, 8.0, 512.0, "1")],
    "GNC": [("slewRateLimit", 0.01, 0.0001, 0.02, "rad/s"), ("pointingTolerance", 0.001, 0.0001, 0.1, "rad"), ("wheelSpeedLimit", 600.0, 100.0, 650.0, "rad/s"), ("desatThreshold", 0.8, 0.5, 0.95, "1")],
    "SEP": [("throttleMinimum", 0.2, 0.1, 0.5, "1"), ("restartDelay", 7200.0, 60.0, 86400.0, "s"), ("dischargeTrip", 32.0, 5.0, 40.0, "A"), ("tankHeaterSetpoint", 293.0, 273.0, 323.0, "K")],
    "EPS": [("endOfChargeVoltage", 33.0, 28.0, 33.6, "V"), ("busLowTrip", 26.0, 24.0, 28.0, "V"), ("busHighTrip", 30.0, 28.0, 32.0, "V"), ("loadShedSoc", 0.3, 0.1, 0.6, "1")],
    "THM": [("deadband", 2.0, 0.5, 10.0, "K"), ("survivalLow", 243.0, 233.0, 283.0, "K"), ("survivalHigh", 253.0, 243.0, 293.0, "K"), ("heaterPowerCap", 800.0, 50.0, 900.0, "W")],
    "COM": [("defaultDownlinkRate", 2000000.0, 10.0, 4000000.0, "Hz"), ("defaultUplinkRate", 2000.0, 7.8125, 4000.0, "Hz"), ("hgaSlewLimit", 0.005, 0.0001, 0.02, "rad/s"), ("transmitPower", 60.0, 5.0, 100.0, "W")],
    "INS": [("releaseSpeed", 0.05, 0.02, 0.2, "m/s"), ("imagingCadence", 10.0, 1.0, 600.0, "s"), ("relayRate", 1000000.0, 1000.0, 2000000.0, "Hz"), ("contactTimeout", 7200.0, 600.0, 86400.0, "s")],
    "CAP": [("approachRateLimit", 0.1, 0.01, 0.5, "m/s"), ("contactForceLimit", 200.0, 1.0, 500.0, "N"), ("cinchTension", 1000.0, 10.0, 2000.0, "N"), ("despinTorqueLimit", 0.5, 0.0, 1.0, "1")],
    "AUT": [("planHorizon", 86400.0, 3600.0, 604800.0, "s"), ("autonomyLevel", 1.0, 0.0, 3.0, "1"), ("waypointHoldDefault", 600.0, 0.0, 86400.0, "s"), ("ruleCooldown", 60.0, 1.0, 3600.0, "s")],
    "FDR": [("commandLossTimeout", 604800.0, 3600.0, 2592000.0, "s"), ("flameoutRetries", 2.0, 0.0, 5.0, "1"), ("batteryLowFraction", 0.3, 0.1, 0.6, "1"), ("impactProbabilityLimit", 1.0e-4, 1.0e-7, 1.0e-3, "1")],
    "MOD": [("transitionTimeout", 300.0, 1.0, 3600.0, "s"), ("twoStepWindow", 600.0, 10.0, 3600.0, "s"), ("modeTableId", 11.0, 0.0, 11.0, "1"), ("autoTransitionDefault", 1.0, 0.0, 1.0, "1")],
    "PBU": [("stagingBufferSize", 65536.0, 4096.0, 65536.0, "1"), ("bootRetryLimit", 3.0, 1.0, 5.0, "1"), ("eepromCycleLimit", 100000.0, 1000.0, 100000.0, "1"), ("tableCount", 12.0, 1.0, 12.0, "1")],
}

FIELDS_PER_PACKET = 24
PACKET_RATE = {0.01: "0.01 [Hz]", 0.1: "0.1 [Hz]", 1.0: "1.0 [Hz]", 10.0: "10.0 [Hz]"}


def lower_camel(prefix: str, verb: str) -> str:
    parts = verb.lower().split("_")
    return prefix.lower() + "".join(p.capitalize() for p in parts)


def doc(text: str, indent: str) -> str:
    return f"{indent}doc /* {text} */\n"


def generate() -> tuple[str, dict]:
    o: list[str] = []
    w = o.append
    counts: dict = {}

    # ---- expand catalogues into flat rows ---------------------------------------------------
    commands = []  # dict rows
    for lit_, defn, prefix, cls, capid, block in APPS:
        for i, (verb, d, crit, hz, md, args) in enumerate(COMMANDS[prefix], start=1):
            commands.append(dict(name=lower_camel(prefix, verb), mnemonic=f"{prefix}_{verb}", opcode=block + i, app=lit_, cls=cls, apid=capid,
                                 doc=d, crit=crit, hazardous=hz, modes=md, args=args))
    points = []
    for lit_, defn, prefix, cls, capid, block in APPS:
        n = 0
        for suffix, kind, count, rate, hk, limits in TELEMETRY[prefix]:
            for k in range(1, count + 1):
                n += 1
                mn = f"{prefix}_{suffix}" + (f"_{k:02d}" if count > 1 else "")
                points.append(dict(name=lower_camel(prefix, suffix + (f"_{k:02d}" if count > 1 else "")), mnemonic=mn, pointId=APPS.index(APP_BY_PREFIX[prefix]) * 1000 + 1000 + n,
                                   app=lit_, cls=cls, kind=kind, rate=rate, hk=hk, limits=limits))
    events = []
    for lit_, defn, prefix, cls, capid, block in APPS:
        idx = APPS.index(APP_BY_PREFIX[prefix]) + 1
        for i, (nm, sev, text) in enumerate(COMMON_EVENTS + EVENTS[prefix], start=1):
            events.append(dict(name=lower_camel(prefix, "EVT_" + nm), mnemonic=f"{prefix}_EVT_{nm}", eventId=idx * 100 + i, app=lit_, severity=sev, text=text))
    packets = []
    apid_next = dict(APID_CLASS_BASE)
    pid = 0
    for lit_, defn, prefix, cls, capid, block in APPS:
        app_points = [p for p in points if p["app"] == lit_]
        for hk in (True, False):
            group = [p for p in app_points if p["hk"] == hk]
            for c in range(math.ceil(len(group) / FIELDS_PER_PACKET)):
                chunk = group[c * FIELDS_PER_PACKET:(c + 1) * FIELDS_PER_PACKET]
                pid += 1
                tag = "Hk" if hk else "Eng"
                rate = max(p["rate"] for p in chunk)
                packets.append(dict(name=f"{prefix.lower()}{tag}Packet{c + 1:02d}", mnemonic=f"{prefix}_{tag.upper()}_{c + 1:02d}", packetId=pid, apid=apid_next[cls], cls=cls,
                                    app=lit_, rate=rate if rate in PACKET_RATE else 1.0, fields=chunk))
                apid_next[cls] += 1

    # ---- header -----------------------------------------------------------------------------
    w("// Mission tier: the flight dictionary of the Argent tug — every command, telemetry point, event\n")
    w("// and packet the flight software and the ground system agree on, with the tables the monitors\n")
    w("// read and the time code the packets carry. GENERATED by scripts/gen-flight-dictionary.py; edit\n")
    w("// the generator, not this file. Everything here is fictional except the CCSDS Space Packet\n")
    w("// primary header layout (CCSDS 133.0-B-2). Standard libraries only.\n")
    w("package TethysFlightDictionary {\n")
    w("    private import ScalarValues::*;\n    private import SequenceFunctions::*;\n    private import ControlFunctions::*;\n    private import NumericalFunctions::*;\n")
    w("    private import ISQ::*;\n    private import SI::*;\n")
    w("    private import TethysTugStructure::*;\n    private import TethysIcds::*;\n    private import TethysOperations::*;\n")
    w("    private import TethysFdir::MonitorLimits;\n    private import TethysFdir::FdirLevel;\n    private import TethysFdir::cruiseLimits;\n")
    w("    private import TethysFlightSoftware::SoftwareEvent;\n    private import TethysFlightSoftware::ParameterTable;\n\n")

    # ---- vocabulary -------------------------------------------------------------------------
    w("    // ---- vocabulary ----------------------------------------------------------------------\n")
    w("    enum def ApplicationName {\n")
    w(doc("The applications of the flight software backbone, one literal per application definition of TethysFlightSoftware, in the backbone's order. A telemetry point, event or packet names its source with one.", "        "))
    for lit_, defn, *_ in APPS:
        w(f"        enum {lit_};\n")
    w("    }\n")
    w("    enum def CommandCriticality {\n")
    w(doc("How a command is treated by the ground and the on-board command service: routine commands need no confirmation, critical ones are two-step on the ground, hazardous ones also carry a confirmation key on board.", "        "))
    w("        enum routine;\n        enum critical;\n        enum hazardous;\n    }\n")
    w("    enum def EventSeverity {\n")
    w(doc("Severity of an on-board event: information, a warning the operators review, a fault the fault application handles, or a critical event that drives a mode change.", "        "))
    w("        enum info;\n        enum warning;\n        enum fault;\n        enum critical;\n    }\n")
    w("    enum def TelemetryKind {\n")
    w(doc("Housekeeping points are downlinked in every pass at a fixed rate; engineering points are recorded and downlinked on request.", "        "))
    w("        enum housekeeping;\n        enum engineering;\n    }\n")
    w("    enum def Opcode {\n")
    w(doc(f"The opcode enumeration: one literal per command, {len(commands)} in all, named by the command mnemonic. The numeric opcode of each is on the command.", "        "))
    for c in commands:
        w(f"        enum {c['mnemonic']};\n")
    w("    }\n\n")

    # ---- time code and headers -------------------------------------------------------------
    w("    // ---- time code and packet headers ---------------------------------------------------\n")
    w("    attribute def TethysTimeCode {\n")
    w(doc("The Tethys time code carried in every packet secondary header: 32 bits of seconds and 16 bits of 1/65 536 s fractions since the mission epoch, a fictional segmented code in the style of CCSDS 301.0-B-4 CUC.", "        "))
    w("        attribute epoch : String = \"2030-01-01T00:00:00 TRT\";\n        attribute coarseWidth : Natural = 32;\n        attribute fineWidth : Natural = 16;\n")
    w("        attribute fineResolution : DurationValue = 1.52587890625e-5 [s];\n        attribute width : Natural = coarseWidth + fineWidth;\n    }\n")
    w("    attribute def PrimaryHeaderLayout {\n")
    w(doc("The CCSDS Space Packet primary header, 48 bits: version, type, secondary header flag, application process id, sequence flags, sequence count and data length (CCSDS 133.0-B-2 §4.1.3).", "        "))
    w("        attribute versionWidth : Natural = 3;\n        attribute typeWidth : Natural = 1;\n        attribute secondaryHeaderFlagWidth : Natural = 1;\n        attribute apidWidth : Natural = 11;\n")
    w("        attribute sequenceFlagsWidth : Natural = 2;\n        attribute sequenceCountWidth : Natural = 14;\n        attribute dataLengthWidth : Natural = 16;\n")
    w("        attribute width : Natural = versionWidth + typeWidth + secondaryHeaderFlagWidth + apidWidth + sequenceFlagsWidth + sequenceCountWidth + dataLengthWidth;\n    }\n")
    w("    attribute def PacketField {\n")
    w(doc("One field of a packet data field: its order, bit offset from the start of the packet, width in bits and the mnemonic of the telemetry point it carries.", "        "))
    w("        attribute order : Natural;\n        attribute offset : Natural;\n        attribute width : Natural;\n        attribute point : String;\n    }\n\n")

    # ---- definitions ------------------------------------------------------------------------
    w("    // ---- dictionary row definitions -----------------------------------------------------\n")
    w("    attribute def CommandArgument {\n")
    w(doc("A command argument: its range and the width it is packed into. An argument is typed by this and by its ISQ quantity type.", "        "))
    w("        attribute minimum : Real;\n        attribute maximum : Real;\n        attribute widthBits : Natural;\n    }\n")
    w("    item def CommandDefinition :> Command {\n")
    w(doc("One command of the dictionary: opcode literal and number, mnemonic, owning application, the modes it is accepted in, its criticality and hazard flag, and its arguments.", "        "))
    w("        attribute opcodeLiteral : Opcode;\n        attribute opcodeNumber : Natural;\n        attribute mnemonic : String;\n        attribute application : ApplicationName;\n")
    w("        attribute allowedModes : TugMode[1..*];\n        attribute criticality : CommandCriticality;\n        attribute hazardous : Boolean;\n")
    w("        attribute argumentCount : Natural;\n        attribute argumentBits : Natural;\n        attribute :>> opcode = mnemonic;\n    }\n")
    w("    item def TelemetryPointDefinition :> TelemetryPoint {\n")
    w(doc("One telemetry point of the dictionary: id, source application, kind, sample rate, packed width and unit symbol. The typed value and limits are on the per-quantity specialisations.", "        "))
    w("        attribute pointId : Natural;\n        attribute source : ApplicationName;\n        attribute kind : TelemetryKind;\n        attribute rate : FrequencyValue;\n")
    w("        attribute widthBits : Natural;\n        attribute unitSymbol : String;\n    }\n")
    for kind, (defn, isq, unit, sym, bits) in TM_KINDS.items():
        w(f"    item def {defn} :> TelemetryPointDefinition {{\n")
        w(doc(f"A {kind} point: value and red/yellow limits typed as {isq}.", "        "))
        w(f"        attribute value : {isq};\n        attribute redLow : {isq};\n        attribute yellowLow : {isq};\n        attribute yellowHigh : {isq};\n        attribute redHigh : {isq};\n")
        w(f"        attribute :>> widthBits = {bits};\n        attribute :>> unitSymbol = \"{sym}\";\n")
        w("        assert constraint limitsOrdered { redLow <= yellowLow and yellowLow <= yellowHigh and yellowHigh <= redHigh }\n    }\n")
    w("    item def EventDefinition :> SoftwareEvent {\n")
    w(doc("One event of the dictionary: id, mnemonic, source application, severity, the text the ground shows, and whether the fault application acts on it.", "        "))
    w("        attribute eventId : Natural;\n        attribute mnemonic : String;\n        attribute source : ApplicationName;\n        attribute severity : EventSeverity;\n")
    w("        attribute text : String;\n        attribute fdirRelevant : Boolean;\n    }\n")
    w("    item def PacketDefinition :> TelemetryPacket {\n")
    w(doc("One telemetry packet of the dictionary: its APID and class, source application, rate, header layout, ordered fields, and the length the field widths must sum to.", "        "))
    w("        attribute packetId : Natural;\n        attribute mnemonic : String;\n        attribute apidClass : ApidClass;\n        attribute source : ApplicationName;\n        attribute rate : FrequencyValue;\n")
    w("        attribute primaryHeader : PrimaryHeaderLayout;\n        attribute timeCode : TethysTimeCode;\n        attribute headerBits : Natural = primaryHeader.width + timeCode.width;\n")
    w("        attribute fieldCount : Natural;\n        attribute widths : Natural[*] nonunique;\n        attribute offsets : Natural[*];\n        attribute payloadBits : Natural = sum(widths);\n")
    w("        attribute lengthOctets : Natural;\n        attribute :>> length = lengthOctets [B];\n")
    w("        attribute layoutConsistent : Boolean = headerBits + payloadBits == lengthOctets * 8 and size(widths) == fieldCount\n")
    w("            and last(offsets) + last(widths) == lengthOctets * 8;\n    }\n")
    w("    attribute def ParameterRow {\n")
    w(doc("One row of a parameter table: id, name, owning application, flight value, range and unit symbol.", "        "))
    w("        attribute parameterId : Natural;\n        attribute name : String;\n        attribute owner : ApplicationName;\n        attribute value : Real;\n")
    w("        attribute minimum : Real;\n        attribute maximum : Real;\n        attribute unitSymbol : String;\n")
    w("        attribute inRange : Boolean = minimum <= value and value <= maximum;\n    }\n")
    w("    item def FlightParameterTable :> ParameterTable {\n")
    w(doc("A parameter table of one application: its rows, loaded and activated by the table service.", "        "))
    w("        attribute owner : ApplicationName;\n        attribute rows : ParameterRow[*];\n        attribute rowCount : Natural = SequenceFunctions::size(rows);\n        attribute :>> size = rowCount * 16 [B];\n")
    w("        attribute allInRange : Boolean = rows->forAll { in r : ParameterRow; r.inRange };\n    }\n")
    w("    attribute def FdirLimitTable {\n")
    w(doc("The limit table the fault supervisor's monitors read: one typed row per monitor threshold, named as the threshold is named in the supervisor's limit set.", "        "))
    w("        attribute tableId : Natural;\n        attribute commandLossTimeout : DurationValue;\n        attribute thrusterRestartDelay : DurationValue;\n        attribute maximumFlameoutRetries : Natural;\n")
    w("        attribute batteryLowFraction : Real;\n        attribute earthExclusionRadius : LengthValue;\n        attribute maximumImpactProbability : Real;\n        attribute rowCount : Natural = 6;\n    }\n\n")

    # ---- commands ---------------------------------------------------------------------------
    w(f"    // ---- command dictionary: {len(commands)} commands ----------------------------------------\n")
    for c in commands:
        w(f"    item {c['name']} : CommandDefinition {{\n")
        w(doc(c["doc"], "        "))
        w(f"        :>> opcodeLiteral = Opcode::{c['mnemonic']}; :>> opcodeNumber = {c['opcode']}; :>> mnemonic = \"{c['mnemonic']}\";\n")
        w(f"        :>> application = ApplicationName::{c['app']}; :>> apidClass = ApidClass::{c['cls']}; :>> apid = {c['apid']};\n")
        w(f"        :>> allowedModes = {c['modes']}; :>> criticality = CommandCriticality::{c['crit']}; :>> hazardous = {'true' if c['hazardous'] else 'false'};\n")
        bits = sum(a[4] for a in c["args"])
        w(f"        :>> argumentCount = {len(c['args'])}; :>> argumentBits = {bits};\n")
        for an, kind, lo, hi, ab in c["args"]:
            t, u = ARG_KINDS[kind]
            w(f"        attribute {an} : {t}, CommandArgument {{ :>> minimum = {arg_lit('fraction', lo)}; :>> maximum = {arg_lit('fraction', hi)}; :>> widthBits = {ab}; }}\n")
        w("    }\n")
    w("\n")

    # ---- telemetry --------------------------------------------------------------------------
    w(f"    // ---- telemetry dictionary: {len(points)} points ------------------------------------------\n")
    for p in points:
        defn = TM_KINDS[p["kind"]][0]
        rl, yl, yh, rh = p["limits"]
        k = p["kind"]
        w(f"    item {p['name']} : {defn} {{\n")
        w(f"        :>> mnemonic = \"{p['mnemonic']}\"; :>> pointId = {p['pointId']}; :>> source = ApplicationName::{p['app']}; :>> apidClass = ApidClass::{p['cls']};\n")
        w(f"        :>> kind = TelemetryKind::{'housekeeping' if p['hk'] else 'engineering'}; :>> rate = {PACKET_RATE[p['rate']]};\n")
        w(f"        :>> redLow = {lit(k, rl)}; :>> yellowLow = {lit(k, yl)}; :>> yellowHigh = {lit(k, yh)}; :>> redHigh = {lit(k, rh)};\n")
        w("    }\n")
    w("\n")

    # ---- events -----------------------------------------------------------------------------
    w(f"    // ---- event dictionary: {len(events)} events ----------------------------------------------\n")
    level = {"info": "unit", "warning": "unit", "fault": "subsystem", "critical": "system"}
    for e in events:
        is_fault = e["severity"] in ("fault", "critical")
        w(f"    item {e['name']} : EventDefinition {{\n")
        w(f"        :>> eventId = {e['eventId']}; :>> mnemonic = \"{e['mnemonic']}\"; :>> source = ApplicationName::{e['app']}; :>> severity = EventSeverity::{e['severity']};\n")
        w(f"        :>> text = \"{e['text']}\"; :>> fdirRelevant = {'true' if is_fault else 'false'}; :>> isFault = {'true' if is_fault else 'false'}; :>> level = FdirLevel::{level[e['severity']]};\n")
        w("    }\n")
    w("\n")

    # ---- packets ----------------------------------------------------------------------------
    w(f"    // ---- packet definitions: {len(packets)} telemetry packets ---------------------------------\n")
    header_bits = 48 + 48
    for pk in packets:
        widths = [TM_KINDS[p["kind"]][4] for p in pk["fields"]]
        payload = sum(widths)
        total = header_bits + payload
        octets = math.ceil(total / 8)
        pad = octets * 8 - total
        if pad:
            widths.append(pad)
        w(f"    item {pk['name']} : PacketDefinition {{\n")
        w(f"        :>> packetId = {pk['packetId']}; :>> mnemonic = \"{pk['mnemonic']}\"; :>> apid = {pk['apid']}; :>> apidClass = ApidClass::{pk['cls']};\n")
        w(f"        :>> source = ApplicationName::{pk['app']}; :>> rate = {PACKET_RATE[pk['rate']]}; :>> fieldCount = {len(widths)}; :>> lengthOctets = {octets};\n")
        off = header_bits
        names = []
        for i, wd in enumerate(widths, start=1):
            point = pk["fields"][i - 1]["mnemonic"] if i - 1 < len(pk["fields"]) else "PAD"
            w(f"        attribute f{i:02d} : PacketField {{ :>> order = {i}; :>> offset = {off}; :>> width = {wd}; :>> point = \"{point}\"; }}\n")
            names.append(f"f{i:02d}")
            off += wd
        w(f"        :>> widths = ({', '.join(n + '.width' for n in names)});\n")
        w(f"        :>> offsets = ({', '.join(n + '.offset' for n in names)});\n")
        w("    }\n")
    w("\n")

    # ---- tables -----------------------------------------------------------------------------
    w("    // ---- parameter and limit tables -------------------------------------------------------\n")
    tables = []
    pid_ = 0
    for ti, (lit_, defn, prefix, *_rest) in enumerate(APPS, start=1):
        name = f"{prefix.lower()}ParameterTable"
        tables.append(name)
        w(f"    item {name} : FlightParameterTable {{\n")
        w(doc(f"Parameter table {ti}: the flight parameters of the {prefix} application.", "        "))
        w(f"        :>> tableId = {ti}; :>> owner = ApplicationName::{lit_};\n")
        rows = []
        for rn, (pname, val, lo, hi, unit) in enumerate(PARAMETERS[prefix], start=1):
            pid_ += 1
            rows.append(f"r{rn}")
            w(f"        attribute r{rn} : ParameterRow {{ :>> parameterId = {pid_}; :>> name = \"{pname}\"; :>> owner = ApplicationName::{lit_}; :>> value = {arg_lit('fraction', val)}; :>> minimum = {arg_lit('fraction', lo)}; :>> maximum = {arg_lit('fraction', hi)}; :>> unitSymbol = \"{unit}\"; }}\n")
        w(f"        :>> rows = ({', '.join(rows)});\n    }}\n")
    w("    attribute flightLimitTable : FdirLimitTable {\n")
    w(doc("The flight limit table: the six thresholds the fault supervisor's cruise limits read, one row each.", "        "))
    w("        :>> tableId = 13;\n        :>> commandLossTimeout = 7.0 [d];\n        :>> thrusterRestartDelay = 2.0 [h];\n        :>> maximumFlameoutRetries = 2;\n")
    w("        :>> batteryLowFraction = 0.30;\n        :>> earthExclusionRadius = 63781.37 [km];\n        :>> maximumImpactProbability = 1.0e-4;\n    }\n")
    w("    attribute tableLimits : MonitorLimits {\n")
    w(doc("The supervisor's limit set as read from the limit table: every threshold is a table row.", "        "))
    for f in ("commandLossTimeout", "thrusterRestartDelay", "maximumFlameoutRetries", "batteryLowFraction", "earthExclusionRadius", "maximumImpactProbability"):
        w(f"        :>> {f} = flightLimitTable.{f};\n")
    w("    }\n")
    w("    attribute flightApids : ApidTable {\n")
    w(doc("The APID class bases of the flight dictionary: each class's packets are numbered upward from its base.", "        "))
    for cls, base in APID_CLASS_BASE.items():
        w(f"        :>> {cls} = {base};\n")
    w("    }\n\n")

    # ---- the dictionary ---------------------------------------------------------------------
    w("    // ---- the dictionary and its consistency checks ----------------------------------------\n")
    w("    part def FlightDictionary :> Dictionary {\n")
    w(doc("The flight dictionary: the rows above collected, with the counts and the consistency flags the dictionary requirement reads computed from them. The opcode, mnemonic, APID and event id sequences are unique features, so a repeated value fails their evaluation.", "        "))
    w("        item commands : CommandDefinition[*];\n        item telemetryPoints : TelemetryPointDefinition[*];\n        item events : EventDefinition[*];\n        item packets : PacketDefinition[*];\n")
    w("        item parameterTables : FlightParameterTable[*];\n        attribute limitTable : FdirLimitTable;\n        attribute commandApids : Natural[*];\n")
    w("        attribute opcodeNumbers : Natural[*] = commands.opcodeNumber;\n        attribute commandMnemonics : String[*] = commands.mnemonic;\n")
    w("        attribute telemetryMnemonics : String[*] = telemetryPoints.mnemonic;\n        attribute eventIds : Natural[*] = events.eventId;\n")
    w("        attribute packetApids : Natural[*] = packets.apid;\n        attribute apidsAllocated : Natural[*] = (packetApids, commandApids);\n")
    w("        attribute :>> commandCount = size(commands);\n        attribute :>> telemetryPointCount = size(telemetryPoints);\n")
    w("        attribute :>> eventCount = size(events);\n        attribute :>> packetCount = size(packets);\n")
    w("        attribute :>> opcodesUnique = size(opcodeNumbers) == commandCount;\n")
    w("        attribute :>> mnemonicsUnique = size(commandMnemonics) == commandCount and size(telemetryMnemonics) == telemetryPointCount;\n")
    w("        attribute :>> apidsUnique = size(apidsAllocated) == packetCount + size(commandApids);\n")
    w("        attribute :>> apidsWithinRange = apidsAllocated->forAll { in a : Natural; a <= apidMaximum };\n")
    w("        attribute :>> eventIdsUnique = size(eventIds) == eventCount;\n")
    w("        attribute :>> packetsSumToLength = packets->forAll { in p : PacketDefinition; p.layoutConsistent };\n")
    w("        attribute :>> commandsHaveModePrecondition = commands->forAll { in c : CommandDefinition; c.opcodeNumber != null and notEmpty(c.allowedModes) and includes(commandApids, c.apid) };\n")
    w("        attribute :>> pointsHaveSource = telemetryPoints->forAll { in t : TelemetryPointDefinition; t.source != null };\n")
    w("        attribute :>> parametersInRange = parameterTables->forAll { in t : FlightParameterTable; t.allInRange };\n")
    w("        attribute :>> fdirThresholdsReadLimitTable = cruiseLimits.commandLossTimeout == limitTable.commandLossTimeout\n")
    w("            and cruiseLimits.thrusterRestartDelay == limitTable.thrusterRestartDelay\n            and cruiseLimits.maximumFlameoutRetries == limitTable.maximumFlameoutRetries\n")
    w("            and cruiseLimits.batteryLowFraction == limitTable.batteryLowFraction\n            and cruiseLimits.earthExclusionRadius == limitTable.earthExclusionRadius\n")
    w("            and cruiseLimits.maximumImpactProbability == limitTable.maximumImpactProbability;\n")
    w("        attribute hazardousCommandCount : Natural = size(commands->select { in c : CommandDefinition; c.hazardous });\n")
    w("        attribute housekeepingPointCount : Natural = size(telemetryPoints->select { in t : TelemetryPointDefinition; t.kind == TelemetryKind::housekeeping });\n")
    w("        attribute faultEventCount : Natural = size(events->select { in e : EventDefinition; e.fdirRelevant });\n")
    w("        attribute abortOpcode : Opcode = Opcode::FDR_ABORT_TO_RETREAT;\n")
    w("        attribute abortIsHazardous : Boolean = commands->exists { in c : CommandDefinition; c.opcodeLiteral == abortOpcode and c.hazardous };\n")
    w("    }\n")
    w("    part flightDictionary : FlightDictionary {\n")
    w(doc("The Tethys flight dictionary at its current issue.", "        "))
    w("        :>> apids = flightApids;\n        :>> limitTable = flightLimitTable;\n")
    w(f"        :>> commandApids = ({', '.join(str(a[4]) for a in APPS)});\n")
    def seq(label, names):
        w(f"        :>> {label} = (\n")
        line = "            "
        for i, n in enumerate(names):
            tok = n + ("," if i < len(names) - 1 else "")
            if len(line) + len(tok) + 1 > 110:
                w(line.rstrip() + "\n")
                line = "            "
            line += tok + " "
        w(line.rstrip() + ");\n")
    seq("commands", [c["name"] for c in commands])
    seq("telemetryPoints", [p["name"] for p in points])
    seq("events", [e["name"] for e in events])
    seq("packets", [p["name"] for p in packets])
    seq("parameterTables", tables)
    w("    }\n")
    w("    satisfy dictionaryConsistent by flightDictionary {\n")
    w(doc("The flight dictionary passes the dictionary requirement: distinct opcodes, mnemonics, application ids and event ids; every command accepted in at least one mode; every packet summing to its length; every point sourced; every supervisor threshold a table row.", "        "))
    w("    }\n")
    w("}\n")

    counts = dict(commands=len(commands), opcodes=len(commands), hazardous=sum(1 for c in commands if c["hazardous"]), arguments=sum(len(c["args"]) for c in commands),
                  telemetryPoints=len(points), housekeepingPoints=sum(1 for p in points if p["hk"]), events=len(events), packets=len(packets),
                  packetFields=sum(len(p["fields"]) for p in packets), parameterRows=pid_, limitRows=6, applications=len(APPS))
    return "".join(o), counts


def main() -> int:
    text, counts = generate()
    out = os.path.normpath(OUT)
    if "--check" in sys.argv:
        with open(out, encoding="utf-8") as f:
            same = f.read() == text
        print("up to date" if same else "STALE: re-run scripts/gen-flight-dictionary.py")
        return 0 if same else 1
    with open(out, "w", encoding="utf-8") as f:
        f.write(text)
    for k, v in counts.items():
        print(f"{k}: {v}")
    print(f"lines: {text.count(chr(10))}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
