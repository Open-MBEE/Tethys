// Findings F-C05: a nested action's `in` parameter bound to the enclosing action's `in`
// parameter (`in mechanism = system;`) reads empty when the enclosing action is performed by a
// part that binds that parameter (`perform action run : Run { in system = mechanism; }`), so an
// `out` default over it fails with `operator '<=' is not defined for a Rational and a sequence`.
// Load alone: sysml -instantiate "'F-C05'::operation" -e "'F-C05'::operation.run.system.limit"
//   -e "'F-C05'::operation.run.check.mechanism.limit" -e "'F-C05'::operation.run.check.go" <this file>
// Observed: run.system.limit = [200.0], run.check.mechanism.limit = [], run.check.go fails.
// Expected: run.check.mechanism.limit = [200.0], run.check.go = [true] (SysML v2 7.16.2:
// a parameter binding in an action body binds the nested parameter to the enclosing one).
package 'F-C05' {
    private import ScalarValues::*;
    part def Mechanism { attribute limit : Real; }
    action def Check { in mechanism : Mechanism; out go : Boolean = 100.0 <= mechanism.limit; }
    action def Run {
        in system : Mechanism;
        action check : Check { in mechanism = system; }
    }
    part mechanism : Mechanism { attribute :>> limit = 200.0; }
    part operation {
        perform action run : Run { in system = mechanism; }
    }
}
