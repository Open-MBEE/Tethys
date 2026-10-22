# ICD-004 Inspector relay link

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| inspectorSide | TethysInterfaces::RfPort |
| tugSide | TethysInterfaces::RfPort |

## Interface parameters

*Parameters both sides agree on*

| name | type |
| --- | --- |
| forwardFrequency | ISQSpaceTime::FrequencyValue |
| returnFrequency | ISQSpaceTime::FrequencyValue |
| modulation | TethysIcds::Modulation |
| coding | TethysIcds::ChannelCoding |
| returnRate | ISQInformation::BinaryDigitRateValue |
| maximumRange | ISQBase::LengthValue |
| minimumRange | ISQBase::LengthValue |
| maximumOffBoresight | ISQSpaceTime::AngularMeasureValue |
| dailyContactWindow | ISQBase::DurationValue |
