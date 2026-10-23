# ICD-013 Data bus interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| a | TethysInterfaces::DataBusPort |
| b | TethysInterfaces::DataBusPort |

## Interface parameters

*Parameters both sides agree on*

| name | type |
| --- | --- |
| busRate | ISQInformation::BinaryDigitRateValue |
| maximumPacketLength | ISQInformation::StorageCapacityValue |
| pollingPeriod | ISQBase::DurationValue |
