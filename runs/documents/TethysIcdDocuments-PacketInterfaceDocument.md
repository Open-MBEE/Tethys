# TCD-010 Command and telemetry packet interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| flightSide | TethysIcds::PacketPort |
| groundSide | TethysIcds::PacketPort |

## Interface parameters

*Parameters both sides agree on*

| name | type | valuation |
| --- | --- | --- |
| maximumPacketLength | ISQInformation::StorageCapacityValue | 65542 \[B\] |
| housekeepingApid | ScalarValues::Natural | 1 |
