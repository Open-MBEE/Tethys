"""The Argent conformance harness: proves the flight host, the generated tables and the ground
suite agree with the Tethys model at the pinned OpenSysML, and turns the model's planned
software verification cases into as-run evidence. Runtime dependencies: the pinned ``opensysml``
client, the generated ``argent_tables`` and the standard library."""
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
HERE = os.path.join(ROOT, "software", "conformance")
EXPECTED = os.path.join(HERE, "expected")
EVIDENCE = os.path.join(HERE, "evidence")
OUT = os.environ.get("CONFORMANCE_OUT", os.path.join(ROOT, "build", "software", "conformance"))
HOST = os.environ.get("ARGENT_HOST", os.path.join(ROOT, "build", "software", "flight", "argent_host"))
SYSML = os.environ.get("SYSML", os.path.join(ROOT, "build", "opensysml", "sysml"))
TOOL_PIN = "5cd37f288fef171d62737d6045f4caff772b6014"
