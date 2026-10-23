// Probe: DocumentQueries RelatedColumn/RelatedElements "derivation" (incoming) finds the connection in
// DerivE but not in DerivD, whose original requirement carries `@original` itself (as every L1
// requirement in TethysRequirements does). Run with model/24-verification-tooling.sysml loaded:
//   sysml -run-query "TethysVerificationTooling::VvMatrix root=DerivD" <this file> model/*.sysml
package DerivD {
    private import RequirementDerivation::*;
    requirement <'D-0'> d0 { @original; }
    requirement <'D-1'> d1;
    #derivation connection { end #original ::> d0; end #derive ::> d1; }
}
package DerivE {
    private import RequirementDerivation::*;
    requirement <'E-0'> e0;
    requirement <'E-1'> e1;
    requirement <'E-2'> e2;
    requirement <'E-3'> e3;
    #derivation connection { end #original ::> e0; end #derive ::> e1; end #derive ::> e2; end #derive ::> e3; }
}
