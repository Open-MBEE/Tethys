// Probe for docs/findings/WP-SW-3.md F-S09 (scale): a supervisor of twenty parallel monitor regions,
// each with a timer and a reset, driven by a conductor sending one reset an hour for a day. Measures
// `-advance` and `-engine check` against the `make check` budget. The assertion sits on the host:
// inside a parallel state definition it is refused ("parallel state body contains unsupported
// member the constraint usage"). Run (time each):
//   sysml -quiet -instantiate FS09::scenario -state "FS09::Host::supervisor FS09::scenario.host" -advance 90000 model/probes/F-S09-twenty-region-supervisor.sysml
//   timeout 900 sysml -quiet -engine check -instantiate FS09::scenario -state "FS09::Host::supervisor FS09::scenario.host" -advance 90000 -check-property FS09::Host::tripsBounded model/probes/F-S09-twenty-region-supervisor.sysml
// Observed: -advance 0.14 s wall, every region tripped; -engine check killed by the timeout after 15 min with no verdict.
package FS09 {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    item def Reset {
        doc /* Resets every tripped monitor. */
    }
    port def ResetPort {
        doc /* Receives resets. */
        in item reset : Reset;
    }
    interface def ResetLink {
        doc /* Conductor to host. */
        end source : ~ResetPort;
        end sink : ResetPort;
    }
    constraint def TripsBounded {
        doc /* No more trips than twenty-four hours of twenty monitors can produce. */
        in trips : Integer;
        trips <= 480
    }
    state def TwentyMonitors parallel {
        doc /* Twenty monitor regions: each trips on its own timer and re-arms on a reset. */
        port command : ResetPort;
        attribute trips : Integer = 0;
        state monitor01 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 1.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor02 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 2.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor03 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 3.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor04 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 4.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor05 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 5.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor06 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 6.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor07 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 7.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor08 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 8.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor09 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 9.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor10 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 10.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor11 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 11.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor12 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 12.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor13 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 13.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor14 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 14.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor15 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 15.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor16 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 16.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor17 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 17.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor18 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 18.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor19 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 19.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
        state monitor20 {
            entry; then nominal;
            state nominal;
            state tripped {
                entry assign trips := trips + 1;
            }
            transition first nominal accept after 20.0 [h] then tripped;
            transition first tripped accept Reset via command then nominal;
        }
    }
    part def Host {
        doc /* Exhibits the supervisor on its command port. */
        port command : ResetPort;
        exhibit state supervisor : TwentyMonitors;
        bind supervisor.command = command;
        assert constraint tripsBounded : TripsBounded { in trips = supervisor.trips; }
    }
    part def Conductor {
        doc /* Sends a reset every hour for a day. */
        port outbound : ~ResetPort;
        attribute period : DurationValue = 1.0 [h];
        perform action script {
            first start;
            then action hour01 accept after period; then send new Reset() via outbound;
            then action hour02 accept after period; then send new Reset() via outbound;
            then action hour03 accept after period; then send new Reset() via outbound;
            then action hour04 accept after period; then send new Reset() via outbound;
            then action hour05 accept after period; then send new Reset() via outbound;
            then action hour06 accept after period; then send new Reset() via outbound;
            then action hour07 accept after period; then send new Reset() via outbound;
            then action hour08 accept after period; then send new Reset() via outbound;
            then action hour09 accept after period; then send new Reset() via outbound;
            then action hour10 accept after period; then send new Reset() via outbound;
            then action hour11 accept after period; then send new Reset() via outbound;
            then action hour12 accept after period; then send new Reset() via outbound;
            then done;
        }
    }
    part scenario {
        doc /* Host under the conductor. */
        part conductor : Conductor;
        part host : Host;
        interface l : ResetLink connect conductor.outbound to host.command;
    }
}
