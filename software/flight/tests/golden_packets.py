#!/usr/bin/env python3
"""Cross-checks the flight telemetry service against the ground package's golden packets:
`software/ground/fixtures/packets.json` (format meridian-packet-fixtures/1) carries, per dictionary
packet, the engineering value of every point and the bytes the ground side expects. The flight side
must produce the same bytes from the same engineering values (header, time code, every field)."""
import json
import os
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))


def main():
    host = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "build", "software", "flight", "argent_host")
    fixture = sys.argv[2] if len(sys.argv) > 2 else os.path.join(ROOT, "software", "ground", "fixtures", "packets.json")
    out = sys.argv[3] if len(sys.argv) > 3 else os.path.join(ROOT, "build", "software", "flight", "golden.txt")
    if not os.path.exists(fixture):
        print(f"golden packets: no fixture at {fixture}; skipped")
        return 0
    with open(fixture) as f:
        data = json.load(f)
    if data.get("format") != "meridian-packet-fixtures/1":
        print(f"golden packets: unknown fixture format {data.get('format')!r}")
        return 1
    os.makedirs(os.path.dirname(out), exist_ok=True)
    expected = {}
    with open(out, "w") as f:
        for p in data["packets"]:
            for point, value in p["engineering"].items():
                f.write(f"value {point} {value!r}\n")
            f.write(f"packet {p['mnemonic']} {p['time_coarse']} {p['time_fine']} {p['sequence_count']}\n")
            expected[p["mnemonic"]] = p["hex"]
    result = subprocess.run([host, "--golden", out], capture_output=True, text=True)
    if result.returncode != 0:
        print(result.stderr.strip())
        return 1
    failures = 0
    for line in result.stdout.splitlines():
        mnemonic, hexdata = line.split()
        if hexdata != expected.get(mnemonic):
            failures += 1
            want = expected.get(mnemonic, "")
            first = next((i for i in range(min(len(want), len(hexdata))) if want[i] != hexdata[i]), min(len(want), len(hexdata)))
            print(f"FAIL {mnemonic}: differs from octet {first // 2}: flight {hexdata[first:first + 16]} ground {want[first:first + 16]}")
    print(f"{len(expected) - failures}/{len(expected)} golden packets reproduced byte for byte")
    return 1 if failures or not expected else 0


if __name__ == "__main__":
    sys.exit(main())
