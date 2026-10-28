// Package telemetry is the Meridian Lantern service (TethysGroundSoftware::TelemetryServer) as an
// always-on Go service: it ingests CCSDS space packets as the flight dictionary lays them out,
// decommutates them by the generated packet tables, applies the dictionary limits, raises alarms
// and archives the engineering values.
package telemetry

import (
	"errors"
	"fmt"

	"github.com/Open-MBEE/Tethys/software/generated/go/argenttables"
	"github.com/Open-MBEE/Tethys/software/ground/go/internal/bits"
)

// Primary header widths from the model (TethysFlightDictionary::PrimaryHeaderLayout).
var (
	primaryHeaderBits = argenttables.PrimaryHeaderVersionWidth + argenttables.PrimaryHeaderTypeWidth +
		argenttables.PrimaryHeaderSecondaryHeaderFlagWidth + argenttables.PrimaryHeaderApidWidth +
		argenttables.PrimaryHeaderSequenceFlagsWidth + argenttables.PrimaryHeaderSequenceCountWidth +
		argenttables.PrimaryHeaderDataLengthWidth
	timeCodeBits = argenttables.TimeCodeCoarseWidth + argenttables.TimeCodeFineWidth
)

// IdleApid fills the rest of a transfer frame (all ones in the 11-bit APID field).
const IdleApid = 0x7FF

// ErrLayout is a packet whose bytes do not fit its dictionary layout.
var ErrLayout = errors.New("telemetry: packet does not fit its dictionary layout")

// PrimaryHeader is the six-octet CCSDS primary header.
type PrimaryHeader struct {
	Version         int
	Type            int
	SecondaryHeader bool
	Apid            int
	SequenceFlags   int
	SequenceCount   int
	DataLength      int
}

// ParseHeader reads the primary header at the start of data.
func ParseHeader(data []byte) (PrimaryHeader, error) {
	if len(data) < primaryHeaderBits/8 {
		return PrimaryHeader{}, ErrLayout
	}
	var h PrimaryHeader
	off := 0
	read := func(width int) int {
		v := int(bits.Get(data, off, width))
		off += width
		return v
	}
	h.Version = read(argenttables.PrimaryHeaderVersionWidth)
	h.Type = read(argenttables.PrimaryHeaderTypeWidth)
	h.SecondaryHeader = read(argenttables.PrimaryHeaderSecondaryHeaderFlagWidth) == 1
	h.Apid = read(argenttables.PrimaryHeaderApidWidth)
	h.SequenceFlags = read(argenttables.PrimaryHeaderSequenceFlagsWidth)
	h.SequenceCount = read(argenttables.PrimaryHeaderSequenceCountWidth)
	h.DataLength = read(argenttables.PrimaryHeaderDataLengthWidth)
	return h, nil
}

// Pack writes the header into six octets.
func (h PrimaryHeader) Pack() []byte {
	out := make([]byte, primaryHeaderBits/8)
	off := 0
	write := func(width, v int) {
		bits.Put(out, off, width, uint64(v))
		off += width
	}
	write(argenttables.PrimaryHeaderVersionWidth, h.Version)
	write(argenttables.PrimaryHeaderTypeWidth, h.Type)
	sh := 0
	if h.SecondaryHeader {
		sh = 1
	}
	write(argenttables.PrimaryHeaderSecondaryHeaderFlagWidth, sh)
	write(argenttables.PrimaryHeaderApidWidth, h.Apid)
	write(argenttables.PrimaryHeaderSequenceFlagsWidth, h.SequenceFlags)
	write(argenttables.PrimaryHeaderSequenceCountWidth, h.SequenceCount)
	write(argenttables.PrimaryHeaderDataLengthWidth, h.DataLength)
	return out
}

// Length is the whole packet length the header announces.
func (h PrimaryHeader) Length() int { return primaryHeaderBits/8 + h.DataLength + 1 }

// Decoded is one decommutated packet: the dictionary packet, its time and raw fields by mnemonic.
type Decoded struct {
	Packet     argenttables.Packet
	Header     PrimaryHeader
	TimeCoarse uint64
	TimeFine   uint64
	Raw        map[string]uint64
}

// Seconds is the time code in seconds since the dictionary epoch.
func (d Decoded) Seconds() float64 {
	return float64(d.TimeCoarse) + float64(d.TimeFine)*argenttables.TimeCodeFineResolution
}

// Decode decommutates one packet by its APID.
func Decode(data []byte) (Decoded, error) {
	h, err := ParseHeader(data)
	if err != nil {
		return Decoded{}, err
	}
	k, ok := argenttables.PacketsByApid[h.Apid]
	if !ok {
		return Decoded{}, fmt.Errorf("telemetry: APID %d is not a dictionary packet", h.Apid)
	}
	p := argenttables.Packets[k]
	if len(data) != p.LengthOctets || h.Length() != p.LengthOctets {
		return Decoded{}, fmt.Errorf("%w: %s has %d octets, header says %d, dictionary %d", ErrLayout, p.Mnemonic, len(data), h.Length(), p.LengthOctets)
	}
	d := Decoded{Packet: p, Header: h, Raw: make(map[string]uint64, len(p.Fields))}
	d.TimeCoarse = bits.Get(data, primaryHeaderBits, argenttables.TimeCodeCoarseWidth)
	d.TimeFine = bits.Get(data, primaryHeaderBits+argenttables.TimeCodeCoarseWidth, argenttables.TimeCodeFineWidth)
	for _, f := range p.Fields {
		d.Raw[f.Point] = bits.Get(data, f.OffsetBits, f.WidthBits)
	}
	return d, nil
}

// LayoutConsistent is PacketDefinition::layoutConsistent: contiguous fields from the header to the length.
func LayoutConsistent(p argenttables.Packet) bool {
	expected := p.HeaderBits
	for _, f := range p.Fields {
		if f.OffsetBits != expected {
			return false
		}
		expected += f.WidthBits
	}
	return expected == p.LengthOctets*8 && p.HeaderBits == primaryHeaderBits+timeCodeBits
}

// Calibration is the (scale, offset) of EngineeringUnits for a point: the red limits span the raw
// range; a point without both limits is carried as its raw count.
func Calibration(p argenttables.TelemetryPoint) (scale, offset float64) {
	if p.RedLow == nil || p.RedHigh == nil || *p.RedHigh <= *p.RedLow {
		return 1, 0
	}
	full := float64(uint64(1)<<uint(p.WidthBits) - 1)
	return (*p.RedHigh - *p.RedLow) / full, *p.RedLow
}

// EngineeringUnits is TethysGroundSoftware::EngineeringUnits: rawCount * scale + offset.
func EngineeringUnits(raw uint64, scale, offset float64) float64 { return float64(raw)*scale + offset }
