package 'F-SW602-allocation-chain-ends' {
    doc /* Smallest reproducer for docs/findings/WP-SW-6.md F-SW602: a four-level allocation chain
         * (function → application → partition → computer → unit) whose allocation definitions
         * redefine the Allocations::Allocation ends `source` and `target` with specialised part
         * definitions, rendered as a matrix. SysML v2.1 7.15 lets the ends be redefined with
         * conforming types; the probe records what each validator and the matrix renderer say. */
    private import StandardViewDefinitions::*;
    part def SoftwareFunction;
    part def Application;
    part def Partition;
    part def Computer;
    part def Unit;
    part def GncApplication :> Application;
    part def PrimeComputer :> Computer;
    allocation def FunctionToApplication { end :>> source : SoftwareFunction; end :>> target : Application; }
    allocation def ApplicationToPartition { end :>> source : Application; end :>> target : Partition; }
    allocation def PartitionToComputer { end :>> source : Partition; end :>> target : Computer; }
    allocation def ComputerToUnit { end :>> source : Computer; end :>> target : Unit; }
    allocation def GncToPrimeChain :> FunctionToApplication { end :>> target : GncApplication; }
    part chain {
        part attitudeControl : SoftwareFunction;
        part gnc : GncApplication;
        part gncPartition : Partition;
        part prime : PrimeComputer;
        part avionics : Unit;
        allocation functionToApp : GncToPrimeChain allocate attitudeControl to gnc;
        allocation appToPartition : ApplicationToPartition allocate gnc to gncPartition;
        allocation partitionToComputer : PartitionToComputer allocate gncPartition to prime;
        allocation computerToUnit : ComputerToUnit allocate prime to avionics;
    }
    view def ChainMatrix :> GridView { filter @SysML::AllocationUsage; }
    view chainMatrix : ChainMatrix { expose chain::*; }
}
