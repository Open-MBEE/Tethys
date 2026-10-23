// Findings F-F02: a variant of a variation bound as an analysis subject, directly or through a
// configuration part, is accepted by both validators but not evaluated by OpenSysML
// (`cannot chain through non-instance member (variant)`). Loaded after model/*.sysml.
package TethysVariantSubjectProbe {
    private import ScalarValues::*;
    private import SI::*;
    private import TethysTarget::SmallBody;
    private import TethysAnalyses::*;
    part def Configuration { part target : SmallBody; }
    part largeConfiguration : Configuration { part :>> target = TargetCase::large; }
    analysis def BodyMass { subject body : SmallBody; return massKg : Real = body.mass / 1 [kg]; }
    analysis viaVariant : BodyMass { subject :>> body = TargetCase::large; }
    analysis viaConfiguration : BodyMass { subject :>> body = largeConfiguration.target; }
    analysis viaPlainPart : BodyMass { subject :>> body = largeTarget; }
}
