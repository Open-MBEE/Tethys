// Who looks at the model, and how: the stakeholder roles, the concerns each holds, the viewpoints
// that frame those concerns, and the views that satisfy them — requirements, interface control,
// budget, timeline and mode views — with the renderings they are drawn in. `-render-all` draws
// every view here; the documents in TethysDocuments embed them. Views that need an OpenSysML
// rendering live in TethysViewsTooling so this file stays in the mission tier.
package TethysViews {
    private import Views::*;
    private import StandardViewDefinitions::*;
    private import TethysMission::Mission;

    // ---- stakeholder roles -----------------------------------------------------------------
    part def StakeholderRole {
        doc /* A role that reads the model: who a viewpoint is written for. The project's named
             * stakeholders (TethysRequirements, WP-A) play these roles. */
    }
    part def ProgrammeManager :> StakeholderRole {
        doc /* Owns cost, schedule and the review gates; reads the mission requirements, the risk
             * register and the lifecycle. */
    }
    part def SystemsEngineer :> StakeholderRole {
        doc /* Owns the requirement tree, its derivation and its traceability to the design. */
    }
    part def InterfaceManager :> StakeholderRole {
        doc /* Owns every interface control document between two segments or two
             * organisations. */
    }
    part def ChiefEngineer :> StakeholderRole {
        doc /* Owns the engineering budgets — mass, power, propellant, data, link — and their
             * margins against the policy per phase. */
    }
    part def MissionOperationsLead :> StakeholderRole {
        doc /* Owns the flight timeline, the operational modes and the operations products. */
    }
    part def VerificationLead :> StakeholderRole {
        doc /* Owns the verification programme: method, level and stage of every requirement. */
    }
    part def SafetyAssuranceLead :> StakeholderRole {
        doc /* Owns hazards, failure modes, fault management and the risk register. */
    }

    // ---- concerns -------------------------------------------------------------------------
    concern def RequirementTraceability {
        doc /* Every requirement is readable in its tier, with its parent and its verification;
             * nothing is orphaned. */
        subject mission : Mission;
        stakeholder systemsEngineer : SystemsEngineer;
        stakeholder programmeManager : ProgrammeManager;
    }
    concern def InterfaceControl {
        doc /* Every boundary between segments, and between the mission and its external
             * partners, is defined by one interface definition with both ends typed. */
        subject mission : Mission;
        stakeholder interfaceManager : InterfaceManager;
    }
    concern def BudgetClosure {
        doc /* Every engineering budget rolls up from the part tree and closes with margin
             * against the phase policy. */
        subject mission : Mission;
        stakeholder chiefEngineer : ChiefEngineer;
    }
    concern def MissionSequence {
        doc /* The flight phases and the events bounding them are visible in order, with the
             * lifecycle reviews that release each. */
        subject mission : Mission;
        stakeholder operationsLead : MissionOperationsLead;
    }
    concern def ModeBehaviour {
        doc /* The operational modes of the flight system, their transitions and the fault
             * responses that force them are visible as one machine. */
        subject mission : Mission;
        stakeholder operationsLead : MissionOperationsLead;
        stakeholder safetyLead : SafetyAssuranceLead;
    }
    concern def VerificationCoverage {
        doc /* Every requirement names how, where and when it is verified, and every
             * verification case closes a requirement. */
        subject mission : Mission;
        stakeholder verificationLead : VerificationLead;
    }
    concern def RiskExposure {
        doc /* Every open risk is visible with its likelihood, consequence and mitigation. */
        subject mission : Mission;
        stakeholder programmeManager : ProgrammeManager;
        stakeholder safetyLead : SafetyAssuranceLead;
    }

    concern requirementTraceability : RequirementTraceability {
        doc /* The RequirementTraceability concern as the project holds it. */
    }
    concern interfaceControl : InterfaceControl {
        doc /* The InterfaceControl concern as the project holds it. */
    }
    concern budgetClosure : BudgetClosure {
        doc /* The BudgetClosure concern as the project holds it. */
    }
    concern missionSequence : MissionSequence {
        doc /* The MissionSequence concern as the project holds it. */
    }
    concern modeBehaviour : ModeBehaviour {
        doc /* The ModeBehaviour concern as the project holds it. */
    }
    concern verificationCoverage : VerificationCoverage {
        doc /* The VerificationCoverage concern as the project holds it. */
    }
    concern riskExposure : RiskExposure {
        doc /* The RiskExposure concern as the project holds it. */
    }

    // ---- viewpoints, one per stakeholder reading ---------------------------------------------
    viewpoint def RequirementsViewpoint {
        doc /* The systems engineer's and verification lead's reading: the requirement tree with
             * its verification. */
        frame requirementTraceability {
            doc /* Framed: requirementTraceability. */
        }
        frame verificationCoverage {
            doc /* Framed: verificationCoverage. */
        }
    }
    viewpoint def InterfaceViewpoint {
        doc /* The interface manager's reading: every segment boundary and the interface
             * definition it is controlled by. */
        frame concern interfaceControl : InterfaceControl {
            doc /* Framed: interface control, declared here rather than referenced. */
        }
    }
    viewpoint def BudgetViewpoint {
        doc /* The chief engineer's reading: the budget-carrying elements with their values. */
        frame budgetClosure {
            doc /* Framed: budgetClosure. */
        }
    }
    viewpoint def OperationsViewpoint {
        doc /* The operations lead's reading: the timeline and the mode machine. */
        frame missionSequence {
            doc /* Framed: missionSequence. */
        }
        frame modeBehaviour {
            doc /* Framed: modeBehaviour. */
        }
    }
    viewpoint def AssuranceViewpoint {
        doc /* The safety and assurance lead's and programme manager's reading: risks and the
             * modes that respond to failures. */
        frame riskExposure {
            doc /* Framed: riskExposure. */
        }
        frame modeBehaviour {
            doc /* Framed: modeBehaviour. */
        }
    }

    viewpoint requirementsViewpoint : RequirementsViewpoint {
        doc /* The RequirementsViewpoint as the project applies it. */
    }
    viewpoint interfaceViewpoint : InterfaceViewpoint {
        doc /* The InterfaceViewpoint as the project applies it. */
    }
    viewpoint budgetViewpoint : BudgetViewpoint {
        doc /* The BudgetViewpoint as the project applies it. */
    }
    viewpoint operationsViewpoint : OperationsViewpoint {
        doc /* The OperationsViewpoint as the project applies it. */
    }
    viewpoint assuranceViewpoint : AssuranceViewpoint {
        doc /* The AssuranceViewpoint as the project applies it. */
    }

    // ---- renderings -------------------------------------------------------------------------
    rendering def BudgetTable :> TabularRendering {
        doc /* A table of budget-carrying elements, one row per exposed element. */
    }
    rendering def TimelineTree :> GraphicalRendering {
        doc /* The phases and events of a timeline as a containment tree in succession order. */
    }
    rendering budgetTable : BudgetTable :> asElementTable;
    rendering timelineTree : TimelineTree :> asTreeDiagram;

    // ---- view definitions -----------------------------------------------------------------
    view def RequirementsTreeView {
        doc /* The requirements of a tier as a tree; the filter keeps the requirement usages
             * that carry a Verification annotation, so an unverifiable requirement is absent
             * and visibly so. */
        filter @TethysRequirements::Verification;
        render asTreeDiagram;
    }
    view def RequirementsTableView {
        doc /* The same requirements as a table, one row per requirement. */
        filter @TethysRequirements::Verification;
        render asElementTable;
    }
    view def InterfaceView :> InterconnectionView {
        doc /* The segments and the interfaces between them as an interconnection diagram. */
    }
    view def BudgetView {
        doc /* Budget-carrying elements in the budget table rendering. */
        render budgetTable;
    }
    view def TimelineView {
        doc /* A timeline (phases and the events bounding them) in the timeline tree rendering. */
        render rendering tree : TimelineTree :> timelineTree;
    }
    view def ModeView :> StateTransitionView {
        doc /* A mode machine as a state-transition diagram. */
    }

    // ---- views ------------------------------------------------------------------------------
    view requirementsTree : RequirementsTreeView {
        doc /* The L1 mission requirements. */
        expose TethysRequirements::*;
        satisfy requirementsViewpoint {
            doc /* This view answers the requirementsViewpoint. */
        }
    }
    view requirementsTable : RequirementsTableView {
        doc /* The L1 mission requirements tabulated. */
        expose TethysRequirements::**[@RequirementDerivation::OriginalRequirementMetadata];
        satisfy requirementsViewpoint {
            doc /* This view answers the requirementsViewpoint. */
        }
    }
    view segmentInterfaces : InterfaceView {
        doc /* The system with its five segment-level parts and the four top-level interfaces:
             * launch adapter, deep-space link, capture and visitor docking. TethysLayout
             * positions the parts, sizes the canvas and routes the interfaces. */
        expose TethysSystem::tethysSystem;
        satisfy interfaceViewpoint {
            doc /* This view answers the interfaceViewpoint. */
        }
    }
    view flightSegmentWiring : InterfaceView {
        doc /* Inside the flight segment: the tug ↔ inspector carrier and relay interfaces. */
        expose TethysSystem::TethysFlightSegment;
        satisfy interfaceViewpoint {
            doc /* This view answers the interfaceViewpoint. */
        }
    }
    view tugPowerBus : InterfaceView {
        doc /* The tug's power interfaces from the electrical power subsystem to every load. */
        expose TethysTug::Tug;
        satisfy interfaceViewpoint {
            doc /* This view answers the interfaceViewpoint. */
        }
    }
    view interfaceDefinitions {
        doc /* Every interface definition an ICD is written against, with its ports and items. */
        expose TethysInterfaces::*;
        render asElementTable;
        satisfy interfaceViewpoint {
            doc /* This view answers the interfaceViewpoint. */
        }
    }
    view massBudget : BudgetView {
        doc /* The flight elements that carry mass: the tug, its subsystems and the inspector. */
        expose TethysTug::argent;
        expose TethysInspector::wren;
        satisfy budgetViewpoint {
            doc /* This view answers the budgetViewpoint. */
        }
    }
    view missionTimeline : TimelineView {
        doc /* The flight from lift-off to disposal. */
        expose TethysMission::flightTimeline;
        satisfy operationsViewpoint {
            doc /* This view answers the operationsViewpoint. */
        }
    }
    view projectLifecycle : TimelineView {
        doc /* The project phases and the reviews that close them. */
        expose TethysMission::projectLifecycle;
        satisfy operationsViewpoint {
            doc /* This view answers the operationsViewpoint. */
        }
    }
    view modeMachine : ModeView {
        doc /* The flight system's mode machine. Until the mode package lands its state
             * definition this view exposes the tug, which the renderer reports is no state
             * machine; the exposed element then moves to that definition. */
        expose TethysTug::Tug;
        satisfy operationsViewpoint {
            doc /* This view answers the operationsViewpoint. */
        }
        satisfy assuranceViewpoint {
            doc /* This view answers the assuranceViewpoint. */
        }
    }
    view environmentText {
        doc /* The target body's design constants in textual notation, for a review package. */
        expose TethysEnvironment::amaranth;
        render asTextualNotation;
    }
}
