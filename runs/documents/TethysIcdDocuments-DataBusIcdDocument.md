# ICD-013 Data bus interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| a | TethysInterfaces::DataBusPort |
| b | TethysInterfaces::DataBusPort |

## Interface parameters

*Parameters both sides agree on*

| name | type | valuation |
| --- | --- | --- |
| busRate | ISQInformation::BinaryDigitRateValue | 1000000 \[bit/s\] |
| maximumPacketLength | ISQInformation::StorageCapacityValue | 1024 \[B\] |
| pollingPeriod | ISQBase::DurationValue | 0.125 \[s\] |
