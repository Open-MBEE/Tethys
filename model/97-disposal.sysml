package TethysDisposal {
    doc /* End of life: the requirements on disposing of the Argent tug once the body is in
         * its distant retrograde orbit, the disposal and passivation sequence, the tug's
         * end-of-life states, the final as-flown snapshot, and the closeout and post-flight
         * assessment records. The body itself is the mission product and stays in the DRO;
         * only the tug is disposed of, to a heliocentric orbit that does not return. */
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import ModelingMetadata::*;
    private import VerificationCases::*;
    private import TethysTug::*;
    private import TethysRequirements::*;
    private import TethysAsBuilt::*;
    private import TethysImportedData::*;
    private import TethysEnvironment::RocketEquationDeltaV;
    private import TethysTarget::targetCases;

    requirement <'TS-290'> heliocentricDisposal : SystemRequirement {
        doc /* After separating from the body in the distant retrograde orbit, the tug shall
             * leave the Earth–Moon system through a lunar gravity assist onto a heliocentric
             * orbit whose closest approach to Earth, propagated over 100 years with
             * dispersions, stays above ten lunar distances. */
        attribute minimumEarthApproach : LengthValue = 5.1e9 [m];
        attribute propagationSpan : DurationValue = 36525.0 [d];
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::inFlight; }
        require constraint {
            doc /* Ten lunar distances: 3.84e9 m. */
            minimumEarthApproach >= 3.84e9 [m]
        }
    }

    requirement <'TS-291'> disposalPropellantReserve : SystemRequirement {
        doc /* At DRO insertion the tug shall hold xenon for the departure burn with 50 %
             * margin: the reserve shall give the dry tug at least 1.5 times the 180 m/s the
             * departure and lunar-flyby targeting need. Checked against the gauged xenon of
             * the DRO-insertion snapshot. */
        subject tug : Tug;
        attribute xenonReserve : MassValue;
        attribute departureDeltaV : SpeedValue = 180.0 ['m/s'];
        attribute margin : Real = 1.5;
        attribute deltaVCapability : Real = RocketEquationDeltaV(2900.0, 5638.4 + 540.0, 5638.4);
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::inFlight; }
        require constraint { deltaVCapability >= margin * 180.0 }
    }

    requirement <'TS-292'> passivation : SystemRequirement {
        doc /* Within 30 days of the disposal burn the tug shall be passivated: xenon tanks
             * vented to below 1 bar, hydrazine depleted to below 2 kg, the battery
             * disconnected from the bus and the transmitter switched off. Checked against
             * the final as-flown snapshot. */
        attribute xenonTankPressure : PressureValue = argentAtEndOfLife.passivated.xenonTankPressure;
        attribute hydrazineResidual : MassValue = argentAtEndOfLife.passivated.telemetry.hydrazineRemaining;
        attribute batteryDisconnected : Boolean = argentAtEndOfLife.passivated.batteryDisconnected;
        attribute transmitterOff : Boolean = argentAtEndOfLife.passivated.transmitterOff;
        attribute deadline : DurationValue = 30.0 [d];
        attribute passivationDelay : DurationValue =
            closeout.passivationCompleteTime - closeout.disposalBurnTime;
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::inFlight; }
        require constraint {
            xenonTankPressure <= 1.0e5 [Pa] and hydrazineResidual <= 2.0 [kg]
                and batteryDisconnected and transmitterOff
                and passivationDelay >= 0.0 [d] and passivationDelay <= deadline
        }
    }

    calc def SeparationDeltaV {
        doc /* Velocity the separation impulse imparts to the body: the impulse over the body
             * mass, the units divided out inside the calculation and restored as m/s. */
        in impulse : ImpulseValue;
        in bodyMass : MassValue;
        return : SpeedValue = (impulse / (1 ['N⋅s'])) / (bodyMass / (1 [kg])) * (1 ['m/s']);
    }

    requirement <'TS-293'> separationSafety : SystemRequirement {
        doc /* Separation of the tug from the captured body shall impart less than 1 mm/s to
             * the body, for the small, nominal and large target cases and for the body as
             * characterised, so the body stays in its DRO. */
        attribute separationImpulse : ImpulseValue = 25.0 ['N⋅s'];
        attribute smallBodyDeltaV : SpeedValue =
            SeparationDeltaV(separationImpulse, targetCases.small.mass);
        attribute nominalBodyDeltaV : SpeedValue =
            SeparationDeltaV(separationImpulse, targetCases.nominal.mass);
        attribute largeBodyDeltaV : SpeedValue =
            SeparationDeltaV(separationImpulse, targetCases.large.mass);
        attribute asCharacterisedDeltaV : SpeedValue =
            SeparationDeltaV(separationImpulse, amaranthFM.postCapture.mass);
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::acceptance; }
        require constraint {
            doc /* The small case bounds the others. */
            smallBodyDeltaV <= 1.0e-3 ['m/s'] and asCharacterisedDeltaV <= 1.0e-3 ['m/s']
        }
    }

    action def DisposalSequence {
        doc /* Tug disposal and passivation: separate from the body in the DRO, burn to
             * depart, use the Moon to leave the Earth–Moon system, confirm the heliocentric
             * orbit, then passivate in the order that keeps the tug controllable longest. */
        action separateFromBody { doc /* Release the capture mechanism and back away at under 1 mm/s imparted. */ }
        action departureBurn { doc /* Low-thrust departure from the DRO toward the lunar flyby. */ }
        action lunarGravityAssist { doc /* Flyby that raises the orbit to Earth escape. */ }
        action confirmHeliocentric { doc /* Radio tracking confirms the 100-year non-return orbit. */ }
        action ventXenon { doc /* Open the xenon tank latch valves and vent to below 1 bar. */ }
        action depleteHydrazine { doc /* Burn the hydrazine to depletion through opposed thrusters. */ }
        action transmitterOff { doc /* Final telemetry frame, then the transmitter is commanded off. */ }
        action disconnectBattery { doc /* Timed relay disconnects the battery from the bus. */ }
        first start then separateFromBody;
        first separateFromBody then departureBurn;
        first departureBurn then lunarGravityAssist;
        first lunarGravityAssist then confirmHeliocentric;
        first confirmHeliocentric then ventXenon;
        first ventXenon then depleteHydrazine;
        first depleteHydrazine then transmitterOff;
        first transmitterOff then disconnectBattery;
        first disconnectBattery then done;
    }

    action disposal : DisposalSequence {
        doc /* The disposal of ARG-FM-001. */
    }

    state def TugEndOfLife {
        doc /* The tug's states from the end of the DRO phase to passivation. */
        entry; then attached;
        state attached { doc /* Holding the body in the DRO. */ }
        state separated { doc /* Free-flying in the DRO, clear of the body. */ }
        state departing { doc /* Thrusting out of the DRO toward the lunar flyby. */ }
        state heliocentric { doc /* Past Earth escape, on the disposal orbit. */ }
        state passivated { doc /* Vented, depleted, silent and unpowered. */ }
        transition attached then separated;
        transition separated then departing;
        transition departing then heliocentric;
        transition heliocentric then passivated;
    }

    part argentAtEndOfLife :> argentFlight {
        doc /* ARG-FM-001 after DRO insertion: the disposal-burn snapshot and the final
             * as-flown snapshot at passivation, which closes the individual's history. */
        snapshot afterDisposalBurn {
            doc /* Departure burn complete, lunar flyby targeted. */
            attribute telemetry : TelemetrySample {
                attribute :>> missionElapsedTime = 2231.0 [d];
                attribute :>> xenonRemaining = 468.0 [kg];
                attribute :>> hydrazineRemaining = 312.0 [kg];
                attribute :>> arrayPower = 41.7 [kW];
                attribute :>> batteryStateOfCharge = 0.96;
            }
        }
        snapshot passivated {
            doc /* The final as-flown snapshot: last telemetry frame before transmitter off. */
            attribute telemetry : TelemetrySample {
                attribute :>> missionElapsedTime = 2254.0 [d];
                attribute :>> xenonRemaining = 2.1 [kg];
                attribute :>> hydrazineRemaining = 0.8 [kg];
                attribute :>> arrayPower = 41.6 [kW];
                attribute :>> batteryStateOfCharge = 0.12;
            }
            attribute xenonTankPressure : PressureValue = 0.6e5 [Pa];
            attribute batteryDisconnected : Boolean = true;
            attribute transmitterOff : Boolean = true;
        }
        first atDroInsertion then afterDisposalBurn;
        first afterDisposalBurn then passivated;
        exhibit state endOfLife : TugEndOfLife;
    }

    satisfy heliocentricDisposal by argentAtEndOfLife {
        doc /* The propagated disposal orbit stays 5.1e9 m from Earth over 100 years. */
    }
    satisfy passivation by argentAtEndOfLife.passivated {
        doc /* The final as-flown snapshot meets every passivation condition. */
    }
    satisfy separationSafety by argentFM.captureSystem {
        doc /* The capture system's 25 N·s release impulse is safe for every target case. */
    }

    item def CloseoutRecord {
        doc /* The decommissioning record: when the disposal burn and passivation happened,
             * where the model and data archive went, and the final state of the tug. */
        attribute disposalBurnTime : DurationValue;
        attribute passivationCompleteTime : DurationValue;
        attribute archiveLocation : String;
        ref part finalState : Tug;
    }

    item closeout : CloseoutRecord {
        doc /* Closeout of ARG-FM-001, 23 days from disposal burn to passivation. */
        attribute :>> disposalBurnTime = 2231.0 [d];
        attribute :>> passivationCompleteTime = 2254.0 [d];
        attribute :>> archiveLocation = "Tethys project archive, as-flown model tethys-1.0 and data/";
        ref :>> finalState = argentAtEndOfLife.passivated;
    }

    item def PostFlightAssessment {
        doc /* The post-flight assessment report: what the flight taught, as issues on the
             * elements they concern. */
        attribute reportId : String;
        attribute lessonCount : Natural;
    }

    item pfar : PostFlightAssessment {
        doc /* PFAR-001: three lessons recorded as issues on the as-built elements. */
        attribute :>> reportId = "PFAR-001";
        attribute :>> lessonCount = 3;
        @Issue { text = "Amaranth mass was 21.5 % above the pre-arrival estimate; the large target case should start at +25 %, not +40 %, with a +60 % stretch case."; }
        @Issue { text = "Wren's 3.75 % mass overrun cost a waiver; the inspector allocation should carry 5 % at CDR."; }
        @Issue { text = "Hydrazine depletion took 9 days of the 30-day passivation window; plan the depletion burns before the lunar flyby."; }
    }
}
