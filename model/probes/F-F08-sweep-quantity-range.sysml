// Finding F-F08: the CLI sweep and sample runners write bare numbers to the parameter they
// draw, so a parameter typed by an ISQ quantity (SpeedValue here) cannot be swept, while the
// same parameter as a Real can. Standalone: loads without model/*.sysml.
package TethysSweepQuantityProbe {
    private import ScalarValues::Real;
    private import ISQ::SpeedValue;
    private import SI::*;

    part def Body;
    part body : Body;

    analysis def TypedSweep {
        doc /* The swept parameter carries its quantity type: the spec-correct form. */
        subject target : Body;
        in attribute speed : SpeedValue default = 10.0 ['m/s'];
        return doubled : SpeedValue = speed * 2.0;
    }
    analysis def PlainSweep {
        doc /* The same parameter as a suffix-named Real: the form the runners accept. */
        subject target : Body;
        in attribute speedMPerS : Real default = 10.0;
        return doubledMPerS : Real = speedMPerS * 2.0;
    }
    analysis typed : TypedSweep { subject :>> target = body; }
    analysis plain : PlainSweep { subject :>> target = body; }
}
