# Tethys Retrieval — Verification Matrix

One row per requirement. The verification cases that close each row are added by the verification package; a requirement without one stays visible here as uncovered.

<a id="matrix"></a>

## Requirements

*L1 requirements*

| Id | Name | Statement | Tier |
| --- | --- | --- | --- |
| TR-001 | retrieval | The mission shall deliver the target body 2031 QX, intact and with a mass of at<br>least 100 t, into the designated lunar distant retrograde orbit. | mission |
| TR-002 | missionDuration | The mission shall complete the insertion of the target into the distant<br>retrograde orbit within 1 300 days of launch. | mission |
| TR-003 | characterisation | Before committing to capture, the mission shall determine the target's shape,<br>mass to within 10 % and spin state, and shall confirm that each lies within the<br>capture system's design envelope. | mission |
| TR-004 | launchCompatibility | The flight system shall be compatible with the Arcturus-5H launch vehicle and its<br>direct injection to an Earth-escape trajectory. | mission |
| TR-005 | groundCompatibility | The flight system shall communicate through the Meridian deep-space network at<br>every Earth range of the mission. | mission |
| TR-006 | cislunarSafety | The target body shall be placed in an orbit that remains bound to the Moon for at<br>least 100 years without station-keeping, and no credible failure during the return<br>shall place it on an Earth-impact trajectory. | mission |
| TR-007 | missionClass | The flight system shall carry no single-point failure that ends the mission. | mission |
| TR-008 | deflectionDemonstration | While attached to the target, the mission shall demonstrate a slow-push<br>deflection and shall measure the resulting change in the target's heliocentric<br>velocity to an accuracy of 1 mm/s. | mission |
| TR-009 | utilisationAccess | After delivery, the tug shall hold the target in an attitude and with a docking<br>interface that lets the visiting vehicle Lantern dock and reach the target's<br>surface. | mission |

*The same requirements as an element table*

<!-- TethysViews::requirementsTable — table rendering (render asElementTable) -->
| Element | Kind | Type | Declared in |
| --- | --- | --- | --- |
| TethysRequirements::retrieval | requirement | MissionRequirement |  |
| deliveredMass | attribute | MassValue | TethysRequirements::retrieval |
|  | metadata usage |  | TethysRequirements::retrieval |
| method | attribute | VerificationMethodKind |  |
| level | attribute | VerificationLevel |  |
| stage | attribute | VerificationStage |  |
|  | metadata usage |  | TethysRequirements::retrieval |
|  | require constraint |  | TethysRequirements::retrieval |
| TethysRequirements::missionDuration | requirement | MissionRequirement |  |
| nominalDuration | attribute | DurationValue | TethysRequirements::missionDuration |
|  | metadata usage |  | TethysRequirements::missionDuration |
| method | attribute | VerificationMethodKind |  |
| level | attribute | VerificationLevel |  |
| stage | attribute | VerificationStage |  |
|  | metadata usage |  | TethysRequirements::missionDuration |
|  | require constraint |  | TethysRequirements::missionDuration |
| TethysRequirements::characterisation | requirement | MissionRequirement |  |
|  | metadata usage |  | TethysRequirements::characterisation |
| method | attribute | VerificationMethodKind |  |
| level | attribute | VerificationLevel |  |
| stage | attribute | VerificationStage |  |
|  | metadata usage |  | TethysRequirements::characterisation |
| TethysRequirements::launchCompatibility | requirement | MissionRequirement |  |
|  | metadata usage |  | TethysRequirements::launchCompatibility |
| method | attribute | VerificationMethodKind |  |
| level | attribute | VerificationLevel |  |
| stage | attribute | VerificationStage |  |
|  | metadata usage |  | TethysRequirements::launchCompatibility |
| TethysRequirements::groundCompatibility | requirement | MissionRequirement |  |
|  | metadata usage |  | TethysRequirements::groundCompatibility |
| method | attribute | VerificationMethodKind |  |
| level | attribute | VerificationLevel |  |
| stage | attribute | VerificationStage |  |
|  | metadata usage |  | TethysRequirements::groundCompatibility |
| TethysRequirements::cislunarSafety | requirement | MissionRequirement |  |
| stabilityHorizon | attribute | DurationValue | TethysRequirements::cislunarSafety |
|  | metadata usage |  | TethysRequirements::cislunarSafety |
| method | attribute | VerificationMethodKind |  |
| level | attribute | VerificationLevel |  |
| stage | attribute | VerificationStage |  |
|  | metadata usage |  | TethysRequirements::cislunarSafety |
|  | require constraint |  | TethysRequirements::cislunarSafety |
| TethysRequirements::missionClass | requirement | MissionRequirement |  |
|  | metadata usage |  | TethysRequirements::missionClass |
| method | attribute | VerificationMethodKind |  |
| level | attribute | VerificationLevel |  |
| stage | attribute | VerificationStage |  |
|  | metadata usage |  | TethysRequirements::missionClass |
| TethysRequirements::deflectionDemonstration | requirement | MissionRequirement |  |
|  | metadata usage |  | TethysRequirements::deflectionDemonstration |
| method | attribute | VerificationMethodKind |  |
| level | attribute | VerificationLevel |  |
| stage | attribute | VerificationStage |  |
|  | metadata usage |  | TethysRequirements::deflectionDemonstration |
| TethysRequirements::utilisationAccess | requirement | MissionRequirement |  |
|  | metadata usage |  | TethysRequirements::utilisationAccess |
| method | attribute | VerificationMethodKind |  |
| level | attribute | VerificationLevel |  |
| stage | attribute | VerificationStage |  |
|  | metadata usage |  | TethysRequirements::utilisationAccess |
