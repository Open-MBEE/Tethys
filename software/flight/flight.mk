# ---- Argent flight software (host build) -----------------------------------------------------
# Included from the root Makefile. Builds the Argent Flight Executive and its applications as C11
# against the generated tables, runs the unit tests (strict + sanitised), the banned-construct
# check, the host scenarios and the pinned-run comparisons. Gate: `make software-flight-check`.
FLIGHT_DIR := software/flight
FLIGHT_BUILD := build/software/flight
FLIGHT_GEN := software/generated/c
FLIGHT_CFLAGS := -std=c11 -Wall -Wextra -Werror -pedantic -fno-common -O2 \
    -I$(FLIGHT_DIR) -I$(FLIGHT_GEN)
FLIGHT_SAN_CFLAGS := -std=c11 -Wall -Wextra -Werror -pedantic -fno-common -O1 -g \
    -fsanitize=address,undefined -fno-omit-frame-pointer -I$(FLIGHT_DIR) -I$(FLIGHT_GEN)
FLIGHT_SRC := $(wildcard $(FLIGHT_DIR)/exec/*.c $(FLIGHT_DIR)/sm/*.c $(FLIGHT_DIR)/bus/*.c \
    $(FLIGHT_DIR)/svc/*.c $(FLIGHT_DIR)/apps/*.c $(FLIGHT_DIR)/trace/*.c \
    $(FLIGHT_DIR)/hal/host/*.c $(FLIGHT_DIR)/hal/sim/*.c)
FLIGHT_HOST_SRC := $(FLIGHT_DIR)/host/argent_host.c
FLIGHT_TEST_SRC := $(wildcard $(FLIGHT_DIR)/tests/test_*.c) $(FLIGHT_DIR)/tests/runner.c
FLIGHT_HDRS := $(wildcard $(FLIGHT_DIR)/*/*.h $(FLIGHT_DIR)/hal/*/*.h $(FLIGHT_GEN)/*.h)
FLIGHT_SCENARIOS := $(wildcard $(FLIGHT_DIR)/scenarios/*.stim)

.PHONY: software-flight-build software-flight-unit software-flight-banned software-flight-scenarios \
    software-flight-compare software-flight-sizes software-flight-check software-flight-clean software-flight-scenarios-update

software-flight-scenarios-update: $(FLIGHT_BUILD)/argent_host
	python3 $(FLIGHT_DIR)/tests/compare_runs.py --host $(FLIGHT_BUILD)/argent_host --out $(FLIGHT_BUILD)/scenarios --shipped $(FLIGHT_DIR)/scenarios --write-shipped

$(FLIGHT_BUILD)/argent_host: $(FLIGHT_SRC) $(FLIGHT_HOST_SRC) $(FLIGHT_HDRS) $(FLIGHT_DIR)/flight.mk
	@mkdir -p $(FLIGHT_BUILD)
	$(CC) $(FLIGHT_CFLAGS) -o $@ $(FLIGHT_SRC) $(FLIGHT_HOST_SRC)

$(FLIGHT_BUILD)/argent_tests: $(FLIGHT_SRC) $(FLIGHT_TEST_SRC) $(FLIGHT_HDRS) $(FLIGHT_DIR)/flight.mk
	@mkdir -p $(FLIGHT_BUILD)
	$(CC) $(FLIGHT_CFLAGS) -o $@ $(FLIGHT_SRC) $(FLIGHT_TEST_SRC)

$(FLIGHT_BUILD)/argent_tests_san: $(FLIGHT_SRC) $(FLIGHT_TEST_SRC) $(FLIGHT_HDRS) $(FLIGHT_DIR)/flight.mk
	@mkdir -p $(FLIGHT_BUILD)
	$(CC) $(FLIGHT_SAN_CFLAGS) -o $@ $(FLIGHT_SRC) $(FLIGHT_TEST_SRC)

$(FLIGHT_BUILD)/argent_host_san: $(FLIGHT_SRC) $(FLIGHT_HOST_SRC) $(FLIGHT_HDRS) $(FLIGHT_DIR)/flight.mk
	@mkdir -p $(FLIGHT_BUILD)
	$(CC) $(FLIGHT_SAN_CFLAGS) -o $@ $(FLIGHT_SRC) $(FLIGHT_HOST_SRC)

software-flight-build: $(FLIGHT_BUILD)/argent_host $(FLIGHT_BUILD)/argent_tests $(FLIGHT_BUILD)/argent_tests_san $(FLIGHT_BUILD)/argent_host_san

software-flight-unit: $(FLIGHT_BUILD)/argent_tests $(FLIGHT_BUILD)/argent_tests_san
	$(FLIGHT_BUILD)/argent_tests
	UBSAN_OPTIONS=halt_on_error=1:print_stacktrace=1 ASAN_OPTIONS=detect_leaks=1 $(FLIGHT_BUILD)/argent_tests_san

software-flight-banned:
	sh $(FLIGHT_DIR)/tests/banned_constructs.sh $(FLIGHT_DIR)

software-flight-scenarios: $(FLIGHT_BUILD)/argent_host $(FLIGHT_BUILD)/argent_host_san
	python3 $(FLIGHT_DIR)/tests/compare_runs.py --host $(FLIGHT_BUILD)/argent_host --out $(FLIGHT_BUILD)/scenarios --shipped $(FLIGHT_DIR)/scenarios
	UBSAN_OPTIONS=halt_on_error=1:print_stacktrace=1 python3 $(FLIGHT_DIR)/tests/compare_runs.py --host $(FLIGHT_BUILD)/argent_host_san --out $(FLIGHT_BUILD)/scenarios-san --shipped $(FLIGHT_DIR)/scenarios
	@for f in $(FLIGHT_BUILD)/scenarios/*.jsonl; do cmp "$$f" "$(FLIGHT_BUILD)/scenarios-san/$$(basename $$f)" || exit 1; done
	@echo "traces identical between the strict and the sanitised build"

software-flight-compare: software-flight-scenarios

software-flight-sizes: $(FLIGHT_BUILD)/argent_host
	sh $(FLIGHT_DIR)/tests/report_sizes.sh $(FLIGHT_BUILD)/argent_host runs/sw-fsw-structure.txt

software-flight-check: software-flight-build software-flight-banned software-flight-unit software-flight-compare software-flight-sizes
	@echo "software-flight-check: OK"

software-flight-clean:
	rm -rf $(FLIGHT_BUILD)
