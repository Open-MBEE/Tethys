# Argent flight software tables. Generated; edit the model or the generator, not this file.
# Generator: software/gen/generate.py 1.0.0
# Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
# Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
# Source elements:
#   TethysModes::TugModeTable
#   TethysModes::SubsystemConfiguration
#   TethysFlightSoftware::ArgentFlightSoftware (Application parts)
#   TethysSoftwareIcds::SpaceLinkProfileIcd (LinkRateSet rows)
#   TethysFlightTiming::argentBus

from typing import NamedTuple

class ModeRow(NamedTuple):
    index: int
    mode: str
    flags: dict[str, bool]
    active_applications: tuple[str, ...]
    rate_set: str | None
    bus_slots_used: int

MODE_TABLE: tuple[ModeRow, ...] = (
    ModeRow(0, 'launch', {'captureSystemArmed': False, 'highGainAntennaOn': False, 'highVoltageBusOn': False, 'proximityLinkOn': False, 'sensorsOn': False, 'sepThrusting': False, 'wheelControl': False}, (), 'launchRates', 0),
    ModeRow(1, 'earlyOperations', {'captureSystemArmed': False, 'highGainAntennaOn': False, 'highVoltageBusOn': False, 'proximityLinkOn': False, 'sensorsOn': False, 'sepThrusting': False, 'wheelControl': True}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'earlyOperationsRates', 32),
    ModeRow(2, 'coast', {'captureSystemArmed': False, 'highGainAntennaOn': True, 'highVoltageBusOn': False, 'proximityLinkOn': False, 'sensorsOn': False, 'sepThrusting': False, 'wheelControl': True}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'coastRates', 32),
    ModeRow(3, 'thrust', {'captureSystemArmed': False, 'highGainAntennaOn': False, 'highVoltageBusOn': True, 'proximityLinkOn': False, 'sensorsOn': False, 'sepThrusting': True, 'wheelControl': True}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'thrustRates', 32),
    ModeRow(4, 'approach', {'captureSystemArmed': False, 'highGainAntennaOn': True, 'highVoltageBusOn': True, 'proximityLinkOn': False, 'sensorsOn': True, 'sepThrusting': True, 'wheelControl': True}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'approachRates', 32),
    ModeRow(5, 'proximityOperations', {'captureSystemArmed': False, 'highGainAntennaOn': True, 'highVoltageBusOn': False, 'proximityLinkOn': True, 'sensorsOn': True, 'sepThrusting': False, 'wheelControl': False}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'captureControl', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'proximityOperationsRates', 36),
    ModeRow(6, 'retreat', {'captureSystemArmed': False, 'highGainAntennaOn': True, 'highVoltageBusOn': False, 'proximityLinkOn': True, 'sensorsOn': True, 'sepThrusting': False, 'wheelControl': False}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'retreatRates', 32),
    ModeRow(7, 'capture', {'captureSystemArmed': True, 'highGainAntennaOn': False, 'highVoltageBusOn': False, 'proximityLinkOn': True, 'sensorsOn': True, 'sepThrusting': False, 'wheelControl': False}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'captureControl', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'captureRates', 36),
    ModeRow(8, 'despin', {'captureSystemArmed': False, 'highGainAntennaOn': False, 'highVoltageBusOn': False, 'proximityLinkOn': False, 'sensorsOn': False, 'sepThrusting': False, 'wheelControl': False}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'captureControl', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'despinRates', 36),
    ModeRow(9, 'stackCoast', {'captureSystemArmed': False, 'highGainAntennaOn': True, 'highVoltageBusOn': False, 'proximityLinkOn': False, 'sensorsOn': False, 'sepThrusting': False, 'wheelControl': True}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'stackCoastRates', 32),
    ModeRow(10, 'stackThrust', {'captureSystemArmed': False, 'highGainAntennaOn': False, 'highVoltageBusOn': True, 'proximityLinkOn': False, 'sensorsOn': False, 'sepThrusting': True, 'wheelControl': True}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'stackThrustRates', 32),
    ModeRow(11, 'droHold', {'captureSystemArmed': False, 'highGainAntennaOn': True, 'highVoltageBusOn': False, 'proximityLinkOn': False, 'sensorsOn': False, 'sepThrusting': False, 'wheelControl': True}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'droHoldRates', 32),
    ModeRow(12, 'dockedPassive', {'captureSystemArmed': False, 'highGainAntennaOn': True, 'highVoltageBusOn': False, 'proximityLinkOn': True, 'sensorsOn': False, 'sepThrusting': False, 'wheelControl': False}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'dockedPassiveRates', 32),
    ModeRow(13, 'disposal', {'captureSystemArmed': False, 'highGainAntennaOn': False, 'highVoltageBusOn': True, 'proximityLinkOn': False, 'sensorsOn': False, 'sepThrusting': True, 'wheelControl': True}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'disposalRates', 32),
    ModeRow(14, 'safe', {'captureSystemArmed': False, 'highGainAntennaOn': False, 'highVoltageBusOn': False, 'proximityLinkOn': False, 'sensorsOn': False, 'sepThrusting': False, 'wheelControl': False}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'safeRates', 32),
    ModeRow(15, 'abortHold', {'captureSystemArmed': False, 'highGainAntennaOn': True, 'highVoltageBusOn': False, 'proximityLinkOn': False, 'sensorsOn': False, 'sepThrusting': False, 'wheelControl': True}, ('cdh', 'gnc', 'sepControl', 'powerManagement', 'thermalControl', 'telecom', 'inspectorHandling', 'autonomy', 'fdir', 'modeManagement', 'parameterBootUpdate'), 'abortHoldRates', 32),
)

class Application(NamedTuple):
    name: str
    definition: str
    rate_hz: float | None
    priority: int
    layer: str
    criticality: str
    active_modes: tuple[str, ...]

APPLICATIONS: tuple[Application, ...] = (
    Application('cdh', 'CdhApplication', 1.0, 2, 'application', 'missionCritical', ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    Application('gnc', 'GncApplication', 16.0, 3, 'application', 'safetyCritical', ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    Application('sepControl', 'SepControlApplication', 1.0, 5, 'application', 'missionCritical', ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    Application('powerManagement', 'PowerManagementApplication', 1.0, 4, 'application', 'missionCritical', ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    Application('thermalControl', 'ThermalControlApplication', 1.0, 8, 'application', 'missionCritical', ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    Application('telecom', 'TelecomApplication', 1.0, 6, 'application', 'missionCritical', ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    Application('inspectorHandling', 'InspectorHandlingApplication', 1.0, 9, 'application', 'missionCritical', ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    Application('captureControl', 'CaptureControlApplication', 16.0, 7, 'application', 'safetyCritical', ('proximityOperations', 'capture', 'despin')),
    Application('autonomy', 'AutonomyApplication', 1.0, 11, 'application', 'safetyCritical', ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    Application('fdir', 'FdirApplication', 16.0, 1, 'application', 'safetyCritical', ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    Application('modeManagement', 'ModeManagementApplication', 1.0, 1, 'application', 'safetyCritical', ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
    Application('parameterBootUpdate', 'ParameterBootUpdateApplication', 1.0, 12, 'application', 'missionCritical', ('earlyOperations', 'coast', 'thrust', 'approach', 'proximityOperations', 'retreat', 'capture', 'despin', 'stackCoast', 'stackThrust', 'droHold', 'dockedPassive', 'disposal', 'safe', 'abortHold')),
)

MODE_FLAG_NAMES = ('captureSystemArmed', 'highGainAntennaOn', 'highVoltageBusOn', 'proximityLinkOn', 'sensorsOn', 'sepThrusting', 'wheelControl')
MODE_ROW_COUNT = 16
MODE_ROWS_BY_NAME = {r.mode: r for r in MODE_TABLE}
