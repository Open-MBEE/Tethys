package ProbeInterpolateLinear {
    private import ScalarValues::*;
    private import SampledFunctions::*;
    attribute s1 : SamplePair { :>> domainValue = 0.9647; :>> rangeValue = 1462.4; }
    attribute s2 : SamplePair { :>> domainValue = 1.052; :>> rangeValue = 1229.8; }
    attribute s3 : SamplePair { :>> domainValue = 1.1393; :>> rangeValue = 1048.5; }
    attribute flux : SampledFunction { :>> samples = (s1, s2, s3); }
    calc def Flux { in x : Real;
        return r : Real = interpolateLinear(flux, x);
    }
}
