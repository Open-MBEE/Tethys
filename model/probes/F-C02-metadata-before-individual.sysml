package 'F-C02' {
    doc /* Prefix metadata placed before `individual`, which the textual notation does not
         * allow (the PrefixMetadataMember follows `individual`). */
    metadata def Tag;
    part def Body;
    #Tag individual part def Article :> Body;
    #Tag individual part article : Article;
}
