SYSML ?= build/opensysml/sysml
PILOT ?= build/pilot-validator/validate-sysml
PILOT_BATCH ?= build/pilot-sysml-validator/validate-sysml-batch
OPENSYSML_LIBRARIES ?= build/opensysml-src/internal/workspace/libs/stdlib/OpenSysML Libraries
MODEL := $(sort $(wildcard model/*.sysml model/*.kerml))
# The standalone pilot wrapper reads .sysml only (docs/findings/WP-G.md F-G01), so the
# mission-tier .kerml files go through the pinned batch oracle against the standard library alone.
MODEL_SYSML := $(sort $(wildcard model/*.sysml))
MODEL_KERML := $(sort $(wildcard model/*.kerml))

# Tool tier: files that reference an OpenSysML library package (the packages shipped under
# "OpenSysML Libraries"). The pilot resolves them only when that directory is loaded as an
# extension library, so these files are gated by the batch pilot; everything else is the
# mission tier and must pass the standalone pilot against the standard library alone.
OPENSYSML_PACKAGES := $(shell ls "$(OPENSYSML_LIBRARIES)" | grep -E '\.(sysml|kerml)$$' | sed 's/\..*//' | paste -sd '|')
MODEL_TOOL := $(sort $(shell grep -lwE '$(OPENSYSML_PACKAGES)' $(MODEL)))
MODEL_MISSION := $(filter-out $(MODEL_TOOL),$(MODEL_SYSML))
MODEL_MISSION_KERML := $(filter-out $(MODEL_TOOL),$(MODEL_KERML))

.PHONY: tools check validate pilot pilot-mission pilot-all house-rules runs runs-check tiers

tools:
	scripts/fetch-tools.sh

check: validate pilot house-rules runs-check

validate:
	$(SYSML) -validate -strict -warnings-as-errors $(MODEL)

pilot: pilot-mission pilot-all

pilot-mission:
	$(PILOT) $(MODEL_MISSION)
	$(PILOT_BATCH) --root $(CURDIR) $(addprefix $(CURDIR)/,$(MODEL_MISSION_KERML))

pilot-all:
	$(PILOT_BATCH) --extension-library "$(OPENSYSML_LIBRARIES)" --root $(CURDIR) $(addprefix $(CURDIR)/,$(MODEL))

tiers:
	@echo "mission tier: $(MODEL_MISSION) $(MODEL_MISSION_KERML)"
	@echo "tool tier:    $(MODEL_TOOL)"

house-rules:
	$(SYSML) -validate -self-check-package TethysHouseRules $(MODEL)

runs:
	SYSML=$(SYSML) scripts/runs.sh record

runs-check:
	SYSML=$(SYSML) scripts/runs.sh check

# ---- stage-2 software: the generator toolchain -------------------------------------------------
# The generator reads the model through the pinned OpenSysML (`-convert api-json`) and writes the
# C11 and Python tables under software/generated/. `make check` stays model-only; the software
# gate is `make software-check`, a separate CI job.
PYTHON ?= python3
SOFTWARE_VENV ?= build/software/venv
SOFTWARE_PY := $(SOFTWARE_VENV)/bin/python
CFLAGS_STRICT := -std=c11 -Wall -Wextra -Werror -pedantic

.PHONY: software-venv software-generate software-selftest software-test software-check

# The Python client of the pinned OpenSysML checkout, so generator and model agree on the pin.
software-venv: $(SOFTWARE_PY)
$(SOFTWARE_PY): build/opensysml-src/client/python/pyproject.toml
	$(PYTHON) -m venv $(SOFTWARE_VENV)
	$(SOFTWARE_PY) -m pip install --quiet --upgrade pip
	$(SOFTWARE_PY) -m pip install --quiet ./build/opensysml-src/client/python pytest

software-generate: $(SOFTWARE_PY)
	$(SOFTWARE_PY) software/gen/generate.py --sysml $(SYSML)

software-selftest:
	mkdir -p build/software
	$(CC) $(CFLAGS_STRICT) -Isoftware/generated/c software/generated/c/selftest.c -o build/software/selftest
	build/software/selftest

software-test: $(SOFTWARE_PY)
	$(SOFTWARE_PY) -m pytest -q software/tests

# Regenerate into a scratch directory and fail on any byte of drift against the committed tables.
software-check: $(SOFTWARE_PY) software-selftest
	rm -rf build/software/regen
	$(SOFTWARE_PY) software/gen/generate.py --sysml $(SYSML) --out build/software/regen --cache build/software/regen.api.json --quiet
	diff -r --exclude=__pycache__ --exclude=selftest.c software/generated build/software/regen > build/software/drift.txt \
		|| { echo "software-check: generated tables drift from the model (build/software/drift.txt):"; cat build/software/drift.txt; exit 1; }
	$(SOFTWARE_PY) -m pytest -q software/tests

include software/ground/ground.mk
include software/flight/flight.mk
