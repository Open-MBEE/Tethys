# Anomaly tracker (Meridian Ledger) design description

## Purpose

*Component definition*

| name | type | documentation |
| --- | --- | --- |
| AnomalyTracker |  | Meridian Ledger, the anomaly tracker: every alarm or fault event the telemetry<br>server raises opens an anomaly, the console answers it with the contingency<br>procedures of the operations model, and the anomaly board dispositions it. |

## Ports

*Ports of the component*

| name | type | documentation |
| --- | --- | --- |
| alarms | TethysMeridian::ProductPort |  |
| reports | TethysMeridian::ProductPort |  |

## Figures and tables

*Attributes the component carries*

| name | type | documentation |
| --- | --- | --- |
| productName |  |  |
| version |  |  |
| faultEventCount | ScalarValues::Natural |  |
| safeModeRecoveryAuthority | TethysGroundSoftware::DecisionAuthority |  |

*Parts the component owns*

| name | type | documentation |
| --- | --- | --- |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| anomalyTracker | anomalyDisposition | 1 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| anomalyTracker | levelD | Meridian Ledger: anomaly reports. |

One volume per component of the Meridian Operations Suite, in the order of TethysGroundSoftware::MeridianOperationsSuite::components. Every table is a query over TethysGroundSoftware, TethysSoftwareRequirements, TethysSoftwareAssurance and TethysVerification.
