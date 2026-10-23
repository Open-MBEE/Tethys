// Argent flight software tables. Generated; edit the model or the generator, not this file.
// Generator: software/gen/generate.py 1.0.0
// Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
// Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
// Source elements:
//   TethysModes::TugModeTable
//   TethysModes::SubsystemConfiguration
//   TethysFlightSoftware::ArgentFlightSoftware (Application parts)
//   TethysSoftwareIcds::SpaceLinkProfileIcd (LinkRateSet rows)
//   TethysFlightTiming::argentBus

package argenttables

type ModeRow struct {
	Index              int
	Mode               string
	Flags              map[string]bool
	ActiveApplications []string
	RateSet            string
	BusSlotsUsed       int
}

var ModeTable = []ModeRow{
	{0, "launch", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": false, "highVoltageBusOn": false, "proximityLinkOn": false, "sensorsOn": false, "sepThrusting": false, "wheelControl": false}, []string{}, "launchRates", 0},
	{1, "earlyOperations", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": false, "highVoltageBusOn": false, "proximityLinkOn": false, "sensorsOn": false, "sepThrusting": false, "wheelControl": true}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "earlyOperationsRates", 32},
	{2, "coast", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": true, "highVoltageBusOn": false, "proximityLinkOn": false, "sensorsOn": false, "sepThrusting": false, "wheelControl": true}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "coastRates", 32},
	{3, "thrust", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": false, "highVoltageBusOn": true, "proximityLinkOn": false, "sensorsOn": false, "sepThrusting": true, "wheelControl": true}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "thrustRates", 32},
	{4, "approach", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": true, "highVoltageBusOn": true, "proximityLinkOn": false, "sensorsOn": true, "sepThrusting": true, "wheelControl": true}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "approachRates", 32},
	{5, "proximityOperations", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": true, "highVoltageBusOn": false, "proximityLinkOn": true, "sensorsOn": true, "sepThrusting": false, "wheelControl": false}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "captureControl", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "proximityOperationsRates", 36},
	{6, "retreat", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": true, "highVoltageBusOn": false, "proximityLinkOn": true, "sensorsOn": true, "sepThrusting": false, "wheelControl": false}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "retreatRates", 32},
	{7, "capture", map[string]bool{"captureSystemArmed": true, "highGainAntennaOn": false, "highVoltageBusOn": false, "proximityLinkOn": true, "sensorsOn": true, "sepThrusting": false, "wheelControl": false}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "captureControl", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "captureRates", 36},
	{8, "despin", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": false, "highVoltageBusOn": false, "proximityLinkOn": false, "sensorsOn": false, "sepThrusting": false, "wheelControl": false}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "captureControl", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "despinRates", 36},
	{9, "stackCoast", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": true, "highVoltageBusOn": false, "proximityLinkOn": false, "sensorsOn": false, "sepThrusting": false, "wheelControl": true}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "stackCoastRates", 32},
	{10, "stackThrust", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": false, "highVoltageBusOn": true, "proximityLinkOn": false, "sensorsOn": false, "sepThrusting": true, "wheelControl": true}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "stackThrustRates", 32},
	{11, "droHold", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": true, "highVoltageBusOn": false, "proximityLinkOn": false, "sensorsOn": false, "sepThrusting": false, "wheelControl": true}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "droHoldRates", 32},
	{12, "dockedPassive", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": true, "highVoltageBusOn": false, "proximityLinkOn": true, "sensorsOn": false, "sepThrusting": false, "wheelControl": false}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "dockedPassiveRates", 32},
	{13, "disposal", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": false, "highVoltageBusOn": true, "proximityLinkOn": false, "sensorsOn": false, "sepThrusting": true, "wheelControl": true}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "disposalRates", 32},
	{14, "safe", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": false, "highVoltageBusOn": false, "proximityLinkOn": false, "sensorsOn": false, "sepThrusting": false, "wheelControl": false}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "safeRates", 32},
	{15, "abortHold", map[string]bool{"captureSystemArmed": false, "highGainAntennaOn": true, "highVoltageBusOn": false, "proximityLinkOn": false, "sensorsOn": false, "sepThrusting": false, "wheelControl": true}, []string{"cdh", "gnc", "sepControl", "powerManagement", "thermalControl", "telecom", "inspectorHandling", "autonomy", "fdir", "modeManagement", "parameterBootUpdate"}, "abortHoldRates", 32},
}

type Application struct {
	Name        string
	Definition  string
	RateHz      *float64
	Priority    int
	Layer       string
	Criticality string
	ActiveModes []string
}

var Applications = []Application{
	{"cdh", "CdhApplication", F(1.0), 2, "application", "missionCritical", []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"gnc", "GncApplication", F(16.0), 3, "application", "safetyCritical", []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"sepControl", "SepControlApplication", F(1.0), 5, "application", "missionCritical", []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"powerManagement", "PowerManagementApplication", F(1.0), 4, "application", "missionCritical", []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"thermalControl", "ThermalControlApplication", F(1.0), 8, "application", "missionCritical", []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"telecom", "TelecomApplication", F(1.0), 6, "application", "missionCritical", []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"inspectorHandling", "InspectorHandlingApplication", F(1.0), 9, "application", "missionCritical", []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"captureControl", "CaptureControlApplication", F(16.0), 7, "application", "safetyCritical", []string{"proximityOperations", "capture", "despin"}},
	{"autonomy", "AutonomyApplication", F(1.0), 11, "application", "safetyCritical", []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"fdir", "FdirApplication", F(16.0), 1, "application", "safetyCritical", []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"modeManagement", "ModeManagementApplication", F(1.0), 1, "application", "safetyCritical", []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"parameterBootUpdate", "ParameterBootUpdateApplication", F(1.0), 12, "application", "missionCritical", []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
}

var ModeFlagNames = []string{"captureSystemArmed", "highGainAntennaOn", "highVoltageBusOn", "proximityLinkOn", "sensorsOn", "sepThrusting", "wheelControl"}

const ModeRowCount = 16
