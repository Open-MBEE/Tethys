// F-B01 probe. Load with the whole model and evaluate each attribute in its own process:
//   sysml -e "ProbeEnumMembership::viaNamedSet" model/*.sysml model/probes/F-B01-in-model-differential.sysml
// Expected (KerML 8.4.4.6 SequenceFunctions::includes, 7.4.9 Expressions): every attribute below
// reads the same unit values, so viaNamedSet = viaAllUnits = inPart.viaNamedSet = 42 W and
// twoTerms = 280 W. Observed on OpenSysML v0.10.1-2054-g0a5fa2d94: viaNamedSet = 42 W,
// viaAllUnits = 0 W, inPart.viaNamedSet = 0 W, twoTerms = 20 W (the left operand).
package ProbeEnumMembership {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import SequenceFunctions::*;
    private import ControlFunctions::collect;
    private import QuantityCalculations::sum;
    private import TethysTugStructure::*;
    attribute viaNamedSet : PowerValue = UnitsPowerInMode(argentDesign.cdh.flightComputers, TugMode::safe);
    attribute viaAllUnits : PowerValue =
        sum(argentDesign.units->collect { in u : Unit; if u == argentDesign.cdh.flightComputers#(1) or u == argentDesign.cdh.flightComputers#(2) ? PowerInMode(u, TugMode::safe) else 0 [W] });
    attribute pumps : PowerValue = UnitsPowerInMode(argentDesign.thermal.coolantPumps, TugMode::safe);
    attribute heaters : PowerValue = UnitsPowerInMode(argentDesign.thermal.heaters, TugMode::safe);
    attribute twoTerms : PowerValue = pumps + heaters;
    attribute plainTerms : PowerValue = argentDesign.eps.powerConditioning.operatingPower + argentDesign.thermal.heaters.operatingPower;
    part def InPart {
        attribute viaNamedSet : PowerValue = UnitsPowerInMode(argentDesign.cdh.flightComputers, TugMode::safe);
        attribute membership : Boolean[*] nonunique =
            argentDesign.cdh.flightComputers->collect { in u : Unit; includes(u.operatingModes, TugMode::safe) };
    }
    part inPart : InPart;
}
