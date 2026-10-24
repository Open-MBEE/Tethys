# Flight dynamics tool (Meridian Sextant) design description

## Purpose

*Component definition*

| name | type | documentation |
| --- | --- | --- |
| FlightDynamicsTool |  | Meridian Sextant, the flight dynamics tool: orbit determination of Argent and of<br>Amaranth from the stations' tracking data, low-thrust arc and DRO insertion design,<br>ephemeris products for the stations and the pass planner, and the delta-v ledger. |

## Ports

*Ports of the component*

| name | type | documentation |
| --- | --- | --- |
| tracking | TethysMeridian::ProductPort |  |
| solutions | TethysMeridian::ProductPort |  |

## Figures and tables

*Attributes the component carries*

| name | type | documentation |
| --- | --- | --- |
| productName |  |  |
| version |  |  |
| odArcLength | ISQBase::DurationValue |  |
| passesPerArc | ScalarValues::Natural |  |

*Parts the component owns*

| name | type | documentation |
| --- | --- | --- |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| flightDynamicsTool | flightDynamicsProducts | 1 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| flightDynamicsTool | levelA | Meridian Sextant: orbit determination and manoeuvre design. |

One volume per component of the Meridian Operations Suite, in the order of TethysGroundSoftware::MeridianOperationsSuite::components. Every table is a query over TethysGroundSoftware, TethysSoftwareRequirements, TethysSoftwareAssurance and TethysVerification.
