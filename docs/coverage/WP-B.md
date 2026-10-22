# WP-B coverage — Argent tug structure and engineering budgets

Files: `model/30-margin-policy.sysml` (`TethysMarginPolicy`), `model/31-tug-structure.sysml`
(`TethysTugStructure`), `model/32-budgets.sysml` (`TethysBudgets`). The margin policy comes first
because the pilot validator resolves cross-file references in file order and the other two
import it. Build: OpenSysML `v0.10.1-2054-g0a5fa2d94`; proving commands are the `wpb-*` lines of
`scripts/runs.sh`, each one expression per process (F-B01). Findings: `docs/findings/WP-B.md`.

Result legend: ✓ satisfied · ◐ construct in the model, tool result wrong or blocked (finding) ·
○ open (not covered by this package) · — owned elsewhere.

## SE rows

| Row | File : element | Proving command | Result |
| --- | --- | --- | --- |
| SE-071 must | 31 : `TugFunctions` and its 13 `action def`s (`ProvidePower` … `RejectHeat`) with typed `in`/`out` items (`ThrustCommand`, `AttitudeEstimate`, `RelativeState`, `CharacterisationData`) | `make validate`; `house-rules` run (every definition has `doc`) | ✓ |
| SE-072 should | — | — | ○ successions and timing of the functions are WP-E's state/sequence rows |
| SE-073 must | 31 : each subsystem def `perform functions.<x>` (e.g. `ArgentPropulsion` performs `generateThrust`, `feedXenon`) | `make validate` | ◐ implementation-free layer is the function tree itself; no separate `#logical` parts |
| SE-074 must | 31 : `ArgentTug` → ten subsystems (`ArgentStructure` … `ArgentSensors`) → `Unit` usages (110 units, `argentDesign.units`); every usage typed by a `part def` | `instantiate-system` run; `wpb-tug-dry-mass` | ✓ depth 4 from `TethysSystem::tethysSystem` |
| SE-075 must | — | — | — allocations are WP-J's |
| SE-076 must | 31 : every leaf function performed by exactly one subsystem (`perform functions.handleData` on `cdh`, …) | `make validate` | ✓ 13 of 13 |
| SE-077 should | — | — | ○ no software components in WP-B |
| SE-078 must | 31 : `metadata def Critical`, `metadata def SinglePointWaiver`; `#Critical` units carry `[2]`/`[3]`/`[4]` or `@SinglePointWaiver { rationale }` (`primaryStructure`, `highGainAntenna`, `bag`); `required` vs installed on every `Unit` | `make validate`; `wpb-reliability` (k-of-n over `required`) | ✓ |
| SE-079 should | 32 : `smallTarget`, `nominalTarget`, `largeTarget : TargetCase`, `targetCases`; the `variation attribute def TargetCases` is in `model/probes/F-B02-variant-binding-chain.sysml` | `wpb-xenon-large`, `wpb-hydrazine-large` | ◐ cases evaluate as plain usages; chaining through a `variant` fails (F-B02) |
| SE-080 should | — | — | ○ |
| SE-081 could | — | — | ○ |
| SE-082 must | 31 : `flow of TethysInterfaces::ElectricalPower`, `flow of Telemetry`, `flow of Propellant`, `flow of Heat`, `flow of ThrustCommand`, `flow of AttitudeEstimate`, `flow of RelativeState` between subsystem ports | `make validate` | ✓ every flow typed |
| SE-083 should | 31 : `item def CharacterisationData`; `Unit::dataRate : TransferRateValue` on cameras, lidar, sensors; 32 : `UnitsDataRate` | `wpb-data-daily` | ◐ sizes and producers modelled; no per-product store |
| SE-084 should | — | — | ○ flight software is WP-E's |
| SE-085 must | backbone `model/09-ground.sysml` | — | — WP-D |
| SE-086 must | backbone `model/08-launch.sysml`; 32 : `MassBudget.launcherCapability = arcturus5H.performanceAtC3` | `wpb-mass-budget` | — WP-C; used here |
| SE-087 should | — | — | ○ tool tier (`DocumentQueries`) |
| SE-088 could | 30 : `enum def Maturity { heritage; modified; newDesign }`; 31 : `Unit::maturity` on every unit | `wpb-tug-dry-mass-allocated` (contingency by maturity) | ◐ maturity read right, the `==` on it is F-B01 |
| SE-089 could | — | — | ○ |
| SE-090 could | — | — | ○ |
| SE-121 must | 32 : `MassBudget` (`dryEstimate`, `dryWithContingency`, `dryAllocation`, `launchMass`, `launcherCapability`, `dryCloses`, `launchCloses`), `requirement <'TS-121'>` | `wpb-tug-dry-mass` = 3725.5 kg; `wpb-tug-dry-mass-allocated` = 4300.9 kg; `wpb-mass-budget` = 12624 kg; `wpb-budgets-satisfy` | ✓ dry margin 30 %, launch margin 36 % |
| SE-122 should | — | — | ○ |
| SE-123 must | 31 : `Unit::operatingPower/standbyPower/operatingModes/standbyModes/poweredShare`, `PowerInMode`, `UnitsPowerInMode`; 32 : `TugPowerInMode`, `PowerBudget.demand<Mode>` for the eight flight modes, `<'TS-123'>` | `wpb-unit-power-safe` = 42 W, `wpb-unit-power-thrusting` = 24.75 kW (right); `wpb-power-budget-safe` = 0 W (wrong) | ◐ F-B01: per-set values are right, the rollup inside `powerBudget` evaluates to 0 W, so `powerBudgetCloses` "holds" vacuously |
| SE-124 must | 32 : `calc def ArrayPower`, `PowerBudget.arrayAtAphelionEol` from `TethysEnvironment::SolarFlux(amaranth.orbit.aphelionAu)` and `arrayWings.endOfLifeFactor` | `wpb-budgets-satisfy` (`thrustingCloses`) | ◐ capability 39.76 kW right; demand side F-B01 |
| SE-125 must | 32 : `EnergyBudget` (DRO eclipse 4 h, launch to arrays 1.5 h, `maximumDepthOfDischarge`), `<'TS-125'>` | `wpb-budgets-satisfy` | ◐ usable 8640 W·h right; demand side F-B01; static budget, no state-machine SOC run |
| SE-126 must | 32 : `InspectorEnergyBudget`, `<'TS-126'>` | `wpb-budgets-satisfy` | ✓ 55 W·h of 108 W·h usable |
| SE-127 must | 32 : `DataBudget` (`generatingRate`, `dailyGenerated`, `dailyDownlink`, `storageDemand`), `<'TS-127'>` | `wpb-data-daily` = 70.6 Gbit; `wpb-budgets-satisfy` | ✓ against 90 Gbit/day and 4 TB |
| SE-128 must | — | — | — link budget is WP-D's |
| SE-129 must | — | — | — relay link is WP-D's |
| SE-130 must | 32 : `deltaVOutbound/Rendezvous/Return/Insertion`, `missedThrustMargin`, `XenonForMission` (four arcs on the running mass with the case's body attached), `PropellantBudget.thrustAtAphelion` via `TethysEnvironment::SepThrust`, `<'TS-130'>` | `wpb-xenon-large`; `wpb-sep-thrust-aphelion` = 1.73 N; `wpb-thrusting-time-large` | ✓ SEP string closed power → thrust → mass flow → thrusting time |
| SE-131 must | 32 : `PropellantBudget` (xenon per case, residuals, `tankCapacity`, `throughputLife`), `HydrazineBudget` (`DespinPropellant` per case, proximity Δv, stack control), `<'TS-130'>`, `<'TS-131'>` | `wpb-xenon-large`, `wpb-hydrazine-large` = 290 kg of 388 kg usable; `wpb-budgets-satisfy` | ✓ |
| SE-132 must | 32 : `RootSumSquareDegrees`, `PointingBudget.antennaPointingErrorDegrees` vs `antennaAllocation`, `<'TS-132'>` | `wpb-pointing-antenna` = 0.0232° (allocation 0.05°) | ✓ |
| SE-133 should | 32 : `PointingBudget.thrustVectorErrorDegrees` (centre-of-mass knowledge, thruster alignment, gimbal) | `wpb-budgets-satisfy` | ✓ 0.229° of 0.5° |
| SE-134 must | 31 : `min/maxOperatingTemperature`, `predictedHot/ColdTemperature` on every unit; 32 : `RadiatorRejection`, `ThermalBudget` (hot case, cold-case heaters, `forAll` limits), `<'TS-134'>` | `wpb-radiator-capacity` = 7480 W; `wpb-budgets-satisfy` | ◐ limits and capacity right; `hotCaseHeat` demand side F-B01 |
| SE-135 must | 32 : `CaptureLoadBudget` (contact force of the heavy case, cinch preload, thrust load vs `bag.cinchLoadCapacity`), `<'TS-135'>` — the small-body reading of the entry-loads rows | `wpb-budgets-satisfy` | ✓ 14.4 kN of 20 kN |
| SE-136 must | as SE-135 | | ✓ |
| SE-137 should | 31 : `Unit::doseRating : AbsorbedDoseValue`; 32 : `RadiationBudget` (150 Gy × RDM 2, `forAll`), `<'TS-137'>` | `wpb-budgets-satisfy` | ✓ |
| SE-138 could | — | — | ○ |
| SE-139 should | 31 : `Unit::magneticMoment : MagneticMomentValue`; 32 : `MagneticCleanlinessBudget`, `<'TS-139'>` | `wpb-budgets-satisfy` | ✓ 19.3 A·m² of 30 |
| SE-140 must | 31 : `Unit::failureRate : FrequencyValue`, `required`; 32 : `Survival`, `SetReliability` (k-of-n), `UnitSetReliability`, `ReliabilityBudget` per subsystem and mission, `<'TS-140'>` | `wpb-reliability` = 0.867 (allocation 0.85; subsystems ≥ 0.95) | ✓ |
| SE-141 should | — | — | ○ |
| SE-142 should | 31 : `FlightComputer.processorCapacityMips/LoadMips/memoryCapacity/memoryAllocated`; 32 : `ProcessorBudget`, `<'TS-142'>` | `wpb-budgets-satisfy` | ✓ 50 % reserve |
| SE-143 should | — | — | — WP-D |
| SE-144 could | — | — | ○ |
| SE-145 must | 30 : `attribute def MarginPolicyRow`, `srrPolicy`/`pdrPolicy`/`cdrPolicy`/`acceptancePolicy`, `activePolicy`, `ContingencyFor`, `WithContingency`, `MarginFraction`, `constraint def ClosesWithMargin`/`WithinLimit`/`ReserveNotNegative`; every `assert constraint … : ClosesWithMargin { … in policy = activePolicy; }` in 32 | `wpb-margin-policy-alone` = 0.1 (right, file alone); `wpb-margin-policy` = 0.2 (wrong, whole model), 120.0, 0.2, holds | ◐ policy complete and referenced by every budget; enum equality in the whole model is F-B01 |
| SE-146 should | — | — | ○ tool tier (`DocumentQueries`); candidate `model/33-budget-report-tooling.sysml` |

## LANG rows

| Row | File : element | Proving command | Result |
| --- | --- | --- | --- |
| LANG-506–510 attributes | 31 : `attribute def` — ; `Unit` attributes `mass : MassValue`, `operatingPower : PowerValue`, …; 30 : `attribute def MarginPolicyRow`, 32 : `attribute def TargetCase` | `make validate`, `make pilot` | ✓ |
| LANG-511–518 enumerations | 31 : `enum def TugMode` (sixteen literals, the one mode vocabulary); 30 : `enum def Maturity`, `enum def ReviewGate`; enum-valued attributes and sequences (`allFlightModes : TugMode[*]`) | `make validate`, `make pilot`; `wpb-margin-policy` | ✓ (membership evaluation: F-B01) |
| LANG-547–551 parts | 31 : 60 `part def`s (`Unit`, `PassiveUnit`, `ElectronicUnit`, `Assembly`, ten subsystems, every unit type), `part argentDesign : ArgentTug` with redefinitions `part :>> sep : ArgentPropulsion`, sequences `part :>> units = (…)` | `instantiate-system` run | ✓ |
| LANG-742–751 calculations | 31 : `PowerInMode`, `HeatInMode`, `UnitsPowerInMode`, `UnitsHeatInMode`; 30 : `ContingencyFor`, `WithContingency`, `MarginFraction`; 32 : `ArrayPower`, `ExpNeg`, `PropellantFor`, `MassFlowRate`, `RootSumSquareDegrees`, `Survival`, `SetReliability` (body items + `return`), `XenonForMission`, `DespinPropellant`, `RadiatorRejection`, `TugPowerInMode`, `TugHeatInMode`, `UnitsDataRate` | `wpb-*` runs | ✓ |
| quantities and units | every physical quantity ISQ-typed with an SI literal: `[kg]`, `[W]`, `[K]`, `[Gy]`, `['W⋅h']`, `['bit/s']`, `['A⋅m²']`, `['°']`, `[N]`, `[Pa]`, `[Hz]`, `['m²']`, `[d]`, `[h]`; `[GHz]`/`[MPa]`/`[GB]` are not SI library literals, so `32.0e9 [Hz]`, `12.0e6 [Pa]`, `4.0e12 [B]` | `make validate`, `make pilot` | ✓ |
