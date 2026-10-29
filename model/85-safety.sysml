package TethysSafety {
    doc /* Safety and dependability of the Tethys asteroid-retrieval mission: the hazard list
         * with its controls, the Earth-impact exclusion case, FMECA rows for solar-electric
         * propulsion, capture and proximity operations, fault trees expressed with the
         * standard CauseAndEffect library, the critical-items list, reliability budget hooks
         * for the budgets package, and the end-of-life, contamination and ground-safety
         * records. Every number is fictional and sized from the Phase B tug and target. */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import CauseAndEffect::*;
    private import TethysTug::*;
    private import TethysInspector::*;
    private import TethysMission::*;
    private import TethysTarget::targetCases;
    private import TethysRequirements::*;
    private import VerificationCases::*;
    private import ModelingMetadata::*;
    private import RequirementDerivation::*;

    // ---------------------------------------------------------------- vocabulary

    enum def Severity {
        doc /* Severity of the worst credible effect, highest first. Catastrophic: loss of life
             * or of the mission; critical: loss of the primary objective; major: loss of a
             * secondary objective or large degradation; minor: degraded performance;
             * negligible: no mission effect. */
        catastrophic; critical; major; minor; negligible;
    }

    enum def DetectionMeans {
        doc /* How a failure mode becomes visible to the flight software or the operators. */
        telemetryLimit; builtInTest; navigationResidual; groundTrending; undetected;
    }

    enum def ControlStatus {
        doc /* Life-cycle status of a hazard control or FMECA compensating provision. */
        proposed; baselined; verified;
    }

    metadata def SafetyCritical {
        doc /* Marks software or a function whose failure could cause a catastrophic or critical
             * hazard; the marked element follows the safety-critical software process. */
        attribute rationale : String;
    }

    metadata def CriticalItem {
        doc /* Marks a single-point-failure item retained on the critical-items list, with the
             * retention rationale and whether a waiver was granted. */
        attribute rationale : String;
        attribute waived : Boolean;
    }

    // ---------------------------------------------------------------- hazard analysis (SE-171)

    occurrence def HazardControl {
        doc /* A design feature, procedure or inhibit that eliminates or reduces a hazard, with
             * the requirement it is written as and the status of its verification. */
        attribute status : ControlStatus;
        attribute evidence : String;
        ref requirement controlRequirement : SystemRequirement [0..1] {
            doc /* The requirement this control is written as, when it has one. */
        }
    }

    occurrence def Hazard {
        doc /* A hazard: a condition that could lead to a mishap. Causes and effects are modelled
             * as CauseAndEffect occurrences so the hazard log and the fault trees share one
             * vocabulary; severity is the worst credible effect before controls. */
        attribute severity : Severity;
        attribute severityAfterControls : Severity;
        ref occurrence phase : MissionPhase [1..*];
        occurrence controls : HazardControl [1..*];
    }

    requirement def SafetyControlRequirement :> SystemRequirement {
        doc /* A system requirement that is also a hazard control; derived from the hazard log. */
    }

    requirement <'TS-801'> earthMissDistance : SafetyControlRequirement {
        doc /* The return trajectory shall be designed so that an uncontrolled target, following
             * loss of all thrust at any point of the return cruise, passes Earth with a perigee
             * radius of at least 60 000 km until the final lunar gravity-assist targeting arc. */
        attribute minimumPerigee : LengthValue;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::qualification; }
        @original;
        require constraint { minimumPerigee >= 60000.0 [km] }
    }

    requirement <'TS-802'> finalTargetingAuthority : SafetyControlRequirement {
        doc /* The final lunar gravity-assist targeting manoeuvre shall be executed only on a
             * ground-enabled command issued after the flight dynamics facility has confirmed the
             * post-manoeuvre trajectory misses Earth under the 3-sigma dispersion ellipse. */
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::system; stage = VerificationStage::acceptance; }
        @original;
    }

    requirement <'TS-803'> captureAbortAuthority : SafetyControlRequirement {
        doc /* The capture sequence shall be abortable autonomously up to the capture-commit event,
             * returning the tug to a station-keeping point at least 500 m from the target. */
        attribute abortStandoff : LengthValue;
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @original;
        require constraint { abortStandoff >= 500.0 [m] }
    }

    requirement <'TS-804'> captureEnvelopeMargin : SafetyControlRequirement {
        doc /* The capture bag shall accept a body up to 1.3 times the largest diameter in the
             * target characterisation envelope (the large-target case) so that a mis-sized target
             * is excluded by the inspector survey before capture commit, not by the bag. */
        attribute envelopeFactor : Real;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
        @original;
        require constraint { envelopeFactor >= 1.3 }
    }

    requirement <'TS-805'> despinContinuation : SafetyControlRequirement {
        doc /* Despin shall be completed with the reaction-control propellant remaining after a
             * capture at the large-target spin case, with a 25 percent propellant reserve. */
        attribute reserveFraction : Real;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @original;
        require constraint { reserveFraction >= 0.25 }
    }

    requirement <'TS-806'> disposalOrbit : SafetyControlRequirement {
        doc /* After release of the captured body in its distant retrograde orbit the tug shall
             * execute a disposal burn to a heliocentric orbit with no Earth or Moon encounter
             * within 100 years. */
        attribute encounterFreeHorizon : DurationValue;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::qualification; }
        @original;
        require constraint { encounterFreeHorizon >= 36525.0 [d] }
    }

    requirement <'TS-807'> highVoltageInhibit : SafetyControlRequirement {
        doc /* Power-processing-unit high voltage shall be inhibited by two independent inhibits
             * until separation from the launcher plus 600 s. */
        attribute inhibitHold : DurationValue;
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::acceptance; }
        @original;
        require constraint { inhibitHold >= 600.0 [s] }
    }

    requirement <'TS-808'> ejectaKeepOut : SafetyControlRequirement {
        doc /* No thruster plume shall impinge on the target surface at less than 50 m range
             * before the bag is closed, to limit ejecta onto optics and radiators. */
        attribute plumeKeepOut : LengthValue;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @original;
        require constraint { plumeKeepOut >= 50.0 [m] }
    }

    occurrence hazardLog {
        doc /* The hazard log. Identifiers TH-nnn; one occurrence per hazard, with its causes
             * and effects as cause/effect occurrences and its controls. */

        occurrence <'TH-001'> earthImpactByTarget : Hazard {
            doc /* The returned body is placed on an Earth-impact trajectory. The one catastrophic
                 * hazard of the mission: a 362 t body (506 t in the large case) at 12 km/s is far above the airburst
                 * threshold. Controlled by trajectory design (TS-801), ground authority over the
                 * final targeting (TS-802) and the fault tree earthImpactTree. */
            attribute :>> severity = Severity::catastrophic;
            attribute :>> severityAfterControls = Severity::catastrophic;
            ref :>> phase ::> flightTimeline.returnCruise;
            #cause event occurrence returnTrajectoryInsideCorridor;
            #cause event occurrence lossOfThrustOnFinalArc;
            #cause event occurrence erroneousFinalTargeting;
            #effect event occurrence earthImpact;
            occurrence :>> controls {
                occurrence trajectoryBias : HazardControl {
                    attribute :>> status = ControlStatus::baselined;
                    attribute :>> evidence = "trajectory dispersion analysis";
                    ref :>> controlRequirement ::> earthMissDistance;
                }
                occurrence groundAuthority : HazardControl {
                    attribute :>> status = ControlStatus::baselined;
                    attribute :>> evidence = "command-path demonstration";
                    ref :>> controlRequirement ::> finalTargetingAuthority;
                }
            }
        }

        occurrence <'TH-002'> tugTargetCollision : Hazard {
            doc /* The tug collides with the target during proximity operations, breaching the
                 * structure or the xenon tank. */
            attribute :>> severity = Severity::critical;
            attribute :>> severityAfterControls = Severity::major;
            ref :>> phase = (flightTimeline.approachAndRendezvous, flightTimeline.capture);
            #cause event occurrence relativeNavigationLoss;
            #cause event occurrence thrusterStuckOpen;
            #effect event occurrence structuralBreach;
            occurrence :>> controls {
                occurrence autonomousAbort : HazardControl {
                    attribute :>> status = ControlStatus::baselined;
                    attribute :>> evidence = "closed-loop capture test";
                    ref :>> controlRequirement ::> captureAbortAuthority;
                }
            }
        }

        occurrence <'TH-003'> overEnvelopeTarget : Hazard {
            doc /* The target is larger or heavier than the capture bag can hold, tearing the bag
                 * or exceeding the structural load path at despin. Target size is the design
                 * driver: the small, nominal and large cases are evaluated in envelopeMargin. */
            attribute :>> severity = Severity::critical;
            attribute :>> severityAfterControls = Severity::minor;
            ref :>> phase ::> flightTimeline.capture;
            #cause event occurrence targetLargerThanSurveyed;
            #effect event occurrence bagTear;
            occurrence :>> controls {
                occurrence envelopeMargin : HazardControl {
                    attribute :>> status = ControlStatus::baselined;
                    attribute :>> evidence = "inspector survey before commit";
                    ref :>> controlRequirement ::> captureEnvelopeMargin;
                }
            }
        }

        occurrence <'TH-004'> uncontrolledTumble : Hazard {
            doc /* The captured body's spin cannot be removed, leaving the stack tumbling with the
                 * arrays unable to track the Sun. */
            attribute :>> severity = Severity::critical;
            attribute :>> severityAfterControls = Severity::major;
            ref :>> phase ::> flightTimeline.capture;
            #cause event occurrence despinPropellantExhausted;
            #cause event occurrence excessiveTargetSpin;
            #effect event occurrence powerStarvation;
            occurrence :>> controls {
                occurrence propellantReserve : HazardControl {
                    attribute :>> status = ControlStatus::proposed;
                    attribute :>> evidence = "despin propellant analysis";
                    ref :>> controlRequirement ::> despinContinuation;
                }
            }
        }

        occurrence <'TH-005'> derelictTug : Hazard {
            doc /* The tug remains in cislunar space after release as an uncontrolled object. */
            attribute :>> severity = Severity::major;
            attribute :>> severityAfterControls = Severity::minor;
            ref :>> phase ::> flightTimeline.disposal;
            #cause event occurrence disposalBurnMissed;
            #effect event occurrence derelictInCislunarSpace;
            occurrence :>> controls {
                occurrence disposalBurn : HazardControl {
                    attribute :>> status = ControlStatus::baselined;
                    attribute :>> evidence = "disposal trajectory analysis";
                    ref :>> controlRequirement ::> disposalOrbit;
                }
            }
        }

        occurrence <'TH-006'> prematureHighVoltage : Hazard {
            doc /* Power-processing high voltage comes up before launcher separation, arcing in the
                 * fairing's residual atmosphere. */
            attribute :>> severity = Severity::critical;
            attribute :>> severityAfterControls = Severity::negligible;
            ref :>> phase ::> flightTimeline.launchAndEarlyOperations;
            #cause event occurrence inhibitFailure;
            #effect event occurrence coronaArc;
            occurrence :>> controls {
                occurrence twoInhibits : HazardControl {
                    attribute :>> status = ControlStatus::verified;
                    attribute :>> evidence = "inhibit test at acceptance";
                    ref :>> controlRequirement ::> highVoltageInhibit;
                }
            }
        }

        occurrence <'TH-007'> ejectaContamination : Hazard {
            doc /* Plume-lofted regolith contaminates optics, radiators and the inspector. */
            attribute :>> severity = Severity::major;
            attribute :>> severityAfterControls = Severity::minor;
            ref :>> phase ::> flightTimeline.capture;
            #cause event occurrence plumeImpingement;
            #effect event occurrence opticsDegraded;
            occurrence :>> controls {
                occurrence keepOut : HazardControl {
                    attribute :>> status = ControlStatus::baselined;
                    attribute :>> evidence = "plume impingement analysis";
                    ref :>> controlRequirement ::> ejectaKeepOut;
                }
            }
        }

        #causation connect earthImpactByTarget.returnTrajectoryInsideCorridor to earthImpactByTarget.earthImpact;
        #causation connect earthImpactByTarget.lossOfThrustOnFinalArc to earthImpactByTarget.earthImpact;
        #causation connect earthImpactByTarget.erroneousFinalTargeting to earthImpactByTarget.earthImpact;
        #causation connect tugTargetCollision.relativeNavigationLoss to tugTargetCollision.structuralBreach;
        #causation connect tugTargetCollision.thrusterStuckOpen to tugTargetCollision.structuralBreach;
        #causation connect overEnvelopeTarget.targetLargerThanSurveyed to overEnvelopeTarget.bagTear;
        #causation connect uncontrolledTumble.despinPropellantExhausted to uncontrolledTumble.powerStarvation;
        #causation connect uncontrolledTumble.excessiveTargetSpin to uncontrolledTumble.powerStarvation;
        #causation connect derelictTug.disposalBurnMissed to derelictTug.derelictInCislunarSpace;
        #causation connect prematureHighVoltage.inhibitFailure to prematureHighVoltage.coronaArc;
        #causation connect ejectaContamination.plumeImpingement to ejectaContamination.opticsDegraded;
    }

    calc def EnvelopeMargin {
        doc /* Capture-envelope margin for a target of the given diameter: the fraction of the
             * bag's maximum body diameter left over. Negative means the body does not fit. */
        in maximumBodyDiameterM : Real;
        in targetDiameterM : Real;
        return : Real = (maximumBodyDiameterM - targetDiameterM) / maximumBodyDiameterM;
    }

    part envelopeCases {
        doc /* The small, nominal and large design cases of TethysTarget::targetCases against
             * Argent's bag; the large case (7.6 m) is the characterisation envelope's upper bound
             * TS-804 sizes the bag from, 1.3 times which is the 10 m bag. */
        attribute maximumBodyDiameter : LengthValue = argent.captureSystem.maximumBodyDiameter;
        attribute smallTargetDiameter : LengthValue = targetCases.small.meanDiameter;
        attribute nominalTargetDiameter : LengthValue = targetCases.nominal.meanDiameter;
        attribute largeTargetDiameter : LengthValue = targetCases.large.meanDiameter;
        attribute smallMargin : Real = EnvelopeMargin(maximumBodyDiameter / (1 [m]), smallTargetDiameter / (1 [m]));
        attribute nominalMargin : Real = EnvelopeMargin(maximumBodyDiameter / (1 [m]), nominalTargetDiameter / (1 [m]));
        attribute largeMargin : Real = EnvelopeMargin(maximumBodyDiameter / (1 [m]), largeTargetDiameter / (1 [m]));
        attribute largeCaseFactor : Real = (maximumBodyDiameter / (1 [m])) / (largeTargetDiameter / (1 [m]));
        assert constraint largeCaseFits { largeMargin >= 0.0 }
        assert constraint largeCaseFactorMet {
            doc /* TS-804: the bag takes 1.3 times the large case's diameter. */
            largeCaseFactor >= 1.3
        }
    }

    // ---------------------------------------------------------------- FMECA (SE-172, SE-174, SE-177)

    occurrence def FailureMode {
        doc /* One FMECA row: the item, the function it loses, the failure mode, its cause, local
             * and end effects, how it is detected, the compensating provision, severity and the
             * criticality derived from severity and failure probability over the exposure time. */
        ref part failedItem : Subsystem;
        attribute lostFunction : String;
        attribute mode : String;
        attribute cause : String;
        attribute localEffect : String;
        attribute endEffect : String;
        attribute detection : DetectionMeans;
        attribute compensatingProvision : String;
        attribute severity : Severity;
        attribute meanTimeToFailure : DurationValue;
        attribute exposure : DurationValue;
        attribute failureProbability : Real = FailureProbability(meanTimeToFailure / exposure);
        attribute singlePointFailure : Boolean;
        ref occurrence propagatesAcross : Hazard [0..*];
    }

    calc def Exp {
        doc /* e^x by its Maclaurin series truncated after x^8/8!. The Kernel Function Library has
             * no exponential (see docs/findings.md F-001), so the reliability calculations carry
             * their own; for |x| ≤ 1 the truncation error is below 3 × 10⁻⁶. */
        in x : Real;
        attribute x2 : Real = x * x;
        attribute x4 : Real = x2 * x2;
        return : Real = 1.0 + x + x2 / 2.0 + x2 * x / 6.0 + x4 / 24.0 + x4 * x / 120.0
            + x4 * x2 / 720.0 + x4 * x2 * x / 5040.0 + x4 * x4 / 40320.0;
    }

    calc def Reliability {
        doc /* Constant-failure-rate reliability R = e^(−t/MTTF) for exposure t and mean time to
             * failure MTTF, both in the same unit; the hook the budgets package rolls up. */
        in mttfOverExposure : Real;
        return : Real = Exp(-1.0 / mttfOverExposure);
    }

    calc def FailureProbability {
        doc /* Probability of at least one failure over the exposure: 1 − R. */
        in mttfOverExposure : Real;
        return : Real = 1.0 - Reliability(mttfOverExposure);
    }

    calc def SeriesReliability {
        doc /* Reliability of a series string of three items: the product of their reliabilities. */
        in r1 : Real;
        in r2 : Real;
        in r3 : Real;
        return : Real = r1 * r2 * r3;
    }

    calc def KOutOfNReliability3of4 {
        doc /* Reliability of a three-out-of-four active-redundant set of identical items with
             * reliability r: r⁴ + 4 r³ (1 − r). Used for the four-thruster, three-operating SEP. */
        in r : Real;
        attribute r3 : Real = r * r * r;
        return : Real = r3 * r + 4.0 * r3 * (1.0 - r);
    }

    occurrence fmeca {
        doc /* The FMECA, one row per failure mode, for the three subsystems that carry the
             * mission's critical functions: solar-electric propulsion, capture, and proximity
             * operations (relative navigation and reaction control). Exposure is the nominal
             * mission for SEP and the capture phase for the others. */
        attribute missionExposure : DurationValue = 2200.0 [d];
        attribute captureExposure : DurationValue = 30.0 [d];

        occurrence <'FM-SEP-01'> thrusterFlameout : FailureMode {
            doc /* One Hall thruster stops producing thrust; the fourth thruster is brought up. */
            ref :>> failedItem ::> argent.sep;
            attribute :>> lostFunction = "produce heliocentric thrust";
            attribute :>> mode = "thruster flameout, no restart";
            attribute :>> cause = "cathode heater open or keeper erosion";
            attribute :>> localEffect = "thrust drops by one third";
            attribute :>> endEffect = "none while a spare thruster remains";
            attribute :>> detection = DetectionMeans::telemetryLimit;
            attribute :>> compensatingProvision = "four thrusters, three operating";
            attribute :>> severity = Severity::minor;
            attribute :>> meanTimeToFailure = 40000.0 [h];
            attribute :>> exposure = missionExposure;
            attribute :>> singlePointFailure = false;
        }
        occurrence <'FM-SEP-02'> ppuHighVoltageFault : FailureMode {
            doc /* A power processing unit loses its high-voltage output. */
            ref :>> failedItem ::> argent.sep;
            attribute :>> lostFunction = "condition array power for a thruster";
            attribute :>> mode = "PPU high-voltage output lost";
            attribute :>> cause = "output stage short";
            attribute :>> localEffect = "thruster on that PPU unusable";
            attribute :>> endEffect = "cross-strapped PPU takes over";
            attribute :>> detection = DetectionMeans::builtInTest;
            attribute :>> compensatingProvision = "PPU cross-strapping";
            attribute :>> severity = Severity::minor;
            attribute :>> meanTimeToFailure = 60000.0 [h];
            attribute :>> exposure = missionExposure;
            attribute :>> singlePointFailure = false;
        }
        occurrence <'FM-SEP-03'> xenonRegulatorFailure : FailureMode {
            doc /* The xenon pressure regulator fails closed; one regulator feeds all thrusters. */
            ref :>> failedItem ::> argent.sep;
            attribute :>> lostFunction = "feed xenon to all thrusters";
            attribute :>> mode = "regulator fails closed";
            attribute :>> cause = "contamination of the regulator seat";
            attribute :>> localEffect = "no xenon flow";
            attribute :>> endEffect = "loss of all SEP thrust; mission lost if during return";
            attribute :>> detection = DetectionMeans::telemetryLimit;
            attribute :>> compensatingProvision = "redundant regulator in a parallel leg";
            attribute :>> severity = Severity::catastrophic;
            attribute :>> meanTimeToFailure = 500000.0 [h];
            attribute :>> exposure = missionExposure;
            attribute :>> singlePointFailure = false;
            ref :>> propagatesAcross ::> hazardLog.earthImpactByTarget;
        }
        occurrence <'FM-SEP-04'> gimbalStuck : FailureMode {
            doc /* A thruster gimbal seizes, leaving a thrust vector offset the others must trim. */
            ref :>> failedItem ::> argent.sep;
            attribute :>> lostFunction = "point the thrust vector through the centre of mass";
            attribute :>> mode = "gimbal seized";
            attribute :>> cause = "actuator bearing failure";
            attribute :>> localEffect = "fixed thrust offset";
            attribute :>> endEffect = "reduced thrust efficiency, wheel desaturation load";
            attribute :>> detection = DetectionMeans::navigationResidual;
            attribute :>> compensatingProvision = "trim with the remaining gimbals";
            attribute :>> severity = Severity::major;
            attribute :>> meanTimeToFailure = 120000.0 [h];
            attribute :>> exposure = missionExposure;
            attribute :>> singlePointFailure = false;
        }
        occurrence <'FM-CAP-01'> bagInflationFailure : FailureMode {
            doc /* The capture bag does not inflate or deploy. */
            ref :>> failedItem ::> argent.captureSystem;
            attribute :>> lostFunction = "enclose the target";
            attribute :>> mode = "bag fails to deploy";
            attribute :>> cause = "boom deployment latch jammed";
            attribute :>> localEffect = "no capture envelope";
            attribute :>> endEffect = "primary objective lost";
            attribute :>> detection = DetectionMeans::builtInTest;
            attribute :>> compensatingProvision = "redundant release actuators per boom";
            attribute :>> severity = Severity::critical;
            attribute :>> meanTimeToFailure = 200000.0 [h];
            attribute :>> exposure = captureExposure;
            attribute :>> singlePointFailure = true;
        }
        occurrence <'FM-CAP-02'> cinchLineFailure : FailureMode {
            doc /* A cinching line parts under load and the body slips in the bag. */
            ref :>> failedItem ::> argent.captureSystem;
            attribute :>> lostFunction = "hold the target rigidly";
            attribute :>> mode = "cinch line parts";
            attribute :>> cause = "abrasion by regolith";
            attribute :>> localEffect = "body free to shift";
            attribute :>> endEffect = "centre of mass moves; thrust vector trim lost";
            attribute :>> detection = DetectionMeans::navigationResidual;
            attribute :>> compensatingProvision = "six lines, four needed";
            attribute :>> severity = Severity::major;
            attribute :>> meanTimeToFailure = 80000.0 [h];
            attribute :>> exposure = captureExposure;
            attribute :>> singlePointFailure = false;
        }
        occurrence <'FM-CAP-03'> targetOverEnvelope : FailureMode {
            doc /* The body exceeds the bag envelope at contact (target-uncertainty case). */
            ref :>> failedItem ::> argent.captureSystem;
            attribute :>> lostFunction = "enclose the target";
            attribute :>> mode = "body does not fit the bag";
            attribute :>> cause = "characterisation underestimated the diameter";
            attribute :>> localEffect = "bag tears at the rim";
            attribute :>> endEffect = "capture aborted; primary objective lost";
            attribute :>> detection = DetectionMeans::groundTrending;
            attribute :>> compensatingProvision = "inspector survey, envelope factor 1.3";
            attribute :>> severity = Severity::critical;
            attribute :>> meanTimeToFailure = 300000.0 [h];
            attribute :>> exposure = captureExposure;
            attribute :>> singlePointFailure = false;
            ref :>> propagatesAcross ::> hazardLog.overEnvelopeTarget;
        }
        occurrence <'FM-PRX-01'> relativeNavigationLoss : FailureMode {
            doc /* The relative-navigation solution diverges during final approach. */
            ref :>> failedItem ::> argent.gnc;
            attribute :>> lostFunction = "estimate relative state to the target";
            attribute :>> mode = "navigation filter divergence";
            attribute :>> cause = "lidar return lost on the dark limb";
            attribute :>> localEffect = "relative state unknown";
            attribute :>> endEffect = "autonomous abort to the 500 m hold point";
            attribute :>> detection = DetectionMeans::navigationResidual;
            attribute :>> compensatingProvision = "camera-only backup mode and abort";
            attribute :>> severity = Severity::major;
            attribute :>> meanTimeToFailure = 20000.0 [h];
            attribute :>> exposure = captureExposure;
            attribute :>> singlePointFailure = false;
            ref :>> propagatesAcross ::> hazardLog.tugTargetCollision;
        }
        occurrence <'FM-PRX-02'> rcsThrusterStuckOpen : FailureMode {
            doc /* A reaction-control thruster valve sticks open during proximity operations. */
            ref :>> failedItem ::> argent.rcs;
            attribute :>> lostFunction = "control relative translation and attitude";
            attribute :>> mode = "thruster valve stuck open";
            attribute :>> cause = "particulate in the valve seat";
            attribute :>> localEffect = "uncommanded thrust";
            attribute :>> endEffect = "collision unless the branch is isolated";
            attribute :>> detection = DetectionMeans::telemetryLimit;
            attribute :>> compensatingProvision = "latch valve isolates the branch in 2 s";
            attribute :>> severity = Severity::critical;
            attribute :>> meanTimeToFailure = 150000.0 [h];
            attribute :>> exposure = captureExposure;
            attribute :>> singlePointFailure = false;
            ref :>> propagatesAcross ::> hazardLog.tugTargetCollision;
        }
        occurrence <'FM-PRX-03'> despinPropellantShortfall : FailureMode {
            doc /* Despin needs more hydrazine than loaded for the large-target spin case. */
            ref :>> failedItem ::> argent.rcs;
            attribute :>> lostFunction = "despin the captured body";
            attribute :>> mode = "propellant exhausted before spin removed";
            attribute :>> cause = "target spin or inertia above the characterised envelope";
            attribute :>> localEffect = "residual stack spin";
            attribute :>> endEffect = "arrays cannot track the Sun; mission lost";
            attribute :>> detection = DetectionMeans::groundTrending;
            attribute :>> compensatingProvision = "25 percent reserve, SEP-assisted despin";
            attribute :>> severity = Severity::critical;
            attribute :>> meanTimeToFailure = 400000.0 [h];
            attribute :>> exposure = captureExposure;
            attribute :>> singlePointFailure = false;
            ref :>> propagatesAcross ::> hazardLog.uncontrolledTumble;
        }
    }

    // ---------------------------------------------------------------- critical items (SE-174, SE-178)

    part criticalItemsList {
        doc /* Single-point failures retained in the design, each with a retention rationale and
             * waiver state. Waivers are granted by the project safety board at CDR. */
        ref part bagDeploymentLatch :>> argent.captureSystem {
            @CriticalItem { rationale = "a second bag doubles the capture-system mass; the latch is qualified to 3x load and inspected before shipment"; waived = true; }
        }
        ref part primaryStructure :>> argent.structure {
            @CriticalItem { rationale = "primary structure is a conventional single-point item verified by proof test"; waived = true; }
        }
        ref part xenonTank :>> argent.sep {
            @CriticalItem { rationale = "single composite-overwrapped tank; leak-before-burst design, proof and burst tests"; waived = false; }
        }
    }

    // ---------------------------------------------------------------- safety-critical software (SE-179)

    part safetyCriticalSoftware {
        doc /* Functions whose software is safety-critical because its failure contributes to a
             * catastrophic or critical hazard. The flight-software package types them; here they
             * are identified against the hazard log. */
        ref part finalTargetingGuidance :>> argent.gnc {
            @SafetyCritical { rationale = "computes the lunar gravity-assist targeting burn (TH-001)"; }
        }
        ref part captureAbortLogic :>> argent.cdh {
            @SafetyCritical { rationale = "autonomous abort to the hold point (TH-002)"; }
        }
        ref part highVoltageInhibitLogic :>> argent.eps {
            @SafetyCritical { rationale = "second inhibit on PPU high voltage (TH-006)"; }
        }
    }

    // ---------------------------------------------------------------- fault trees (SE-173, SE-176)

    calc def AndGate {
        doc /* Probability that two independent events both occur. */
        in a : Real;
        in b : Real;
        return : Real = a * b;
    }

    calc def OrGate {
        doc /* Probability that at least one of two independent events occurs. */
        in a : Real;
        in b : Real;
        return : Real = 1.0 - (1.0 - a) * (1.0 - b);
    }

    occurrence def BasicEvent {
        doc /* A fault-tree leaf with its per-mission probability. */
        attribute probability : Real;
    }

    occurrence earthImpactTree {
        doc /* Fault tree for TH-001, the Earth-impact exclusion case. The top event needs both
             * a trajectory that passes inside the Earth-impact corridor (excluded by the TS-801
             * bias except on the final targeting arc) and a control failure on that arc; the
             * control failure is the OR of thrust loss and an erroneous targeting burn, the
             * latter itself needing both a guidance error and the ground authority of TS-802 to
             * fail. Gates: isNecessary on every cause of a multicausation marks an AND gate;
             * isSufficient on each causation marks an OR gate. Probabilities are per mission. */

        #cause occurrence thrustLossOnFinalArc : BasicEvent { attribute :>> probability = 2.0e-3; }
        #cause occurrence guidanceErrorOnFinalArc : BasicEvent { attribute :>> probability = 1.0e-3; }
        #cause occurrence groundAuthorityFails : BasicEvent { attribute :>> probability = 1.0e-3; }
        #cause occurrence insideCorridorOnFinalArc : BasicEvent { attribute :>> probability = 2.0e-2; }

        #effect event occurrence erroneousTargetingBurn;
        #effect event occurrence controlFailureOnFinalArc;
        #effect event occurrence earthImpact;

        #multicausation connection erroneousTargetingGate {
            end #cause :> causes ::> guidanceErrorOnFinalArc;
            end #cause :> causes ::> groundAuthorityFails;
            end #effect :> effects ::> erroneousTargetingBurn;
            @CausationMetadata { isNecessary = true; isSufficient = false; }
        }
        #causation connection thrustLossBranch connect thrustLossOnFinalArc to controlFailureOnFinalArc {
            @CausationMetadata { isNecessary = false; isSufficient = true; probability = 1.0; }
        }
        #causation connection targetingBranch connect erroneousTargetingBurn to controlFailureOnFinalArc {
            @CausationMetadata { isNecessary = false; isSufficient = true; probability = 1.0; }
        }
        #multicausation connection topGate {
            end #cause :> causes ::> insideCorridorOnFinalArc;
            end #cause :> causes ::> controlFailureOnFinalArc;
            end #effect :> effects ::> earthImpact;
            @CausationMetadata { isNecessary = true; isSufficient = false; }
        }

        attribute pErroneousTargeting : Real = AndGate(guidanceErrorOnFinalArc.probability, groundAuthorityFails.probability);
        attribute pControlFailure : Real = OrGate(thrustLossOnFinalArc.probability, pErroneousTargeting);
        attribute pEarthImpact : Real = AndGate(insideCorridorOnFinalArc.probability, pControlFailure);
        attribute earthImpactLimit : Real = 1.0e-4;
        assert constraint earthImpactExcluded {
            doc /* The probabilistic risk assessment criterion for TR-006: the per-mission Earth-impact
                 * probability stays below the limit. */
            pEarthImpact <= earthImpactLimit
        }
    }

    occurrence lossOfCaptureTree {
        doc /* Fault tree for loss of the primary objective at capture: the bag fails to deploy,
             * OR the body is over the envelope, OR despin cannot be completed. */
        #cause occurrence bagFailsToDeploy : BasicEvent { attribute :>> probability = fmeca.bagInflationFailure.failureProbability; }
        #cause occurrence bodyOverEnvelope : BasicEvent { attribute :>> probability = fmeca.targetOverEnvelope.failureProbability; }
        #cause occurrence despinIncomplete : BasicEvent { attribute :>> probability = fmeca.despinPropellantShortfall.failureProbability; }
        #effect event occurrence captureLost;
        #causation connection bagBranch connect bagFailsToDeploy to captureLost {
            @CausationMetadata { isSufficient = true; probability = 1.0; }
        }
        #causation connection envelopeBranch connect bodyOverEnvelope to captureLost {
            @CausationMetadata { isSufficient = true; probability = 1.0; }
        }
        #causation connection despinBranch connect despinIncomplete to captureLost {
            @CausationMetadata { isSufficient = true; probability = 1.0; }
        }
        attribute pCaptureLost : Real = OrGate(OrGate(bagFailsToDeploy.probability, bodyOverEnvelope.probability), despinIncomplete.probability);
    }

    // ---------------------------------------------------------------- reliability budget hooks (SE-175)

    part reliabilityBudget {
        doc /* Reliability block hooks for the budgets package: per-subsystem mean time to failure
             * over the nominal mission (thruster strings over the 1 100 thrust days), the series string of the single-string subsystems and the
             * three-of-four SEP set. The budgets package rolls these into the mission reliability
             * figure; the allocation here is the Phase B starting point. */
        attribute missionDuration : DurationValue = 2200.0 [d];
        attribute thrustDuration : DurationValue = 1100.0 [d];
        attribute structureMttf : DurationValue = 2.0e6 [h];
        attribute epsMttf : DurationValue = 6.0e5 [h];
        attribute cdhMttf : DurationValue = 5.0e5 [h];
        attribute thrusterStringMttf : DurationValue = 2.0e5 [h];
        attribute structureReliability : Real = Reliability(structureMttf / missionDuration);
        attribute epsReliability : Real = Reliability(epsMttf / missionDuration);
        attribute cdhReliability : Real = Reliability(cdhMttf / missionDuration);
        attribute sepReliability : Real = KOutOfNReliability3of4(Reliability(thrusterStringMttf / thrustDuration));
        attribute busReliability : Real = SeriesReliability(structureReliability, epsReliability, cdhReliability);
        attribute missionReliability : Real = busReliability * sepReliability;
        attribute requiredMissionReliability : Real = 0.70;
        assert constraint reliabilityAllocationMet { missionReliability >= requiredMissionReliability }
    }

    // ---------------------------------------------------------------- end of life, contamination, ground safety (SE-180–SE-182)

    part endOfLifeSafety {
        doc /* Space-debris and end-of-life record: the captured body stays in its distant
             * retrograde orbit (TR-006, 100-year stability); the tug leaves cislunar space on a
             * heliocentric disposal orbit (TS-806); the inspector is disposed by impact on the
             * captured body's shadowed side at 0.05 m/s after its survey. */
        attribute tugDisposalDeltaV : SpeedValue = 150.0 [m/s];
        attribute inspectorImpactSpeed : SpeedValue = 0.05 [m/s];
        attribute residualXenonAtDisposal : MassValue = 120.0 [kg];
        attribute disposalXenonNeeded : MassValue = 95.0 [kg];
        assert constraint disposalPropellantSufficient { residualXenonAtDisposal >= disposalXenonNeeded }
    }

    part contaminationControl {
        doc /* Cleanliness: the optics and radiators are the ejecta-sensitive surfaces; the
             * plume keep-out (TS-808) bounds the lofted-regolith deposit, and the pre-capture
             * radiator cover limits the post-capture emissivity loss to the allocation. */
        attribute radiatorEmissivityLossAllocation : Real = 0.05;
        attribute opticsThroughputLossAllocation : Real = 0.10;
        attribute plumeKeepOut : LengthValue = 50.0 [m];
    }

    part groundSafetyData {
        doc /* Launch-site and ground safety data: the pressurised xenon tank and the hydrazine
             * load are the hazardous systems; both are loaded at the site in a serviced-last
             * sequence, and the high-voltage inhibits (TS-807) are the electrical hazard control. */
        attribute xenonTankMaximumOperatingPressure : PressureValue = 18.6e6 [Pa];
        attribute hydrazineLoad : MassValue = argent.rcs.hydrazineMass;
        attribute inhibitCount : Natural = 2;
        assert constraint twoInhibits { inhibitCount >= 2 }
    }
}
