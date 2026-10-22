// Link budgets for the X-band and Ka-band space–ground links and the Wren–Argent proximity
// link, in decibels, with the Earth-range envelope per mission phase and the relay data
// volume for the small, nominal and large target cases.
//
// The decibel boundary: ISQ/SI define `dB` only as a sound-pressure-level unit, so RF levels
// (dBW, dBi, dB/K, dB) have no quantity type in the standard library. Every linear quantity
// (power in W, frequency in Hz, range in m, temperature in K, rate in bit/s) is an ISQ-typed
// attribute; every level is a Real attribute whose name ends in Db (or DbPerK, Dbi), and the
// two meet only in DecibelsFromRatio / RatioFromDecibels. Calculations take Reals in SI base
// units because the library has no logarithm: Log10 below is the one the budgets use.
package TethysLinkBudgets {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import RealFunctions::*;
    private import TethysEnvironment::*;
    private import TethysRequirements::*;
    private import TethysMeridian::RfBand;
    private import VerificationCases::VerificationMethodKind;

    // ---- the logarithm and the decibel boundary ---------------------------------------
    calc def Log10 {
        doc /* log10(x) for any positive x: eight square roots bring x to within [0.8, 1.35] of
             * one, where the atanh series ln(r) = 2 Σ y^(2k+1)/(2k+1), y = (r−1)/(r+1), converges
             * to better than 1e-12 in six terms; the 2^8 factor undoes the roots. Standard
             * SysML stands in for the ln/log10 the library lacks (docs/findings.md F-001). */
        in x : Real;
        attribute r : Real = sqrt(sqrt(sqrt(sqrt(sqrt(sqrt(sqrt(sqrt(x))))))));
        attribute y : Real = (r - 1.0) / (r + 1.0);
        attribute y2 : Real = y * y;
        attribute naturalLog : Real = 512.0 * y * (1.0 + y2 * (1.0 / 3.0 + y2 * (1.0 / 5.0 + y2 * (1.0 / 7.0 + y2 * (1.0 / 9.0 + y2 / 11.0)))));
        return log10 : Real = naturalLog / 2.302585092994046;
    }

    calc def DecibelsFromRatio {
        doc /* A power ratio to decibels: 10 log10(ratio). */
        in ratio : Real;
        return db : Real = 10.0 * Log10(ratio);
    }

    calc def RatioFromDecibels {
        doc /* Decibels to a power ratio: 10^(dB/10). */
        in db : Real;
        return ratio : Real = 10.0 ** (db / 10.0);
    }

    // ---- link geometry -------------------------------------------------------------------
    calc def Wavelength {
        doc /* Carrier wavelength in metres from the frequency in hertz. */
        in frequencyHz : Real;
        return wavelengthM : Real = speedOfLightKmPerS * 1000.0 / frequencyHz;
    }

    calc def DishGainDbi {
        doc /* Parabolic antenna gain: 10 log10(η (πD/λ)²). */
        in diameterM : Real;
        in frequencyHz : Real;
        in efficiency : Real;
        attribute ratio : Real = pi * diameterM / Wavelength(frequencyHz);
        return gainDbi : Real = DecibelsFromRatio(efficiency * ratio * ratio);
    }

    calc def FreeSpaceLossDb {
        doc /* Free-space path loss: 20 log10(4πd/λ), computed as 10 log10 of the square. */
        in rangeM : Real;
        in frequencyHz : Real;
        attribute ratio : Real = 4.0 * pi * rangeM / Wavelength(frequencyHz);
        return lossDb : Real = DecibelsFromRatio(ratio * ratio);
    }

    calc def GainToNoiseTemperatureDbPerK {
        doc /* Receive figure of merit G/T from the antenna gain and system noise temperature. */
        in gainDbi : Real;
        in systemNoiseTemperatureK : Real;
        return gOverTDbPerK : Real = gainDbi - DecibelsFromRatio(systemNoiseTemperatureK);
    }

    calc def LinkMarginDb {
        doc /* Eb/N0 = EIRP − losses + G/T − 10 log10(k) − 10 log10(R), with Boltzmann's constant
             * as −228.6 dBW/(K·Hz); the margin is Eb/N0 less the required Eb/N0 and the
             * implementation loss. */
        in eirpDbw : Real;
        in pathLossDb : Real;
        in otherLossesDb : Real;
        in gOverTDbPerK : Real;
        in dataRateBps : Real;
        in requiredEbN0Db : Real;
        in implementationLossDb : Real;
        attribute ebN0Db : Real = eirpDbw - pathLossDb - otherLossesDb + gOverTDbPerK + 228.6 - DecibelsFromRatio(dataRateBps);
        return marginDb : Real = ebN0Db - requiredEbN0Db - implementationLossDb;
    }

    // ---- Earth range per mission phase -------------------------------------------------------
    attribute def PhaseEarthRange {
        doc /* The tug–Earth distance envelope during one flight phase, with the one-way light
             * time at its far edge. */
        attribute phaseName : String;
        attribute range : RangeEnvelope;
        attribute maximumOneWayLightTime : DurationValue;
    }

    attribute launchAndEarlyOperationsRange : PhaseEarthRange {
        doc /* From separation to the first thrust arc: inside the lunar distance. */
        attribute :>> phaseName = "launch and early operations";
        attribute :>> range { attribute :>> minimum = 0.007e6 [km]; attribute :>> maximum = 0.4e6 [km]; }
        attribute :>> maximumOneWayLightTime = 1.4 [s];
    }
    attribute outboundCruiseRange : PhaseEarthRange {
        doc /* The low-thrust spiral and drift to the target: the tug falls behind Earth to the
             * far edge of the envelope. */
        attribute :>> phaseName = "outbound cruise";
        attribute :>> range { attribute :>> minimum = 0.4e6 [km]; attribute :>> maximum = 60.0e6 [km]; }
        attribute :>> maximumOneWayLightTime = 200.0 [s];
    }
    attribute proximityOperationsRange : PhaseEarthRange {
        doc /* Approach, characterisation and capture at the target: the Earth-like orbit keeps
             * the range between 10 and 45 million km over the stay. */
        attribute :>> phaseName = "approach, characterisation and capture";
        attribute :>> range { attribute :>> minimum = 10.0e6 [km]; attribute :>> maximum = 45.0e6 [km]; }
        attribute :>> maximumOneWayLightTime = 150.0 [s];
    }
    attribute returnCruiseRange : PhaseEarthRange {
        doc /* The return with the body: from the target range back to the lunar gravity assist. */
        attribute :>> phaseName = "return cruise";
        attribute :>> range { attribute :>> minimum = 0.4e6 [km]; attribute :>> maximum = 60.0e6 [km]; }
        attribute :>> maximumOneWayLightTime = 200.0 [s];
    }
    attribute droRange : PhaseEarthRange {
        doc /* Insertion, checkout, utilisation and extended mission in the DRO: lunar distance
             * plus or minus the DRO radius. */
        attribute :>> phaseName = "DRO operations";
        attribute :>> range { attribute :>> minimum = 0.29e6 [km]; attribute :>> maximum = 0.48e6 [km]; }
        attribute :>> maximumOneWayLightTime = 1.6 [s];
    }

    // ---- the links --------------------------------------------------------------------------
    part def LinkBudget {
        doc /* One link at one range: the linear quantities as ISQ attributes, their levels as
             * Reals, and the margin the calcs close. */
        attribute band : RfBand;
        attribute frequency : FrequencyValue;
        attribute range : LengthValue;
        attribute transmitPower : PowerValue;
        attribute transmitGainDbi : Real;
        attribute receiveGainDbi : Real;
        attribute systemNoiseTemperature : ThermodynamicTemperatureValue;
        attribute dataRate : BinaryDigitRateValue;
        attribute otherLossesDb : Real default = 4.0;
        attribute requiredEbN0Db : Real default = 3.0;
        attribute implementationLossDb : Real default = 1.5;
        attribute requiredMarginDb : Real default = 3.0;
        attribute frequencyHz : Real;
        attribute rangeM : Real;
        attribute transmitPowerW : Real;
        attribute systemNoiseTemperatureK : Real;
        attribute dataRateBps : Real;
        attribute eirpDbw : Real = DecibelsFromRatio(transmitPowerW) + transmitGainDbi;
        attribute pathLossDb : Real = FreeSpaceLossDb(rangeM, frequencyHz);
        attribute gOverTDbPerK : Real = GainToNoiseTemperatureDbPerK(receiveGainDbi, systemNoiseTemperatureK);
        attribute marginDb : Real = LinkMarginDb(eirpDbw, pathLossDb, otherLossesDb, gOverTDbPerK, dataRateBps, requiredEbN0Db, implementationLossDb);
    }

    attribute tugHighGainDiameter : LengthValue = 2.4 [m];
    attribute tugHighGainDiameterM : Real = 2.4;
    attribute stationDiameterM : Real = 32.0;
    attribute dishEfficiency : Real = 0.6;

    part xDownlinkAtMaximumRange : LinkBudget {
        doc /* X-band downlink at the 60 million km edge of the cruise envelopes: 100 W into the
             * 2.4 m high-gain antenna, a 32 m Meridian station at 25 K, 1 Mbit/s. */
        attribute :>> band = RfBand::xBand;
        attribute :>> frequency = 8.445e9 [Hz];
        attribute :>> frequencyHz = 8.445e9;
        attribute :>> range = 60.0e6 [km];
        attribute :>> rangeM = 60.0e9;
        attribute :>> transmitPower = 100.0 [W];
        attribute :>> transmitPowerW = 100.0;
        attribute :>> transmitGainDbi = DishGainDbi(tugHighGainDiameterM, frequencyHz, dishEfficiency);
        attribute :>> receiveGainDbi = DishGainDbi(stationDiameterM, frequencyHz, dishEfficiency);
        attribute :>> systemNoiseTemperature = 25.0 [K];
        attribute :>> systemNoiseTemperatureK = 25.0;
        attribute :>> dataRate = 1.0e6 [bit/s];
        attribute :>> dataRateBps = 1.0e6;
    }

    part xUplinkAtMaximumRange : LinkBudget {
        doc /* X-band uplink at 60 million km: 20 kW from the station into the tug's high-gain
             * antenna, 2 kbit/s commanding, a 500 K receive system on the tug. */
        attribute :>> band = RfBand::xBand;
        attribute :>> frequency = 7.165e9 [Hz];
        attribute :>> frequencyHz = 7.165e9;
        attribute :>> range = 60.0e6 [km];
        attribute :>> rangeM = 60.0e9;
        attribute :>> transmitPower = 20.0 [kW];
        attribute :>> transmitPowerW = 20.0e3;
        attribute :>> transmitGainDbi = DishGainDbi(stationDiameterM, frequencyHz, dishEfficiency);
        attribute :>> receiveGainDbi = DishGainDbi(tugHighGainDiameterM, frequencyHz, dishEfficiency);
        attribute :>> systemNoiseTemperature = 500.0 [K];
        attribute :>> systemNoiseTemperatureK = 500.0;
        attribute :>> dataRate = 2.0e3 [bit/s];
        attribute :>> dataRateBps = 2.0e3;
    }

    part kaDownlinkAtTargetRange : LinkBudget {
        doc /* Ka-band science downlink at the 45 million km edge of the proximity-operations
             * envelope: 50 W, 2.4 m antenna, a 60 K station, 4 Mbit/s for the imagery. */
        attribute :>> band = RfBand::kaBand;
        attribute :>> frequency = 32.05e9 [Hz];
        attribute :>> frequencyHz = 32.05e9;
        attribute :>> range = 45.0e6 [km];
        attribute :>> rangeM = 45.0e9;
        attribute :>> transmitPower = 50.0 [W];
        attribute :>> transmitPowerW = 50.0;
        attribute :>> transmitGainDbi = DishGainDbi(tugHighGainDiameterM, frequencyHz, dishEfficiency);
        attribute :>> receiveGainDbi = DishGainDbi(stationDiameterM, frequencyHz, dishEfficiency);
        attribute :>> systemNoiseTemperature = 60.0 [K];
        attribute :>> systemNoiseTemperatureK = 60.0;
        attribute :>> otherLossesDb = 6.0;
        attribute :>> dataRate = 4.0e6 [bit/s];
        attribute :>> dataRateBps = 4.0e6;
    }

    part xDownlinkInDro : LinkBudget {
        doc /* X-band downlink from the DRO at 0.48 million km: the same transmitter at the
             * 4 Mbit/s ceiling of ICD-003. */
        attribute :>> band = RfBand::xBand;
        attribute :>> frequency = 8.445e9 [Hz];
        attribute :>> frequencyHz = 8.445e9;
        attribute :>> range = 0.48e6 [km];
        attribute :>> rangeM = 0.48e9;
        attribute :>> transmitPower = 100.0 [W];
        attribute :>> transmitPowerW = 100.0;
        attribute :>> transmitGainDbi = DishGainDbi(tugHighGainDiameterM, frequencyHz, dishEfficiency);
        attribute :>> receiveGainDbi = DishGainDbi(stationDiameterM, frequencyHz, dishEfficiency);
        attribute :>> systemNoiseTemperature = 25.0 [K];
        attribute :>> systemNoiseTemperatureK = 25.0;
        attribute :>> dataRate = 4.0e6 [bit/s];
        attribute :>> dataRateBps = 4.0e6;
    }

    part proximityReturnLink : LinkBudget {
        doc /* Wren to Argent at the 5 km edge of the ICD-004 window: 0.5 W into a 3 dBi patch
             * on Wren, a 6 dBi patch and a 400 K receiver on Argent, 1 Mbit/s of imagery. */
        attribute :>> band = RfBand::uhfProximity;
        attribute :>> frequency = 437.5e6 [Hz];
        attribute :>> frequencyHz = 437.5e6;
        attribute :>> range = 5.0 [km];
        attribute :>> rangeM = 5.0e3;
        attribute :>> transmitPower = 0.5 [W];
        attribute :>> transmitPowerW = 0.5;
        attribute :>> transmitGainDbi = 3.0;
        attribute :>> receiveGainDbi = 6.0;
        attribute :>> systemNoiseTemperature = 400.0 [K];
        attribute :>> systemNoiseTemperatureK = 400.0;
        attribute :>> dataRate = 1.0e6 [bit/s];
        attribute :>> dataRateBps = 1.0e6;
    }

    calc def MarginReport {
        doc /* Reads a budget's margin back so a run can print it: MarginReport(xDownlinkAtMaximumRange). */
        in link : LinkBudget;
        return marginDb : Real = link.marginDb;
    }

    // ---- requirements the budgets satisfy ---------------------------------------------------
    requirement def LinkClosure :> SystemRequirement {
        doc /* A link closes with margin at the far edge of its range envelope. */
        subject link : LinkBudget;
        require constraint { link.marginDb >= link.requiredMarginDb }
    }

    requirement <'TG-001'> xDownlinkCloses : LinkClosure {
        doc /* The X-band downlink shall close with at least 3 dB margin at 1 Mbit/s at the
             * 60 million km edge of the cruise envelopes. */
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
    }
    requirement <'TG-002'> xUplinkCloses : LinkClosure {
        doc /* The X-band uplink shall close with at least 3 dB margin at 2 kbit/s at
             * 60 million km. */
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
    }
    requirement <'TG-003'> kaDownlinkCloses : LinkClosure {
        doc /* The Ka-band downlink shall close with at least 3 dB margin at 4 Mbit/s at the
             * 45 million km edge of the proximity-operations envelope. */
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
    }
    requirement <'TG-004'> droDownlinkCloses : LinkClosure {
        doc /* From the DRO the X-band downlink shall close with at least 3 dB margin at the
             * 4 Mbit/s ceiling of ICD-003. */
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
    }
    requirement <'TG-005'> proximityLinkCloses : LinkClosure {
        doc /* The proximity return link shall close with at least 3 dB margin at 1 Mbit/s at
             * the 5 km edge of the ICD-004 window. */
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::acceptance; }
    }

    satisfy xDownlinkCloses by xDownlinkAtMaximumRange { doc /* The X-band downlink case at 60 million km satisfies TG-001. */ }
    satisfy xUplinkCloses by xUplinkAtMaximumRange { doc /* The X-band uplink case at 60 million km satisfies TG-002. */ }
    satisfy kaDownlinkCloses by kaDownlinkAtTargetRange { doc /* The Ka-band case at 45 million km satisfies TG-003. */ }
    satisfy droDownlinkCloses by xDownlinkInDro { doc /* The DRO downlink case satisfies TG-004. */ }
    satisfy proximityLinkCloses by proximityReturnLink { doc /* The proximity return link at 5 km satisfies TG-005. */ }

    // ---- relay data volume by target case ----------------------------------------------------
    calc def CharacterisationDataVolume {
        doc /* Imagery to be relayed over a characterisation campaign: the surface area of a
             * sphere of the given diameter imaged at the given ground sampling, each pixel
             * seen the given number of times at the given bits per pixel. */
        in diameterM : Real;
        in groundSamplingM : Real;
        in coverageCount : Real;
        in bitsPerPixel : Real;
        attribute surfaceAreaM2 : Real = pi * diameterM * diameterM;
        return volumeBits : Real = surfaceAreaM2 / (groundSamplingM * groundSamplingM) * coverageCount * bitsPerPixel;
    }

    calc def RelayDaysRequired {
        doc /* Days of relay contact to carry a data volume at a rate over a daily window. */
        in volumeBits : Real;
        in rateBps : Real;
        in dailyWindowS : Real;
        return days : Real = volumeBits / (rateBps * dailyWindowS);
    }

    part def RelayLoadCase {
        doc /* The relay load for one target size: the volume to carry and the contact days it
             * takes over the ICD-004 link at the duty cycle the geometry window allows (Wren
             * is in the window about 5 % of the time), against the phase allowance. */
        attribute targetDiameter : LengthValue;
        attribute targetDiameterM : Real;
        attribute groundSampling : LengthValue = 0.005 [m];
        attribute coverageCount : Real default = 40.0;
        attribute bitsPerPixel : Real = 12.0;
        attribute relayRate : BinaryDigitRateValue = 1.0e6 [bit/s];
        attribute dailyWindow : DurationValue = 18.0 [h];
        attribute dutyCycle : Real default = 0.05;
        attribute allowedDays : Real default = 30.0;
        attribute volumeBits : Real = CharacterisationDataVolume(targetDiameterM, 0.005, coverageCount, bitsPerPixel);
        attribute relayDays : Real = RelayDaysRequired(volumeBits, 1.0e6, 64800.0 * dutyCycle);
    }

    variation part def RelayLoadByTarget :> RelayLoadCase {
        doc /* The small, nominal and large Amaranth cases from the target-uncertainty list:
             * 4 m, 6.8 m (the backbone value) and 9.5 m. */
        variant part small : RelayLoadCase {
            attribute :>> targetDiameter = 4.0 [m];
            attribute :>> targetDiameterM = 4.0;
        }
        variant part nominal : RelayLoadCase {
            attribute :>> targetDiameter = 6.8 [m];
            attribute :>> targetDiameterM = 6.8;
        }
        variant part large : RelayLoadCase {
            attribute :>> targetDiameter = 9.5 [m];
            attribute :>> targetDiameterM = 9.5;
        }
    }

    part relayLoad : RelayLoadByTarget {
        doc /* The relay load, to be resolved to one variant per target case. */
    }

    requirement <'TG-006'> relayCarriesCharacterisation : SystemRequirement {
        doc /* The proximity link shall carry the full characterisation imagery of the largest
             * credible target within the 30-day characterisation allowance. */
        subject load : RelayLoadCase;
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
        require constraint { load.relayDays <= load.allowedDays }
    }
    part largeTargetRelayLoad : RelayLoadCase {
        doc /* The large-target case stated directly for the satisfaction check. */
        attribute :>> targetDiameter = 9.5 [m];
        attribute :>> targetDiameterM = 9.5;
    }
    satisfy relayCarriesCharacterisation by largeTargetRelayLoad { doc /* The large-target relay load satisfies TG-006. */ }
}
