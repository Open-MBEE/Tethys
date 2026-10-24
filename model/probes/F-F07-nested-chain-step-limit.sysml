// Findings F-F07: the same rocket-equation chain that evaluates on its own, and on the baseline
// configuration, exhausts the evaluator's step budget when written as two chained PropellantFor
// calls inside a RetrievalArchitecture configured with the heavy xenon load. Loaded after
// model/*.sysml.
package TethysNestedChainProbe {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysMission::transferBook;
    private import TethysTug::argent;
    private import TethysTarget::targetCases;
    private import TethysBudgets::PropellantFor;
    private import TethysBudgets::propellantBudget;
    private import TethysMarginPolicy::activePolicy;
    private import TethysVariants::*;

    part def ChainedArchitecture :> RetrievalArchitecture {
        doc /* The outbound and rendezvous arcs as two chained calls, the second on the mass the
             * first leaves, and the return xenon as the load less both. */
        attribute outboundXenon : MassValue =
            PropellantFor(transferBook.deltaVOutbound / 1 ['m/s'], tugAloneMass, argent.sep.specificImpulse);
        attribute rendezvousXenon : MassValue =
            PropellantFor(transferBook.deltaVRendezvous / 1 ['m/s'], tugAloneMass - outboundXenon, argent.sep.specificImpulse);
        attribute chainedReturnXenon : MassValue = xenonLoad * (1.0 - propellantBudget.residualFraction)
            / ((1.0 + activePolicy.systemMargin) * (1.0 + transferBook.missedThrustMargin))
            - outboundXenon - rendezvousXenon;
    }
    part baselineChained : ChainedArchitecture {
        doc /* The baseline load: evaluates. */
        part :>> target = targetCases.nominal;
        attribute :>> arrayPower = arrayPower::baseline;
        attribute :>> thrusterCount = thrusterCount::fourStrings;
        attribute :>> xenonLoad = xenonLoad::baseline;
        part :>> inspector = inspector::wrenFreeFlyer;
        part :>> launcher = launcher::arcturus5H;
    }
    part heavyChained : ChainedArchitecture {
        doc /* The heavy load: `evaluation step limit exceeded` inside rendezvousXenon, although
             * rendezvousXenon alone evaluates on this configuration. */
        part :>> target = targetCases.densest;
        attribute :>> arrayPower = arrayPower::extended;
        attribute :>> thrusterCount = thrusterCount::fiveStrings;
        attribute :>> xenonLoad = xenonLoad::heavy;
        part :>> inspector = inspector::wrenFreeFlyer;
        part :>> launcher = launcher::arcturus5H;
    }
}
