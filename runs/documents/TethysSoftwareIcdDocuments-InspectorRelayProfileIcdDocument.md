# SCD-022 Tug–inspector relay profile

<a id="ends"></a>

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| a | TethysInterfaces::DataBusPort |
| b | TethysInterfaces::DataBusPort |

## Profile parameters

*Rates, identifiers, store-and-forward and acknowledgement*

| name | type | valuation |
| --- | --- | --- |
| designation | ScalarValues::String | AABP-1 over TI-004 |
| forwardCommandRate | ISQInformation::BinaryDigitRateValue | 9600 \[bit/s\] |
| returnTelemetryRate | ISQInformation::BinaryDigitRateValue | 1000000 \[bit/s\] |
| relayApidBase | ScalarValues::Natural | 128 |
| relayApidCount | ScalarValues::Natural | 32 |
| storeAndForwardCapacity | ISQInformation::StorageCapacityValue | 200000000 \[B\] |
| acknowledgementTimeout | ISQBase::DurationValue | 2 \[s\] |
| retryLimit | ScalarValues::Natural | 3 |
| maximumRelayLatency | ISQBase::DurationValue | 5 \[s\] |
