# SCD-021 MLS-2 space-link profile

## Interface ends

*Ends and their port types*

| name | type |
| --- | --- |
| flightSide | TethysIcds::PacketPort |
| groundSide | TethysIcds::PacketPort |

## Profile parameters

*Packets, frames, virtual channels and the rate envelope*

| name | type | valuation |
| --- | --- | --- |
| designation | ScalarValues::String | MLS-2 |
| packetStandard | ScalarValues::String | CCSDS Space Packet, version 1 |
| transferFrameLength | ISQInformation::StorageCapacityValue | 1115 \[B\] |
| frameHeaderLength | ISQInformation::StorageCapacityValue | 6 \[B\] |
| frameTrailerLength | ISQInformation::StorageCapacityValue | 4 \[B\] |
| secondaryHeaderLength | ISQInformation::StorageCapacityValue | 10 \[B\] |
| timeCode | ScalarValues::String | unsegmented, 32-bit seconds and 16-bit fraction |
| timeCorrelationPeriod | ISQBase::DurationValue | 60 \[s\] |
| dictionaryVersionWidth | ScalarValues::Natural | 16 |
| virtualChannelCount | ScalarValues::Natural | 8 |
| realTimeVirtualChannel | ScalarValues::Natural | 0 |
| playbackVirtualChannel | ScalarValues::Natural | 1 |
| eventVirtualChannel | ScalarValues::Natural | 2 |
| fileTransferVirtualChannel | ScalarValues::Natural | 3 |
| idleVirtualChannel | ScalarValues::Natural | 7 |
| minimumDownlinkRate | ISQInformation::BinaryDigitRateValue | 2000 \[bit/s\] |
| maximumDownlinkRate | ISQInformation::BinaryDigitRateValue | 4000000 \[bit/s\] |
| safeRates | TethysSoftwareIcds::LinkRateSet |  |
| launchRates | TethysSoftwareIcds::LinkRateSet |  |
| earlyOperationsRates | TethysSoftwareIcds::LinkRateSet |  |
| coastRates | TethysSoftwareIcds::LinkRateSet |  |
| thrustRates | TethysSoftwareIcds::LinkRateSet |  |
| approachRates | TethysSoftwareIcds::LinkRateSet |  |
| proximityOperationsRates | TethysSoftwareIcds::LinkRateSet |  |
| retreatRates | TethysSoftwareIcds::LinkRateSet |  |
| captureRates | TethysSoftwareIcds::LinkRateSet |  |
| despinRates | TethysSoftwareIcds::LinkRateSet |  |
| stackCoastRates | TethysSoftwareIcds::LinkRateSet |  |
| stackThrustRates | TethysSoftwareIcds::LinkRateSet |  |
| droHoldRates | TethysSoftwareIcds::LinkRateSet |  |
| dockedPassiveRates | TethysSoftwareIcds::LinkRateSet |  |
| disposalRates | TethysSoftwareIcds::LinkRateSet |  |
| abortHoldRates | TethysSoftwareIcds::LinkRateSet |  |
| uplinkRateFloor | ISQInformation::BinaryDigitRateValue | 2000 \[bit/s\] |

<a id="rateSets"></a>

## Rate sets per tug mode

*Downlink and uplink rates and housekeeping period by mode; safeRates is the fallback*

| name | mode | downlinkRate | uplinkRate | housekeepingPeriod |
| --- | --- | --- | --- | --- |
| safeRates | safe | 2000 \[bit/s\] | 2000 \[bit/s\] | 60 \[s\] |
| launchRates | launch | 2000 \[bit/s\] | 2000 \[bit/s\] | 10 \[s\] |
| earlyOperationsRates | earlyOperations | 100000 \[bit/s\] | 2000 \[bit/s\] | 1 \[s\] |
| coastRates | coast | 32000 \[bit/s\] | 2000 \[bit/s\] | 10 \[s\] |
| thrustRates | thrust | 32000 \[bit/s\] | 2000 \[bit/s\] | 10 \[s\] |
| approachRates | approach | 256000 \[bit/s\] | 2000 \[bit/s\] | 1 \[s\] |
| proximityOperationsRates | proximityOperations | 4000000 \[bit/s\] | 2000 \[bit/s\] | 1 \[s\] |
| retreatRates | retreat | 256000 \[bit/s\] | 2000 \[bit/s\] | 1 \[s\] |
| captureRates | capture | 4000000 \[bit/s\] | 2000 \[bit/s\] | 1 \[s\] |
| despinRates | despin | 256000 \[bit/s\] | 2000 \[bit/s\] | 1 \[s\] |
| stackCoastRates | stackCoast | 32000 \[bit/s\] | 2000 \[bit/s\] | 10 \[s\] |
| stackThrustRates | stackThrust | 32000 \[bit/s\] | 2000 \[bit/s\] | 10 \[s\] |
| droHoldRates | droHold | 100000 \[bit/s\] | 2000 \[bit/s\] | 10 \[s\] |
| dockedPassiveRates | dockedPassive | 32000 \[bit/s\] | 2000 \[bit/s\] | 60 \[s\] |
| disposalRates | disposal | 8000 \[bit/s\] | 2000 \[bit/s\] | 60 \[s\] |
| abortHoldRates | abortHold | 2000 \[bit/s\] | 2000 \[bit/s\] | 60 \[s\] |
