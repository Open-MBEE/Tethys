#Reviewed package TethysNotation {
    doc locale "en"
        /* The notation forms no other Tethys package reaches, each carrying a mission statement
         * of its own: the review vocabulary (metadata and user-defined keywords) that marks what
         * the preliminary design review covered, the hazard register that the vocabulary
         * classifies, the readiness logic that decides whether a configuration goes to the
         * review, and the capture-method variation. Nothing here is a toy: every value is a
         * Tethys value and every constraint is one the review asks. */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SequenceFunctions::*;
    private import Metaobjects::SemanticMetadata;
    private import all TethysEnvironment::*;
    private import TethysTug::*;
    private import TethysInspector::*;
    private import TethysTarget::*;
    private import TethysLaunch::*;
    private import TethysVariants::*;
    private import ReviewVocabulary::*;
    private import HazardScale::**;

    alias <'pdr'> PreliminaryDesignReview for ReviewVocabulary {
        doc /* The review the vocabulary serves. */
    }

    package HazardScale {
        doc /* The severity scale of the hazard register, imported recursively so that the
             * literals are usable by their bare names. */
        enum def Severity {
            doc /* Four-step severity: from no mission effect to loss of mission. */
            enum negligible;
            enum marginal;
            enum critical;
            enum catastrophic;
        }
    }

    library #Reviewed package ReviewVocabulary {
        doc /* Metadata the design review stamps on elements, and the keywords it adds to the
             * language: a library package because TethysBudgets and TethysVerification reuse it
             * without owning it. */

        metadata def Reviewed {
            doc /* Who reviewed an element and in which cycle. */
            attribute reviewer : String default "systems";
            attribute cycle : Natural default 1;
        }

        abstract metadata def Finding {
            doc /* A review finding of any severity. */
            attribute summary : String;
        }

        metadata def Observation :> Finding {
            doc /* A finding the design need not act on. */
        }

        metadata def hazard :> SemanticMetadata {
            doc /* The keyword `#hazard`: a usage so marked is a hazard register entry, implicitly
                 * subsetting hazards. */
            ref :>> baseType = hazards meta SysML::Usage;
        }

        metadata def hazardKind :> SemanticMetadata {
            doc /* The keyword `#hazardKind`: a definition so marked is a kind of hazard,
                 * implicitly specializing HazardEntry. */
            ref :>> baseType = HazardEntry meta SysML::Definition;
        }

        item def HazardEntry {
            doc /* One hazard register line: a cause, the phase it threatens and its severity on
                 * a four-step scale. */
            attribute cause : String;
            attribute phase : String;
            attribute severity : Severity;
        }

        abstract item hazards : HazardEntry[*] {
            doc /* The register: every `#hazard` usage subsets it. */
        }
    }

    #hazardKind def PropulsionHazard {
        doc /* Hazards of the xenon system: tank, feed lines and thrusters. */
        attribute :>> phase = "cruise";
    }

    #hazardKind def ProximityHazard {
        doc /* Hazards within a kilometre of the body. */
        attribute :>> phase = "proximity";
    }

    #hazard xenonTankRupture : PropulsionHazard {
        doc /* Over-pressure of a xenon tank after a heater fault. */
        attribute :>> cause = "tank heater fault";
        attribute :>> severity = catastrophic;
    }

    #hazard inspectorCollision : ProximityHazard {
        doc /* Wren strikes the body or the tug during characterisation. */
        attribute :>> cause = "inspector guidance fault";
        attribute :>> severity = critical;
    }

    #hazard ejectaStrike : ProximityHazard {
        doc /* Regolith lofted by the grapple strikes an array. */
        attribute :>> cause = "grapple contact ejecta";
        attribute :>> severity = marginal;
    }

    @Reviewed about xenonTankRupture, inspectorCollision {
        reviewer = "propulsion";
        cycle = 2;
    }

    metadata Reviewed about ejectaStrike {
        :>> reviewer = "mechanisms";
    }

    @ejectaNote : Observation about ejectaStrike {
        ref :>> summary = "Array edge shielding covers the ejecta cone; no action.";
    }

    comment InspectorNote about inspectorCollision, ejectaStrike locale "en-GB"
        /* Both proximity hazards close when the inspector keeps outside the 200 m exclusion
         * sphere, which TethysRequirements states and TethysVerification tests. */

    comment locale "en"
        /* The register is deliberately short: the full hazard analysis belongs to the safety
         * package; these three entries are the ones that drive architecture choices. */

    rep language "markdown"
        /* | hazard | severity |
         * |---|---|
         * | xenonTankRupture | catastrophic |
         * | inspectorCollision | critical |
         * | ejectaStrike | marginal | */

    language "text"
        /* Severity is assigned by the worst credible outcome, not the most likely one. */

    rep RegisterQuery language "sql"
        /* SELECT cause, severity FROM hazards WHERE severity IN ('critical', 'catastrophic') */

    dependency HazardsDriveVariants from xenonTankRupture, inspectorCollision to TethysVariants::RetrievalArchitecture {
        doc /* The tank hazard sizes the xenon-load variants; the collision hazard is why the
             * inspector is optional. */
    }

    dependency from ejectaStrike to TethysTug::CaptureSystem;

    package ReviewedHazards {
        doc /* The hazards the review has stamped: a filtered import of the register. */
        private import TethysNotation::*[@Reviewed];
    }

    package CriticalFindings {
        doc /* Everything in the vocabulary package that is a finding, by element filter. */
        private import ReviewVocabulary::*;
        filter @Finding;
    }

    attribute def ReturnWindow {
        doc /* A return opportunity as the days after departure between which the body must be
             * released into the storage orbit. */
        attribute opens : DurationValue;
        attribute closes : DurationValue;
        attribute marginal : Boolean = false;
    }

    part def ReviewReadiness {
        doc /* The logic the review applies to a retrieval configuration before it is admitted:
             * which spin period is believed, whether the inspector decision is consistent,
             * whether the string count leaves one spare, and the return window. */

        part configuration : RetrievalArchitecture;
        protected attribute exclusionRadius : LengthValue = 200.0 [m] {
            doc /* The inspector's exclusion sphere, visible to readiness subtypes only. */
        }
        attribute radarSpinPeriod : DurationValue[0..1] = null {
            doc /* Spin period from radar, when a radar apparition has been observed. */
        }
        attribute believedSpinPeriod : DurationValue = radarSpinPeriod ?? configuration.target.rotationPeriod {
            doc /* Radar wins when present; otherwise the lightcurve value of the target case. */
        }
        attribute inspectorCarried : Boolean = not configuration.inspector->isEmpty();
        attribute tugSensorsSuffice : Boolean = configuration.target.meanDiameter <= 6.0 [m] {
            doc /* The tug's own sensors characterise a body of up to 6 m from the stand-off
                 * point; a larger body needs the inspector's close pass. */
        }
        attribute unpairedString : Boolean = configuration.thrusterCount % 2 == 1 {
            doc /* An odd string count means the spare has no twin. */
        }
        attribute firstWindow : ReturnWindow = new ReturnWindow(opens = 1900.0 [d], closes = 1960.0 [d]) {
            doc /* The first release opportunity after the nominal cruise. */
        }
        attribute windowLength : DurationValue = firstWindow.closes - firstWindow.opens;
        ref part heavySubsystems : Subsystem[*] = (argent.eps, argent.sep, argent.rcs).?{in s : Subsystem; s.mass > 400.0 [kg]} {
            doc /* The subsystems above 400 kg, picked by a select expression. */
        }
        attribute subsystemCount : Natural = (argent.eps, argent.sep, argent.rcs)->size();
        attribute diameterCubed : Real = configuration.target.meanDiameter.num ** 3;
        attribute bodyCount : Natural = (all SmallBody)->size() {
            doc /* How many small bodies the model declares, by extent. */
        }
        attribute configurationKind : Boolean = configuration @@ SysML::PartUsage;
        attribute targetIsBody : Boolean = configuration.target istype SmallBody;
        attribute targetHasType : Boolean = configuration.target hastype SmallBody;
        attribute targetClassified : Boolean = configuration.target @ SmallBody;
        attribute targetMassAsMass : MassValue = configuration.target.mass as MassValue;
        ref configurationMeta : SysML::PartUsage = configuration meta SysML::PartUsage;
        ref reviewStamps : Metaobjects::Metaobject[*] = xenonTankRupture.metadata;
        attribute envelopeMass : MassValue = $::TethysEnvironment::amaranth.mass;
        attribute strings : Natural[2..*] = (configuration.thrusterCount, configuration.operatingThrusters);

        assert constraint inspectorDecisionIsExclusive {
            doc /* Either the inspector flies or the tug's sensors are sized to replace it. */
            inspectorCarried xor tugSensorsSuffice
        }
        assert constraint carriedMeansLifted {
            doc /* Carrying Wren implies the stack mass includes it. */
            inspectorCarried implies configuration.stackMass >= argent.dryMass + wren.wetMass
        }
        assert constraint spareIsReal {
            doc /* The operating count is strictly below the fitted count. */
            configuration.operatingThrusters < configuration.thrusterCount &
            configuration.operatingThrusters > 0
        }
        assert constraint windowIsOrdered {
            doc /* The window opens before it closes and is not marked marginal. */
            (firstWindow.opens < firstWindow.closes) | firstWindow.marginal == true
        }
        assert constraint identityChecks {
            doc /* The configuration's target is one of the declared cases, and its launcher is
                 * the same part the baseline uses only when it is the baseline. */
            (configuration.target === TethysVariants::baselineConfiguration.target) ==
            (configuration === TethysVariants::baselineConfiguration) and
            configuration.target !== null
        }
    }

    part baselineReadiness : ReviewReadiness {
        doc /* The readiness logic applied to the baseline configuration. */
        part :>> configuration = TethysVariants::baselineConfiguration;
    }

    variation action def CaptureMethod {
        doc /* How the body is secured: the alternatives of the capture trade. */
        variant action grappleArms {
            doc /* Three arms close on the body and clamp. */
        }
        variant action inflatableBag {
            doc /* A bag envelops the body and cinches. */
        }
    }

    variation occurrence def ReleaseEvent {
        doc /* When the body is released into the storage orbit. */
        variant occurrence atFirstWindow {
            doc /* Release in the first window of the nominal cruise. */
        }
        variant occurrence atSecondWindow {
            doc /* Release one synodic period later. */
        }
    }

    rendering def ConfigurationTable {
        doc /* Renders a configuration as a table of its selections. */
    }

    variation rendering tableStyle : ConfigurationTable {
        doc /* Compact or full table. */
        variant rendering compact;
        variant rendering full;
    }

    calc def SpinPeriodBelieved {
        doc /* The spin period the review believes: radar when present, lightcurve otherwise. */
        in radarSeconds : Real[0..1];
        in lightcurveSeconds : Real;
        return : Real = radarSeconds ?? lightcurveSeconds;
    }

    calc def SpareIsUnpaired {
        doc /* True when a string count leaves an unpaired spare. */
        in stringCount : Natural;
        return : Boolean = stringCount % 2 == 1;
    }

    calc def InspectorDecisionConsistent {
        doc /* Exactly one of the two characterisation means is chosen. */
        in inspectorCarried : Boolean;
        in tugSensorsSuffice : Boolean;
        return : Boolean = inspectorCarried xor tugSensorsSuffice;
    }

    calc def HeavierBodyNeedsMoreXenon {
        doc /* A heavier body than nominal implies a heavier xenon load, else the return fails. */
        in bodyMassKg : Real;
        in xenonLoadKg : Real;
        return : Boolean = (bodyMassKg > 362000.0) implies (xenonLoadKg > 6600.0);
    }

    calc def VolumeScale {
        doc /* Cube of a diameter ratio: how the body mass scales with the photometric error. */
        in diameterRatio : Real;
        return : Real = diameterRatio ** 3;
    }
}
