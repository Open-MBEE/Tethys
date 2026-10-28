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
