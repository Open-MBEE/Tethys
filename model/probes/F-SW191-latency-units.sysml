// Probe: a sum of DurationValues (same and mixed SI units) compared with a requirement bound,
// and a calc def that sums a DurationValue chain, for -compile. KerML 8.3.4.8 (operator
// expressions over quantities) / SysML Quantities and Units library (QuantityCalculations::sum).
package F_SW191 {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import QuantityCalculations::sum;
    calc def ChainLatency {
        in legs : DurationValue[*];
        return total : DurationValue = sum(legs);
    }
    calc def ChainLatencyReal {
        in legs : Real[*];
        return total : Real = RealFunctions::sum(legs);
    }
    attribute chainReal : Real = ChainLatencyReal((0.125, 0.0625, 0.003, 0.0005));
    attribute chain : DurationValue = ChainLatency((0.125 [s], 0.0625 [s], 0.003 [s], 0.0005 [s]));
    attribute bound : DurationValue = 0.5 [s];
    attribute within : Boolean = chain <= bound;
    attribute mixed : DurationValue = ChainLatency((2.0 [min], 30.0 [s]));
    attribute mixedWithin : Boolean = mixed <= 0.05 [h];
    attribute ratio : Real = chain / bound;
    requirement def Bounded {
        attribute latency : DurationValue;
        require constraint { latency <= 0.5 [s] }
    }
    requirement bounded : Bounded { attribute :>> latency = chain; }
    requirement mixedBounded : Bounded { attribute :>> latency = mixed; }
}
