#!/usr/bin/env python3
"""Edelbaum low-thrust transfer solver for the Tethys external-tool analysis.

Circular-coplanar heliocentric transfer between two radii (AU) with a plane
change (degrees), then the exact rocket equation for the propellant and the
thrusting time at constant thrust and specific impulse. Answers one CSV record.
"""

import argparse
import csv
import math
import sys

SUN_GM_KM3_PER_S2 = 1.32712440018e11
AU_KM = 149597870.7
G0 = 9.80665


def main():
    parser = argparse.ArgumentParser(description="Edelbaum low-thrust transfer")
    parser.add_argument("--start-au", type=float, required=True)
    parser.add_argument("--end-au", type=float, required=True)
    parser.add_argument("--plane-change-deg", type=float, required=True)
    parser.add_argument("--initial-mass-kg", type=float, required=True)
    parser.add_argument("--thrust-n", type=float, required=True)
    parser.add_argument("--isp-s", type=float, required=True)
    args = parser.parse_args()
    if min(args.start_au, args.end_au, args.initial_mass_kg, args.thrust_n, args.isp_s) <= 0:
        print("radii, mass, thrust and Isp must be positive", file=sys.stderr)
        return 2
    v0 = math.sqrt(SUN_GM_KM3_PER_S2 / (args.start_au * AU_KM))
    v1 = math.sqrt(SUN_GM_KM3_PER_S2 / (args.end_au * AU_KM))
    di = math.radians(args.plane_change_deg)
    delta_v = 1000.0 * math.sqrt(v0 * v0 + v1 * v1 - 2.0 * v0 * v1 * math.cos(math.pi / 2.0 * di))
    exhaust = args.isp_s * G0
    propellant = args.initial_mass_kg * (1.0 - math.exp(-delta_v / exhaust))
    mass_flow = args.thrust_n / exhaust
    days = propellant / mass_flow / 86400.0
    writer = csv.writer(sys.stdout, lineterminator="\n")
    writer.writerow(["deltaVMPerS", "propellantKg", "thrustDays"])
    writer.writerow([delta_v, propellant, days])
    return 0


if __name__ == "__main__":
    sys.exit(main())
