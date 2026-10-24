# Pass planner (Meridian Almanac) design description

## Purpose

*Component definition*

| name | type | documentation |
| --- | --- | --- |
| PassPlanner |  | Meridian Almanac, the pass planner: from the stations' visibility of the tug and<br>the MLS-2 rate set of the planned mode it allocates the day's passes, resolves the<br>conflicts between the three stations and the relay windows, and writes the<br>DailyPassPlan the operations model flies. |

## Ports

*Ports of the component*

| name | type | documentation |
| --- | --- | --- |
| ephemerides | TethysMeridian::ProductPort |  |
| plans | TethysMeridian::ProductPort |  |

## Figures and tables

*Attributes the component carries*

| name | type | documentation |
| --- | --- | --- |
| productName |  |  |
| version |  |  |
| visibilityHalfWidth | ISQSpaceTime::AngularMeasureValue |  |
| proximityRates | TethysSoftwareIcds::LinkRateSet |  |
| coastRates | TethysSoftwareIcds::LinkRateSet |  |

*Parts the component owns*

| name | type | documentation |
| --- | --- | --- |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| passPlanner | passPlanningVolume, plannedPassesFitTheLink | 2 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| passPlanner | levelC | Meridian Almanac: pass planning. |

One volume per component of the Meridian Operations Suite, in the order of TethysGroundSoftware::MeridianOperationsSuite::components. Every table is a query over TethysGroundSoftware, TethysSoftwareRequirements, TethysSoftwareAssurance and TethysVerification.
