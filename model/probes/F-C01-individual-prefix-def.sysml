package 'F-C01' {
    doc /* IndividualDefinition with prefix metadata between `individual` and `def`
         * (SysML v2 textual notation: `individual` EmptyMultiplicityMember
         * DefinitionExtensionKeyword* `def`). */
    metadata def Tag;
    occurrence def Campaign;
    individual #Tag def Flight :> Campaign;
    individual flight : Flight;
}
