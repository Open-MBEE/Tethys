// Findings F-008: an external tool's `out` parameter declared without a multiplicity is read
// by OpenSysML as [0..*] (`one value answered but deltaVMPerS holds a sequence`), so the tool's
// single value is refused; the same action with `[1]` on every parameter
// (model/70-analyses.sysml SolveThrustArc) runs. Loaded after model/*.sysml with
// OPENSYSML_TOOLS pointing at a copy of scripts/tools/thrust-arc.
package TethysToolMultiplicityProbe {
    private import ScalarValues::*;
    private import SI::*;
    private import AnalysisTooling::*;
    private import TethysEnvironment::*;
    private import TethysTug::*;
    action def SolveThrustArcUnmultiplied {
        metadata ToolExecution { toolName = "ThrustArcSolver"; uri = "tethys://tools/thrust-arc"; }
        in startAu : Real { @ToolVariable { name = "startAu"; } }
        in endAu : Real { @ToolVariable { name = "endAu"; } }
        in planeChangeDeg : Real { @ToolVariable { name = "planeChangeDeg"; } }
        in initialMassKg : Real { @ToolVariable { name = "initialMassKg"; } }
        in thrustN : Real { @ToolVariable { name = "thrustN"; } }
        in specificImpulseS : Real { @ToolVariable { name = "specificImpulseS"; } }
        out deltaVMPerS : Real { @ToolVariable { name = "deltaVMPerS"; } }
        out propellantKg : Real { @ToolVariable { name = "propellantKg"; } }
        out thrustDays : Real { @ToolVariable { name = "thrustDays"; } }
    }
    analysis def UnmultipliedTransfer {
        subject tug : Tug;
        action solve : SolveThrustArcUnmultiplied {
            in startAu = 1.0;
            in endAu = amaranth.orbit.semiMajorAxisAu;
            in planeChangeDeg = amaranth.orbit.inclination / 1 ['°'];
            in initialMassKg = tug.wetMass / 1 [kg];
            in thrustN = 1.83;
            in specificImpulseS = tug.sep.specificImpulse / 1 [s];
        }
        return thrustDays : Real = solve.thrustDays;
    }
    analysis unmultipliedTransfer : UnmultipliedTransfer { subject :>> tug = argent; }
}
