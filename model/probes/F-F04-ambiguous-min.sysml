// Findings F-F04: `min` is both RealFunctions::min and the SI minute; with both packages
// imported by `*`, the pilot binds the unit (`Must invoke a behavior or a behavioral feature`)
// and OpenSysML the function, and neither reports the ambiguity. `max` has no unit namesake
// and resolves in both. Standalone.
package TethysAmbiguousMinProbe {
    private import ScalarValues::*;
    private import SI::*;
    private import RealFunctions::*;
    calc def Smaller { in a : Real; in b : Real; return r : Real = min(a, b); }
    calc def Larger { in a : Real; in b : Real; return r : Real = max(a, b); }
}
