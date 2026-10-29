# Argent flight software tables. Generated; edit the model or the generator, not this file.
# Generator: software/gen/generate.py 1.0.0
# Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
# Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
# Source elements:
#   TethysFlightBehaviour::SepStringController
#   TethysFlightBehaviour::PowerManager
#   TethysFlightBehaviour::ThermalController
#   TethysFlightBehaviour::TelecomManager
#   TethysFlightBehaviour::InspectorHandler
#   TethysFlightBehaviour::CaptureController
#   TethysFlightBehaviour::RedundancyManager
#   TethysFlightBehaviour::BootUpdateManager
#   TethysModes::TugModes
#   TethysFlightBehaviour::ModeManagementSoftware::dispatcher
#   TethysFdir::FdirSupervisor
#   TethysFlightBehaviour::FdirSoftware::responseRelay

from typing import NamedTuple

class State(NamedTuple):
    name: str
    qualified_name: str
    parent: str | None
    initial_substate: str | None
    leaf: bool
    entry_action: str
    exit_action: str


class Transition(NamedTuple):
    source: str | None
    target: str
    event: str | None
    parameter: str | None
    port: str | None
    timed: str | None
    guard: str | None
    effect: str | None


class NamedExpression(NamedTuple):
    id: str
    text: str


class StateMachine(NamedTuple):
    name: str
    source: str
    initial: str | None
    states: tuple[State, ...]
    transitions: tuple[Transition, ...]
    guards: tuple[NamedExpression, ...]
    effects: tuple[NamedExpression, ...]


SEP_STRING_CONTROLLER = StateMachine(
    'SepStringController', 'TethysFlightBehaviour::SepStringController', 'TethysFlightBehaviour::SepStringController::off',
    (
        State('off', 'TethysFlightBehaviour::SepStringController::off', None, None, True, '', ''),
        State('standby', 'TethysFlightBehaviour::SepStringController::standby', None, None, True, '', ''),
        State('thrusting', 'TethysFlightBehaviour::SepStringController::thrusting', None, None, True, 'arcsStarted := arcsStarted + 1', ''),
        State('disposalBurn', 'TethysFlightBehaviour::SepStringController::disposalBurn', None, None, True, '', ''),
        State('restarting', 'TethysFlightBehaviour::SepStringController::restarting', None, None, True, 'restarts := restarts + 1', ''),
    ),
    (
        Transition('TethysFlightBehaviour::SepStringController::off', 'TethysFlightBehaviour::SepStringController::standby', 'SepStandby', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::SepStringController::standby', 'TethysFlightBehaviour::SepStringController::thrusting', 'SepThrust', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::SepStringController::thrusting', 'TethysFlightBehaviour::SepStringController::standby', 'SepStandby', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::SepStringController::thrusting', 'TethysFlightBehaviour::SepStringController::restarting', 'ThrusterFlameout', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::SepStringController::restarting', 'TethysFlightBehaviour::SepStringController::thrusting', None, None, None, 'after restartDelay', None, None),
        Transition('TethysFlightBehaviour::SepStringController::standby', 'TethysFlightBehaviour::SepStringController::disposalBurn', 'SepDisposalBurn', 'b', 'command', None, None, 'SEP_STRING_CONTROLLER_E1'),
        Transition('TethysFlightBehaviour::SepStringController::disposalBurn', 'TethysFlightBehaviour::SepStringController::off', None, None, None, 'after burnDuration', None, None),
        Transition('TethysFlightBehaviour::SepStringController::disposalBurn', 'TethysFlightBehaviour::SepStringController::restarting', 'ThrusterFlameout', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::SepStringController::standby', 'TethysFlightBehaviour::SepStringController::off', 'SepOff', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::SepStringController::thrusting', 'TethysFlightBehaviour::SepStringController::off', 'SepOff', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::SepStringController::disposalBurn', 'TethysFlightBehaviour::SepStringController::off', 'SepOff', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::SepStringController::restarting', 'TethysFlightBehaviour::SepStringController::off', 'SepOff', None, 'command', None, None, None),
    ),
    (
    ),
    (
        NamedExpression('SEP_STRING_CONTROLLER_E1', 'burnDuration := b.duration'),
    ),
)

POWER_MANAGER = StateMachine(
    'PowerManager', 'TethysFlightBehaviour::PowerManager', 'TethysFlightBehaviour::PowerManager::nominal',
    (
        State('nominal', 'TethysFlightBehaviour::PowerManager::nominal', None, None, True, 'tier := LoadShedTier::none', ''),
        State('tierOne', 'TethysFlightBehaviour::PowerManager::tierOne', None, None, True, 'shedOne: tier := LoadShedTier::tierOne; shedEvents := shedEvents + 1', ''),
        State('tierTwo', 'TethysFlightBehaviour::PowerManager::tierTwo', None, None, True, 'shedTwo: tier := LoadShedTier::tierTwo; shedEvents := shedEvents + 1', ''),
        State('survival', 'TethysFlightBehaviour::PowerManager::survival', None, None, True, 'shedAll: tier := LoadShedTier::survival; shedEvents := shedEvents + 1', ''),
    ),
    (
        Transition('TethysFlightBehaviour::PowerManager::nominal', 'TethysFlightBehaviour::PowerManager::tierOne', 'BatteryStateOfCharge', 'b', 'command', None, 'POWER_MANAGER_G1', None),
        Transition('TethysFlightBehaviour::PowerManager::nominal', 'TethysFlightBehaviour::PowerManager::tierTwo', 'BatteryStateOfCharge', 'b', 'command', None, 'POWER_MANAGER_G2', None),
        Transition('TethysFlightBehaviour::PowerManager::tierOne', 'TethysFlightBehaviour::PowerManager::tierTwo', 'BatteryStateOfCharge', 'b', 'command', None, 'POWER_MANAGER_G2', None),
        Transition('TethysFlightBehaviour::PowerManager::tierOne', 'TethysFlightBehaviour::PowerManager::nominal', 'BatteryStateOfCharge', 'b', 'command', None, 'POWER_MANAGER_G3', None),
        Transition('TethysFlightBehaviour::PowerManager::tierTwo', 'TethysFlightBehaviour::PowerManager::nominal', 'BatteryStateOfCharge', 'b', 'command', None, 'POWER_MANAGER_G3', None),
        Transition('TethysFlightBehaviour::PowerManager::nominal', 'TethysFlightBehaviour::PowerManager::survival', 'LoadShed', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::PowerManager::tierOne', 'TethysFlightBehaviour::PowerManager::survival', 'LoadShed', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::PowerManager::tierTwo', 'TethysFlightBehaviour::PowerManager::survival', 'LoadShed', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::PowerManager::survival', 'TethysFlightBehaviour::PowerManager::nominal', 'LoadRestore', None, 'command', None, None, None),
    ),
    (
        NamedExpression('POWER_MANAGER_G1', 'b.fraction < tierOneFraction and b.fraction >= limits.batteryLowFraction'),
        NamedExpression('POWER_MANAGER_G2', 'b.fraction < limits.batteryLowFraction'),
        NamedExpression('POWER_MANAGER_G3', 'b.fraction >= restoreFraction'),
    ),
    (
    ),
)

THERMAL_CONTROLLER = StateMachine(
    'ThermalController', 'TethysFlightBehaviour::ThermalController', None,
    (
        State('setpointSelection', 'TethysFlightBehaviour::ThermalController::setpointSelection', None, 'TethysFlightBehaviour::ThermalController::setpointSelection::operational', False, '', ''),
        State('operational', 'TethysFlightBehaviour::ThermalController::setpointSelection::operational', 'TethysFlightBehaviour::ThermalController::setpointSelection', None, True, 'setpoint := operationalSetpoint', ''),
        State('survival', 'TethysFlightBehaviour::ThermalController::setpointSelection::survival', 'TethysFlightBehaviour::ThermalController::setpointSelection', None, True, 'setpoint := survivalSetpoint', ''),
        State('heaterLoop', 'TethysFlightBehaviour::ThermalController::heaterLoop', None, 'TethysFlightBehaviour::ThermalController::heaterLoop::heaterOff', False, '', ''),
        State('heaterOff', 'TethysFlightBehaviour::ThermalController::heaterLoop::heaterOff', 'TethysFlightBehaviour::ThermalController::heaterLoop', None, True, '', ''),
        State('heaterOn', 'TethysFlightBehaviour::ThermalController::heaterLoop::heaterOn', 'TethysFlightBehaviour::ThermalController::heaterLoop', None, True, 'heaterCycles := heaterCycles + 1', ''),
    ),
    (
        Transition('TethysFlightBehaviour::ThermalController::setpointSelection::operational', 'TethysFlightBehaviour::ThermalController::setpointSelection::survival', 'LoadShed', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::ThermalController::setpointSelection::survival', 'TethysFlightBehaviour::ThermalController::setpointSelection::operational', 'LoadRestore', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::ThermalController::heaterLoop::heaterOff', 'TethysFlightBehaviour::ThermalController::heaterLoop::heaterOn', 'TemperatureReport', 't', 'command', None, 'THERMAL_CONTROLLER_G1', None),
        Transition('TethysFlightBehaviour::ThermalController::heaterLoop::heaterOn', 'TethysFlightBehaviour::ThermalController::heaterLoop::heaterOff', 'TemperatureReport', 't', 'command', None, 'THERMAL_CONTROLLER_G2', None),
    ),
    (
        NamedExpression('THERMAL_CONTROLLER_G1', 't.temperature < setpoint - hysteresis'),
        NamedExpression('THERMAL_CONTROLLER_G2', 't.temperature > setpoint + hysteresis'),
    ),
    (
    ),
)

TELECOM_MANAGER = StateMachine(
    'TelecomManager', 'TethysFlightBehaviour::TelecomManager', 'TethysFlightBehaviour::TelecomManager::safeRate',
    (
        State('safeRate', 'TethysFlightBehaviour::TelecomManager::safeRate', None, None, True, 'safeRateEntries := safeRateEntries + 1', ''),
        State('highGainIdle', 'TethysFlightBehaviour::TelecomManager::highGainIdle', None, None, True, '', ''),
        State('pass', 'TethysFlightBehaviour::TelecomManager::pass', None, None, True, 'passes := passes + 1', ''),
        State('relaying', 'TethysFlightBehaviour::TelecomManager::relaying', None, None, True, '', ''),
    ),
    (
        Transition('TethysFlightBehaviour::TelecomManager::safeRate', 'TethysFlightBehaviour::TelecomManager::highGainIdle', 'HighGainSelect', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::TelecomManager::highGainIdle', 'TethysFlightBehaviour::TelecomManager::pass', 'PassStart', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::TelecomManager::pass', 'TethysFlightBehaviour::TelecomManager::highGainIdle', 'PassEnd', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::TelecomManager::pass', 'TethysFlightBehaviour::TelecomManager::highGainIdle', None, None, None, 'after passDuration', None, None),
        Transition('TethysFlightBehaviour::TelecomManager::highGainIdle', 'TethysFlightBehaviour::TelecomManager::relaying', 'RelayEnable', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::TelecomManager::relaying', 'TethysFlightBehaviour::TelecomManager::highGainIdle', 'RelayDisable', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::TelecomManager::highGainIdle', 'TethysFlightBehaviour::TelecomManager::safeRate', 'LowGainSelect', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::TelecomManager::pass', 'TethysFlightBehaviour::TelecomManager::safeRate', 'LowGainSelect', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::TelecomManager::relaying', 'TethysFlightBehaviour::TelecomManager::safeRate', 'LowGainSelect', None, 'command', None, None, None),
    ),
    (
    ),
    (
    ),
)

INSPECTOR_HANDLER = StateMachine(
    'InspectorHandler', 'TethysFlightBehaviour::InspectorHandler', 'TethysFlightBehaviour::InspectorHandler::stowed',
    (
        State('stowed', 'TethysFlightBehaviour::InspectorHandler::stowed', None, None, True, '', ''),
        State('checkout', 'TethysFlightBehaviour::InspectorHandler::checkout', None, None, True, '', 'checkedOut := true'),
        State('released', 'TethysFlightBehaviour::InspectorHandler::released', None, None, True, '', ''),
        State('relayingImagery', 'TethysFlightBehaviour::InspectorHandler::relayingImagery', None, None, True, 'imagingCampaigns := imagingCampaigns + 1', ''),
        State('retired', 'TethysFlightBehaviour::InspectorHandler::retired', None, None, True, '', ''),
    ),
    (
        Transition('TethysFlightBehaviour::InspectorHandler::stowed', 'TethysFlightBehaviour::InspectorHandler::checkout', 'InspectorCheckoutGo', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::InspectorHandler::checkout', 'TethysFlightBehaviour::InspectorHandler::stowed', None, None, None, 'after checkoutDuration', None, None),
        Transition('TethysFlightBehaviour::InspectorHandler::stowed', 'TethysFlightBehaviour::InspectorHandler::released', 'InspectorReleaseGo', None, 'command', None, 'INSPECTOR_HANDLER_G1', None),
        Transition('TethysFlightBehaviour::InspectorHandler::released', 'TethysFlightBehaviour::InspectorHandler::relayingImagery', 'InspectorImagingGo', 'go', 'command', None, None, 'INSPECTOR_HANDLER_E1'),
        Transition('TethysFlightBehaviour::InspectorHandler::relayingImagery', 'TethysFlightBehaviour::InspectorHandler::released', None, None, None, 'after passDuration', None, None),
        Transition('TethysFlightBehaviour::InspectorHandler::released', 'TethysFlightBehaviour::InspectorHandler::retired', 'InspectorRetireGo', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::InspectorHandler::relayingImagery', 'TethysFlightBehaviour::InspectorHandler::retired', 'InspectorRetireGo', None, 'command', None, None, None),
    ),
    (
        NamedExpression('INSPECTOR_HANDLER_G1', 'checkedOut'),
    ),
    (
        NamedExpression('INSPECTOR_HANDLER_E1', 'passDuration := go.passDuration'),
    ),
)

CAPTURE_CONTROLLER = StateMachine(
    'CaptureController', 'TethysFlightBehaviour::CaptureController', 'TethysFlightBehaviour::CaptureController::characterising',
    (
        State('characterising', 'TethysFlightBehaviour::CaptureController::characterising', None, None, True, '', ''),
        State('armed', 'TethysFlightBehaviour::CaptureController::armed', None, None, True, '', ''),
        State('committed', 'TethysFlightBehaviour::CaptureController::committed', None, None, True, '', ''),
        State('cinching', 'TethysFlightBehaviour::CaptureController::cinching', None, None, True, 'cinchFire: cinchAttempts := cinchAttempts + 1; fire; fired := fire.fired', ''),
        State('inhibited', 'TethysFlightBehaviour::CaptureController::inhibited', None, None, True, '', ''),
        State('despinning', 'TethysFlightBehaviour::CaptureController::despinning', None, None, True, '', ''),
        State('captured', 'TethysFlightBehaviour::CaptureController::captured', None, None, True, '', ''),
    ),
    (
        Transition('TethysFlightBehaviour::CaptureController::characterising', 'TethysFlightBehaviour::CaptureController::armed', 'CaptureArm', None, 'command', None, None, 'CAPTURE_CONTROLLER_E1'),
        Transition('TethysFlightBehaviour::CaptureController::armed', 'TethysFlightBehaviour::CaptureController::armed', 'GroundEnable', None, 'command', None, None, 'CAPTURE_CONTROLLER_E2'),
        Transition('TethysFlightBehaviour::CaptureController::armed', 'TethysFlightBehaviour::CaptureController::committed', 'CaptureGo', None, 'command', None, None, 'CAPTURE_CONTROLLER_E3'),
        Transition('TethysFlightBehaviour::CaptureController::characterising', 'TethysFlightBehaviour::CaptureController::characterising', 'GroundEnable', None, 'command', None, None, 'CAPTURE_CONTROLLER_E2'),
        Transition('TethysFlightBehaviour::CaptureController::characterising', 'TethysFlightBehaviour::CaptureController::cinching', 'ContactDetected', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::CaptureController::armed', 'TethysFlightBehaviour::CaptureController::cinching', 'ContactDetected', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::CaptureController::committed', 'TethysFlightBehaviour::CaptureController::cinching', 'ContactDetected', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::CaptureController::cinching', 'TethysFlightBehaviour::CaptureController::despinning', None, None, None, None, 'CAPTURE_CONTROLLER_G1', None),
        Transition('TethysFlightBehaviour::CaptureController::cinching', 'TethysFlightBehaviour::CaptureController::inhibited', None, None, None, None, 'CAPTURE_CONTROLLER_G2', None),
        Transition('TethysFlightBehaviour::CaptureController::despinning', 'TethysFlightBehaviour::CaptureController::captured', None, None, None, 'after despinDuration', None, None),
        Transition('TethysFlightBehaviour::CaptureController::inhibited', 'TethysFlightBehaviour::CaptureController::characterising', 'CaptureDisarm', None, 'command', None, None, 'CAPTURE_CONTROLLER_E4'),
        Transition('TethysFlightBehaviour::CaptureController::armed', 'TethysFlightBehaviour::CaptureController::characterising', 'CaptureDisarm', None, 'command', None, None, 'CAPTURE_CONTROLLER_E5'),
        Transition('TethysFlightBehaviour::CaptureController::committed', 'TethysFlightBehaviour::CaptureController::characterising', 'CaptureDisarm', None, 'command', None, None, 'CAPTURE_CONTROLLER_E6'),
    ),
    (
        NamedExpression('CAPTURE_CONTROLLER_G1', 'fired'),
        NamedExpression('CAPTURE_CONTROLLER_G2', 'not fired'),
    ),
    (
        NamedExpression('CAPTURE_CONTROLLER_E1', 'armCommanded := true'),
        NamedExpression('CAPTURE_CONTROLLER_E2', 'groundEnable := true'),
        NamedExpression('CAPTURE_CONTROLLER_E3', 'inCaptureMode := true'),
        NamedExpression('CAPTURE_CONTROLLER_E4', 'clear: armCommanded := false; groundEnable := false; inCaptureMode := false'),
        NamedExpression('CAPTURE_CONTROLLER_E5', 'clearArmed: armCommanded := false; groundEnable := false; inCaptureMode := false'),
        NamedExpression('CAPTURE_CONTROLLER_E6', 'clearCommitted: armCommanded := false; groundEnable := false; inCaptureMode := false'),
    ),
)

REDUNDANCY_MANAGER = StateMachine(
    'RedundancyManager', 'TethysFlightBehaviour::RedundancyManager', 'TethysFlightBehaviour::RedundancyManager::primeActive',
    (
        State('primeActive', 'TethysFlightBehaviour::RedundancyManager::primeActive', None, None, True, '', ''),
        State('switchingToRedundant', 'TethysFlightBehaviour::RedundancyManager::switchingToRedundant', None, None, True, 'switchovers := switchovers + 1', ''),
        State('redundantActive', 'TethysFlightBehaviour::RedundancyManager::redundantActive', None, None, True, '', ''),
        State('switchingToPrime', 'TethysFlightBehaviour::RedundancyManager::switchingToPrime', None, None, True, 'switchovers := switchovers + 1', ''),
        State('lastComputer', 'TethysFlightBehaviour::RedundancyManager::lastComputer', None, None, True, '', ''),
    ),
    (
        Transition('TethysFlightBehaviour::RedundancyManager::primeActive', 'TethysFlightBehaviour::RedundancyManager::primeActive', 'Heartbeat', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::RedundancyManager::primeActive', 'TethysFlightBehaviour::RedundancyManager::switchingToRedundant', 'ProcessorReset', None, 'faults', None, None, 'REDUNDANCY_MANAGER_E1'),
        Transition('TethysFlightBehaviour::RedundancyManager::primeActive', 'TethysFlightBehaviour::RedundancyManager::switchingToRedundant', 'SwitchToRedundant', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::RedundancyManager::primeActive', 'TethysFlightBehaviour::RedundancyManager::switchingToRedundant', None, None, None, 'after heartbeatTimeout', None, 'REDUNDANCY_MANAGER_E1'),
        Transition('TethysFlightBehaviour::RedundancyManager::switchingToRedundant', 'TethysFlightBehaviour::RedundancyManager::redundantActive', None, None, None, 'after switchoverDuration', None, None),
        Transition('TethysFlightBehaviour::RedundancyManager::redundantActive', 'TethysFlightBehaviour::RedundancyManager::redundantActive', 'Heartbeat', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::RedundancyManager::redundantActive', 'TethysFlightBehaviour::RedundancyManager::switchingToPrime', 'ProcessorReset', None, 'faults', None, 'REDUNDANCY_MANAGER_G1', 'REDUNDANCY_MANAGER_E2'),
        Transition('TethysFlightBehaviour::RedundancyManager::redundantActive', 'TethysFlightBehaviour::RedundancyManager::lastComputer', 'ProcessorReset', None, 'faults', None, 'REDUNDANCY_MANAGER_G2', 'REDUNDANCY_MANAGER_E2'),
        Transition('TethysFlightBehaviour::RedundancyManager::redundantActive', 'TethysFlightBehaviour::RedundancyManager::switchingToPrime', None, None, None, 'after heartbeatTimeout', 'REDUNDANCY_MANAGER_G1', 'REDUNDANCY_MANAGER_E2'),
        Transition('TethysFlightBehaviour::RedundancyManager::redundantActive', 'TethysFlightBehaviour::RedundancyManager::lastComputer', None, None, None, 'after heartbeatTimeout', 'REDUNDANCY_MANAGER_G2', 'REDUNDANCY_MANAGER_E2'),
        Transition('TethysFlightBehaviour::RedundancyManager::switchingToPrime', 'TethysFlightBehaviour::RedundancyManager::primeActive', None, None, None, 'after switchoverDuration', None, None),
    ),
    (
        NamedExpression('REDUNDANCY_MANAGER_G1', 'primeHealthy'),
        NamedExpression('REDUNDANCY_MANAGER_G2', 'not primeHealthy'),
    ),
    (
        NamedExpression('REDUNDANCY_MANAGER_E1', 'primeHealthy := false'),
        NamedExpression('REDUNDANCY_MANAGER_E2', 'redundantHealthy := false'),
    ),
)

BOOT_UPDATE_MANAGER = StateMachine(
    'BootUpdateManager', 'TethysFlightBehaviour::BootUpdateManager', 'TethysFlightBehaviour::BootUpdateManager::bootRom',
    (
        State('bootRom', 'TethysFlightBehaviour::BootUpdateManager::bootRom', None, None, True, 'boots := boots + 1', ''),
        State('loadingImage', 'TethysFlightBehaviour::BootUpdateManager::loadingImage', None, None, True, '', ''),
        State('running', 'TethysFlightBehaviour::BootUpdateManager::running', None, None, True, '', ''),
        State('safeImage', 'TethysFlightBehaviour::BootUpdateManager::safeImage', None, None, True, 'fallBack: activeSlot := ImageSlot::safe; fallbacks := fallbacks + 1', ''),
        State('receivingUpdate', 'TethysFlightBehaviour::BootUpdateManager::receivingUpdate', None, None, True, '', ''),
        State('uploadVerifiedIdle', 'TethysFlightBehaviour::BootUpdateManager::uploadVerifiedIdle', None, None, True, '', ''),
    ),
    (
        Transition('TethysFlightBehaviour::BootUpdateManager::bootRom', 'TethysFlightBehaviour::BootUpdateManager::loadingImage', None, None, None, 'after 5.0 [s]', None, None),
        Transition('TethysFlightBehaviour::BootUpdateManager::loadingImage', 'TethysFlightBehaviour::BootUpdateManager::running', 'ImageVerify', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::BootUpdateManager::loadingImage', 'TethysFlightBehaviour::BootUpdateManager::safeImage', None, None, None, 'after bootTimeout', None, None),
        Transition('TethysFlightBehaviour::BootUpdateManager::running', 'TethysFlightBehaviour::BootUpdateManager::receivingUpdate', 'ImageSegment', None, 'update', None, None, 'BOOT_UPDATE_MANAGER_E1'),
        Transition('TethysFlightBehaviour::BootUpdateManager::receivingUpdate', 'TethysFlightBehaviour::BootUpdateManager::receivingUpdate', 'ImageSegment', None, 'update', None, None, 'BOOT_UPDATE_MANAGER_E1'),
        Transition('TethysFlightBehaviour::BootUpdateManager::receivingUpdate', 'TethysFlightBehaviour::BootUpdateManager::uploadVerifiedIdle', 'ImageVerify', None, 'command', None, None, 'BOOT_UPDATE_MANAGER_E2'),
        Transition('TethysFlightBehaviour::BootUpdateManager::uploadVerifiedIdle', 'TethysFlightBehaviour::BootUpdateManager::bootRom', 'ImageActivate', None, 'command', None, None, 'BOOT_UPDATE_MANAGER_E3'),
        Transition('TethysFlightBehaviour::BootUpdateManager::running', 'TethysFlightBehaviour::BootUpdateManager::bootRom', 'RebootCommand', None, 'command', None, None, None),
        Transition('TethysFlightBehaviour::BootUpdateManager::safeImage', 'TethysFlightBehaviour::BootUpdateManager::bootRom', 'ImageRollback', None, 'command', None, None, 'BOOT_UPDATE_MANAGER_E4'),
        Transition('TethysFlightBehaviour::BootUpdateManager::safeImage', 'TethysFlightBehaviour::BootUpdateManager::bootRom', 'RebootCommand', None, 'command', None, None, None),
    ),
    (
    ),
    (
        NamedExpression('BOOT_UPDATE_MANAGER_E1', 'segmentsReceived := segmentsReceived + 1'),
        NamedExpression('BOOT_UPDATE_MANAGER_E2', 'uploadVerified := true'),
        NamedExpression('BOOT_UPDATE_MANAGER_E3', 'activeSlot := ImageSlot::backup'),
        NamedExpression('BOOT_UPDATE_MANAGER_E4', 'activeSlot := ImageSlot::primary'),
    ),
)

TUG_MODES = StateMachine(
    'TugModes', 'TethysModes::TugModes', None,
    (
        State('flightMode', 'TethysModes::TugModes::flightMode', None, 'TethysModes::TugModes::flightMode::launch', False, '', ''),
        State('launch', 'TethysModes::TugModes::flightMode::launch', 'TethysModes::TugModes::flightMode', 'TethysModes::TugModes::flightMode::launch::onLauncher', False, '', ''),
        State('onLauncher', 'TethysModes::TugModes::flightMode::launch::onLauncher', 'TethysModes::TugModes::flightMode::launch', None, True, '', ''),
        State('deploying', 'TethysModes::TugModes::flightMode::launch::deploying', 'TethysModes::TugModes::flightMode::launch', None, True, '', ''),
        State('freeFlight', 'TethysModes::TugModes::flightMode::freeFlight', 'TethysModes::TugModes::flightMode', 'TethysModes::TugModes::flightMode::freeFlight::coast', False, '', ''),
        State('coast', 'TethysModes::TugModes::flightMode::freeFlight::coast', 'TethysModes::TugModes::flightMode::freeFlight', None, True, '', ''),
        State('thrust', 'TethysModes::TugModes::flightMode::freeFlight::thrust', 'TethysModes::TugModes::flightMode::freeFlight', None, True, 'startArc: thrustArcsStarted := thrustArcsStarted + 1; lastApplicationCommand := "SepControlApplication: start thrust arc"; applicationCommands := applicationCommands + 1', 'endArc: lastApplicationCommand := "SepControlApplication: end thrust arc"; applicationCommands := applicationCommands + 1'),
        State('approach', 'TethysModes::TugModes::flightMode::freeFlight::approach', 'TethysModes::TugModes::flightMode::freeFlight', None, True, '', ''),
        State('proximityOperations', 'TethysModes::TugModes::flightMode::freeFlight::proximityOperations', 'TethysModes::TugModes::flightMode::freeFlight', None, True, 'relayOn: lastApplicationCommand := "TelecomApplication, InspectorHandlingApplication: proximity relay on"; applicationCommands := applicationCommands + 1', ''),
        State('retreat', 'TethysModes::TugModes::flightMode::freeFlight::retreat', 'TethysModes::TugModes::flightMode::freeFlight', None, True, '', ''),
        State('capture', 'TethysModes::TugModes::flightMode::freeFlight::capture', 'TethysModes::TugModes::flightMode::freeFlight', None, True, 'armCapture: lastApplicationCommand := "CaptureControlApplication: arm"; applicationCommands := applicationCommands + 1', 'disarmCapture: lastApplicationCommand := "CaptureControlApplication: disarm"; applicationCommands := applicationCommands + 1'),
        State('stacked', 'TethysModes::TugModes::flightMode::stacked', 'TethysModes::TugModes::flightMode', 'TethysModes::TugModes::flightMode::stacked::despin', False, '', ''),
        State('despin', 'TethysModes::TugModes::flightMode::stacked::despin', 'TethysModes::TugModes::flightMode::stacked', None, True, '', ''),
        State('stackCoast', 'TethysModes::TugModes::flightMode::stacked::stackCoast', 'TethysModes::TugModes::flightMode::stacked', None, True, '', ''),
        State('stackThrust', 'TethysModes::TugModes::flightMode::stacked::stackThrust', 'TethysModes::TugModes::flightMode::stacked', None, True, 'startReturnArc: thrustArcsStarted := thrustArcsStarted + 1; lastApplicationCommand := "SepControlApplication: start return arc"; applicationCommands := applicationCommands + 1', ''),
        State('droHold', 'TethysModes::TugModes::flightMode::stacked::droHold', 'TethysModes::TugModes::flightMode::stacked', None, True, '', ''),
        State('dockedPassive', 'TethysModes::TugModes::flightMode::stacked::dockedPassive', 'TethysModes::TugModes::flightMode::stacked', None, True, '', ''),
        State('disposal', 'TethysModes::TugModes::flightMode::stacked::disposal', 'TethysModes::TugModes::flightMode::stacked', None, True, '', ''),
        State('safe', 'TethysModes::TugModes::flightMode::safe', 'TethysModes::TugModes::flightMode', None, True, 'shedToSafe: safeModeEntries := safeModeEntries + 1; lastApplicationCommand := "PowerManagementApplication: shed loads; TelecomApplication: low-gain safe rate"; applicationCommands := applicationCommands + 1', ''),
        State('abortHold', 'TethysModes::TugModes::flightMode::abortHold', 'TethysModes::TugModes::flightMode', None, True, 'abortSequences: abortEntries := abortEntries + 1; lastApplicationCommand := "AutonomyApplication: abort sequence; SepControlApplication: thrust inhibited"; applicationCommands := applicationCommands + 1', ''),
        State('sepString', 'TethysModes::TugModes::sepString', None, 'TethysModes::TugModes::sepString::off', False, '', ''),
        State('off', 'TethysModes::TugModes::sepString::off', 'TethysModes::TugModes::sepString', None, True, '', ''),
        State('standby', 'TethysModes::TugModes::sepString::standby', 'TethysModes::TugModes::sepString', None, True, '', ''),
        State('thrusting', 'TethysModes::TugModes::sepString::thrusting', 'TethysModes::TugModes::sepString', None, True, '', ''),
        State('disposalBurn', 'TethysModes::TugModes::sepString::disposalBurn', 'TethysModes::TugModes::sepString', None, True, '', ''),
        State('telecom', 'TethysModes::TugModes::telecom', None, 'TethysModes::TugModes::telecom::lowGain', False, '', ''),
        State('lowGain', 'TethysModes::TugModes::telecom::lowGain', 'TethysModes::TugModes::telecom', None, True, '', ''),
        State('highGain', 'TethysModes::TugModes::telecom::highGain', 'TethysModes::TugModes::telecom', None, True, '', ''),
        State('relaying', 'TethysModes::TugModes::telecom::relaying', 'TethysModes::TugModes::telecom', None, True, '', ''),
        State('attitudeControl', 'TethysModes::TugModes::attitudeControl', None, 'TethysModes::TugModes::attitudeControl::thrusters', False, '', ''),
        State('thrusters', 'TethysModes::TugModes::attitudeControl::thrusters', 'TethysModes::TugModes::attitudeControl', None, True, '', ''),
        State('wheels', 'TethysModes::TugModes::attitudeControl::wheels', 'TethysModes::TugModes::attitudeControl', None, True, '', ''),
        State('captureMechanism', 'TethysModes::TugModes::captureMechanism', None, 'TethysModes::TugModes::captureMechanism::stowed', False, '', ''),
        State('stowed', 'TethysModes::TugModes::captureMechanism::stowed', 'TethysModes::TugModes::captureMechanism', None, True, '', ''),
        State('deployed', 'TethysModes::TugModes::captureMechanism::deployed', 'TethysModes::TugModes::captureMechanism', None, True, '', ''),
        State('cinched', 'TethysModes::TugModes::captureMechanism::cinched', 'TethysModes::TugModes::captureMechanism', None, True, '', ''),
        State('released', 'TethysModes::TugModes::captureMechanism::released', 'TethysModes::TugModes::captureMechanism', None, True, '', ''),
    ),
    (
        Transition('TethysModes::TugModes::flightMode::launch::onLauncher', 'TethysModes::TugModes::flightMode::launch::deploying', 'SeparationConfirmed', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::flightMode::launch::deploying', 'done', 'ArraysDeployed', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::flightMode::launch::deploying', 'done', None, None, None, 'after arraysDeploymentTimeout', None, None),
        Transition('TethysModes::TugModes::flightMode::freeFlight::coast', 'TethysModes::TugModes::flightMode::freeFlight::thrust', 'ThrustArcGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::flightMode::freeFlight::thrust', 'TethysModes::TugModes::flightMode::freeFlight::coast', 'ThrustArcEnd', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::flightMode::freeFlight::coast', 'TethysModes::TugModes::flightMode::freeFlight::approach', 'ProximityOperationsGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::flightMode::freeFlight::approach', 'TethysModes::TugModes::flightMode::freeFlight::proximityOperations', 'RangeUpdate', 'u', 'command', None, 'TUG_MODES_G1', None),
        Transition('TethysModes::TugModes::flightMode::freeFlight::proximityOperations', 'TethysModes::TugModes::flightMode::freeFlight::capture', 'CaptureGo', 'go', 'command', None, 'TUG_MODES_G2', None),
        Transition('TethysModes::TugModes::flightMode::freeFlight::proximityOperations', 'TethysModes::TugModes::flightMode::freeFlight::retreat', 'CaptureGo', 'go', 'command', None, 'TUG_MODES_G3', None),
        Transition('TethysModes::TugModes::flightMode::freeFlight::retreat', 'TethysModes::TugModes::flightMode::freeFlight::proximityOperations', 'ProximityOperationsGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::flightMode::freeFlight::capture', 'done', 'CaptureComplete', None, 'command', None, None, 'TUG_MODES_E1'),
        Transition('TethysModes::TugModes::flightMode::stacked::despin', 'TethysModes::TugModes::flightMode::stacked::stackCoast', 'DespinComplete', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::flightMode::stacked::stackCoast', 'TethysModes::TugModes::flightMode::stacked::stackThrust', 'ReturnThrustGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::flightMode::stacked::stackThrust', 'TethysModes::TugModes::flightMode::stacked::stackCoast', 'ThrustArcEnd', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::flightMode::stacked::stackCoast', 'TethysModes::TugModes::flightMode::stacked::droHold', 'DroHoldGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::flightMode::stacked::droHold', 'TethysModes::TugModes::flightMode::stacked::dockedPassive', 'DockingGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::flightMode::stacked::dockedPassive', 'TethysModes::TugModes::flightMode::stacked::disposal', 'DisposalGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::flightMode::stacked::disposal', 'done', None, None, None, 'after disposalBurnDuration', None, None),
        Transition('TethysModes::TugModes::flightMode::launch', 'TethysModes::TugModes::flightMode::freeFlight', None, None, None, None, None, None),
        Transition('TethysModes::TugModes::flightMode::freeFlight', 'TethysModes::TugModes::flightMode::stacked', None, None, None, None, 'TUG_MODES_G4', None),
        Transition('TethysModes::TugModes::flightMode::stacked', 'done', None, None, None, None, None, None),
        Transition('TethysModes::TugModes::flightMode::launch', 'TethysModes::TugModes::flightMode::safe', 'SafeModeRequest', 'r', None, None, None, 'TUG_MODES_E2'),
        Transition('TethysModes::TugModes::flightMode::freeFlight', 'TethysModes::TugModes::flightMode::safe', 'SafeModeRequest', 'r', None, None, None, 'TUG_MODES_E2'),
        Transition('TethysModes::TugModes::flightMode::stacked', 'TethysModes::TugModes::flightMode::safe', 'SafeModeRequest', 'r', None, None, None, 'TUG_MODES_E2'),
        Transition('TethysModes::TugModes::flightMode::safe', 'TethysModes::TugModes::flightMode::freeFlight', 'SafeModeExit', None, 'command', None, 'TUG_MODES_G5', None),
        Transition('TethysModes::TugModes::flightMode::safe', 'TethysModes::TugModes::flightMode::stacked', 'SafeModeExit', None, 'command', None, 'TUG_MODES_G4', None),
        Transition('TethysModes::TugModes::flightMode::stacked', 'TethysModes::TugModes::flightMode::abortHold', 'AbortReturn', 'a', None, None, None, 'TUG_MODES_E3'),
        Transition('TethysModes::TugModes::flightMode::abortHold', 'TethysModes::TugModes::flightMode::stacked', 'SafeModeExit', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::sepString::off', 'TethysModes::TugModes::sepString::standby', 'ArraysDeployed', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::sepString::standby', 'TethysModes::TugModes::sepString::thrusting', 'ThrustArcGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::sepString::standby', 'TethysModes::TugModes::sepString::thrusting', 'ProximityOperationsGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::sepString::thrusting', 'TethysModes::TugModes::sepString::standby', 'RangeUpdate', 'u', 'command', None, 'TUG_MODES_G1', None),
        Transition('TethysModes::TugModes::sepString::standby', 'TethysModes::TugModes::sepString::thrusting', 'ReturnThrustGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::sepString::standby', 'TethysModes::TugModes::sepString::disposalBurn', 'DisposalGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::sepString::disposalBurn', 'TethysModes::TugModes::sepString::off', None, None, None, 'after disposalBurnDuration', None, None),
        Transition('TethysModes::TugModes::sepString::thrusting', 'TethysModes::TugModes::sepString::standby', 'ThrustArcEnd', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::sepString::standby', 'TethysModes::TugModes::sepString::off', 'SafeModeRequest', None, None, None, None, None),
        Transition('TethysModes::TugModes::sepString::thrusting', 'TethysModes::TugModes::sepString::off', 'SafeModeRequest', None, None, None, None, None),
        Transition('TethysModes::TugModes::sepString::disposalBurn', 'TethysModes::TugModes::sepString::off', 'SafeModeRequest', None, None, None, None, None),
        Transition('TethysModes::TugModes::sepString::thrusting', 'TethysModes::TugModes::sepString::off', 'AbortReturn', None, None, None, None, None),
        Transition('TethysModes::TugModes::sepString::off', 'TethysModes::TugModes::sepString::standby', 'SafeModeExit', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::telecom::lowGain', 'TethysModes::TugModes::telecom::highGain', 'ArraysDeployed', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::telecom::highGain', 'TethysModes::TugModes::telecom::relaying', 'InspectorReleaseGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::telecom::relaying', 'TethysModes::TugModes::telecom::highGain', 'InspectorRetireGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::telecom::highGain', 'TethysModes::TugModes::telecom::lowGain', 'SafeModeRequest', None, None, None, None, None),
        Transition('TethysModes::TugModes::telecom::relaying', 'TethysModes::TugModes::telecom::lowGain', 'SafeModeRequest', None, None, None, None, None),
        Transition('TethysModes::TugModes::telecom::lowGain', 'TethysModes::TugModes::telecom::highGain', 'SafeModeExit', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::attitudeControl::thrusters', 'TethysModes::TugModes::attitudeControl::wheels', 'ArraysDeployed', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::attitudeControl::wheels', 'TethysModes::TugModes::attitudeControl::thrusters', 'ProximityOperationsGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::attitudeControl::thrusters', 'TethysModes::TugModes::attitudeControl::wheels', 'DespinComplete', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::attitudeControl::wheels', 'TethysModes::TugModes::attitudeControl::thrusters', 'DockingGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::attitudeControl::thrusters', 'TethysModes::TugModes::attitudeControl::wheels', 'DisposalGo', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::attitudeControl::wheels', 'TethysModes::TugModes::attitudeControl::thrusters', 'SafeModeRequest', None, None, None, None, None),
        Transition('TethysModes::TugModes::attitudeControl::thrusters', 'TethysModes::TugModes::attitudeControl::wheels', 'SafeModeExit', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::captureMechanism::stowed', 'TethysModes::TugModes::captureMechanism::deployed', 'CaptureGo', 'go', 'command', None, 'TUG_MODES_G2', None),
        Transition('TethysModes::TugModes::captureMechanism::deployed', 'TethysModes::TugModes::captureMechanism::cinched', 'CaptureComplete', None, 'command', None, None, None),
        Transition('TethysModes::TugModes::captureMechanism::cinched', 'TethysModes::TugModes::captureMechanism::released', 'DisposalGo', None, 'command', None, None, None),
    ),
    (
        NamedExpression('TUG_MODES_G1', 'u.range <= rendezvousRange'),
        NamedExpression('TUG_MODES_G2', 'go.estimatedMass <= envelope.maximumBodyMass and go.estimatedDiameter <= envelope.maximumBodyDiameter'),
        NamedExpression('TUG_MODES_G3', 'go.estimatedMass > envelope.maximumBodyMass or go.estimatedDiameter > envelope.maximumBodyDiameter'),
        NamedExpression('TUG_MODES_G4', 'captured'),
        NamedExpression('TUG_MODES_G5', 'not captured'),
    ),
    (
        NamedExpression('TUG_MODES_E1', 'captured := true'),
        NamedExpression('TUG_MODES_E2', 'lastSafeModeReason := r.reason'),
        NamedExpression('TUG_MODES_E3', 'lastSafeModeReason := a.reason'),
    ),
)

MODE_MANAGEMENT_DISPATCHER = StateMachine(
    'ModeManagementDispatcher', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching',
    (
        State('dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', None, None, True, '', ''),
    ),
    (
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'ArraysDeployed', None, 'dispatch', None, None, 'MODE_MANAGEMENT_DISPATCHER_E1'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'ThrustArcGo', None, 'dispatch', None, None, 'MODE_MANAGEMENT_DISPATCHER_E2'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'ThrustArcEnd', None, 'dispatch', None, None, 'MODE_MANAGEMENT_DISPATCHER_E3'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'ProximityOperationsGo', None, 'dispatch', None, None, 'MODE_MANAGEMENT_DISPATCHER_E4'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'RangeUpdate', 'u', 'dispatch', None, 'MODE_MANAGEMENT_DISPATCHER_G1', 'MODE_MANAGEMENT_DISPATCHER_E5'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'CaptureGo', None, 'dispatch', None, None, 'MODE_MANAGEMENT_DISPATCHER_E6'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'CaptureComplete', None, 'dispatch', None, None, 'MODE_MANAGEMENT_DISPATCHER_E7'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'ReturnThrustGo', None, 'dispatch', None, None, 'MODE_MANAGEMENT_DISPATCHER_E8'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'DockingGo', None, 'dispatch', None, None, 'MODE_MANAGEMENT_DISPATCHER_E9'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'DisposalGo', None, 'dispatch', None, None, 'MODE_MANAGEMENT_DISPATCHER_E10'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'InspectorCheckoutGo', None, 'dispatch', None, None, 'MODE_MANAGEMENT_DISPATCHER_E11'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'InspectorReleaseGo', None, 'dispatch', None, None, 'MODE_MANAGEMENT_DISPATCHER_E12'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'InspectorRetireGo', None, 'dispatch', None, None, 'MODE_MANAGEMENT_DISPATCHER_E13'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'SafeModeRequest', 'r', 'fdirRequests', None, None, 'MODE_MANAGEMENT_DISPATCHER_E14'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'SafeModeExit', None, 'dispatch', None, None, 'MODE_MANAGEMENT_DISPATCHER_E15'),
        Transition('TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching', 'AbortReturn', 'a', 'fdirRequests', None, None, 'MODE_MANAGEMENT_DISPATCHER_E16'),
    ),
    (
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_G1', 'u.range <= modes.rendezvousRange'),
    ),
    (
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E1', 'earlyOperations: send new SepStandby() via sepCommands; send new HighGainSelect() via telecomCommands; send new LoadRestore() via powerCommands; send new ApplicationReport(application = "ModeManagementApplication", report = "early operations") via events; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E2', 'thrustArc: send new SepThrust() via sepCommands; send new LowGainSelect() via telecomCommands; send new ApplicationReport(application = "ModeManagementApplication", report = "thrust arc") via events; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E3', 'coast: send new SepStandby() via sepCommands; send new HighGainSelect() via telecomCommands; send new ApplicationReport(application = "ModeManagementApplication", report = "coast") via events; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E4', 'approach: send new SepThrust() via sepCommands; send new ApplicationReport(application = "ModeManagementApplication", report = "approach") via events; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E5', 'proximityOperations: send new SepStandby() via sepCommands; send new RelayEnable() via telecomCommands; send new ApplicationReport(application = "ModeManagementApplication", report = "proximity operations") via events; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E6', 'capture: send new CaptureArm() via captureCommands; send new SequenceStart(sequenceId = 3) via autonomyCommands; send new ApplicationReport(application = "ModeManagementApplication", report = "capture") via events; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E7', 'despin: send new CaptureDisarm() via captureCommands; send new RelayDisable() via telecomCommands; send new ApplicationReport(application = "ModeManagementApplication", report = "despin") via events; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E8', 'stackThrust: send new SepThrust() via sepCommands; send new LowGainSelect() via telecomCommands; send new ApplicationReport(application = "ModeManagementApplication", report = "stack thrust") via events; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E9', 'docking: send new RelayEnable() via telecomCommands; send new ApplicationReport(application = "ModeManagementApplication", report = "docking") via events; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E10', 'disposal: send new SepDisposalBurn(duration = modes.disposalBurnDuration) via sepCommands; send new RelayDisable() via telecomCommands; send new ApplicationReport(application = "ModeManagementApplication", report = "disposal") via events; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E11', 'inspectorCheckout: send new InspectorCheckoutGo() via inspectorCommands; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E12', 'inspectorRelease: send new InspectorReleaseGo() via inspectorCommands; send new RelayEnable() via telecomCommands; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E13', 'inspectorRetire: send new InspectorRetireGo() via inspectorCommands; send new RelayDisable() via telecomCommands; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E14', 'safe: send new SafeModeRequest(reason = r.reason); send new SepOff() via sepCommands; send new LowGainSelect() via telecomCommands; send new LoadShed() via powerCommands; send new LoadShed() via thermalCommands; send new CaptureDisarm() via captureCommands; send new SequenceAbort() via autonomyCommands; send new ApplicationReport(application = "ModeManagementApplication", report = "safe mode") via events; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E15', 'recover: send new SepStandby() via sepCommands; send new HighGainSelect() via telecomCommands; send new LoadRestore() via powerCommands; send new LoadRestore() via thermalCommands; send new ApplicationReport(application = "ModeManagementApplication", report = "safe mode exit") via events; dispatched := dispatched + 1'),
        NamedExpression('MODE_MANAGEMENT_DISPATCHER_E16', 'abortHold: send new AbortReturn(reason = a.reason); send new SepOff() via sepCommands; send new HighGainSelect() via telecomCommands; send new SequenceAbort() via autonomyCommands; send new ApplicationReport(application = "ModeManagementApplication", report = "abort hold") via events; dispatched := dispatched + 1'),
    ),
)

FDIR_SUPERVISOR = StateMachine(
    'FdirSupervisor', 'TethysFdir::FdirSupervisor', None,
    (
        State('commandLossTimer', 'TethysFdir::FdirSupervisor::commandLossTimer', None, 'TethysFdir::FdirSupervisor::commandLossTimer::armed', False, '', ''),
        State('armed', 'TethysFdir::FdirSupervisor::commandLossTimer::armed', 'TethysFdir::FdirSupervisor::commandLossTimer', None, True, '', ''),
        State('expired', 'TethysFdir::FdirSupervisor::commandLossTimer::expired', 'TethysFdir::FdirSupervisor::commandLossTimer', None, True, 'callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = "command-loss timer expired")', ''),
        State('thrusterHealth', 'TethysFdir::FdirSupervisor::thrusterHealth', None, 'TethysFdir::FdirSupervisor::thrusterHealth::nominal', False, '', ''),
        State('nominal', 'TethysFdir::FdirSupervisor::thrusterHealth::nominal', 'TethysFdir::FdirSupervisor::thrusterHealth', None, True, '', ''),
        State('restarting', 'TethysFdir::FdirSupervisor::thrusterHealth::restarting', 'TethysFdir::FdirSupervisor::thrusterHealth', None, True, '', ''),
        State('onSpare', 'TethysFdir::FdirSupervisor::thrusterHealth::onSpare', 'TethysFdir::FdirSupervisor::thrusterHealth', None, True, '', ''),
        State('stringLost', 'TethysFdir::FdirSupervisor::thrusterHealth::stringLost', 'TethysFdir::FdirSupervisor::thrusterHealth', None, True, 'callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = "thruster string lost: operating set not available")', ''),
        State('ppuHealth', 'TethysFdir::FdirSupervisor::ppuHealth', None, 'TethysFdir::FdirSupervisor::ppuHealth::nominal', False, '', ''),
        State('nominal', 'TethysFdir::FdirSupervisor::ppuHealth::nominal', 'TethysFdir::FdirSupervisor::ppuHealth', None, True, '', ''),
        State('crossStrapped', 'TethysFdir::FdirSupervisor::ppuHealth::crossStrapped', 'TethysFdir::FdirSupervisor::ppuHealth', None, True, '', ''),
        State('ppuLost', 'TethysFdir::FdirSupervisor::ppuHealth::ppuLost', 'TethysFdir::FdirSupervisor::ppuHealth', None, True, 'callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = "second PPU trip: thrust profile replan needed")', ''),
        State('powerHealth', 'TethysFdir::FdirSupervisor::powerHealth', None, 'TethysFdir::FdirSupervisor::powerHealth::nominal', False, '', ''),
        State('nominal', 'TethysFdir::FdirSupervisor::powerHealth::nominal', 'TethysFdir::FdirSupervisor::powerHealth', None, True, '', ''),
        State('loadShed', 'TethysFdir::FdirSupervisor::powerHealth::loadShed', 'TethysFdir::FdirSupervisor::powerHealth', None, True, 'callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = "battery state of charge below load-shed fraction")', ''),
        State('attitudeHealth', 'TethysFdir::FdirSupervisor::attitudeHealth', None, 'TethysFdir::FdirSupervisor::attitudeHealth::nominal', False, '', ''),
        State('nominal', 'TethysFdir::FdirSupervisor::attitudeHealth::nominal', 'TethysFdir::FdirSupervisor::attitudeHealth', None, True, '', ''),
        State('sunAcquisition', 'TethysFdir::FdirSupervisor::attitudeHealth::sunAcquisition', 'TethysFdir::FdirSupervisor::attitudeHealth', None, True, 'callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = "attitude loss")', ''),
        State('earthImpactExclusion', 'TethysFdir::FdirSupervisor::earthImpactExclusion', None, 'TethysFdir::FdirSupervisor::earthImpactExclusion::monitoring', False, '', ''),
        State('monitoring', 'TethysFdir::FdirSupervisor::earthImpactExclusion::monitoring', 'TethysFdir::FdirSupervisor::earthImpactExclusion', None, True, '', ''),
        State('aborted', 'TethysFdir::FdirSupervisor::earthImpactExclusion::aborted', 'TethysFdir::FdirSupervisor::earthImpactExclusion', None, True, 'send new AbortReturn(reason = "Earth-impact exclusion violated")', ''),
    ),
    (
        Transition('TethysFdir::FdirSupervisor::commandLossTimer::armed', 'TethysFdir::FdirSupervisor::commandLossTimer::armed', 'GroundContact', None, 'command', None, None, None),
        Transition('TethysFdir::FdirSupervisor::commandLossTimer::armed', 'TethysFdir::FdirSupervisor::commandLossTimer::armed', 'ProcessorReset', None, 'command', None, None, None),
        Transition('TethysFdir::FdirSupervisor::commandLossTimer::armed', 'TethysFdir::FdirSupervisor::commandLossTimer::expired', None, None, None, 'after limits.commandLossTimeout', None, None),
        Transition('TethysFdir::FdirSupervisor::commandLossTimer::expired', 'TethysFdir::FdirSupervisor::commandLossTimer::armed', 'GroundContact', None, 'command', None, None, None),
        Transition('TethysFdir::FdirSupervisor::thrusterHealth::nominal', 'TethysFdir::FdirSupervisor::thrusterHealth::restarting', 'ThrusterFlameout', 'f', 'command', None, 'FDIR_SUPERVISOR_G1', 'FDIR_SUPERVISOR_E1'),
        Transition('TethysFdir::FdirSupervisor::thrusterHealth::restarting', 'TethysFdir::FdirSupervisor::thrusterHealth::nominal', None, None, None, 'after limits.thrusterRestartDelay', None, None),
        Transition('TethysFdir::FdirSupervisor::thrusterHealth::nominal', 'TethysFdir::FdirSupervisor::thrusterHealth::onSpare', 'ThrusterFlameout', 'f', 'command', None, 'FDIR_SUPERVISOR_G2', 'FDIR_SUPERVISOR_E2'),
        Transition('TethysFdir::FdirSupervisor::thrusterHealth::onSpare', 'TethysFdir::FdirSupervisor::thrusterHealth::stringLost', 'ThrusterFlameout', 'f', 'command', None, None, 'FDIR_SUPERVISOR_E2'),
        Transition('TethysFdir::FdirSupervisor::ppuHealth::nominal', 'TethysFdir::FdirSupervisor::ppuHealth::crossStrapped', 'PpuTrip', None, 'command', None, None, 'FDIR_SUPERVISOR_E3'),
        Transition('TethysFdir::FdirSupervisor::ppuHealth::crossStrapped', 'TethysFdir::FdirSupervisor::ppuHealth::ppuLost', 'PpuTrip', None, 'command', None, None, 'FDIR_SUPERVISOR_E3'),
        Transition('TethysFdir::FdirSupervisor::powerHealth::nominal', 'TethysFdir::FdirSupervisor::powerHealth::loadShed', 'BatteryLow', 'b', 'command', None, 'FDIR_SUPERVISOR_G3', None),
        Transition('TethysFdir::FdirSupervisor::powerHealth::loadShed', 'TethysFdir::FdirSupervisor::powerHealth::nominal', 'SafeModeExit', None, 'command', None, None, None),
        Transition('TethysFdir::FdirSupervisor::attitudeHealth::nominal', 'TethysFdir::FdirSupervisor::attitudeHealth::sunAcquisition', 'AttitudeLoss', None, 'command', None, None, None),
        Transition('TethysFdir::FdirSupervisor::attitudeHealth::sunAcquisition', 'TethysFdir::FdirSupervisor::attitudeHealth::nominal', 'SafeModeExit', None, 'command', None, None, None),
        Transition('TethysFdir::FdirSupervisor::earthImpactExclusion::monitoring', 'TethysFdir::FdirSupervisor::earthImpactExclusion::monitoring', 'TrajectoryUpdate', 't', 'command', None, 'FDIR_SUPERVISOR_G4', 'FDIR_SUPERVISOR_E4'),
        Transition('TethysFdir::FdirSupervisor::earthImpactExclusion::monitoring', 'TethysFdir::FdirSupervisor::earthImpactExclusion::aborted', 'TrajectoryUpdate', 't', 'command', None, 'FDIR_SUPERVISOR_G5', 'FDIR_SUPERVISOR_E4'),
        Transition('TethysFdir::FdirSupervisor::earthImpactExclusion::aborted', 'TethysFdir::FdirSupervisor::earthImpactExclusion::monitoring', 'SafeModeExit', None, 'command', None, None, None),
    ),
    (
        NamedExpression('FDIR_SUPERVISOR_G1', 'flameoutRetries < limits.maximumFlameoutRetries'),
        NamedExpression('FDIR_SUPERVISOR_G2', 'flameoutRetries >= limits.maximumFlameoutRetries'),
        NamedExpression('FDIR_SUPERVISOR_G3', 'b.stateOfCharge < limits.batteryLowFraction'),
        NamedExpression('FDIR_SUPERVISOR_G4', 't.earthClosestApproach > limits.earthExclusionRadius and t.impactProbability <= limits.maximumImpactProbability'),
        NamedExpression('FDIR_SUPERVISOR_G5', 't.earthClosestApproach <= limits.earthExclusionRadius or t.impactProbability > limits.maximumImpactProbability'),
    ),
    (
        NamedExpression('FDIR_SUPERVISOR_E1', 'flameoutRetries := flameoutRetries + 1'),
        NamedExpression('FDIR_SUPERVISOR_E2', 'healthyThrusters := healthyThrusters - 1'),
        NamedExpression('FDIR_SUPERVISOR_E3', 'ppuTrips := ppuTrips + 1'),
        NamedExpression('FDIR_SUPERVISOR_E4', 'record: lastEarthClosestApproach := t.earthClosestApproach; lastImpactProbability := t.impactProbability'),
    ),
)

FDIR_RESPONSE_RELAY = StateMachine(
    'FdirResponseRelay', 'TethysFlightBehaviour::FdirSoftware::responseRelay', 'TethysFlightBehaviour::FdirSoftware::responseRelay::relaying',
    (
        State('relaying', 'TethysFlightBehaviour::FdirSoftware::responseRelay::relaying', None, None, True, '', ''),
    ),
    (
        Transition('TethysFlightBehaviour::FdirSoftware::responseRelay::relaying', 'TethysFlightBehaviour::FdirSoftware::responseRelay::relaying', 'SafeModeRequest', 'r', None, None, None, 'FDIR_RESPONSE_RELAY_E1'),
        Transition('TethysFlightBehaviour::FdirSoftware::responseRelay::relaying', 'TethysFlightBehaviour::FdirSoftware::responseRelay::relaying', 'AbortReturn', 'a', None, None, None, 'FDIR_RESPONSE_RELAY_E2'),
    ),
    (
    ),
    (
        NamedExpression('FDIR_RESPONSE_RELAY_E1', 'relaySafeMode: send new SafeModeRequest(reason = r.reason) via supervisorRequests; relayed := relayed + 1'),
        NamedExpression('FDIR_RESPONSE_RELAY_E2', 'relayAbort: send new AbortReturn(reason = a.reason) via supervisorRequests; relayed := relayed + 1'),
    ),
)

STATE_MACHINES: tuple[StateMachine, ...] = (
    SEP_STRING_CONTROLLER,
    POWER_MANAGER,
    THERMAL_CONTROLLER,
    TELECOM_MANAGER,
    INSPECTOR_HANDLER,
    CAPTURE_CONTROLLER,
    REDUNDANCY_MANAGER,
    BOOT_UPDATE_MANAGER,
    TUG_MODES,
    MODE_MANAGEMENT_DISPATCHER,
    FDIR_SUPERVISOR,
    FDIR_RESPONSE_RELAY,
)
STATE_MACHINES_BY_NAME = {m.name: m for m in STATE_MACHINES}
