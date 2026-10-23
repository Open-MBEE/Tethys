// Probe F-SW701: reading a nested attribute (the dictionary range) of an argument that is typed by
// a quantity value and by an argument attribute def, when the argument itself carries no value.
// Expected (KerML §7.4.7 feature chains, §8.4.4.6 feature values): `plain.minimum` and
// `quantity.minimum` both evaluate to 60.0 — the chain reads the redefined `minimum`, whose value
// does not depend on whether the owning attribute has a value of its own.
package FSW701 {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    attribute def Argument {
        doc /* A command argument's dictionary range. */
        attribute minimum : Real;
        attribute maximum : Real;
    }
    part def Command {
        doc /* A command with one plain and one quantity-typed argument of the same range. */
        attribute plain : Natural, Argument { :>> minimum = 60.0; :>> maximum = 2592000.0; }
        attribute quantity : DurationValue, Argument { :>> minimum = 60.0; :>> maximum = 2592000.0; }
    }
    part command : Command {
        doc /* The instance the probe reads. */
    }
    calc def InRange {
        doc /* The range check as the ground command builder applies it. */
        in value : Real;
        in argument : Argument;
        return inRange : Boolean = argument.minimum <= value and value <= argument.maximum;
    }
    part builder {
        doc /* One check through the plain argument, one through the quantity-typed argument. */
        calc plainCheck : InRange { in value = 100.0; in argument = command.plain; }
        calc quantityCheck : InRange { in value = 100.0; in argument = command.quantity; }
    }
}
