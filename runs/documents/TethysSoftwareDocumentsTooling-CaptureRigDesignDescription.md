# Capture rig controller (Meridian Capstan) design description

## Purpose

*Component definition*

| name | type | documentation |
| --- | --- | --- |
| CaptureRigController |  | Meridian Capstan: the capture rig's control and data software. |

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
| captureRig | TethysVerification::TestBed | A thermal-vacuum rig with a rotating mock body for bag deployment and cinch tests. |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| captureRig | simulatorFidelity | 1 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| captureRigSimulator | levelC | Meridian Capstan, the capture rig controller. |

One volume per component of the Meridian Operations Suite, in the order of TethysGroundSoftware::MeridianOperationsSuite::components. Every table is a query over TethysGroundSoftware, TethysSoftwareRequirements, TethysSoftwareAssurance and TethysVerification.
