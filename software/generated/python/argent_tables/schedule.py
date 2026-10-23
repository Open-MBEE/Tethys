# Argent flight software tables. Generated; edit the model or the generator, not this file.
# Generator: software/gen/generate.py 1.0.0
# Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
# Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
# Source elements:
#   TethysFlightTiming::FlightTiming
#   TethysFlightTiming::argentTiming
#   TethysFlightTiming::ScheduledTask
#   TethysFlightSoftware::ArgentFlightSoftware::executive
#   TethysFlightTiming::argentBus

from typing import NamedTuple

class RateGroup(NamedTuple):
    name: str
    rate_hz: float
    period_s: float
    activations_per_major_frame: int

RATE_GROUPS: tuple[RateGroup, ...] = (
    RateGroup('rg16', 16.0, 0.0625, 16),
    RateGroup('rg8', 8.0, 0.125, 8),
    RateGroup('rg2', 2.0, 0.5, 2),
    RateGroup('rg1', 1.0, 1.0, 1),
)

class Partition(NamedTuple):
    name: str
    window_s: float
    memory_bytes: float
    criticality: str
    restartable: bool

PARTITIONS: tuple[Partition, ...] = (
    Partition('platformPartition', 0.25, 256000000.0, 'safetyCritical', False),
    Partition('gncPartition', 0.25, 256000000.0, 'safetyCritical', True),
    Partition('subsystemPartition', 0.25, 256000000.0, 'missionCritical', True),
    Partition('autonomyPartition', 0.125, 128000000.0, 'safetyCritical', True),
    Partition('payloadPartition', 0.125, 128000000.0, 'nonCritical', True),
)

class ScheduledTask(NamedTuple):
    name: str
    schedule: str
    kind: str
    component: str
    rate_group: str
    wcet_s: float
    period_s: float
    deadline_s: float
    firing_frames: tuple[int, ...]
    active_modes: tuple[str, ...]

SCHEDULED_TASKS: tuple[ScheduledTask, ...] = (
    ScheduledTask('boardSupportTask', 'platformSchedule', 'ScheduledTask', 'software.boardSupport', 'rg16', 0.001, 0.0625, 0.0625, (0, 1, 2, 3, 4, 5, 6, 7), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('schedulerTask', 'platformSchedule', 'ScheduledTask', 'software.scheduler', 'rg16', 0.001, 0.0625, 0.0625, (0, 1, 2, 3, 4, 5, 6, 7), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('fdirTask', 'platformSchedule', 'ApplicationTask', 'software.fdir', 'rg16', 0.003, 0.0625, 0.0625, (0, 1, 2, 3, 4, 5, 6, 7), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('modeManagementTask', 'platformSchedule', 'ApplicationTask', 'software.modeManagement', 'rg8', 0.003, 0.125, 0.125, (0, 1, 2, 3, 4, 5, 6, 7), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('cdhTask', 'platformSchedule', 'ApplicationTask', 'software.cdh', 'rg8', 0.004, 0.125, 0.125, (0, 1, 2, 3, 4, 5, 6, 7), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('commandIngestTask', 'platformSchedule', 'ScheduledTask', 'software.commandIngest', 'rg8', 0.002, 0.125, 0.125, (0, 1, 2, 3, 4, 5, 6, 7), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('telemetryOutputTask', 'platformSchedule', 'ScheduledTask', 'software.telemetryOutput', 'rg8', 0.003, 0.125, 0.125, (0, 1, 2, 3, 4, 5, 6, 7), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('telecomTask', 'platformSchedule', 'ApplicationTask', 'software.telecom', 'rg8', 0.005, 0.125, 0.125, (0, 1, 2, 3, 4, 5, 6, 7), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('housekeepingTask', 'platformSchedule', 'ScheduledTask', 'software.housekeeping', 'rg1', 0.003, 1.0, 1.0, (0,), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('timeTask', 'platformSchedule', 'ScheduledTask', 'software.time', 'rg1', 0.001, 1.0, 1.0, (1,), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('eventTask', 'platformSchedule', 'ScheduledTask', 'software.events', 'rg1', 0.001, 1.0, 1.0, (2,), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('tableTask', 'platformSchedule', 'ScheduledTask', 'software.tables', 'rg1', 0.001, 1.0, 1.0, (3,), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('dataStoreTask', 'platformSchedule', 'ScheduledTask', 'software.dataStore', 'rg1', 0.002, 1.0, 1.0, (4,), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('bootUpdateTask', 'platformSchedule', 'ScheduledTask', 'software.bootUpdate', 'rg1', 0.001, 1.0, 1.0, (5,), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('parameterBootUpdateTask', 'platformSchedule', 'ApplicationTask', 'software.parameterBootUpdate', 'rg1', 0.004, 1.0, 1.0, (6,), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('gncTask', 'gncSchedule', 'ApplicationTask', 'software.gnc', 'rg16', 0.012, 0.0625, 0.0625, (0, 1, 2, 3, 4, 5, 6, 7), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('sepControlTask', 'gncSchedule', 'ApplicationTask', 'software.sepControl', 'rg8', 0.005, 0.125, 0.125, (0, 1, 2, 3, 4, 5, 6, 7), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('powerManagementTask', 'subsystemSchedule', 'ApplicationTask', 'software.powerManagement', 'rg8', 0.005, 0.125, 0.125, (0, 1, 2, 3, 4, 5, 6, 7), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('thermalControlTask', 'subsystemSchedule', 'ApplicationTask', 'software.thermalControl', 'rg2', 0.006, 0.5, 0.5, (1, 5), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('autonomyTask', 'autonomySchedule', 'ApplicationTask', 'software.autonomy', 'rg8', 0.01, 0.125, 0.125, (0, 1, 2, 3, 4, 5, 6, 7), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('captureControlTask', 'payloadSchedule', 'ApplicationTask', 'software.captureControl', 'rg16', 0.006, 0.0625, 0.0625, (0, 1, 2, 3, 4, 5, 6, 7), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    ScheduledTask('inspectorHandlingTask', 'payloadSchedule', 'ApplicationTask', 'software.inspectorHandling', 'rg2', 0.003, 0.5, 0.5, (2, 6), ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
)

class PartitionSchedule(NamedTuple):
    name: str
    partition: str
    slices: tuple[tuple[str, float], ...]
    tasks: tuple[str, ...]

PARTITION_SCHEDULES: tuple[PartitionSchedule, ...] = (
    PartitionSchedule('platformSchedule', 'software.executive.platformPartition', (('sliceA', 0.015625), ('sliceB', 0.015625)), ('boardSupportTask', 'schedulerTask', 'fdirTask', 'modeManagementTask', 'cdhTask', 'commandIngestTask', 'telemetryOutputTask', 'telecomTask', 'housekeepingTask', 'timeTask', 'eventTask', 'tableTask', 'dataStoreTask', 'bootUpdateTask', 'parameterBootUpdateTask')),
    PartitionSchedule('gncSchedule', 'software.executive.gncPartition', (('sliceA', 0.015625), ('sliceB', 0.015625)), ('gncTask', 'sepControlTask')),
    PartitionSchedule('subsystemSchedule', 'software.executive.subsystemPartition', (('slice', 0.03125),), ('powerManagementTask', 'thermalControlTask')),
    PartitionSchedule('autonomySchedule', 'software.executive.autonomyPartition', (('slice', 0.015625),), ('autonomyTask',)),
    PartitionSchedule('payloadSchedule', 'software.executive.payloadPartition', (('slice', 0.015625),), ('captureControlTask', 'inspectorHandlingTask')),
)

class BusStream(NamedTuple):
    name: str
    node: str
    slots_per_frame: int
    message_length_bytes: float
    active_modes: tuple[str, ...]

BUS_STREAMS: tuple[BusStream, ...] = (
    BusStream('timeBroadcast', 'broadcast', 1, 16.0, ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    BusStream('thermalPropulsionPoll', 'thermal and propulsion unit', 2, 256.0, ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    BusStream('thermalPropulsionCommand', 'thermal and propulsion unit', 1, 64.0, ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    BusStream('thermalZoneSweep', 'thermal and propulsion unit', 1, 512.0, ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    BusStream('mechanismStatus', 'mechanism unit', 1, 128.0, ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    BusStream('mechanismPoll', 'mechanism unit', 2, 256.0, ('proximityOperations', 'capture', 'despin')),
    BusStream('mechanismCommand', 'mechanism unit', 2, 64.0, ('proximityOperations', 'capture', 'despin')),
    BusStream('gncSensorPoll', 'star trackers and inertial units', 8, 128.0, ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    BusStream('gncActuatorCommand', 'reaction wheels', 4, 64.0, ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    BusStream('massMemoryWrite', 'mass memories', 8, 1024.0, ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    BusStream('transponderUplink', 'transponders', 1, 1024.0, ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    BusStream('transponderDownlink', 'transponders', 3, 1024.0, ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    BusStream('retryReserve', 'any', 2, 1024.0, ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
)

class BusModeLoad(NamedTuple):
    mode: str
    slots_used: int
    bytes_per_frame: float

BUS_MODE_LOADS: tuple[BusModeLoad, ...] = (
    BusModeLoad('launch', 0, 0.0),
    BusModeLoad('earlyOperations', 32, 16848.0),
    BusModeLoad('coast', 32, 16848.0),
    BusModeLoad('thrust', 32, 16848.0),
    BusModeLoad('approach', 32, 16848.0),
    BusModeLoad('proximityOperations', 36, 17488.0),
    BusModeLoad('retreat', 32, 16848.0),
    BusModeLoad('capture', 36, 17488.0),
    BusModeLoad('despin', 36, 17488.0),
    BusModeLoad('stackCoast', 32, 16848.0),
    BusModeLoad('stackThrust', 32, 16848.0),
    BusModeLoad('droHold', 32, 16848.0),
    BusModeLoad('dockedPassive', 32, 16848.0),
    BusModeLoad('disposal', 32, 16848.0),
    BusModeLoad('safe', 32, 16848.0),
    BusModeLoad('abortHold', 32, 16848.0),
)

MINOR_FRAME_PERIOD_S = 0.125
MAJOR_FRAME_PERIOD_S = 1.0
MINOR_FRAMES_PER_MAJOR_FRAME = 8
BUS_FRAME_SLOTS = 64
BUS_FRAME_PERIOD_S = 0.125
BUS_SLOT_LENGTH_BYTES = 1024.0
