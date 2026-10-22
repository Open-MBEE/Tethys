// Probe: a `@VerificationMethod { kind = …; }` metadata usage inside a verification def's body
// makes OpenSysML's -analysis fail with "statement not executable: calculation body: `then`
// statement in a body is not executable"; without it, on the usage, or as `metadata … about`
// the case runs and passes. The pilot validates every form.
// Run: sysml -analysis VProbe::plain -analysis VProbe::withMeta -analysis VProbe::aboutForm <this file>
package VProbe {
    private import ScalarValues::*;
    private import VerificationCases::*;
    part def Thing { attribute v : Real; }
    part thing : Thing { attribute :>> v = 3.0; }
    requirement big { subject t : Thing; require constraint { t.v >= 1.0 } }
    verification def Plain {
        subject t : Thing;
        objective { verify big; }
        PassIf(t.v >= 1.0)
    }
    verification def WithMeta {
        subject t : Thing;
        objective { verify big; }
        @VerificationMethod { kind = VerificationMethodKind::test; }
        PassIf(t.v >= 1.0)
    }
    metadata VerificationMethod about Plain { kind = VerificationMethodKind::test; }
    verification plain : Plain { subject t = thing; }
    verification withMeta : WithMeta { subject t = thing; }
    verification aboutForm : Plain { subject t = thing; }
}
