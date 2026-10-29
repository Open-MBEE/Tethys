# Flatsat hardware-in-the-loop test bed (Meridian Anvil) design description

## Purpose

*Component definition*

| name | type | documentation |
| --- | --- | --- |
| HardwareInTheLoopTestBed |  | Meridian Anvil: the flatsat's engineering-model avionics with the flight software,<br>driven by the suite. |

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
| flatsat | TethysVerification::TestBed | Engineering-model avionics with flight software, used for fault-response and<br>autonomy tests. |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| flatsat | simulatorFidelity | 1 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| flatsatSimulator | levelC | Meridian Anvil, the hardware-in-the-loop test bed. |

One volume per component of the Meridian Operations Suite, in the order of TethysGroundSoftware::MeridianOperationsSuite::components. Every table is a query over TethysGroundSoftware, TethysSoftwareRequirements, TethysSoftwareAssurance and TethysVerification.
