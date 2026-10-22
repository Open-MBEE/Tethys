# SCD-020 AABP-1 on-board bus protocol

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| a | TethysInterfaces::DataBusPort |
| b | TethysInterfaces::DataBusPort |

## Protocol parameters

*Framing, addressing, schedule and error handling*

| name | type | valuation |
| --- | --- | --- |
| designation | ScalarValues::String | AABP-1 |
| frameHeaderLength | ISQInformation::StorageCapacityValue | 8 \[B\] |
| frameTrailerLength | ISQInformation::StorageCapacityValue | 2 \[B\] |
| maximumFrameLength | ISQInformation::StorageCapacityValue | 1024 \[B\] |
| addressWidth | ScalarValues::Natural | 5 |
| nodeCount | ScalarValues::Natural | 32 |
| broadcastAddress | ScalarValues::Natural | 31 |
| controllerAddress | ScalarValues::Natural | 0 |
| majorFrame | ISQBase::DurationValue | 0.125 \[s\] |
| scheduleSlotCount | ScalarValues::Natural | 64 |
| slotDuration | ISQBase::DurationValue | 0.001953125 \[s\] |
| checksumWidth | ScalarValues::Natural | 16 |
| retryLimit | ScalarValues::Natural | 2 |
| checksumFailure | TethysSoftwareIcds::BusErrorResponse | requestRetry |
| retryExhausted | TethysSoftwareIcds::BusErrorResponse | raiseFault |
| unknownAddress | TethysSoftwareIcds::BusErrorResponse | discardAndCount |
