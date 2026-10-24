# ICD-003 Space–ground RF interface

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| spacecraftSide | TethysInterfaces::RfPort |
| groundSide | TethysInterfaces::RfPort |

## Interface parameters

*Parameters both sides agree on*

| name | type | valuation |
| --- | --- | --- |
| uplinkFrequency | ISQSpaceTime::FrequencyValue | 7165000000 \[Hz\] |
| xDownlinkFrequency | ISQSpaceTime::FrequencyValue | 8445000000 \[Hz\] |
| kaDownlinkFrequency | ISQSpaceTime::FrequencyValue | 32050000000 \[Hz\] |
| uplinkModulation | TethysIcds::Modulation | bpsk |
| downlinkModulation | TethysIcds::Modulation | qpsk |
| downlinkCoding | TethysIcds::ChannelCoding | turboRateSixth |
| minimumDownlinkRate | ISQInformation::BinaryDigitRateValue | 2000 \[bit/s\] |
| maximumDownlinkRate | ISQInformation::BinaryDigitRateValue | 4000000 \[bit/s\] |
| uplinkRate | ISQInformation::BinaryDigitRateValue | 2000 \[bit/s\] |
| rangingTone | ISQSpaceTime::FrequencyValue | 1000000 \[Hz\] |
| packetProtocol | ScalarValues::String | space packet, telemetry transfer frames |
| downlinkBand | TethysMeridian::RfBand | xBand |
