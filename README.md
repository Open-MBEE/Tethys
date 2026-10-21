# Hesperia — a complete, simulated planetary mission in SysML v2

Hesperia is a **fictional** Venus mission: the *Hesperia Orbiter* carries the short-lived
atmospheric descent probe *Kestrel*, launches on the fictional *Arcturus-5H*, and is operated
through the fictional *Meridian* deep-space network. Every name, budget and performance figure in
this repository is invented; only the physics of Venus and of spaceflight is real.

The model is written in standard SysML v2 and exists for two purposes:

1. to show what a *complete* mission model looks like — stakeholders and needs, requirement
   tiers with derivation and verification, functional/logical/physical architecture with
   allocations, interface control, every engineering budget with margins, modes and fault
   management, trades and Monte Carlo analyses, risks, the as-built individual with imported
   telemetry, operations products, views and rendered documents — all executable and queryable;
2. to find where [OpenSysML](https://github.com/Open-MBEE/OpenSysML) stops being correct,
   complete or fast. Every tool defect the model surfaces is recorded in
   [docs/findings.md](docs/findings.md) with the construct that shows it.

## Layout

| Path | Content |
| --- | --- |
| `model/` | the model, one top-level package per file (`NN-<area>.sysml`), see [CONVENTIONS.md](CONVENTIONS.md) |
| `runs/` | the pinned output of every command `make check` runs over the model |
| `docs/` | the coverage matrix the model is checked against, the findings register, rendered documents |
| `scripts/` | the gate scripts `make` calls |

## Running it

```bash
make tools      # fetch OpenSysML (nightly) and the pinned OMG pilot validator into build/
make check      # every gate: validate (strict), pilot, house rules, satisfy, runs/ diff
make runs       # re-record runs/ after an intentional model change
```
