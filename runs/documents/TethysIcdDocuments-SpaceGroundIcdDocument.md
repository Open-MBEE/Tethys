# ICD-003 Space–ground RF interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| spacecraftSide | TethysInterfaces::RfPort |
| groundSide | TethysInterfaces::RfPort |

## Interface parameters

*Parameters both sides agree on*

| name | type |
| --- | --- |
| uplinkFrequency | ISQSpaceTime::FrequencyValue |
| xDownlinkFrequency | ISQSpaceTime::FrequencyValue |
| kaDownlinkFrequency | ISQSpaceTime::FrequencyValue |
| uplinkModulation | TethysIcds::Modulation |
| downlinkModulation | TethysIcds::Modulation |
| downlinkCoding | TethysIcds::ChannelCoding |
| minimumDownlinkRate | ISQInformation::BinaryDigitRateValue |
| maximumDownlinkRate | ISQInformation::BinaryDigitRateValue |
| uplinkRate | ISQInformation::BinaryDigitRateValue |
| rangingTone | ISQSpaceTime::FrequencyValue |
| packetProtocol | ScalarValues::String |
| downlinkBand | TethysMeridian::RfBand |
