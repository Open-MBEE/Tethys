// The requirement tiers, the verification vocabulary every requirement carries, and the L1
// mission requirements the rest of the tree derives from.
package TethysRequirements {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import VerificationCases::VerificationMethodKind;
    private import ModelingMetadata::*;
    private import RequirementDerivation::*;

    enum def RequirementTier {
        doc /* The level a requirement is written at. */
        enum mission;
        enum system;
        enum subsystem;
        enum component;
    }
    enum def VerificationLevel {
        doc /* The integration level a requirement is verified at. */
        enum unit;
        enum subsystem;
        enum system;
        enum mission;
    }
    enum def VerificationStage {
        doc /* The milestone a verification closes against. */
        enum qualification;
        enum acceptance;
        enum preLaunch;
        enum inFlight;
    }

    metadata def Verification {
        doc /* How, where and when a requirement is verified. */
        attribute method : VerificationMethodKind;
        attribute level : VerificationLevel;
        attribute stage : VerificationStage;
    }

    requirement def MissionRequirement {
        doc /* An L1 requirement: a statement of what the mission achieves. */
        attribute tier : RequirementTier = RequirementTier::mission;
    }
    requirement def SystemRequirement {
        doc /* An L2 requirement on a segment or the flight system. */
        attribute tier : RequirementTier = RequirementTier::system;
    }
    requirement def SubsystemRequirement {
        doc /* An L3 requirement on a subsystem. */
        attribute tier : RequirementTier = RequirementTier::subsystem;
    }
    requirement def ComponentRequirement {
        doc /* An L4 requirement on a unit. */
        attribute tier : RequirementTier = RequirementTier::component;
    }

    requirement <'TR-001'> retrieval : MissionRequirement {
        doc /* The mission shall deliver the target body 2031 QX, intact and with a mass of at
             * least 100 t, into the designated lunar distant retrograde orbit. */
        attribute deliveredMass : MassValue;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @original;
        require constraint { deliveredMass >= 100.0e3 [kg] }
    }
    requirement <'TR-002'> missionDuration : MissionRequirement {
        doc /* The mission shall complete the insertion of the target into the distant
             * retrograde orbit within 1 300 days of launch. */
        attribute nominalDuration : DurationValue;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @original;
        require constraint { nominalDuration <= 1300 [d] }
    }
    requirement <'TR-003'> characterisation : MissionRequirement {
        doc /* Before committing to capture, the mission shall determine the target's shape,
             * mass to within 10 % and spin state, and shall confirm that each lies within the
             * capture system's design envelope. */
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @original;
    }
    requirement <'TR-004'> launchCompatibility : MissionRequirement {
        doc /* The flight system shall be compatible with the Arcturus-5H launch vehicle and its
             * direct injection to an Earth-escape trajectory. */
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::acceptance; }
        @original;
    }
    requirement <'TR-005'> groundCompatibility : MissionRequirement {
        doc /* The flight system shall communicate through the Meridian deep-space network at
             * every Earth range of the mission. */
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        @original;
    }
    requirement <'TR-006'> cislunarSafety : MissionRequirement {
        doc /* The target body shall be placed in an orbit that remains bound to the Moon for at
             * least 100 years without station-keeping, and no credible failure during the return
             * shall place it on an Earth-impact trajectory. */
        attribute stabilityHorizon : DurationValue;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::mission; stage = VerificationStage::qualification; }
        @original;
        require constraint { stabilityHorizon >= 36525.0 [d] }
    }
    requirement <'TR-007'> missionClass : MissionRequirement {
        doc /* The flight system shall carry no single-point failure that ends the mission. */
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
        @original;
    }
    requirement <'TR-008'> deflectionDemonstration : MissionRequirement {
        doc /* While attached to the target, the mission shall demonstrate a slow-push
             * deflection and shall measure the resulting change in the target's heliocentric
             * velocity to an accuracy of 1 mm/s. */
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @original;
    }
    requirement <'TR-009'> utilisationAccess : MissionRequirement {
        doc /* After delivery, the tug shall hold the target in an attitude and with a docking
             * interface that lets the visiting vehicle Lantern dock and reach the target's
             * surface. */
        @Verification { method = VerificationMethodKind::demo; level = VerificationLevel::mission; stage = VerificationStage::inFlight; }
        @original;
    }
}
