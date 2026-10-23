# Sequencer and flight-rule checker (Meridian Warden) design description

## Purpose

*Component definition*

| name | type | documentation |
| --- | --- | --- |
| FlightRuleChecker |  | Meridian Warden, the sequencer and flight-rule checker: every planned sequence is<br>loaded, checked against FR-001 to FR-004 and either released to the uplink queue<br>as a LoadSequence command or refused. The release is a send from this part's own<br>port inside its performed action, the form the pinned runtime routes. |

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
| storedSequences | ScalarValues::Natural |  |
| plannedSequence | TethysGroundSoftware::PlannedSequence |  |
| released | ScalarValues::Natural |  |

*Parts the component owns*

| name | type | documentation |
| --- | --- | --- |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| sequencer | sequenceClearance | 1 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| sequencer | levelB | Meridian Warden: clears sequences against the flight rules. |

One volume per component of the Meridian Operations Suite, in the order of TethysGroundSoftware::MeridianOperationsSuite::components. Every table is a query over TethysGroundSoftware, TethysSoftwareRequirements, TethysSoftwareAssurance and TethysVerification.
