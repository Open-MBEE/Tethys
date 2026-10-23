# ---- stage-2 software: the Meridian Operations Suite (ground) -----------------------------------
# Python package software/ground/meridian over the generated Python tables and the pinned OpenSysML
# client; Go services software/ground/go over the generated Go tables. The model evaluations go
# through a sysml-grpc service built from the same pinned checkout as build/opensysml/sysml.
GROUND_GO := software/ground/go
GROUND_PYTHONPATH := software/ground:software/generated/python
SYSML_GRPC ?= build/opensysml/sysml-grpc

.PHONY: software-ground-test software-ground-go software-ground-check

$(SYSML_GRPC): build/opensysml-src/go.mod
	cd build/opensysml-src && GOTOOLCHAIN=$${GOTOOLCHAIN:-go1.25.11} go build -o bin/sysml-grpc ./cmd/sysml-grpc
	cp build/opensysml-src/bin/sysml-grpc $(SYSML_GRPC)

software-ground-test: $(SOFTWARE_PY) $(SYSML_GRPC)
	mkdir -p build/software
	OPENSYSML_BINARY=$(SYSML_GRPC) PYTHONPATH=$(GROUND_PYTHONPATH) $(SOFTWARE_PY) -m pytest -q -p no:cacheprovider software/ground/tests

# gofmt must print nothing; the generated Go package is vetted here too (its regen drift is part
# of `make software-check`, which diffs the whole of software/generated/).
software-ground-go:
	test -z "$$(cd software/generated/go && gofmt -l .)" || { echo "software-ground-go: generated Go is not gofmt-clean"; exit 1; }
	cd software/generated/go && go vet ./...
	test -z "$$(cd $(GROUND_GO) && gofmt -l .)" || { echo "software-ground-go: gofmt -l is not empty:"; cd $(GROUND_GO) && gofmt -l .; exit 1; }
	cd $(GROUND_GO) && go vet ./... && go test ./...

software-ground-check: software-ground-test software-ground-go
