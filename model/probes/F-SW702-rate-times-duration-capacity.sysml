// Probe F-SW702: a data rate times a duration written to a storage-capacity attribute, where the
// pass duration is in hours and the lock-up in seconds (the units the operations model uses).
// Expected (KerML §8.4.4.6 feature values; Quantities and Units library: differences of
// durations in different units and products of quantity values are quantity values, so
// bit/s × (h − s) is a storage capacity in bit): `volumeAsCapacity` = 114000.0 [bit],
// `sameUnits` = 4800.0 [bit]; `volumeAsNumber` is the numeric form the pass planner uses.
package FSW702 {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    attribute def RateSet {
        doc /* One downlink rate. */
        attribute downlinkRate : BinaryDigitRateValue;
    }
    attribute rates : RateSet {
        doc /* Four bits per second. */
        :>> downlinkRate = 4.0 [bit/s];
    }
    calc def PassVolume {
        doc /* The data a pass returns after lock-up. */
        in rateSet : RateSet;
        in passDuration : DurationValue;
        in lockUp : DurationValue;
        return volume : StorageCapacityValue = rateSet.downlinkRate * (passDuration - lockUp);
    }
    calc def PassVolumeNumeric {
        doc /* The same product on the numeric values, in bits. */
        in rateSet : RateSet;
        in passDurationSeconds : Real;
        in lockUpSeconds : Real;
        return volumeBits : Real = rateSet.downlinkRate.num * (passDurationSeconds - lockUpSeconds);
    }
    part planner {
        doc /* An eight-hour pass with a five-minute lock-up, and a twenty-minute pass in seconds. */
        calc volumeAsCapacity : PassVolume { in rateSet = rates; in passDuration = 8.0 [h]; in lockUp = 300.0 [s]; }
        calc sameUnits : PassVolume { in rateSet = rates; in passDuration = 1500.0 [s]; in lockUp = 300.0 [s]; }
        calc volumeAsNumber : PassVolumeNumeric { in rateSet = rates; in passDurationSeconds = 8.0 * 3600.0; in lockUpSeconds = 300.0; }
    }
}
