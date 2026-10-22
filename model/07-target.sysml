// The target body as a system element: the thing the mission is about, with the properties the
// capture system and the return trajectory depend on, and the surface the capture bag contacts.
package TethysTarget {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysInterfaces::*;
    private import TethysEnvironment::*;

    enum def SpinState {
        doc /* The rotation state of a small body as the characterisation reports it:
             * principal-axis rotation about the maximum-inertia axis, or non-principal-axis
             * tumbling, which the capture envelope excludes. */
        principalAxis;
        tumbling;
    }

    part def SmallBody {
        doc /* A small natural body: its bulk properties as known before and after
             * characterisation, its spin state, and the contact surface the capture mechanism
             * loads. */
        attribute meanDiameter : LengthValue;
        attribute bulkDensity : MassDensityValue;
        attribute mass : MassValue;
        attribute rotationPeriod : DurationValue;
        attribute spinState : SpinState;
        port surface : ~MechanicalPort;
    }

    part def TargetCaseBody :> SmallBody {
        doc /* One pre-arrival case of the target. Diameter, bulk density and spin are the
             * inputs; the mass follows from the sphere model (TethysEnvironment::SphereMass),
             * so no case carries a mass number of its own and every consumer reads the same
             * body. */
        attribute :>> mass default = SphereMass(meanDiameter / (1 [m]), bulkDensity / (1 ['kg⋅m⁻³'])) [kg];
        attribute :>> spinState default = SpinState::principalAxis;
    }

    part targetCases {
        doc /* The one target-case table of the mission. Every budget, analysis, envelope,
             * sequence and requirement that needs a body reads a case from here.
             *
             * Design cases — the ±40 % mass band the propellant, hydrazine and load budgets, the
             * transfer analyses, the flight sequence and the safety envelope close on:
             * `small` 5.7 m, 213 t; `nominal` Amaranth as catalogued, 6.8 m, 362 t;
             * `large` 7.6 m, 506 t, the heaviest body the mission is designed to return.
             *
             * Knowledge bounds — what ground-based knowledge of Amaranth spans before Wren
             * measures it (a factor of two in diameter, 1 200–3 500 kg/m³, 100–600 s), which size
             * the capture bag and the despin (TS-001) without being design-to-return cases:
             * `lightest` 4.0 m, 40 t; `largest` 9.5 m, 987 t; `densest` 6.8 m at 3 500 kg/m³,
             * 576 t — inside the bag, but above the return envelope with the margin policy
             * (TethysBudgets::captureCommitEnvelope), so the commit gate refuses it.
             *
             * Spin cases the capture envelope refuses: `fastSpin`, the nominal body at 120 s;
             * `tumbling`, the nominal body in non-principal-axis rotation. */
        part small : TargetCaseBody {
            doc /* −40 % on the nominal mass at the nominal density: 5.7 m, about 213 t. */
            attribute :>> meanDiameter = 5.7 [m];
            attribute :>> bulkDensity = 2200.0 ['kg⋅m⁻³'];
            attribute :>> rotationPeriod = 252.0 [s];
        }
        part nominal : TargetCaseBody {
            doc /* The backbone estimate: TethysEnvironment::amaranth. */
            attribute :>> meanDiameter = TethysEnvironment::amaranth.meanDiameter;
            attribute :>> bulkDensity = TethysEnvironment::amaranth.bulkDensity;
            attribute :>> mass = TethysEnvironment::amaranth.mass;
            attribute :>> rotationPeriod = TethysEnvironment::amaranth.rotationPeriod;
        }
        part large : TargetCaseBody {
            doc /* +40 % on the nominal mass at the nominal density: 7.6 m, about 506 t; sizes the
                 * return xenon, the stack loads and the safety envelope factor. */
            attribute :>> meanDiameter = 7.6 [m];
            attribute :>> bulkDensity = 2200.0 ['kg⋅m⁻³'];
            attribute :>> rotationPeriod = 252.0 [s];
        }
        part lightest : TargetCaseBody {
            doc /* High-albedo, low-density, slow: 4.0 m, about 40 t — below 100 t whatever the
                 * tug does, so outside the TR-001 envelope and covered by minimum success. */
            attribute :>> meanDiameter = 4.0 [m];
            attribute :>> bulkDensity = 1200.0 ['kg⋅m⁻³'];
            attribute :>> rotationPeriod = 600.0 [s];
        }
        part largest : TargetCaseBody {
            doc /* Low-albedo, fast: 9.5 m at the nominal density, about 987 t, 100 s — bounds the
                 * bag diameter and the despin; refused at commit on mass and spin. */
            attribute :>> meanDiameter = 9.5 [m];
            attribute :>> bulkDensity = 2200.0 ['kg⋅m⁻³'];
            attribute :>> rotationPeriod = 100.0 [s];
        }
        part densest : TargetCaseBody {
            doc /* Nominal size at the top of the density range (a stony-iron body): about 576 t —
                 * bounds the bag's mass limit and the stack inertia; it fits the mechanism but
                 * not the return envelope, so the commit gate refuses it. */
            attribute :>> meanDiameter = TethysEnvironment::amaranth.meanDiameter;
            attribute :>> bulkDensity = 3500.0 ['kg⋅m⁻³'];
            attribute :>> rotationPeriod = TethysEnvironment::amaranth.rotationPeriod;
        }
        part fastSpin : TargetCaseBody {
            doc /* The nominal body at a 120 s period: 8.8 × 10⁴ N·m·s against the 6.0 × 10⁴
                 * budget and 0.18 m/s at the equator; a no-go on angular momentum. */
            attribute :>> meanDiameter = TethysEnvironment::amaranth.meanDiameter;
            attribute :>> bulkDensity = TethysEnvironment::amaranth.bulkDensity;
            attribute :>> mass = TethysEnvironment::amaranth.mass;
            attribute :>> rotationPeriod = 120.0 [s];
        }
        part tumbling : TargetCaseBody {
            doc /* The nominal body in non-principal-axis rotation; a no-go on spin state. */
            attribute :>> meanDiameter = TethysEnvironment::amaranth.meanDiameter;
            attribute :>> bulkDensity = TethysEnvironment::amaranth.bulkDensity;
            attribute :>> mass = TethysEnvironment::amaranth.mass;
            attribute :>> rotationPeriod = TethysEnvironment::amaranth.rotationPeriod;
            attribute :>> spinState = SpinState::tumbling;
        }
    }

    variation part def CaptureTargetCase :> SmallBody {
        doc /* The target-case table as a variation, one variant per case bound to the body
             * above, so a configuration selects a case by name
             * (`part :>> target = CaptureTargetCase::large`). */
        variant part small : TargetCaseBody = targetCases.small;
        variant part nominal : TargetCaseBody = targetCases.nominal;
        variant part large : TargetCaseBody = targetCases.large;
        variant part lightest : TargetCaseBody = targetCases.lightest;
        variant part largest : TargetCaseBody = targetCases.largest;
        variant part densest : TargetCaseBody = targetCases.densest;
        variant part fastSpin : TargetCaseBody = targetCases.fastSpin;
        variant part tumbling : TargetCaseBody = targetCases.tumbling;
    }

    part amaranth : SmallBody {
        doc /* 2031 QX "Amaranth" as designed to: the pre-arrival estimates in
             * TethysEnvironment::amaranth. The as-characterised individual lives in the
             * as-built package. */
        attribute :>> meanDiameter = TethysEnvironment::amaranth.meanDiameter;
        attribute :>> bulkDensity = TethysEnvironment::amaranth.bulkDensity;
        attribute :>> mass = TethysEnvironment::amaranth.mass;
        attribute :>> rotationPeriod = TethysEnvironment::amaranth.rotationPeriod;
    }
}
