// F-B02 probe. Both validators accept this file; evaluation fails:
//   sysml -e "ProbeVariantChain::viaVariant" model/probes/F-B02-variant-binding-chain.sysml
// Expected (SysML 7.7.3 variation and variant usages; a variant is a usage whose value is the
// case): viaVariant = viaPlain = 507000.0 [kg].
// Observed on OpenSysML v0.10.1-2054-g0a5fa2d94: viaPlain = 507000.0 [kg];
// viaVariant: "cannot chain through non-instance member (variant)".
package ProbeVariantChain {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    attribute def TargetCase { attribute bodyMass : MassValue; }
    attribute small : TargetCase { attribute :>> bodyMass = 217.0e3 [kg]; }
    attribute large : TargetCase { attribute :>> bodyMass = 507.0e3 [kg]; }
    variation attribute def TargetCases :> TargetCase {
        variant attribute smallCase = small;
        variant attribute largeCase = large;
    }
    attribute viaPlain : MassValue = large.bodyMass;
    attribute viaVariant : MassValue = TargetCases::largeCase.bodyMass;
}
