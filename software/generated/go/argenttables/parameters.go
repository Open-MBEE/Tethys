// Argent flight software tables. Generated; edit the model or the generator, not this file.
// Generator: software/gen/generate.py 1.0.0
// Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
// Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
// Source elements:
//   TethysFlightDictionary::flightDictionary::parameterTables
//   TethysFlightDictionary::ParameterRow
//   TethysFlightDictionary::flightLimitTable
//   TethysFlightDictionary::tableLimits
//   TethysFdir::cruiseLimits
//   TethysFdir::FaultEvent

package argenttables

type Parameter struct {
	ID      int
	Name    string
	Owner   string
	TableID int
	Value   float64
	Minimum float64
	Maximum float64
	Unit    string
}

var Parameters = []Parameter{
	{1, "watchdogPeriod", "cdh", 1, 5.0, 0.1, 30.0, "s"},
	{2, "recorderHighWater", "cdh", 1, 0.9, 0.5, 0.99, "1"},
	{3, "clockSlewLimit", "cdh", 1, 1.0, 0.01, 10.0, "s"},
	{4, "downlinkQueueDepth", "cdh", 1, 64.0, 8.0, 512.0, "1"},
	{5, "slewRateLimit", "gnc", 2, 0.01, 0.0001, 0.02, "rad/s"},
	{6, "pointingTolerance", "gnc", 2, 0.001, 0.0001, 0.1, "rad"},
	{7, "wheelSpeedLimit", "gnc", 2, 600.0, 100.0, 650.0, "rad/s"},
	{8, "desatThreshold", "gnc", 2, 0.8, 0.5, 0.95, "1"},
	{9, "throttleMinimum", "sepControl", 3, 0.2, 0.1, 0.5, "1"},
	{10, "restartDelay", "sepControl", 3, 7200.0, 60.0, 86400.0, "s"},
	{11, "dischargeTrip", "sepControl", 3, 32.0, 5.0, 40.0, "A"},
	{12, "tankHeaterSetpoint", "sepControl", 3, 293.0, 273.0, 323.0, "K"},
	{13, "endOfChargeVoltage", "powerManagement", 4, 33.0, 28.0, 33.6, "V"},
	{14, "busLowTrip", "powerManagement", 4, 26.0, 24.0, 28.0, "V"},
	{15, "busHighTrip", "powerManagement", 4, 30.0, 28.0, 32.0, "V"},
	{16, "loadShedSoc", "powerManagement", 4, 0.3, 0.1, 0.6, "1"},
	{17, "deadband", "thermalControl", 5, 2.0, 0.5, 10.0, "K"},
	{18, "survivalLow", "thermalControl", 5, 243.0, 233.0, 283.0, "K"},
	{19, "survivalHigh", "thermalControl", 5, 253.0, 243.0, 293.0, "K"},
	{20, "heaterPowerCap", "thermalControl", 5, 800.0, 50.0, 900.0, "W"},
	{21, "defaultDownlinkRate", "telecom", 6, 2000000.0, 10.0, 4000000.0, "Hz"},
	{22, "defaultUplinkRate", "telecom", 6, 2000.0, 7.8125, 4000.0, "Hz"},
	{23, "hgaSlewLimit", "telecom", 6, 0.005, 0.0001, 0.02, "rad/s"},
	{24, "transmitPower", "telecom", 6, 60.0, 5.0, 100.0, "W"},
	{25, "releaseSpeed", "inspectorHandling", 7, 0.05, 0.02, 0.2, "m/s"},
	{26, "imagingCadence", "inspectorHandling", 7, 10.0, 1.0, 600.0, "s"},
	{27, "relayRate", "inspectorHandling", 7, 1000000.0, 1000.0, 2000000.0, "Hz"},
	{28, "contactTimeout", "inspectorHandling", 7, 7200.0, 600.0, 86400.0, "s"},
	{29, "approachRateLimit", "captureControl", 8, 0.1, 0.01, 0.5, "m/s"},
	{30, "contactForceLimit", "captureControl", 8, 200.0, 1.0, 500.0, "N"},
	{31, "cinchTension", "captureControl", 8, 1000.0, 10.0, 2000.0, "N"},
	{32, "despinTorqueLimit", "captureControl", 8, 0.5, 0.0, 1.0, "1"},
	{33, "planHorizon", "autonomy", 9, 86400.0, 3600.0, 604800.0, "s"},
	{34, "autonomyLevel", "autonomy", 9, 1.0, 0.0, 3.0, "1"},
	{35, "waypointHoldDefault", "autonomy", 9, 600.0, 0.0, 86400.0, "s"},
	{36, "ruleCooldown", "autonomy", 9, 60.0, 1.0, 3600.0, "s"},
	{37, "commandLossTimeout", "fdir", 10, 604800.0, 3600.0, 2592000.0, "s"},
	{38, "flameoutRetries", "fdir", 10, 2.0, 0.0, 5.0, "1"},
	{39, "batteryLowFraction", "fdir", 10, 0.3, 0.1, 0.6, "1"},
	{40, "impactProbabilityLimit", "fdir", 10, 0.0001, 1e-07, 0.001, "1"},
	{41, "transitionTimeout", "modeManagement", 11, 300.0, 1.0, 3600.0, "s"},
	{42, "twoStepWindow", "modeManagement", 11, 600.0, 10.0, 3600.0, "s"},
	{43, "modeTableId", "modeManagement", 11, 11.0, 0.0, 11.0, "1"},
	{44, "autoTransitionDefault", "modeManagement", 11, 1.0, 0.0, 1.0, "1"},
	{45, "stagingBufferSize", "parameterBootUpdate", 12, 65536.0, 4096.0, 65536.0, "1"},
	{46, "bootRetryLimit", "parameterBootUpdate", 12, 3.0, 1.0, 5.0, "1"},
	{47, "eepromCycleLimit", "parameterBootUpdate", 12, 100000.0, 1000.0, 100000.0, "1"},
	{48, "tableCount", "parameterBootUpdate", 12, 12.0, 1.0, 12.0, "1"},
}

type ParameterTable struct {
	TableID int
	Owner   string
	Item    string
	RowIDs  []int
}

var ParameterTables = []ParameterTable{
	{1, "cdh", "TethysFlightDictionary::cdhParameterTable", []int{1, 2, 3, 4}},
	{2, "gnc", "TethysFlightDictionary::gncParameterTable", []int{5, 6, 7, 8}},
	{3, "sepControl", "TethysFlightDictionary::sepParameterTable", []int{9, 10, 11, 12}},
	{4, "powerManagement", "TethysFlightDictionary::epsParameterTable", []int{13, 14, 15, 16}},
	{5, "thermalControl", "TethysFlightDictionary::thmParameterTable", []int{17, 18, 19, 20}},
	{6, "telecom", "TethysFlightDictionary::comParameterTable", []int{21, 22, 23, 24}},
	{7, "inspectorHandling", "TethysFlightDictionary::insParameterTable", []int{25, 26, 27, 28}},
	{8, "captureControl", "TethysFlightDictionary::capParameterTable", []int{29, 30, 31, 32}},
	{9, "autonomy", "TethysFlightDictionary::autParameterTable", []int{33, 34, 35, 36}},
	{10, "fdir", "TethysFlightDictionary::fdrParameterTable", []int{37, 38, 39, 40}},
	{11, "modeManagement", "TethysFlightDictionary::modParameterTable", []int{41, 42, 43, 44}},
	{12, "parameterBootUpdate", "TethysFlightDictionary::pbuParameterTable", []int{45, 46, 47, 48}},
}

type Limit struct {
	Name  string
	Value float64
	Unit  string
}

var LimitTable = []Limit{
	{"commandLossTimeout", 7.0, "d"},
	{"thrusterRestartDelay", 2.0, "h"},
	{"maximumFlameoutRetries", 2.0, ""},
	{"batteryLowFraction", 0.3, ""},
	{"earthExclusionRadius", 63781.37, "km"},
	{"maximumImpactProbability", 0.0001, ""},
}

type MonitorLimit struct {
	LimitSet string
	Name     string
	Value    float64
	Unit     string
}

var MonitorLimits = []MonitorLimit{
	{"TethysFdir::cruiseLimits", "commandLossTimeout", 7.0, "d"},
	{"TethysFdir::cruiseLimits", "thrusterRestartDelay", 2.0, "h"},
	{"TethysFdir::cruiseLimits", "maximumFlameoutRetries", 2.0, ""},
	{"TethysFdir::cruiseLimits", "batteryLowFraction", 0.3, ""},
	{"TethysFdir::cruiseLimits", "earthExclusionRadius", 63781.37, "km"},
	{"TethysFdir::cruiseLimits", "maximumImpactProbability", 0.0001, ""},
	{"TethysFlightDictionary::tableLimits", "commandLossTimeout", 7.0, "d"},
	{"TethysFlightDictionary::tableLimits", "thrusterRestartDelay", 2.0, "h"},
	{"TethysFlightDictionary::tableLimits", "maximumFlameoutRetries", 2.0, ""},
	{"TethysFlightDictionary::tableLimits", "batteryLowFraction", 0.3, ""},
	{"TethysFlightDictionary::tableLimits", "earthExclusionRadius", 63781.37, "km"},
	{"TethysFlightDictionary::tableLimits", "maximumImpactProbability", 0.0001, ""},
}

type FaultEventType struct {
	Name   string
	Fields [][2]string
}

var FaultEventTypes = []FaultEventType{
	{"ThrusterFlameout", [][2]string{{"thrusterId", "ScalarValues::Natural"}}},
	{"PpuTrip", [][2]string{{"ppuId", "ScalarValues::Natural"}}},
	{"AttitudeLoss", [][2]string{}},
	{"BatteryLow", [][2]string{{"stateOfCharge", "ScalarValues::Real"}}},
	{"ProcessorReset", [][2]string{}},
}

const LimitTableID = 13
const ParameterCount = 48
