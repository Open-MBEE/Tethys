package 'F-I03' {
    doc /* A system part that subsets a configured part one-to-one (`part tug : Tug :> argent`
         * with both at multiplicity 1) against the same part bound (`= argent`): whether a
         * requirement satisfied by the system part can read the configured value. */
    private import ScalarValues::*;
    part def Tug {
        doc /* A tug with one budgeted value. */
        attribute dryMass : Real;
    }
    part argent : Tug {
        doc /* The configured tug. */
        attribute :>> dryMass = 3700.0;
    }
    part def SubsettingSegment {
        doc /* The flight segment whose tug subsets the configured one. */
        part tug : Tug :> argent;
    }
    part def BoundSegment {
        doc /* The flight segment whose tug is bound to the configured one. */
        part tug : Tug = argent;
    }
    part subsetting : SubsettingSegment;
    part bound : BoundSegment;
    requirement def MassLimit {
        doc /* The tug's dry mass stays under the limit. */
        subject tug : Tug;
        require constraint { tug.dryMass <= 4000.0 }
    }
    requirement massLimit : MassLimit {
        doc /* The one mass requirement. */
    }
    satisfy massLimit by subsetting.tug {
        doc /* Through the subsetting segment. */
    }
    satisfy massLimit by bound.tug {
        doc /* Through the bound segment. */
    }
}
