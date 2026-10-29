# Command builder (Meridian Forge) design description

## Purpose

*Component definition*

| name | type | documentation |
| --- | --- | --- |
| CommandBuilder |  | Meridian Forge, the command builder: every command is built from the flight<br>dictionary and validated by ValidateCommand before it is packed as a CommandPacket<br>for the uplink queue; hazardous commands wait for a second signature. |

## Ports

*Ports of the component*

| name | type | documentation |
| --- | --- | --- |
| uplinkQueue | TethysIcds::PacketPort |  |

## Figures and tables

*Attributes the component carries*

| name | type | documentation |
| --- | --- | --- |
| productName |  |  |
| version |  |  |
| dictionaryCommandCount | ScalarValues::Natural |  |
| hazardousCommandCount | ScalarValues::Natural |  |
| secondApprover | TethysGroundSoftware::DecisionAuthority |  |
| thrustArcRequest | TethysGroundSoftware::CommandRequest |  |
| thrustArcInCoastRequest | TethysGroundSoftware::CommandRequest |  |
| resetWithOneApproval | TethysGroundSoftware::CommandRequest |  |
| resetKeyOutOfRange | TethysGroundSoftware::CommandRequest |  |
| misspelledRequest | TethysGroundSoftware::CommandRequest |  |
| verdictsAsPlanted | ScalarValues::Boolean |  |

*Parts the component owns*

| name | type | documentation |
| --- | --- | --- |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| commandBuilder | commandValidation, hazardousApproval, commandValidation | 3 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| commandBuilder | levelB | Meridian Forge: builds and validates commands, holds hazardous ones for a second approval. |

One volume per component of the Meridian Operations Suite, in the order of TethysGroundSoftware::MeridianOperationsSuite::components. Every table is a query over TethysGroundSoftware, TethysSoftwareRequirements, TethysSoftwareAssurance and TethysVerification.
