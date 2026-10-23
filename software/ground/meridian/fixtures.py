"""Golden packet fixtures: one encoded packet per dictionary packet, built from the tables by the
``ccsds`` encoder with a deterministic raw pattern, so the flight side can be checked against the
same bytes. Format: see ``software/ground/README.md``."""

from __future__ import annotations

import json
import os

from argent_tables import packets, telemetry

from . import ccsds
from .simulators.mirror import raw_pattern

FIXTURE_PATH = os.path.join(os.path.dirname(__file__), "..", "fixtures", "packets.json")
FIXTURE_TIME_S = 1234.5
FIXTURE_SEQUENCE_COUNT = 7


def build() -> dict:
    rows = []
    for p in packets.PACKETS:
        raw = {f.point: raw_pattern(telemetry.TELEMETRY_BY_MNEMONIC[f.point], f.order, FIXTURE_TIME_S) for f in p.fields}
        data = ccsds.encode(p, raw, ccsds.TimeCode.from_seconds(FIXTURE_TIME_S), FIXTURE_SEQUENCE_COUNT)
        engineering = {}
        for f in p.fields:
            point = telemetry.TELEMETRY_BY_MNEMONIC[f.point]
            scale, offset = ccsds.calibration(point)
            engineering[f.point] = ccsds.engineering_units(raw[f.point], scale, offset)
        rows.append({"mnemonic": p.mnemonic, "apid": p.apid, "length_octets": p.length_octets, "sequence_count": FIXTURE_SEQUENCE_COUNT,
                     "time_coarse": ccsds.TimeCode.from_seconds(FIXTURE_TIME_S).coarse, "time_fine": ccsds.TimeCode.from_seconds(FIXTURE_TIME_S).fine,
                     "hex": data.hex(), "raw": raw, "engineering": engineering})
    return {"format": "meridian-packet-fixtures/1", "model_tool_commit": __import__("argent_tables").MODEL_TOOL_COMMIT,
            "primary_header": packets.PRIMARY_HEADER, "time_code": packets.TIME_CODE, "packets": rows}


def write(path: str = FIXTURE_PATH) -> str:
    text = json.dumps(build(), indent=1, sort_keys=True) + "\n"
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    return text


def read(path: str = FIXTURE_PATH) -> dict:
    with open(path, encoding="utf-8") as f:
        return json.load(f)


if __name__ == "__main__":
    write()
