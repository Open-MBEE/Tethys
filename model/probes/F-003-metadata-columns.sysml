// F-003: a DocumentQueries projection cannot read the attribute values of a metadata annotation.
// Load with the model: sysml -run-query "F003::VerificationMethods" model/*.sysml model/probes/F-003-metadata-columns.sysml
// Observed: `query F003::VerificationMethods references unknown property Verification.method`;
// the same for Column(path = …), Column(expression = …) and properties = ("metadata").
// Expected: one row per L1 requirement with the method its @Verification annotation states.
package F003 {
    private import DocumentQueries::*;
    private import KerML::Root::Element;
    private import ScalarValues::*;

    calc def VerificationMethods :> Query {
        Project(
            source = WhereType(
                source = OwnedElements(source = Named(qualifiedName = "TethysRequirements")),
                type = "RequirementUsage"),
            properties = ("shortName", "Verification.method", "Verification.level", "Verification.stage"))
    }
    calc def VerificationMethodsByPath :> Query {
        Project(
            source = WhereType(
                source = OwnedElements(source = Named(qualifiedName = "TethysRequirements")),
                type = "RequirementUsage"),
            properties = ("shortName"),
            columns = (Column(name = "method", path = "Verification.method")))
    }
}
