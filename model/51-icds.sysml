// One interface control document per TethysInterfaces interface definition: each ICD
// specialises its interface def, carries the parameters the items crossing it must agree on,
// binds the two ends to those parameters, names its control authority and is verified by a
// case of its own, the inspector dispenser, inspector thermal and propellant feed ICDs
// included; icdSystem retypes every system interface by its ICD.
package TethysIcds {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import TethysInterfaces::*;
    private import TethysRequirements::*;
    private import TethysTug::Tug;
    private import TethysInspector::Inspector;
    private import TethysSystem::*;
    private import TethysMeridian::RfBand;
    private import VerificationCases::VerificationMethodKind;

    // ---- interface control metadata ----------------------------------------------------
    enum def IcdStatus {
        doc /* Where an ICD stands in its control cycle. */
        enum draft;
        enum preliminary;
        enum baselined;
    }

    metadata def InterfaceControl {
        doc /* Who controls an interface, which document records it and at what revision. */
        attribute authority : String;
        attribute document : String;
        attribute revision : String;
        attribute status : IcdStatus;
    }

    enum def Modulation {
        doc /* Carrier modulations the RF ICDs admit. */
        enum bpsk;
        enum qpsk;
        enum gmsk;
    }

    enum def ChannelCoding {
        doc /* Channel codings the RF ICDs admit. */
        enum convolutionalRateHalf;
        enum turboRateSixth;
        enum ldpcRateSevenEighths;
    }

    // ---- packets: the command/telemetry interface the dictionary is written against -----
    attribute def PacketSecondaryHeader {
        doc /* The packet secondary header: the on-board time code, seconds and 1/65 536 s
             * fractions since the mission epoch, six octets. */
        attribute coarseTime : Natural;
        attribute fineTime : Natural;
        attribute length : StorageCapacityValue default = 6.0 [B];
    }
    item def SpacePacket {
        doc /* A packet on the space link: the six-octet primary header's application id, sequence
             * count and length, and the secondary header carrying the time code. */
        attribute apid : Natural;
        attribute sequenceCount : Natural;
        attribute length : StorageCapacityValue;
        attribute primaryHeaderLength : StorageCapacityValue default = 6.0 [B];
        attribute secondaryHeader : PacketSecondaryHeader;
    }
    item def TelemetryPacket :> SpacePacket, Telemetry {
        doc /* A telemetry packet: a space packet carrying housekeeping or payload data. */
    }
    item def CommandPacket :> SpacePacket, Telecommand {
        doc /* A telecommand packet: a space packet carrying one command and its arguments. */
        attribute opcode : String;
    }

    port def PacketPort {
        doc /* The packet-level view of the space link: telemetry out, commands in. */
        out item telemetry : TelemetryPacket;
        in item command : CommandPacket;
    }

    interface def <'TI-010'> PacketInterface {
        doc /* The command/telemetry packet interface between the flight software and the
             * operations centre, independent of the RF link that carries it. */
        @InterfaceControl { authority = "operations centre"; document = "TCD-010"; revision = "A"; status = IcdStatus::preliminary; }
        end flightSide : PacketPort;
        end groundSide : ~PacketPort;
        attribute maximumPacketLength : StorageCapacityValue = 65542.0 [B];
        attribute housekeepingApid : Natural = 1;
        flow of TelemetryPacket from flightSide.telemetry to groundSide.telemetry;
        flow of CommandPacket from groundSide.command to flightSide.command;
    }

    // ---- ICDs over the backbone interface definitions ----------------------------------
    interface def <'TI-001'> TugInspectorIcd :> TugInspectorInterface {
        doc /* Argent ↔ Wren while stowed: 28 V keep-alive power, checkout telemetry over the
             * umbilical and the separation signal. The mechanical and thermal disciplines of
             * the stowed stack are TI-007 and TI-008 over their own backbone interfaces. */
        @InterfaceControl { authority = "flight segment"; document = "ICD-001"; revision = "B"; status = IcdStatus::baselined; }
        attribute keepAliveVoltage : ElectricPotentialValue = 28.0 [V];
        attribute keepAlivePower : PowerValue = 15.0 [W];
        attribute checkoutDataRate : BinaryDigitRateValue = 9600.0 [bit/s];
        bind tugSide.keepAlive.voltage = inspectorSide.keepAlive.voltage;
        binding bind tugSide.keepAlive.voltage = keepAliveVoltage;
        binding bind tugSide.keepAlive.power = keepAlivePower;
        flow of ElectricalPower from tugSide.keepAlive to inspectorSide.keepAlive;
    }

    interface def <'TI-002'> LaunchIcd :> SpacecraftLauncherInterface {
        doc /* Stack ↔ Arcturus-5H: adapter geometry, quasi-static and dynamic loads, fairing
             * environments, stack mass properties, separation and injection accuracy. */
        @InterfaceControl { authority = "launch segment"; document = "ICD-002"; revision = "C"; status = IcdStatus::baselined; }
        attribute adapterDiameter : LengthValue = 1.666 [m];
        attribute fairingEnvelopeDiameter : LengthValue = 4.5 [m];
        attribute fairingEnvelopeHeight : LengthValue = 11.0 [m];
        attribute axialQuasiStatic : AccelerationValue = 58.8 ['m/s²'];
        attribute lateralQuasiStatic : AccelerationValue = 19.6 ['m/s²'];
        attribute sineVibration : AccelerationValue = 9.8 ['m/s²'];
        attribute shockResponse : AccelerationValue = 19600.0 ['m/s²'];
        attribute acousticLevelDb : Real = 139.5;
        attribute maximumStackMass : MassValue = 12800.0 [kg];
        attribute maximumCentreOfMassHeight : LengthValue = 2.6 [m];
        attribute separationSpeed : SpeedValue = 0.5 ['m/s'];
        attribute tipOffRate : AngularVelocityValue = 0.0175 ['rad⋅s⁻¹'];
        attribute injectionC3ToleranceKm2PerS2 : Real = 0.1;
        attribute umbilicalVoltage : ElectricPotentialValue = 28.0 [V];
        bind spacecraftSide.load.quasiStaticAcceleration = launcherSide.load.quasiStaticAcceleration;
        binding bind spacecraftSide.load.quasiStaticAcceleration = axialQuasiStatic;
        bind spacecraftSide.separable = launcherSide.separable;
        assert constraint separable { spacecraftSide.separable == true }
    }

    interface def <'TI-003'> SpaceGroundIcd :> SpaceGroundLink {
        doc /* Argent ↔ Meridian: X-band up and down, Ka-band down, modulation, coding, rate
             * envelope, two-way ranging and the packet protocol over the link. The Earth-range
             * envelope per phase is in TethysLinkBudgets. */
        @InterfaceControl { authority = "ground segment"; document = "ICD-003"; revision = "B"; status = IcdStatus::baselined; }
        attribute uplinkFrequency : FrequencyValue = 7.165e9 [Hz];
        attribute xDownlinkFrequency : FrequencyValue = 8.445e9 [Hz];
        attribute kaDownlinkFrequency : FrequencyValue = 32.05e9 [Hz];
        attribute uplinkModulation : Modulation = Modulation::bpsk;
        attribute downlinkModulation : Modulation = Modulation::qpsk;
        attribute downlinkCoding : ChannelCoding = ChannelCoding::turboRateSixth;
        attribute minimumDownlinkRate : BinaryDigitRateValue = 2.0e3 [bit/s];
        attribute maximumDownlinkRate : BinaryDigitRateValue = 4.0e6 [bit/s];
        attribute uplinkRate : BinaryDigitRateValue = 2.0e3 [bit/s];
        attribute rangingTone : FrequencyValue = 1.0e6 [Hz];
        attribute packetProtocol : String = "space packet, telemetry transfer frames";
        attribute downlinkBand : RfBand = RfBand::xBand;
        bind spacecraftSide.carrier.frequency = groundSide.carrier.frequency;
        binding bind spacecraftSide.carrier.frequency = xDownlinkFrequency;
        flow of RfCarrier from spacecraftSide.carrier to groundSide.carrier;
        flow of RfCarrier from groundSide.carrier to spacecraftSide.carrier;
        assert constraint ratesOrdered { minimumDownlinkRate <= maximumDownlinkRate }
    }

    interface def <'TI-004'> InspectorRelayIcd :> InspectorRelayLink {
        doc /* Wren ↔ Argent proximity link: UHF, low rate down to Wren, imagery and radar up to
             * Argent, usable within the geometry window below; the data volume it must carry
             * depends on the target size and is sized in TethysLinkBudgets. */
        @InterfaceControl { authority = "flight segment"; document = "ICD-004"; revision = "A"; status = IcdStatus::preliminary; }
        attribute forwardFrequency : FrequencyValue = 401.5e6 [Hz];
        attribute returnFrequency : FrequencyValue = 437.5e6 [Hz];
        attribute modulation : Modulation = Modulation::gmsk;
        attribute coding : ChannelCoding = ChannelCoding::convolutionalRateHalf;
        attribute returnRate : BinaryDigitRateValue = 1.0e6 [bit/s];
        attribute maximumRange : LengthValue = 5.0 [km];
        attribute minimumRange : LengthValue = 50.0 [m];
        attribute maximumOffBoresight : AngularMeasureValue = 60.0 ['°'];
        attribute dailyContactWindow : DurationValue = 18.0 [h];
        bind inspectorSide.carrier.frequency = tugSide.carrier.frequency;
        binding bind inspectorSide.carrier.frequency = returnFrequency;
        flow of RfCarrier from inspectorSide.carrier to tugSide.carrier;
        assert constraint window { minimumRange < maximumRange }
    }

    interface def <'TI-005'> CaptureIcd :> CaptureInterface {
        doc /* Argent ↔ Amaranth through capture: contact loads, grapple torque, the spin the
             * capture system absorbs and the contact thermal environment. The spin and load
             * figures are the large-target case; the small and nominal cases follow from the
             * target cases in TethysLinkBudgets and the capture analyses. */
        @InterfaceControl { authority = "flight segment"; document = "ICD-005"; revision = "A"; status = IcdStatus::draft; }
        attribute maximumContactForce : ForceValue = 2500.0 [N];
        attribute maximumContactSpeed : SpeedValue = 0.1 ['m/s'];
        attribute maximumBodySpinRate : AngularVelocityValue = 0.0175 ['rad⋅s⁻¹'];
        attribute despinTorque : TorqueValue = 120.0 ['N⋅m'];
        attribute surfaceTemperatureMinimum : ThermodynamicTemperatureValue = 180.0 [K];
        attribute surfaceTemperatureMaximum : ThermodynamicTemperatureValue = 340.0 [K];
        bind tugSide.load.force = bodySide.load.force;
        binding bind tugSide.load.force = maximumContactForce;
        assert constraint temperaturesOrdered { surfaceTemperatureMinimum < surfaceTemperatureMaximum }
    }

    interface def <'TI-006'> DockingIcd :> DockingInterface {
        doc /* Argent ↔ visiting vehicle in the DRO: a passive androgynous ring on the tug,
             * power transfer and a data link across the mated interface. */
        @InterfaceControl { authority = "utilisation partners"; document = "ICD-006"; revision = "A"; status = IcdStatus::draft; }
        attribute ringDiameter : LengthValue = 0.8 [m];
        attribute captureSpeedMaximum : SpeedValue = 0.05 ['m/s'];
        attribute transferVoltage : ElectricPotentialValue = 120.0 [V];
        attribute transferPower : PowerValue = 2.0 [kW];
        attribute dataRate : BinaryDigitRateValue = 10.0e6 [bit/s];
        bind tugSide.transfer.voltage = visitorSide.transfer.voltage;
        binding bind tugSide.transfer.voltage = transferVoltage;
        binding bind tugSide.transfer.power = transferPower;
    }

    interface def <'TI-011'> PowerIcd :> PowerInterface {
        doc /* The regulated 28 V bus from the EPS to every subsystem, with its ripple and
             * the current limit each load may draw. */
        @InterfaceControl { authority = "flight segment"; document = "ICD-011"; revision = "B"; status = IcdStatus::baselined; }
        attribute busVoltage : ElectricPotentialValue = 28.0 [V];
        attribute voltageTolerance : ElectricPotentialValue = 1.0 [V];
        attribute maximumLoadPower : PowerValue = 1200.0 [W];
        bind source.supply.voltage = load.supply.voltage;
        binding bind source.supply.voltage = busVoltage;
        flow of ElectricalPower from source.supply to load.supply;
    }

    interface def <'TI-012'> HighVoltagePowerIcd :> PowerInterface {
        doc /* The unregulated high-voltage bus from the arrays to the SEP power processing. */
        @InterfaceControl { authority = "flight segment"; document = "ICD-012"; revision = "A"; status = IcdStatus::preliminary; }
        attribute busVoltage : ElectricPotentialValue = 300.0 [V];
        attribute maximumLoadPower : PowerValue = 40.0 [kW];
        bind source.supply.voltage = load.supply.voltage;
        binding bind source.supply.voltage = busVoltage;
        binding bind source.supply.power = maximumLoadPower;
    }

    interface def <'TI-013'> DataBusIcd :> DataBusInterface {
        doc /* The on-board data bus: a dual-redundant serial bus at 1 Mbit/s carrying packets
             * between the bus controller and every remote terminal. */
        @InterfaceControl { authority = "flight segment"; document = "ICD-013"; revision = "B"; status = IcdStatus::baselined; }
        attribute busRate : BinaryDigitRateValue = 1.0e6 [bit/s];
        attribute maximumPacketLength : StorageCapacityValue = 1024.0 [B];
        attribute pollingPeriod : DurationValue = 0.125 [s];
        bind a.telemetry.dataRate = b.telemetry.dataRate;
        flow of Telemetry from b.telemetry to a.telemetry;
        flow of Telecommand from a.telecommand to b.telecommand;
    }

    interface def <'TI-014'> ThermalIcd :> ThermalInterface {
        doc /* A conductive thermal interface: bolted joint conductance and the heat it carries
             * at the interface temperature band. */
        @InterfaceControl { authority = "flight segment"; document = "ICD-014"; revision = "A"; status = IcdStatus::preliminary; }
        attribute conductance : ThermalConductanceValue = 2.5 [W/K];
        attribute maximumHeat : PowerValue = 150.0 [W];
        attribute interfaceTemperatureMinimum : ThermodynamicTemperatureValue = 253.0 [K];
        attribute interfaceTemperatureMaximum : ThermodynamicTemperatureValue = 313.0 [K];
        bind hot.heat.power = cold.heat.power;
        binding bind hot.heat.power = maximumHeat;
        flow of Heat from hot.heat to cold.heat;
    }

    // ---- ICDs over the stowed-stack and propellant-loading interface definitions ---------
    interface def <'TI-007'> InspectorDispenserIcd :> InspectorDispenserInterface {
        doc /* Argent ↔ Wren mechanical: the dispenser rails, preload, release spring and the
             * ejection velocity; connected over the structure ports the backbone exposes. */
        @InterfaceControl { authority = "flight segment"; document = "ICD-007"; revision = "A"; status = IcdStatus::preliminary; }
        attribute railPreload : ForceValue = 400.0 [N];
        attribute ejectionSpeed : SpeedValue = 0.3 ['m/s'];
        attribute inspectorMassMaximum : MassValue = 26.0 [kg];
        bind tugSide.load.force = inspectorSide.load.force;
        binding bind tugSide.load.force = railPreload;
    }

    interface def <'TI-008'> InspectorThermalIcd :> InspectorThermalInterface {
        doc /* Argent ↔ Wren thermal while stowed: the dispenser keeps Wren's battery above its
             * survival temperature with heat conducted through the rails. */
        @InterfaceControl { authority = "flight segment"; document = "ICD-008"; revision = "A"; status = IcdStatus::draft; }
        attribute survivalTemperature : ThermodynamicTemperatureValue = 263.0 [K];
        attribute heaterPower : PowerValue = 4.0 [W];
        bind tugSide.heat.power = inspectorSide.heat.power;
        binding bind tugSide.heat.power = heaterPower;
    }

    interface def <'TI-009'> PropellantFeedIcd :> PropellantFeedInterface {
        doc /* Tank ↔ ground fill-and-drain for xenon and hydrazine: fill pressure, flow rate
             * and the mass loaded. */
        @InterfaceControl { authority = "launch segment"; document = "ICD-009"; revision = "A"; status = IcdStatus::preliminary; }
        attribute fillPressure : PressureValue = 15.0e6 [Pa];
        attribute fillRate : MassFlowRateValue = 0.02 ['kg⋅s⁻¹'];
        attribute loadedMass : MassValue;
        bind tankSide.propellantFlow.mass = groundSide.propellantFlow.mass;
        binding bind tankSide.propellantFlow.mass = loadedMass;
        flow of Propellant from groundSide.propellantFlow to tankSide.propellantFlow;
    }

    // ---- the system with every interface typed by its ICD --------------------------------
    part def IcdFlightSegment :> TethysFlightSegment {
        doc /* The flight segment with every one of its interfaces retyped by its ICD. */
        interface :>> inspectorCarrier : TugInspectorIcd
            connect tug.eps.inspectorKeepAlive to inspector.bus.umbilical;
        interface :>> inspectorRelay : InspectorRelayIcd
            connect inspector.bus.proximity to tug.telecom.proximity;
        interface :>> inspectorDispenser : InspectorDispenserIcd
            connect tug.structure.inspectorAttachment to inspector.carrierAttachment;
        interface :>> inspectorThermal : InspectorThermalIcd
            connect tug.thermal.inspectorThermal to inspector.stowedThermal;
    }

    part def LoadingCart {
        doc /* A ground loading cart: the fill-and-drain side of a propellant feed ICD. */
        port fill : ~FluidPort;
    }

    part def PropellantLoading {
        doc /* Argent on the pad with its xenon and hydrazine loading carts connected. */
        part tug : Tug;
        part xenonCart : LoadingCart;
        part hydrazineCart : LoadingCart;
        interface xenonFill : PropellantFeedIcd connect tug.sep.xenonFill to xenonCart.fill {
            attribute :>> loadedMass = 6600.0 [kg];
        }
        interface hydrazineFill : PropellantFeedIcd connect tug.rcs.hydrazineFill to hydrazineCart.fill {
            attribute :>> loadedMass = 400.0 [kg];
        }
    }

    part icdSystem :> tethysSystem {
        doc /* The mission with every system-level interface typed by its ICD, the N² the
             * matrix rendering is taken from. */
        part :>> flight : IcdFlightSegment;
        interface :>> launchAdapter : LaunchIcd
            connect flight.tug.structure.launcherAttachment to launch.vehicle.payloadAdapter;
        interface :>> deepSpaceLink : SpaceGroundIcd
            connect flight.tug.telecom.deepSpace to ground.network.stations.uplinkDownlink;
        interface :>> capture : CaptureIcd
            connect flight.tug.captureSystem.grapple to target.surface;
        interface :>> visitorDocking : DockingIcd
            connect flight.tug.structure.docking to visitor.docking;
    }

    // ---- interface requirements and their verification -----------------------------------
    requirement def InterfaceRequirement :> SystemRequirement {
        doc /* A requirement that both sides of an interface conform to its ICD. */
        attribute icdDocument : String;
    }

    requirement <'TI-101'> tugInspectorConformance : InterfaceRequirement {
        doc /* Argent and Wren shall conform to ICD-001 across the umbilical: keep-alive voltage
             * 28 V, power 15 W, checkout telemetry at 9 600 bit/s. */
        attribute :>> icdDocument = "ICD-001";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::acceptance; }
    }
    requirement <'TI-102'> launchConformance : InterfaceRequirement {
        doc /* The stack shall conform to ICD-002: mass, centre of mass, loads, envelope and
             * separation. */
        attribute :>> icdDocument = "ICD-002";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
    }
    requirement <'TI-103'> spaceGroundConformance : InterfaceRequirement {
        doc /* Argent and Meridian shall conform to ICD-003: frequencies, modulation, coding,
             * rates and ranging. */
        attribute :>> icdDocument = "ICD-003";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
    }
    requirement <'TI-104'> relayConformance : InterfaceRequirement {
        doc /* Wren and Argent shall conform to ICD-004 across the proximity link within the
             * geometry window. */
        attribute :>> icdDocument = "ICD-004";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::acceptance; }
    }
    requirement <'TI-105'> captureConformance : InterfaceRequirement {
        doc /* The capture system shall meet ICD-005 for every target case. */
        attribute :>> icdDocument = "ICD-005";
        @Verification { method = VerificationMethodKind::analyze; level = VerificationLevel::system; stage = VerificationStage::qualification; }
    }
    requirement <'TI-106'> dockingConformance : InterfaceRequirement {
        doc /* The docking ring shall meet ICD-006. */
        attribute :>> icdDocument = "ICD-006";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
    }
    requirement <'TI-107'> dispenserConformance : InterfaceRequirement {
        doc /* The dispenser and Wren shall meet ICD-007. */
        attribute :>> icdDocument = "ICD-007";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::acceptance; }
    }
    requirement <'TI-108'> inspectorThermalConformance : InterfaceRequirement {
        doc /* The dispenser shall keep Wren above its survival temperature per ICD-008. */
        attribute :>> icdDocument = "ICD-008";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::qualification; }
    }
    requirement <'TI-109'> propellantFeedConformance : InterfaceRequirement {
        doc /* Both fill-and-drain interfaces shall meet ICD-009. */
        attribute :>> icdDocument = "ICD-009";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
    }
    requirement <'TI-110'> packetConformance : InterfaceRequirement {
        doc /* Flight software and the operations centre shall exchange only packets the
             * dictionary defines, per TCD-010. */
        attribute :>> icdDocument = "TCD-010";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::system; stage = VerificationStage::preLaunch; }
    }
    requirement <'TI-111'> internalBusConformance : InterfaceRequirement {
        doc /* Every subsystem shall meet ICD-011 to ICD-014 on its power, data and thermal
             * interfaces. */
        attribute :>> icdDocument = "ICD-011, ICD-012, ICD-013, ICD-014";
        @Verification { method = VerificationMethodKind::test; level = VerificationLevel::subsystem; stage = VerificationStage::acceptance; }
    }

    verification def InterfaceVerification {
        doc /* A verification case for one ICD: fit check, functional or analytical. */
        attribute icdDocument : String;
        attribute method : VerificationMethodKind;
    }

    verification umbilicalTest : InterfaceVerification {
        doc /* Mated umbilical test with flight Wren in the dispenser. */
        attribute :>> icdDocument = "ICD-001";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify tugInspectorConformance { doc /* The ICD requirement this case verifies. */ } }
    }
    verification adapterFitCheck : InterfaceVerification {
        doc /* Adapter fit check and separation shock test with the launcher's flight adapter. */
        attribute :>> icdDocument = "ICD-002";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify launchConformance { doc /* The ICD requirement this case verifies. */ } }
    }
    verification rfCompatibilityTest : InterfaceVerification {
        doc /* End-to-end RF compatibility test between the flight transponder and a station. */
        attribute :>> icdDocument = "ICD-003";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify spaceGroundConformance { doc /* The ICD requirement this case verifies. */ } }
    }
    verification relayRangeTest : InterfaceVerification {
        doc /* Proximity link test over the geometry window on an antenna range. */
        attribute :>> icdDocument = "ICD-004";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify relayConformance { doc /* The ICD requirement this case verifies. */ } }
    }
    verification captureLoadsAnalysis : InterfaceVerification {
        doc /* Contact-dynamics analysis for the small, nominal and large target cases. */
        attribute :>> icdDocument = "ICD-005";
        attribute :>> method = VerificationMethodKind::analyze;
        objective { doc /* Show both sides conform to the ICD. */ verify captureConformance { doc /* The ICD requirement this case verifies. */ } }
    }
    verification dockingRingTest : InterfaceVerification {
        doc /* Docking ring capture and power-transfer test with the partner's mating ring. */
        attribute :>> icdDocument = "ICD-006";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify dockingConformance { doc /* The ICD requirement this case verifies. */ } }
    }
    verification dispenserEjectionTest : InterfaceVerification {
        doc /* Ejection test on the dispenser with a Wren mass model. */
        attribute :>> icdDocument = "ICD-007";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify dispenserConformance { doc /* The ICD requirement this case verifies. */ } }
    }
    verification stowedThermalTest : InterfaceVerification {
        doc /* Thermal-vacuum cold case with Wren stowed. */
        attribute :>> icdDocument = "ICD-008";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify inspectorThermalConformance { doc /* The ICD requirement this case verifies. */ } }
    }
    verification fillAndDrainTest : InterfaceVerification {
        doc /* Fill-and-drain flow test with the ground loading cart. */
        attribute :>> icdDocument = "ICD-009";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify propellantFeedConformance { doc /* The ICD requirement this case verifies. */ } }
    }
    verification packetDictionaryTest : InterfaceVerification {
        doc /* Every dictionary command sent and every telemetry packet decoded on the flatsat. */
        attribute :>> icdDocument = "TCD-010";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify packetConformance { doc /* The ICD requirement this case verifies. */ } }
    }
    verification subsystemInterfaceTests : InterfaceVerification {
        doc /* Power, data-bus and thermal interface acceptance tests on each subsystem. */
        attribute :>> icdDocument = "ICD-011, ICD-012, ICD-013, ICD-014";
        attribute :>> method = VerificationMethodKind::test;
        objective { doc /* Show both sides conform to the ICD. */ verify internalBusConformance { doc /* The ICD requirement this case verifies. */ } }
    }
}
