// The Meridian ground segment in detail: the three deep-space stations, the operations centre,
// the flight-dynamics facility and the science data system, the roles that staff them, the
// data products they exchange and the end-to-end flow from the tug's sensors to the archive.
package TethysMeridian {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysInterfaces::*;
    private import TethysGround::*;
    private import TethysTug::Tug;

    // ---- vocabulary --------------------------------------------------------------------
    enum def RfBand {
        doc /* The radio bands the mission uses: X and Ka to Earth, a short-range UHF
             * proximity link between Wren and Argent. */
        enum xBand;
        enum kaBand;
        enum uhfProximity;
    }

    enum def ProductLevel {
        doc /* Data product levels: L0 raw frames, L1 decoded and time-tagged, L2 derived
             * geophysical products (shape, mass, spin), L3 the decision packages built from them. */
        enum l0;
        enum l1;
        enum l2;
        enum l3;
    }

    // ---- data products -----------------------------------------------------------------
    item def DataProduct {
        doc /* Anything the ground segment produces, with its level and its size on disk. */
        attribute level : ProductLevel;
        attribute volume : StorageCapacityValue;
    }
    item def RawFrames :> DataProduct {
        doc /* L0: the transfer frames as received by a station, undecoded, with receive time. */
        attribute :>> level = ProductLevel::l0;
    }
    item def DecodedTelemetry :> DataProduct {
        doc /* L1: packets decoded, time-correlated and converted to engineering units. */
        attribute :>> level = ProductLevel::l1;
    }
    item def TrackingData :> DataProduct {
        doc /* L1: two-way Doppler and range observables from a pass. */
        attribute :>> level = ProductLevel::l1;
        attribute dopplerNoise : SpeedValue;
        attribute rangeNoise : LengthValue;
    }
    item def ShapeModel :> DataProduct {
        doc /* L2: the target shape model from Wren imagery and Argent's lidar. */
        attribute :>> level = ProductLevel::l2;
        attribute facetCount : Natural;
        attribute meanDiameter : LengthValue;
    }
    item def MassSpinEstimate :> DataProduct {
        doc /* L2: the target mass and spin state estimated from gravity perturbations on Wren
             * and from the shape model's apparent motion. */
        attribute :>> level = ProductLevel::l2;
        attribute mass : MassValue;
        attribute massUncertainty : MassValue;
        attribute rotationPeriod : DurationValue;
    }
    item def OrbitSolution :> DataProduct {
        doc /* L2: an orbit-determination solution for the tug or the target with its covariance. */
        attribute :>> level = ProductLevel::l2;
        attribute positionUncertainty : LengthValue;
        attribute velocityUncertainty : SpeedValue;
        attribute arcLength : DurationValue;
    }
    item def ManeuverPlan :> DataProduct {
        doc /* L3: a thrust-arc or impulsive manoeuvre plan ready to be sequenced. */
        attribute :>> level = ProductLevel::l3;
        attribute deltaV : SpeedValue;
        attribute arcDuration : DurationValue;
        attribute xenonUsed : MassValue;
    }
    item def CaptureReadinessPackage :> DataProduct {
        doc /* L3: shape, mass, spin and orbit solutions bundled with their uncertainties for the
             * capture-commit decision. */
        attribute :>> level = ProductLevel::l3;
        attribute massUncertaintyFraction : Real;
        attribute spinKnown : Boolean;
    }
    item def ArchiveRecord :> DataProduct {
        doc /* A product as archived: checksummed, versioned and distributable. */
        attribute version : Natural;
    }

    port def ProductPort {
        doc /* A ground-internal data port: products in either direction. */
        inout item product : DataProduct;
    }

    // ---- stations ----------------------------------------------------------------------
    part def MeridianStation :> DeepSpaceStation {
        doc /* A Meridian station: a 32 m beam-waveguide antenna with X and Ka receive and X
             * transmit. The dB figures (G/T, EIRP) are levels, kept as Real with a Db suffix;
             * TethysLinkBudgets documents that boundary. */
        attribute stationName : String;
        attribute latitude : AngularMeasureValue;
        attribute elevationMask : AngularMeasureValue = 10.0 ['°'];
        attribute systemNoiseTemperatureX : ThermodynamicTemperatureValue = 25.0 [K];
        attribute systemNoiseTemperatureKa : ThermodynamicTemperatureValue = 60.0 [K];
        attribute transmitPowerX : PowerValue = 20.0 [kW];
        attribute gainToNoiseTemperatureXDbPerK : Real = 52.0;
        attribute gainToNoiseTemperatureKaDbPerK : Real = 59.5;
        attribute eirpXDbw : Real = 110.0;
        attribute bands : RfBand[2];
        port backhaul : ProductPort;
    }

    part def OperationsRole {
        doc /* A position on the operations team, with its shift length. */
        attribute title : String;
        attribute shiftLength : DurationValue;
        attribute positionsPerShift : Natural;
    }

    part def GroundSoftwareComponent {
        doc /* A software component of the ground segment as the facilities see it: a named
             * product at a version. The Meridian Operations Suite (TethysGroundSoftware)
             * specialises it component by component and retypes the parts below. */
        attribute productName : String;
        attribute version : String;
    }

    part def MeridianOperationsCentre :> MissionOperationsCentre {
        doc /* The Tethys operations centre: a flight-director console, spacecraft and
             * ground-system positions, and the planning team that builds the weekly plan. */
        attribute shiftsPerDay : Natural = 3;
        part flightDirector : OperationsRole {
            attribute :>> title = "flight director";
            attribute :>> shiftLength = 8.0 [h];
            attribute :>> positionsPerShift = 1;
        }
        part spacecraftEngineer : OperationsRole {
            attribute :>> title = "spacecraft systems engineer";
            attribute :>> shiftLength = 8.0 [h];
            attribute :>> positionsPerShift = 2;
        }
        part groundController : OperationsRole {
            attribute :>> title = "ground controller";
            attribute :>> shiftLength = 8.0 [h];
            attribute :>> positionsPerShift = 1;
        }
        part sequencePlanner : OperationsRole {
            attribute :>> title = "sequence planner";
            attribute :>> shiftLength = 8.0 [h];
            attribute :>> positionsPerShift = 2;
        }
        part commandBuilder : GroundSoftwareComponent;
        part sequencer : GroundSoftwareComponent;
        part telemetryServer : GroundSoftwareComponent;
        part passPlanner : GroundSoftwareComponent;
        part anomalyTracker : GroundSoftwareComponent;
        part proximityPlanner : GroundSoftwareComponent;
        port stationFeed : ProductPort;
        port toFlightDynamics : ProductPort;
        port toScience : ProductPort;
    }

    part def MeridianFlightDynamics :> FlightDynamicsFacility {
        doc /* Orbit determination of Argent and of Amaranth, low-thrust arc design, and the
             * DRO insertion design; it returns orbit solutions and manoeuvre plans. */
        part navigator : OperationsRole {
            attribute :>> title = "navigation analyst";
            attribute :>> shiftLength = 8.0 [h];
            attribute :>> positionsPerShift = 2;
        }
        attribute odArcLength : DurationValue = 7.0 [d];
        part flightDynamicsTool : GroundSoftwareComponent;
        port fromOperations : ProductPort;
        port toScience : ProductPort;
    }

    part def MeridianScienceDataSystem :> ScienceDataSystem {
        doc /* Processes L0 frames to L1 telemetry, builds the L2 shape, mass and spin products
             * and the L3 capture-readiness package, and archives every level. */
        part dataEngineer : OperationsRole {
            attribute :>> title = "science data engineer";
            attribute :>> shiftLength = 8.0 [h];
            attribute :>> positionsPerShift = 1;
        }
        attribute archiveCapacity : StorageCapacityValue = 400.0e12 [B];
        part dataArchive : GroundSoftwareComponent;
        port fromOperations : ProductPort;
        port fromFlightDynamics : ProductPort;
        port archive : ProductPort;
    }

    connection def StationBackhaul {
        doc /* The terrestrial network joining the three stations to the operations centre. */
        end caldera : ProductPort;
        end tableland : ProductPort;
        end saltmarsh : ProductPort;
        end centre : ProductPort;
    }

    part def MeridianNetwork :> GroundNetwork {
        doc /* The Meridian network: three 32 m stations roughly 120° apart in longitude so the
             * tug is always above the elevation mask of at least one, with the operations
             * centre, flight dynamics and the science data system behind them. */
        part :>> stations : MeridianStation[3];
        part caldera :> stations {
            attribute :>> stationName = "Caldera";
            attribute :>> antennaDiameter = 32.0 [m];
            attribute :>> longitude = -68.0 ['°'];
            attribute :>> latitude = -33.0 ['°'];
            attribute :>> bands = (RfBand::xBand, RfBand::kaBand);
        }
        part tableland :> stations {
            attribute :>> stationName = "Tableland";
            attribute :>> antennaDiameter = 32.0 [m];
            attribute :>> longitude = 52.0 ['°'];
            attribute :>> latitude = 41.0 ['°'];
            attribute :>> bands = (RfBand::xBand, RfBand::kaBand);
        }
        part saltmarsh :> stations {
            attribute :>> stationName = "Saltmarsh";
            attribute :>> antennaDiameter = 32.0 [m];
            attribute :>> longitude = 172.0 ['°'];
            attribute :>> latitude = -38.0 ['°'];
            attribute :>> bands = (RfBand::xBand, RfBand::kaBand);
        }
        part :>> moc : MeridianOperationsCentre;
        part :>> fdf : MeridianFlightDynamics;
        part :>> sds : MeridianScienceDataSystem;

        connection backhaul : StationBackhaul
            connect (caldera.backhaul, tableland.backhaul, saltmarsh.backhaul, moc.stationFeed);
        connect moc.toFlightDynamics to fdf.fromOperations;
        connect moc.toScience to sds.fromOperations;
        connect fdf.toScience to sds.fromFlightDynamics;

        flow of RawFrames from caldera.backhaul.product to moc.stationFeed.product;
        flow of TrackingData from moc.toFlightDynamics.product to fdf.fromOperations.product;
        flow of OrbitSolution from fdf.toScience.product to sds.fromFlightDynamics.product;
        flow of RawFrames from moc.toScience.product to sds.fromOperations.product;
        flow of ArchiveRecord from sds.fromOperations.product to sds.archive.product;

        assert constraint longitudeSpread {
            doc /* Successive stations are at least 100° apart so coverage never drops. */
            tableland.longitude - caldera.longitude >= 100.0 ['°']
                and saltmarsh.longitude - tableland.longitude >= 100.0 ['°']
        }
    }

    part meridian : MeridianNetwork {
        doc /* The Meridian network as committed to Tethys. */
    }

    // ---- the science pipeline as a behaviour --------------------------------------------
    action def ProcessingStep {
        doc /* One step of the science data pipeline: a product in, a product out. */
        in input : DataProduct;
        out output : DataProduct;
    }

    action def SciencePipeline {
        doc /* L0 frames to the L3 capture-readiness package, each level handed to the next
             * by a succession flow; every level is also archived. */
        in frames : RawFrames;
        action decode : ProcessingStep { in :>> input = frames; out :>> output : DecodedTelemetry; }
        action buildShape : ProcessingStep { in :>> input; out :>> output : ShapeModel; }
        action estimateMassSpin : ProcessingStep { in :>> input; out :>> output : MassSpinEstimate; }
        action assemblePackage : ProcessingStep { in :>> input; out :>> output : CaptureReadinessPackage; }
        succession flow of DecodedTelemetry from decode.output to buildShape.input;
        succession flow of ShapeModel from buildShape.output to estimateMassSpin.input;
        succession flow of MassSpinEstimate from estimateMassSpin.output to assemblePackage.input;
        out readiness : CaptureReadinessPackage = assemblePackage.output;
    }

    // ---- end-to-end data flow -------------------------------------------------------------
    part def EndToEndDataFlow {
        doc /* The telemetry path from Argent's sensors through its data bus and X-band
             * downlink to a Meridian station, then across the backhaul to the operations centre
             * and into the science data system; the command path runs the other way. */
        part tug : Tug;
        part network : MeridianNetwork;
        flow of Telemetry from tug.sensors.bus.telemetry to tug.cdh.busController.telemetry;
        flow of Telemetry from tug.cdh.busController.telemetry to tug.telecom.bus.telemetry;
        flow of RfCarrier from tug.telecom.deepSpace.carrier to network.caldera.uplinkDownlink.carrier;
        flow of RfCarrier from network.tableland.uplinkDownlink.carrier to tug.telecom.deepSpace.carrier;
        flow of Telecommand from tug.telecom.bus.telecommand to tug.cdh.busController.telecommand;
        message commandRelease of Telecommand from network.moc to network.caldera;
        message frameDelivery of RawFrames from network.caldera to network.sds;
        perform action pipeline : SciencePipeline;
    }

    part endToEnd : EndToEndDataFlow {
        doc /* The data flow as it stands for Argent and the committed Meridian network. */
    }
}
