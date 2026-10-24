// Argent flight software tables. Generated; edit the model or the generator, not this file.
// Generator: software/gen/generate.py 1.0.0
// Model tool: OpenSysML 5cd37f2 (commit 5cd37f288fef171d62737d6045f4caff772b6014)
// Model files: 64 files under model/ (81-physics.kerml … 99-house-rules.sysml)
// Source elements:
//   every table of this package

package argenttables

// Index maps from the tables' keys to row positions, built once at package initialisation.
var (
	CommandsByOpcode    = map[int]int{}
	CommandsByMnemonic  = map[string]int{}
	TelemetryByID       = map[int]int{}
	TelemetryByMnemonic = map[string]int{}
	EventsByID          = map[int]int{}
	PacketsByApid       = map[int]int{}
	PacketsByMnemonic   = map[string]int{}
	ParametersByID      = map[int]int{}
	ModeRowsByName      = map[string]int{}
	RateSetByMode       = map[string]ModeRateSet{}
	MessagesByApid      = map[int]int{}
	IcdParametersByName = map[[2]string]IcdParameter{}
	StateMachinesByName = map[string]int{}
	FlightRulesByID     = map[string]int{}
	SequencesByID       = map[int]int{}
	ComponentsByProduct = map[string]int{}
	ComponentsByPath    = map[string]int{}
	StationsByName      = map[string]int{}
)

func init() {
	for k, c := range Commands {
		CommandsByOpcode[c.Opcode] = k
		CommandsByMnemonic[c.Mnemonic] = k
	}
	for k, t := range TelemetryPoints {
		TelemetryByID[t.ID] = k
		TelemetryByMnemonic[t.Mnemonic] = k
	}
	for k, e := range Events {
		EventsByID[e.ID] = k
	}
	for k, p := range Packets {
		PacketsByApid[p.Apid] = k
		PacketsByMnemonic[p.Mnemonic] = k
	}
	for k, p := range Parameters {
		ParametersByID[p.ID] = k
	}
	for k, r := range ModeTable {
		ModeRowsByName[r.Mode] = k
	}
	for _, r := range ModeRateSets {
		RateSetByMode[r.Mode] = r
	}
	for k, m := range Messages {
		MessagesByApid[m.Apid] = k
	}
	for _, p := range IcdParameters {
		IcdParametersByName[[2]string{p.Icd, p.Name}] = p
	}
	for k, m := range StateMachines {
		StateMachinesByName[m.Name] = k
	}
	for k, r := range FlightRules {
		FlightRulesByID[r.ID] = k
	}
	for k, q := range OnBoardSequences {
		SequencesByID[q.SequenceID] = k
	}
	for k, c := range GroundComponents {
		ComponentsByProduct[c.ProductName] = k
		ComponentsByPath[c.Path] = k
	}
	for k, st := range Stations {
		StationsByName[st.Name] = k
	}
}

const GeneratorVersion = "1.0.0"
const ModelToolVersion = "5cd37f2"
const ModelToolCommit = "5cd37f288fef171d62737d6045f4caff772b6014"
