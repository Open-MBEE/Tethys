// The physical environment Hesperia operates in: Venus, its atmosphere, the Sun at 0.72 AU.
// Public physics only; nothing here is mission-specific.
package HesperiaEnvironment {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;

    attribute def BodyConstants {
        doc /* Gravitational and geometric constants of a central body. */
        attribute gravitationalParameter : ISQ::VolumeValue;
        attribute equatorialRadius : LengthValue;
        attribute siderealRotationPeriod : DurationValue;
        attribute solarDistance : LengthValue;
    }

    attribute venus : BodyConstants {
        doc /* Venus. The gravitational parameter is carried as a volume value until a
             * length-cubed-per-time-squared quantity is declared; see HesperiaBudgets. */
        attribute :>> equatorialRadius = 6051.8 [km];
        attribute :>> siderealRotationPeriod = 243.025 [d];
        attribute :>> solarDistance = 108.21e6 [km];
    }

    attribute solarConstantAtEarth : ISQ::PowerValue;
}
