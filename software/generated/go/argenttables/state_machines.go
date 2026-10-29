// Argent flight software tables. Generated; edit the model or the generator, not this file.
// Generator: software/gen/generate.py 1.0.0
// Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
// Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
// Source elements:
//   TethysFlightBehaviour::SepStringController
//   TethysFlightBehaviour::PowerManager
//   TethysFlightBehaviour::ThermalController
//   TethysFlightBehaviour::TelecomManager
//   TethysFlightBehaviour::InspectorHandler
//   TethysFlightBehaviour::CaptureController
//   TethysFlightBehaviour::RedundancyManager
//   TethysFlightBehaviour::BootUpdateManager
//   TethysModes::TugModes
//   TethysFlightBehaviour::ModeManagementSoftware::dispatcher
//   TethysFdir::FdirSupervisor
//   TethysFlightBehaviour::FdirSoftware::responseRelay

package argenttables

type State struct {
	Name            string
	QualifiedName   string
	Parent          string
	InitialSubstate string
	Leaf            bool
	EntryAction     string
	ExitAction      string
}

type Transition struct {
	Source    string
	Target    string
	Event     string
	Parameter string
	Port      string
	Timed     string
	Guard     string
	Effect    string
	Region    string
	Line      int
}

type NamedExpression struct {
	ID   string
	Text string
}

type StateMachine struct {
	Name        string
	Source      string
	Initial     string
	States      []State
	Transitions []Transition
	Guards      []NamedExpression
	Effects     []NamedExpression
}

var SepStringController = StateMachine{
	"SepStringController", "TethysFlightBehaviour::SepStringController", "TethysFlightBehaviour::SepStringController::off",
	[]State{
		{"off", "TethysFlightBehaviour::SepStringController::off", "", "", true, "", ""},
		{"standby", "TethysFlightBehaviour::SepStringController::standby", "", "", true, "", ""},
		{"thrusting", "TethysFlightBehaviour::SepStringController::thrusting", "", "", true, "arcsStarted := arcsStarted + 1", ""},
		{"disposalBurn", "TethysFlightBehaviour::SepStringController::disposalBurn", "", "", true, "", ""},
		{"restarting", "TethysFlightBehaviour::SepStringController::restarting", "", "", true, "restarts := restarts + 1", ""},
		{"restartingDisposal", "TethysFlightBehaviour::SepStringController::restartingDisposal", "", "", true, "restarts := restarts + 1", ""},
	},
	[]Transition{
		{"TethysFlightBehaviour::SepStringController::off", "TethysFlightBehaviour::SepStringController::standby", "SepStandby", "", "command", "", "", "", "", 203},
		{"TethysFlightBehaviour::SepStringController::standby", "TethysFlightBehaviour::SepStringController::thrusting", "SepThrust", "", "command", "", "", "", "", 204},
		{"TethysFlightBehaviour::SepStringController::thrusting", "TethysFlightBehaviour::SepStringController::standby", "SepStandby", "", "command", "", "", "", "", 205},
		{"TethysFlightBehaviour::SepStringController::thrusting", "TethysFlightBehaviour::SepStringController::restarting", "ThrusterFlameout", "", "command", "", "", "", "", 206},
		{"TethysFlightBehaviour::SepStringController::restarting", "TethysFlightBehaviour::SepStringController::thrusting", "", "", "", "after restartDelay", "", "", "", 207},
		{"TethysFlightBehaviour::SepStringController::standby", "TethysFlightBehaviour::SepStringController::disposalBurn", "SepDisposalBurn", "b", "command", "", "", "SEP_STRING_CONTROLLER_E1", "", 208},
		{"TethysFlightBehaviour::SepStringController::disposalBurn", "TethysFlightBehaviour::SepStringController::off", "", "", "", "after burnDuration", "", "", "", 209},
		{"TethysFlightBehaviour::SepStringController::disposalBurn", "TethysFlightBehaviour::SepStringController::restartingDisposal", "ThrusterFlameout", "", "command", "", "", "", "", 210},
		{"TethysFlightBehaviour::SepStringController::restartingDisposal", "TethysFlightBehaviour::SepStringController::disposalBurn", "", "", "", "after restartDelay", "", "", "", 211},
		{"TethysFlightBehaviour::SepStringController::standby", "TethysFlightBehaviour::SepStringController::off", "SepOff", "", "command", "", "", "", "", 212},
		{"TethysFlightBehaviour::SepStringController::thrusting", "TethysFlightBehaviour::SepStringController::off", "SepOff", "", "command", "", "", "", "", 213},
		{"TethysFlightBehaviour::SepStringController::disposalBurn", "TethysFlightBehaviour::SepStringController::off", "SepOff", "", "command", "", "", "", "", 214},
		{"TethysFlightBehaviour::SepStringController::restarting", "TethysFlightBehaviour::SepStringController::off", "SepOff", "", "command", "", "", "", "", 215},
		{"TethysFlightBehaviour::SepStringController::restartingDisposal", "TethysFlightBehaviour::SepStringController::off", "SepOff", "", "command", "", "", "", "", 216},
	},
	[]NamedExpression{},
	[]NamedExpression{{"SEP_STRING_CONTROLLER_E1", "burnDuration := b.duration"}},
}

var PowerManager = StateMachine{
	"PowerManager", "TethysFlightBehaviour::PowerManager", "TethysFlightBehaviour::PowerManager::nominal",
	[]State{
		{"nominal", "TethysFlightBehaviour::PowerManager::nominal", "", "", true, "tier := LoadShedTier::none", ""},
		{"tierOne", "TethysFlightBehaviour::PowerManager::tierOne", "", "", true, "shedOne: tier := LoadShedTier::tierOne; shedEvents := shedEvents + 1", ""},
		{"tierTwo", "TethysFlightBehaviour::PowerManager::tierTwo", "", "", true, "shedTwo: tier := LoadShedTier::tierTwo; shedEvents := shedEvents + 1", ""},
		{"survival", "TethysFlightBehaviour::PowerManager::survival", "", "", true, "shedAll: tier := LoadShedTier::survival; shedEvents := shedEvents + 1", ""},
	},
	[]Transition{
		{"TethysFlightBehaviour::PowerManager::nominal", "TethysFlightBehaviour::PowerManager::tierOne", "BatteryStateOfCharge", "b", "command", "", "POWER_MANAGER_G1", "", "", 242},
		{"TethysFlightBehaviour::PowerManager::nominal", "TethysFlightBehaviour::PowerManager::tierTwo", "BatteryStateOfCharge", "b", "command", "", "POWER_MANAGER_G2", "", "", 244},
		{"TethysFlightBehaviour::PowerManager::tierOne", "TethysFlightBehaviour::PowerManager::tierTwo", "BatteryStateOfCharge", "b", "command", "", "POWER_MANAGER_G2", "", "", 246},
		{"TethysFlightBehaviour::PowerManager::tierOne", "TethysFlightBehaviour::PowerManager::nominal", "BatteryStateOfCharge", "b", "command", "", "POWER_MANAGER_G3", "", "", 248},
		{"TethysFlightBehaviour::PowerManager::tierTwo", "TethysFlightBehaviour::PowerManager::nominal", "BatteryStateOfCharge", "b", "command", "", "POWER_MANAGER_G3", "", "", 250},
		{"TethysFlightBehaviour::PowerManager::nominal", "TethysFlightBehaviour::PowerManager::survival", "LoadShed", "", "command", "", "", "", "", 252},
		{"TethysFlightBehaviour::PowerManager::tierOne", "TethysFlightBehaviour::PowerManager::survival", "LoadShed", "", "command", "", "", "", "", 253},
		{"TethysFlightBehaviour::PowerManager::tierTwo", "TethysFlightBehaviour::PowerManager::survival", "LoadShed", "", "command", "", "", "", "", 254},
		{"TethysFlightBehaviour::PowerManager::survival", "TethysFlightBehaviour::PowerManager::nominal", "LoadRestore", "", "command", "", "", "", "", 255},
	},
	[]NamedExpression{{"POWER_MANAGER_G1", "b.fraction < tierOneFraction and b.fraction >= limits.batteryLowFraction"}, {"POWER_MANAGER_G2", "b.fraction < limits.batteryLowFraction"}, {"POWER_MANAGER_G3", "b.fraction >= restoreFraction"}},
	[]NamedExpression{},
}

var ThermalController = StateMachine{
	"ThermalController", "TethysFlightBehaviour::ThermalController", "",
	[]State{
		{"setpointSelection", "TethysFlightBehaviour::ThermalController::setpointSelection", "", "TethysFlightBehaviour::ThermalController::setpointSelection::operational", false, "", ""},
		{"operational", "TethysFlightBehaviour::ThermalController::setpointSelection::operational", "TethysFlightBehaviour::ThermalController::setpointSelection", "", true, "setpoint := operationalSetpoint", ""},
		{"survival", "TethysFlightBehaviour::ThermalController::setpointSelection::survival", "TethysFlightBehaviour::ThermalController::setpointSelection", "", true, "setpoint := survivalSetpoint", ""},
		{"heaterLoop", "TethysFlightBehaviour::ThermalController::heaterLoop", "", "TethysFlightBehaviour::ThermalController::heaterLoop::heaterOff", false, "", ""},
		{"heaterOff", "TethysFlightBehaviour::ThermalController::heaterLoop::heaterOff", "TethysFlightBehaviour::ThermalController::heaterLoop", "", true, "", ""},
		{"heaterOn", "TethysFlightBehaviour::ThermalController::heaterLoop::heaterOn", "TethysFlightBehaviour::ThermalController::heaterLoop", "", true, "heaterCycles := heaterCycles + 1", ""},
	},
	[]Transition{
		{"TethysFlightBehaviour::ThermalController::setpointSelection::operational", "TethysFlightBehaviour::ThermalController::setpointSelection::survival", "LoadShed", "", "command", "", "", "", "TethysFlightBehaviour::ThermalController::setpointSelection", 276},
		{"TethysFlightBehaviour::ThermalController::setpointSelection::survival", "TethysFlightBehaviour::ThermalController::setpointSelection::operational", "LoadRestore", "", "command", "", "", "", "TethysFlightBehaviour::ThermalController::setpointSelection", 277},
		{"TethysFlightBehaviour::ThermalController::heaterLoop::heaterOff", "TethysFlightBehaviour::ThermalController::heaterLoop::heaterOn", "TemperatureReport", "t", "command", "", "THERMAL_CONTROLLER_G1", "", "TethysFlightBehaviour::ThermalController::heaterLoop", 285},
		{"TethysFlightBehaviour::ThermalController::heaterLoop::heaterOn", "TethysFlightBehaviour::ThermalController::heaterLoop::heaterOff", "TemperatureReport", "t", "command", "", "THERMAL_CONTROLLER_G2", "", "TethysFlightBehaviour::ThermalController::heaterLoop", 287},
	},
	[]NamedExpression{{"THERMAL_CONTROLLER_G1", "t.temperature < setpoint - hysteresis"}, {"THERMAL_CONTROLLER_G2", "t.temperature > setpoint + hysteresis"}},
	[]NamedExpression{},
}

var TelecomManager = StateMachine{
	"TelecomManager", "TethysFlightBehaviour::TelecomManager", "TethysFlightBehaviour::TelecomManager::safeRate",
	[]State{
		{"safeRate", "TethysFlightBehaviour::TelecomManager::safeRate", "", "", true, "safeRateEntries := safeRateEntries + 1", ""},
		{"highGainIdle", "TethysFlightBehaviour::TelecomManager::highGainIdle", "", "", true, "", ""},
		{"pass", "TethysFlightBehaviour::TelecomManager::pass", "", "", true, "passes := passes + 1", ""},
		{"relaying", "TethysFlightBehaviour::TelecomManager::relaying", "", "", true, "", ""},
	},
	[]Transition{
		{"TethysFlightBehaviour::TelecomManager::safeRate", "TethysFlightBehaviour::TelecomManager::highGainIdle", "HighGainSelect", "", "command", "", "", "", "", 308},
		{"TethysFlightBehaviour::TelecomManager::highGainIdle", "TethysFlightBehaviour::TelecomManager::pass", "PassStart", "", "command", "", "", "", "", 309},
		{"TethysFlightBehaviour::TelecomManager::pass", "TethysFlightBehaviour::TelecomManager::highGainIdle", "PassEnd", "", "command", "", "", "", "", 310},
		{"TethysFlightBehaviour::TelecomManager::pass", "TethysFlightBehaviour::TelecomManager::highGainIdle", "", "", "", "after passDuration", "", "", "", 311},
		{"TethysFlightBehaviour::TelecomManager::highGainIdle", "TethysFlightBehaviour::TelecomManager::relaying", "RelayEnable", "", "command", "", "", "", "", 312},
		{"TethysFlightBehaviour::TelecomManager::relaying", "TethysFlightBehaviour::TelecomManager::highGainIdle", "RelayDisable", "", "command", "", "", "", "", 313},
		{"TethysFlightBehaviour::TelecomManager::highGainIdle", "TethysFlightBehaviour::TelecomManager::safeRate", "LowGainSelect", "", "command", "", "", "", "", 314},
		{"TethysFlightBehaviour::TelecomManager::pass", "TethysFlightBehaviour::TelecomManager::safeRate", "LowGainSelect", "", "command", "", "", "", "", 315},
		{"TethysFlightBehaviour::TelecomManager::relaying", "TethysFlightBehaviour::TelecomManager::safeRate", "LowGainSelect", "", "command", "", "", "", "", 316},
	},
	[]NamedExpression{},
	[]NamedExpression{},
}

var InspectorHandler = StateMachine{
	"InspectorHandler", "TethysFlightBehaviour::InspectorHandler", "TethysFlightBehaviour::InspectorHandler::stowed",
	[]State{
		{"stowed", "TethysFlightBehaviour::InspectorHandler::stowed", "", "", true, "", ""},
		{"checkout", "TethysFlightBehaviour::InspectorHandler::checkout", "", "", true, "", "checkedOut := true"},
		{"released", "TethysFlightBehaviour::InspectorHandler::released", "", "", true, "", ""},
		{"relayingImagery", "TethysFlightBehaviour::InspectorHandler::relayingImagery", "", "", true, "imagingCampaigns := imagingCampaigns + 1", ""},
		{"retired", "TethysFlightBehaviour::InspectorHandler::retired", "", "", true, "", ""},
	},
	[]Transition{
		{"TethysFlightBehaviour::InspectorHandler::stowed", "TethysFlightBehaviour::InspectorHandler::checkout", "InspectorCheckoutGo", "", "command", "", "", "", "", 337},
		{"TethysFlightBehaviour::InspectorHandler::checkout", "TethysFlightBehaviour::InspectorHandler::stowed", "", "", "", "after checkoutDuration", "", "", "", 338},
		{"TethysFlightBehaviour::InspectorHandler::stowed", "TethysFlightBehaviour::InspectorHandler::released", "InspectorReleaseGo", "", "command", "", "INSPECTOR_HANDLER_G1", "", "", 339},
		{"TethysFlightBehaviour::InspectorHandler::released", "TethysFlightBehaviour::InspectorHandler::relayingImagery", "InspectorImagingGo", "go", "command", "", "", "INSPECTOR_HANDLER_E1", "", 340},
		{"TethysFlightBehaviour::InspectorHandler::relayingImagery", "TethysFlightBehaviour::InspectorHandler::released", "", "", "", "after passDuration", "", "", "", 341},
		{"TethysFlightBehaviour::InspectorHandler::released", "TethysFlightBehaviour::InspectorHandler::retired", "InspectorRetireGo", "", "command", "", "", "", "", 342},
		{"TethysFlightBehaviour::InspectorHandler::relayingImagery", "TethysFlightBehaviour::InspectorHandler::retired", "InspectorRetireGo", "", "command", "", "", "", "", 343},
	},
	[]NamedExpression{{"INSPECTOR_HANDLER_G1", "checkedOut"}},
	[]NamedExpression{{"INSPECTOR_HANDLER_E1", "passDuration := go.passDuration"}},
}

var CaptureController = StateMachine{
	"CaptureController", "TethysFlightBehaviour::CaptureController", "TethysFlightBehaviour::CaptureController::characterising",
	[]State{
		{"characterising", "TethysFlightBehaviour::CaptureController::characterising", "", "", true, "", ""},
		{"armed", "TethysFlightBehaviour::CaptureController::armed", "", "", true, "", ""},
		{"committed", "TethysFlightBehaviour::CaptureController::committed", "", "", true, "", ""},
		{"cinching", "TethysFlightBehaviour::CaptureController::cinching", "", "", true, "cinchFire: cinchAttempts := cinchAttempts + 1; fire; fired := fire.fired", ""},
		{"inhibited", "TethysFlightBehaviour::CaptureController::inhibited", "", "", true, "", ""},
		{"despinning", "TethysFlightBehaviour::CaptureController::despinning", "", "", true, "", ""},
		{"captured", "TethysFlightBehaviour::CaptureController::captured", "", "", true, "", ""},
	},
	[]Transition{
		{"TethysFlightBehaviour::CaptureController::characterising", "TethysFlightBehaviour::CaptureController::armed", "CaptureArm", "", "command", "", "", "CAPTURE_CONTROLLER_E1", "", 383},
		{"TethysFlightBehaviour::CaptureController::armed", "TethysFlightBehaviour::CaptureController::armed", "GroundEnable", "", "command", "", "", "CAPTURE_CONTROLLER_E2", "", 384},
		{"TethysFlightBehaviour::CaptureController::armed", "TethysFlightBehaviour::CaptureController::committed", "CaptureGo", "", "command", "", "", "CAPTURE_CONTROLLER_E3", "", 385},
		{"TethysFlightBehaviour::CaptureController::characterising", "TethysFlightBehaviour::CaptureController::characterising", "GroundEnable", "", "command", "", "", "CAPTURE_CONTROLLER_E2", "", 386},
		{"TethysFlightBehaviour::CaptureController::characterising", "TethysFlightBehaviour::CaptureController::cinching", "ContactDetected", "", "command", "", "", "", "", 387},
		{"TethysFlightBehaviour::CaptureController::armed", "TethysFlightBehaviour::CaptureController::cinching", "ContactDetected", "", "command", "", "", "", "", 388},
		{"TethysFlightBehaviour::CaptureController::committed", "TethysFlightBehaviour::CaptureController::cinching", "ContactDetected", "", "command", "", "", "", "", 389},
		{"TethysFlightBehaviour::CaptureController::cinching", "TethysFlightBehaviour::CaptureController::despinning", "", "", "", "", "CAPTURE_CONTROLLER_G1", "", "", 390},
		{"TethysFlightBehaviour::CaptureController::cinching", "TethysFlightBehaviour::CaptureController::inhibited", "", "", "", "", "CAPTURE_CONTROLLER_G2", "", "", 391},
		{"TethysFlightBehaviour::CaptureController::despinning", "TethysFlightBehaviour::CaptureController::captured", "", "", "", "after despinDuration", "", "", "", 392},
		{"TethysFlightBehaviour::CaptureController::inhibited", "TethysFlightBehaviour::CaptureController::characterising", "CaptureDisarm", "", "command", "", "", "CAPTURE_CONTROLLER_E4", "", 393},
		{"TethysFlightBehaviour::CaptureController::armed", "TethysFlightBehaviour::CaptureController::characterising", "CaptureDisarm", "", "command", "", "", "CAPTURE_CONTROLLER_E5", "", 395},
		{"TethysFlightBehaviour::CaptureController::committed", "TethysFlightBehaviour::CaptureController::characterising", "CaptureDisarm", "", "command", "", "", "CAPTURE_CONTROLLER_E6", "", 397},
	},
	[]NamedExpression{{"CAPTURE_CONTROLLER_G1", "fired"}, {"CAPTURE_CONTROLLER_G2", "not fired"}},
	[]NamedExpression{{"CAPTURE_CONTROLLER_E1", "armCommanded := true"}, {"CAPTURE_CONTROLLER_E2", "groundEnable := true"}, {"CAPTURE_CONTROLLER_E3", "inCaptureMode := true"}, {"CAPTURE_CONTROLLER_E4", "clear: armCommanded := false; groundEnable := false; inCaptureMode := false"}, {"CAPTURE_CONTROLLER_E5", "clearArmed: armCommanded := false; groundEnable := false; inCaptureMode := false"}, {"CAPTURE_CONTROLLER_E6", "clearCommitted: armCommanded := false; groundEnable := false; inCaptureMode := false"}},
}

var RedundancyManager = StateMachine{
	"RedundancyManager", "TethysFlightBehaviour::RedundancyManager", "TethysFlightBehaviour::RedundancyManager::primeActive",
	[]State{
		{"primeActive", "TethysFlightBehaviour::RedundancyManager::primeActive", "", "", true, "", ""},
		{"switchingToRedundant", "TethysFlightBehaviour::RedundancyManager::switchingToRedundant", "", "", true, "switchovers := switchovers + 1", ""},
		{"redundantActive", "TethysFlightBehaviour::RedundancyManager::redundantActive", "", "", true, "", ""},
		{"switchingToPrime", "TethysFlightBehaviour::RedundancyManager::switchingToPrime", "", "", true, "switchovers := switchovers + 1", ""},
		{"lastComputer", "TethysFlightBehaviour::RedundancyManager::lastComputer", "", "", true, "", ""},
	},
	[]Transition{
		{"TethysFlightBehaviour::RedundancyManager::primeActive", "TethysFlightBehaviour::RedundancyManager::primeActive", "Heartbeat", "", "command", "", "", "", "", 422},
		{"TethysFlightBehaviour::RedundancyManager::primeActive", "TethysFlightBehaviour::RedundancyManager::switchingToRedundant", "ProcessorReset", "", "faults", "", "", "REDUNDANCY_MANAGER_E1", "", 423},
		{"TethysFlightBehaviour::RedundancyManager::primeActive", "TethysFlightBehaviour::RedundancyManager::switchingToRedundant", "SwitchToRedundant", "", "command", "", "", "", "", 424},
		{"TethysFlightBehaviour::RedundancyManager::primeActive", "TethysFlightBehaviour::RedundancyManager::switchingToRedundant", "", "", "", "after heartbeatTimeout", "", "REDUNDANCY_MANAGER_E1", "", 425},
		{"TethysFlightBehaviour::RedundancyManager::switchingToRedundant", "TethysFlightBehaviour::RedundancyManager::redundantActive", "", "", "", "after switchoverDuration", "", "", "", 426},
		{"TethysFlightBehaviour::RedundancyManager::redundantActive", "TethysFlightBehaviour::RedundancyManager::redundantActive", "Heartbeat", "", "command", "", "", "", "", 427},
		{"TethysFlightBehaviour::RedundancyManager::redundantActive", "TethysFlightBehaviour::RedundancyManager::switchingToPrime", "ProcessorReset", "", "faults", "", "REDUNDANCY_MANAGER_G1", "REDUNDANCY_MANAGER_E2", "", 428},
		{"TethysFlightBehaviour::RedundancyManager::redundantActive", "TethysFlightBehaviour::RedundancyManager::lastComputer", "ProcessorReset", "", "faults", "", "REDUNDANCY_MANAGER_G2", "REDUNDANCY_MANAGER_E2", "", 430},
		{"TethysFlightBehaviour::RedundancyManager::redundantActive", "TethysFlightBehaviour::RedundancyManager::switchingToPrime", "", "", "", "after heartbeatTimeout", "REDUNDANCY_MANAGER_G1", "REDUNDANCY_MANAGER_E2", "", 432},
		{"TethysFlightBehaviour::RedundancyManager::redundantActive", "TethysFlightBehaviour::RedundancyManager::lastComputer", "", "", "", "after heartbeatTimeout", "REDUNDANCY_MANAGER_G2", "REDUNDANCY_MANAGER_E2", "", 434},
		{"TethysFlightBehaviour::RedundancyManager::switchingToPrime", "TethysFlightBehaviour::RedundancyManager::primeActive", "", "", "", "after switchoverDuration", "", "", "", 436},
	},
	[]NamedExpression{{"REDUNDANCY_MANAGER_G1", "primeHealthy"}, {"REDUNDANCY_MANAGER_G2", "not primeHealthy"}},
	[]NamedExpression{{"REDUNDANCY_MANAGER_E1", "primeHealthy := false"}, {"REDUNDANCY_MANAGER_E2", "redundantHealthy := false"}},
}

var BootUpdateManager = StateMachine{
	"BootUpdateManager", "TethysFlightBehaviour::BootUpdateManager", "TethysFlightBehaviour::BootUpdateManager::bootRom",
	[]State{
		{"bootRom", "TethysFlightBehaviour::BootUpdateManager::bootRom", "", "", true, "boots := boots + 1", ""},
		{"loadingImage", "TethysFlightBehaviour::BootUpdateManager::loadingImage", "", "", true, "", ""},
		{"running", "TethysFlightBehaviour::BootUpdateManager::running", "", "", true, "", ""},
		{"safeImage", "TethysFlightBehaviour::BootUpdateManager::safeImage", "", "", true, "fallBack: activeSlot := ImageSlot::safe; fallbacks := fallbacks + 1", ""},
		{"receivingUpdate", "TethysFlightBehaviour::BootUpdateManager::receivingUpdate", "", "", true, "", ""},
		{"uploadVerifiedIdle", "TethysFlightBehaviour::BootUpdateManager::uploadVerifiedIdle", "", "", true, "", ""},
	},
	[]Transition{
		{"TethysFlightBehaviour::BootUpdateManager::bootRom", "TethysFlightBehaviour::BootUpdateManager::loadingImage", "", "", "", "after 5.0 [s]", "", "", "", 462},
		{"TethysFlightBehaviour::BootUpdateManager::loadingImage", "TethysFlightBehaviour::BootUpdateManager::running", "ImageVerify", "", "command", "", "", "", "", 463},
		{"TethysFlightBehaviour::BootUpdateManager::loadingImage", "TethysFlightBehaviour::BootUpdateManager::safeImage", "", "", "", "after bootTimeout", "", "", "", 464},
		{"TethysFlightBehaviour::BootUpdateManager::running", "TethysFlightBehaviour::BootUpdateManager::receivingUpdate", "ImageSegment", "", "update", "", "", "BOOT_UPDATE_MANAGER_E1", "", 465},
		{"TethysFlightBehaviour::BootUpdateManager::receivingUpdate", "TethysFlightBehaviour::BootUpdateManager::receivingUpdate", "ImageSegment", "", "update", "", "", "BOOT_UPDATE_MANAGER_E1", "", 466},
		{"TethysFlightBehaviour::BootUpdateManager::receivingUpdate", "TethysFlightBehaviour::BootUpdateManager::uploadVerifiedIdle", "ImageVerify", "", "command", "", "", "BOOT_UPDATE_MANAGER_E2", "", 467},
		{"TethysFlightBehaviour::BootUpdateManager::uploadVerifiedIdle", "TethysFlightBehaviour::BootUpdateManager::bootRom", "ImageActivate", "", "command", "", "", "BOOT_UPDATE_MANAGER_E3", "", 468},
		{"TethysFlightBehaviour::BootUpdateManager::running", "TethysFlightBehaviour::BootUpdateManager::bootRom", "RebootCommand", "", "command", "", "", "", "", 469},
		{"TethysFlightBehaviour::BootUpdateManager::safeImage", "TethysFlightBehaviour::BootUpdateManager::bootRom", "ImageRollback", "", "command", "", "", "BOOT_UPDATE_MANAGER_E4", "", 470},
		{"TethysFlightBehaviour::BootUpdateManager::safeImage", "TethysFlightBehaviour::BootUpdateManager::bootRom", "RebootCommand", "", "command", "", "", "", "", 471},
	},
	[]NamedExpression{},
	[]NamedExpression{{"BOOT_UPDATE_MANAGER_E1", "segmentsReceived := segmentsReceived + 1"}, {"BOOT_UPDATE_MANAGER_E2", "uploadVerified := true"}, {"BOOT_UPDATE_MANAGER_E3", "activeSlot := ImageSlot::backup"}, {"BOOT_UPDATE_MANAGER_E4", "activeSlot := ImageSlot::primary"}},
}

var TugModes = StateMachine{
	"TugModes", "TethysModes::TugModes", "",
	[]State{
		{"flightMode", "TethysModes::TugModes::flightMode", "", "TethysModes::TugModes::flightMode::launch", false, "", ""},
		{"launch", "TethysModes::TugModes::flightMode::launch", "TethysModes::TugModes::flightMode", "TethysModes::TugModes::flightMode::launch::onLauncher", false, "", ""},
		{"onLauncher", "TethysModes::TugModes::flightMode::launch::onLauncher", "TethysModes::TugModes::flightMode::launch", "", true, "", ""},
		{"deploying", "TethysModes::TugModes::flightMode::launch::deploying", "TethysModes::TugModes::flightMode::launch", "", true, "", ""},
		{"freeFlight", "TethysModes::TugModes::flightMode::freeFlight", "TethysModes::TugModes::flightMode", "TethysModes::TugModes::flightMode::freeFlight::coast", false, "", ""},
		{"coast", "TethysModes::TugModes::flightMode::freeFlight::coast", "TethysModes::TugModes::flightMode::freeFlight", "", true, "", ""},
		{"thrust", "TethysModes::TugModes::flightMode::freeFlight::thrust", "TethysModes::TugModes::flightMode::freeFlight", "", true, "startArc: thrustArcsStarted := thrustArcsStarted + 1; lastApplicationCommand := \"SepControlApplication: start thrust arc\"; applicationCommands := applicationCommands + 1", "endArc: lastApplicationCommand := \"SepControlApplication: end thrust arc\"; applicationCommands := applicationCommands + 1"},
		{"approach", "TethysModes::TugModes::flightMode::freeFlight::approach", "TethysModes::TugModes::flightMode::freeFlight", "", true, "", ""},
		{"proximityOperations", "TethysModes::TugModes::flightMode::freeFlight::proximityOperations", "TethysModes::TugModes::flightMode::freeFlight", "", true, "relayOn: lastApplicationCommand := \"TelecomApplication, InspectorHandlingApplication: proximity relay on\"; applicationCommands := applicationCommands + 1", ""},
		{"retreat", "TethysModes::TugModes::flightMode::freeFlight::retreat", "TethysModes::TugModes::flightMode::freeFlight", "", true, "", ""},
		{"capture", "TethysModes::TugModes::flightMode::freeFlight::capture", "TethysModes::TugModes::flightMode::freeFlight", "", true, "armCapture: lastApplicationCommand := \"CaptureControlApplication: arm\"; applicationCommands := applicationCommands + 1", "disarmCapture: lastApplicationCommand := \"CaptureControlApplication: disarm\"; applicationCommands := applicationCommands + 1"},
		{"stacked", "TethysModes::TugModes::flightMode::stacked", "TethysModes::TugModes::flightMode", "TethysModes::TugModes::flightMode::stacked::despin", false, "", ""},
		{"despin", "TethysModes::TugModes::flightMode::stacked::despin", "TethysModes::TugModes::flightMode::stacked", "", true, "", ""},
		{"stackCoast", "TethysModes::TugModes::flightMode::stacked::stackCoast", "TethysModes::TugModes::flightMode::stacked", "", true, "", ""},
		{"stackThrust", "TethysModes::TugModes::flightMode::stacked::stackThrust", "TethysModes::TugModes::flightMode::stacked", "", true, "startReturnArc: thrustArcsStarted := thrustArcsStarted + 1; lastApplicationCommand := \"SepControlApplication: start return arc\"; applicationCommands := applicationCommands + 1", ""},
		{"droHold", "TethysModes::TugModes::flightMode::stacked::droHold", "TethysModes::TugModes::flightMode::stacked", "", true, "", ""},
		{"dockedPassive", "TethysModes::TugModes::flightMode::stacked::dockedPassive", "TethysModes::TugModes::flightMode::stacked", "", true, "", ""},
		{"disposal", "TethysModes::TugModes::flightMode::stacked::disposal", "TethysModes::TugModes::flightMode::stacked", "", true, "", ""},
		{"safe", "TethysModes::TugModes::flightMode::safe", "TethysModes::TugModes::flightMode", "", true, "shedToSafe: safeModeEntries := safeModeEntries + 1; lastApplicationCommand := \"PowerManagementApplication: shed loads; TelecomApplication: low-gain safe rate\"; applicationCommands := applicationCommands + 1", ""},
		{"abortHold", "TethysModes::TugModes::flightMode::abortHold", "TethysModes::TugModes::flightMode", "", true, "abortSequences: abortEntries := abortEntries + 1; lastApplicationCommand := \"AutonomyApplication: abort sequence; SepControlApplication: thrust inhibited\"; applicationCommands := applicationCommands + 1", ""},
		{"sepString", "TethysModes::TugModes::sepString", "", "TethysModes::TugModes::sepString::off", false, "", ""},
		{"off", "TethysModes::TugModes::sepString::off", "TethysModes::TugModes::sepString", "", true, "", ""},
		{"standby", "TethysModes::TugModes::sepString::standby", "TethysModes::TugModes::sepString", "", true, "", ""},
		{"thrusting", "TethysModes::TugModes::sepString::thrusting", "TethysModes::TugModes::sepString", "", true, "", ""},
		{"disposalBurn", "TethysModes::TugModes::sepString::disposalBurn", "TethysModes::TugModes::sepString", "", true, "", ""},
		{"telecom", "TethysModes::TugModes::telecom", "", "TethysModes::TugModes::telecom::lowGain", false, "", ""},
		{"lowGain", "TethysModes::TugModes::telecom::lowGain", "TethysModes::TugModes::telecom", "", true, "", ""},
		{"highGain", "TethysModes::TugModes::telecom::highGain", "TethysModes::TugModes::telecom", "", true, "", ""},
		{"relaying", "TethysModes::TugModes::telecom::relaying", "TethysModes::TugModes::telecom", "", true, "", ""},
		{"attitudeControl", "TethysModes::TugModes::attitudeControl", "", "TethysModes::TugModes::attitudeControl::thrusters", false, "", ""},
		{"thrusters", "TethysModes::TugModes::attitudeControl::thrusters", "TethysModes::TugModes::attitudeControl", "", true, "", ""},
		{"wheels", "TethysModes::TugModes::attitudeControl::wheels", "TethysModes::TugModes::attitudeControl", "", true, "", ""},
		{"captureMechanism", "TethysModes::TugModes::captureMechanism", "", "TethysModes::TugModes::captureMechanism::stowed", false, "", ""},
		{"stowed", "TethysModes::TugModes::captureMechanism::stowed", "TethysModes::TugModes::captureMechanism", "", true, "", ""},
		{"deployed", "TethysModes::TugModes::captureMechanism::deployed", "TethysModes::TugModes::captureMechanism", "", true, "", ""},
		{"cinched", "TethysModes::TugModes::captureMechanism::cinched", "TethysModes::TugModes::captureMechanism", "", true, "", ""},
		{"released", "TethysModes::TugModes::captureMechanism::released", "TethysModes::TugModes::captureMechanism", "", true, "", ""},
	},
	[]Transition{
		{"TethysModes::TugModes::flightMode::launch::onLauncher", "TethysModes::TugModes::flightMode::launch::deploying", "SeparationConfirmed", "", "command", "", "", "", "TethysModes::TugModes::flightMode::launch", 288},
		{"TethysModes::TugModes::flightMode::launch::deploying", "done", "ArraysDeployed", "", "command", "", "", "", "TethysModes::TugModes::flightMode::launch", 289},
		{"TethysModes::TugModes::flightMode::launch::deploying", "done", "", "", "", "after arraysDeploymentTimeout", "", "", "TethysModes::TugModes::flightMode::launch", 290},
		{"TethysModes::TugModes::flightMode::freeFlight::coast", "TethysModes::TugModes::flightMode::freeFlight::thrust", "ThrustArcGo", "", "command", "", "", "", "TethysModes::TugModes::flightMode::freeFlight", 326},
		{"TethysModes::TugModes::flightMode::freeFlight::thrust", "TethysModes::TugModes::flightMode::freeFlight::coast", "ThrustArcEnd", "", "command", "", "", "", "TethysModes::TugModes::flightMode::freeFlight", 327},
		{"TethysModes::TugModes::flightMode::freeFlight::coast", "TethysModes::TugModes::flightMode::freeFlight::approach", "ProximityOperationsGo", "", "command", "", "", "", "TethysModes::TugModes::flightMode::freeFlight", 328},
		{"TethysModes::TugModes::flightMode::freeFlight::approach", "TethysModes::TugModes::flightMode::freeFlight::proximityOperations", "RangeUpdate", "u", "command", "", "TUG_MODES_G1", "", "TethysModes::TugModes::flightMode::freeFlight", 329},
		{"TethysModes::TugModes::flightMode::freeFlight::proximityOperations", "TethysModes::TugModes::flightMode::freeFlight::capture", "CaptureGo", "go", "command", "", "TUG_MODES_G2", "", "TethysModes::TugModes::flightMode::freeFlight", 330},
		{"TethysModes::TugModes::flightMode::freeFlight::proximityOperations", "TethysModes::TugModes::flightMode::freeFlight::retreat", "CaptureGo", "go", "command", "", "TUG_MODES_G3", "", "TethysModes::TugModes::flightMode::freeFlight", 333},
		{"TethysModes::TugModes::flightMode::freeFlight::retreat", "TethysModes::TugModes::flightMode::freeFlight::proximityOperations", "ProximityOperationsGo", "", "command", "", "", "", "TethysModes::TugModes::flightMode::freeFlight", 336},
		{"TethysModes::TugModes::flightMode::freeFlight::capture", "done", "CaptureComplete", "", "command", "", "", "TUG_MODES_E1", "TethysModes::TugModes::flightMode::freeFlight", 337},
		{"TethysModes::TugModes::flightMode::stacked::despin", "TethysModes::TugModes::flightMode::stacked::stackCoast", "DespinComplete", "", "command", "", "", "", "TethysModes::TugModes::flightMode::stacked", 356},
		{"TethysModes::TugModes::flightMode::stacked::stackCoast", "TethysModes::TugModes::flightMode::stacked::stackThrust", "ReturnThrustGo", "", "command", "", "", "", "TethysModes::TugModes::flightMode::stacked", 357},
		{"TethysModes::TugModes::flightMode::stacked::stackThrust", "TethysModes::TugModes::flightMode::stacked::stackCoast", "ThrustArcEnd", "", "command", "", "", "", "TethysModes::TugModes::flightMode::stacked", 358},
		{"TethysModes::TugModes::flightMode::stacked::stackCoast", "TethysModes::TugModes::flightMode::stacked::droHold", "DroHoldGo", "", "command", "", "", "", "TethysModes::TugModes::flightMode::stacked", 359},
		{"TethysModes::TugModes::flightMode::stacked::droHold", "TethysModes::TugModes::flightMode::stacked::dockedPassive", "DockingGo", "", "command", "", "", "", "TethysModes::TugModes::flightMode::stacked", 360},
		{"TethysModes::TugModes::flightMode::stacked::dockedPassive", "TethysModes::TugModes::flightMode::stacked::disposal", "DisposalGo", "", "command", "", "", "", "TethysModes::TugModes::flightMode::stacked", 361},
		{"TethysModes::TugModes::flightMode::stacked::disposal", "done", "", "", "", "after disposalBurnDuration", "", "", "TethysModes::TugModes::flightMode::stacked", 362},
		{"TethysModes::TugModes::flightMode::launch", "TethysModes::TugModes::flightMode::freeFlight", "", "", "", "", "", "", "TethysModes::TugModes::flightMode", 389},
		{"TethysModes::TugModes::flightMode::freeFlight", "TethysModes::TugModes::flightMode::stacked", "", "", "", "", "TUG_MODES_G4", "", "TethysModes::TugModes::flightMode", 390},
		{"TethysModes::TugModes::flightMode::stacked", "done", "", "", "", "", "", "", "TethysModes::TugModes::flightMode", 391},
		{"TethysModes::TugModes::flightMode::launch", "TethysModes::TugModes::flightMode::safe", "SafeModeRequest", "r", "", "", "", "TUG_MODES_E2", "TethysModes::TugModes::flightMode", 392},
		{"TethysModes::TugModes::flightMode::freeFlight", "TethysModes::TugModes::flightMode::safe", "SafeModeRequest", "r", "", "", "", "TUG_MODES_E2", "TethysModes::TugModes::flightMode", 393},
		{"TethysModes::TugModes::flightMode::stacked", "TethysModes::TugModes::flightMode::safe", "SafeModeRequest", "r", "", "", "", "TUG_MODES_E2", "TethysModes::TugModes::flightMode", 394},
		{"TethysModes::TugModes::flightMode::safe", "TethysModes::TugModes::flightMode::freeFlight", "SafeModeExit", "", "command", "", "TUG_MODES_G5", "", "TethysModes::TugModes::flightMode", 395},
		{"TethysModes::TugModes::flightMode::safe", "TethysModes::TugModes::flightMode::stacked", "SafeModeExit", "", "command", "", "TUG_MODES_G4", "", "TethysModes::TugModes::flightMode", 396},
		{"TethysModes::TugModes::flightMode::stacked", "TethysModes::TugModes::flightMode::abortHold", "AbortReturn", "a", "", "", "", "TUG_MODES_E3", "TethysModes::TugModes::flightMode", 397},
		{"TethysModes::TugModes::flightMode::abortHold", "TethysModes::TugModes::flightMode::stacked", "SafeModeExit", "", "command", "", "", "", "TethysModes::TugModes::flightMode", 398},
		{"TethysModes::TugModes::sepString::off", "TethysModes::TugModes::sepString::standby", "ArraysDeployed", "", "command", "", "", "", "TethysModes::TugModes::sepString", 411},
		{"TethysModes::TugModes::sepString::standby", "TethysModes::TugModes::sepString::thrusting", "ThrustArcGo", "", "command", "", "", "", "TethysModes::TugModes::sepString", 412},
		{"TethysModes::TugModes::sepString::standby", "TethysModes::TugModes::sepString::thrusting", "ProximityOperationsGo", "", "command", "", "", "", "TethysModes::TugModes::sepString", 413},
		{"TethysModes::TugModes::sepString::thrusting", "TethysModes::TugModes::sepString::standby", "RangeUpdate", "u", "command", "", "TUG_MODES_G1", "", "TethysModes::TugModes::sepString", 414},
		{"TethysModes::TugModes::sepString::standby", "TethysModes::TugModes::sepString::thrusting", "ReturnThrustGo", "", "command", "", "", "", "TethysModes::TugModes::sepString", 415},
		{"TethysModes::TugModes::sepString::standby", "TethysModes::TugModes::sepString::disposalBurn", "DisposalGo", "", "command", "", "", "", "TethysModes::TugModes::sepString", 416},
		{"TethysModes::TugModes::sepString::disposalBurn", "TethysModes::TugModes::sepString::off", "", "", "", "after disposalBurnDuration", "", "", "TethysModes::TugModes::sepString", 417},
		{"TethysModes::TugModes::sepString::thrusting", "TethysModes::TugModes::sepString::standby", "ThrustArcEnd", "", "command", "", "", "", "TethysModes::TugModes::sepString", 418},
		{"TethysModes::TugModes::sepString::standby", "TethysModes::TugModes::sepString::off", "SafeModeRequest", "", "", "", "", "", "TethysModes::TugModes::sepString", 419},
		{"TethysModes::TugModes::sepString::thrusting", "TethysModes::TugModes::sepString::off", "SafeModeRequest", "", "", "", "", "", "TethysModes::TugModes::sepString", 420},
		{"TethysModes::TugModes::sepString::disposalBurn", "TethysModes::TugModes::sepString::off", "SafeModeRequest", "", "", "", "", "", "TethysModes::TugModes::sepString", 421},
		{"TethysModes::TugModes::sepString::thrusting", "TethysModes::TugModes::sepString::off", "AbortReturn", "", "", "", "", "", "TethysModes::TugModes::sepString", 422},
		{"TethysModes::TugModes::sepString::off", "TethysModes::TugModes::sepString::standby", "SafeModeExit", "", "command", "", "", "", "TethysModes::TugModes::sepString", 423},
		{"TethysModes::TugModes::telecom::lowGain", "TethysModes::TugModes::telecom::highGain", "ArraysDeployed", "", "command", "", "", "", "TethysModes::TugModes::telecom", 433},
		{"TethysModes::TugModes::telecom::highGain", "TethysModes::TugModes::telecom::relaying", "InspectorReleaseGo", "", "command", "", "", "", "TethysModes::TugModes::telecom", 434},
		{"TethysModes::TugModes::telecom::relaying", "TethysModes::TugModes::telecom::highGain", "InspectorRetireGo", "", "command", "", "", "", "TethysModes::TugModes::telecom", 435},
		{"TethysModes::TugModes::telecom::highGain", "TethysModes::TugModes::telecom::lowGain", "SafeModeRequest", "", "", "", "", "", "TethysModes::TugModes::telecom", 436},
		{"TethysModes::TugModes::telecom::relaying", "TethysModes::TugModes::telecom::lowGain", "SafeModeRequest", "", "", "", "", "", "TethysModes::TugModes::telecom", 437},
		{"TethysModes::TugModes::telecom::lowGain", "TethysModes::TugModes::telecom::highGain", "SafeModeExit", "", "command", "", "", "", "TethysModes::TugModes::telecom", 438},
		{"TethysModes::TugModes::attitudeControl::thrusters", "TethysModes::TugModes::attitudeControl::wheels", "ArraysDeployed", "", "command", "", "", "", "TethysModes::TugModes::attitudeControl", 447},
		{"TethysModes::TugModes::attitudeControl::wheels", "TethysModes::TugModes::attitudeControl::thrusters", "ProximityOperationsGo", "", "command", "", "", "", "TethysModes::TugModes::attitudeControl", 448},
		{"TethysModes::TugModes::attitudeControl::thrusters", "TethysModes::TugModes::attitudeControl::wheels", "DespinComplete", "", "command", "", "", "", "TethysModes::TugModes::attitudeControl", 449},
		{"TethysModes::TugModes::attitudeControl::wheels", "TethysModes::TugModes::attitudeControl::thrusters", "DockingGo", "", "command", "", "", "", "TethysModes::TugModes::attitudeControl", 450},
		{"TethysModes::TugModes::attitudeControl::thrusters", "TethysModes::TugModes::attitudeControl::wheels", "DisposalGo", "", "command", "", "", "", "TethysModes::TugModes::attitudeControl", 451},
		{"TethysModes::TugModes::attitudeControl::wheels", "TethysModes::TugModes::attitudeControl::thrusters", "SafeModeRequest", "", "", "", "", "", "TethysModes::TugModes::attitudeControl", 452},
		{"TethysModes::TugModes::attitudeControl::thrusters", "TethysModes::TugModes::attitudeControl::wheels", "SafeModeExit", "", "command", "", "", "", "TethysModes::TugModes::attitudeControl", 453},
		{"TethysModes::TugModes::captureMechanism::stowed", "TethysModes::TugModes::captureMechanism::deployed", "CaptureGo", "go", "command", "", "TUG_MODES_G2", "", "TethysModes::TugModes::captureMechanism", 464},
		{"TethysModes::TugModes::captureMechanism::deployed", "TethysModes::TugModes::captureMechanism::cinched", "CaptureComplete", "", "command", "", "", "", "TethysModes::TugModes::captureMechanism", 467},
		{"TethysModes::TugModes::captureMechanism::cinched", "TethysModes::TugModes::captureMechanism::released", "DisposalGo", "", "command", "", "", "", "TethysModes::TugModes::captureMechanism", 468},
	},
	[]NamedExpression{{"TUG_MODES_G1", "u.range <= rendezvousRange"}, {"TUG_MODES_G2", "go.estimatedMass <= envelope.maximumBodyMass and go.estimatedDiameter <= envelope.maximumBodyDiameter"}, {"TUG_MODES_G3", "go.estimatedMass > envelope.maximumBodyMass or go.estimatedDiameter > envelope.maximumBodyDiameter"}, {"TUG_MODES_G4", "captured"}, {"TUG_MODES_G5", "not captured"}},
	[]NamedExpression{{"TUG_MODES_E1", "captured := true"}, {"TUG_MODES_E2", "lastSafeModeReason := r.reason"}, {"TUG_MODES_E3", "lastSafeModeReason := a.reason"}},
}

var ModeManagementDispatcher = StateMachine{
	"ModeManagementDispatcher", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching",
	[]State{
		{"dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "", "", true, "", ""},
	},
	[]Transition{
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "ArraysDeployed", "", "dispatch", "", "", "MODE_MANAGEMENT_DISPATCHER_E1", "", 647},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "ThrustArcGo", "", "dispatch", "", "", "MODE_MANAGEMENT_DISPATCHER_E2", "", 654},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "ThrustArcEnd", "", "dispatch", "", "", "MODE_MANAGEMENT_DISPATCHER_E3", "", 660},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "ProximityOperationsGo", "", "dispatch", "", "", "MODE_MANAGEMENT_DISPATCHER_E4", "", 666},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "RangeUpdate", "u", "dispatch", "", "MODE_MANAGEMENT_DISPATCHER_G1", "MODE_MANAGEMENT_DISPATCHER_E5", "", 671},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "CaptureGo", "", "dispatch", "", "", "MODE_MANAGEMENT_DISPATCHER_E6", "", 677},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "CaptureComplete", "", "dispatch", "", "", "MODE_MANAGEMENT_DISPATCHER_E7", "", 683},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "ReturnThrustGo", "", "dispatch", "", "", "MODE_MANAGEMENT_DISPATCHER_E8", "", 689},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "DockingGo", "", "dispatch", "", "", "MODE_MANAGEMENT_DISPATCHER_E9", "", 695},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "DisposalGo", "", "dispatch", "", "", "MODE_MANAGEMENT_DISPATCHER_E10", "", 700},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "InspectorCheckoutGo", "", "dispatch", "", "", "MODE_MANAGEMENT_DISPATCHER_E11", "", 706},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "InspectorReleaseGo", "", "dispatch", "", "", "MODE_MANAGEMENT_DISPATCHER_E12", "", 710},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "InspectorRetireGo", "", "dispatch", "", "", "MODE_MANAGEMENT_DISPATCHER_E13", "", 715},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "SafeModeRequest", "r", "fdirRequests", "", "", "MODE_MANAGEMENT_DISPATCHER_E14", "", 720},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "SafeModeExit", "", "dispatch", "", "", "MODE_MANAGEMENT_DISPATCHER_E15", "", 731},
		{"TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "TethysFlightBehaviour::ModeManagementSoftware::dispatcher::dispatching", "AbortReturn", "a", "fdirRequests", "", "", "MODE_MANAGEMENT_DISPATCHER_E16", "", 739},
	},
	[]NamedExpression{{"MODE_MANAGEMENT_DISPATCHER_G1", "u.range <= modes.rendezvousRange"}},
	[]NamedExpression{{"MODE_MANAGEMENT_DISPATCHER_E1", "earlyOperations: send new SepStandby() via sepCommands; send new HighGainSelect() via telecomCommands; send new LoadRestore() via powerCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"early operations\") via events; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E2", "thrustArc: send new SepThrust() via sepCommands; send new LowGainSelect() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"thrust arc\") via events; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E3", "coast: send new SepStandby() via sepCommands; send new HighGainSelect() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"coast\") via events; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E4", "approach: send new SepThrust() via sepCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"approach\") via events; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E5", "proximityOperations: send new SepStandby() via sepCommands; send new RelayEnable() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"proximity operations\") via events; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E6", "capture: send new CaptureArm() via captureCommands; send new SequenceStart(sequenceId = 3) via autonomyCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"capture\") via events; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E7", "despin: send new CaptureDisarm() via captureCommands; send new RelayDisable() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"despin\") via events; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E8", "stackThrust: send new SepThrust() via sepCommands; send new LowGainSelect() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"stack thrust\") via events; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E9", "docking: send new RelayEnable() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"docking\") via events; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E10", "disposal: send new SepDisposalBurn(duration = modes.disposalBurnDuration) via sepCommands; send new RelayDisable() via telecomCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"disposal\") via events; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E11", "inspectorCheckout: send new InspectorCheckoutGo() via inspectorCommands; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E12", "inspectorRelease: send new InspectorReleaseGo() via inspectorCommands; send new RelayEnable() via telecomCommands; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E13", "inspectorRetire: send new InspectorRetireGo() via inspectorCommands; send new RelayDisable() via telecomCommands; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E14", "safe: send new SafeModeRequest(reason = r.reason); send new SepOff() via sepCommands; send new LowGainSelect() via telecomCommands; send new LoadShed() via powerCommands; send new LoadShed() via thermalCommands; send new CaptureDisarm() via captureCommands; send new SequenceAbort() via autonomyCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"safe mode\") via events; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E15", "recover: send new SepStandby() via sepCommands; send new HighGainSelect() via telecomCommands; send new LoadRestore() via powerCommands; send new LoadRestore() via thermalCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"safe mode exit\") via events; dispatched := dispatched + 1"}, {"MODE_MANAGEMENT_DISPATCHER_E16", "abortHold: send new AbortReturn(reason = a.reason); send new SepOff() via sepCommands; send new HighGainSelect() via telecomCommands; send new SequenceAbort() via autonomyCommands; send new ApplicationReport(application = \"ModeManagementApplication\", report = \"abort hold\") via events; dispatched := dispatched + 1"}},
}

var FdirSupervisor = StateMachine{
	"FdirSupervisor", "TethysFdir::FdirSupervisor", "",
	[]State{
		{"commandLossTimer", "TethysFdir::FdirSupervisor::commandLossTimer", "", "TethysFdir::FdirSupervisor::commandLossTimer::armed", false, "", ""},
		{"armed", "TethysFdir::FdirSupervisor::commandLossTimer::armed", "TethysFdir::FdirSupervisor::commandLossTimer", "", true, "", ""},
		{"expired", "TethysFdir::FdirSupervisor::commandLossTimer::expired", "TethysFdir::FdirSupervisor::commandLossTimer", "", true, "callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = \"command-loss timer expired\")", ""},
		{"thrusterHealth", "TethysFdir::FdirSupervisor::thrusterHealth", "", "TethysFdir::FdirSupervisor::thrusterHealth::nominal", false, "", ""},
		{"nominal", "TethysFdir::FdirSupervisor::thrusterHealth::nominal", "TethysFdir::FdirSupervisor::thrusterHealth", "", true, "", ""},
		{"restarting", "TethysFdir::FdirSupervisor::thrusterHealth::restarting", "TethysFdir::FdirSupervisor::thrusterHealth", "", true, "", ""},
		{"onSpare", "TethysFdir::FdirSupervisor::thrusterHealth::onSpare", "TethysFdir::FdirSupervisor::thrusterHealth", "", true, "", ""},
		{"stringLost", "TethysFdir::FdirSupervisor::thrusterHealth::stringLost", "TethysFdir::FdirSupervisor::thrusterHealth", "", true, "callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = \"thruster string lost: operating set not available\")", ""},
		{"ppuHealth", "TethysFdir::FdirSupervisor::ppuHealth", "", "TethysFdir::FdirSupervisor::ppuHealth::nominal", false, "", ""},
		{"nominal", "TethysFdir::FdirSupervisor::ppuHealth::nominal", "TethysFdir::FdirSupervisor::ppuHealth", "", true, "", ""},
		{"crossStrapped", "TethysFdir::FdirSupervisor::ppuHealth::crossStrapped", "TethysFdir::FdirSupervisor::ppuHealth", "", true, "", ""},
		{"ppuLost", "TethysFdir::FdirSupervisor::ppuHealth::ppuLost", "TethysFdir::FdirSupervisor::ppuHealth", "", true, "callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = \"second PPU trip: thrust profile replan needed\")", ""},
		{"powerHealth", "TethysFdir::FdirSupervisor::powerHealth", "", "TethysFdir::FdirSupervisor::powerHealth::nominal", false, "", ""},
		{"nominal", "TethysFdir::FdirSupervisor::powerHealth::nominal", "TethysFdir::FdirSupervisor::powerHealth", "", true, "", ""},
		{"loadShed", "TethysFdir::FdirSupervisor::powerHealth::loadShed", "TethysFdir::FdirSupervisor::powerHealth", "", true, "callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = \"battery state of charge below load-shed fraction\")", ""},
		{"attitudeHealth", "TethysFdir::FdirSupervisor::attitudeHealth", "", "TethysFdir::FdirSupervisor::attitudeHealth::nominal", false, "", ""},
		{"nominal", "TethysFdir::FdirSupervisor::attitudeHealth::nominal", "TethysFdir::FdirSupervisor::attitudeHealth", "", true, "", ""},
		{"sunAcquisition", "TethysFdir::FdirSupervisor::attitudeHealth::sunAcquisition", "TethysFdir::FdirSupervisor::attitudeHealth", "", true, "callSafe: safeModeRequests := safeModeRequests + 1; send new SafeModeRequest(reason = \"attitude loss\")", ""},
		{"earthImpactExclusion", "TethysFdir::FdirSupervisor::earthImpactExclusion", "", "TethysFdir::FdirSupervisor::earthImpactExclusion::monitoring", false, "", ""},
		{"monitoring", "TethysFdir::FdirSupervisor::earthImpactExclusion::monitoring", "TethysFdir::FdirSupervisor::earthImpactExclusion", "", true, "", ""},
		{"aborted", "TethysFdir::FdirSupervisor::earthImpactExclusion::aborted", "TethysFdir::FdirSupervisor::earthImpactExclusion", "", true, "send new AbortReturn(reason = \"Earth-impact exclusion violated\")", ""},
	},
	[]Transition{
		{"TethysFdir::FdirSupervisor::commandLossTimer::armed", "TethysFdir::FdirSupervisor::commandLossTimer::armed", "GroundContact", "", "command", "", "", "", "TethysFdir::FdirSupervisor::commandLossTimer", 129},
		{"TethysFdir::FdirSupervisor::commandLossTimer::armed", "TethysFdir::FdirSupervisor::commandLossTimer::armed", "ProcessorReset", "", "command", "", "", "", "TethysFdir::FdirSupervisor::commandLossTimer", 130},
		{"TethysFdir::FdirSupervisor::commandLossTimer::armed", "TethysFdir::FdirSupervisor::commandLossTimer::expired", "", "", "", "after limits.commandLossTimeout", "", "", "TethysFdir::FdirSupervisor::commandLossTimer", 131},
		{"TethysFdir::FdirSupervisor::commandLossTimer::expired", "TethysFdir::FdirSupervisor::commandLossTimer::armed", "GroundContact", "", "command", "", "", "", "TethysFdir::FdirSupervisor::commandLossTimer", 132},
		{"TethysFdir::FdirSupervisor::thrusterHealth::nominal", "TethysFdir::FdirSupervisor::thrusterHealth::restarting", "ThrusterFlameout", "f", "command", "", "FDIR_SUPERVISOR_G1", "FDIR_SUPERVISOR_E1", "TethysFdir::FdirSupervisor::thrusterHealth", 149},
		{"TethysFdir::FdirSupervisor::thrusterHealth::restarting", "TethysFdir::FdirSupervisor::thrusterHealth::nominal", "", "", "", "after limits.thrusterRestartDelay", "", "", "TethysFdir::FdirSupervisor::thrusterHealth", 151},
		{"TethysFdir::FdirSupervisor::thrusterHealth::nominal", "TethysFdir::FdirSupervisor::thrusterHealth::onSpare", "ThrusterFlameout", "f", "command", "", "FDIR_SUPERVISOR_G2", "FDIR_SUPERVISOR_E2", "TethysFdir::FdirSupervisor::thrusterHealth", 152},
		{"TethysFdir::FdirSupervisor::thrusterHealth::onSpare", "TethysFdir::FdirSupervisor::thrusterHealth::stringLost", "ThrusterFlameout", "f", "command", "", "", "FDIR_SUPERVISOR_E2", "TethysFdir::FdirSupervisor::thrusterHealth", 154},
		{"TethysFdir::FdirSupervisor::ppuHealth::nominal", "TethysFdir::FdirSupervisor::ppuHealth::crossStrapped", "PpuTrip", "", "command", "", "", "FDIR_SUPERVISOR_E3", "TethysFdir::FdirSupervisor::ppuHealth", 171},
		{"TethysFdir::FdirSupervisor::ppuHealth::crossStrapped", "TethysFdir::FdirSupervisor::ppuHealth::ppuLost", "PpuTrip", "", "command", "", "", "FDIR_SUPERVISOR_E3", "TethysFdir::FdirSupervisor::ppuHealth", 172},
		{"TethysFdir::FdirSupervisor::powerHealth::nominal", "TethysFdir::FdirSupervisor::powerHealth::loadShed", "BatteryLow", "b", "command", "", "FDIR_SUPERVISOR_G3", "", "TethysFdir::FdirSupervisor::powerHealth", 186},
		{"TethysFdir::FdirSupervisor::powerHealth::loadShed", "TethysFdir::FdirSupervisor::powerHealth::nominal", "SafeModeExit", "", "command", "", "", "", "TethysFdir::FdirSupervisor::powerHealth", 187},
		{"TethysFdir::FdirSupervisor::attitudeHealth::nominal", "TethysFdir::FdirSupervisor::attitudeHealth::sunAcquisition", "AttitudeLoss", "", "command", "", "", "", "TethysFdir::FdirSupervisor::attitudeHealth", 201},
		{"TethysFdir::FdirSupervisor::attitudeHealth::sunAcquisition", "TethysFdir::FdirSupervisor::attitudeHealth::nominal", "SafeModeExit", "", "command", "", "", "", "TethysFdir::FdirSupervisor::attitudeHealth", 202},
		{"TethysFdir::FdirSupervisor::earthImpactExclusion::monitoring", "TethysFdir::FdirSupervisor::earthImpactExclusion::monitoring", "TrajectoryUpdate", "t", "command", "", "FDIR_SUPERVISOR_G4", "FDIR_SUPERVISOR_E4", "TethysFdir::FdirSupervisor::earthImpactExclusion", 214},
		{"TethysFdir::FdirSupervisor::earthImpactExclusion::monitoring", "TethysFdir::FdirSupervisor::earthImpactExclusion::aborted", "TrajectoryUpdate", "t", "command", "", "FDIR_SUPERVISOR_G5", "FDIR_SUPERVISOR_E4", "TethysFdir::FdirSupervisor::earthImpactExclusion", 218},
		{"TethysFdir::FdirSupervisor::earthImpactExclusion::aborted", "TethysFdir::FdirSupervisor::earthImpactExclusion::monitoring", "SafeModeExit", "", "command", "", "", "", "TethysFdir::FdirSupervisor::earthImpactExclusion", 222},
	},
	[]NamedExpression{{"FDIR_SUPERVISOR_G1", "flameoutRetries < limits.maximumFlameoutRetries"}, {"FDIR_SUPERVISOR_G2", "flameoutRetries >= limits.maximumFlameoutRetries"}, {"FDIR_SUPERVISOR_G3", "b.stateOfCharge < limits.batteryLowFraction"}, {"FDIR_SUPERVISOR_G4", "t.earthClosestApproach > limits.earthExclusionRadius and t.impactProbability <= limits.maximumImpactProbability"}, {"FDIR_SUPERVISOR_G5", "t.earthClosestApproach <= limits.earthExclusionRadius or t.impactProbability > limits.maximumImpactProbability"}},
	[]NamedExpression{{"FDIR_SUPERVISOR_E1", "flameoutRetries := flameoutRetries + 1"}, {"FDIR_SUPERVISOR_E2", "healthyThrusters := healthyThrusters - 1"}, {"FDIR_SUPERVISOR_E3", "ppuTrips := ppuTrips + 1"}, {"FDIR_SUPERVISOR_E4", "record: lastEarthClosestApproach := t.earthClosestApproach; lastImpactProbability := t.impactProbability"}},
}

var FdirResponseRelay = StateMachine{
	"FdirResponseRelay", "TethysFlightBehaviour::FdirSoftware::responseRelay", "TethysFlightBehaviour::FdirSoftware::responseRelay::relaying",
	[]State{
		{"relaying", "TethysFlightBehaviour::FdirSoftware::responseRelay::relaying", "", "", true, "", ""},
	},
	[]Transition{
		{"TethysFlightBehaviour::FdirSoftware::responseRelay::relaying", "TethysFlightBehaviour::FdirSoftware::responseRelay::relaying", "SafeModeRequest", "r", "", "", "", "FDIR_RESPONSE_RELAY_E1", "", 608},
		{"TethysFlightBehaviour::FdirSoftware::responseRelay::relaying", "TethysFlightBehaviour::FdirSoftware::responseRelay::relaying", "AbortReturn", "a", "", "", "", "FDIR_RESPONSE_RELAY_E2", "", 612},
	},
	[]NamedExpression{},
	[]NamedExpression{{"FDIR_RESPONSE_RELAY_E1", "relaySafeMode: send new SafeModeRequest(reason = r.reason) via supervisorRequests; relayed := relayed + 1"}, {"FDIR_RESPONSE_RELAY_E2", "relayAbort: send new AbortReturn(reason = a.reason) via supervisorRequests; relayed := relayed + 1"}},
}

var StateMachines = []StateMachine{SepStringController, PowerManager, ThermalController, TelecomManager, InspectorHandler, CaptureController, RedundancyManager, BootUpdateManager, TugModes, ModeManagementDispatcher, FdirSupervisor, FdirResponseRelay}
