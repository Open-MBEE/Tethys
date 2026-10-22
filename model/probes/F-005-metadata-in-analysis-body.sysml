// Findings F-005: an annotating metadata usage inside an analysis case body makes OpenSysML
// refuse to run the case (`then statement in a body is not executable`); the same annotation
// written as `metadata … about …` outside the body (the form model/70-analyses.sysml uses) runs.
// Loaded after model/*.sysml.
package TethysMetadataInBodyProbe {
    private import ScalarValues::*;
    private import TethysTug::*;
    private import TethysAnalyses::CredibilityAssessment;
    analysis def AnnotatedInline {
        @CredibilityAssessment { verificationFactor = 3; validation = 1; inputPedigree = 2; resultsUncertainty = 2; resultsRobustness = 2; useHistory = 1; managementProcess = 2; peopleQualification = 3; }
        subject tug : Tug;
        return dryMassKg : Real = tug.dryMass / 1 [SI::kg];
    }
    analysis def AnnotatedOutside {
        subject tug : Tug;
        return dryMassKg : Real = tug.dryMass / 1 [SI::kg];
    }
    metadata CredibilityAssessment about AnnotatedOutside { verificationFactor = 3; validation = 1; inputPedigree = 2; resultsUncertainty = 2; resultsRobustness = 2; useHistory = 1; managementProcess = 2; peopleQualification = 3; }
    analysis inline : AnnotatedInline { subject :>> tug = argent; }
    analysis outside : AnnotatedOutside { subject :>> tug = argent; }
}
