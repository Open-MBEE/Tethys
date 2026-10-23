# Argent flight software tables. Generated; edit the model or the generator, not this file.
# Generator: software/gen/generate.py 1.0.0
# Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
# Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
# Source elements:
#   TethysFlightDictionary::flightDictionary::parameterTables
#   TethysFlightDictionary::ParameterRow
#   TethysFlightDictionary::flightLimitTable
#   TethysFlightDictionary::tableLimits
#   TethysFdir::cruiseLimits
#   TethysFdir::FaultEvent

from typing import NamedTuple

class Parameter(NamedTuple):
    id: int
    name: str
    owner: str
    table_id: int
    value: float
    minimum: float
    maximum: float
    unit: str

PARAMETERS: tuple[Parameter, ...] = (
    Parameter(1, 'watchdogPeriod', 'cdh', 1, 5.0, 0.1, 30.0, 's'),
    Parameter(2, 'recorderHighWater', 'cdh', 1, 0.9, 0.5, 0.99, '1'),
    Parameter(3, 'clockSlewLimit', 'cdh', 1, 1.0, 0.01, 10.0, 's'),
    Parameter(4, 'downlinkQueueDepth', 'cdh', 1, 64.0, 8.0, 512.0, '1'),
    Parameter(5, 'slewRateLimit', 'gnc', 2, 0.01, 0.0001, 0.02, 'rad/s'),
    Parameter(6, 'pointingTolerance', 'gnc', 2, 0.001, 0.0001, 0.1, 'rad'),
    Parameter(7, 'wheelSpeedLimit', 'gnc', 2, 600.0, 100.0, 650.0, 'rad/s'),
    Parameter(8, 'desatThreshold', 'gnc', 2, 0.8, 0.5, 0.95, '1'),
    Parameter(9, 'throttleMinimum', 'sepControl', 3, 0.2, 0.1, 0.5, '1'),
    Parameter(10, 'restartDelay', 'sepControl', 3, 7200.0, 60.0, 86400.0, 's'),
    Parameter(11, 'dischargeTrip', 'sepControl', 3, 32.0, 5.0, 40.0, 'A'),
    Parameter(12, 'tankHeaterSetpoint', 'sepControl', 3, 293.0, 273.0, 323.0, 'K'),
    Parameter(13, 'endOfChargeVoltage', 'powerManagement', 4, 33.0, 28.0, 33.6, 'V'),
    Parameter(14, 'busLowTrip', 'powerManagement', 4, 26.0, 24.0, 28.0, 'V'),
    Parameter(15, 'busHighTrip', 'powerManagement', 4, 30.0, 28.0, 32.0, 'V'),
    Parameter(16, 'loadShedSoc', 'powerManagement', 4, 0.3, 0.1, 0.6, '1'),
    Parameter(17, 'deadband', 'thermalControl', 5, 2.0, 0.5, 10.0, 'K'),
    Parameter(18, 'survivalLow', 'thermalControl', 5, 243.0, 233.0, 283.0, 'K'),
    Parameter(19, 'survivalHigh', 'thermalControl', 5, 253.0, 243.0, 293.0, 'K'),
    Parameter(20, 'heaterPowerCap', 'thermalControl', 5, 800.0, 50.0, 900.0, 'W'),
    Parameter(21, 'defaultDownlinkRate', 'telecom', 6, 2000000.0, 10.0, 4000000.0, 'Hz'),
    Parameter(22, 'defaultUplinkRate', 'telecom', 6, 2000.0, 7.8125, 4000.0, 'Hz'),
    Parameter(23, 'hgaSlewLimit', 'telecom', 6, 0.005, 0.0001, 0.02, 'rad/s'),
    Parameter(24, 'transmitPower', 'telecom', 6, 60.0, 5.0, 100.0, 'W'),
    Parameter(25, 'releaseSpeed', 'inspectorHandling', 7, 0.05, 0.02, 0.2, 'm/s'),
    Parameter(26, 'imagingCadence', 'inspectorHandling', 7, 10.0, 1.0, 600.0, 's'),
    Parameter(27, 'relayRate', 'inspectorHandling', 7, 1000000.0, 1000.0, 2000000.0, 'Hz'),
    Parameter(28, 'contactTimeout', 'inspectorHandling', 7, 7200.0, 600.0, 86400.0, 's'),
    Parameter(29, 'approachRateLimit', 'captureControl', 8, 0.1, 0.01, 0.5, 'm/s'),
    Parameter(30, 'contactForceLimit', 'captureControl', 8, 200.0, 1.0, 500.0, 'N'),
    Parameter(31, 'cinchTension', 'captureControl', 8, 1000.0, 10.0, 2000.0, 'N'),
    Parameter(32, 'despinTorqueLimit', 'captureControl', 8, 0.5, 0.0, 1.0, '1'),
    Parameter(33, 'planHorizon', 'autonomy', 9, 86400.0, 3600.0, 604800.0, 's'),
    Parameter(34, 'autonomyLevel', 'autonomy', 9, 1.0, 0.0, 3.0, '1'),
    Parameter(35, 'waypointHoldDefault', 'autonomy', 9, 600.0, 0.0, 86400.0, 's'),
    Parameter(36, 'ruleCooldown', 'autonomy', 9, 60.0, 1.0, 3600.0, 's'),
    Parameter(37, 'commandLossTimeout', 'fdir', 10, 604800.0, 3600.0, 2592000.0, 's'),
    Parameter(38, 'flameoutRetries', 'fdir', 10, 2.0, 0.0, 5.0, '1'),
    Parameter(39, 'batteryLowFraction', 'fdir', 10, 0.3, 0.1, 0.6, '1'),
    Parameter(40, 'impactProbabilityLimit', 'fdir', 10, 0.0001, 1e-07, 0.001, '1'),
    Parameter(41, 'transitionTimeout', 'modeManagement', 11, 300.0, 1.0, 3600.0, 's'),
    Parameter(42, 'twoStepWindow', 'modeManagement', 11, 600.0, 10.0, 3600.0, 's'),
    Parameter(43, 'modeTableId', 'modeManagement', 11, 11.0, 0.0, 11.0, '1'),
    Parameter(44, 'autoTransitionDefault', 'modeManagement', 11, 1.0, 0.0, 1.0, '1'),
    Parameter(45, 'stagingBufferSize', 'parameterBootUpdate', 12, 65536.0, 4096.0, 65536.0, '1'),
    Parameter(46, 'bootRetryLimit', 'parameterBootUpdate', 12, 3.0, 1.0, 5.0, '1'),
    Parameter(47, 'eepromCycleLimit', 'parameterBootUpdate', 12, 100000.0, 1000.0, 100000.0, '1'),
    Parameter(48, 'tableCount', 'parameterBootUpdate', 12, 12.0, 1.0, 12.0, '1'),
)

class ParameterTable(NamedTuple):
    table_id: int
    owner: str
    item: str
    row_ids: tuple[int, ...]

PARAMETER_TABLES: tuple[ParameterTable, ...] = (
    ParameterTable(1, 'cdh', 'TethysFlightDictionary::cdhParameterTable', (1, 2, 3, 4)),
    ParameterTable(2, 'gnc', 'TethysFlightDictionary::gncParameterTable', (5, 6, 7, 8)),
    ParameterTable(3, 'sepControl', 'TethysFlightDictionary::sepParameterTable', (9, 10, 11, 12)),
    ParameterTable(4, 'powerManagement', 'TethysFlightDictionary::epsParameterTable', (13, 14, 15, 16)),
    ParameterTable(5, 'thermalControl', 'TethysFlightDictionary::thmParameterTable', (17, 18, 19, 20)),
    ParameterTable(6, 'telecom', 'TethysFlightDictionary::comParameterTable', (21, 22, 23, 24)),
    ParameterTable(7, 'inspectorHandling', 'TethysFlightDictionary::insParameterTable', (25, 26, 27, 28)),
    ParameterTable(8, 'captureControl', 'TethysFlightDictionary::capParameterTable', (29, 30, 31, 32)),
    ParameterTable(9, 'autonomy', 'TethysFlightDictionary::autParameterTable', (33, 34, 35, 36)),
    ParameterTable(10, 'fdir', 'TethysFlightDictionary::fdrParameterTable', (37, 38, 39, 40)),
    ParameterTable(11, 'modeManagement', 'TethysFlightDictionary::modParameterTable', (41, 42, 43, 44)),
    ParameterTable(12, 'parameterBootUpdate', 'TethysFlightDictionary::pbuParameterTable', (45, 46, 47, 48)),
)

class Limit(NamedTuple):
    name: str
    value: float
    unit: str

LIMIT_TABLE: tuple[Limit, ...] = (
    Limit('commandLossTimeout', 7.0, 'd'),
    Limit('thrusterRestartDelay', 2.0, 'h'),
    Limit('maximumFlameoutRetries', 2.0, ''),
    Limit('batteryLowFraction', 0.3, ''),
    Limit('earthExclusionRadius', 63781.37, 'km'),
    Limit('maximumImpactProbability', 0.0001, ''),
)

class MonitorLimit(NamedTuple):
    limit_set: str
    name: str
    value: float
    unit: str

MONITOR_LIMITS: tuple[MonitorLimit, ...] = (
    MonitorLimit('TethysFdir::cruiseLimits', 'commandLossTimeout', 7.0, 'd'),
    MonitorLimit('TethysFdir::cruiseLimits', 'thrusterRestartDelay', 2.0, 'h'),
    MonitorLimit('TethysFdir::cruiseLimits', 'maximumFlameoutRetries', 2.0, ''),
    MonitorLimit('TethysFdir::cruiseLimits', 'batteryLowFraction', 0.3, ''),
    MonitorLimit('TethysFdir::cruiseLimits', 'earthExclusionRadius', 63781.37, 'km'),
    MonitorLimit('TethysFdir::cruiseLimits', 'maximumImpactProbability', 0.0001, ''),
    MonitorLimit('TethysFlightDictionary::tableLimits', 'commandLossTimeout', 7.0, 'd'),
    MonitorLimit('TethysFlightDictionary::tableLimits', 'thrusterRestartDelay', 2.0, 'h'),
    MonitorLimit('TethysFlightDictionary::tableLimits', 'maximumFlameoutRetries', 2.0, ''),
    MonitorLimit('TethysFlightDictionary::tableLimits', 'batteryLowFraction', 0.3, ''),
    MonitorLimit('TethysFlightDictionary::tableLimits', 'earthExclusionRadius', 63781.37, 'km'),
    MonitorLimit('TethysFlightDictionary::tableLimits', 'maximumImpactProbability', 0.0001, ''),
)

class FaultEventType(NamedTuple):
    name: str
    fields: tuple[tuple[str, str], ...]

FAULT_EVENT_TYPES: tuple[FaultEventType, ...] = (
    FaultEventType('ThrusterFlameout', (('thrusterId', 'ScalarValues::Natural'),)),
    FaultEventType('PpuTrip', (('ppuId', 'ScalarValues::Natural'),)),
    FaultEventType('AttitudeLoss', ()),
    FaultEventType('BatteryLow', (('stateOfCharge', 'ScalarValues::Real'),)),
    FaultEventType('ProcessorReset', ()),
)

LIMIT_TABLE_ID = 13
PARAMETER_COUNT = 48
PARAMETERS_BY_ID = {p.id: p for p in PARAMETERS}
