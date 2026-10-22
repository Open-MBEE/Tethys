SYSML ?= build/opensysml/sysml
PILOT ?= build/pilot-validator/validate-sysml
MODEL := $(sort $(wildcard model/*.sysml))

.PHONY: tools check validate pilot house-rules runs runs-check

tools:
	scripts/fetch-tools.sh

check: validate pilot house-rules runs-check

validate:
	$(SYSML) -validate -strict -warnings-as-errors $(MODEL)

pilot:
	$(PILOT) $(MODEL)

house-rules:
	$(SYSML) -validate -self-check-package TethysHouseRules $(MODEL)

runs:
	SYSML=$(SYSML) scripts/runs.sh record

runs-check:
	SYSML=$(SYSML) scripts/runs.sh check
