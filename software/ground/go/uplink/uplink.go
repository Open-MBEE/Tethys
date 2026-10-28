// Package uplink is the Meridian command uplink service: it accepts the products Forge and Warden
// release (command packets, LoadSequence loads), enforces the dictionary's two-step hazardous flow
// on the server side too, and frames them for the MLS-2 space link (TI-021).
package uplink

import (
	"errors"
	"fmt"
	"sync"

	"github.com/Open-MBEE/Tethys/software/generated/go/argenttables"
	"github.com/Open-MBEE/Tethys/software/ground/go/internal/bits"
	"github.com/Open-MBEE/Tethys/software/ground/go/telemetry"
)

// RequiredApprovals is the two-step rule of TethysGroundSoftware::ValidateCommand.
const RequiredApprovals = 2

// LoadSequenceApid is the APID Warden's LoadSequence commands carry.
const LoadSequenceApid = 1

var (
	// ErrNotCommand is a packet whose primary header is not a command packet.
	ErrNotCommand = errors.New("uplink: not a command packet")
	// ErrUnknownOpcode is a command the dictionary does not define.
	ErrUnknownOpcode = errors.New("uplink: unknown opcode")
	// ErrAwaitingSecondApproval is a hazardous command with fewer than two approvals.
	ErrAwaitingSecondApproval = errors.New("uplink: hazardous command awaiting its second approval")
	// ErrModeNotAllowed is a command whose allowed modes exclude the mode at execution.
	ErrModeNotAllowed = errors.New("uplink: mode not allowed")
)

// Product is one released item: its packet bytes and the approvals it carries.
type Product struct {
	Packet    []byte
	Approvals int
	Mode      string
	Approvers []string
}

// Queued is an accepted product with the dictionary row it resolved to.
type Queued struct {
	Product
	Opcode   int
	Mnemonic string
	Apid     int
}

// Service is the uplink queue.
type Service struct {
	mu       sync.Mutex
	queue    []Queued
	Refused  int
	Released int
}

// NewService returns an empty queue.
func NewService() *Service { return &Service{} }

// Accept validates a product against the dictionary and queues it.
func (s *Service) Accept(p Product) (Queued, error) {
	h, err := telemetry.ParseHeader(p.Packet)
	if err != nil || h.Type != 1 || h.Length() != len(p.Packet) {
		return s.refuse(ErrNotCommand)
	}
	q := Queued{Product: p, Apid: h.Apid}
	if h.Apid == LoadSequenceApid {
		q.Mnemonic = "LoadSequence"
		return s.enqueue(q)
	}
	q.Opcode = int(bits.Get(p.Packet, 48, 16))
	k, ok := argenttables.CommandsByOpcode[q.Opcode]
	if !ok {
		return s.refuse(ErrUnknownOpcode)
	}
	c := argenttables.Commands[k]
	q.Mnemonic = c.Mnemonic
	if c.Hazardous && (p.Approvals < RequiredApprovals || len(distinct(p.Approvers)) < RequiredApprovals && len(p.Approvers) > 0) {
		return s.refuse(ErrAwaitingSecondApproval)
	}
	if p.Mode != "" && !contains(c.AllowedModes, p.Mode) {
		return s.refuse(ErrModeNotAllowed)
	}
	return s.enqueue(q)
}

func (s *Service) refuse(err error) (Queued, error) {
	s.mu.Lock()
	s.Refused++
	s.mu.Unlock()
	return Queued{}, err
}

func (s *Service) enqueue(q Queued) (Queued, error) {
	s.mu.Lock()
	s.queue = append(s.queue, q)
	s.mu.Unlock()
	return q, nil
}

// Pending is the queue, in acceptance order.
func (s *Service) Pending() []Queued {
	s.mu.Lock()
	defer s.mu.Unlock()
	return append([]Queued(nil), s.queue...)
}

func contains(list []string, v string) bool {
	for _, x := range list {
		if x == v {
			return true
		}
	}
	return false
}

func distinct(list []string) []string {
	seen := map[string]bool{}
	var out []string
	for _, x := range list {
		if !seen[x] {
			seen[x] = true
			out = append(out, x)
		}
	}
	return out
}

// Framer builds MLS-2 transfer frames (TI-021 SpaceLinkProfileIcd): fixed length, a header carrying
// the virtual channel and frame count, packets back to back, idle fill, a trailer.
type Framer struct {
	Length, Header, Trailer int
	VirtualChannel          int
	count                   int
}

// NewFramer reads the frame geometry from the ICD parameter table.
func NewFramer(virtualChannel int) (*Framer, error) {
	get := func(name string) (int, error) {
		p, ok := argenttables.IcdParametersByName[[2]string{"SpaceLinkProfileIcd", name}]
		if !ok || p.Number == nil {
			return 0, fmt.Errorf("uplink: ICD parameter %s missing", name)
		}
		return int(*p.Number), nil
	}
	l, err := get("transferFrameLength")
	if err != nil {
		return nil, err
	}
	h, err := get("frameHeaderLength")
	if err != nil {
		return nil, err
	}
	t, err := get("frameTrailerLength")
	if err != nil {
		return nil, err
	}
	vcs, err := get("virtualChannelCount")
	if err != nil {
		return nil, err
	}
	if virtualChannel < 0 || virtualChannel >= vcs {
		return nil, fmt.Errorf("uplink: virtual channel %d outside the %d the profile defines", virtualChannel, vcs)
	}
	return &Framer{Length: l, Header: h, Trailer: t, VirtualChannel: virtualChannel}, nil
}

// Frames packs the queued products into as many frames as they need and clears the queue.
func (f *Framer) Frames(s *Service) [][]byte {
	s.mu.Lock()
	defer s.mu.Unlock()
	var frames [][]byte
	room := f.Length - f.Header - f.Trailer
	var body []byte
	flush := func() {
		frame := make([]byte, f.Length)
		frame[0] = byte(f.VirtualChannel)
		frame[1] = byte(f.count >> 8)
		frame[2] = byte(f.count)
		copy(frame[f.Header:], body)
		if len(body)+6 <= room {
			copy(frame[f.Header+len(body):], telemetry.PrimaryHeader{Apid: telemetry.IdleApid}.Pack())
		}
		f.count++
		frames = append(frames, frame)
		body = nil
	}
	for _, q := range s.queue {
		if len(body)+len(q.Packet) > room {
			flush()
		}
		body = append(body, q.Packet...)
		s.Released++
	}
	if len(body) > 0 {
		flush()
	}
	s.queue = nil
	return frames
}
