package TethysRisk {
    doc /* Risk management for the Tethys mission: the 5 × 5 likelihood–consequence scheme and
         * its rating thresholds, the risk register with owners, mitigations written as
         * requirements and actions, review snapshots that record the burn-down, links to the
         * hazard log, the FMECA and the requirements, margin-related indicators, the lessons
         * learned list and the technology-development risks with their fallback options.
         * Each register entry also carries the standard RiskMetadata so library-aware tools
         * read the same probability and impact. All numbers are fictional. */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import RiskMetadata::*;
    private import ControlFunctions::*;
    private import StandardViewDefinitions::*;
    private import TethysTug::*;
    private import TethysMission::*;
    private import TethysRequirements::*;
    private import TethysSafety::*;

    // ---------------------------------------------------------------- 5 × 5 scheme (SE-242)

    enum def Likelihood :> Natural {
        doc /* Likelihood of the risk being realised over the mission, 1 (very unlikely, under
             * 2 percent) to 5 (near certain, over 80 percent). */
        veryLow = 1; low = 2; moderate = 3; high = 4; veryHigh = 5;
    }

    enum def Consequence :> Natural {
        doc /* Consequence if realised, 1 (negligible) to 5 (loss of the mission or a public
             * safety impact). */
        negligible = 1; minor = 2; moderate = 3; major = 4; catastrophic = 5;
    }

    enum def Rating {
        doc /* Rating colour from the 5 × 5 matrix: red needs a mitigation plan approved by the
             * project board, yellow a tracked mitigation, green monitoring only. */
        green; yellow; red;
    }

    enum def RiskStatus {
        doc /* Life-cycle status of a register entry. */
        open; mitigating; watch; accepted; closed;
    }

    enum def Trend {
        doc /* Movement of the score since the last review. */
        increasing; stable; decreasing;
    }

    part riskMatrix {
        doc /* The rating thresholds on the product likelihood × consequence: red at 15 and
             * above or whenever consequence is catastrophic with likelihood at least moderate;
             * yellow from 8; green below. */
        attribute redThreshold : Natural = 15;
        attribute yellowThreshold : Natural = 8;
        attribute catastrophicRedLikelihood : Natural = 3;
    }

    calc def Score {
        doc /* Risk score: likelihood × consequence on the 1–5 scales. */
        in likelihood : Likelihood;
        in consequence : Consequence;
        return : Natural = likelihood * consequence;
    }

    calc def RatingOf {
        doc /* Rating colour of a likelihood–consequence pair under riskMatrix. */
        in likelihood : Likelihood;
        in consequence : Consequence;
        return : Rating = if likelihood * consequence >= riskMatrix.redThreshold
                or (consequence == Consequence::catastrophic and likelihood >= riskMatrix.catastrophicRedLikelihood) ? Rating::red
            else if likelihood * consequence >= riskMatrix.yellowThreshold ? Rating::yellow
            else Rating::green;
    }

    calc def ToLevel {
        doc /* Maps a 1–5 scale value onto the RiskMetadata Level range 0–1. */
        in scale : Natural;
        return : Level = scale / 5.0;
    }

    // ---------------------------------------------------------------- register (SE-241, SE-244)

    action def MitigationAction {
        doc /* A mitigation step with the review at which it is due and whether it is complete. */
        attribute dueReview : String;
        attribute complete : Boolean;
    }

    part def RiskItem {
        doc /* One register entry: statement, owner, current likelihood and consequence with the
             * derived score and rating, status and trend, the requirements and actions that
             * mitigate it, and its links to the hazard log, the FMECA and the requirements it
             * threatens. */
        attribute statement : String;
        attribute owner : String;
        attribute likelihood : Likelihood;
        attribute consequence : Consequence;
        attribute score : Natural = Score(likelihood, consequence);
        attribute rating : Rating = RatingOf(likelihood, consequence);
        attribute status : RiskStatus;
        attribute trend : Trend;
        ref requirement mitigationRequirements : SystemRequirement [0..*] {
            doc /* Requirements written to mitigate this risk. */
        }
        action mitigationActions : MitigationAction [0..*];
        ref occurrence relatedHazards : Hazard [0..*];
        ref occurrence relatedFailureModes : FailureMode [0..*];
        ref requirement threatenedRequirements : MissionRequirement [0..*] {
            doc /* Mission requirements this risk puts at stake. */
        }
    }

    part def TechnologyRisk :> RiskItem {
        doc /* A risk that a technology does not mature in time, with its current and needed
             * readiness level and the fallback that bounds the consequence. */
        attribute readinessNow : Natural;
        attribute readinessNeeded : Natural;
        attribute fallback : String;
    }

    part riskRegister {
        doc /* The project risk register at the start of Phase B. Identifiers TK-nnn. Every
             * entry subsets `items`, the collection the register-wide gates quantify over. */
        part items : RiskItem[*];

        part <'TK-001'> earthImpactRisk : RiskItem :> items {
            doc /* The returned body could be placed on an Earth-impact trajectory. */
            @Risk { :>> totalRisk { :>> probability = 0.2; :>> impact = 1.0; } }
            attribute :>> statement = "A control failure on the final targeting arc places the body on an Earth-impact trajectory.";
            attribute :>> owner = "mission design lead";
            attribute :>> likelihood default = Likelihood::veryLow;
            attribute :>> consequence = Consequence::catastrophic;
            attribute :>> status = RiskStatus::mitigating;
            attribute :>> trend = Trend::decreasing;
            ref :>> mitigationRequirements = (earthMissDistance, finalTargetingAuthority);
            action :>> mitigationActions {
                action dispersionAnalysis : MitigationAction {
                    attribute :>> dueReview = "PDR";
                    attribute :>> complete = true;
                }
                action commandPathDemo : MitigationAction {
                    attribute :>> dueReview = "CDR";
                    attribute :>> complete = false;
                }
            }
            ref :>> relatedHazards ::> hazardLog.earthImpactByTarget;
            ref :>> relatedFailureModes ::> fmeca.xenonRegulatorFailure;
            ref :>> threatenedRequirements ::> cislunarSafety;
            snapshot atSrr : RiskItem {
                doc /* As rated at SRR, before the trajectory bias was baselined. */
                attribute :>> likelihood = Likelihood::moderate;
            }
            snapshot atPdr : RiskItem {
                doc /* As rated at PDR, with TS-801 baselined. */
                attribute :>> likelihood = Likelihood::low;
            }
        }

        part <'TK-002'> targetSizeRisk : RiskItem :> items {
            doc /* The target may be larger, heavier or faster-spinning than the characterisation
                 * envelope (the design driver of the mission). */
            @Risk { :>> totalRisk { :>> probability = 0.6; :>> impact = 0.8; } }
            attribute :>> statement = "Ground characterisation underestimates the target's size, mass or spin and the capture system cannot hold it.";
            attribute :>> owner = "target characterisation lead";
            attribute :>> likelihood default = Likelihood::moderate;
            attribute :>> consequence = Consequence::major;
            attribute :>> status = RiskStatus::mitigating;
            attribute :>> trend = Trend::stable;
            ref :>> mitigationRequirements = (captureEnvelopeMargin, despinContinuation);
            action :>> mitigationActions {
                action radarCampaign : MitigationAction {
                    attribute :>> dueReview = "PDR";
                    attribute :>> complete = false;
                }
                action inspectorSurveyBeforeCommit : MitigationAction {
                    attribute :>> dueReview = "CDR";
                    attribute :>> complete = false;
                }
            }
            ref :>> relatedHazards = (hazardLog.overEnvelopeTarget, hazardLog.uncontrolledTumble);
            ref :>> relatedFailureModes = (fmeca.targetOverEnvelope, fmeca.despinPropellantShortfall);
            ref :>> threatenedRequirements ::> retrieval;
            snapshot atSrr : RiskItem { attribute :>> likelihood = Likelihood::high; }
            snapshot atPdr : RiskItem { attribute :>> likelihood = Likelihood::moderate; }
        }

        part <'TK-003'> thrusterLifeRisk : RiskItem :> items {
            doc /* The Hall thrusters may not reach the 20 000 h per-string life the return needs. */
            @Risk { :>> totalRisk { :>> probability = 0.4; :>> impact = 0.8; } }
            attribute :>> statement = "Thruster erosion life falls short of the return-cruise demand and the fourth thruster is consumed early.";
            attribute :>> owner = "propulsion lead";
            attribute :>> likelihood default = Likelihood::low;
            attribute :>> consequence = Consequence::major;
            attribute :>> status = RiskStatus::mitigating;
            attribute :>> trend = Trend::decreasing;
            action :>> mitigationActions {
                action lifeTest : MitigationAction {
                    attribute :>> dueReview = "CDR";
                    attribute :>> complete = false;
                }
            }
            ref :>> relatedFailureModes ::> fmeca.thrusterFlameout;
            ref :>> threatenedRequirements ::> missionDuration;
            snapshot atSrr : RiskItem { attribute :>> likelihood = Likelihood::moderate; }
            snapshot atPdr : RiskItem { attribute :>> likelihood = Likelihood::low; }
        }

        part <'TK-004'> proximityOperationsRisk : RiskItem :> items {
            doc /* Relative navigation at the target may be less robust than designed. */
            @Risk { :>> totalRisk { :>> probability = 0.4; :>> impact = 0.6; } }
            attribute :>> statement = "Relative navigation diverges during final approach and the capture attempt is aborted repeatedly.";
            attribute :>> owner = "guidance, navigation and control lead";
            attribute :>> likelihood default = Likelihood::low;
            attribute :>> consequence = Consequence::moderate;
            attribute :>> status = RiskStatus::watch;
            attribute :>> trend = Trend::stable;
            ref :>> mitigationRequirements ::> captureAbortAuthority;
            action :>> mitigationActions {
                action hardwareInTheLoopCampaign : MitigationAction {
                    attribute :>> dueReview = "CDR";
                    attribute :>> complete = false;
                }
            }
            ref :>> relatedHazards ::> hazardLog.tugTargetCollision;
            ref :>> relatedFailureModes = (fmeca.relativeNavigationLoss, fmeca.rcsThrusterStuckOpen);
            ref :>> threatenedRequirements ::> retrieval;
            snapshot atSrr : RiskItem { attribute :>> likelihood = Likelihood::low; }
            snapshot atPdr : RiskItem { attribute :>> likelihood = Likelihood::low; }
        }

        part <'TK-005'> xenonMarginRisk : RiskItem :> items {
            doc /* The xenon margin may be consumed by target mass growth. */
            @Risk { :>> totalRisk { :>> probability = 0.6; :>> impact = 0.6; } }
            attribute :>> statement = "A large-case target consumes the xenon reserve and the return arc cannot be closed.";
            attribute :>> owner = "systems engineering lead";
            attribute :>> likelihood default = Likelihood::moderate;
            attribute :>> consequence = Consequence::moderate;
            attribute :>> status = RiskStatus::open;
            attribute :>> trend = Trend::increasing;
            action :>> mitigationActions {
                action tankGrowthOption : MitigationAction {
                    attribute :>> dueReview = "PDR";
                    attribute :>> complete = false;
                }
            }
            ref :>> threatenedRequirements = (retrieval, missionDuration);
            snapshot atSrr : RiskItem { attribute :>> likelihood = Likelihood::low; }
            snapshot atPdr : RiskItem { attribute :>> likelihood = Likelihood::moderate; }
        }

        part <'TK-006'> captureBagTechnology : TechnologyRisk :> items {
            doc /* The inflatable capture bag is the mission's least mature technology. */
            @Risk { :>> totalRisk { :>> probability = 0.4; :>> impact = 0.8; } :>> technicalRisk { :>> probability = 0.6; :>> impact = 0.8; } :>> scheduleRisk { :>> probability = 0.6; :>> impact = 0.6; } }
            attribute :>> statement = "The inflatable bag does not reach flight readiness by CDR.";
            attribute :>> owner = "capture system lead";
            attribute :>> likelihood default = Likelihood::low;
            attribute :>> consequence = Consequence::major;
            attribute :>> status = RiskStatus::mitigating;
            attribute :>> trend = Trend::stable;
            attribute :>> readinessNow = 4;
            attribute :>> readinessNeeded = 6;
            attribute :>> fallback = "rigid articulated claw sized for the small and nominal target cases only";
            action :>> mitigationActions {
                action vacuumDeploymentTest : MitigationAction {
                    attribute :>> dueReview = "PDR";
                    attribute :>> complete = false;
                }
            }
            ref :>> relatedFailureModes ::> fmeca.bagInflationFailure;
            ref :>> threatenedRequirements ::> retrieval;
            snapshot atSrr : RiskItem { attribute :>> likelihood = Likelihood::moderate; }
            snapshot atPdr : RiskItem { attribute :>> likelihood = Likelihood::low; }
        }

        assert constraint noUnownedRedRisk {
            doc /* Every red risk has a mitigation plan under way: no entry of the register is
                 * both rated red and still open. Quantified over `items`, so an entry added
                 * later is checked without touching the gate. */
            items->forAll { in risk : RiskItem;
                not (risk.rating == Rating::red and risk.status == RiskStatus::open) }
        }
    }

    // ---------------------------------------------------------------- burn-down (SE-243)

    part burnDown {
        doc /* Review snapshots of the register score: the sum over the register at SRR, PDR
             * and now, and the per-risk check that no score rose between SRR and PDR except the
             * xenon-margin risk, whose rise is the recorded trend. */
        attribute srrTotal : Natural = riskRegister.earthImpactRisk.atSrr.score + riskRegister.targetSizeRisk.atSrr.score
            + riskRegister.thrusterLifeRisk.atSrr.score + riskRegister.proximityOperationsRisk.atSrr.score
            + riskRegister.xenonMarginRisk.atSrr.score + riskRegister.captureBagTechnology.atSrr.score;
        attribute pdrTotal : Natural = riskRegister.earthImpactRisk.atPdr.score + riskRegister.targetSizeRisk.atPdr.score
            + riskRegister.thrusterLifeRisk.atPdr.score + riskRegister.proximityOperationsRisk.atPdr.score
            + riskRegister.xenonMarginRisk.atPdr.score + riskRegister.captureBagTechnology.atPdr.score;
        attribute currentTotal : Natural = riskRegister.earthImpactRisk.score + riskRegister.targetSizeRisk.score
            + riskRegister.thrusterLifeRisk.score + riskRegister.proximityOperationsRisk.score
            + riskRegister.xenonMarginRisk.score + riskRegister.captureBagTechnology.score;
        assert constraint registerBurningDown { pdrTotal <= srrTotal }
        assert constraint earthImpactBurningDown { riskRegister.earthImpactRisk.atPdr.score <= riskRegister.earthImpactRisk.atSrr.score }
    }

    // ---------------------------------------------------------------- margin indicators (SE-245)

    part marginIndicators {
        doc /* Margin-related risk indicators: a resource whose margin falls under its trigger
             * raises the paired register entry. Xenon: loaded mass against the large-case
             * return demand; capture envelope: the large-case diameter against the bag. */
        attribute xenonLoaded : MassValue = argent.sep.xenonMass;
        attribute xenonLargeCaseDemand : MassValue = 6100.0 [kg];
        attribute xenonMarginFraction : Real = (xenonLoaded - xenonLargeCaseDemand) / xenonLoaded;
        attribute xenonMarginTrigger : Real = 0.10;
        attribute xenonMarginFlag : Boolean = xenonMarginFraction < xenonMarginTrigger;
        attribute envelopeMarginFraction : Real = envelopeCases.largeMargin;
        attribute envelopeMarginTrigger : Real = 0.15;
        attribute envelopeMarginFlag : Boolean = envelopeMarginFraction < envelopeMarginTrigger;
        assert constraint xenonFlagMatchesRegister {
            doc /* A raised xenon flag is carried as an increasing trend on TK-005. */
            not xenonMarginFlag or riskRegister.xenonMarginRisk.trend == Trend::increasing
        }
    }

    // ---------------------------------------------------------------- lessons learned (SE-246)

    part def LessonLearned {
        doc /* A lesson from an earlier (fictional) programme and the model element that applies it. */
        attribute source : String;
        attribute lesson : String;
        attribute appliedAs : String;
    }

    part lessonsLearned {
        doc /* Lessons carried into the Tethys design. */
        part <'LL-001'> inhibitsBeforeSeparation : LessonLearned {
            attribute :>> source = "Corvid-2 electric tug, anomaly review";
            attribute :>> lesson = "High-voltage inhibits released on a timer arced in the fairing's residual gas.";
            attribute :>> appliedAs = "TS-807: two inhibits held to separation plus 600 s";
        }
        part <'LL-002'> surveyBeforeCommit : LessonLearned {
            attribute :>> source = "Harrier small-body flyby, post-flight report";
            attribute :>> lesson = "Ground radar underestimated the body's long axis by 30 percent.";
            attribute :>> appliedAs = "TS-804 envelope factor and the inspector survey before capture commit";
        }
        part <'LL-003'> groundAuthorityOnCriticalBurns : LessonLearned {
            attribute :>> source = "Marlin lunar return demonstrator, lessons learned";
            attribute :>> lesson = "An autonomous retargeting burn executed on a stale ephemeris.";
            attribute :>> appliedAs = "TS-802 ground-enabled final targeting";
        }
    }

    // ---------------------------------------------------------------- technology fallback (SE-247)

    part def CaptureMechanism {
        doc /* A capture mechanism option with its readiness level and the largest body it holds. */
        attribute readinessLevel : Natural;
        attribute maximumBodyDiameter : LengthValue;
    }

    part inflatableBagOption : CaptureMechanism {
        doc /* The baseline inflatable bag, sized to the capture-system envelope. */
        attribute :>> readinessLevel = 4;
        attribute :>> maximumBodyDiameter = argent.captureSystem.maximumBodyDiameter;
    }

    part rigidClawOption : CaptureMechanism {
        doc /* The fallback rigid articulated claw, sized for the small and nominal cases only. */
        attribute :>> readinessLevel = 6;
        attribute :>> maximumBodyDiameter = 7.0 [m];
    }

    part technologyPlan {
        doc /* The technology-development plan: the capture-mechanism choice kept open as a
             * variation until the TK-006 fallback decision at PDR. */
        variation part captureMechanism : CaptureMechanism {
            variant part inflatableBag :> inflatableBagOption;
            variant part rigidClaw :> rigidClawOption;
        }
        attribute decisionReview : String = "PDR";
        assert constraint fallbackHoldsNominalTarget {
            doc /* The fallback still holds the nominal 6.8 m body. */
            rigidClawOption.maximumBodyDiameter >= envelopeCases.nominalTargetDiameter
        }
    }

    // ---------------------------------------------------------------- views

    view def RiskRegisterView :> GridView {
        doc /* The register as a grid, one row per risk item. */
        filter @SysML::PartUsage;
    }

    view riskRegisterView : RiskRegisterView {
        doc /* The Phase B register. */
        expose riskRegister::*;
    }
}
