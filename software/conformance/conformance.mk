# ---- software conformance: flight host and generated tables vs the pinned model -----------------
# Runs the Python package software/conformance/argent_conformance against build/software/flight/
# argent_host (flight.mk) and a sysml-grpc service built from the pinned checkout (ground.mk), and
# compares its outputs byte for byte with software/conformance/expected/.
CONFORMANCE_PYTHONPATH := software/conformance:software/ground:software/generated/python

.PHONY: software-conformance-check software-conformance-update software-conformance-clean

software-conformance-check: $(SOFTWARE_PY) $(SYSML_GRPC) $(FLIGHT_BUILD)/argent_host
	PYTHONPATH=$(CONFORMANCE_PYTHONPATH) OPENSYSML_BINARY=$(SYSML_GRPC) $(SOFTWARE_PY) -m argent_conformance all

software-conformance-update: $(SOFTWARE_PY) $(SYSML_GRPC) $(FLIGHT_BUILD)/argent_host
	PYTHONPATH=$(CONFORMANCE_PYTHONPATH) OPENSYSML_BINARY=$(SYSML_GRPC) $(SOFTWARE_PY) -m argent_conformance all --write-expected

software-conformance-clean:
	rm -rf build/software/conformance
