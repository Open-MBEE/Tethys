# Proximity planner (Meridian Compass) design description

## Purpose

*Component definition*

| name | type | documentation |
| --- | --- | --- |
| ProximityPlanner |  | Meridian Compass, the proximity-operations planner: relative navigation products,<br>the keep-out check of FR-002 on every planned approach, the go/no-go checklist and<br>the abort criteria the capture sequence is uplinked with. |

## Ports

*Ports of the component*

| name | type | documentation |
| --- | --- | --- |
| navigation | TethysMeridian::ProductPort |  |
| plans | TethysMeridian::ProductPort |  |

## Figures and tables

*Attributes the component carries*

| name | type | documentation |
| --- | --- | --- |
| productName |  |  |
| version |  |  |
| keepOutRadius | ISQBase::LengthValue |  |
| standoff | TethysGroundSoftware::RelativeNavigationProduct |  |
| finalApproach | TethysGroundSoftware::RelativeNavigationProduct |  |
| abortRangeRate | ISQSpaceTime::SpeedValue |  |
| abortRangeUncertainty | ISQBase::LengthValue |  |

*Parts the component owns*

| name | type | documentation |
| --- | --- | --- |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| proximityPlanner | proximityGoNoGo | 1 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| proximityPlanner | levelC | Meridian Compass: proximity-operations planning and the go/no-go checklist. |

One volume per component of the Meridian Operations Suite, in the order of TethysGroundSoftware::MeridianOperationsSuite::components. Every table is a query over TethysGroundSoftware, TethysSoftwareRequirements, TethysSoftwareAssurance and TethysVerification.
