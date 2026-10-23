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

    variation part def CaptureTargetCase :> SmallBody {
        doc /* Amaranth as it may turn out to be when Wren measures it: the pre-arrival
             * uncertainty on diameter (±20 %), density (1 000–3 500 kg/m³ for the spectral
             * class) and spin, as the cases the capture envelope is evaluated over. The
             * nominal case is TethysEnvironment::amaranth. */
        variant part small {
            doc /* 5.4 m at 2 200 kg/m³: 181 t, well inside the envelope. */
            attribute :>> meanDiameter = 5.4 [m];
            attribute :>> bulkDensity = 2200.0 ['kg⋅m⁻³'];
            attribute :>> mass = 181.0e3 [kg];
            attribute :>> rotationPeriod = 252.0 [s];
            attribute :>> spinState = SpinState::principalAxis;
        }
        variant part nominal {
            doc /* 6.8 m at 2 200 kg/m³: 362 t, 252 s. */
            attribute :>> meanDiameter = 6.8 [m];
            attribute :>> bulkDensity = 2200.0 ['kg⋅m⁻³'];
            attribute :>> mass = 362.0e3 [kg];
            attribute :>> rotationPeriod = 252.0 [s];
            attribute :>> spinState = SpinState::principalAxis;
        }
        variant part large {
            doc /* 8.2 m at 3 500 kg/m³: 1 010 t, 1 % over the mass limit — a no-go the
                 * characterisation must be able to tell from the nominal case. */
            attribute :>> meanDiameter = 8.2 [m];
            attribute :>> bulkDensity = 3500.0 ['kg⋅m⁻³'];
            attribute :>> mass = 1010.0e3 [kg];
            attribute :>> rotationPeriod = 252.0 [s];
            attribute :>> spinState = SpinState::principalAxis;
        }
        variant part fastSpin {
            doc /* The nominal body at a 120 s period: 8.8 × 10⁴ N·m·s against a 6.0 × 10⁴
                 * budget and 0.18 m/s at the equator; a no-go on angular momentum. */
            attribute :>> meanDiameter = 6.8 [m];
            attribute :>> bulkDensity = 2200.0 ['kg⋅m⁻³'];
            attribute :>> mass = 362.0e3 [kg];
            attribute :>> rotationPeriod = 120.0 [s];
            attribute :>> spinState = SpinState::principalAxis;
        }
        variant part tumbling {
            doc /* The nominal body in non-principal-axis rotation; a no-go on spin state. */
            attribute :>> meanDiameter = 6.8 [m];
            attribute :>> bulkDensity = 2200.0 ['kg⋅m⁻³'];
            attribute :>> mass = 362.0e3 [kg];
            attribute :>> rotationPeriod = 252.0 [s];
            attribute :>> spinState = SpinState::tumbling;
        }
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
