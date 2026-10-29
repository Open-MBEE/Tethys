// Argent flight software tables. Generated; edit the model or the generator, not this file.
// Generator: software/gen/generate.py 1.0.0
// Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
// Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
// Source elements:
//   TethysOperations::noThrustDuringRelay … batteryDepthOfDischarge (FR-001 … FR-004) and their constraint definitions
//   TethysSequence::OnBoardSequence specialisations
//   TethysGroundSoftware::GroundSequenceCheck, FlightRuleChecker, CheckFlightRules
//   TethysTugStructure::allFlightModes, thrustingModes
//   TethysGroundSoftware::MeridianOperationsSuite (components)
//   TethysGroundSoftware::DataArchive, ProximityPlanner, PassPlanner, PlannedDailyPassPlan
//   TethysMeridian::MeridianNetwork
//   TethysOperations::DailyPassPlan
//   TethysGroundSoftware::AlarmLifecycle, AnomalyLifecycle
//   TethysGroundSoftware::CommandVerdict, SequenceVerdict, AlarmSeverity, AnomalyDisposition, DecisionAuthority

package argenttables

type Quantity struct {
	Value float64
	Unit  string
}

// CommandVerdict is TethysGroundSoftware::CommandVerdict.
type CommandVerdict int

const (
	CommandVerdictAccepted               CommandVerdict = 0
	CommandVerdictUnknownOpcode          CommandVerdict = 1
	CommandVerdictArgumentOutOfRange     CommandVerdict = 2
	CommandVerdictModeNotAllowed         CommandVerdict = 3
	CommandVerdictAwaitingSecondApproval CommandVerdict = 4
)

var CommandVerdictNames = [5]string{"accepted", "unknownOpcode", "argumentOutOfRange", "modeNotAllowed", "awaitingSecondApproval"}

// SequenceVerdict is TethysGroundSoftware::SequenceVerdict.
type SequenceVerdict int

const (
	SequenceVerdictPending SequenceVerdict = 0
	SequenceVerdictCleared SequenceVerdict = 1
	SequenceVerdictRefused SequenceVerdict = 2
)

var SequenceVerdictNames = [3]string{"pending", "cleared", "refused"}

// AlarmSeverity is TethysGroundSoftware::AlarmSeverity.
type AlarmSeverity int

const (
	AlarmSeverityNominal   AlarmSeverity = 0
	AlarmSeverityWarning   AlarmSeverity = 1
	AlarmSeverityViolation AlarmSeverity = 2
)

var AlarmSeverityNames = [3]string{"nominal", "warning", "violation"}

// AnomalyDisposition is TethysGroundSoftware::AnomalyDisposition.
type AnomalyDisposition int

const (
	AnomalyDispositionExplained       AnomalyDisposition = 0
	AnomalyDispositionProcedureChange AnomalyDisposition = 1
	AnomalyDispositionParameterChange AnomalyDisposition = 2
	AnomalyDispositionSoftwareFix     AnomalyDisposition = 3
)

var AnomalyDispositionNames = [4]string{"explained", "procedureChange", "parameterChange", "softwareFix"}

// DecisionAuthority is TethysGroundSoftware::DecisionAuthority.
type DecisionAuthority int

const (
	DecisionAuthorityFlightDirector DecisionAuthority = 0
	DecisionAuthorityAnomalyBoard   DecisionAuthority = 1
	DecisionAuthorityMissionManager DecisionAuthority = 2
)

var DecisionAuthorityNames = [3]string{"flightDirector", "anomalyBoard", "missionManager"}

type RuleParameter struct {
	Name  string
	Value float64
	Unit  string
}

type FlightRule struct {
	ID         string
	Name       string
	Item       string
	Text       string
	Constraint string
	Expression string
	Inputs     []string
	Parameters []RuleParameter
}

var FlightRules = []FlightRule{
	{"FR-001", "noThrustDuringRelay", "TethysOperations::noThrustDuringRelay", "The flight system shall not thrust while the proximity link is active.", "TethysOperations::NoThrustDuringRelay", "not (thrusting and relayActive)", []string{"thrusting", "relayActive"}, []RuleParameter{}},
	{"FR-002", "approachKeepOut", "TethysOperations::approachKeepOut", "The tug shall remain outside the 500 m keep-out sphere until a capture sequence is loaded and authorised.", "TethysOperations::ApproachKeepOut", "rangeToTarget >= keepOutRadius or approachAuthorised", []string{"rangeToTarget", "keepOutRadius", "approachAuthorised"}, []RuleParameter{{"keepOutRadius", 500.0, "m"}}},
	{"FR-003", "sunExclusion", "TethysOperations::sunExclusion", "The imager boresight shall stay more than 25\u00b0 from the Sun while its cover is open.", "TethysOperations::SunExclusion", "sunAngle >= exclusionHalfAngle or not coverOpen", []string{"sunAngle", "exclusionHalfAngle", "coverOpen"}, []RuleParameter{{"exclusionHalfAngle", 25.0, "'\u00b0'"}}},
	{"FR-004", "batteryDepthOfDischarge", "TethysOperations::batteryDepthOfDischarge", "Battery state of charge shall not fall below 40 % in any planned activity.", "TethysOperations::BatteryDepthOfDischarge", "stateOfCharge >= 0.4", []string{"stateOfCharge"}, []RuleParameter{{"stateOfChargeFloor", 0.4, ""}}},
}

type OnBoardSequence struct {
	SequenceID int
	Name       string
	Item       string
	TimeTagged bool
	Text       string
}

var OnBoardSequences = []OnBoardSequence{
	{1, "ThrustArc", "TethysSequence::ThrustArc", true, "One thrust arc: the SEP string thrusts for the arc's duration at the given thrust and burns the xenon that duration implies; the result is the xenon left."},
	{2, "DespinSequence", "TethysSequence::DespinSequence", true, "Despin the captured stack with the hydrazine thrusters: each pulse train lengthens the spin period by a fixed factor until the period is above the threshold at which the wheels take over."},
	{3, "InspectorReleaseSequence", "TethysSequence::InspectorReleaseSequence", true, "The inspector release as a timed go/no-go sequence: checkout, umbilical disconnect, a hold for the ground go, then release \u2014 each step gated by the state the previous one must have reached."},
	{4, "DroInsertionSequence", "TethysSequence::DroInsertionSequence", true, "The insertion into the distant retrograde orbit after the lunar assist: the post-assist trajectory is checked against the insertion corridor, the insertion arc is executed, and a miss leaves the stack in the backup heliocentric loiter orbit rather than in cislunar space. The arc length is an owned attribute, not a parameter: see docs/findings/WP-E.md F-E02."},
	{5, "DroStationKeeping", "TethysSequence::DroStationKeeping", true, "The DRO checkout's station-keeping demonstration: hydrazine trims are repeated until the along-track drift is inside the control box, then the three demonstration cycles of the checkout plan are costed."},
	{6, "MissionSequence", "TethysSequence::MissionSequence", true, "The flight from lift-off to disposal as an executable action over the phases of TethysMission::flightTimeline. The clock runs in days; the thrust arcs are loops counted against the arc plan; the capture commit is a decision over the delivered target estimate and the capture envelope, and a refused commit ends the mission in a retreat hold (`terminate`). The lunar assist is waited for as a timed event (`accept at` a clock instant scheduled after the return arcs)."},
}

const SequenceCheckSource = "TethysGroundSoftware::GroundSequenceCheck"

var StoredSequences = []int{1, 2, 3, 4, 5, 6}

var CheckLimits = map[string]Quantity{"keepOutRadius": {500.0, "m"}, "exclusionHalfAngle": {30.0, "'\u00b0'"}, "stateOfChargeFloor": {0.4, ""}}

var FlightModes = []string{"earlyOperations", "thrust", "approach", "stackThrust", "disposal", "coast", "stackCoast", "dockedPassive", "proximityOperations", "retreat", "capture", "despin", "droHold", "safe", "abortHold"}

var ThrustingModes = []string{"thrust", "approach", "stackThrust", "disposal"}

var CheckReasons = []string{"FR-001 thrust during a relay pass", "FR-002 inside the keep-out sphere without authorisation", "FR-003 sun inside the exclusion cone with the cover open", "FR-004 battery below the depth-of-discharge floor", "planned mode is not a flight mode", "none"}

type GroundComponent struct {
	SuitePart               string
	Part                    string
	Path                    string
	Definition              string
	ProductName             string
	Version                 string
	Simulator               bool
	FlightSoftwareInTheLoop bool
	HardwareInTheLoop       bool
	Text                    string
}

var GroundComponents = []GroundComponent{
	{"moc", "commandBuilder", "moc.commandBuilder", "TethysGroundSoftware::CommandBuilder", "Meridian Forge", "3.2", false, false, false, "Meridian Forge, the command builder: every command is built from the flight dictionary and validated by ValidateCommand before it is packed as a CommandPacket for the uplink queue; hazardous commands wait for a second signature."},
	{"moc", "sequencer", "moc.sequencer", "TethysGroundSoftware::FlightRuleChecker", "Meridian Warden", "2.5", false, false, false, "Meridian Warden, the sequencer and flight-rule checker: every planned sequence is loaded, checked against FR-001 to FR-004 and either released to the uplink queue as a LoadSequence command or refused. The release is a send from this part's own port inside its performed action, the form the pinned runtime routes."},
	{"moc", "telemetryServer", "moc.telemetryServer", "TethysGroundSoftware::TelemetryServer", "Meridian Lantern", "5.0", false, false, false, "Meridian Lantern, the telemetry server: synchronises the transfer frames the gateway forwards, decommutates every dictionary packet by its PacketDefinition layout, converts to engineering units, checks the dictionary limits and the FDIR limit table, raises alarms and trends the resource points."},
	{"moc", "passPlanner", "moc.passPlanner", "TethysGroundSoftware::PassPlanner", "Meridian Almanac", "1.9", false, false, false, "Meridian Almanac, the pass planner: from the stations' visibility of the tug and the MLS-2 rate set of the planned mode it allocates the day's passes, resolves the conflicts between the three stations and the relay windows, and writes the DailyPassPlan the operations model flies."},
	{"moc", "anomalyTracker", "moc.anomalyTracker", "TethysGroundSoftware::AnomalyTracker", "Meridian Ledger", "2.3", false, false, false, "Meridian Ledger, the anomaly tracker: every alarm or fault event the telemetry server raises opens an anomaly, the console answers it with the contingency procedures of the operations model, and the anomaly board dispositions it."},
	{"moc", "proximityPlanner", "moc.proximityPlanner", "TethysGroundSoftware::ProximityPlanner", "Meridian Compass", "1.4", false, false, false, "Meridian Compass, the proximity-operations planner: relative navigation products, the keep-out check of FR-002 on every planned approach, the go/no-go checklist and the abort criteria the capture sequence is uplinked with."},
	{"fdf", "flightDynamicsTool", "fdf.flightDynamicsTool", "TethysGroundSoftware::FlightDynamicsTool", "Meridian Sextant", "2.7", false, false, false, "Meridian Sextant, the flight dynamics tool: orbit determination of Argent and of Amaranth from the stations' tracking data, low-thrust arc and DRO insertion design, ephemeris products for the stations and the pass planner, and the delta-v ledger."},
	{"sds", "dataArchive", "sds.dataArchive", "TethysGroundSoftware::DataArchive", "Meridian Vault", "4.1", false, false, false, "Meridian Vault, the archive: catalogues every product level with a checksum, keeps each by its retention rule and distributes the released levels."},
	{"testBeds", "flatsat", "testBeds.flatsat", "TethysGroundSoftware::HardwareInTheLoopTestBed", "Meridian Anvil", "2.0", true, true, true, "Meridian Anvil: the flatsat's engineering-model avionics with the flight software, driven by the suite."},
	{"testBeds", "captureRig", "testBeds.captureRig", "TethysGroundSoftware::CaptureRigController", "Meridian Capstan", "1.2", true, false, true, "Meridian Capstan: the capture rig's control and data software."},
	{"testBeds", "dynamicsSimulator", "testBeds.dynamicsSimulator", "TethysGroundSoftware::DynamicsSimulator", "Meridian Orrery", "3.3", true, true, false, "Meridian Orrery: the six-degree-of-freedom proximity-operations simulator with the GNC flight code in the loop."},
	{"testBeds", "trajectoryTool", "testBeds.trajectoryTool", "TethysGroundSoftware::FlightSoftwareInTheLoopSimulator", "Meridian Mirror", "6.1", true, true, false, "Meridian Mirror: the flight software image running on an emulated flight computer with simulated dynamics, used for sequence and procedure validation."},
}

type RetentionRule struct {
	Rule        string
	Level       string
	Retention   float64
	Unit        string
	Distributed bool
}

var RetentionRules = []RetentionRule{
	{"l0Rule", "l0", 3650.0, "d", false},
	{"l1Rule", "l1", 3650.0, "d", true},
	{"l2Rule", "l2", 3650.0, "d", true},
	{"l3Rule", "l3", 3650.0, "d", true},
}

const ChecksumWidth = 32

type RelativeNavigationProduct struct {
	Name             string
	Range            Quantity
	RangeRate        Quantity
	RangeUncertainty Quantity
}

var ProximityProducts = []RelativeNavigationProduct{
	{"standoff", Quantity{2000.0, "m"}, Quantity{0.0, "'m/s'"}, Quantity{5.0, "m"}},
	{"finalApproach", Quantity{50.0, "m"}, Quantity{-0.05, "'m/s'"}, Quantity{0.5, "m"}},
}

var ProximityLimits = map[string]Quantity{"keep_out_radius": {500.0, "m"}, "abort_range_rate": {-0.2, "'m/s'"}, "abort_range_uncertainty": {2.0, "m"}}

const (
	ChecklistItemsTotal int = 12
	ChecklistItemsGo    int = 12
)

type Station struct {
	Name      string
	Longitude float64
	Unit      string
}

var Stations = []Station{
	{"caldera", -68.0, "'\u00b0'"},
	{"tableland", 52.0, "'\u00b0'"},
	{"saltmarsh", 172.0, "'\u00b0'"},
}

type StationPass struct {
	Name     string
	Station  string
	Duration float64
	Unit     string
}

var StationPasses = []StationPass{
	{"calderaPass", "caldera", 8.0, "h"},
	{"tablelandPass", "tableland", 8.0, "h"},
	{"saltmarshPass", "saltmarsh", 8.0, "h"},
}

type DownlinkActivity struct {
	Name   string
	Volume float64
	Unit   string
}

var DownlinkActivities = []DownlinkActivity{
	{"imageryDownlink", 11500000000.0, "bit"},
	{"housekeepingDownlink", 580000000.0, "bit"},
	{"radarDownlink", 11500000000.0, "bit"},
}

type PassAllocation struct {
	Name        string
	Activity    string
	StationPass string
}

var PassAllocations = []PassAllocation{
	{"imageryToCaldera", "imageryDownlink", "calderaPass"},
	{"housekeepingToTableland", "housekeepingDownlink", "tablelandPass"},
	{"radarToSaltmarsh", "radarDownlink", "saltmarshPass"},
}

var VisibilityHalfWidth = Quantity{65.0, "'\u00b0'"}

var LockUp = Quantity{300.0, "s"}

const (
	PlannedRateSet string = "proximityOperationsRates"
	PlannedMode    string = "proximityOperations"
)

var AlarmLifecycle = StateMachine{
	"AlarmLifecycle", "TethysGroundSoftware::AlarmLifecycle", "TethysGroundSoftware::AlarmLifecycle::quiet",
	[]State{
		{"quiet", "TethysGroundSoftware::AlarmLifecycle::quiet", "", "", true, "", ""},
		{"raised", "TethysGroundSoftware::AlarmLifecycle::raised", "", "", true, "", ""},
		{"acknowledged", "TethysGroundSoftware::AlarmLifecycle::acknowledged", "", "", true, "", ""},
	},
	[]Transition{
		{"TethysGroundSoftware::AlarmLifecycle::quiet", "TethysGroundSoftware::AlarmLifecycle::raised", "AlarmRaised", "", "", "", "", "", "", 264},
		{"TethysGroundSoftware::AlarmLifecycle::raised", "TethysGroundSoftware::AlarmLifecycle::acknowledged", "AlarmAcknowledge", "", "", "", "", "", "", 265},
		{"TethysGroundSoftware::AlarmLifecycle::acknowledged", "TethysGroundSoftware::AlarmLifecycle::quiet", "AlarmCleared", "", "", "", "", "", "", 266},
		{"TethysGroundSoftware::AlarmLifecycle::raised", "TethysGroundSoftware::AlarmLifecycle::quiet", "AlarmCleared", "", "", "", "", "", "", 267},
	},
	[]NamedExpression{},
	[]NamedExpression{},
}

var AnomalyLifecycle = StateMachine{
	"AnomalyLifecycle", "TethysGroundSoftware::AnomalyLifecycle", "TethysGroundSoftware::AnomalyLifecycle::opened",
	[]State{
		{"opened", "TethysGroundSoftware::AnomalyLifecycle::opened", "", "", true, "", ""},
		{"triaged", "TethysGroundSoftware::AnomalyLifecycle::triaged", "", "", true, "", ""},
		{"investigating", "TethysGroundSoftware::AnomalyLifecycle::investigating", "", "", true, "", ""},
		{"closed", "TethysGroundSoftware::AnomalyLifecycle::closed", "", "", true, "", ""},
	},
	[]Transition{
		{"TethysGroundSoftware::AnomalyLifecycle::opened", "TethysGroundSoftware::AnomalyLifecycle::triaged", "AnomalyTriaged", "", "", "", "", "", "", 441},
		{"TethysGroundSoftware::AnomalyLifecycle::triaged", "TethysGroundSoftware::AnomalyLifecycle::investigating", "AnomalyAssigned", "", "", "", "", "", "", 442},
		{"TethysGroundSoftware::AnomalyLifecycle::investigating", "TethysGroundSoftware::AnomalyLifecycle::closed", "AnomalyDispositioned", "", "", "", "", "", "", 443},
	},
	[]NamedExpression{},
	[]NamedExpression{},
}
