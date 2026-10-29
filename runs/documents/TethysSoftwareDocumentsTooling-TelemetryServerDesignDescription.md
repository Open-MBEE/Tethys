# Telemetry server (Meridian Lantern) design description

## Purpose

*Component definition*

| name | type | documentation |
| --- | --- | --- |
| TelemetryServer |  | Meridian Lantern, the telemetry server: synchronises the transfer frames the<br>gateway forwards, decommutates every dictionary packet by its PacketDefinition<br>layout, converts to engineering units, checks the dictionary limits and the FDIR<br>limit table, raises alarms and trends the resource points. |

## Ports

*Ports of the component*

| name | type | documentation |
| --- | --- | --- |
| frames | TethysIcds::PacketPort |  |
| products | TethysMeridian::ProductPort |  |

## Figures and tables

*Attributes the component carries*

| name | type | documentation |
| --- | --- | --- |
| productName |  |  |
| version |  |  |
| dictionaryPacketCount | ScalarValues::Natural |  |
| dictionaryPointCount | ScalarValues::Natural |  |
| housekeepingPointCount | ScalarValues::Natural |  |
| limitTable | TethysFlightDictionary::FdirLimitTable |  |
| frameLength | ISQInformation::StorageCapacityValue |  |
| allPacketsDecommutate | ScalarValues::Boolean |  |
| floorViolationRaised | ScalarValues::Boolean |  |

*Parts the component owns*

| name | type | documentation |
| --- | --- | --- |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| telemetryServer | telemetryDecommutation, limitAlarming, trendingAutomation, dictionaryDrivenTelemetry | 4 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| telemetryServer | levelB | Meridian Lantern: decommutation, limits, alarms. |

One volume per component of the Meridian Operations Suite, in the order of TethysGroundSoftware::MeridianOperationsSuite::components. Every table is a query over TethysGroundSoftware, TethysSoftwareRequirements, TethysSoftwareAssurance and TethysVerification.
