#include "tests/runner.h"
#include <stdlib.h>
#include <time.h>

int test_failures = 0;
int test_checks = 0;

#define SUITE(n) extern const test_case_t n##_tests[]; extern const unsigned n##_test_count;
SUITE(sm) SUITE(bus) SUITE(command) SUITE(telemetry) SUITE(services) SUITE(exec) SUITE(system)

static int run(const test_case_t *cases, unsigned count)
{
    int failed = 0;
    for (unsigned i = 0; i < count; i++) {
        int before = test_failures;
        clock_t t0 = clock();
        cases[i].fn();
        printf("%s %s [%s] %.2fs\n", test_failures == before ? "ok  " : "FAIL", cases[i].name, cases[i].requirement, (double)(clock() - t0) / CLOCKS_PER_SEC);
        if (test_failures != before) failed++;
    }
    return failed;
}

int main(void)
{
    int failed = 0;
    failed += run(sm_tests, sm_test_count);
    failed += run(bus_tests, bus_test_count);
    failed += run(command_tests, command_test_count);
    failed += run(telemetry_tests, telemetry_test_count);
    failed += run(services_tests, services_test_count);
    failed += run(exec_tests, exec_test_count);
    failed += run(system_tests, system_test_count);
    printf("%d checks, %d failing checks, %d failing cases\n", test_checks, test_failures, failed);
    return failed == 0 ? 0 : 1;
}
