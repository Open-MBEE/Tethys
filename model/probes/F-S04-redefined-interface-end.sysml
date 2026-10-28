// Probe for docs/findings/WP-SW-3.md F-S04: redefining the part at the receiving end of an
// inherited interface (`part :>> vehicle : BetterVehicle` under a definition whose interface
// connects `injector.outbound to vehicle.command`) materialises a second `vehicle` object that
// takes the message; the redefined part's machine never sees it. The same parts under their own
// interface receive. Run:
//   sysml -quiet -instantiate FS04::base -state "FS04::Vehicle::m FS04::base.vehicle" -advance 10 -trace model/probes/F-S04-redefined-interface-end.sysml
//   sysml -quiet -instantiate FS04::redefined -state "FS04::Vehicle::m FS04::redefined.vehicle" -advance 10 -trace model/probes/F-S04-redefined-interface-end.sysml
//   sysml -quiet -instantiate FS04::own -state "FS04::Vehicle::m FS04::own.vehicle" -advance 10 model/probes/F-S04-redefined-interface-end.sysml
// Observed: base and own reach `gone`; redefined stays `idle` and its trace materialises
// `BetterVehicle` and then a second `vehicle`.
package FS04 {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    item def Go {
        doc /* The command sent once. */
    }
    port def GoPort {
        doc /* Receives the command. */
        in item go : Go;
    }
    interface def GoLink {
        doc /* Injector to vehicle. */
        end source : ~GoPort;
        end sink : GoPort;
    }
    state def Listener {
        doc /* One transition on the command through its port. */
        port command : GoPort;
        entry; then idle;
        state idle;
        state gone;
        transition first idle accept Go via command then gone;
    }
    part def Vehicle {
        doc /* Exhibits the listener on its command port. */
        port command : GoPort;
        exhibit state m : Listener;
        bind m.command = command;
    }
    part def BetterVehicle :> Vehicle {
        doc /* The vehicle with one more attribute. */
        attribute extra : Integer = 1;
    }
    part def Injector {
        doc /* Sends the command once after a second. */
        port outbound : ~GoPort;
        perform action script {
            first start;
            then action wait accept after 1.0 [s];
            then send new Go() via outbound;
            then done;
        }
    }
    part def Scenario {
        doc /* Injector and vehicle under one interface. */
        part injector : Injector;
        part vehicle : Vehicle;
        interface l : GoLink connect injector.outbound to vehicle.command;
    }
    part base : Scenario;
    part redefined : Scenario {
        part :>> vehicle : BetterVehicle;
    }
    part own {
        part injector : Injector;
        part vehicle : BetterVehicle;
        interface l : GoLink connect injector.outbound to vehicle.command;
    }
}
