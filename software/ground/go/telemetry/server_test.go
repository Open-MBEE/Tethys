package telemetry

import (
	"encoding/hex"
	"encoding/json"
	"os"
	"testing"

	"github.com/Open-MBEE/Tethys/software/generated/go/argenttables"
)

// fixtures is software/ground/fixtures/packets.json, the golden packets the Python encoder writes
// from the same tables (format: software/ground/README.md).
type fixtures struct {
	Format  string `json:"format"`
	Packets []struct {
		Mnemonic      string             `json:"mnemonic"`
		Apid          int                `json:"apid"`
		LengthOctets  int                `json:"length_octets"`
		SequenceCount int                `json:"sequence_count"`
		TimeCoarse    uint64             `json:"time_coarse"`
		TimeFine      uint64             `json:"time_fine"`
		Hex           string             `json:"hex"`
		Raw           map[string]uint64  `json:"raw"`
		Engineering   map[string]float64 `json:"engineering"`
	} `json:"packets"`
}

func loadFixtures(t *testing.T) fixtures {
	t.Helper()
	data, err := os.ReadFile("../../fixtures/packets.json")
	if err != nil {
		t.Fatal(err)
	}
	var f fixtures
	if err := json.Unmarshal(data, &f); err != nil {
		t.Fatal(err)
	}
	if f.Format != "meridian-packet-fixtures/1" {
		t.Fatalf("fixture format %q", f.Format)
	}
	return f
}

// TestAllPacketsDecommutate is allPacketsDecommutate of runs/sw-ground-structure.txt (TM-004): every
// dictionary packet of the golden fixtures decodes to the raw and engineering values the encoder wrote.
func TestAllPacketsDecommutate(t *testing.T) {
	f := loadFixtures(t)
	if len(f.Packets) != argenttables.PacketCount || argenttables.PacketCount != 51 {
		t.Fatalf("%d fixture packets, dictionary %d", len(f.Packets), argenttables.PacketCount)
	}
	srv := NewServer()
	for _, fx := range f.Packets {
		data, err := hex.DecodeString(fx.Hex)
		if err != nil {
			t.Fatal(err)
		}
		d, err := Decode(data)
		if err != nil {
			t.Fatalf("%s: %v", fx.Mnemonic, err)
		}
		if d.Packet.Mnemonic != fx.Mnemonic || d.Header.Apid != fx.Apid || d.Header.SequenceCount != fx.SequenceCount || d.TimeCoarse != fx.TimeCoarse || d.TimeFine != fx.TimeFine {
			t.Fatalf("%s: header/time mismatch: %+v", fx.Mnemonic, d.Header)
		}
		for k, v := range fx.Raw {
			if d.Raw[k] != v {
				t.Fatalf("%s.%s raw %d, fixture %d", fx.Mnemonic, k, d.Raw[k], v)
			}
		}
		samples, err := srv.Ingest(data)
		if err != nil {
			t.Fatal(err)
		}
		for _, s := range samples {
			if s.Value != fx.Engineering[s.Mnemonic] {
				t.Fatalf("%s.%s engineering %v, fixture %v", fx.Mnemonic, s.Mnemonic, s.Value, fx.Engineering[s.Mnemonic])
			}
		}
	}
	if srv.Packets != 51 || srv.Points != argenttables.TelemetryPointCount {
		t.Fatalf("ingested %d packets, %d points", srv.Packets, srv.Points)
	}
	for _, p := range argenttables.Packets {
		if !LayoutConsistent(p) {
			t.Fatalf("%s layout inconsistent", p.Mnemonic)
		}
	}
}

// TestLimitsAndAlarms is busVoltageAlarm/lowBatteryAlarm of the pinned run (TM-005): the model's
// sample inputs give nominal and violation, the limit table's batteryLowFraction being the floor.
func TestLimitsAndAlarms(t *testing.T) {
	if got := CheckLimits(EngineeringUnits(2048, 0.0146, 0), 24, 34, 1); got != argenttables.AlarmSeverityNominal {
		t.Fatalf("bus voltage severity %v", argenttables.AlarmSeverityNames[got])
	}
	var floor float64
	for _, l := range argenttables.LimitTable {
		if l.Name == "batteryLowFraction" {
			floor = l.Value
		}
	}
	if floor == 0 || CheckLimits(0.12, floor, 1.0, 0.05) != argenttables.AlarmSeverityViolation {
		t.Fatalf("low battery against floor %v is not a violation", floor)
	}
	srv := NewServer()
	p := argenttables.TelemetryPoints[argenttables.TelemetryByMnemonic["EPS_BATT_CELL_V_01"]]
	srv.observe(Sample{p.Mnemonic, 0, *p.RedLow - 1, DictionarySeverity(p, *p.RedLow-1)})
	if a := srv.Alarms(); len(a) != 1 || a[0].State != "raised" {
		t.Fatalf("alarms %+v", a)
	}
	if err := srv.Acknowledge(p.Mnemonic); err != nil {
		t.Fatal(err)
	}
	srv.observe(Sample{p.Mnemonic, 1, (*p.RedLow + *p.RedHigh) / 2, argenttables.AlarmSeverityNominal})
	if a := srv.Alarms(); len(a) != 0 {
		t.Fatalf("alarm did not clear: %+v", a)
	}
}

// TestFrame synchronises a 1115-octet MLS-2 transfer frame holding three fixture packets.
func TestFrame(t *testing.T) {
	f := loadFixtures(t)
	frame := make([]byte, 1115)
	pos := 6
	for _, fx := range f.Packets[:3] {
		data, _ := hex.DecodeString(fx.Hex)
		copy(frame[pos:], data)
		pos += len(data)
	}
	copy(frame[pos:], PrimaryHeader{Apid: IdleApid}.Pack())
	srv := NewServer()
	n, err := srv.Frame(frame)
	if err != nil || n != 3 {
		t.Fatalf("frame: %d packets, %v", n, err)
	}
	if _, err := srv.Frame(frame[:100]); err == nil {
		t.Fatal("short frame accepted")
	}
}

func TestRejectsNonDictionaryPackets(t *testing.T) {
	srv := NewServer()
	if _, err := srv.Ingest(PrimaryHeader{Apid: 1000, DataLength: 1}.Pack()); err == nil || srv.Rejected != 1 {
		t.Fatal("unknown APID accepted")
	}
}
