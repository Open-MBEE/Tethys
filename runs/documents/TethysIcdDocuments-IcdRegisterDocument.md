# Tethys Retrieval interface control document register

One interface control document per TethysInterfaces interface definition, each specialising its interface def with the parameters both sides must agree on, bound to both ends, under the control authority its InterfaceControl metadata names; the software ICDs (TI-02x) of TethysSoftwareIcds profile the packet and data-bus interfaces down to message, frame and register level.

<a id="classes"></a>

## ICD classes

*Interface control documents of the mission*

| name | documentation |
| --- | --- |
| PacketInterface | The command/telemetry packet interface between the flight software and the<br>operations centre, independent of the RF link that carries it. |
| TugInspectorIcd | Argent ↔ Wren while stowed: 28 V keep-alive power, checkout telemetry over the<br>umbilical and the separation signal. The mechanical and thermal disciplines of<br>the stowed stack are TI-007 and TI-008 over their own backbone interfaces. |
| LaunchIcd | Stack ↔ Arcturus-5H: adapter geometry, quasi-static and dynamic loads, fairing<br>environments, stack mass properties, separation and injection accuracy. |
| SpaceGroundIcd | Argent ↔ Meridian: X-band up and down, Ka-band down, modulation, coding, rate<br>envelope, two-way ranging and the packet protocol over the link. The Earth-range<br>envelope per phase is in TethysLinkBudgets. |
| InspectorRelayIcd | Wren ↔ Argent proximity link: UHF, low rate down to Wren, imagery and radar up to<br>Argent, usable within the geometry window below; the data volume it must carry<br>depends on the target size and is sized in TethysLinkBudgets. |
| CaptureIcd | Argent ↔ Amaranth through capture: contact loads, grapple torque, the spin the<br>capture system absorbs and the contact thermal environment. The spin and load<br>figures are the large-target case; the small and nominal cases follow from the<br>target cases in TethysLinkBudgets and the capture analyses. |
| DockingIcd | Argent ↔ visiting vehicle in the DRO: a passive androgynous ring on the tug,<br>power transfer and a data link across the mated interface. |
| PowerIcd | The regulated 28 V bus from the EPS to every subsystem, with its ripple and<br>the current limit each load may draw. |
| HighVoltagePowerIcd | The unregulated high-voltage bus from the arrays to the SEP power processing. |
| DataBusIcd | The on-board data bus: a dual-redundant serial bus at 1 Mbit/s carrying packets<br>between the bus controller and every remote terminal. |
| ThermalIcd | A conductive thermal interface: bolted joint conductance and the heat it carries<br>at the interface temperature band. |
| InspectorDispenserIcd | Argent ↔ Wren mechanical: the dispenser rails, preload, release spring and the<br>ejection velocity; connected over the structure ports the backbone exposes. |
| InspectorThermalIcd | Argent ↔ Wren thermal while stowed: the dispenser keeps Wren's battery above its<br>survival temperature with heat conducted through the rails. |
| PropellantFeedIcd | Tank ↔ ground fill-and-drain for xenon and hydrazine: fill pressure, flow rate<br>and the mass loaded. |
| FanoutTopic | One message type from its publisher to two subscribers: a three-ended interface,<br>which the standard permits for any interface not typed by BinaryInterface. |
| BroadcastTopic | One message type from its publisher to three subscribers: a four-ended interface. |
| OnBoardBusProtocolIcd | The AABP-1 protocol between the software bus controller in the board support<br>package and each remote terminal on the on-board data bus: frame layout,<br>addressing, the time-slot schedule within one polling period and the handling of<br>check failures. The bus electrical and rate figures are those of TI-013. |
| SpaceLinkProfileIcd | The MLS-2 profile of the TI-010 packet interface between the telecom application<br>and the Meridian packet gateway: CCSDS Space Packets with a time-code secondary<br>header, carried in fixed-length transfer frames on eight virtual channels, with a<br>rate set per tug mode and a safe rate set that every mode falls back to. The RF<br>carrier beneath it is TI-003. |
| InspectorRelaySoftwareIcd | The software profile of the proximity relay between the inspector-handling<br>application and Wren: AABP-1 frames tunnelled over the TI-004 GMSK link, the<br>identifier block the relayed inspector packets use, the store-and-forward depth<br>on the tug and the acknowledgement rules. |
| RemoteInterfaceUnitRegisterIcd | The register-level ICD between the remote-interface-unit driver of the board<br>support package and each remote interface unit: the register access frame AABP-1<br>carries, the address and data widths, and the two register maps. |

## Interface requirements

*Requirements that both sides conform to each ICD*

| name | documentation |
| --- | --- |
| tugInspectorConformance | Argent and Wren shall conform to ICD-001 across the umbilical: keep-alive voltage<br>28 V, power 15 W, checkout telemetry at 9 600 bit/s. |
| launchConformance | The stack shall conform to ICD-002: mass, centre of mass, loads, envelope and<br>separation. |
| spaceGroundConformance | Argent and Meridian shall conform to ICD-003: frequencies, modulation, coding,<br>rates and ranging. |
| relayConformance | Wren and Argent shall conform to ICD-004 across the proximity link within the<br>geometry window. |
| captureConformance | The capture system shall meet ICD-005 for every target case. |
| dockingConformance | The docking ring shall meet ICD-006. |
| dispenserConformance | The dispenser and Wren shall meet ICD-007. |
| inspectorThermalConformance | The dispenser shall keep Wren above its survival temperature per ICD-008. |
| propellantFeedConformance | Both fill-and-drain interfaces shall meet ICD-009. |
| packetConformance | Flight software and the operations centre shall exchange only packets the<br>dictionary defines, per TCD-010. |
| internalBusConformance | Every subsystem shall meet ICD-011 to ICD-014 on its power, data and thermal<br>interfaces. |
| busProtocolConformance | The board support package and every remote terminal shall conform to SCD-020:<br>AABP-1 frames of at most 1 024 B with an 8 B header and a 16-bit checksum, 32<br>addresses, 64 schedule slots per 125 ms polling period, two retries before a<br>fault is raised. |
| spaceLinkProfileConformance | The telecom application and the Meridian packet gateway shall conform to<br>SCD-021: CCSDS Space Packets with a 10 B time-code secondary header in 1 115 B<br>transfer frames on eight virtual channels, the rate set of the current tug mode,<br>and the 2 000 bit/s safe rate set in safe and abort-hold modes. |
| relayProfileConformance | The inspector-handling application and Wren shall conform to SCD-022: AABP-1<br>frames tunnelled over the proximity link, identifiers 128–159, acknowledgement<br>within 2 s, three retries, 200 MB store-and-forward on the tug. |
| registerMapConformance | The remote-interface-unit driver and both remote interface units shall conform<br>to SCD-023: 8-bit register addresses, 16-bit data words, the register maps of the<br>thermal and propulsion unit and of the mechanism unit. |

## Interface verification

*Verification case per ICD*

| name | documentation |
| --- | --- |
| umbilicalTest | Mated umbilical test with flight Wren in the dispenser. |
| adapterFitCheck | Adapter fit check and separation shock test with the launcher's flight adapter. |
| rfCompatibilityTest | End-to-end RF compatibility test between the flight transponder and a station. |
| relayRangeTest | Proximity link test over the geometry window on an antenna range. |
| captureLoadsAnalysis | Contact-dynamics analysis for the small, nominal and large target cases. |
| dockingRingTest | Docking ring capture and power-transfer test with the partner's mating ring. |
| dispenserEjectionTest | Ejection test on the dispenser with a Wren mass model. |
| stowedThermalTest | Thermal-vacuum cold case with Wren stowed. |
| fillAndDrainTest | Fill-and-drain flow test with the ground loading cart. |
| packetDictionaryTest | Every dictionary command sent and every telemetry packet decoded on the flatsat. |
| subsystemInterfaceTests | Power, data-bus and thermal interface acceptance tests on each subsystem. |
| busProtocolTest | Bus protocol test on the avionics test bench with the flight bus controller and<br>both remote interface units. |
| spaceLinkProfileTest | End-to-end packet test through a Meridian station to the operations centre,<br>running every rate set and the fallback to the safe rate set. |
| relayProfileTest | Relay profile test with flight Wren on the proximity link in the anechoic<br>chamber, including a store-and-forward backlog. |
| registerMapTest | Register read-back test of every mapped register on both remote interface units. |
