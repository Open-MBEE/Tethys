// Probe: a packet layout carried as Natural widths/offsets with a Σ widths = length constraint,
// evaluated, `-compile`d and read back by a DocumentQueries field table. SysML v2 §7.6 (attributes)
// and KerML §9.2.9 (SequenceFunctions::sum) give the semantics; the specification defines no bit
// layout, so offset/width are plain attributes here. OpenSysML: `layoutOk` evaluates true, the
// query lists the fields in order. Pilot: validates (no evaluation). See docs/findings/WP-SW-2.md.
package F_SW192 {
    private import ScalarValues::*;
    private import SequenceFunctions::*;
    private import NumericalFunctions::*;
    attribute def Field { attribute order : Natural; attribute offset : Natural; attribute width : Natural; }
    calc def LayoutOk {
        in headerBits : Natural; in widths : Natural[*] nonunique; in lengthOctets : Natural;
        return ok : Boolean = headerBits + sum(widths) == lengthOctets * 8;
    }
    item def Packet {
        attribute headerBits : Natural = 48;
        attribute widths : Natural[*] nonunique;
        attribute lengthOctets : Natural;
        attribute layoutOk : Boolean = headerBits + sum(widths) == lengthOctets * 8;
    }
    item hk : Packet {
        attribute f1 : Field { :>> order = 1; :>> offset = 48; :>> width = 16; }
        attribute f2 : Field { :>> order = 2; :>> offset = 64; :>> width = 16; }
        attribute f3 : Field { :>> order = 3; :>> offset = 80; :>> width = 32; }
        :>> widths = (16, 16, 32);
        :>> lengthOctets = 14;
    }
    item bad : Packet { :>> widths = (16, 16); :>> lengthOctets = 14; }
}
