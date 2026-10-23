# Argent flight software tables. Generated; edit the model or the generator, not this file.
# Generator: software/gen/generate.py 1.0.0
# Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
# Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
# Source elements:
#   TethysOperations::noThrustDuringRelay … batteryDepthOfDischarge (FR-001 … FR-004) and their constraint definitions
#   TethysSequence::OnBoardSequence specialisations
#   TethysGroundSoftware::GroundSequenceCheck, FlightRuleChecker, CheckFlightRules
#   TethysTugStructure::allFlightModes, thrustingModes
#   TethysGroundSoftware::MeridianOperationsSuite (components)
#   TethysGroundSoftware::DataArchive, ProximityPlanner, PassPlanner, PlannedDailyPassPlan
#   TethysMeridian::MeridianNetwork
#   TethysOperations::DailyPassPlan
#   TethysGroundSoftware::AlarmLifecycle, AnomalyLifecycle
#   TethysGroundSoftware::CommandVerdict, SequenceVerdict, AlarmSeverity, AnomalyDisposition, DecisionAuthority

from enum import IntEnum
from typing import NamedTuple

from .state_machines import NamedExpression, State, StateMachine, Transition

class Quantity(NamedTuple):
    value: float
    unit: str


class CommandVerdict(IntEnum):
    ACCEPTED = 0
    UNKNOWN_OPCODE = 1
    ARGUMENT_OUT_OF_RANGE = 2
    MODE_NOT_ALLOWED = 3
    AWAITING_SECOND_APPROVAL = 4


class SequenceVerdict(IntEnum):
    PENDING = 0
    CLEARED = 1
    REFUSED = 2


class AlarmSeverity(IntEnum):
    NOMINAL = 0
    WARNING = 1
    VIOLATION = 2


class AnomalyDisposition(IntEnum):
    EXPLAINED = 0
    PROCEDURE_CHANGE = 1
    PARAMETER_CHANGE = 2
    SOFTWARE_FIX = 3


class DecisionAuthority(IntEnum):
    FLIGHT_DIRECTOR = 0
    ANOMALY_BOARD = 1
    MISSION_MANAGER = 2


class RuleParameter(NamedTuple):
    name: str
    value: float
    unit: str


class FlightRule(NamedTuple):
    id: str
    name: str
    item: str
    text: str
    constraint: str
    expression: str
    inputs: tuple[str, ...]
    parameters: tuple[RuleParameter, ...]

FLIGHT_RULES: tuple[FlightRule, ...] = (
    FlightRule('FR-001', 'noThrustDuringRelay', 'TethysOperations::noThrustDuringRelay', 'The flight system shall not thrust while the proximity link is active.', 'TethysOperations::NoThrustDuringRelay', 'not (thrusting and relayActive)', ('thrusting', 'relayActive'), ()),
    FlightRule('FR-002', 'approachKeepOut', 'TethysOperations::approachKeepOut', 'The tug shall remain outside the 500 m keep-out sphere until a capture sequence is loaded and authorised.', 'TethysOperations::ApproachKeepOut', 'rangeToTarget >= keepOutRadius or approachAuthorised', ('rangeToTarget', 'keepOutRadius', 'approachAuthorised'), (RuleParameter('keepOutRadius', 500.0, 'm'), )),
    FlightRule('FR-003', 'sunExclusion', 'TethysOperations::sunExclusion', 'The imager boresight shall stay more than 25° from the Sun while its cover is open.', 'TethysOperations::SunExclusion', 'sunAngle >= exclusionHalfAngle or not coverOpen', ('sunAngle', 'exclusionHalfAngle', 'coverOpen'), (RuleParameter('exclusionHalfAngle', 25.0, "'°'"), )),
    FlightRule('FR-004', 'batteryDepthOfDischarge', 'TethysOperations::batteryDepthOfDischarge', 'Battery state of charge shall not fall below 40 % in any planned activity.', 'TethysOperations::BatteryDepthOfDischarge', 'stateOfCharge >= 0.4', ('stateOfCharge',), (RuleParameter('stateOfChargeFloor', 0.4, ''), )),
)

class OnBoardSequence(NamedTuple):
    sequence_id: int
    name: str
    item: str
    time_tagged: bool
    text: str

ON_BOARD_SEQUENCES: tuple[OnBoardSequence, ...] = (
    OnBoardSequence(1, 'ThrustArc', 'TethysSequence::ThrustArc', True, "One thrust arc: the SEP string thrusts for the arc's duration at the given thrust and burns the xenon that duration implies; the result is the xenon left."),
    OnBoardSequence(2, 'DespinSequence', 'TethysSequence::DespinSequence', True, 'Despin the captured stack with the hydrazine thrusters: each pulse train lengthens the spin period by a fixed factor until the period is above the threshold at which the wheels take over.'),
    OnBoardSequence(3, 'InspectorReleaseSequence', 'TethysSequence::InspectorReleaseSequence', True, 'The inspector release as a timed go/no-go sequence: checkout, umbilical disconnect, a hold for the ground go, then release — each step gated by the state the previous one must have reached.'),
    OnBoardSequence(4, 'DroInsertionSequence', 'TethysSequence::DroInsertionSequence', True, 'The insertion into the distant retrograde orbit after the lunar assist: the post-assist trajectory is checked against the insertion corridor, the insertion arc is executed, and a miss leaves the stack in the backup heliocentric loiter orbit rather than in cislunar space. The arc length is an owned attribute, not a parameter: see docs/findings/WP-E.md F-E02.'),
    OnBoardSequence(5, 'DroStationKeeping', 'TethysSequence::DroStationKeeping', True, "The DRO checkout's station-keeping demonstration: hydrazine trims are repeated until the along-track drift is inside the control box, then the three demonstration cycles of the checkout plan are costed."),
    OnBoardSequence(6, 'MissionSequence', 'TethysSequence::MissionSequence', True, 'The flight from lift-off to disposal as an executable action over the phases of TethysMission::flightTimeline. The clock runs in days; the thrust arcs are loops counted against the arc plan; the capture commit is a decision over the delivered target estimate and the capture envelope, and a refused commit ends the mission in a retreat hold (`terminate`). The lunar assist is waited for as a timed event (`accept at` a clock instant scheduled after the return arcs).'),
)

SEQUENCE_CHECK_SOURCE = 'TethysGroundSoftware::GroundSequenceCheck'
STORED_SEQUENCES = (1, 2, 3, 4, 5, 6)
CHECK_LIMITS = {
    'keepOutRadius': Quantity(500.0, 'm'),
    'exclusionHalfAngle': Quantity(30.0, "'°'"),
    'stateOfChargeFloor': Quantity(0.4, ''),
}
FLIGHT_MODES = ('earlyOperations', 'thrust', 'approach', 'stackThrust', 'disposal', 'coast', 'stackCoast', 'dockedPassive', 'proximityOperations', 'retreat', 'capture', 'despin', 'droHold', 'safe', 'abortHold')
THRUSTING_MODES = ('thrust', 'approach', 'stackThrust', 'disposal')
CHECK_REASONS = ('FR-001 thrust during a relay pass', 'FR-002 inside the keep-out sphere without authorisation', 'FR-003 sun inside the exclusion cone with the cover open', 'FR-004 battery below the depth-of-discharge floor', 'planned mode is not a flight mode', 'none')

class GroundComponent(NamedTuple):
    suite_part: str
    part: str
    path: str
    definition: str
    product_name: str
    version: str
    simulator: bool
    flight_software_in_the_loop: bool
    hardware_in_the_loop: bool
    text: str

GROUND_COMPONENTS: tuple[GroundComponent, ...] = (
    GroundComponent('moc', 'commandBuilder', 'moc.commandBuilder', 'TethysGroundSoftware::CommandBuilder', 'Meridian Forge', '3.2', False, False, False, 'Meridian Forge, the command builder: every command is built from the flight dictionary and validated by ValidateCommand before it is packed as a CommandPacket for the uplink queue; hazardous commands wait for a second signature.'),
    GroundComponent('moc', 'sequencer', 'moc.sequencer', 'TethysGroundSoftware::FlightRuleChecker', 'Meridian Warden', '2.5', False, False, False, "Meridian Warden, the sequencer and flight-rule checker: every planned sequence is loaded, checked against FR-001 to FR-004 and either released to the uplink queue as a LoadSequence command or refused. The release is a send from this part's own port inside its performed action, the form the pinned runtime routes."),
    GroundComponent('moc', 'telemetryServer', 'moc.telemetryServer', 'TethysGroundSoftware::TelemetryServer', 'Meridian Lantern', '5.0', False, False, False, 'Meridian Lantern, the telemetry server: synchronises the transfer frames the gateway forwards, decommutates every dictionary packet by its PacketDefinition layout, converts to engineering units, checks the dictionary limits and the FDIR limit table, raises alarms and trends the resource points.'),
    GroundComponent('moc', 'passPlanner', 'moc.passPlanner', 'TethysGroundSoftware::PassPlanner', 'Meridian Almanac', '1.9', False, False, False, "Meridian Almanac, the pass planner: from the stations' visibility of the tug and the MLS-2 rate set of the planned mode it allocates the day's passes, resolves the conflicts between the three stations and the relay windows, and writes the DailyPassPlan the operations model flies."),
    GroundComponent('moc', 'anomalyTracker', 'moc.anomalyTracker', 'TethysGroundSoftware::AnomalyTracker', 'Meridian Ledger', '2.3', False, False, False, 'Meridian Ledger, the anomaly tracker: every alarm or fault event the telemetry server raises opens an anomaly, the console answers it with the contingency procedures of the operations model, and the anomaly board dispositions it.'),
    GroundComponent('moc', 'proximityPlanner', 'moc.proximityPlanner', 'TethysGroundSoftware::ProximityPlanner', 'Meridian Compass', '1.4', False, False, False, 'Meridian Compass, the proximity-operations planner: relative navigation products, the keep-out check of FR-002 on every planned approach, the go/no-go checklist and the abort criteria the capture sequence is uplinked with.'),
    GroundComponent('fdf', 'flightDynamicsTool', 'fdf.flightDynamicsTool', 'TethysGroundSoftware::FlightDynamicsTool', 'Meridian Sextant', '2.7', False, False, False, "Meridian Sextant, the flight dynamics tool: orbit determination of Argent and of Amaranth from the stations' tracking data, low-thrust arc and DRO insertion design, ephemeris products for the stations and the pass planner, and the delta-v ledger."),
    GroundComponent('sds', 'dataArchive', 'sds.dataArchive', 'TethysGroundSoftware::DataArchive', 'Meridian Vault', '4.1', False, False, False, 'Meridian Vault, the archive: catalogues every product level with a checksum, keeps each by its retention rule and distributes the released levels.'),
    GroundComponent('testBeds', 'flatsat', 'testBeds.flatsat', 'TethysGroundSoftware::HardwareInTheLoopTestBed', 'Meridian Anvil', '2.0', True, True, True, "Meridian Anvil: the flatsat's engineering-model avionics with the flight software, driven by the suite."),
    GroundComponent('testBeds', 'captureRig', 'testBeds.captureRig', 'TethysGroundSoftware::CaptureRigController', 'Meridian Capstan', '1.2', True, False, True, "Meridian Capstan: the capture rig's control and data software."),
    GroundComponent('testBeds', 'dynamicsSimulator', 'testBeds.dynamicsSimulator', 'TethysGroundSoftware::DynamicsSimulator', 'Meridian Orrery', '3.3', True, True, False, 'Meridian Orrery: the six-degree-of-freedom proximity-operations simulator with the GNC flight code in the loop.'),
    GroundComponent('testBeds', 'trajectoryTool', 'testBeds.trajectoryTool', 'TethysGroundSoftware::FlightSoftwareInTheLoopSimulator', 'Meridian Mirror', '6.1', True, True, False, 'Meridian Mirror: the flight software image running on an emulated flight computer with simulated dynamics, used for sequence and procedure validation.'),
)

class RetentionRule(NamedTuple):
    rule: str
    level: str
    retention: float
    unit: str
    distributed: bool

RETENTION_RULES: tuple[RetentionRule, ...] = (
    RetentionRule('l0Rule', 'l0', 3650.0, 'd', False),
    RetentionRule('l1Rule', 'l1', 3650.0, 'd', True),
    RetentionRule('l2Rule', 'l2', 3650.0, 'd', True),
    RetentionRule('l3Rule', 'l3', 3650.0, 'd', True),
)
CHECKSUM_WIDTH = 32

class RelativeNavigationProduct(NamedTuple):
    name: str
    range: Quantity
    range_rate: Quantity
    range_uncertainty: Quantity

PROXIMITY_PRODUCTS: tuple[RelativeNavigationProduct, ...] = (
    RelativeNavigationProduct('standoff', Quantity(2000.0, 'm'), Quantity(0.0, "'m/s'"), Quantity(5.0, 'm')),
    RelativeNavigationProduct('finalApproach', Quantity(50.0, 'm'), Quantity(-0.05, "'m/s'"), Quantity(0.5, 'm')),
)
PROXIMITY_LIMITS = {
    'keep_out_radius': Quantity(500.0, 'm'),
    'abort_range_rate': Quantity(-0.2, "'m/s'"),
    'abort_range_uncertainty': Quantity(2.0, 'm'),
}
CHECKLIST_ITEMS_TOTAL = 12
CHECKLIST_ITEMS_GO = 12

class Station(NamedTuple):
    name: str
    longitude: float
    unit: str

STATIONS: tuple[Station, ...] = (
    Station('caldera', -68.0, "'°'"),
    Station('tableland', 52.0, "'°'"),
    Station('saltmarsh', 172.0, "'°'"),
)

class StationPass(NamedTuple):
    name: str
    station: str
    duration: float
    unit: str

STATION_PASSES: tuple[StationPass, ...] = (
    StationPass('calderaPass', 'caldera', 8.0, 'h'),
    StationPass('tablelandPass', 'tableland', 8.0, 'h'),
    StationPass('saltmarshPass', 'saltmarsh', 8.0, 'h'),
)

class DownlinkActivity(NamedTuple):
    name: str
    volume: float
    unit: str

DOWNLINK_ACTIVITIES: tuple[DownlinkActivity, ...] = (
    DownlinkActivity('imageryDownlink', 11500000000.0, 'bit'),
    DownlinkActivity('housekeepingDownlink', 580000000.0, 'bit'),
    DownlinkActivity('radarDownlink', 11500000000.0, 'bit'),
)

class PassAllocation(NamedTuple):
    name: str
    activity: str
    station_pass: str

PASS_ALLOCATIONS: tuple[PassAllocation, ...] = (
    PassAllocation('imageryToCaldera', 'imageryDownlink', 'calderaPass'),
    PassAllocation('housekeepingToTableland', 'housekeepingDownlink', 'tablelandPass'),
    PassAllocation('radarToSaltmarsh', 'radarDownlink', 'saltmarshPass'),
)

VISIBILITY_HALF_WIDTH = Quantity(65.0, "'°'")
LOCK_UP = Quantity(300.0, 's')
PLANNED_RATE_SET = 'proximityOperationsRates'
PLANNED_MODE = 'proximityOperations'

ALARM_LIFECYCLE = StateMachine(
    'AlarmLifecycle', 'TethysGroundSoftware::AlarmLifecycle', 'TethysGroundSoftware::AlarmLifecycle::quiet',
    (
        State('quiet', 'TethysGroundSoftware::AlarmLifecycle::quiet', None, None, True, '', ''),
        State('raised', 'TethysGroundSoftware::AlarmLifecycle::raised', None, None, True, '', ''),
        State('acknowledged', 'TethysGroundSoftware::AlarmLifecycle::acknowledged', None, None, True, '', ''),
    ),
    (
        Transition('TethysGroundSoftware::AlarmLifecycle::quiet', 'TethysGroundSoftware::AlarmLifecycle::raised', 'AlarmRaised', None, None, None, None, None),
        Transition('TethysGroundSoftware::AlarmLifecycle::raised', 'TethysGroundSoftware::AlarmLifecycle::acknowledged', 'AlarmAcknowledge', None, None, None, None, None),
        Transition('TethysGroundSoftware::AlarmLifecycle::acknowledged', 'TethysGroundSoftware::AlarmLifecycle::quiet', 'AlarmCleared', None, None, None, None, None),
        Transition('TethysGroundSoftware::AlarmLifecycle::raised', 'TethysGroundSoftware::AlarmLifecycle::quiet', 'AlarmCleared', None, None, None, None, None),
    ),
    (),
    (),
)

ANOMALY_LIFECYCLE = StateMachine(
    'AnomalyLifecycle', 'TethysGroundSoftware::AnomalyLifecycle', 'TethysGroundSoftware::AnomalyLifecycle::opened',
    (
        State('opened', 'TethysGroundSoftware::AnomalyLifecycle::opened', None, None, True, '', ''),
        State('triaged', 'TethysGroundSoftware::AnomalyLifecycle::triaged', None, None, True, '', ''),
        State('investigating', 'TethysGroundSoftware::AnomalyLifecycle::investigating', None, None, True, '', ''),
        State('closed', 'TethysGroundSoftware::AnomalyLifecycle::closed', None, None, True, '', ''),
    ),
    (
        Transition('TethysGroundSoftware::AnomalyLifecycle::opened', 'TethysGroundSoftware::AnomalyLifecycle::triaged', 'AnomalyTriaged', None, None, None, None, None),
        Transition('TethysGroundSoftware::AnomalyLifecycle::triaged', 'TethysGroundSoftware::AnomalyLifecycle::investigating', 'AnomalyAssigned', None, None, None, None, None),
        Transition('TethysGroundSoftware::AnomalyLifecycle::investigating', 'TethysGroundSoftware::AnomalyLifecycle::closed', 'AnomalyDispositioned', None, None, None, None, None),
    ),
    (),
    (),
)

FLIGHT_RULES_BY_ID = {r.id: r for r in FLIGHT_RULES}
SEQUENCES_BY_ID = {s.sequence_id: s for s in ON_BOARD_SEQUENCES}
COMPONENTS_BY_PRODUCT = {c.product_name: c for c in GROUND_COMPONENTS}
COMPONENTS_BY_PATH = {c.path: c for c in GROUND_COMPONENTS}
STATIONS_BY_NAME = {s.name: s for s in STATIONS}
PROXIMITY_PRODUCTS_BY_NAME = {p.name: p for p in PROXIMITY_PRODUCTS}
