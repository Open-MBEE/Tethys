# Small-body retrieval — domain content list for the Tethys model

Replacement for §2 of `docs/se-completeness-checklist.md` (the Venus-orbiter-class list written for the earlier concept). Same shape — environment constants, phases and events, subsystems, interfaces, failure modes, trades — plus a target-uncertainty table (§7) and the checklist rows whose meaning changes for this class (§8). Generic to the class *solar-electric tug + free-flying inspector + small near-Earth asteroid captured whole and returned to cislunar space*; the Tethys values are quoted only where the backbone already fixes them.

## How to read this

* **Class** of every number: **P** public constant or public physics (source named); **D** derived in this review from P values and the backbone's invented values — **D✓** means it was computed by a Tethys `calc def` with `sysml -calc` on the fresh build (command in §0.3), **D✎** means it was computed by hand/script in this review because no Tethys calc exists (the calc the model should add is named); **I** to be invented by a work package (a plausible range is given where the physics bounds it); **L** order of magnitude from the scientific literature (reference given; not re-read for this review — re-check before it becomes a requirement).
* **Construct** names the SysML v2 construct and the library type the model should use. Library abbreviations follow the checklist (§"How to read this"): **ISQ/SI**, **SF** SampledFunctions, **SSR** StateSpaceRepresentation, **TS** TradeStudies, **AT** AnalysisTooling, **MM** ModelingMetadata, **RM** RiskMetadata, **CE** CauseAndEffect, **Geo** SpatialItems/ShapeItems, **VC** VectorCalculations, **TC** TensorCalculations; OpenSysML (non-normative, `internal/workspace/libs/stdlib/OpenSysML Libraries/`) **Sim** Simulation (`MonteCarlo`), **Sto** Stochastic, **RF** RandomFunctions, **SSI** StateSpaceIntegration (`RK4`, `Euler`, `ZeroCrossing`), **AR** AnalysisRecords, **OMF** OpenSysMLMathFunctions (`exp`, `ln`, `log`, `atan2`, …), marked **[ext]** as in the checklist.
* **Pattern?** — whether a published model or an OpenSysML example already shows the pattern. Abbreviations: **rts/…** `examples/runtime-showcase/{delta-v-budget,mass-rollup,mission-sequence,reliability,spacecraft-comms}.sysml`; **relay** `examples/relay-probe-demo/mission.sysml` (snapshots `postSeparation`, `postFlyby`, l.46–49); **lander** `examples/analysis-demo/lander.sysml` (trade study); **robot** `examples/disposal-robot-demo/robot.sysml` (variation points from l.467, trade); **self** `examples/self-model/` (variations); **expr** `examples/expressions-demo.sysml` (`SampledFunctions::Sample`, l.102); **PL** `docs/guide/modeling-product-lines.md` (superset model, configurations, solving the family); **FL** `docs/guide/modeling-fleets.md`; **TR/nn** the OMG training examples (`examples/sysml-v2-training/nn. …`, e.g. TR/36 Variability, TR/33 Analysis, TR/30 Calculations, TR/28 Individuals); **A11** the Apollo 11 model as reviewed in the checklist §3 (not re-cloned here); **TB** the Tethys backbone itself (`model/NN-*.sysml`). A grep of every non-corpus `.sysml` file under OpenSysML `examples/` found **no** use of `StateSpaceRepresentation`, `StateSpaceIntegration`/`RK4`/`ZeroCrossing`, `Simulation::MonteCarlo`, `SampledFunctions::Interpolate`/`interpolateLinear`, `TorqueValue`, `MomentOfInertiaValue`, `AbsorbedDoseValue`, docking, rendezvous/proximity or asteroid content; those rows are marked **—**.
* **Rows** — the SE-### rows of the checklist the item feeds.
* Nothing below is taken from a real or planned mission. Public physics (celestial mechanics, the Sun–Earth–Moon system, the small-body population, electric-propulsion physics) and public standards are cited as such.

## 0. What was verified

### 0.1 Trees and build

* Tethys `develop` @ `a916424` (backbone: environment, timeline, interfaces, L1 requirements TR-001…TR-009, segment skeletons). Read: `README.md`, `CONVENTIONS.md`, `model/00…10, 99`, `scripts/runs.sh`, `runs/*.txt`, `docs/coverage-matrix.md`, `docs/se-completeness-checklist.md`.
* OpenSysML `develop` @ `0a5fa2d94`; `make build` → `bin/sysml v0.10.1-2054-g0a5fa2d94`; `./bin/sysml -help` (1 030 lines) lists `-calc`, `-analysis`, `-sweep`/`-samples`, `-runs`/`-seed`/`-observe`/`-draws`, `-instantiate`/`-validate=<object>`, `-action`/`-state`/`-advance`, `-engine check|smt`, `-import`/`-import-map`, which every "verdict"/"Monte Carlo"/"sweep" mention below relies on.
* On that build: `sysml -validate -strict -warnings-as-errors model/*.sysml` → `no errors`; `-self-check-package TethysHouseRules` → `1143 elements, 10046 checks, 0 violations, 0 unevaluated`.
* Public constants re-read for this review from the NASA NSSDCA *Earth Fact Sheet* (nssdc.gsfc.nasa.gov/planetary/factsheet/earthfact.html, "Last Updated: 15 November 2024"): mass 5.9722 × 10²⁴ kg, GM 0.39860 × 10⁶ km³/s², equatorial radius 6378.137 km, escape velocity 11.186 km/s, solar irradiance 1361.0 W/m², semi-major axis 149.598 × 10⁶ km, sidereal period 365.256 d, mean orbital velocity 29.78 km/s, eccentricity 0.0167, Bond albedo 0.294, black-body temperature 254.0 K. These match `TethysEnvironment::earth`/`solar`. The Moon and Sun sheets were reachable but their tables did not parse in this review; the backbone's Moon/Sun values (GM 4902.800066 km³/s², R 1737.4 km, a 384 400 km; GM☉ 1.32712440018 × 10¹¹ km³/s², R☉ 695 700 km) are the standard published ones (IAU/JPL) and are kept as **P**.

### 0.2 Observations on the backbone (observed) and what they imply (inferred)

| # | Observed | Inferred / action for the owning work package |
|---|---|---|
| O1 | The fresh build prints `-calc` results as `= [1229.7777906287497]`; the pinned `runs/environment-calcs.txt` has `= 1229.7777906287497` (`diff` of the exact `runs.sh` command, 10 hunks, values identical). | `make runs-check` fails against a build of current OpenSysML develop; the runs were recorded with an older nightly. Re-record `runs/` when the tool pin moves (backbone). |
| O2 | `scripts/runs.sh` pins `RocketEquationDeltaV(2900.0, 15800.0, 9800.0)` = 13 583 m/s, i.e. final mass = the xenon mass. Spending all 9 800 kg of xenon from 15 800 kg leaves 6 000 kg: `RocketEquationDeltaV(2900.0, 15800.0, 6000.0)` = **27 536 m/s** (D✓). | The pinned run computes the Δv of burning 6 000 kg, not the tug's capability; the argument order/meaning should be fixed when WP-B writes the Δv budget (SE-130). |
| O3 | `SepThrust(40000, 2900, 0.65)` = 1.828 N (D✓) → ṁ = T/(Isp g₀) = 6.43 × 10⁻⁵ kg/s (D✎). Processing 9 800 kg takes **1 764 d** of continuous full-power thrust at 1 AU; the mission is 1 300 d (`TethysMission::tethys.nominalDuration`, TR-002). | Either the xenon load is mostly reserve (target-mass uncertainty, §7), or power/thrust must rise. Thrust *time*, not propellant, bounds the return Δv: 4 000 kg of xenon (≈ 720 d of thrusting) gives `≈ 304 m/s` on the 376 t stack (D✎, same formula as `RocketEquationDeltaV`). This is the first number WP-B/WP-F must close. |
| O4 | `amaranth.absoluteMagnitude = 28.1`, `geometricAlbedo = 0.20`, `meanDiameter = 6.8 m`. D = 1329 km/√p × 10^(−H/5) gives **7.13 m** for H = 28.1, p = 0.20, and 6.81 m for H = 28.2 (D✎, probe calc `DiameterFromH` evaluated on the fresh build, §0.3). | Make the three consistent (H = 28.2, or D = 7.1 m) and derive D from H and p with a calc rather than typing both. |
| O5 | `amaranth.orbit.synodicPeriodWithEarth = 5004.0 [d]`. From the model's own period (`OrbitalPeriod(1.32712440018e11, 157376960.0)` = 3.4051 × 10⁷ s = 394.11 d, D✓) and Earth's 365.256 d: 1/(1/365.256 − 1/394.11) = **4 988 d** (D✎). | Replace the typed value with a `SynodicPeriod` calc. |
| O6 | `destinationDro.period = 13.9 [d]`; the two-body `OrbitalPeriod(4902.800066, 70000.0)` = 1.662 × 10⁶ s = **19.2 d** (D✓). The Moon's Hill radius a(m☾/3M⊕)^⅓ = **61 525 km** (D✎) is smaller than the 70 000 km DRO radius. | A DRO of this size exists only in the three-body problem; its period, stability and Earth-range envelope cannot come from a two-body calc. A circular-restricted three-body propagation (SSR + SSI, §1.5) is needed; the 13.9 d value must then be shown, not typed. |
| O7 | `earthRange.minimum = 2.0e6 [km]`. | The envelope excludes launch/early operations (range from 0) and the whole cislunar end of the mission (DRO at 0.31–0.46 × 10⁶ km, §1.5). Split the envelope per phase (§1.5 row "Earth range by phase"). |
| O8 | `heliocentricRange` 144.3–170.4 × 10⁶ km: `SolarFlux(0.9647)` = 1462.4, `SolarFlux(1.1393)` = 1048.5 W/m² (D✓) — consistent with the doc comment. | — |
| O9 | `NaturalLog` (series, k ≤ 5): `NaturalLog(3.0)` = 1.0985883 vs ln 3 = 1.0986123 (error 2.4 × 10⁻⁵, inside the doc's "below 3 × 10⁻⁵"); `NaturalLog(2.6333)` = 0.968232. The OpenSysML library `OpenSysMLMathFunctions::ln(2.0)` evaluates to 0.6931471805599453 on the fresh build. | Keep the standard-only series (CONVENTIONS: standard SysML only); `OMF::ln` [ext] is available if the pilot is given the library file, and is the better reference value for a `-calc` cross-check. |
| O10 | **Candidate finding (standard library text).** `SampledFunctions::interpolateLinear` over samples (0.9647, 1462.4), (1.052, 1229.8), (1.1393, 1048.5) returned **1135.75** at 1.0 and 869.31 at 1.1 (linear interpolation: 1368.3 and 1130.1). Reading the vendored file (`Domain Libraries/Analysis/SampledFunctions.sysml`, `calc interpolateLinear`, private `Linear`): `f = (value − lower.domainValue)/(lower.domainValue − upper.domainValue)`, `result = upper.rangeValue + f·(lower.rangeValue − upper.rangeValue)` — the tool's 1135.75 is exactly what that text computes, so the defect is in the library expression (sign of the denominator / wrong anchor), not the evaluator. | Not checked against the pilot's copy in this review (the checklist states the OMG files are vendored unmodified). Every tabulated environment in this list (array degradation, dose–depth, thermal-inertia tables) wants `interpolateLinear`; until the library text is corrected the model needs its own linear-interpolation calc. Record in `docs/findings.md` once confirmed against the pilot copy. |
| O11 | A `variation part def TargetCase` with an owned `attribute m` is rejected: `error[variation-member-not-variant]: An owned usage of a variation must be a variant.` Putting `m` on a base `part def BodyCase` and `variation part def TargetCase :> BodyCase` with `variant part small/nominal/large { attribute :>> m = … }` validates `-strict`, and `-instantiate … -validate=` evaluated an `assert constraint { body.m <= maxMass }` on the `large` choice (`holds`). | That is the shape §7 recommends for target cases (variation with a common base def; the configuration binds a variant). Matches the spec rule; PL documents the same. |
| O12 | The backbone's `CaptureInterface` carries only `MechanicalPort` ends; `TugInspectorInterface` carries only the `UmbilicalPort` (its doc names mechanical and thermal too); the high-voltage SEP feed reuses `PowerOutlet` (no voltage class); no internal xenon-feed or proximity-sensor interface def exists. | §4 lists what each ICD class must add. |

### 0.3 Commands run (fresh build, Tethys `model/*.sysml`)

```text
sysml -calc "TethysEnvironment::SolarFlux(1.1393)"    → 1048.53      (aphelion of target)
sysml -calc "TethysEnvironment::SolarFlux(0.9833)"    → 1407.62      (Earth perihelion)
sysml -calc "TethysEnvironment::SolarFlux(1.0167)"    → 1316.66      (Earth aphelion)
sysml -calc "TethysEnvironment::CircularSpeed(1.32712440018e11, 149597870.7)" → 29.7847 km/s
sysml -calc "TethysEnvironment::CircularSpeed(1.32712440018e11, 157376960.0)" → 29.0392 km/s (1.052 AU)
sysml -calc "TethysEnvironment::OrbitalPeriod(1.32712440018e11, 149597870.7)" → 3.15582e7 s (365.25 d)
sysml -calc "TethysEnvironment::OrbitalPeriod(1.32712440018e11, 157376960.0)" → 3.40515e7 s (394.11 d)
sysml -calc "TethysEnvironment::OrbitalPeriod(4902.800066, 70000.0)"          → 1.66190e6 s (19.2 d, two-body)
sysml -calc "TethysEnvironment::OrbitalPeriod(398600.4418, 384400.0)"         → 2.37184e6 s (27.45 d)
sysml -calc "TethysEnvironment::CircularSpeed(398600.4418, 384400.0)"         → 1.0183 km/s (Moon about Earth)
sysml -calc "TethysEnvironment::EscapeSpeed(398600.4418, 6578.137)"           → 11.0086 km/s (200 km LEO)
sysml -calc "TethysEnvironment::EscapeSpeed(4902.800066, 1837.4)"             → 2.3101 km/s (100 km above Moon)
sysml -calc "TethysEnvironment::EscapeSpeed(4902.800066, 70000.0)"            → 0.3743 km/s
sysml -calc "TethysEnvironment::CircularSpeed(4902.800066, 70000.0)"          → 0.2647 km/s
sysml -calc "TethysEnvironment::OneWayLightTime(2.0e6)"   → 6.67 s
sysml -calc "TethysEnvironment::OneWayLightTime(60.0e6)"  → 200.14 s
sysml -calc "TethysEnvironment::OneWayLightTime(314400.0)"→ 1.049 s
sysml -calc "TethysEnvironment::OneWayLightTime(475500.0)"→ 1.586 s
sysml -calc "TethysEnvironment::OneWayLightTime(1.5e6)"   → 5.00 s
sysml -calc "TethysEnvironment::SphereMass(6.8, 2200.0)"  → 362 200 kg
sysml -calc "TethysEnvironment::SphereMass(6.8, 1300.0)"  → 214 027 kg
sysml -calc "TethysEnvironment::SphereMass(6.8, 3500.0)"  → 576 227 kg
sysml -calc "TethysEnvironment::SphereMass(5.0, 1300.0)"  →  85 085 kg
sysml -calc "TethysEnvironment::SphereMass(5.0, 2200.0)"  → 143 990 kg
sysml -calc "TethysEnvironment::SphereMass(8.0, 2700.0)"  → 723 823 kg
sysml -calc "TethysEnvironment::SphereMass(10.0, 2200.0)" → 1 151 917 kg
sysml -calc "TethysEnvironment::SphereMass(10.0, 2700.0)" → 1 413 717 kg
sysml -calc "TethysEnvironment::SphereMass(10.0, 3500.0)" → 1 832 596 kg
sysml -calc "TethysEnvironment::EscapeSpeed(2.4174e-14, 0.0034)"   → 3.771e-6 km/s (3.77 mm/s at Amaranth's surface)
sysml -calc "TethysEnvironment::CircularSpeed(2.4174e-14, 0.0034)" → 2.666e-6 km/s
sysml -calc "TethysEnvironment::SepThrust(40000.0, 2900.0, 0.65)"  → 1.8285 N
sysml -calc "TethysEnvironment::SepThrust(48000.0, 2900.0, 0.65)"  → 2.1941 N
sysml -calc "TethysEnvironment::SepThrust(40000.0, 2000.0, 0.60)"  → 2.4473 N
sysml -calc "TethysEnvironment::SepThrust(40000.0, 3500.0, 0.68)"  → 1.5849 N
sysml -calc "TethysEnvironment::RocketEquationDeltaV(2900.0, 15800.0, 6000.0)"     → 27 536 m/s
sysml -calc "TethysEnvironment::RocketEquationDeltaV(2900.0, 15800.0, 14318.0)"    →  2 801 m/s
sysml -calc "TethysEnvironment::RocketEquationDeltaV(2900.0, 376318.0, 368000.0)"  →    636 m/s
sysml -calc "TethysEnvironment::RocketEquationDeltaV(2900.0, 231318.0, 223000.0)"  →  1 041 m/s
sysml -calc "TethysEnvironment::RocketEquationDeltaV(2900.0, 521318.0, 513000.0)"  →    457 m/s
sysml -calc "TethysEnvironment::RocketEquationDeltaV(2900.0, 1014318.0, 1006000.0)"→    234 m/s
sysml -calc "TethysEnvironment::NaturalLog(3.0)" → 1.0985883
```

Probe calcs (scratch file outside both repos, validated `-strict` with `01-environment.sysml`): `DiameterFromH(h, albedo) = 1329000.0 / sqrt(albedo) * 10.0 ** (-h / 5.0)` → 7.1287 m (28.1, 0.20), 6.8079 m (28.2, 0.20), 13.015 m (28.1, 0.06), 4.7525 m (28.1, 0.45) — real exponents evaluate; `OpenSysMLMathFunctions::ln(2.0)` → 0.69314718; `interpolateLinear` see O10; the variation probe see O11.

---

## 1. Environment and public constants (for `TethysEnvironment`)

Every row: value, class, the SysML construct and library type, whether a pattern exists, rows fed. "Calc to add" names a `calc def` the model should own so the value is derived, not typed. GM stays a documented `Real` in km³/s² as the backbone does (no ISQ quantity kind for a gravitational parameter — boundary already recorded in the backbone's `BodyConstants` doc).

### 1.1 Sun, Earth, Moon

| Item | Value (source) | Class | Construct / library type | Pattern? | Rows |
|---|---|---|---|---|---|
| Sun GM, radius, mass | 1.32712440018 × 10¹¹ km³/s²; 695 700 km; 1.9885 × 10³⁰ kg | P (IAU/JPL; in TB) | `attribute sun : BodyConstants` (TB) — `Real`, `LengthValue`, `MassValue` (ISQ) | TB | SE-195, SE-301 |
| Astronomical unit | 149 597 870.7 km (IAU 2012 B2, exact) | P | `LengthValue` in km; **not** `SI::ua` (checklist §3 #13: the vendored `ua` factor evaluates to 1.496 × 10²² m — not re-checked here) | TB | SE-303 |
| Solar irradiance at 1 AU | 1361.0 W/m² (NSSDCA Earth sheet, read) | P | `ISQLight::IrradianceValue` `['W/m²']` (TB `solar`) | TB | SE-124, SE-134, SE-303 |
| Earth GM, equatorial radius, mass | 398 600.4418 km³/s²; 6378.137 km; 5.9722 × 10²⁴ kg (NSSDCA, read) | P | TB `earth : BodyConstants` | TB | SE-195 |
| Earth heliocentric orbit | a = 1.00000011 AU, e = 0.0167, P = 365.256 d, v̄ = 29.78 km/s (NSSDCA, read) | P | add `attribute earthOrbit : HeliocentricOrbit` (TB has the def, no Earth usage) | TB (def only) | SE-195, SE-265 |
| Earth circular heliocentric speed | 29.785 km/s at 1 AU (`CircularSpeed`) | D✓ | calc result; `SpeedValue` once converted | — | SE-130 |
| Flux at Earth perihelion / aphelion | 1407.6 / 1316.7 W/m² (`SolarFlux(0.9833)`, `SolarFlux(1.0167)`) | D✓ | `SolarFlux` | TB | SE-124 (launch-phase arrays) |
| Earth escape from 200 km | v_esc = 11.009 km/s (`EscapeSpeed`); injection speed for C3 = 2 km²/s²: √(v_esc² + C3) = 11.099 km/s; v∞ = √C3 = 1.414 km/s | D✓ / D✎ (calc to add: `InjectionSpeed(gm, r, c3)`) | calc; C3 as `Real` km²/s² (no ISQ kind; or `ISQ::SpecificEnergyValue`-style derived — check before use) | rts/delta-v-budget (Δv with units) | SE-130, SE-195, SE-265 |
| Earth sphere of influence (Laplace) / Hill radius | 0.925 × 10⁶ km / 1.497 × 10⁶ km (a(m/M)^⅖, a(m/3M)^⅓) | D✎ (calc to add: `SphereOfInfluence`, `HillRadius`) | `LengthValue` | — | SE-195 (escape, return capture boundary) |
| Moon GM, radius, mass | 4902.800066 km³/s²; 1737.4 km; 7.346 × 10²² kg | P (in TB) | TB `moon` | TB | SE-195 |
| Lunar orbit | a = 384 400 km; mean perigee/apogee ≈ 363 300 / 405 500 km (NSSDCA Moon sheet, footnote "mean apogee and perigee"); sidereal 27.3217 d; synodic 29.5306 d; inclination to ecliptic 5.145° | P | TB `lunarOrbit` (add perigee/apogee, inclination: `AngularMeasureValue`) | TB | SE-195, SE-308 |
| Moon orbital speed about Earth | 1.018 km/s (`CircularSpeed(398600.4418, 384400)`); two-body period 27.45 d (`OrbitalPeriod`) vs sidereal 27.32 d (Earth–Moon is not a test-particle problem: use GM⊕ + GM☾ for the period) | D✓ | — | — | SE-195 |
| Moon Hill radius (Earth–Moon) | 61 525 km | D✎ (`HillRadius`) | `LengthValue` | — | SE-195 (O6: DRO lies outside it) |
| Escape from 100 km above the Moon | 2.310 km/s (`EscapeSpeed(4902.8, 1837.4)`) | D✓ | — | — | SE-130 (lunar gravity-assist periapsis) |
| Earth–Moon rotating frame, mass ratio μ | μ = GM☾/(GM⊕+GM☾) = 0.012151 | D✎ | `Geo` coordinate frame (`SpatialItems::CoordinateFrame`) for the synodic frame; μ as `Real` | — | SE-080, SE-195 |
| Speed of light, g₀ | 299 792.458 km/s; 9.80665 m/s² | P (exact, SI) | TB `speedOfLightKmPerS`, `standardGravityMPerS2` | TB | SE-141, SE-130 |
| Newtonian G | 6.674 30 × 10⁻¹¹ m³ kg⁻¹ s⁻² (CODATA 2018) | P | add `attribute gravitationalConstant : Real` (no ISQ kind) | — | SE-301 (small-body GM = G·M) |

### 1.2 The generic small near-Earth-asteroid population (prior for the target)

Population values are **L** (literature, order of magnitude) and are what the target-uncertainty table (§7) draws its ranges from. Spectral classes per the Bus–DeMeo taxonomy (DeMeo et al. 2009, *Icarus* 202:160).

| Item | Value / range | Class (source) | Construct / library type | Pattern? | Rows |
|---|---|---|---|---|---|
| Absolute magnitude ↔ diameter | D = 1329 km / √p_V × 10^(−H/5) | P (Fowler & Chillemi 1992; Harris & Harris 1997) | calc to add `DiameterFromH(h, albedo)` — **probe ran** on fresh build (§0.3; real exponent works); `LengthValue` once converted | — | SE-301, §7 |
| Geometric albedo by class | S ≈ 0.15–0.35 (mean ≈ 0.25); C ≈ 0.03–0.10; X spans E (≈ 0.4–0.6), M (≈ 0.1–0.3), P (< 0.1); Q/V similar to or above S | L (Mainzer et al. 2011, *ApJ* 741:90; Thomas et al. 2011, *AJ* 142:85) | `Real` (dimensionless) per class: `enum def SpectralClass` + attribute per class, or a `SampledFunction` keyed by class index | — | §7, SE-201 |
| Diameter range for H ≈ 28 | 13.0 m (p = 0.06) … 4.75 m (p = 0.45) for H = 28.1 (probe calc) | D✎ | §7 driver | — | SE-201 |
| Bulk density by class | C ≈ 1.2–1.8 g/cm³; S ≈ 2.0–3.0 (mean ≈ 2.7) for large bodies; X wide (1.5–5); a monolithic small S-type can approach its meteorite bulk density (ordinary chondrites ≈ 3.2–3.4); macroporosity 0–≈50 % | L (Carry 2012, *PSS* 73:98; Consolmagno et al. 2008, *Chemie der Erde* 68:1) | `MassDensityValue` `['kg⋅m⁻³']` (SI dot form — Hesperia gotcha) | TB (`bulkDensity`) | §7 |
| Mass for 5–10 m, 1 300–3 500 kg/m³ | 85 t (5 m, 1 300) … 1 833 t (10 m, 3 500); 6.8 m: 214 t (1 300), 362 t (2 200), 576 t (3 500) | D✓ (`SphereMass`, §0.3) | `MassValue`; non-spherical bodies: volume from shape model × density | rts/mass-rollup (rollup pattern only) | SE-121, SE-130, §7 |
| Rotation-period distribution | For D ≳ 150–300 m a "spin barrier" near 2.2 h (rubble piles); below ≈ 150 m most measured bodies rotate faster, many in minutes, some in seconds ("fast rotators", interpreted as monoliths or cohesive) | L (Pravec & Harris 2000, *Icarus* 148:12; Warner, Harris & Pravec 2009, *Icarus* 202:134, the LCDB) | `DurationValue`; distribution for Monte Carlo as `RF::uniform`/`triangular` [ext] or a `SampledFunction` CDF | — | §7, SE-194 |
| Non-principal-axis (tumbling) rotation | Observed among small bodies; damping time depends on size, spin and rigidity | L (Pravec et al. 2005, *Icarus* 173:108) | spin state as `VC` vector (`AngularVelocityValue` components) + `enum def SpinState { principalAxis; tumbling; }` | — | §7, SE-155 |
| Amaranth spin rate and equatorial speed | ω = 2π/252 s = 0.02493 rad/s; v_eq = ωR = 84.8 mm/s | D✎ (calc to add `SurfaceSpeed`) | `ISQSpaceTime::AngularVelocityValue`, `SpeedValue` | — | SE-136-replacement (capture contact), §7 |
| Centrifugal vs gravitational acceleration at the equator | ω²R = 2.11 × 10⁻³ m/s² vs GM/R² = 2.09 × 10⁻⁶ m/s² — ratio ≈ 1 000 | D✎ (calc to add `SurfaceGravity`) | `AccelerationValue` | — | §7 strength row: loose regolith cannot rest on the equator; the body must be monolithic or cohesive |
| Surface gravity, escape and circular speed at 5–10 m bodies | Amaranth (6.8 m, 362 t, GM = 2.417 × 10⁻¹⁴ km³/s²): g = 2.09 × 10⁻⁶ m/s², v_esc = **3.77 mm/s**, v_circ = 2.67 mm/s (`EscapeSpeed`/`CircularSpeed` with km units). Scaling: g ∝ ρD, v_esc ∝ D√ρ | D✓ | `AccelerationValue`, `SpeedValue` | — | SE-301, failure modes (ejecta) |
| Hill radius of the target about the Sun | r_H = q(m/3M☉)^⅓ ≈ 0.57 km at perihelion | D✎ (`HillRadius`) | `LengthValue` | — | §2 inspector circumnavigation |
| Solar radiation pressure vs target gravity (inspector) | SRP at 1 AU 4.54 × 10⁻⁶ N/m²; on a 24 kg inspector with ≈ 0.1 m²: ≈ 1.9 × 10⁻⁸ m/s²; Amaranth's gravity at 100 m: 2.4 × 10⁻⁹ m/s² (SRP 8× larger); at 20 m: 6.0 × 10⁻⁸ m/s² | D✎ (inspector area **I**) | calc to add `SrpAcceleration`; `AccelerationValue` | — | Wren cannot orbit: circumnavigation is forced motion (cold-gas budget, SE-130/131 for Wren) |
| Rotational state of Amaranth (sphere approximation) | I = ⅖MR² = 1.675 × 10⁶ kg·m²; L = Iω = 4.18 × 10⁴ N·m·s; E_rot = ½Iω² = 521 J | D✎ (calc to add `SphereInertia`, `AngularMomentum`) | `ISQMechanics::MomentOfInertiaValue` (scalar), `AngularMomentumValue`, `EnergyValue`; full tensor via `TC` | — | despin budget, capture loads |
| Thermal inertia | Small fast rotators trend higher than km bodies; ≈ 50 (fine regolith) … 200–1 000 (coarse/rocky) … ≈ 2 000–2 500 J m⁻² K⁻¹ s⁻½ (bare rock) | L (Delbo et al. 2007, *Icarus* 190:236; Delbo et al. 2015, *Asteroids IV*) | no ISQ kind for thermal inertia (√(kρc)) — compose from `ThermalConductivityValue`, `MassDensityValue`, `SpecificHeatCapacityValue` or document a `Real` | — | SE-304-replacement, §7 |
| Surface temperature (fast-rotator model) | T = [(1−A)S/(πεσ)]^¼ with A = q·p_V ≈ 0.39 × 0.20 = 0.078, ε = 0.9: ≈ 303 K at 0.9647 AU, 298 K at 1 AU, 279 K at 1.1393 AU (equatorial) | D✎ (calc to add `FastRotatorTemperature`; needs the fourth root → `sqrt(sqrt(x))`) | `ThermodynamicTemperatureValue` | — | SE-134 (body as a thermal boundary for the bag) |
| Regolith vs monolith | Fast rotation with centrifugal ≫ gravity (row above) implies a coherent body or cohesion-held aggregate; cohesion of ≈ 25 Pa–kPa can hold small fast rotators | L (Sánchez & Scheeres 2014, *MAPS* 49:788) | `enum def InteriorStructure { monolith; cohesiveAggregate; fracturedMonolith; }` + `PressureValue` cohesion | — | §7 strength row |
| Yarkovsky drift | da/dt ≈ 10⁻⁴ AU/Myr at 1 km, scaling ≈ 1/D → ≈ 10⁻² AU/Myr at ≈ 10 m (order) | L (Bottke et al. 2006, *Annu. Rev. Earth Planet. Sci.* 34:157; Vokrouhlický et al. 2015, *Asteroids IV*) | `Real` AU/Myr with doc | — | SE-282 (pre-launch target ephemeris uncertainty), not a mission-time force |
| YORP spin change | Spin-doubling time ∝ D² at fixed distance; at metre–decametre size short on geological scales (≲ 10⁴ yr order) | L (same) | doc + `DurationValue` | — | §7 spin-state prior (fast/tumbling states are common) |
| SRP on the target | ≈ 1.6 × 10⁻⁴ N on a 36 m² cross-section; ≈ 4.5 × 10⁻¹⁰ m/s² — negligible against the stack thrust acceleration (4.9 × 10⁻⁶ m/s²) | D✎ | `ForceValue` | — | SE-130 |
| Amaranth heliocentric orbit | a = 1.052 AU, e = 0.083, i = 1.6°, q = 0.9647 AU, Q = 1.1393 AU (q = a(1−e), Q = a(1+e) check), P = 394.11 d (`OrbitalPeriod`), synodic 4 988 d (O5) | I (TB) + D✓ | TB `HeliocentricOrbit`; add calcs `Perihelion`, `Aphelion`, `SynodicPeriod` | TB | SE-195, SE-265 |
| Phase drift of an Earth-like orbit | 360° × (1 − 365.256/394.11) ≈ 26°/yr relative to Earth; Earth range after a year of drift ≈ 2 sin(13°) AU ≈ 0.45 AU | D✎ | calc to add `RelativePhaseDrift` | — | SE-128 (the `earthRange.maximum` of 60 × 10⁶ km must come from the trajectory, O7) |
| Planetary protection | COSPAR policy: return of an S-type small body to cislunar space is assessed against the "Earth return" categories; the category is a determination to record, not invent | P (COSPAR Policy on Planetary Protection, 2021 update) | `requirement` + `MM::StatusInfo`, assumption as `@Rationale` | — | SE-034, SE-036 |

### 1.3 Low-thrust transfer physics

| Item | Value / relation | Class | Construct / library type | Pattern? | Rows |
|---|---|---|---|---|---|
| Thrust–power–Isp | T = 2ηP/(Isp g₀): 1.83 N at 40 kW, 2 900 s, η 0.65; 2.19 N at 48 kW; 2.45 N at (40 kW, 2 000 s, 0.60); 1.58 N at (40 kW, 3 500 s, 0.68) | P physics; D✓ (`SepThrust`) | `ForceValue` result once the calc is unit-typed; inputs `PowerValue`, `DurationValue` (Isp in s), `Real` η | rts/delta-v-budget (Isp·g₀) | SE-130, SE-123 |
| Mass flow | ṁ = T/(Isp g₀) = 6.43 × 10⁻⁵ kg/s at 40 kW | D✎ (calc to add `MassFlow`) | `ISQMechanics::MassFlowRateValue` | — | SE-131, O3 |
| Thrusting time to process xenon | 9 800 kg → 1 764 d at 40 kW; 1 482 kg (outbound example) → 267 d | D✎ | `DurationValue` | — | SE-130, SE-261, O3 |
| Rocket equation | Δv = Isp g₀ ln(m₀/m₁); tug alone, all xenon: 27 536 m/s; 2 801 m/s for 1 482 kg | P; D✓ (`RocketEquationDeltaV`) | calc (TB uses `NaturalLog`; `OMF::ln` [ext] cross-check) | rts/delta-v-budget | SE-130 |
| Return Δv with the body attached | with 8 318 kg left after a 2.8 km/s outbound leg: 636 m/s at 362 t, 1 041 m/s at 217 t (−40 %), 457 m/s at 507 t (+40 %), 234 m/s at the 1 000 t capture limit (`RocketEquationDeltaV`, masses incl. 14.3 t tug) — but thrust time (O3) limits it first: ≈ 304 m/s for ≈ 720 d of thrusting at 376 t | D✓ / D✎ | analysis case over target variants (§7) | — | SE-130, SE-131, TR-001, TR-002 |
| Thrust acceleration | 1.16 × 10⁻⁴ m/s² (tug, 15.8 t); 4.86 × 10⁻⁶ m/s² (stack, 376 t) | D✎ | `AccelerationValue` | — | SE-130, SE-132 |
| Low-thrust Δv to an Earth-like orbit (circular-coplanar, Edelbaum-type estimates) | semi-major axis 1 → 1.052 AU: v⊕(1 − 1/√1.052) = 0.745 km/s; eccentricity 0 → 0.083 with tangential steering: (π/4)v⊕Δe ≈ 1.94 km/s; inclination 1.6°: (π/2)v⊕Δi ≈ 1.31 km/s; combined with optimal steering and the launch v∞ (1.41 km/s) the rendezvous total is a few km/s — to be optimised, not summed | P physics (Edelbaum 1961, *ARS J.* 31:1079); D✎ | calc to add `EdelbaumDeltaV`; real trajectory: SSR + SSI [ext] or external optimiser (`AT`/`-tool`) with a recorded run (AR) | — | SE-130, SE-195 |
| Array power vs Sun distance | first order P ∝ 1/r²: 48 kW → 51.6 kW at 0.9647 AU, 37.0 kW at 1.1393 AU (from `SolarFlux` ratios); real arrays gain a little at larger r from lower cell temperature | D✓ (ratios of `SolarFlux`) | `PowerValue`; `SF` table of P(r, T) | — | SE-124 |
| Array degradation | radiation (mostly solar-proton fluence in interplanetary space), UV, thermal cycling, micrometeoroids; temperature coefficient of multi-junction cells negative; per-year loss **I** within the range the cell vendor's data supports | I (method per ECSS-E-ST-20-08 *Photovoltaic assemblies and components*) | `SF::SampledFunction` power-fraction vs fluence or time; `interpolateLinear` (see O10) | expr (`Sample` only) | SE-124, SE-281 |
| Eclipse-free cruise | heliocentric cruise has no eclipses; eclipses only in launch/early ops, at the lunar gravity assist and in the DRO (§1.4) | P geometry | `event occurrence` eclipse entry/exit | — | SE-125, SE-264, SE-308 |
| Solar conjunction | for a co-orbital spacecraft at heliocentric longitude offset φ from Earth, the Sun–Earth–probe angle is ≈ 90° − φ/2: ≥ 78° for ranges up to 60 × 10⁶ km — **no solar conjunction** in the mission | D✎ | doc + constraint | — | SE-264 (meaning changes), SE-273 |
| HGA–array geometry | Sun–probe–Earth angle near 90° for most of the cruise | D✎ | pointing constraint (gimballed HGA) | — | SE-132 |
| Hall thruster efficiency, throughput | total efficiency ≈ 0.5–0.65 at Isp 1 500–3 000 s; xenon throughput per thruster is a qualification-life parameter (9 800 kg / 3 operating = 3 267 kg each if spread evenly) | P physics (Goebel & Katz, *Fundamentals of Electric Propulsion*, JPL Space Science and Technology Series, 2008); throughput **I** | `MassValue` throughput per thruster, `DurationValue` life; requirement TA- | — | SE-140, SE-216 |
| Xenon storage | critical point 289.7 K, 5.84 MPa (NIST); stored supercritical; at a storage density of ≈ 1.6 g/cm³, 9 800 kg needs ≈ 6.1 m³ | P (NIST WebBook) / D✎ (density **I**) | `PressureValue`, `ThermodynamicTemperatureValue`, `VolumeValue` | — | SE-131, SE-144, SE-180 |
| Missed-thrust margin | low-thrust trajectories carry a margin for unplanned coast (safe modes) | P practice (Laipert & Longuski 2015, *J. Spacecraft & Rockets* 52(4)) | analysis case with `Sim::MonteCarlo` [ext] over coast events | — | SE-130, SE-194 |

### 1.4 Cislunar destination geometry and return

| Item | Value / relation | Class | Construct / library type | Pattern? | Rows |
|---|---|---|---|---|---|
| DRO family | planar retrograde periodic orbits about the Moon in the Earth–Moon CR3BP; large members are linearly stable and remain bound for very long times | P (Hénon 1969, *A&A* 1:223; Bezrouk & Parker 2017, *Astrophys. Space Sci.* 362:176) | `SSR::ContinuousStateSpaceDynamics` with a CR3BP `GetDerivative`, integrated by `SSI::RK4` [ext] | — (SSR unused in every reviewed model) | SE-195, TR-006 |
| DRO size and period (Tethys) | ≈ 70 000 km from the Moon (TB, I); period 13.9 d (TB, I — two-body 19.2 d is not applicable, O6) | I + D✓ | TB `destinationDro`; period must become an analysis output | TB | SE-195 |
| DRO stability horizon | ≥ 100 yr without station-keeping (TR-006) — to be shown by long propagation including solar gravity | I (requirement) | analysis case + `requirement` TR-006; `-analysis` verdict | — | SE-192, TR-006 |
| Earth range in the DRO | 384 400 ± 70 000 km nominal; with lunar perigee/apogee 363 300–405 500 km: ≈ 0.29–0.48 × 10⁶ km | D✎ | `RangeEnvelope` per phase | TB (def) | SE-128, SE-141 |
| Light time in the DRO | 1.05–1.59 s (`OneWayLightTime(314400)`, `(475500)`) | D✓ | `DurationValue` | — | SE-141 |
| Light time over the mission | 0 (launch) … 6.7 s at 2 × 10⁶ km … 200 s at 60 × 10⁶ km | D✓ | — | — | SE-141, SE-162 |
| Eclipses in the DRO | Earth's umbra at lunar distance ≈ 4 600 km radius (penumbra ≈ 8 300 km); crossing at ≈ 1 km/s → up to ≈ 2–4 h with penumbra. Moon's umbra 70 000 km behind the Moon ≈ 1 400 km radius → ≲ 2 h | D✎ (calc to add `ShadowConeRadius`) | `event occurrence`; `DurationValue` | — | SE-125, SE-264, SE-308 |
| Lunar gravity assist | turn δ: sin(δ/2) = 1/(1 + r_p v∞²/GM☾); max Δv = 2v∞ sin(δ/2): 1.45 km/s at v∞ = 1 km/s, 0.91 km/s at 0.5 km/s (r_p = 1 837 km) | P physics; D✎ (calc to add `FlybyDeltaV`) | calc + `event occurrence lunarGravityAssist` (TB) | relay (`postFlyby` snapshot — a mass change, not the geometry) | SE-130, SE-195 |
| Return v∞ at Earth | small for an Earth-like orbit (fraction of a km/s to ≈ 1 km/s; C3 ≲ 1 km²/s²) — the reason a single lunar flyby plus low thrust can capture | D (order; trajectory **I**) | analysis output | — | SE-195 |
| Earth-impact exclusion | no credible return failure may leave the body on an Earth-intersecting trajectory (TR-006) — biased aim points and keep-out on the B-plane | I (requirement) | `constraint def` on the B-plane miss distance; `Sim::MonteCarlo` [ext] over failures; `RM` risk | — | SE-171, SE-176, TR-006 |
| Insertion into the DRO | small Δv from a lunar-flyby-shaped approach (to be optimised); low-thrust insertion takes days–weeks at 4.9 × 10⁻⁶ m/s² (1 m/s per ≈ 2.4 d) | D✎ | event + analysis | — | SE-130, SE-155 |
| Magnetotail crossings | The Moon (and a DRO about it) passes through Earth's magnetotail for several days around each full Moon | P (general knowledge; size with an environment tool) | `event occurrence` monthly | — | SE-305, SE-306 |
| Lunar albedo/IR at 70 000 km | the Moon subtends ≈ 2.8° from 70 000 km; albedo and IR loads small vs the Sun | D✎ | thermal case input | — | SE-134 |

### 1.5 Radiation and particles

| Item | Value / relation | Class | Construct / library type | Pattern? | Rows |
|---|---|---|---|---|---|
| Trapped belts | direct injection crosses the Earth's belts in hours; a spiral-out from low orbit would spend months in them (array damage) — the main radiation argument for direct escape | P physics; durations D from trajectory | `event occurrence` belt entry/exit; dose contribution as `AbsorbedDoseValue` | — | SE-137, trade T2 |
| After escape | no trapped radiation; dose from solar particle events (SPE) and galactic cosmic rays (GCR) | P | — | — | SE-137, SE-305 |
| SPE fluence model | e.g. ESP/PSYCHIC; confidence level a requirement parameter | P (ECSS-E-ST-10-04C *Space environment*) | `ISQAtomicNuclear::ParticleFluenceValue`; confidence `Real` | — | SE-305 |
| GCR model | ISO 15390 / Badhwar–O'Neill class | P (standard) | `LinearEnergyTransferValue` spectra as `SF` | — | SE-138 |
| Dose–depth curve | mission dose vs shield thickness (e.g. SHIELDOSE-2 output) | D from environment tool (not quoted) | `SF::SampledFunction` thickness → `AbsorbedDoseValue`; `interpolateLinear` (O10) | — | SE-137 |
| Cislunar return and DRO | interplanetary SPE/GCR plus magnetotail/plasma-sheet passages; no trapped belts at the DRO | P | doc + events | — | SE-305 |
| Micrometeoroids | interplanetary flux at ≈ 1 AU (Grün et al. 1985 model as in ECSS-E-ST-10-04C); large thin arrays and the bag are the exposed areas | P (standard) | `SF` flux vs mass; probability calcs | rts/reliability (e^(−λt) form) | SE-307 |
| Ejecta from contact | particles released by contact leave at ≥ 3.8 mm/s (above escape) — contamination of optics/arrays, not an impact hazard | D✎ | hazard (CE) | — | SE-171, SE-181 |

---

## 2. Mission phases and events

Time-to-criticality (TTC) is the time from a fault to an unrecoverable state; it is compared with the round-trip light time (RTLT, 0–400 s; ≈ 2–3 s in the DRO) plus the ground reaction time to decide the autonomy level: **G** ground-in-the-loop, **S** on-board sequenced with ground go/no-go, **A** fully autonomous (on-board detection and response). TTC values are **D✎** estimates from the physics in §1 with invented operating points (stated); the model should compute each as a `calc` and assert `ttc > rtlt + reaction` as a `constraint` on the phase.

Construct used throughout: each phase is an `occurrence … : MissionPhase` inside `TethysMission::flightTimeline` (TB); events are `event occurrence`s ordered by `first … then …` (TB); entry/exit criteria are `requirement`s whose subject is the phase occurrence; critical sequences are `action def`s with `accept`/`send` and timed `after` triggers; modes are `state def`s exhibited by the tug (`exhibit state`). Patterns: rts/mission-sequence (branching sequence), relay (events and snapshots with multiplicity), A11 (phases as `state def`).

| # | Phase (TB occurrence) | Events (TB events in **bold**; others to add) | Critical events — TTC and autonomy | Rows exercised |
|---|---|---|---|---|
| P1 | Integration & test (pre-flight; add `integrationAndTest`) | unit deliveries; SEP string hot-fire acceptance; array wing deployment test (gravity-offloaded); capture-bag deployment and inflation test (vacuum/thermal); Wren dispenser fit and release test; xenon loading (supercritical, slow fill); hydrazine loading; stack integration; launch-site processing; encapsulation | xenon/hydrazine loading are hazardous operations (ground safety) | SE-215, SE-216, SE-217, SE-267, SE-180, SE-109 |
| P2 | Launch and direct escape (`launchAndEarlyOperations`) | **liftOff**; fairing jettison; upper-stage burns to C3 ≈ 2 km²/s²; **separationFromLauncher**; tip-off rate damping; initial acquisition (LEOP station view of a fast-receding vehicle: range rate ≈ v∞ ≈ 1.4 km/s) | separation → sun acquisition before battery depletion: TTC = battery energy / load (**I**, hours) — **A** | SE-154, SE-155, SE-262, SE-265, SE-311 |
| P3 | Array deployment and early checkout | **arraysDeployed** (two roll-out wings, each a configuration change); HGA deployment; Wren health check on keep-alive | wing deployment failure → power-negative before thrust: TTC hours–days (battery + reduced load) — **S** | SE-262, SE-124, SE-125, SE-225 |
| P4 | SEP commissioning (add `sepCommissioning` between P3 and P5) | HV bus enable; PPU checkout; each thruster: conditioning, ignition, throttle sweep, gimbal sweep, plume/EMI checks on telecom and sensors; first long-duration firing | arcing/HV fault → PPU trip: TTC seconds (thermal/electrical) — **A** (PPU protection), recovery **G** | SE-225, SE-139, SE-153, SE-221 |
| P5 | Outbound thrust/coast arcs (`outboundCruise`) | **firstThrustArc**; repeated thrust arcs (weeks) and coast periods for navigation, HGA passes and momentum management; thruster rotation for wear balancing; array degradation tracking | missed thrust (safe mode) — TTC weeks (missed-thrust margin, §1.3) — **G**; HV/thruster faults **A** | SE-130, SE-160, SE-161, SE-281, SE-282 |
| P6 | Approach and optical navigation (`approachAndRendezvous`) | target detection by the narrow-angle camera (a 7 m body at H ≈ 28 is faint: detection range **I**, thousands of km); optical-navigation campaign; target-relative OD; thrust-arc ramp-down; braking arcs | late detection → overshoot: TTC days at the approach speed — **G** with on-board image processing | SE-195, SE-282, SE-132 |
| P7 | Rendezvous and station-keeping (`approachAndRendezvous` → **rendezvous**) | hold at ≈ 1–10 km, then ≈ 100 m (**I**); forced-motion station-keeping (SRP ≫ target gravity, §1.2) | closing at 2 cm/s from 50 m → contact in 2 500 s (≈ 42 min) vs RTLT up to 400 s — **A** collision avoidance (keep-out sphere) | SE-151, SE-162, SE-273 |
| P8 | Inspector release and circumnavigation (`characterisation`, **inspectorRelease**) | Wren checkout on umbilical; release from dispenser (separation velocity **I**, cm/s); proximity link acquisition; forced-motion circumnavigation at ≈ 20–100 m; imaging in many phase angles; bistatic radar sounding with the tug as transmitter; close passes for gravity-perturbation mass estimate | Wren–target or Wren–tug collision: TTC minutes at cm/s — **A** on Wren; proximity-link loss → Wren autonomous safe retreat | SE-158 (meaning changes), SE-159, SE-129, SE-106 |
| P9 | Characterisation and the capture-commit decision (`characterisation` → **captureCommit**) | shape model, spin state, mass (TR-003: to 10 %), thermal and strength assessment; ground capture-readiness review; envelope check (§7) against `CaptureSystem.maximumBodyDiameter` / `maximumBodyMass`; commit or abort/retarget | decision is ground-made (**G**), with no time pressure except the departure window | SE-003-like gate, SE-025, SE-192, SE-201, TR-003 |
| P10 | Approach, contact and capture (`capture`) | final approach along the spin axis or a matched-rotation approach; bag deployment and inflation; envelopment; contact | contact with an 84.8 mm/s equatorial surface: TTC seconds — **A** (closed-loop relative GNC, abort-to-retreat) | SE-155, SE-157 (meaning changes), SE-163 |
| P11 | Bag cinching (`capture` → **captureComplete**) | cinch lines tensioned; bag pressure/shape monitoring; body-to-tug load path established | cinch-motor stall/slip: TTC minutes — **A** stop, **G** recovery | SE-155, SE-163 |
| P12 | Despin (`capture` → **despinComplete**) | RCS torques remove L ≈ 4.2 × 10⁴ N·m·s; e.g. 11.6 N·m for 1 h, propellant ≈ 6.5 kg with a 3 m arm at Isp 220 s (D✎, arm and Isp **I**); nutation damping; stack mass-properties estimation by response to known torques/thrust | despin torque exceeding bag/cinch capability → slip: TTC seconds–minutes — **A** torque limiting | SE-122, SE-131, SE-153 |
| P13 | Departure (**departureFromTarget**) | first stack thrust arc; in-flight mass measurement (a = F/m: 1.83 N on 376 t → 0.42 m/s/day, measured by ranging — mass to ≪ 10 % after capture); gimbal re-trim to the stack CoM | thrust vector off the stack CoM → tumble: TTC minutes — **A** | SE-122, SE-132, TR-008 (slow-push deflection demonstration) |
| P14 | Return arcs (`returnCruise`) | long thrust arcs at 4.9 × 10⁻⁶ m/s²; Earth-impact-exclusion biased aiming; deflection demonstration measurement (TR-008: Δv to 1 mm/s) | missed thrust → must not converge on an Earth-impact trajectory: TTC months — **G**, but the trajectory is designed so that *stopping* is safe | SE-130, SE-171, SE-176, TR-006, TR-008 |
| P15 | Lunar gravity assist (**lunarGravityAssist**) | approach targeting; flyby (periapsis ≈ 100 km class, **I**); possible lunar shadow passage | flyby targeting error: TTC days (correction windows) — **G**; shadow passage — **S** | SE-155, SE-195, SE-264 |
| P16 | DRO insertion and checkout (**droInsertion**, `droInsertionAndCheckout`) | insertion thrust arcs; orbit determination of the stack; stability confirmation | missed insertion → escape or unstable orbit: TTC days — **G** with pre-planned contingency arcs | SE-155, SE-195, TR-006 |
| P17 | Utilisation and visiting-vehicle docking (`utilisation`, **visitingVehicleDocking**) | attitude hold for Lantern; docking-port configuration; RCS inhibits during docking; power/data pass-through | docking contact: TTC seconds — **A** on the visiting vehicle; the tug in a passive, inhibited mode | SE-151, SE-163, SE-105-like ICD (docking) |
| P18 | Extended mission (`extendedMission`) | further deflection experiments; long-term DRO stability tracking; degraded-unit operations | none new | SE-283, SE-281 |
| P19 | Tug separation (**tugSeparation**) | bag release / cut; tug back-away; body left free in the DRO | re-contact risk: TTC minutes — **A** | SE-262, SE-290 |
| P20 | Disposal (`disposal`, **tugDisposalBurn**) | departure to heliocentric orbit (lunar flyby or thrust); passivation (xenon vent, hydrazine depletion, battery disconnect, transmitter off) | none; disposal is a requirement on the end state | SE-182, SE-290, SE-291 |
| P21 | Safe-mode periods (anywhere) | sun-safe with large arrays; with the body attached the stack's inertia (≈ 2 × 10⁶ kg·m², D✎) makes slews slow and wheels useless (momentum ≫ wheel capacity) — thrusters only | power-negative attitude loss: TTC hours — **A** | SE-160, SE-161, SE-165 |
| P22 | Earth/lunar eclipse in the DRO | Earth umbra passages up to a few hours; lunar shadow ≲ 2 h | battery depth of discharge — **S** | SE-125, SE-264, SE-308 |

Timeline gaps seen in TB: no `integrationAndTest`, no `sepCommissioning`, no inspector-recovery/retirement event (Wren is expendable or re-docked — a decision for WP-E), and **inspectorRelease** is ordered *after* `characterisation` starts while Wren *performs* the characterisation (`first characterisation then inspectorRelease`; the release is inside the phase — fine as an ordering, but entry/exit criteria of `characterisation` must then be written against it).

## 3. Subsystems and instruments

Construct: `part def … :> Subsystem` (TB `TethysTug`), units as nested `part`s, attributes ISQ-typed, power by mode as attributes keyed by the mode enum (checklist §3 #15 — no map type: one attribute per mode or `if` chains), redundancy as multiplicity plus `@Probability` (Sto [ext]) for reliability. Patterns: rts/mass-rollup (mass), rts/reliability (`e^(−λt)`), rts/spacecraft-comms (orthogonal modes), A11 (CoSMA layering), FL (multiplicity at scale).

| Element | Subsystem / unit | Key parameters to model | Construct / library type | Pattern? |
|---|---|---|---|---|
| Tug | SEP — Hall thrusters (4, 3 operating, TB) | thrust vs power (`SepThrust`), Isp (TB 2 900 s), efficiency, throttle range, xenon throughput and life per thruster, plume divergence, gimbal range and rate | `part thruster : HallThruster[4]`; `ForceValue`, `DurationValue`, `MassValue`; operating set as `variation`/state | rts/delta-v-budget |
| Tug | SEP — power processing units | number, cross-strapping to thrusters (switching unit), input voltage range, efficiency (heat to reject ≈ (1−η)P: 2 kW at 40 kW and η 0.95, D✎), mass | `part ppu : PowerProcessingUnit[n]`, connections; `PowerValue` | — |
| Tug | SEP — xenon storage and feed | tank count/volume (≈ 6.1 m³ at 1.6 g/cm³), MEOP, temperature control (supercritical storage), pressure regulation, flow controllers per thruster, residuals, gauging method | `part xenonTank[n]`; `PressureValue`, `VolumeValue`, `MassValue`; `FluidPort` (TB) | — |
| Tug | EPS — roll-out arrays (2 wings) | P(1 AU, BOL) = 48 kW (TB), P(r, T, fluence) table, wing stiffness/first mode (low: couples with the stack attitude control), drive mechanism, deployed area | `SF::SampledFunction` for degradation; `PowerValue`, `AreaValue`, `FrequencyValue` | expr |
| Tug | EPS — high-voltage bus | direct-drive (array voltage straight to PPUs) vs regulated; bus voltage class (hundreds of V, **I**); arcing/paschen design rules; fault isolation | separate `port def HighVoltageOutlet :> PowerOutlet` with a voltage constraint (O12) | — |
| Tug | EPS — low-voltage bus, battery, PCDU | 28 V-class bus, battery energy for LEOP, LGA and DRO eclipses (§1.4), depth of discharge | `EnergyValue`, `ElectricPotentialValue`; energy budget calc | rts/spacecraft-comms (battery region) |
| Tug | GNC — attitude | star trackers, IMU, sun sensors, wheels (sized for the tug alone — useless for the stack), RCS for stack control | `AngularMomentumValue` wheel capacity, `TorqueValue` | — |
| Tug | GNC — relative navigation | narrow/wide-angle cameras, flash or scanning lidar, thermal IR camera; range/accuracy envelopes from detection to contact | `LengthValue` range bands; accuracy `LengthValue`; frames `Geo` | — |
| Tug | Reaction control (hydrazine, TB 400 kg) | thruster count/thrust/arm, Isp (≈ 220 s class, P), despin and stack-attitude budget, plume impingement on the body/bag | `ForceValue`, `TorqueValue`, `MassValue` | rts/delta-v-budget |
| Tug | Capture system | bag envelope (TB max 10 m, 1 000 t), inflatable booms, fabric strength and puncture resistance, cinch lines and motors, load path stiffness/damping, contact sensors, release (cut) mechanism | `ForceValue`, `TorqueValue`, `PressureValue`, `LengthValue`; contact dynamics as SSR (§7) | — |
| Tug | Characterisation sensors (TB) | cameras, thermal imager, radio-science mass determination | data rates, FoV (`AngularMeasureValue`), resolution | — |
| Tug | Telecom | X/Ka transponders, gimballed HGA (Sun–probe–Earth ≈ 90°), LGAs, proximity transceiver for Wren, ranging accuracy for the deflection measurement (TR-008, 1 mm/s) | `FrequencyValue`, `PowerValue`, dB as `Real` (checklist §3 #12) | rts/spacecraft-comms |
| Tug | C&DH and flight software | autonomy for prox-ops, capture and despin; image processing; mass memory for characterisation data | processor margin attributes; `state def`s | — |
| Tug | Thermal | PPU heat rejection, xenon tank temperature band, hot case at 0.9647 AU full power, cold case at 1.1393 AU coast, body contact (≈ 280–303 K surface, §1.2) | `ThermodynamicTemperatureValue`, `PowerValue`; lumped nodes via external tool | — |
| Tug | Structure & mechanisms (TB) | launch loads, stowed volume in the fairing, docking interface, inspector dispenser, stack load path (body mass 60× the tug) | `MassValue`, `AccelerationValue`, `ForceValue`; CoM/inertia via `TC` | rts/mass-rollup |
| Inspector (Wren) | 12U bus (TB) | structure, body-mounted/deployable arrays (≈ tens of W), battery, ADCS (wheels + cold gas), proximity transceiver, autonomy | `PowerValue`, `EnergyValue`, `MassValue` (TB 24 kg wet) | — |
| Inspector | Cold-gas propulsion (TB) | propellant mass, Isp (≈ 40–70 s for cold gas, P), Δv for forced-motion circumnavigation (SRP ≈ 1.9 × 10⁻⁸ m/s² continuous ≈ 0.6 m/s per year to counter; plus manoeuvres) | `MassValue`, `SpeedValue` | rts/delta-v-budget |
| Inspector | Imaging payload (TB) | visible camera (shape), thermal camera (thermal inertia), bistatic radar sounder with the tug transmitter (interior), data volume per circumnavigation | data rate/volume; FoV; pointing | — |
| Launch segment | Arcturus-5H (TB) | mass vs C3 curve (TB one point: 17 200 kg at C3 = 2 km²/s²), launch declination, fairing envelope, environments, adapter | `SF::SampledFunction` C3 → mass; `MassValue` | — |
| Launch segment | Payload adapter and separation | interface diameter class (standard clamp-band sizes, e.g. 1 194 / 1 666 mm, public), separation velocity, tip-off | `LengthValue`, `SpeedValue`, `AngularVelocityValue` | — |
| Launch segment | Launch site and window (TB) | latitude, daily window, launch period for the escape asymptote | `AngularMeasureValue`, `DurationValue` | — |
| Ground segment | Meridian stations (TB, 3) | aperture, G/T, EIRP, bands, longitudes ≈ 120° apart, ranging/Doppler accuracy | `LengthValue`, `PowerValue`, dB `Real` | — |
| Ground segment | MOC, FDF, SDS (TB) | low-thrust optimiser and OD of tug and target (FDF); shape/mass/spin pipeline that gates the capture commit (SDS); capture-readiness review | `part`s with `perform action`s; products as `item def`s | — |
| Target (Amaranth) | the body as a system element (TB `TethysTarget`) | diameter, shape (`Geo::ShapeItems`), mass, density, inertia tensor (`TC`), spin state (`VC`), surface strength and friction, thermal inertia, albedo, as-designed (pre-arrival) vs as-characterised individual | `part def SmallBody` (TB) + `individual part def` for the as-characterised body with `snapshot`s (pre-arrival, post-characterisation, post-capture) | relay (snapshots), TR/28 |
| External | Visiting vehicle Lantern (TB) | docking interface only: mass, approach corridor, docking loads, power/data demand | TB `VisitingVehicle` | — |

## 4. Interfaces

Construct: one `interface def` per ICD class in `TethysInterfaces` (TB), ends typed by `port def`s whose directed `item` features carry ISQ attributes; flows as `flow … from … to …`; ICD parameters both ends must agree on as `constraint`s over the two ends (SE-111); the ICD document from DQ `Document` [ext] (SE-112). Patterns: mosa (ICD document), TR/10–13 (ports, interfaces, binding, flows), TB (definitions already present).

| Interface (TB def) | Disciplines | What the ICD must carry | Gap in TB (O12) | Rows |
|---|---|---|---|---|
| Tug ↔ launcher (`SpacecraftLauncherInterface`) | mechanical (adapter, clamp band/bolts), loads (quasi-static, sine, random, acoustic, shock), electrical (umbilical, separation switches), RF during ascent, thermal and cleanliness in fairing | stack mass/CoM/inertia limits (stowed arrays, full xenon), fundamental-frequency requirements, environment levels, separation velocity and tip-off, fairing envelope, launch-to-C3 injection accuracy | only `MechanicalPort`; add umbilical and separation-signal ends | SE-104, SE-311 |
| Tug ↔ inspector, attached (`TugInspectorInterface`) | mechanical (dispenser, preload, release), electrical (keep-alive, charging, checkout data), thermal (heater power, conductive isolation) | dispenser release velocity and tip-off, umbilical pins and power limits, separation signals and inhibits, thermal limits while stowed for ≈ 1 yr of cruise | only the umbilical; add dispenser `MechanicalPort` and `ThermalPort` ends | SE-103 (meaning changes) |
| Tug ↔ inspector, free-flying (`InspectorRelayLink`) | RF proximity link; relative ranging; time correlation | frequency band, data rate vs range (≤ few km), protocol, commanding latency, the bistatic-radar timing between tug transmitter and Wren receiver | geometry window not modelled | SE-106 (meaning changes), SE-129 |
| Tug ↔ target (`CaptureInterface`) | mechanical contact (bag, cinch), dynamics (despin torques, thrust loads), thermal (body as a heat source/sink through the bag), contamination (ejecta) | envelope (max diameter, mass, spin rate, aspect ratio), contact speed limit, cinch preload, maximum despin torque, load path stiffness, allowed slip, steady thrust load (1.8–2.2 N) and attitude-control torques transmitted, bag temperature limits vs body temperature 280–303 K | only `MechanicalPort`; add `ThermalPort`, spin/torque attributes and a contact-dynamics model reference | new row (no Venus analogue); SE-136-replacement |
| Tug ↔ visiting vehicle (`DockingInterface`) | mechanical (docking mechanism and loads), electrical (power transfer), data, approach corridor and keep-out, RCS inhibits | docking standard (e.g. the public International Docking System Standard, IDSS IDD), capture/attenuation loads, power and data pass-through levels, approach corridor, attitude-hold accuracy of the stack | adequate shape; constraints missing | SE-105-like, SE-163 |
| Space ↔ ground (`SpaceGroundLink`) | X/Ka RF; TM/TC protocols; ranging/Doppler; time correlation | frequencies, data rates per phase, coding, link margins at the range envelope per phase (LEOP near 0 … ≈ 60 × 10⁶ km … DRO 0.3–0.5 × 10⁶ km), ranging accuracy for TR-008 | range envelope (O7) | SE-105, SE-128 |
| Ground internal (none in TB) | station ↔ MOC ↔ FDF ↔ SDS | file formats, latencies; the characterisation product chain (images → shape model → mass/spin estimate → capture-readiness package); OD exchange (tug and target ephemerides) | add `interface def`s or `flow`s between `GroundNetwork` parts | SE-279 |
| Internal tug — high-voltage power (`highVoltageToSep` uses `PowerInterface`) | array → PPU direct drive or regulated HV bus | voltage range vs array temperature and Sun distance, current limits, fault isolation, arcing rules | no voltage class: add a `HighVoltageOutlet` port def with a voltage constraint | SE-107 |
| Internal tug — low-voltage power (`PowerInterface`) | 28 V-class bus | per-unit power by mode, protection | per-mode loads missing | SE-107, SE-123 |
| Internal tug — data (`DataBusInterface`) | on-board bus (MIL-STD-1553B or SpaceWire class), high-rate camera/lidar links | data rates per mode, latency for relative GNC | rates missing | SE-107, SE-142 |
| Internal tug — xenon feed (none) | tanks → regulator → flow controllers → thrusters | pressures, flow rates per thruster (ṁ ≈ 2.1 × 10⁻⁵ kg/s each for 3 operating at 40 kW, D✎), temperatures, isolation valves | add `interface def XenonFeed` over `FluidPort` | SE-107, SE-131 |
| Internal tug — hydrazine feed (none) | tank → RCS thrusters | as for xenon | add | SE-107 |
| Internal tug — thermal (`ThermalInterface`) | PPU baseplates → radiators, tank heaters | heat loads per mode, temperature limits | values missing | SE-107, SE-134 |
| Internal tug — gimbal/mechanism drives | thruster gimbals, array drives, HGA gimbals, cinch motors | ranges, rates, torques, power | add | SE-107 |

## 5. Failure modes and safe-mode triggers

Construct: FMECA items as `CE` `#cause`/`#effect`/`causation` (SysML §9.5) with severity as `MM`/local metadata; monitors as `constraint`s evaluated in `state def` guards (`accept when …`); responses as transitions to `safe`/`retreat`/`hold` states; inhibits as Boolean guards on the hazardous actions (SE-163); probabilities as `Sto::Probability` [ext] for `Sim::MonteCarlo` runs; behaviour checked with `-engine check -check-property`. Patterns: rts/spacecraft-comms (orthogonal regions), TR/41 (CauseAndEffect keywords only), rules (house rules). Proximity and capture rows have **no** pattern.

| # | Failure / trigger | Detection | Typical response | TTC / autonomy | Rows |
|---|---|---|---|---|---|
| F1 | Hall thruster fails to ignite / flameout | discharge current, PPU telemetry | retry, switch to spare thruster (4th), re-plan arc | days — A/G | SE-160, SE-174 |
| F2 | PPU fault (output short, HV arcing) | PPU protection, bus current | PPU trip and cross-strap to a spare PPU | seconds — A | SE-160, SE-078 |
| F3 | Thrust-arc loss (any safe mode during thrusting) | thrust accumulator vs plan | resume within the missed-thrust margin; re-plan | weeks — G | SE-130, SE-194 |
| F4 | Gimbal stuck | gimbal position | use remaining gimbals/thrusters; RCS momentum management | hours — A/G | SE-132 |
| F5 | Xenon regulator/flow-controller failure, leak | pressure, flow | isolate branch, switch regulator | hours — A | SE-131, SE-144 |
| F6 | Array wing partial deployment or string loss | array current/voltage | reduced-power thrust profile; variant with one wing | days — G | SE-124, SE-079 |
| F7 | Faster array degradation than predicted (SPE) | power trend | re-plan trip time; TPM breach → risk | months — G | SE-124, SE-245, SE-281 |
| F8 | HV bus fault | bus monitor | isolate SEP, LV bus survives | seconds — A | SE-107 |
| F9 | Collision risk tug–target (closing rate above corridor) | relative nav (lidar/camera), keep-out sphere | autonomous collision-avoidance manoeuvre (retreat) | minutes — A | SE-162, SE-273 |
| F10 | Loss of relative navigation (sensor fault, glare, target out of FoV) | sensor validity, filter covariance | hold or retreat on inertial propagation | minutes — A | SE-160, SE-161 |
| F11 | Ejecta or debris released by contact contaminates optics/arrays | image quality, array current | continue with degraded sensors; retreat | hours — G | SE-181 |
| F12 | Bag tear or puncture | bag pressure, shape sensing | re-inflate from reserve, partial envelopment, abort | minutes — A | SE-174, SE-178 |
| F13 | Body slips in the cinched bag | relative motion sensors, cinch tension | re-cinch, limit torques | minutes — A | SE-155 |
| F14 | Body larger than characterised (> envelope) | shape model | no-go at capture commit; retarget/variant | n/a — G | SE-025, §7 |
| F15 | Body heavier than characterised | stack response to known thrust after capture | re-plan return; reduced-Δv aim point (still Earth-safe) | months — G | TR-001, §7 |
| F16 | Body spinning faster/tumbling beyond despin capability | spin estimation, despin rate | extend despin, release body, abort | minutes–hours — A/G | SE-155, §7 |
| F17 | Despin fails to converge (nutation, RCS fault) | rates | stop, release and retreat | minutes — A | SE-153 |
| F18 | Inspector loss (separation failure, prox-link loss, collision) | link status, Wren beacon | tug-only characterisation (tug cameras, radio-science mass after capture) — variant | n/a — G | SE-079, SE-158 |
| F19 | Inspector does not release | dispenser switches | retry, backup release, tug-only variant | hours — G | SE-158 |
| F20 | Return-leg missed thrust that biases toward Earth | trajectory monitor vs Earth-impact keep-out | trajectory designed so that stopping is safe; contingency aim points | months — G (by design) | SE-171, SE-176, TR-006 |
| F21 | Lunar gravity-assist targeting error | OD | correction arcs; alternative flyby | days — G | SE-155, SE-195 |
| F22 | DRO insertion miss | OD | contingency insertion arcs; alternative stable orbit | days — G | SE-155, TR-006 |
| F23 | Docking fault (misalignment, latch failure, load exceedance) | docking sensors | visiting vehicle aborts; tug stays passive, inhibits held | seconds — A (visitor) | SE-163 |
| F24 | Attitude loss with body attached | rates, sun sensors | thruster-only sun-safe (wheels saturate instantly) | hours — A | SE-161, P21 |
| F25 | Battery low (LEOP, LGA shadow, DRO eclipse) | SOC | load shed, safe | hours — A | SE-125 |
| F26 | Loss of uplink (command-loss timer) | timer | LGA rotation, safe mode; prox-ops: retreat first | days — A | SE-162 |
| F27 | Processor reset during prox ops/capture | watchdog | reboot to redundant computer in a safe prox-ops state (hold/retreat), never resume a capture sequence without ground | seconds — A | SE-160, SE-165 |
| F28 | Tug fails to separate from the body at end of mission | release mechanism status | backup cut; stack stays in the DRO (TR-006 still holds) | n/a — G | SE-290 |

## 6. Trades

Construct: `TS::TradeStudy` analysis with `TS::MinimizeObjective`/`MaximizeObjective` and an `EvaluationFunction`; alternatives as `variant`s of a `variation` (O11 shape) or as separate `part` usages; selection rationale as `MM::Rationale`; parametric trades with `-sweep`/`-samples`; recorded runs with AR [ext]. Patterns: lander (trade study), robot (variation points + trade), PL (superset model, configurations, solving the family), TR/36 (variability).

| # | Trade | Alternatives (generic) | Criteria | Drives rows |
|---|---|---|---|---|
| T1 | Target selection and uncertainty policy | well-characterised target from ground (radar/thermal IR observed) vs optical-only (H, colour) target; design to the nominal case vs to an envelope (worst case) vs adaptive (commit after characterisation) | capture-system mass, xenon reserve, probability of a go at the commit, schedule | §7, SE-201, SE-025 |
| T2 | Direct escape vs spiral-out | heavy launcher to C3 ≈ 2 km²/s² vs medium launcher to low orbit + SEP spiral (months in the belts) | launch cost, trip time, array radiation damage, thruster throughput | SE-137, SE-130, SE-311 |
| T3 | Array power vs trip time | e.g. 30 / 48 / 70 kW at 1 AU | trip time (thrust ∝ P), mass, cost, thermal; the 1 300 d constraint (O3) | SE-124, SE-130, TR-002 |
| T4 | Isp vs thrust | 2 000 s (more thrust, more xenon) vs 2 900 s vs 3 500 s (less thrust): 2.45 / 1.83 / 1.58 N at 40 kW (D✓) | xenon mass vs thrust time — with the body attached thrust time dominates | SE-130, SE-131 |
| T5 | Capture mechanism | inflatable bag (TB) vs rigid arms/grapples vs nets vs tethered harpoons | envelope tolerance (size/shape/spin), contact-dynamics risk, mass, testability on the ground | SE-136-replacement, SE-221 |
| T6 | Characterisation architecture | free-flying inspector (TB) vs tug-only (cameras + touch-and-measure) vs two inspectors | mass-estimate accuracy before commit (TR-003, 10 %), risk to the tug, cost | SE-079, TR-003 |
| T7 | Mass-determination method before commit | inspector gravity perturbation (close passes, SRP-limited) vs volume × density prior vs contact push test | accuracy vs SRP knowledge, risk | TR-003, §7 |
| T8 | Destination orbit | DRO (TB) vs near-rectilinear halo orbit vs Earth–Moon L1/L2 halo vs high Earth orbit | stability without station-keeping (TR-006), insertion Δv, access by the visiting vehicle, eclipses, Earth-impact safety | SE-195, TR-006, TR-009 |
| T9 | Gravity-assist chain | single lunar flyby vs double lunar flyby vs Earth flyby + lunar flyby vs no flyby (all low thrust) | Δv, timing, Earth-impact safety margins | SE-130, SE-195 |
| T10 | Disposal | tug to heliocentric orbit (TB) vs lunar impact vs remain attached in the DRO | debris/long-term safety, propellant, re-contact risk | SE-182, SE-290 |
| T11 | Redundancy level | single-string vs selective (thrusters 3+1, PPUs n+1) vs fully redundant, for TR-007 (no single-point failure that ends the mission) — capture bag is inherently single-point (waiver) | reliability vs mass/cost | SE-078, SE-140, SE-174, SE-178 |
| T12 | Launcher | Arcturus-5H vs a second fictional launcher (C3-vs-mass curves) | margin at C3, environments, fairing, cost | SE-086, SE-121 |
| T13 | Bus voltage architecture | direct-drive HV vs regulated HV vs low voltage + PPU boost | mass, efficiency, arcing risk | SE-107, SE-123 |
| T14 | Telecom band and HGA | X only vs X + Ka; HGA size | data volume (characterisation imagery), ranging accuracy (TR-008) | SE-127, SE-128 |
| T15 | Despin method | RCS thrusters vs SEP differential gimballing vs momentum exchange with the tug's arrays | despin time, propellant, loads in the bag | SE-131, P12 |
| T16 | Approach strategy for a spinning body | match rotation (spin-axis approach) vs despin-after-capture vs capture of a slowed body (contact-free despin is not available) | contact loads, autonomy complexity | SE-155, P10 |

## 7. Target uncertainty — the dominant design driver

Every pre-arrival unknown, its plausible range (from §1.2 and the backbone), how it is measured in flight, and what it drives. Recommended SysML shape (verified in O11): a common base `part def BodyCase` carrying the uncertain attributes; `variation part def TargetCase :> BodyCase` with `variant part`s for the design cases (e.g. `small`, `nominal`, `large`, `fastSpin`, `tumbling`, `elongated`); the capture envelope and the return budgets as `assert constraint`s over `body`; one configuration per case bound by `part :>> body = TargetCase::large;` and checked with `-instantiate … -validate=`. Continuous dispersions on top: `Sim::MonteCarlo` [ext] with `RF::uniform`/`triangular`/`normal` draws, run by `-runs N -seed S` (`outOfSpec` counts envelope violations); deterministic corners with `-sweep`. Characterised values replace the priors in an `individual part def` of the body with snapshots (`preArrival`, `postCharacterisation`, `postCapture`), values brought in with `-import`. Patterns: robot/PL (variation), TR/36; MonteCarlo and RF are unused in every reviewed model (checklist §3 #8); snapshots: relay.

| Unknown | Plausible range before arrival | Measured in flight by | Drives (budgets / requirements / variants) | SysML construct |
|---|---|---|---|---|
| Diameter (mean) | 4.75–13.0 m for H = 28.1 and p_V 0.45–0.06 (probe calc); for an S-type (p_V 0.15–0.35) ≈ 5.4–8.2 m | tug and Wren imaging; shape model; lidar ranging | `CaptureSystem.maximumBodyDiameter` (TB 10 m), bag size and mass, approach geometry; TR-003; variant `large` | `LengthValue`; `DiameterFromH` calc; variants |
| Geometric albedo | 0.15–0.35 (S), wider if the type is wrong | photometry with known range and size | diameter (above), thermal | `Real` |
| Spectral type | S assumed; C/X possible from colours | multispectral imaging | density prior, albedo prior, strength | `enum def SpectralClass` |
| Bulk density | 1 300–3 500 kg/m³ (all types); S-type monolith 2 000–3 400 | mass/volume after both are measured | mass | `MassDensityValue` |
| Mass | 85 t – 1 833 t over 5–10 m and 1 300–3 500 kg/m³; 214–576 t at 6.8 m (D✓); TB nominal 362 t "±40 %" | before commit: gravitational perturbation of Wren (SRP-limited, §1.2) or contact push; after capture: response to known thrust (≪ 10 %) | `maximumBodyMass` (TB 1 000 t), return Δv and thrust time (§1.3: 1 041 / 636 / 457 / 234 m/s at 217 / 362 / 507 / 1 000 t), xenon reserve, despin propellant, structural loads; TR-001 (≥ 100 t delivered), TR-002, TR-003 (mass to 10 %) | `MassValue`; analysis case over variants; Monte Carlo |
| Shape (aspect ratio, concavities) | spheroid to ≈ 2:1 elongated (small bodies are often elongated) | shape model from imaging | bag envelope fit, inertia tensor, CoM offset in the stack, SRP; variant `elongated` | `Geo::ShapeItems`; inertia via `TC`; `MomentOfInertiaValue` |
| Spin period | seconds to hours; TB 252 s | light curve from approach imaging | equatorial surface speed (84.8 mm/s at 252 s), angular momentum (4.2 × 10⁴ N·m·s), despin torque/time/propellant, approach strategy (T16); variant `fastSpin` | `DurationValue`, `AngularVelocityValue` |
| Spin state (principal axis vs tumbling) | either | multi-epoch imaging, shape + light-curve inversion | capture feasibility, despin control design; variant `tumbling` | `enum def SpinState`; spin vector via `VC` |
| Rotational angular momentum | from inertia × spin: 10³–10⁶ N·m·s over the ranges above (D✎) | derived from shape, mass and spin | despin propellant (≈ 6.5 kg at the nominal case with a 3 m arm, D✎), cinch/bag torque capacity | `AngularMomentumValue` |
| Strength / internal structure | monolith, fractured monolith, cohesive aggregate (fast rotation rules out a strengthless rubble pile, §1.2) | bistatic radar sounding (Wren), surface imaging, contact response | bag contact pressure limits, risk of break-up during cinch/despin, fragment containment | `enum def InteriorStructure`; cohesion `PressureValue` |
| Surface properties (friction, roughness, loose material) | bare rock to cohesive fine material | imaging, thermal inertia, contact | bag slip (F13), ejecta (F11), contamination | `Real` (no ISQ friction-coefficient kind found by name) |
| Thermal inertia / surface temperature | ≈ 50–2 500 J m⁻² K⁻¹ s⁻½; surface ≈ 280–303 K equatorial (FRM) | thermal camera (Wren), diurnal curves | bag thermal design, contact heat flow, Yarkovsky prior | composed ISQ thermal quantities; `ThermodynamicTemperatureValue` |
| Orbit (ephemeris) | known from ground astrometry; small Yarkovsky drift (≈ 10⁻² AU/Myr order) | optical navigation on approach | arrival Δv and timing margins | TB `HeliocentricOrbit` |
| Satellites / debris around the body | unlikely at this size, not excluded | approach imaging | prox-ops safety corridor | `Boolean` + hazard |

## 8. Checklist impact — rows whose meaning changes for this class

The rows below keep their ids and predicates; only the content they check changes. Every other row of the checklist applies unchanged. "Construct" names the construct/library the new reading needs where it differs from the checklist's.

| Row | Venus-class reading (checklist) | Small-body-retrieval reading | Construct / library (if different) |
|---|---|---|---|
| SE-024 | science traceability (goals → instruments) | characterisation and deflection-demonstration traceability: TR-003/TR-008 objectives → measurements (shape, mass, spin, Δv to 1 mm/s) → sensor and ranging requirements | — |
| SE-025 | minimum/full success | minimum: characterisation complete; full: ≥ 100 t delivered to the DRO (TR-001); plus deflection demo (TR-008) | requirement subject = as-flown individual |
| SE-029, SE-030 | orbiter + probe ConOps | tug + inspector ConOps across P1–P22 | — |
| SE-033 | design drivers | target uncertainty (§7), thrust time (O3), Earth-impact exclusion | — |
| SE-034 | launch/PP category assumptions | direct escape on Arcturus-5H; COSPAR Earth-return assessment; target availability (synodic ≈ 4 988 d) | — |
| SE-036 | Venus PP category | small-body return to cislunar space (§1.2 row) | — |
| SE-052 | Venus environments | small-body proximity/contact environment, interplanetary 0.96–1.14 AU, cislunar | — |
| SE-053 | pointing/data/ΔV | thrust, Isp, capture envelope, ranging accuracy for TR-008 | — |
| SE-055 | fault tolerance | TR-007 plus the Earth-impact exclusion of TR-006 | — |
| SE-079 | orbiter-only / +probe variants | target-case variants (§7), tug-only vs inspector (T6), one-wing power variant (F6) | `variation`/`variant` (O11 shape) |
| SE-080 | body/instrument frames | adds target body-fixed frame, target-relative (Hill/LVLH) frame for prox ops, Earth–Moon synodic frame for the DRO | `Geo` frames |
| SE-086 | launch segment | direct injection to C3 ≈ 2 km²/s² | — |
| SE-103 | orbiter–probe ICD | tug–inspector ICD (dispenser, umbilical, thermal) | §4 |
| SE-104 | spacecraft–launcher | adds full-xenon stack with stowed roll-out arrays | — |
| SE-105 | space–ground RF at 38–261 Mkm | range envelope per phase: 0 … ≈ 60 × 10⁶ km … 0.29–0.48 × 10⁶ km (DRO) | `RangeEnvelope` per phase (O7) |
| SE-106 | probe UHF relay | Wren proximity link (≤ few km) and bistatic radar timing | §4 |
| SE-107 | power/data/propellant/thermal internal | adds HV bus, xenon feed, hydrazine feed, gimbal drives | §4 |
| SE-121 | orbiter dry + probe + propellant | tug dry, xenon, hydrazine, Wren, adapter vs launcher at C3; the target is *not* in the mass budget but in the stack mass properties | — |
| SE-122 | mass properties per configuration | adds the stack (tug + 85–1 833 t body): CoM within the bag, inertia ≈ 2 × 10⁶ kg·m² at the nominal case | `TC`, `MomentOfInertiaValue` |
| SE-123 | power by mode | adds thrusting modes (40 kW SEP), prox-ops, capture, despin, DRO hold | — |
| SE-124 | array sizing at 0.72 AU | array sizing over 0.9647–1.1393 AU (1462–1049 W/m², D✓), EOL after SPE fluence; P drives thrust and trip time (T3) | `SF` degradation table (O10) |
| SE-125 | eclipse battery | eclipses only in LEOP, the lunar flyby and the DRO (≤ a few hours, §1.4); peak loads in capture | — |
| SE-126 | probe primary battery | Wren battery/energy budget (rechargeable, body-mounted arrays) | — |
| SE-127 | science data volume | characterisation imagery and radar data through Wren's link and the tug's mass memory | — |
| SE-128 | X/Ka at Venus range | X/Ka per phase range (SE-105); no solar conjunction (§1.3) | — |
| SE-129 | probe UHF relay budget | Wren–tug proximity-link budget | — |
| SE-130 | ΔV per manoeuvre (TCMs, VOI, aerobraking) | low-thrust Δv per arc (outbound, braking, return, LGA, DRO insertion), finite-thrust time per arc (O3), missed-thrust margin; Δv depends on the target variant (§7) | analysis over variants; SSR + SSI [ext] |
| SE-131 | bipropellant budget | xenon (throughput per thruster, residuals) + hydrazine (prox ops, despin, stack attitude) + Wren cold gas | — |
| SE-132 | instrument/HGA pointing | thrust-vector pointing through the stack CoM, HGA with Sun–probe–Earth ≈ 90°, relative-nav sensor pointing | — |
| SE-133 | alignment | thruster alignment vs the moving stack CoM | — |
| SE-134 | Venus hot/cold cases | hot: full-power PPU heat at 0.9647 AU; cold: coast at 1.1393 AU and DRO eclipse; body contact case (280–303 K) | — |
| SE-135 | heat-shield budget | **replaced** by the capture contact-load budget (contact speed, cinch preload, despin torque, steady thrust load) | `ForceValue`, `TorqueValue` |
| SE-136 | entry loads, parachute | **replaced** by capture/despin dynamics: contact at up to 84.8 mm/s surface speed, despin of 4.2 × 10⁴ N·m·s | SSR (contact dynamics) |
| SE-137 | radiation (cruise + Venus orbit) | belt transit (direct escape), SPE/GCR over ≈ 3.6 yr, magnetotail passages in the DRO; dose–depth table | `SF`, `AbsorbedDoseValue` |
| SE-139 | EMC, magnetic cleanliness | Hall-thruster plume and EMI vs telecom and relative-nav sensors; plume impingement on arrays, body, Wren | — |
| SE-140 | reliability | SEP strings with wear-out (throughput), capture system as a single-point item | rts/reliability |
| SE-141 | latency at 127–871 s | RTLT 0–400 s vs prox-ops/capture TTC (minutes–seconds) → autonomy (§2) | — |
| SE-143 | ground-contact budget | continuous coverage through rendezvous, capture, LGA and DRO insertion | — |
| SE-144 | pressurant budget | supercritical xenon storage thermal/pressure budget | — |
| SE-151 | Venus modes | launch, safe, thrust, coast, approach, prox-ops, inspector-support, capture, despin, stack-thrust, DRO-hold, docking-passive, disposal | — |
| SE-152, SE-153 | modes × subsystems | adds SEP, capture system and Wren as mode-carrying elements | — |
| SE-154 | Venus sequence | P1–P20 (§2) | TB `flightTimeline` |
| SE-155 | VOI, probe release, EDL | capture commit, contact/capture, despin, LGA, DRO insertion, docking | — |
| SE-156 | aerobraking campaign | **replaced** by the thrust-arc campaign (outbound and return) with missed-thrust handling | — |
| SE-157 | probe EDL sequence | **replaced** by the capture sequence P10–P12 | — |
| SE-158 | probe release + deflection | Wren release + tug retreat; Wren end-of-life | — |
| SE-159 | relay ops during descent | tug support of Wren's circumnavigation (link, bistatic radar) | — |
| SE-161 | sun-safe | sun-safe with and without the body attached (thrusters only when attached) | — |
| SE-162 | LOS timer | adds prox-ops autonomous retreat rules | — |
| SE-163 | pyro/propulsion inhibits | bag inflation, cinch, HV enable, Wren release, tug–body separation, RCS during docking | — |
| SE-166 | entry dispersion branches | capture outcome branches (go/no-go, slip, abort) | `Sto::Probability` [ext] |
| SE-171 | Venus hazards | Earth impact by the returned body; collision in prox ops; HV; pressurised xenon | `CE`, `RM` |
| SE-174, SE-178 | SPF list and waivers | capture bag/cinch and the tug–body release are inherent single points — waivers vs TR-007 | — |
| SE-176 | PRA (optional) | Earth-impact probability of the returned body — **must** for this class | `Sim::MonteCarlo` [ext] |
| SE-180 | ground safety | xenon (high pressure) and hydrazine | — |
| SE-181 | contamination | thruster plume and contact ejecta on optics/arrays/body | — |
| SE-182 | Venus atmospheric disposal | tug heliocentric disposal; long-term fate of the body in the DRO (TR-006) | — |
| SE-191 | Venus trades | T1–T16 (§6) | `TS` |
| SE-194 | entry/aerobraking Monte Carlo | target-uncertainty, capture-dynamics, missed-thrust and DRO-insertion dispersions | `Sim::MonteCarlo` [ext] |
| SE-195 | Venus transfer and orbit | low-thrust transfer, LGA, CR3BP DRO (O6) | SSR + SSI [ext] |
| SE-196 | probe descent dynamics | relative dynamics in prox ops (forced motion under SRP), contact/despin dynamics, CR3BP propagation | SSR + SSI [ext] (no pattern) |
| SE-197 | atmosphere model | **replaced** by the small-body model: shape, gravity (point-mass at this size), SRP, thermal | `Geo`, `SF` |
| SE-198 | thermal model | adds the bag–body contact node | — |
| SE-201 | UQ | §7 is the UQ — the primary analysis of the mission | — |
| SE-216 | environmental test | adds bag deployment/inflation in vacuum and cold, roll-out wing deployment, SEP life test | — |
| SE-221 | validation | capture test against an analog body; prox-ops hardware-in-the-loop | — |
| SE-222 | simulators | prox-ops and capture simulator | — |
| SE-225 | commissioning | SEP commissioning P4; Wren checkout | — |
| SE-260 | Venus phase list | P1–P22 | — |
| SE-261 | Venus timeline | thrust arcs, rendezvous, commit, capture, LGA, DRO insertion, docking | — |
| SE-262 | config-changing events | array deployment, Wren release, bag deployment, capture, tug separation | — |
| SE-263 | as-flown individual | adds the as-characterised body individual (§7) | `individual part def`, snapshots |
| SE-264 | Venus eclipses, occultation, conjunction | no heliocentric eclipses; no solar conjunction (§1.3); LEOP, LGA and DRO shadows only | — |
| SE-265 | Venus window every 19.2 months | target-driven windows (synodic ≈ 13.7 yr) and the C3 asymptote | — |
| SE-273 | Venus flight rules | prox-ops keep-out sphere, approach corridor, no SEP firing in prox ops, torque limits in the bag | — |
| SE-278 | contingency procedures | one per F1–F28 | — |
| SE-279 | science data levels | characterisation product chain to the capture-readiness package | — |
| SE-282 | OD products | tug OD, target OD, stack OD after capture | — |
| SE-283 | extended mission | further deflection experiments, DRO tracking | — |
| SE-290 | Venus atmospheric entry disposal | tug separation and heliocentric disposal; passivation; body left in the DRO | — |
| SE-301 | Venus constants | Sun, Earth, Moon (TB) + the target body constants (§1.2) | — |
| SE-302 | Venus atmosphere | **not applicable**; replaced by the small-body surface/shape/gravity model (SE-197) | — |
| SE-303 | flux at 0.72 AU | flux at 0.9647–1.1393 AU | `SolarFlux` |
| SE-304 | Venus albedo/IR | small-body thermal (FRM, thermal inertia); Earth/Moon IR/albedo negligible except LEOP | — |
| SE-305 | radiation | §1.5 | — |
| SE-306 | Venus induced magnetosphere | solar wind; Earth's magnetotail in the DRO; SEP plume plasma | — |
| SE-307 | micrometeoroids | large thin arrays and the bag as exposed areas | — |
| SE-308 | eclipse geometry | DRO Earth/Moon shadows (§1.4) | — |
| SE-311 | launch environment | heavy launcher, direct escape, stowed roll-out arrays and full xenon | — |
| SE-313 | probe EDL environment | **replaced** by the proximity/contact environment (gravity ≈ 2 × 10⁻⁶ m/s², SRP dominance, ejecta at > 3.8 mm/s) | — |

## 9. Boundaries this class is likely to hit (beyond checklist §3)

1. **Three-body dynamics** (O6): the DRO and its stability horizon need a CR3BP state-space model — first real use of `StateSpaceRepresentation`/`StateSpaceIntegration::RK4` [ext] in any reviewed model; a 100-year horizon (TR-006) at a usable step size is also a runtime scale test.
2. **Interpolated tables** (O10): `SampledFunctions::interpolateLinear` as vendored returns wrong values; every tabulated environment depends on it.
3. **Thrust-time-limited Δv** (O3): the return budget is a coupled time/propellant/target-mass analysis over variants — a `variation` × `Sim::MonteCarlo` × `-sweep` combination none of the examples shows.
4. **No ISQ kinds** for gravitational parameter, C3, thermal inertia and friction coefficient (stiffness/damping not found by name either): documented `Real`s, as the backbone already does for GM.
5. **Vectors and tensors**: spin vector, inertia tensor and the stack CoM need `VectorCalculations`/`TensorCalculations` — unused in every reviewed model (checklist §3 #11).
6. **Autonomy timing**: TTC-vs-RTLT constraints per phase (§2) over concurrent prox-ops state machines — the checklist §3 #16 boundary, with timing in seconds.
7. **Pinned runs and tool output format** (O1): the runs gate is sensitive to output formatting; pinning a tool version with the runs is needed for `make check` to be reproducible.

## 10. Size against the section it replaces

| Part | Venus §2 rows | This list |
|---|---|---|
| Environment and constants | 25 | 70 (§1.1–1.5) |
| Phases and events | 11 | 22 (§2) |
| Subsystems and instruments | 6 | 25 (§3) |
| Interfaces | 6 | 14 (§4) |
| Failure modes | 10 | 28 (§5) |
| Trades | 10 | 16 (§6) |
| Target uncertainty | — | 14 (§7) |
| Checklist rows re-read | — | 93 row ids in 90 table rows (§8) |
