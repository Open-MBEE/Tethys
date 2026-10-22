# Tethys — a complete, simulated deep-space mission in SysML v2

Tethys Retrieval is a **fictional** asteroid-retrieval mission: the solar-electric tug *Argent*
flies to the small near-Earth asteroid 2031 QX *"Amaranth"*, characterises it with the free-flying
inspector *Wren*, captures and despins it, and returns it to a lunar distant retrograde orbit for
the visiting vehicle *Lantern*. It launches on the fictional *Arcturus-5H* and is operated through
the fictional *Meridian* deep-space network. Every name, body, budget and performance figure in
this repository is invented; only the physics of spaceflight and of the Sun–Earth–Moon system is
real.

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
make tools      # build OpenSysML from source at the pinned commit (scripts/fetch-tools.sh) and fetch the pinned OMG pilot validators into build/
make check      # every gate: validate (strict), pilot (mission tier standalone, all files batch), house rules, runs/ diff
make runs       # re-record runs/ after an intentional model change
```
