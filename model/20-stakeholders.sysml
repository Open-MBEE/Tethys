// Who the mission is for and what they need: the stakeholder register, their concerns and the
// viewpoints that frame them, the needs the L1 requirements refine, success criteria, measures of
// effectiveness and performance, technical performance measures with margins, the mission context,
// the capabilities and ConOps use cases, and the assumptions, led by the target-uncertainty cases.
package TethysStakeholders {
    doc /* Stakeholder and concept layer of the Tethys requirements tree. Everything here is
         * upstream of the L1 requirements in TethysRequirements: the needs are refined by
         * TR-001 to TR-009, the measures and target cases are what the L2 tree quantifies. */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import ModelingMetadata::*;
    private import ParametersOfInterestMetadata::*;
    private import VerificationCases::VerificationMethodKind;
    private import TethysRequirements::*;
    private import TethysMission::*;
    private import TethysSystem::*;
    private import TethysTarget::SmallBody;

    // ---- Stakeholder register ------------------------------------------------------------

    enum def StakeholderRole {
        doc /* The part a stakeholder plays in the programme. */
        enum sponsor;
        enum operator;
        enum scienceUser;
        enum utilisationCustomer;
        enum launchProvider;
        enum groundProvider;
        enum safetyAuthority;
        enum generalPublic;
    }

    part def Stakeholder {
        doc /* A person or organisation with an interest in the mission's outcome. Influence is a
             * 1 (low) to 3 (high) weight used when concerns conflict. */
        attribute role : StakeholderRole;
        attribute influence : Integer;
        attribute engagement : String;
    }

    part stakeholderRegister {
        doc /* The stakeholder register (fictional organisations). */
        part programmeBoard : Stakeholder {
            doc /* The sponsoring programme board: funds the mission and owns the success criteria. */
            attribute :>> role = StakeholderRole::sponsor;
            attribute :>> influence = 3;
            attribute :>> engagement = "approves every lifecycle review";
        }
        part flightOperationsTeam : Stakeholder {
            doc /* The team that flies Argent and Wren from the Meridian operations centre. */
            attribute :>> role = StakeholderRole::operator;
            attribute :>> influence = 2;
            attribute :>> engagement = "ConOps and operability reviews";
        }
        part smallBodyScienceTeam : Stakeholder {
            doc /* Investigators who use the characterisation data and the returned body. */
            attribute :>> role = StakeholderRole::scienceUser;
            attribute :>> influence = 2;
            attribute :>> engagement = "science traceability matrix";
        }
        part lanternUtilisationOffice : Stakeholder {
            doc /* The office that sends Lantern to the body once it is in the DRO. */
            attribute :>> role = StakeholderRole::utilisationCustomer;
            attribute :>> influence = 2;
            attribute :>> engagement = "docking ICD and access requirements";
        }
        part arcturusLaunchServices : Stakeholder {
            doc /* The provider of the Arcturus-5H launch. */
            attribute :>> role = StakeholderRole::launchProvider;
            attribute :>> influence = 1;
            attribute :>> engagement = "launch ICD";
        }
        part meridianNetwork : Stakeholder {
            doc /* The operator of the Meridian deep-space stations. */
            attribute :>> role = StakeholderRole::groundProvider;
            attribute :>> influence = 1;
            attribute :>> engagement = "space-ground ICD and scheduling";
        }
        part cislunarSafetyBoard : Stakeholder {
            doc /* The independent board that clears the return trajectory and the DRO. */
            attribute :>> role = StakeholderRole::safetyAuthority;
            attribute :>> influence = 3;
            attribute :>> engagement = "Earth-impact exclusion and disposal reviews";
        }
        part generalPublic : Stakeholder {
            doc /* The public, whose interest is that nothing falls on them. */
            attribute :>> role = StakeholderRole::generalPublic;
            attribute :>> influence = 1;
            attribute :>> engagement = "represented by the safety board";
        }
    }

    // ---- Concerns and viewpoints -----------------------------------------------------------

    concern def MissionValueConcern {
        doc /* Does the mission return enough body, soon enough, to be worth its cost? */
        subject mission : Mission;
        stakeholder board : Stakeholder;
    }
    concern def ReturnSafetyConcern {
        doc /* Can the returned body ever reach the Earth, and does it stay bound to the Moon? */
        subject mission : Mission;
        stakeholder safetyBoard : Stakeholder;
        stakeholder publicAtLarge : Stakeholder;
    }
    concern def TargetUncertaintyConcern {
        doc /* Will the system still work if Amaranth is smaller, larger, denser or faster than
             * the ground estimate? */
        subject mission : Mission;
        stakeholder board : Stakeholder;
        stakeholder science : Stakeholder;
    }
    concern def OperabilityConcern {
        doc /* Can a small team fly the mission with 0 to 400 s round-trip light time and
             * hours-long thrust arcs? */
        subject mission : Mission;
        stakeholder operations : Stakeholder;
    }
    concern def UtilisationConcern {
        doc /* Can Lantern dock and reach the surface after delivery? */
        subject mission : Mission;
        stakeholder customer : Stakeholder;
    }
    concern def InterfaceConcern {
        doc /* Are the launch and ground interfaces fixed early enough for the providers? */
        subject mission : Mission;
        stakeholder launcher : Stakeholder;
        stakeholder ground : Stakeholder;
    }

    concern missionValue : MissionValueConcern {
        doc /* The board's value concern. */
        subject mission : Mission;
        stakeholder :>> board = stakeholderRegister.programmeBoard;
    }
    concern returnSafety : ReturnSafetyConcern {
        doc /* The safety board's and public's return-safety concern. */
        subject mission : Mission;
        stakeholder :>> safetyBoard = stakeholderRegister.cislunarSafetyBoard;
        stakeholder :>> publicAtLarge = stakeholderRegister.generalPublic;
    }
    concern targetUncertainty : TargetUncertaintyConcern {
        doc /* The design-driving concern: the target is known only to a factor of two in size. */
        subject mission : Mission;
        stakeholder :>> board = stakeholderRegister.programmeBoard;
        stakeholder :>> science = stakeholderRegister.smallBodyScienceTeam;
    }
    concern operability : OperabilityConcern {
        doc /* The operators' concern. */
        subject mission : Mission;
        stakeholder :>> operations = stakeholderRegister.flightOperationsTeam;
    }
    concern utilisation : UtilisationConcern {
        doc /* The utilisation office's concern. */
        subject mission : Mission;
        stakeholder :>> customer = stakeholderRegister.lanternUtilisationOffice;
    }
    concern interfaces : InterfaceConcern {
        doc /* The providers' interface concern. */
        subject mission : Mission;
        stakeholder :>> launcher = stakeholderRegister.arcturusLaunchServices;
        stakeholder :>> ground = stakeholderRegister.meridianNetwork;
    }

    viewpoint def MissionAssuranceViewpoint {
        doc /* The view a safety reviewer needs: every return-safety requirement, its verification
             * and its closure state. */
        subject mission : Mission;
        frame concern framedReturnSafety :> returnSafety { doc /* Frames returnSafety. */ }
        frame concern framedTargetUncertainty :> targetUncertainty { doc /* Frames targetUncertainty. */ }
    }
    viewpoint def ProgrammeViewpoint {
        doc /* The view the board needs: success criteria, MOEs and TPM margins. */
        subject mission : Mission;
        frame concern framedMissionValue :> missionValue { doc /* Frames missionValue. */ }
        frame concern framedTargetUncertainty :> targetUncertainty { doc /* Frames targetUncertainty. */ }
    }
    viewpoint def OperationsViewpoint {
        doc /* The view the operators need: ConOps use cases and operability requirements. */
        subject mission : Mission;
        frame concern framedOperability :> operability { doc /* Frames operability. */ }
        frame concern framedUtilisation :> utilisation { doc /* Frames utilisation. */ }
    }
    viewpoint def VerificationViewpoint {
        doc /* The view the V&V lead needs: the requirement-to-verification matrix. */
        subject mission : Mission;
        frame concern framedMissionValue :> missionValue { doc /* Frames missionValue. */ }
        frame concern framedReturnSafety :> returnSafety { doc /* Frames returnSafety. */ }
        frame concern framedInterfaces :> interfaces { doc /* Frames interfaces. */ }
    }

    viewpoint missionAssuranceViewpoint : MissionAssuranceViewpoint {
        doc /* The safety board's viewpoint. */
    }
    viewpoint programmeViewpoint : ProgrammeViewpoint {
        doc /* The programme board's viewpoint. */
    }
    viewpoint operationsViewpoint : OperationsViewpoint {
        doc /* The flight operations team's viewpoint. */
    }
    viewpoint verificationViewpoint : VerificationViewpoint {
        doc /* The V&V lead's viewpoint. */
    }

    // ---- Needs, goals and objectives -------------------------------------------------------

    requirement def StakeholderNeed {
        doc /* A need stated in a stakeholder's words, before any solution is implied. Needs are
             * validated (demonstrated to the stakeholder), not verified. */
        attribute tier : RequirementTier = RequirementTier::mission;
        ref part originator : Stakeholder;
    }

    requirement <'N-001'> returnedBodyNeed : StakeholderNeed {
        doc /* The board needs a body of at least 100 t placed where cislunar vehicles can reach
             * it, to anchor the utilisation programme. */
        ref part :>> originator = stakeholderRegister.programmeBoard;
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @StatusInfo { owner = "programme board"; status = StatusKind::done; }
    }
    requirement <'N-002'> timelinessNeed : StakeholderNeed {
        doc /* The board needs the body delivered within one funding cycle of about six years
             * from launch. */
        ref part :>> originator = stakeholderRegister.programmeBoard;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @StatusInfo { owner = "programme board"; status = StatusKind::done; }
    }
    requirement <'N-003'> knownTargetNeed : StakeholderNeed {
        doc /* The science team needs the body's shape, mass and spin known before capture, both
             * to decide capture and as the first science product. */
        ref part :>> originator = stakeholderRegister.smallBodyScienceTeam;
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @StatusInfo { owner = "science team"; status = StatusKind::done; }
    }
    requirement <'N-004'> noEarthRiskNeed : StakeholderNeed {
        doc /* The safety board needs assurance that no failure during the return can put the
             * body on an Earth-impact trajectory and that the final orbit is stable for a century. */
        ref part :>> originator = stakeholderRegister.cislunarSafetyBoard;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "cislunar safety board"; status = StatusKind::done; }
    }
    requirement <'N-005'> deflectionKnowledgeNeed : StakeholderNeed {
        doc /* The science team needs a measured slow-push deflection to calibrate planetary
             * defence models. */
        ref part :>> originator = stakeholderRegister.smallBodyScienceTeam;
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @StatusInfo { owner = "science team"; status = StatusKind::done; }
    }
    requirement <'N-006'> surfaceAccessNeed : StakeholderNeed {
        doc /* The utilisation office needs Lantern to dock to the stack and reach the body's
             * surface. */
        ref part :>> originator = stakeholderRegister.lanternUtilisationOffice;
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @StatusInfo { owner = "utilisation office"; status = StatusKind::done; }
    }
    requirement <'N-007'> operabilityNeed : StakeholderNeed {
        doc /* The operations team needs a vehicle that is safe for days without ground contact
             * and that a single shift can command through long thrust arcs. */
        ref part :>> originator = stakeholderRegister.flightOperationsTeam;
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        @StatusInfo { owner = "flight operations"; status = StatusKind::done; }
    }
    requirement <'N-008'> robustToTargetNeed : StakeholderNeed {
        doc /* The board needs the mission to succeed for any body within the ground
             * characterisation uncertainty, not only for the nominal Amaranth. */
        ref part :>> originator = stakeholderRegister.programmeBoard;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "programme board"; status = StatusKind::done; }
    }
    requirement <'N-009'> providerInterfaceNeed : StakeholderNeed {
        doc /* The launch and ground providers need their interfaces frozen at the system PDR. */
        ref part :>> originator = stakeholderRegister.arcturusLaunchServices;
        @Verification { method = VerificationMethodKind::inspect; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @StatusInfo { owner = "systems engineering"; status = StatusKind::done; }
    }

    // L1 requirements refine the needs (ModelingMetadata::refinement); derivation starts at L1.
    #refinement dependency retrievalRefinesNeeds from retrieval to returnedBodyNeed, robustToTargetNeed;
    #refinement dependency durationRefinesNeed from missionDuration to timelinessNeed;
    #refinement dependency characterisationRefinesNeed from characterisation to knownTargetNeed, robustToTargetNeed;
    #refinement dependency launchRefinesNeed from launchCompatibility to providerInterfaceNeed;
    #refinement dependency groundRefinesNeeds from groundCompatibility to providerInterfaceNeed, operabilityNeed;
    #refinement dependency safetyRefinesNeed from cislunarSafety to noEarthRiskNeed;
    #refinement dependency classRefinesNeed from missionClass to noEarthRiskNeed, operabilityNeed;
    #refinement dependency deflectionRefinesNeed from deflectionDemonstration to deflectionKnowledgeNeed;
    #refinement dependency accessRefinesNeed from utilisationAccess to surfaceAccessNeed;

    // ---- Science and deflection traceability ---------------------------------------------

    requirement def ScienceObjective {
        doc /* A characterisation or deflection objective, traced to the measurement that
             * meets it and the need it serves. */
        attribute measurement : String;
    }
    requirement <'SO-001'> shapeModel : ScienceObjective {
        doc /* Produce a shape model of the body with a resolution of 0.1 m or better. */
        attribute :>> measurement = "Wren narrow-angle stereo imaging over one rotation";
        attribute resolution : LengthValue;
        require constraint { resolution <= 0.1 [m] }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
    }
    requirement <'SO-002'> massEstimate : ScienceObjective {
        doc /* Estimate the body's mass to 10 % before capture commit. */
        attribute :>> measurement = "Wren two-way proximity-link Doppler during circumnavigation";
        attribute relativeUncertainty : Real;
        require constraint { relativeUncertainty <= 0.10 }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
    }
    requirement <'SO-003'> spinState : ScienceObjective {
        doc /* Determine the spin period to 1 % and the spin-axis direction to 2 degrees. */
        attribute :>> measurement = "tug light-curve and landmark tracking";
        attribute periodUncertainty : Real;
        require constraint { periodUncertainty <= 0.01 }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
    }
    requirement <'SO-004'> deflectionMeasurement : ScienceObjective {
        doc /* Measure the heliocentric velocity change imparted by one slow-push arc to 1 mm/s. */
        attribute :>> measurement = "Meridian two-way range and Doppler over the arc";
        attribute velocityAccuracy : SpeedValue;
        require constraint { velocityAccuracy <= 0.001 [m/s] }
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
    }
    #refinement dependency objectivesRefineCharacterisation from shapeModel, massEstimate, spinState to characterisation;
    #refinement dependency objectiveRefinesDeflection from deflectionMeasurement to deflectionDemonstration;

    // ---- Success criteria ----------------------------------------------------------------

    requirement def SuccessCriterion {
        doc /* One criterion of the minimum or full mission success definition. */
        attribute tier : RequirementTier = RequirementTier::mission;
    }

    requirement minimumSuccess {
        doc /* Minimum success: the body is characterised and a slow-push deflection is measured,
             * even if the return is not completed. */
        requirement <'MS-001'> characterised : SuccessCriterion {
            doc /* Shape, mass and spin of the target are determined to the TR-003 accuracy. */
            @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        }
        requirement <'MS-002'> deflected : SuccessCriterion {
            doc /* A slow-push deflection is applied and its velocity change measured to 1 mm/s. */
            @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
    }
    requirement fullSuccess {
        doc /* Full success: minimum success and the body, at least 100 t, is in the DRO within
             * the nominal duration with Lantern able to dock. */
        require minimumSuccess;
        requirement <'FS-001'> delivered : SuccessCriterion {
            doc /* At least 100 t of body is in the designated DRO within 2 200 days of launch. */
            @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        }
        requirement <'FS-002'> accessible : SuccessCriterion {
            doc /* Lantern docks and reaches the surface during the utilisation phase. */
            @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        }
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
    }

    // ---- Measures of effectiveness and performance ---------------------------------------

    part def MissionMeasures {
        doc /* The measures the board and the system team watch. MOEs are mission-level outcomes;
             * MOPs are system quantities that drive them. Values are the current estimates. */
        #moe attribute returnedMass : MassValue;
        #moe attribute returnedMassPerXenon : Real;
        #moe attribute timeToDelivery : DurationValue;
        #moe attribute earthImpactProbability : Real;
        #moe attribute targetEnvelopeCoverage : Real;
        #mop attribute sepThrust : ForceValue;
        #mop attribute specificImpulse : DurationValue;
        #mop attribute stackAcceleration : AccelerationValue;
        #mop attribute captureBagDiameter : LengthValue;
        #mop attribute massEstimateUncertainty : Real;
        #mop attribute rangingAccuracy : LengthValue;
    }

    part missionMeasures : MissionMeasures {
        doc /* Current best estimates, derived from the backbone where the model carries them:
             * the body mass from TethysEnvironment::amaranth, the thrust from SepThrust at
             * 40 kW, 2 900 s and 0.65 efficiency, the acceleration from thrust over the stack mass. */
        attribute :>> returnedMass = TethysEnvironment::amaranth.mass;
        attribute :>> returnedMassPerXenon = TethysEnvironment::amaranth.mass / TethysTug::argent.sep.xenonMass;
        attribute :>> timeToDelivery = 2200 [d];
        attribute :>> earthImpactProbability = 4.0e-7;
        attribute :>> targetEnvelopeCoverage = 0.95;
        attribute :>> sepThrust = TethysEnvironment::SepThrust(40000.0, 2900.0, 0.65) [N];
        attribute :>> specificImpulse = TethysTug::argent.sep.specificImpulse;
        attribute :>> stackAcceleration = sepThrust / (returnedMass + TethysTug::argent.wetMass);
        attribute :>> captureBagDiameter = 15 [m];
        attribute :>> massEstimateUncertainty = 0.08;
        attribute :>> rangingAccuracy = 2 [m];
    }

    // ---- Technical performance measures with margins -------------------------------------

    attribute def MassTpm {
        doc /* A tracked mass with its allocation, current best estimate, growth contingency and
             * the margin the allocation leaves over the contingency-loaded estimate. */
        attribute allocated : MassValue;
        attribute currentBestEstimate : MassValue;
        attribute contingencyFraction : Real;
        attribute predicted : MassValue = currentBestEstimate * (1.0 + contingencyFraction);
        attribute marginFraction : Real = (allocated - predicted) / allocated;
    }
    attribute def PowerTpm {
        doc /* A tracked power with allocation, estimate, contingency and margin. */
        attribute allocated : PowerValue;
        attribute currentBestEstimate : PowerValue;
        attribute contingencyFraction : Real;
        attribute predicted : PowerValue = currentBestEstimate * (1.0 + contingencyFraction);
        attribute marginFraction : Real = (allocated - predicted) / allocated;
    }
    attribute def DurationTpm {
        doc /* A tracked duration with allocation, estimate, contingency and margin. */
        attribute allocated : DurationValue;
        attribute currentBestEstimate : DurationValue;
        attribute contingencyFraction : Real;
        attribute predicted : DurationValue = currentBestEstimate * (1.0 + contingencyFraction);
        attribute marginFraction : Real = (allocated - predicted) / allocated;
    }

    constraint def MarginAtLeast {
        doc /* A TPM keeps at least the required margin at this lifecycle stage. */
        in margin : Real;
        in required : Real;
        margin >= required
    }

    part technicalPerformanceMeasures {
        doc /* The TPM register at the current (PDR) stage; the house margin at PDR is 15 % on mass
             * and power, 10 % on propellant and 5 % on duration. The estimates are the backbone
             * values where it carries them. */
        attribute tugDryMass : MassTpm {
            doc /* Argent dry mass against the 7 000 kg allocation. */
            attribute :>> allocated = 7000.0 [kg];
            attribute :>> currentBestEstimate = TethysTug::argent.dryMass;
            attribute :>> contingencyFraction = 0.0;
        }
        attribute arrayPower : PowerTpm {
            doc /* Power demand at 1 AU (SEP plus bus) against the array power generated; margin is
                 * the excess of generation over demand. */
            attribute :>> allocated = TethysTug::argent.eps.arrayPowerAtOneAu;
            attribute :>> currentBestEstimate = 38000.0 [W];
            attribute :>> contingencyFraction = 0.0;
        }
        attribute xenonLoad : MassTpm {
            doc /* Xenon required for the nominal return against the 6 600 kg loaded. */
            attribute :>> allocated = TethysTug::argent.sep.xenonMass;
            attribute :>> currentBestEstimate = 5300.0 [kg];
            attribute :>> contingencyFraction = 0.10;
        }
        attribute missionDuration : DurationTpm {
            doc /* Launch-to-DRO duration against the 2 200 d allocation. */
            attribute :>> allocated = 2200.0 [d];
            attribute :>> currentBestEstimate = 1900.0 [d];
            attribute :>> contingencyFraction = 0.05;
        }
        attribute launchMass : MassTpm {
            doc /* Stack launch mass against the Arcturus-5H performance at C3 = 2 km2/s2. */
            attribute :>> allocated = TethysLaunch::arcturus5H.performanceAtC3;
            attribute :>> currentBestEstimate = TethysTug::argent.wetMass + TethysInspector::wren.wetMass;
            attribute :>> contingencyFraction = 0.10;
        }
        assert constraint tugDryMassMargin : MarginAtLeast { in margin = tugDryMass.marginFraction; in required = 0.15; }
        assert constraint arrayPowerMargin : MarginAtLeast { in margin = arrayPower.marginFraction; in required = 0.15; }
        assert constraint xenonMargin : MarginAtLeast { in margin = xenonLoad.marginFraction; in required = 0.10; }
        assert constraint durationMargin : MarginAtLeast { in margin = missionDuration.marginFraction; in required = 0.05; }
        assert constraint launchMassMargin : MarginAtLeast { in margin = launchMass.marginFraction; in required = 0.10; }
    }

    // ---- Mission context and capabilities -------------------------------------------------

    part def ExternalBody {
        doc /* A natural body in the mission context; its gravitational parameter is what the
             * trajectory sees. */
        attribute gravitationalParameter : Real;
    }

    part missionContext {
        doc /* The system in its environment: what it exchanges with, and what it does not control.
             * The segments themselves are TethysSystem::tethysSystem. */
        ref part system :> tethysSystem;
        part sun : ExternalBody {
            doc /* The Sun: power source, SRP and the heliocentric frame; mu in km3/s2. */
            attribute :>> gravitationalParameter = 1.32712440018e11;
        }
        part earth : ExternalBody {
            doc /* The Earth: launch site, ground stations and the body the return must avoid. */
            attribute :>> gravitationalParameter = 398600.4418;
        }
        part moon : ExternalBody {
            doc /* The Moon: gravity assist and the primary of the destination DRO. */
            attribute :>> gravitationalParameter = 4902.8;
        }
        ref part target :> system.target;
        ref part visitingVehicle :> system.visitor;
    }

    action def Capability {
        doc /* A thing the mission can do, stated without saying how; use cases exercise them. */
    }
    part capabilities {
        doc /* The capability register the ConOps use cases map onto. */
        action escapeDirectly : Capability { doc /* Leave Earth on the launcher's direct-escape injection. */ }
        action cruiseUnderSep : Capability { doc /* Transfer under solar-electric thrust with coast arcs. */ }
        action findAndRendezvous : Capability { doc /* Detect a faint body optically and rendezvous with it. */ }
        action characterise : Capability { doc /* Determine shape, mass and spin from a hovering inspector. */ }
        action captureAndDespin : Capability { doc /* Envelop a rotating body, cinch, and remove its spin. */ }
        action returnToCislunar : Capability { doc /* Fly the stack to a lunar DRO on an Earth-safe trajectory. */ }
        action hostVisitors : Capability { doc /* Hold attitude and a docking port for Lantern. */ }
        action deflectMeasurably : Capability { doc /* Slow-push the body and measure the deflection. */ }
        action disposeSafely : Capability { doc /* Separate from the body and passivate in heliocentric orbit. */ }
    }

    // ---- ConOps use cases ----------------------------------------------------------------

    part def Operator {
        doc /* The flight controller role at the operations centre. */
    }
    part def LaunchAuthority {
        doc /* The launch provider's range and vehicle authority. */
    }

    use case def RetrieveAmaranth {
        doc /* The design reference mission: launch, cruise out, find, characterise, capture,
             * despin, return and insert the body, then host Lantern and dispose of the tug. */
        subject system : TethysSystem::TethysFlightSegment;
        actor operator : Operator;
        actor launchAuthority : LaunchAuthority;
        actor visitor : VisitingVehicle;
        objective {
            doc /* Full mission success as defined by fullSuccess. */
            require fullSuccess;
        }
    }

    use case def LaunchAndEscape {
        doc /* Lift off, direct escape at C3 of about 2 km2/s2, separation, tip-off damping, array
             * deployment and first acquisition by Meridian. */
        subject system : TethysSystem::TethysFlightSegment;
        actor operator : Operator;
        actor launchAuthority : LaunchAuthority;
    }
    use case def CommissionSep {
        doc /* Enable the high-voltage bus, check each thruster through conditioning, ignition,
             * throttle and gimbal sweeps, then the first long firing. */
        subject system : TethysSystem::TethysFlightSegment;
        actor operator : Operator;
    }
    use case def CruiseOutbound {
        doc /* Weeks-long thrust arcs with coast periods for navigation and momentum management;
             * one shift per day of ground contact. */
        subject system : TethysSystem::TethysFlightSegment;
        actor operator : Operator;
    }
    use case def ApproachAndRendezvous {
        doc /* Detect the body with the narrow-angle camera, run the optical-navigation campaign,
             * ramp thrust down and hold at 1 to 10 km, then 100 m. */
        subject system : TethysSystem::TethysFlightSegment;
        actor operator : Operator;
    }
    use case def CharacteriseWithInspector {
        doc /* Release Wren, acquire the proximity link, circumnavigate at 20 to 100 m and build the
             * shape, mass and spin products for the capture-commit review. */
        subject system : TethysSystem::TethysFlightSegment;
        actor operator : Operator;
    }
    use case def CaptureAndDespin {
        doc /* Approach along the spin axis, deploy and inflate the bag, envelop, cinch, then despin
             * with the reaction-control system and estimate the stack mass properties. */
        subject system : TethysSystem::TethysFlightSegment;
        actor operator : Operator;
    }
    use case def ReturnAndInsert {
        doc /* Depart on biased Earth-impact-exclusion arcs, measure a deflection, fly the lunar
             * gravity assist and insert into the DRO. */
        subject system : TethysSystem::TethysFlightSegment;
        actor operator : Operator;
    }
    use case def HostVisitingVehicle {
        doc /* Hold attitude, configure the docking port, inhibit thrusters and pass power and data
             * while Lantern docks and works at the surface. */
        subject system : TethysSystem::TethysFlightSegment;
        actor operator : Operator;
        actor visitor : VisitingVehicle;
    }
    use case def SeparateAndDispose {
        doc /* Release the bag, back away, depart to heliocentric orbit and passivate. */
        subject system : TethysSystem::TethysFlightSegment;
        actor operator : Operator;
    }
    use case def RecoverFromSafeMode {
        doc /* Off-nominal thread: a safe-mode entry during a thrust arc, Sun-safe hold, ground
             * diagnosis and return to thrust within the missed-thrust allowance. */
        subject system : TethysSystem::TethysFlightSegment;
        actor operator : Operator;
    }

    use case retrieveAmaranth : RetrieveAmaranth {
        doc /* The design reference mission as a sequence of included use cases. */
        include use case launchAndEscape : LaunchAndEscape;
        include use case commissionSep : CommissionSep;
        include use case cruiseOutbound : CruiseOutbound;
        include use case approachAndRendezvous : ApproachAndRendezvous;
        include use case characterise : CharacteriseWithInspector;
        include use case captureAndDespin : CaptureAndDespin;
        include use case returnAndInsert : ReturnAndInsert;
        include use case hostVisitingVehicle : HostVisitingVehicle;
        include use case separateAndDispose : SeparateAndDispose;
        first launchAndEscape then commissionSep;
        first commissionSep then cruiseOutbound;
        first cruiseOutbound then approachAndRendezvous;
        first approachAndRendezvous then characterise;
        first characterise then captureAndDespin;
        first captureAndDespin then returnAndInsert;
        first returnAndInsert then hostVisitingVehicle;
        first hostVisitingVehicle then separateAndDispose;
    }
    use case recoverFromSafeMode : RecoverFromSafeMode {
        doc /* The off-nominal thread, applicable in every cruise phase. */
    }

    // ---- Assumptions and constraints: the target cases -------------------------------------

    part targetCases {
        doc /* The assumed bodies the system is sized against. Ground-based knowledge of Amaranth
             * spans a factor of two in diameter (albedo unknown), 1 200 to 3 500 kg/m3 in density
             * and 100 s to 600 s in spin period; mass follows from SphereMass so the cases stay
             * consistent with TethysEnvironment. Requirements read these parts; TargetCase offers
             * the same bodies as a variation for configuration selection. */
        part small : SmallBody {
            doc /* High-albedo small case: 4.0 m, low density, slow spin. Below 100 t whatever the
                 * tug does, so outside the TR-001 envelope (covered by minimum success). */
            attribute :>> meanDiameter = 4.0 [m];
            attribute :>> bulkDensity = 1200.0 [kg/m^3];
            attribute :>> mass = TethysEnvironment::SphereMass(4.0, 1200.0) [kg];
            attribute :>> rotationPeriod = 600.0 [s];
        }
        part nominal : SmallBody {
            doc /* The nominal case: TethysEnvironment::amaranth. */
            attribute :>> meanDiameter = TethysEnvironment::amaranth.meanDiameter;
            attribute :>> bulkDensity = TethysEnvironment::amaranth.bulkDensity;
            attribute :>> mass = TethysEnvironment::amaranth.mass;
            attribute :>> rotationPeriod = TethysEnvironment::amaranth.rotationPeriod;
        }
        part large : SmallBody {
            doc /* Low-albedo large case: 9.5 m at the nominal density, fast spin; it bounds the
                 * capture bag and the despin budget. */
            attribute :>> meanDiameter = 9.5 [m];
            attribute :>> bulkDensity = 2200.0 [kg/m^3];
            attribute :>> mass = TethysEnvironment::SphereMass(9.5, 2200.0) [kg];
            attribute :>> rotationPeriod = 100.0 [s];
        }
        part dense : SmallBody {
            doc /* Nominal size at the top of the density range (a stony-iron body); it bounds the
                 * return propellant and the stack inertia. */
            attribute :>> meanDiameter = TethysEnvironment::amaranth.meanDiameter;
            attribute :>> bulkDensity = 3500.0 [kg/m^3];
            attribute :>> mass = TethysEnvironment::SphereMass(6.8, 3500.0) [kg];
            attribute :>> rotationPeriod = TethysEnvironment::amaranth.rotationPeriod;
        }
    }

    variation part def TargetCase :> SmallBody {
        doc /* The target-uncertainty cases as a variation: a configuration of the mission selects
             * one variant, each of which is one of the assumed bodies in targetCases. */
        variant part small :> targetCases.small {
            doc /* The small case. */
        }
        variant part nominal :> targetCases.nominal {
            doc /* The nominal case. */
        }
        variant part large :> targetCases.large {
            doc /* The large case. */
        }
        variant part dense :> targetCases.dense {
            doc /* The dense case. */
        }
    }

    part def ProgrammeAssumptions {
        doc /* Externally given assumptions the requirements rest on. If one fails, the
             * requirement that assumes it is re-opened, not waived. */
        attribute directEscapeC3 : Real;
        attribute targetAvailableFrom : String;
        attribute meridianPassesPerDay : Integer;
        attribute lanternReadyBy : String;
        attribute pdrMassMargin : Real;
    }
    part programmeAssumptions : ProgrammeAssumptions {
        doc /* The current assumption set, each with its originator. */
        attribute :>> directEscapeC3 = 2.0;
        attribute :>> targetAvailableFrom = "launch window opening 2031-03";
        attribute :>> meridianPassesPerDay = 1;
        attribute :>> lanternReadyBy = "DRO insertion plus 180 d";
        attribute :>> pdrMassMargin = 0.15;
    }

    metadata def DrivingRequirement {
        doc /* Marks a requirement that sizes the system; driver names what it drives. */
        attribute driver : String;
    }
}
