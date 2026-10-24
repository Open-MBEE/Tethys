package telemetry

import (
	"fmt"
	"sync"

	"github.com/Open-MBEE/Tethys/software/generated/go/argenttables"
)

// Severity is TethysGroundSoftware::AlarmSeverity.
type Severity = argenttables.AlarmSeverity

// CheckLimits is TethysGroundSoftware::CheckLimits.
func CheckLimits(value, low, high, band float64) Severity {
	switch {
	case value < low || value > high:
		return argenttables.AlarmSeverityViolation
	case value < low+band || value > high-band:
		return argenttables.AlarmSeverityWarning
	}
	return argenttables.AlarmSeverityNominal
}

// DictionarySeverity applies a point's four dictionary limits: red limits bound the violation,
// yellow limits the warning.
func DictionarySeverity(p argenttables.TelemetryPoint, value float64) Severity {
	if p.RedLow == nil || p.RedHigh == nil {
		return argenttables.AlarmSeverityNominal
	}
	if value < *p.RedLow || value > *p.RedHigh {
		return argenttables.AlarmSeverityViolation
	}
	if (p.YellowLow != nil && value < *p.YellowLow) || (p.YellowHigh != nil && value > *p.YellowHigh) {
		return argenttables.AlarmSeverityWarning
	}
	return argenttables.AlarmSeverityNominal
}

// Sample is one engineering value with its time and severity.
type Sample struct {
	Mnemonic string
	Seconds  float64
	Value    float64
	Severity Severity
}

// Alarm is one entry of the alarm list; State follows AlarmLifecycle (quiet, raised, acknowledged).
type Alarm struct {
	Mnemonic string
	Value    float64
	Severity Severity
	State    string
}

// Server is Meridian Lantern: decommutation, limits, alarms and an in-memory archive.
type Server struct {
	mu       sync.Mutex
	archive  []Sample
	alarms   map[string]*Alarm
	Packets  int
	Points   int
	Rejected int
}

// NewServer returns an empty server.
func NewServer() *Server { return &Server{alarms: map[string]*Alarm{}} }

// Ingest decommutates one packet, limit-checks every point, archives the samples and returns them.
func (s *Server) Ingest(data []byte) ([]Sample, error) {
	d, err := Decode(data)
	if err != nil {
		s.mu.Lock()
		s.Rejected++
		s.mu.Unlock()
		return nil, err
	}
	samples := make([]Sample, 0, len(d.Raw))
	for _, f := range d.Packet.Fields {
		p := argenttables.TelemetryPoints[argenttables.TelemetryByMnemonic[f.Point]]
		scale, offset := Calibration(p)
		v := EngineeringUnits(d.Raw[f.Point], scale, offset)
		samples = append(samples, Sample{f.Point, d.Seconds(), v, DictionarySeverity(p, v)})
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	s.Packets++
	s.Points += len(samples)
	s.archive = append(s.archive, samples...)
	for _, smp := range samples {
		s.observe(smp)
	}
	return samples, nil
}

func (s *Server) observe(smp Sample) {
	a, ok := s.alarms[smp.Mnemonic]
	if !ok {
		a = &Alarm{Mnemonic: smp.Mnemonic, State: "quiet"}
		s.alarms[smp.Mnemonic] = a
	}
	a.Value, a.Severity = smp.Value, smp.Severity
	switch {
	case smp.Severity == argenttables.AlarmSeverityViolation && a.State == "quiet":
		a.State = "raised"
	case smp.Severity != argenttables.AlarmSeverityViolation && a.State != "quiet":
		a.State = "quiet"
	}
}

// Acknowledge moves a raised alarm to acknowledged (AlarmLifecycle: raised → acknowledged).
func (s *Server) Acknowledge(mnemonic string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	a, ok := s.alarms[mnemonic]
	if !ok || a.State != "raised" {
		return fmt.Errorf("telemetry: %s is not a raised alarm", mnemonic)
	}
	a.State = "acknowledged"
	return nil
}

// Alarms lists the alarms not in the quiet state.
func (s *Server) Alarms() []Alarm {
	s.mu.Lock()
	defer s.mu.Unlock()
	var out []Alarm
	for _, a := range s.alarms {
		if a.State != "quiet" {
			out = append(out, *a)
		}
	}
	return out
}

// Archive returns every sample ingested, in order.
func (s *Server) Archive() []Sample {
	s.mu.Lock()
	defer s.mu.Unlock()
	return append([]Sample(nil), s.archive...)
}

// Frame splits one MLS-2 transfer frame (TI-021: fixed length, header and trailer from the ICD
// parameters) into its packets and ingests each; idle fill ends the frame.
func (s *Server) Frame(frame []byte) (int, error) {
	length := int(*argenttables.IcdParametersByName[[2]string{"SpaceLinkProfileIcd", "transferFrameLength"}].Number)
	head := int(*argenttables.IcdParametersByName[[2]string{"SpaceLinkProfileIcd", "frameHeaderLength"}].Number)
	tail := int(*argenttables.IcdParametersByName[[2]string{"SpaceLinkProfileIcd", "frameTrailerLength"}].Number)
	if len(frame) != length {
		return 0, fmt.Errorf("telemetry: frame of %d octets, the profile says %d", len(frame), length)
	}
	body := frame[head : length-tail]
	n := 0
	for pos := 0; pos+primaryHeaderBits/8 <= len(body); {
		h, err := ParseHeader(body[pos:])
		if err != nil || h.Apid == IdleApid {
			break
		}
		end := pos + h.Length()
		if end > len(body) {
			return n, ErrLayout
		}
		if _, err := s.Ingest(body[pos:end]); err != nil {
			return n, err
		}
		n++
		pos = end
	}
	return n, nil
}
