// The physical environment Tethys operates in: the Sun near 1 AU, the Earth–Moon system the tug
// leaves and returns to, and the target body. Public physics and the invented target only;
// nothing here is a design value.
package TethysEnvironment {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import RealFunctions::*;

    attribute def BodyConstants {
        doc /* Gravitational and geometric constants of a natural body. The gravitational
             * parameter GM is a plain Real in km³/s² because ISQ declares no quantity kind for
             * it; TethysBudgets converts it where a unit matters. */
        attribute gravitationalParameterKm3PerS2 : Real;
        attribute mass : MassValue;
        attribute equatorialRadius : LengthValue;
    }

    attribute sun : BodyConstants {
        doc /* The Sun: GM 1.327 124 4 × 10¹¹ km³/s². */
        attribute :>> gravitationalParameterKm3PerS2 = 1.32712440018e11;
        attribute :>> mass = 1.9885e30 [kg];
        attribute :>> equatorialRadius = 695700.0 [km];
    }

    attribute earth : BodyConstants {
        doc /* Earth: GM 398 600.4418 km³/s², equatorial radius 6378.137 km. */
        attribute :>> gravitationalParameterKm3PerS2 = 398600.4418;
        attribute :>> mass = 5.9722e24 [kg];
        attribute :>> equatorialRadius = 6378.137 [km];
    }

    attribute moon : BodyConstants {
        doc /* The Moon: GM 4902.800 km³/s², mean radius 1737.4 km. */
        attribute :>> gravitationalParameterKm3PerS2 = 4902.800066;
        attribute :>> mass = 7.346e22 [kg];
        attribute :>> equatorialRadius = 1737.4 [km];
    }

    attribute def LunarOrbitConstants {
        doc /* The Moon's orbit about the Earth, which sets the cislunar destination geometry. */
        attribute semiMajorAxis : LengthValue;
        attribute siderealPeriod : DurationValue;
        attribute synodicPeriod : DurationValue;
    }

    attribute lunarOrbit : LunarOrbitConstants {
        doc /* 384 400 km mean distance, 27.3217 d sidereal month, 29.5306 d synodic month. */
        attribute :>> semiMajorAxis = 384400.0 [km];
        attribute :>> siderealPeriod = 27.3217 [d];
        attribute :>> synodicPeriod = 29.5306 [d];
    }

    attribute def HeliocentricOrbit {
        doc /* Keplerian elements of a heliocentric orbit at a reference epoch. */
        attribute semiMajorAxisAu : Real;
        attribute eccentricity : Real;
        attribute inclination : AngularMeasureValue;
        attribute perihelionAu : Real;
        attribute aphelionAu : Real;
        attribute period : DurationValue;
        attribute synodicPeriodWithEarth : DurationValue;
    }

    attribute def SmallBodyConstants {
        doc /* The physical characterisation of a small body as known before arrival: every
             * value carries the uncertainty TethysAnalyses propagates through capture and
             * return. */
        attribute meanDiameter : LengthValue;
        attribute bulkDensity : MassDensityValue;
        attribute mass : MassValue;
        attribute rotationPeriod : DurationValue;
        attribute absoluteMagnitude : Real;
        attribute geometricAlbedo : Real;
        attribute spectralType : String;
        attribute orbit : HeliocentricOrbit;
    }

    attribute amaranth : SmallBodyConstants {
        doc /* 2031 QX "Amaranth" is an invented target: a small, fast-rotating S-type on an
             * Earth-like orbit, chosen so that a solar-electric tug can reach it with a few
             * km/s and bring it back with a few hundred m/s. The mass follows from the
             * diameter and the density (SphereMass); its ±40 % pre-arrival uncertainty is the
             * mission's dominant design driver. */
        attribute :>> meanDiameter = 6.8 [m];
        attribute :>> bulkDensity = 2200.0 ['kg⋅m⁻³'];
        attribute :>> mass = 362.0e3 [kg];
        attribute :>> rotationPeriod = 252.0 [s];
        attribute :>> absoluteMagnitude = 28.1;
        attribute :>> geometricAlbedo = 0.20;
        attribute :>> spectralType = "S";
        attribute :>> orbit : HeliocentricOrbit {
            attribute :>> semiMajorAxisAu = 1.052;
            attribute :>> eccentricity = 0.083;
            attribute :>> inclination = 1.6 ['°'];
            attribute :>> perihelionAu = 0.9647;
            attribute :>> aphelionAu = 1.1393;
            attribute :>> period = 394.1 [d];
            attribute :>> synodicPeriodWithEarth = 5004.0 [d];
        }
    }

    attribute def SolarConstants {
        doc /* The Sun as the tug's power source and thermal load. */
        attribute irradianceAtOneAu : IrradianceValue;
        attribute astronomicalUnit : LengthValue;
    }

    attribute solar : SolarConstants {
        doc /* Solar irradiance 1361 W/m² at 1 AU; 1 AU = 149 597 870.7 km. */
        attribute :>> irradianceAtOneAu = 1361.0 ['W/m²'];
        attribute :>> astronomicalUnit = 149597870.7 [km];
    }

    attribute def RangeEnvelope {
        doc /* A minimum–maximum distance envelope. */
        attribute minimum : LengthValue;
        attribute maximum : LengthValue;
    }

    attribute earthRange : RangeEnvelope {
        doc /* Tug–Earth distance over the mission: 2 to 60 million km (one-way light time 7 to
             * 200 s). The Earth-like target orbit keeps the tug close; the drift phases of the
             * outbound and return legs set the maximum. */
        attribute :>> minimum = 2.0e6 [km];
        attribute :>> maximum = 60.0e6 [km];
    }

    attribute heliocentricRange : RangeEnvelope {
        doc /* Sun distance over the mission, from the target's perihelion to its aphelion:
             * solar flux 1049 to 1462 W/m² (SolarFlux). */
        attribute :>> minimum = 144.3e6 [km];
        attribute :>> maximum = 170.4e6 [km];
    }

    attribute def DistantRetrogradeOrbit {
        doc /* The cislunar destination: a planar distant retrograde orbit about the Moon, chosen
             * for its long-term stability without station-keeping. */
        attribute radiusAboutMoon : LengthValue;
        attribute period : DurationValue;
        attribute stabilityHorizon : DurationValue;
    }

    attribute destinationDro : DistantRetrogradeOrbit {
        doc /* The selected DRO: about 70 000 km from the Moon, two-week period, stable for well
             * over a century (invented selection; the stability is what TethysAnalyses must
             * show). */
        attribute :>> radiusAboutMoon = 70000.0 [km];
        attribute :>> period = 13.9 [d];
        attribute :>> stabilityHorizon = 36525.0 [d];
    }

    attribute speedOfLightKmPerS : Real = 299792.458;
    attribute standardGravityMPerS2 : Real = 9.80665;
    attribute pi : Real = 3.14159265358979;

    calc def SolarFlux {
        doc /* Inverse-square solar irradiance in W/m² at a heliocentric distance given in AU. */
        in distanceAu : Real;
        return flux : Real = 1361.0 / (distanceAu * distanceAu);
    }

    calc def CircularSpeed {
        doc /* Circular orbital speed in km/s for GM in km³/s² and orbit radius in km. */
        in gm : Real;
        in radiusKm : Real;
        return speedKmPerS : Real = sqrt(gm / radiusKm);
    }

    calc def EscapeSpeed {
        doc /* Escape speed in km/s from radius r (km) about GM (km³/s²). */
        in gm : Real;
        in radiusKm : Real;
        return speedKmPerS : Real = sqrt(2.0 * gm / radiusKm);
    }

    calc def OrbitalPeriod {
        doc /* Period in seconds of an orbit with semi-major axis a (km) about GM (km³/s²). */
        in gm : Real;
        in semiMajorAxisKm : Real;
        return periodS : Real = 2.0 * pi * sqrt(semiMajorAxisKm ** 3 / gm);
    }

    calc def OneWayLightTime {
        doc /* Signal travel time in seconds over a range in km. */
        in rangeKm : Real;
        return seconds : Real = rangeKm / speedOfLightKmPerS;
    }

    calc def SphereMass {
        doc /* Mass in kg of a sphere of the given diameter (m) and bulk density (kg/m³): the
             * first-order small-body mass estimate. */
        in diameterM : Real;
        in densityKgPerM3 : Real;
        return massKg : Real = pi / 6.0 * diameterM ** 3 * densityKgPerM3;
    }

    calc def SepThrust {
        doc /* Thrust in newtons of an electric propulsion system from the power it draws (W),
             * its specific impulse (s) and its total efficiency: T = 2 η P / (Isp g₀). */
        in powerW : Real;
        in specificImpulseS : Real;
        in efficiency : Real;
        return thrustN : Real =
            2.0 * efficiency * powerW / (specificImpulseS * standardGravityMPerS2);
    }

    calc def NaturalLog {
        doc /* ln x by the series 2 Σ y^(2k+1)/(2k+1), y = (x−1)/(x+1), truncated after k = 5.
             * The Kernel Function Library has no logarithm (RealFunctions declares sqrt, floor,
             * round and the arithmetic operators only), so the rocket equation needs its own.
             * For x ≤ 3 the truncation error is below 3 × 10⁻⁵. */
        in x : Real;
        attribute y : Real = (x - 1.0) / (x + 1.0);
        return lnX : Real = 2.0 * (y + y ** 3 / 3.0 + y ** 5 / 5.0 + y ** 7 / 7.0
            + y ** 9 / 9.0 + y ** 11 / 11.0);
    }

    calc def RocketEquationDeltaV {
        doc /* Tsiolkovsky: Δv in m/s = Isp g₀ ln(m₀/m₁) for the specific impulse in seconds and
             * the initial and final masses in kg. */
        in specificImpulseS : Real;
        in initialMassKg : Real;
        in finalMassKg : Real;
        return deltaVMPerS : Real =
            specificImpulseS * standardGravityMPerS2 * NaturalLog(initialMassKg / finalMassKg);
    }
}
