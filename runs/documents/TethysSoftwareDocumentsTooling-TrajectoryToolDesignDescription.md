# Flight-software-in-the-loop simulator (Meridian Mirror) design description

## Purpose

*Component definition*

| name | type | documentation |
| --- | --- | --- |
| FlightSoftwareInTheLoopSimulator |  | Meridian Mirror: the flight software image running on an emulated flight computer<br>with simulated dynamics, used for sequence and procedure validation. |

## Ports

*Ports of the component*

| name | type | documentation |
| --- | --- | --- |

## Figures and tables

*Attributes the component carries*

| name | type | documentation |
| --- | --- | --- |
| productName |  |  |
| version |  |  |
| flightSoftwareInTheLoop |  |  |
| hardwareInTheLoop |  |  |

*Parts the component owns*

| name | type | documentation |
| --- | --- | --- |

## Test bed

*Programme test bed this simulator retypes*

| name | type | documentation |
| --- | --- | --- |
| trajectoryTool | TethysVerification::TestBed | The flight dynamics facility's propagation tool used for the Earth-impact and<br>DRO analyses, validated against independent propagation. |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| trajectoryTool | simulatorFidelity | 1 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| flightSoftwareSimulator | levelC | Meridian Mirror, the flight-software-in-the-loop simulator. |

One volume per component of the Meridian Operations Suite, in the order of TethysGroundSoftware::MeridianOperationsSuite::components. Every table is a query over TethysGroundSoftware, TethysSoftwareRequirements, TethysSoftwareAssurance and TethysVerification.
