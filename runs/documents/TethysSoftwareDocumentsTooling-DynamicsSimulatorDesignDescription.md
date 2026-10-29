# Dynamics simulator (Meridian Orrery) design description

## Purpose

*Component definition*

| name | type | documentation |
| --- | --- | --- |
| DynamicsSimulator |  | Meridian Orrery: the six-degree-of-freedom proximity-operations simulator with the<br>GNC flight code in the loop. |

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
| dynamicsSimulator | TethysVerification::TestBed | Six-degree-of-freedom proximity-operations simulator with the GNC flight code. |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| dynamicsSimulator | simulatorFidelity | 1 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| dynamicsSimulatorSoftware | levelC | Meridian Orrery, the dynamics simulator. |

One volume per component of the Meridian Operations Suite, in the order of TethysGroundSoftware::MeridianOperationsSuite::components. Every table is a query over TethysGroundSoftware, TethysSoftwareRequirements, TethysSoftwareAssurance and TethysVerification.
