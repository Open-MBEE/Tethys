package uplink

import (
	"errors"
	"testing"

	"github.com/Open-MBEE/Tethys/software/generated/go/argenttables"
	"github.com/Open-MBEE/Tethys/software/ground/go/internal/bits"
	"github.com/Open-MBEE/Tethys/software/ground/go/telemetry"
)

// command packs a command packet as Forge does: primary header (type 1, no secondary header),
// 16-bit opcode, arguments at their dictionary widths (zero here).
func command(c argenttables.Command) []byte {
	octets := (16 + c.ArgumentBits + 7) / 8
	out := make([]byte, 6+octets)
	copy(out, telemetry.PrimaryHeader{Type: 1, Apid: c.Apid, SequenceFlags: 3, DataLength: octets - 1}.Pack())
	bits.Put(out, 48, 16, uint64(c.Opcode))
	return out
}

// TestTwoStepServerSide is TM-002 hazardousApproval and TF-002: every dictionary-hazardous command
// is held with one approval and queued with two from different approvers.
func TestTwoStepServerSide(t *testing.T) {
	s := NewService()
	held, queued := 0, 0
	for _, c := range argenttables.Commands {
		if !c.Hazardous {
			continue
		}
		if _, err := s.Accept(Product{Packet: command(c), Approvals: 1}); !errors.Is(err, ErrAwaitingSecondApproval) {
			t.Fatalf("%s accepted with one approval: %v", c.Mnemonic, err)
		}
		held++
		if _, err := s.Accept(Product{Packet: command(c), Approvals: 2, Approvers: []string{"ace", "flight director"}}); err != nil {
			t.Fatalf("%s refused with two approvals: %v", c.Mnemonic, err)
		}
		queued++
	}
	if held != argenttables.HazardousCommandCount || queued != 51 || s.Refused != 51 {
		t.Fatalf("held %d queued %d refused %d", held, queued, s.Refused)
	}
	c := argenttables.Commands[argenttables.CommandsByMnemonic["CDH_RESET_PROCESSOR"]]
	if _, err := s.Accept(Product{Packet: command(c), Approvals: 2, Approvers: []string{"ace", "ace"}}); !errors.Is(err, ErrAwaitingSecondApproval) {
		t.Fatal("the same approver twice counted as two")
	}
}

// TestModeAndOpcode is the ground half of TM-001: unknown opcodes and disallowed modes are refused.
func TestModeAndOpcode(t *testing.T) {
	s := NewService()
	c := argenttables.Commands[argenttables.CommandsByMnemonic["SEP_START_THRUST_ARC"]]
	if _, err := s.Accept(Product{Packet: command(c), Approvals: 2, Mode: "coast"}); !errors.Is(err, ErrModeNotAllowed) {
		t.Fatalf("thrust arc in coast: %v", err)
	}
	if _, err := s.Accept(Product{Packet: command(c), Approvals: 2, Mode: "thrust"}); err != nil {
		t.Fatalf("thrust arc in thrust: %v", err)
	}
	bad := command(c)
	bits.Put(bad, 48, 16, 65000)
	if _, err := s.Accept(Product{Packet: bad, Approvals: 2}); !errors.Is(err, ErrUnknownOpcode) {
		t.Fatalf("unknown opcode: %v", err)
	}
	if _, err := s.Accept(Product{Packet: telemetry.PrimaryHeader{Apid: 16, DataLength: 1}.Pack()}); !errors.Is(err, ErrNotCommand) {
		t.Fatal("telemetry header accepted as a command")
	}
}

// TestFraming frames the queue for MLS-2 at the profile's 1115-octet frame with its 6/4-octet
// header and trailer; a LoadSequence (Warden's product) rides along.
func TestFraming(t *testing.T) {
	s := NewService()
	load := make([]byte, 8)
	copy(load, telemetry.PrimaryHeader{Type: 1, Apid: LoadSequenceApid, SequenceFlags: 3, DataLength: 1}.Pack())
	bits.Put(load, 48, 16, 1)
	if _, err := s.Accept(Product{Packet: load}); err != nil {
		t.Fatal(err)
	}
	noop := argenttables.Commands[argenttables.CommandsByMnemonic["CDH_NOOP"]]
	for i := 0; i < 300; i++ {
		if _, err := s.Accept(Product{Packet: command(noop), Mode: "coast"}); err != nil {
			t.Fatal(err)
		}
	}
	f, err := NewFramer(0)
	if err != nil {
		t.Fatal(err)
	}
	frames := f.Frames(s)
	if f.Length != 1115 || f.Header != 6 || f.Trailer != 4 {
		t.Fatalf("frame geometry %d/%d/%d", f.Length, f.Header, f.Trailer)
	}
	if len(frames) != 3 || len(frames[0]) != 1115 || s.Released != 301 || len(s.Pending()) != 0 {
		t.Fatalf("%d frames, released %d", len(frames), s.Released)
	}
	if _, err := NewFramer(8); err == nil {
		t.Fatal("virtual channel 8 accepted")
	}
}
