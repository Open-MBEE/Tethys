SYSML ?= build/opensysml/sysml
PILOT ?= build/pilot-validator/validate-sysml
MODEL := $(sort $(wildcard model/*.sysml model/*.kerml))
# The pinned pilot validator reads .sysml only (docs/findings.md F-003); the KerML library is
# gated by the strict OpenSysML validate above.
PILOT_MODEL := $(sort $(wildcard model/*.sysml))

.PHONY: tools check validate pilot house-rules runs runs-check

tools:
	scripts/fetch-tools.sh

check: validate pilot house-rules runs-check

validate:
	$(SYSML) -validate -strict -warnings-as-errors $(MODEL)

pilot:
	$(PILOT) $(PILOT_MODEL)

house-rules:
	$(SYSML) -validate -self-check-package TethysHouseRules $(MODEL)

runs:
	SYSML=$(SYSML) scripts/runs.sh record

runs-check:
	SYSML=$(SYSML) scripts/runs.sh check
