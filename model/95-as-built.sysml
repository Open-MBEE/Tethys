package TethysAsBuilt {
    doc /* The flight units as they were built, not as they were designed: the Argent and
         * Wren individuals with their serial numbers and as-measured masses, the Amaranth
         * individual as it was characterised after arrival, the configuration baselines
         * each review placed under control, and the integration sequence that joined the
         * units. The as-designed values stay in TethysTug, TethysInspector and
         * TethysTarget; this package only specialises them. */
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysTug::*;
    private import TethysInspector::*;
    private import TethysTarget::*;
    private import TethysRequirements::*;

    enum def ProcurementKind {
        doc /* How a unit was obtained: built in house, bought to a specification, or
             * reused from an earlier build with a heritage record. */
        make;
        buy;
        reuse;
    }

    attribute def UnitIdentity {
        doc /* The identity a flight unit carries on its nameplate and in its end-item data
             * package: serial, production lot and the drawing revision it was built to. */
        attribute serialNumber : String;
        attribute lotNumber : String;
        attribute drawingRevision : String;
    }

    metadata def Provenance {
        doc /* Heritage and procurement record of a flight unit: who supplied it and whether
             * it was made, bought or reused. */
        attribute procurement : ProcurementKind;
        attribute supplier : String;
        attribute heritageNote : String;
    }

    part def AsBuiltUnit {
        doc /* A unit that exists as hardware: it has an identity and a mass that was put on
             * a scale, as opposed to the current best estimate it was designed to. The
             * as-measured mass must lie within the mass-property tolerance of the design
             * value the unit redefines. */
        attribute identity : UnitIdentity;
        attribute asMeasuredMass : MassValue;
        attribute designMass : MassValue;
        attribute massTolerance : Real = 0.03;
        attribute massDeviation : Real = (asMeasuredMass - designMass) / designMass;
    }

    individual part def SepFlightUnit :> SolarElectricPropulsion, AsBuiltUnit {
        doc /* The one solar-electric propulsion module flown on Argent. */
    }
    individual part def EpsFlightUnit :> ElectricalPowerSystem, AsBuiltUnit {
        doc /* The one electrical-power subsystem flown on Argent. */
    }
    individual part def CaptureFlightUnit :> CaptureSystem, AsBuiltUnit {
        doc /* The one capture system flown on Argent. */
    }
    individual part def RcsFlightUnit :> ReactionControl, AsBuiltUnit {
        doc /* The one hydrazine reaction-control subsystem flown on Argent. */
    }

    individual part def ArgentFlightModel :> Tug, AsBuiltUnit {
        doc /* The single Argent tug that flew: a Tug with an identity and the masses that
             * were weighed at acceptance. Its subsystems are the serialised flight units. */
        part :>> sep : SepFlightUnit;
        part :>> eps : EpsFlightUnit;
        part :>> captureSystem : CaptureFlightUnit;
        part :>> rcs : RcsFlightUnit;
    }

    individual part def WrenFlightModel :> Inspector, AsBuiltUnit {
        doc /* The single Wren inspector that flew, weighed with its cold-gas propellant
             * loaded. */
        attribute :>> designMass = wetMass;
    }

    individual part def AmaranthAsCharacterised :> SmallBody {
        doc /* 2031 QX "Amaranth" as it turned out to be: the pre-arrival estimate of
             * TethysEnvironment::amaranth as a snapshot, then the values Wren's imaging and
             * Argent's radio tracking measured after rendezvous, then the captured body.
             * The difference between the first two snapshots is the realised target
             * uncertainty the design carried as its small/nominal/large cases. */
        attribute massEstimateRatio : Real = postCharacterisation.mass / preArrival.mass;
        snapshot preArrival {
            doc /* The ground estimate the system was sized to. */
            attribute :>> meanDiameter = TethysEnvironment::amaranth.meanDiameter;
            attribute :>> bulkDensity = TethysEnvironment::amaranth.bulkDensity;
            attribute :>> mass = TethysEnvironment::amaranth.mass;
            attribute :>> rotationPeriod = TethysEnvironment::amaranth.rotationPeriod;
        }
        snapshot postCharacterisation {
            doc /* After the characterisation phase: a slightly larger, slightly denser and
                 * faster-spinning body than estimated, still inside the large target case. */
            attribute :>> meanDiameter = 7.1 [m];
            attribute :>> bulkDensity = 2350.0 ['kg⋅m⁻³'];
            attribute :>> mass = 440.0e3 [kg];
            attribute :>> rotationPeriod = 231.0 [s];
        }
        snapshot postCapture {
            doc /* After capture and despin: the body is rigidly held and its spin is the
                 * stack's. Mass and shape are unchanged; ~1.2 t of regolith was shed. */
            attribute :>> meanDiameter = 7.1 [m];
            attribute :>> bulkDensity = 2350.0 ['kg⋅m⁻³'];
            attribute :>> mass = 438.8e3 [kg];
            attribute :>> rotationPeriod = 0.0 [s];
        }
        first preArrival then postCharacterisation;
        first postCharacterisation then postCapture;
    }

    individual part argentFM : ArgentFlightModel {
        doc /* Argent flight model, serial ARG-FM-001, as accepted at ORR: 5 638.4 kg dry
             * against 5 600 kg designed (+0.7 %), 6 600 kg xenon and 400 kg hydrazine loaded. */
        @Provenance { procurement = ProcurementKind::make; supplier = "Tethys integration facility";
            heritageNote = "new build; SEP module reuses a qualified thruster design"; }
        attribute :>> identity {
            attribute :>> serialNumber = "ARG-FM-001";
            attribute :>> lotNumber = "ARG-L1";
            attribute :>> drawingRevision = "C";
        }
        attribute :>> designMass = 5600.0 [kg];
        attribute :>> dryMass default = 5638.4 [kg];
        attribute :>> wetMass default = 12638.4 [kg];
        attribute :>> asMeasuredMass = 5638.4 [kg];
        part :>> sep {
            attribute :>> identity { attribute :>> serialNumber = "SEP-FM-001"; attribute :>> lotNumber = "SEP-L2"; attribute :>> drawingRevision = "B"; }
            attribute :>> designMass = 1180.0 [kg];
            attribute :>> asMeasuredMass = 1196.2 [kg];
            attribute :>> mass = asMeasuredMass;
            attribute :>> xenonMass = 6600.0 [kg];
            attribute :>> thrusterCount = 4;
            attribute :>> operatingThrusters = 3;
            attribute :>> specificImpulse = 2900.0 [s];
            attribute :>> maximumPower = 40.0 [kW];
        }
        part :>> eps {
            attribute :>> identity { attribute :>> serialNumber = "EPS-FM-001"; attribute :>> lotNumber = "EPS-L1"; attribute :>> drawingRevision = "D"; }
            attribute :>> designMass = 1240.0 [kg];
            attribute :>> asMeasuredMass = 1251.5 [kg];
            attribute :>> mass = asMeasuredMass;
            attribute :>> arrayPowerAtOneAu = 48.0 [kW];
        }
        part :>> captureSystem {
            attribute :>> identity { attribute :>> serialNumber = "CAP-FM-001"; attribute :>> lotNumber = "CAP-L1"; attribute :>> drawingRevision = "E"; }
            attribute :>> designMass = 820.0 [kg];
            attribute :>> asMeasuredMass = 833.9 [kg];
            attribute :>> mass = asMeasuredMass;
            attribute :>> maximumBodyDiameter = 10.0 [m];
            attribute :>> maximumBodyMass = 1000.0e3 [kg];
        }
        part :>> rcs {
            attribute :>> identity { attribute :>> serialNumber = "RCS-FM-001"; attribute :>> lotNumber = "RCS-L1"; attribute :>> drawingRevision = "B"; }
            attribute :>> designMass = 210.0 [kg];
            attribute :>> asMeasuredMass = 207.1 [kg];
            attribute :>> mass = asMeasuredMass;
            attribute :>> hydrazineMass = 400.0 [kg];
        }
        snapshot atCdr {
            doc /* The product baseline: the design values under configuration control at CDR. */
            attribute :>> dryMass = 5600.0 [kg];
            attribute :>> wetMass = 12600.0 [kg];
        }
        snapshot atAcceptance {
            doc /* The as-built baseline weighed at acceptance, before shipment. */
            attribute :>> dryMass = 5638.4 [kg];
            attribute :>> wetMass = 12638.4 [kg];
        }
        first atCdr then atAcceptance;
    }

    individual part wrenFM : WrenFlightModel {
        doc /* Wren flight model, serial WRN-FM-001: 24.9 kg wet against 24.0 kg designed
             * (+3.75 %), over the 3 % mass-property tolerance and carried on waiver
             * TW-001 because the carrier and separation system have the margin. */
        @Provenance { procurement = ProcurementKind::buy; supplier = "Larkspur Small Satellites";
            heritageNote = "12U bus with two prior flights; imaging payload new"; }
        attribute :>> identity {
            attribute :>> serialNumber = "WRN-FM-001";
            attribute :>> lotNumber = "LSS-12U-7";
            attribute :>> drawingRevision = "A";
        }
        attribute :>> wetMass = 24.0 [kg];
        attribute :>> asMeasuredMass = 24.9 [kg];
        part :>> bus { attribute :>> mass = 14.6 [kg]; }
        part :>> payload { attribute :>> mass = 6.1 [kg]; }
        part :>> propulsion { attribute :>> mass = 4.2 [kg]; attribute :>> propellantMass = 1.1 [kg]; }
    }

    individual part amaranthFM : AmaranthAsCharacterised {
        doc /* The one Amaranth there is, carried through its three snapshots. */
    }

    requirement def AsMeasuredMassWithinTolerance {
        doc /* A flight unit's as-measured mass lies within the mass-property tolerance of the
             * design mass it redefines; a unit outside it flies on a waiver. */
        subject unit : AsBuiltUnit;
        require constraint {
            doc /* |measured − design| ≤ tolerance × design. */
            unit.massDeviation <= unit.massTolerance and unit.massDeviation >= -unit.massTolerance
        }
    }

    requirement <'TS-268'> argentMassWithinTolerance : AsMeasuredMassWithinTolerance {
        doc /* The Argent flight model's as-measured dry mass shall be within 3 % of the CDR
             * dry mass. */
    }

    requirement <'TS-269'> wrenMassWithinTolerance : AsMeasuredMassWithinTolerance {
        doc /* The Wren flight model's as-measured wet mass shall be within 3 % of the CDR
             * wet mass. Not met by WRN-FM-001; see waiver TW-001. */
    }

    satisfy argentMassWithinTolerance by argentFM {
        doc /* ARG-FM-001 is 0.69 % over its CDR dry mass: within tolerance. */
    }
    satisfy wrenMassWithinTolerance by wrenFM {
        doc /* WRN-FM-001 is 3.75 % over its CDR wet mass: violated, flown on waiver TW-001. */
    }

    item def Waiver {
        doc /* A documented departure from a requirement accepted by the project: the
             * requirement it departs from, the deviation, and the disposition. */
        attribute id : String;
        attribute deviation : String;
        attribute disposition : String;
    }

    item waiverTW001 : Waiver {
        doc /* Wren wet mass 24.9 kg vs 24.0 kg CDR value: accepted because the inspector
             * accommodation on Argent carries 30 kg and the separation system is qualified
             * to 30 kg. */
        attribute :>> id = "TW-001";
        attribute :>> deviation = "WRN-FM-001 as-measured wet mass +3.75 % (limit 3 %)";
        attribute :>> disposition = "use as is";
    }

    dependency wrenMassDeviation from wrenFM to waiverTW001 {
        doc /* The deviation of the Wren flight model is covered by waiver TW-001. */
    }

    enum def BaselineKind {
        doc /* The configuration baselines a review establishes, in lifecycle order. */
        functional;
        allocated;
        product;
        asBuilt;
        asFlown;
    }

    item def ConfigurationBaseline {
        doc /* A configuration baseline: which review established it, what kind it is, which
             * model revision it froze, and the state of the Argent individual it describes. */
        attribute kind : BaselineKind;
        attribute review : String;
        attribute modelRevision : String;
        ref part tugState : Tug;
    }

    item functionalBaseline : ConfigurationBaseline {
        doc /* Established at SRR: the system requirements of TethysRequirements. */
        attribute :>> kind = BaselineKind::functional;
        attribute :>> review = "SRR";
        attribute :>> modelRevision = "tethys-0.1";
        ref :>> tugState = argentFM.atCdr;
    }
    item allocatedBaseline : ConfigurationBaseline {
        doc /* Established at PDR: requirements allocated to the tug, inspector and segments. */
        attribute :>> kind = BaselineKind::allocated;
        attribute :>> review = "PDR";
        attribute :>> modelRevision = "tethys-0.2";
        ref :>> tugState = argentFM.atCdr;
    }
    item productBaseline : ConfigurationBaseline {
        doc /* Established at CDR: the design the flight units were built to. */
        attribute :>> kind = BaselineKind::product;
        attribute :>> review = "CDR";
        attribute :>> modelRevision = "tethys-0.3";
        ref :>> tugState = argentFM.atCdr;
    }
    item asBuiltBaseline : ConfigurationBaseline {
        doc /* Established at ORR: the flight units as weighed, with their waivers. */
        attribute :>> kind = BaselineKind::asBuilt;
        attribute :>> review = "ORR";
        attribute :>> modelRevision = "tethys-0.4";
        ref :>> tugState = argentFM.atAcceptance;
    }
    first functionalBaseline then allocatedBaseline;
    first allocatedBaseline then productBaseline;
    first productBaseline then asBuiltBaseline;

    action def IntegrationSequence {
        doc /* Assembly, integration and test of the flight stack: subsystem flight units are
             * delivered, integrated onto the Argent structure, the stack is weighed and
             * tested, Wren is mated to its carrier attachment, and the stack is shipped to
             * the launch site. */
        action deliverFlightUnits {
            doc /* Receive SEP-FM-001, EPS-FM-001, CAP-FM-001 and RCS-FM-001 with their
                 * end-item data packages. */
        }
        action integrateSubsystems {
            doc /* Mount the units on the structure and connect power and data buses. */
        }
        action weighAndBalance {
            doc /* Weigh the integrated tug: the as-measured dry mass of argentFM. */
        }
        action environmentalTest {
            doc /* Vibration, thermal-vacuum and EMC at acceptance levels. */
        }
        action mateInspector {
            doc /* Mate WRN-FM-001 to the inspector attachment and verify the umbilical. */
        }
        action shipToLaunchSite {
            doc /* Pack and ship the stack; the as-built baseline is frozen at ORR. */
        }
        first start then deliverFlightUnits;
        first deliverFlightUnits then integrateSubsystems;
        first integrateSubsystems then weighAndBalance;
        first weighAndBalance then environmentalTest;
        first environmentalTest then mateInspector;
        first mateInspector then shipToLaunchSite;
        first shipToLaunchSite then done;
    }

    action integration : IntegrationSequence {
        doc /* The integration campaign that was run on the flight units. */
    }

    connection inspectorMated connect argentFM.structure.inspectorAttachment to wrenFM.carrierAttachment {
        doc /* The as-built mate of WRN-FM-001 to the Argent inspector attachment. */
    }
}
