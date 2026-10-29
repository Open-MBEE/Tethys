// Probe F-SW704: a requirement's `require constraint` reading the result of a calc usage owned by
// the subject through a feature chain, against the same read wrapped in an attribute.
// Expected (SysML v2 §7.21.2 requirement constraints are Boolean expressions over the subject;
// §7.4.7 feature chains; a calc usage's result is read through its result parameter name):
// `-satisfy` reports both `throughChain` and `throughAttribute` as holding.
package FSW704 {
    private import ScalarValues::*;
    calc def Verdict {
        doc /* Accepts values of at least one half. */
        in value : Real;
        return accepted : Boolean = value >= 0.5;
    }
    part def Builder {
        doc /* One planted case, read directly and through an attribute. */
        calc planted : Verdict { in value = 0.9; }
        attribute plantedAccepted : Boolean = planted.accepted;
    }
    part builder : Builder {
        doc /* The instance under check. */
    }
    requirement throughChain {
        doc /* The planted case is accepted, read through the calc usage's result. */
        subject b : Builder;
        require constraint {
            doc /* Reads the calc result through the chain. */
            b.planted.accepted
        }
    }
    requirement throughAttribute {
        doc /* The planted case is accepted, read through the wrapping attribute. */
        subject b : Builder;
        require constraint {
            doc /* Reads the attribute. */
            b.plantedAccepted
        }
    }
    satisfy throughChain by builder {
        doc /* Expected to hold. */
    }
    satisfy throughAttribute by builder {
        doc /* Holds on the pinned runtime. */
    }
}
