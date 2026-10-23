// Argent flight software tables. Generated; edit the model or the generator, not this file.
// Generator: software/gen/generate.py 1.0.0
// Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
// Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
// Source elements:
//   TethysFlightTiming::FlightTiming
//   TethysFlightTiming::argentTiming
//   TethysFlightTiming::ScheduledTask
//   TethysFlightSoftware::ArgentFlightSoftware::executive
//   TethysFlightTiming::argentBus

package argenttables

type RateGroup struct {
	Name                     string
	RateHz                   float64
	PeriodS                  float64
	ActivationsPerMajorFrame int
}

var RateGroups = []RateGroup{
	{"rg16", 16.0, 0.0625, 16},
	{"rg8", 8.0, 0.125, 8},
	{"rg2", 2.0, 0.5, 2},
	{"rg1", 1.0, 1.0, 1},
}

type Partition struct {
	Name        string
	WindowS     float64
	MemoryBytes float64
	Criticality string
	Restartable bool
}

var Partitions = []Partition{
	{"platformPartition", 0.25, 256000000.0, "safetyCritical", false},
	{"gncPartition", 0.25, 256000000.0, "safetyCritical", true},
	{"subsystemPartition", 0.25, 256000000.0, "missionCritical", true},
	{"autonomyPartition", 0.125, 128000000.0, "safetyCritical", true},
	{"payloadPartition", 0.125, 128000000.0, "nonCritical", true},
}

type ScheduledTask struct {
	Name         string
	Schedule     string
	Kind         string
	Component    string
	RateGroup    string
	WcetS        float64
	PeriodS      float64
	DeadlineS    float64
	FiringFrames []int
	ActiveModes  []string
}

var ScheduledTasks = []ScheduledTask{
	{"boardSupportTask", "platformSchedule", "ScheduledTask", "software.boardSupport", "rg16", 0.001, 0.0625, 0.0625, []int{0, 1, 2, 3, 4, 5, 6, 7}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"schedulerTask", "platformSchedule", "ScheduledTask", "software.scheduler", "rg16", 0.001, 0.0625, 0.0625, []int{0, 1, 2, 3, 4, 5, 6, 7}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"fdirTask", "platformSchedule", "ApplicationTask", "software.fdir", "rg16", 0.003, 0.0625, 0.0625, []int{0, 1, 2, 3, 4, 5, 6, 7}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"modeManagementTask", "platformSchedule", "ApplicationTask", "software.modeManagement", "rg8", 0.003, 0.125, 0.125, []int{0, 1, 2, 3, 4, 5, 6, 7}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"cdhTask", "platformSchedule", "ApplicationTask", "software.cdh", "rg8", 0.004, 0.125, 0.125, []int{0, 1, 2, 3, 4, 5, 6, 7}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"commandIngestTask", "platformSchedule", "ScheduledTask", "software.commandIngest", "rg8", 0.002, 0.125, 0.125, []int{0, 1, 2, 3, 4, 5, 6, 7}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"telemetryOutputTask", "platformSchedule", "ScheduledTask", "software.telemetryOutput", "rg8", 0.003, 0.125, 0.125, []int{0, 1, 2, 3, 4, 5, 6, 7}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"telecomTask", "platformSchedule", "ApplicationTask", "software.telecom", "rg8", 0.005, 0.125, 0.125, []int{0, 1, 2, 3, 4, 5, 6, 7}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"housekeepingTask", "platformSchedule", "ScheduledTask", "software.housekeeping", "rg1", 0.003, 1.0, 1.0, []int{0}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"timeTask", "platformSchedule", "ScheduledTask", "software.time", "rg1", 0.001, 1.0, 1.0, []int{1}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"eventTask", "platformSchedule", "ScheduledTask", "software.events", "rg1", 0.001, 1.0, 1.0, []int{2}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"tableTask", "platformSchedule", "ScheduledTask", "software.tables", "rg1", 0.001, 1.0, 1.0, []int{3}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"dataStoreTask", "platformSchedule", "ScheduledTask", "software.dataStore", "rg1", 0.002, 1.0, 1.0, []int{4}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"bootUpdateTask", "platformSchedule", "ScheduledTask", "software.bootUpdate", "rg1", 0.001, 1.0, 1.0, []int{5}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"parameterBootUpdateTask", "platformSchedule", "ApplicationTask", "software.parameterBootUpdate", "rg1", 0.004, 1.0, 1.0, []int{6}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"gncTask", "gncSchedule", "ApplicationTask", "software.gnc", "rg16", 0.012, 0.0625, 0.0625, []int{0, 1, 2, 3, 4, 5, 6, 7}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"sepControlTask", "gncSchedule", "ApplicationTask", "software.sepControl", "rg8", 0.005, 0.125, 0.125, []int{0, 1, 2, 3, 4, 5, 6, 7}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"powerManagementTask", "subsystemSchedule", "ApplicationTask", "software.powerManagement", "rg8", 0.005, 0.125, 0.125, []int{0, 1, 2, 3, 4, 5, 6, 7}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"thermalControlTask", "subsystemSchedule", "ApplicationTask", "software.thermalControl", "rg2", 0.006, 0.5, 0.5, []int{1, 5}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"autonomyTask", "autonomySchedule", "ApplicationTask", "software.autonomy", "rg8", 0.01, 0.125, 0.125, []int{0, 1, 2, 3, 4, 5, 6, 7}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"captureControlTask", "payloadSchedule", "ApplicationTask", "software.captureControl", "rg16", 0.006, 0.0625, 0.0625, []int{0, 1, 2, 3, 4, 5, 6, 7}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"inspectorHandlingTask", "payloadSchedule", "ApplicationTask", "software.inspectorHandling", "rg2", 0.003, 0.5, 0.5, []int{2, 6}, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
}

type FrameSlice struct {
	Name      string
	DurationS float64
}

type PartitionSchedule struct {
	Name      string
	Partition string
	Slices    []FrameSlice
	Tasks     []string
}

var PartitionSchedules = []PartitionSchedule{
	{"platformSchedule", "software.executive.platformPartition", []FrameSlice{{"sliceA", 0.015625}, {"sliceB", 0.015625}}, []string{"boardSupportTask", "schedulerTask", "fdirTask", "modeManagementTask", "cdhTask", "commandIngestTask", "telemetryOutputTask", "telecomTask", "housekeepingTask", "timeTask", "eventTask", "tableTask", "dataStoreTask", "bootUpdateTask", "parameterBootUpdateTask"}},
	{"gncSchedule", "software.executive.gncPartition", []FrameSlice{{"sliceA", 0.015625}, {"sliceB", 0.015625}}, []string{"gncTask", "sepControlTask"}},
	{"subsystemSchedule", "software.executive.subsystemPartition", []FrameSlice{{"slice", 0.03125}}, []string{"powerManagementTask", "thermalControlTask"}},
	{"autonomySchedule", "software.executive.autonomyPartition", []FrameSlice{{"slice", 0.015625}}, []string{"autonomyTask"}},
	{"payloadSchedule", "software.executive.payloadPartition", []FrameSlice{{"slice", 0.015625}}, []string{"captureControlTask", "inspectorHandlingTask"}},
}

type BusStream struct {
	Name               string
	Node               string
	SlotsPerFrame      int
	MessageLengthBytes float64
	ActiveModes        []string
}

var BusStreams = []BusStream{
	{"timeBroadcast", "broadcast", 1, 16.0, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"thermalPropulsionPoll", "thermal and propulsion unit", 2, 256.0, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"thermalPropulsionCommand", "thermal and propulsion unit", 1, 64.0, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"thermalZoneSweep", "thermal and propulsion unit", 1, 512.0, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"mechanismStatus", "mechanism unit", 1, 128.0, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"mechanismPoll", "mechanism unit", 2, 256.0, []string{"proximityOperations", "capture", "despin"}},
	{"mechanismCommand", "mechanism unit", 2, 64.0, []string{"proximityOperations", "capture", "despin"}},
	{"gncSensorPoll", "star trackers and inertial units", 8, 128.0, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"gncActuatorCommand", "reaction wheels", 4, 64.0, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"massMemoryWrite", "mass memories", 8, 1024.0, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"transponderUplink", "transponders", 1, 1024.0, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"transponderDownlink", "transponders", 3, 1024.0, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
	{"retryReserve", "any", 2, 1024.0, []string{"earlyOperations", "coast", "thrust", "approach", "proximityOperations", "retreat", "capture", "despin", "stackCoast", "stackThrust", "droHold", "dockedPassive", "disposal", "safe", "abortHold"}},
}

type BusModeLoad struct {
	Mode          string
	SlotsUsed     int
	BytesPerFrame float64
}

var BusModeLoads = []BusModeLoad{
	{"launch", 0, 0.0},
	{"earlyOperations", 32, 16848.0},
	{"coast", 32, 16848.0},
	{"thrust", 32, 16848.0},
	{"approach", 32, 16848.0},
	{"proximityOperations", 36, 17488.0},
	{"retreat", 32, 16848.0},
	{"capture", 36, 17488.0},
	{"despin", 36, 17488.0},
	{"stackCoast", 32, 16848.0},
	{"stackThrust", 32, 16848.0},
	{"droHold", 32, 16848.0},
	{"dockedPassive", 32, 16848.0},
	{"disposal", 32, 16848.0},
	{"safe", 32, 16848.0},
	{"abortHold", 32, 16848.0},
}

const (
	MinorFramePeriodS        float64 = 0.125
	MajorFramePeriodS        float64 = 1.0
	MinorFramesPerMajorFrame int     = 8
	BusFrameSlots            int     = 64
	BusFramePeriodS          float64 = 0.125
	BusSlotLengthBytes       float64 = 1024.0
)
