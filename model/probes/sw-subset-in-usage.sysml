// Probe: a multiplicity-[*] part declared in a definition, subsetted by parts declared in the
// body of a usage of that definition (and in a nested usage). KerML 7.3.4.7 (subsetting) and
// SysML 7.6.3 (part usages): the subsetting parts are values of the subsetted feature, so a
// feature chain through the subsetted feature should yield them.
package SubsetInUsageProbe {
    private import ScalarValues::*;
    private import SequenceFunctions::*;
    part def Item { attribute weight : Real; }
    part def Bag {
        part items : Item[*];
        attribute count : Natural = size(items);
        attribute total : Real = RealFunctions::sum(items.weight);
    }
    part def Shelf { part bags : Bag[*]; attribute bagCount : Natural = size(bags); }
    part def DefBag :> Bag {
        part a : Item :> items { attribute :>> weight = 1.0; }
        part b : Item :> items { attribute :>> weight = 2.0; }
    }
    part defBag : DefBag;
    part usageBag : Bag {
        part a : Item :> items { attribute :>> weight = 1.0; }
        part b : Item :> items { attribute :>> weight = 2.0; }
    }
    part shelf : Shelf {
        part nested : Bag :> bags {
            part a : Item :> items { attribute :>> weight = 1.0; }
            part b : Item :> items { attribute :>> weight = 2.0; }
        }
    }
}
package SubsetInUsageProbeAbstract {
    doc /* The same shape with the collection declared abstract, and with an explicit value. */
    private import ScalarValues::*;
    private import SequenceFunctions::*;
    private import SubsetInUsageProbe::Item;
    part def AbstractBag {
        abstract part items : Item[*];
        attribute count : Natural = size(items);
        attribute total : Real = RealFunctions::sum(items.weight);
    }
    part abstractBag : AbstractBag {
        part a : Item :> items { attribute :>> weight = 1.0; }
        part b : Item :> items { attribute :>> weight = 2.0; }
    }
    part def ValuedBag {
        part items : Item[*];
        attribute count : Natural = size(items);
        attribute total : Real = RealFunctions::sum(items.weight);
    }
    part valuedBag : ValuedBag {
        part a : Item { attribute :>> weight = 1.0; }
        part b : Item { attribute :>> weight = 2.0; }
        part :>> items = (a, b);
    }
}
