# ICD-004 Inspector relay link

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| inspectorSide | TethysInterfaces::RfPort |
| tugSide | TethysInterfaces::RfPort |

## Interface parameters

*Parameters both sides agree on*

| name | type | valuation |
| --- | --- | --- |
| forwardFrequency | ISQSpaceTime::FrequencyValue | 401500000 \[Hz\] |
| returnFrequency | ISQSpaceTime::FrequencyValue | 437500000 \[Hz\] |
| modulation | TethysIcds::Modulation | gmsk |
| coding | TethysIcds::ChannelCoding | convolutionalRateHalf |
| returnRate | ISQInformation::BinaryDigitRateValue | 1000000 \[bit/s\] |
| maximumRange | ISQBase::LengthValue | 5 \[km\] |
| minimumRange | ISQBase::LengthValue | 50 \[m\] |
| maximumOffBoresight | ISQSpaceTime::AngularMeasureValue | 60 \['°'\] |
| dailyContactWindow | ISQBase::DurationValue | 18 \[h\] |
