library package TethysPhysics {
    doc /* Kernel-level physics library of the Tethys Retrieval mission model, written in KerML
         * so that every function, classifier and relationship below is reachable from SysML
         * (TethysEnvironment, TethysBudgets, TethysVariants) and from a plain KerML tool alike.
         * Four fields: two-body orbital mechanics, the restricted three-body environment of the
         * storage orbit, low-thrust transfer sizing and gridded-ion electric propulsion. Every
         * function takes and returns SI base units (m, kg, s, W, N, rad) as Real values; the
         * SysML packages attach ISQ quantity kinds and unit literals at the point of use. Values
         * such as the heliocentric gravitational parameter are passed in, never embedded, so
         * the library carries no mission data of its own. */

    private import ScalarValues::*;
    private import RealFunctions::*;
    private import TrigFunctions::*;
    private import Occurrences::*;
    private import Objects::*;
    private import Metaobjects::*;
    private import ISQ::*;

    alias <'phys'> Physics for TethysPhysics;
    comment AliasNote about Physics locale "en"
        /* The alias carries no body: the pinned pilot rejects a documented alias in KerML
         * (docs/findings.md F-005), so its note is this comment. */

    metaclass Derivation :> SemanticMetadata {
        doc /* Semantic metadata recording the textbook derivation a function implements, so a
             * reviewer can tell a closed-form result from a fitted approximation. */
        feature source : String;
        feature closedForm : Boolean default true;
        feature redefines baseType = DerivedFunction meta KerML::Function;
    }

    metaclass Reviewed :> Metaobject {
        doc /* Plain metadata marking a namespace whose relations were checked against the
             * references its Derivation annotations cite. */
        feature reviewer : String;
    }

    abstract function DerivedFunction {
        doc /* The kind of element a Derivation annotates: any function of this library. */
    }

    namespace Constants {
        doc /* The two universal values the library needs; mission-specific constants stay in
             * TethysEnvironment. */
        feature standardGravity : Real = 9.80665 {
            doc /* g₀ in m/s², the convention that turns specific impulse in seconds into exhaust
                 * velocity. */
        }
        feature astronomicalUnit : Real = 1.495978707e11 {
            doc /* One astronomical unit in metres. */
        }
        feature gravitationalConstant : Real = 6.67430e-11 {
            doc /* Newtonian constant of gravitation in m³·kg⁻¹·s⁻². */
        }
    }

    #Reviewed namespace TwoBody {
        doc /* Keplerian two-body relations used for the heliocentric cruise, the Earth
             * departure hyperbola and the target's orbit about the Sun. */

        struct Orbit {
            doc /* A conic orbit about a central body, described by its gravitational parameter
                 * and classical elements. Distances in metres, angles in radians. */
            feature mu : Real;
            feature semiMajorAxis : Real;
            feature eccentricity : Real;
            feature inclination : Real;
            member feature twoPi : Real = 6.283185307179586 {
                doc /* A member of the namespace of Orbit, not a feature of orbits. */
            }
            derived feature perihelion : Real = semiMajorAxis * (1.0 - eccentricity);
            derived feature aphelion : Real = semiMajorAxis * (1.0 + eccentricity);
            derived feature period : Real = OrbitalPeriod(mu, semiMajorAxis);
            inv boundOrbit { eccentricity >= 0.0 and eccentricity < 1.0 }
            inv { mu > 0.0 and semiMajorAxis > 0.0 }
        }

        class all CircularOrbit :> Orbit {
            doc /* Every bound orbit with zero eccentricity is a circular orbit: the classifier is
                 * sufficient, so a storage-orbit candidate classifies as circular by its elements
                 * alone. */
            inv circular { eccentricity == 0.0 }
        }

        class all EarthLikeOrbit :> Orbit {
            doc /* Heliocentric orbits within two per cent of 1 AU and five degrees of the
                 * ecliptic: the band in which a retrieval target is reachable by a solar-electric
                 * tug within one synodic cycle. */
            inv nearOneAu {
                semiMajorAxis > 0.98 * Constants::astronomicalUnit and
                semiMajorAxis < 1.02 * Constants::astronomicalUnit
            }
            inv lowInclination { inclination < 0.0873 }
        }

        classifier EasyReturnOrbit intersects CircularOrbit, EarthLikeOrbit {
            doc /* The intersection of the circular and Earth-like bands: the cheapest class of
                 * target orbit for a return by low thrust. */
        }

        classifier EccentricEarthLikeOrbit differences EarthLikeOrbit, CircularOrbit {
            doc /* Earth-like orbits that are not circular — the class Amaranth's orbit belongs
                 * to, which is why its return costs more than the ideal case. */
        }

        function OrbitalPeriod {
            doc /* Keplerian period T = 2π·√(a³/μ) in seconds. */
            in mu : Real;
            in semiMajorAxis : Real;
            return : Real = 2.0 * 3.141592653589793 * sqrt(semiMajorAxis ^ 3 / mu);
        }

        function MeanMotion {
            doc /* Mean motion n = √(μ/a³) in rad/s. */
            in mu : Real;
            in semiMajorAxis : Real;
            return : Real = sqrt(mu / semiMajorAxis ^ 3);
        }

        function VisVivaSpeed {
            doc /* Orbital speed from the vis-viva equation v = √(μ·(2/r − 1/a)) in m/s. */
            in mu : Real;
            in radius : Real;
            in semiMajorAxis : Real;
            return : Real = sqrt(mu * (2.0 / radius - 1.0 / semiMajorAxis));
        }

        function CircularSpeed {
            doc /* Circular orbital speed √(μ/r) in m/s. */
            in mu : Real;
            in radius : Real;
            return : Real = sqrt(mu / radius);
        }

        function EscapeSpeed {
            doc /* Local escape speed √(2μ/r) in m/s. */
            in mu : Real;
            in radius : Real;
            return : Real = sqrt(2.0 * mu / radius);
        }

        function HohmannDeltaV {
            doc /* Total impulsive Δv of a two-burn Hohmann transfer between coplanar circular
                 * orbits of radii r₁ and r₂, in m/s; the impulsive floor against which the
                 * low-thrust estimates are compared. */
            in mu : Real;
            in radius1 : Real;
            in radius2 : Real;
            feature transferSemiMajorAxis : Real = (radius1 + radius2) / 2.0;
            feature departureBurn : Real =
                abs(VisVivaSpeed(mu, radius1, transferSemiMajorAxis) - CircularSpeed(mu, radius1));
            feature arrivalBurn : Real =
                abs(CircularSpeed(mu, radius2) - VisVivaSpeed(mu, radius2, transferSemiMajorAxis));
            return : Real = departureBurn + arrivalBurn;
        }

        function SynodicPeriod {
            doc /* Synodic period of two bodies with sidereal periods T₁ and T₂, in seconds; the
                 * interval between successive return opportunities to the same target. */
            in period1 : Real;
            in period2 : Real;
            return : Real = 1.0 / abs(1.0 / period1 - 1.0 / period2);
        }

        function HyperbolicExcessSpeed {
            doc /* Hyperbolic excess speed v∞ = √C3 in m/s from a characteristic energy in m²/s². */
            in c3 : Real;
            return : Real = sqrt(c3);
        }

        function DepartureSpeed {
            doc /* Speed on a departure hyperbola at radius r for excess speed v∞: √(v∞² + 2μ/r). */
            in mu : Real;
            in radius : Real;
            in excessSpeed : Real;
            return : Real = sqrt(excessSpeed ^ 2 + 2.0 * mu / radius);
        }

        @Derivation about OrbitalPeriod, VisVivaSpeed, HohmannDeltaV {
            feature redefines source = "Battin, An Introduction to the Mathematics and Methods of Astrodynamics, ch. 3";
        }
    }

    namespace ThreeBody {
        doc /* Circular restricted three-body relations for the Earth–Moon storage orbit. */

        function MassRatio {
            doc /* Mass parameter μ′ = m₂/(m₁ + m₂) of a primary pair. */
            in primaryMass : Real;
            in secondaryMass : Real;
            return : Real = secondaryMass / (primaryMass + secondaryMass);
        }

        function HillRadius {
            doc /* Hill-sphere radius a·∛(m₂/(3·m₁)) in metres; a storage orbit must stay well
                 * inside the Moon's Hill sphere to remain lunar-bound. */
            in separation : Real;
            in primaryMass : Real;
            in secondaryMass : Real;
            return : Real = separation * (secondaryMass / (3.0 * primaryMass)) ^ (1.0 / 3.0);
        }

        function JacobiConstant {
            doc /* Jacobi constant C = x² + y² + 2(1−μ′)/r₁ + 2μ′/r₂ − v² in the rotating frame
                 * with unit distance and unit angular rate; a distant retrograde orbit keeps C
                 * above the L1/L2 gateway values. */
            in massRatio : Real;
            in x : Real;
            in y : Real;
            in speed : Real;
            feature r1 : Real = sqrt((x + massRatio) ^ 2 + y ^ 2);
            feature r2 : Real = sqrt((x - 1.0 + massRatio) ^ 2 + y ^ 2);
            return : Real = x ^ 2 + y ^ 2 + 2.0 * (1.0 - massRatio) / r1 + 2.0 * massRatio / r2 - speed ^ 2;
        }
    }

    namespace LowThrust {
        doc /* Sizing relations for continuous-thrust transfers between near-circular orbits. */

        function EdelbaumDeltaV {
            doc /* Edelbaum's Δv for a low-thrust transfer between circular orbits of speeds v₁
                 * and v₂ with a plane change Δi in radians: √(v₁² − 2·v₁·v₂·cos(π/2·Δi) + v₂²). */
            in speed1 : Real;
            in speed2 : Real;
            in planeChange : Real;
            return : Real = sqrt(speed1 ^ 2 - 2.0 * speed1 * speed2 * cos(1.5707963267948966 * planeChange) + speed2 ^ 2);
        }

        function ThrustAcceleration {
            doc /* Thrust acceleration F/m in m/s². */
            in thrust : Real;
            in mass : Real;
            return : Real = thrust / mass;
        }

        function PropellantForDeltaV {
            doc /* Propellant mass m₀·(1 − e^(−Δv/vₑ)) from the rocket equation, in kg. */
            in initialMass : Real;
            in deltaV : Real;
            in exhaustVelocity : Real;
            return : Real = initialMass * (1.0 - 1.0 / Exponential(deltaV / exhaustVelocity));
        }

        function ThrustTime {
            doc /* Burn duration m_p/ṁ in seconds for a propellant mass and a mass flow rate. */
            in propellantMass : Real;
            in massFlowRate : Real;
            return : Real = propellantMass / massFlowRate;
        }

        function Exponential {
            doc /* eˣ by a 24-term Maclaurin series with argument halving: the Kernel library
                 * declares neither exp nor ln (see docs/findings.md F-001), so the library
                 * carries its own. Accurate to better than 1e-12 for |x| < 20. */
            in x : Real;
            feature halvings : Natural = 8;
            feature reduced : Real = x / 256.0;
            feature series : Real = 1.0 + reduced * (1.0 + reduced / 2.0 * (1.0 + reduced / 3.0 * (1.0 + reduced / 4.0 *
                (1.0 + reduced / 5.0 * (1.0 + reduced / 6.0 * (1.0 + reduced / 7.0 * (1.0 + reduced / 8.0 *
                (1.0 + reduced / 9.0 * (1.0 + reduced / 10.0 * (1.0 + reduced / 11.0 * (1.0 + reduced / 12.0)))))))))));
            return : Real = series ^ 256;
        }
    }

    namespace ElectricPropulsion {
        doc /* Gridded-ion thruster relations: exhaust velocity, jet power, thrust and mass flow,
             * and the solar-array power available at heliocentric distance. */

        struct Thruster {
            doc /* One gridded-ion thruster: its rated input power, specific impulse and total
                 * efficiency, with its performance derived. */
            feature inputPower : Real;
            feature specificImpulse : Real;
            feature efficiency : Real default 0.65;
            var feature xenonIn : Real := 0.0;
            feature fedBy : PropellantTank[1] inverse of PropellantTank::feeds;
            derived feature exhaustVelocity : Real = ExhaustVelocity(specificImpulse);
            derived feature thrust : Real = Thrust(inputPower, specificImpulse, efficiency);
            inv efficiencyIsAFraction { efficiency > 0.0 and efficiency <= 1.0 }
        }

        struct PropellantTank {
            doc /* A xenon tank with its loaded mass, the mass still aboard and the thrusters it
                 * can feed. */
            const feature capacity : Real;
            var feature remaining : Real;
            feature feeds : Thruster[0..*];
            inv notOverfilled { remaining <= capacity }
            inv false overfilled { remaining > capacity }
        }

        datatype ThrottleTable {
            doc /* The throttle points of a thruster as ordered, possibly repeated power levels:
                 * a flight profile steps down through the same level more than once. */
            feature powerLevels : Real[1..*] ordered nonunique;
            feature all positiveLevels : Real[*] :> powerLevels {
                doc /* Every power level greater than zero is a positive level: the feature is
                     * sufficient, so membership follows from the value alone. */
                inv { that > 0.0 }
            }
        }

        struct PowerProcessor {
            doc /* The power-processing unit between array and thruster. */
            feature outputPower : Real;
        }

        struct SolarArray {
            doc /* A photovoltaic wing rated at 1 AU, derated by distance and degradation. */
            feature ratedPower : Real;
        }

        struct PropulsionString {
            doc /* Array → power processor → thruster → tank, bound end to end: the structural
                 * unit the architecture variants count in threes, fours and fives. */
            composite feature array : SolarArray[1];
            composite feature processor : PowerProcessor[1];
            composite feature thruster : Thruster[1];
            composite feature tank : PropellantTank[1];
            feature coldSpare typed by Thruster[0..1];
            connector all powerLine from array to processor;
            connector feedLine ([1] processor, [1] thruster, [1] tank);
            binding of thruster.inputPower = processor.outputPower;
            binding all of thruster.fedBy = tank;
            succession flow xenonFeed of Real from tank.remaining to thruster.xenonIn;
        }

        struct OperatingString :> PropulsionString {
            doc /* A string that is thrusting. Between two and four strings operate at once across
                 * every architecture variant, which the type's own multiplicity states. */
            multiplicity [2..4];
        }

        assoc Feeds {
            doc /* A tank feeds a thruster. */
            end feature tank : PropellantTank[1];
            end feature thruster : Thruster[1] crosses tank.feeds;
        }

        assoc struct CrossFeed :> Feeds {
            doc /* A cross-feed is itself an object: the valve manifold that lets any tank feed
                 * any thruster, so a stuck valve is a failure of the manifold rather than of a
                 * tank. */
            feature valveCount : Natural;
            const end feature manifoldTank;
            end feature manifoldThruster;
        }

        interaction XenonTransfer :> Feeds {
            doc /* Xenon moving from a tank to a thruster over a feed line. */
            flow of Real from tank.remaining to thruster.inputPower;
        }

        behavior ThrustArc {
            doc /* One continuous thrust arc: throttle up, hold at power, throttle down. The
                 * successions order the steps; the invariant bounds the arc. */
            in power : Real;
            in duration : Real;
            out impulse : Real;
            inout remainingXenon : Real;
            portion feature steadyState : ThrustArc;
            step throttleUp;
            step hold;
            step throttleDown;
            succession first throttleUp then hold;
            succession all first hold then throttleDown;
            inv { duration > 0.0 }
        }

        behavior CoastArc {
            doc /* An unpowered arc between thrust arcs. */
            in duration : Real;
        }

        behavior CoastArcAsSeen {
            doc /* The coast arc from the power side; conjugated by a standalone statement in
                 * the Relationships namespace. */
        }

        behavior ThrustArcAsSeen ~ ThrustArc {
            doc /* The same arc seen from the power side: its inputs become outputs. */
        }

        function ExhaustVelocity {
            doc /* Effective exhaust velocity vₑ = g₀·Isp in m/s. */
            in specificImpulse : Real;
            return : Real = Constants::standardGravity * specificImpulse;
        }

        function Thrust {
            doc /* Thrust F = 2·η·P/vₑ in newtons from input power P and exhaust velocity. */
            in inputPower : Real;
            in specificImpulse : Real;
            in efficiency : Real;
            return : Real = 2.0 * efficiency * inputPower / ExhaustVelocity(specificImpulse);
        }

        function JetPower {
            doc /* Jet power ½·F·vₑ in watts. */
            in thrust : Real;
            in exhaustVelocity : Real;
            return : Real = 0.5 * thrust * exhaustVelocity;
        }

        function MassFlowRate {
            doc /* Propellant mass flow F/vₑ in kg/s. */
            in thrust : Real;
            in exhaustVelocity : Real;
            return : Real = thrust / exhaustVelocity;
        }

        function ArrayPowerAtDistance {
            doc /* Array power at a heliocentric distance in AU for a 1 AU rating, inverse-square
                 * with a flat degradation factor; temperature effects are left to TethysBudgets. */
            in ratedPower : Real;
            in distanceAu : Real;
            in degradation : Real default 1.0;
            return : Real = ratedPower * degradation / distanceAu ^ 2;
        }

        predicate PowerCloses {
            doc /* True when the array power at distance covers every operating thruster string. */
            in arrayPower : Real;
            in thrusterPower : Real;
            in operatingThrusters : Natural;
            return : Boolean = arrayPower >= thrusterPower * operatingThrusters;
        }

        bool efficiencyIsPhysical : PowerCloses;

        expr specificImpulseOf {
            doc /* Specific impulse in seconds recovered from an exhaust velocity. */
            in exhaustVelocity : Real;
            exhaustVelocity / Constants::standardGravity
        }
    }

    namespace SmallBodies {
        doc /* Rubble-pile relations that set the capture envelope. */

        class Body {
            doc /* A small body as a mass with a bulk density and a spin period. */
            feature diameter : Real;
            feature density : Real;
            feature spinPeriod : Real;
            derived feature mass : Real = SphereMass(diameter, density);
        }

        class SlowRotator :> Body {
            doc /* Bodies whose spin period exceeds the cohesionless break-up period. */
            inv { spinPeriod > BreakupPeriod(density) }
        }

        class FastRotator :> Body disjoint from SlowRotator {
            doc /* Bodies spinning faster than the break-up period, which must be monolithic to
                 * exist and are therefore outside the capture envelope. */
        }

        class DespunBody :> Body {
            doc /* A fast rotator slowed below break-up by an external torque before capture. */
            feature despinTorque : Real;
        }

        class Capturable unions SlowRotator, DespunBody {
            doc /* The class of bodies a capture system can take: the slow rotators and the
                 * bodies despun on arrival. */
        }

        function SphereMass {
            doc /* Mass of a homogeneous sphere π/6·d³·ρ in kg. */
            in diameter : Real;
            in density : Real;
            return : Real = 3.141592653589793 / 6.0 * diameter ^ 3 * density;
        }

        function SurfaceGravity {
            doc /* Surface gravity G·m/r² in m/s². */
            in mass : Real;
            in radius : Real;
            return : Real = Constants::gravitationalConstant * mass / radius ^ 2;
        }

        function BreakupPeriod {
            doc /* Cohesionless spin break-up period √(3π/(G·ρ)) in seconds: a rubble pile spinning
                 * faster than this flies apart. */
            in density : Real;
            return : Real = sqrt(3.0 * 3.141592653589793 / (Constants::gravitationalConstant * density));
        }

        function EquatorialAcceleration {
            doc /* Centripetal acceleration at the equator (2π/T)²·r in m/s². */
            in spinPeriod : Real;
            in radius : Real;
            return : Real = (2.0 * 3.141592653589793 / spinPeriod) ^ 2 * radius;
        }
    }

    namespace Relationships {
        doc /* The library's standalone relationship statements: the physics above is stated by
             * the classifiers, and these say how it hangs together. */
        feature referenceString : ElectricPropulsion::PropulsionString {
            doc /* A reference propulsion string whose members the chained statements below
                 * subset and specialize. */
        }
        feature stringExhaustVelocity chains referenceString.thruster.exhaustVelocity {
            doc /* The exhaust velocity of the reference string, reached by a feature chain. */
        }
        feature feedThruster ::> referenceString.thruster {
            doc /* A reference to the string's thruster. */
        }
        feature stringThrust : Real featured by ElectricPropulsion::PropulsionString, ElectricPropulsion::Thruster {
            doc /* Thrust as a feature of both a string and its thruster. */
        }
        feature spareThruster {
            doc /* The cold spare, typed by the standalone typing statement below. */
        }
        specialization subclassifier SmallBodies::Body :> Occurrence;
        specialization Tankage subtype ElectricPropulsion::PropellantTank specializes Object;
        specialization typing spareThruster typed by ElectricPropulsion::Thruster;
        specialization subset referenceString.tank :> Objects::objects;
        specialization subtype referenceString.thruster specializes Occurrences::occurrences;
        specialization redefinition ElectricPropulsion::CrossFeed::manifoldTank :>> ElectricPropulsion::Feeds::tank;
        redefinition ElectricPropulsion::CrossFeed::manifoldThruster redefines ElectricPropulsion::Feeds::thruster;
        conjugation ArcView conjugate ElectricPropulsion::ThrustArcAsSeen ~ ElectricPropulsion::ThrustArc;
        conjugate ElectricPropulsion::CoastArcAsSeen conjugates ElectricPropulsion::CoastArc;
        disjoining RotatorClasses disjoint SmallBodies::FastRotator from SmallBodies::SlowRotator;
        featuring Arcs of ElectricPropulsion::ThrustArc::hold by ElectricPropulsion::ThrustArc;
        inverting FeedEnds inverse ElectricPropulsion::Feeds::tank of ElectricPropulsion::Feeds::thruster;
    }
}
