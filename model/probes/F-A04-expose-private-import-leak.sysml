// Probe: `expose A::*` in a view makes A's *private* import (Lib::Y) visible, so it conflicts with
// Other::Y: OpenSysML warns name-conflict (an error under -warnings-as-errors); the pilot accepts.
package Lib { part def Y; }
package Other { part def Y; }
package A { private import Lib::*; part def X; }
package C {
    view v { expose A::*; expose Other::*; }
}
