package TethysImportedData {
    doc /* The flown individuals as the data describe them: snapshots of the Argent flight
         * model at the mission events, whose telemetry values are imported from the
         * ground system's CSV export, and snapshots of Amaranth at the approach epochs,
         * whose ephemeris values are imported from the navigation team's JSON through a
         * mapping file. The snapshot features are declared here and left unvalued; the
         * import (`sysml -import`, see data/) fills them, and the recorded runs show the
         * values it sets. */
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysAsBuilt::*;

    attribute def TelemetrySample {
        doc /* One row of the housekeeping telemetry the ground system exports per event:
             * mission elapsed time, propellant remaining from the tank gauging, array power
             * and battery state of charge. */
        attribute missionElapsedTime : DurationValue;
        attribute xenonRemaining : MassValue;
        attribute hydrazineRemaining : MassValue;
        attribute arrayPower : PowerValue;
        attribute batteryStateOfCharge : Real;
    }

    attribute def EphemerisSample {
        doc /* One navigation solution for the target: epoch as mission elapsed time,
             * heliocentric distance, and range and range rate from Earth. */
        attribute epoch : DurationValue;
        attribute heliocentricDistanceAu : Real;
        attribute earthRange : LengthValue;
        attribute rangeRate : SpeedValue;
    }

    part argentFlight :> argentFM {
        doc /* ARG-FM-001 in flight: the same individual as argentFM, portioned into the
             * snapshots the telemetry export describes and the thrusting timeslice. */
        snapshot afterArraysDeployed {
            doc /* Two days after lift-off, arrays deployed, before the first thrust arc. */
            attribute telemetry : TelemetrySample;
        }
        snapshot atRendezvous {
            doc /* Station-keeping at Amaranth, before Wren is released. */
            attribute telemetry : TelemetrySample;
        }
        snapshot atCaptureComplete {
            doc /* Body captured and despun. */
            attribute telemetry : TelemetrySample;
        }
        snapshot atDroInsertion {
            doc /* Stack inserted into the distant retrograde orbit. */
            attribute telemetry : TelemetrySample;
        }
        timeslice outboundThrust {
            doc /* The outbound thrust arcs, first thrust arc to rendezvous. */
            attribute averageThrust : ForceValue = 1.83 [N];
            attribute thrustDuration : DurationValue = 540.0 [d];
        }
        first afterArraysDeployed then outboundThrust;
        first outboundThrust then atRendezvous;
        first atRendezvous then atCaptureComplete;
        first atCaptureComplete then atDroInsertion;
    }

    part amaranthTracked :> amaranthFM {
        doc /* Amaranth as the navigation team tracked it on approach: three solutions
             * from Argent's radio tracking and Wren's optical navigation. */
        snapshot approachEpoch1 {
            doc /* First optical acquisition. */
            attribute ephemeris : EphemerisSample;
        }
        snapshot approachEpoch2 {
            doc /* Mid-approach solution. */
            attribute ephemeris : EphemerisSample;
        }
        snapshot approachEpoch3 {
            doc /* Solution at rendezvous. */
            attribute ephemeris : EphemerisSample;
        }
        first approachEpoch1 then approachEpoch2;
        first approachEpoch2 then approachEpoch3;
    }

    calc def XenonUsed {
        doc /* Xenon spent between two gauged snapshots. */
        in before : MassValue;
        in later : MassValue;
        return used : MassValue = before - later;
    }

    calc xenonUsedOutbound : XenonUsed {
        doc /* Xenon spent from lift-off to rendezvous, from the imported telemetry. */
        in :>> before = argentFlight.afterArraysDeployed.telemetry.xenonRemaining;
        in :>> later = argentFlight.atRendezvous.telemetry.xenonRemaining;
    }

    calc xenonUsedReturn : XenonUsed {
        doc /* Xenon spent from capture to DRO insertion, from the imported telemetry. */
        in :>> before = argentFlight.atCaptureComplete.telemetry.xenonRemaining;
        in :>> later = argentFlight.atDroInsertion.telemetry.xenonRemaining;
    }
}
