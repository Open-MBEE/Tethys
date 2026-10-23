#include "tests/runner.h"
#include <stdlib.h>

int test_failures = 0;
int test_checks = 0;

extern const test_case_t sm_tests[];
extern const unsigned sm_test_count;

static int run(const test_case_t *cases, unsigned count)
{
    int failed = 0;
    for (unsigned i = 0; i < count; i++) {
        int before = test_failures;
        cases[i].fn();
        printf("%s %s [%s]\n", test_failures == before ? "ok  " : "FAIL", cases[i].name, cases[i].requirement);
        if (test_failures != before) failed++;
    }
    return failed;
}

int main(void)
{
    int failed = 0;
    failed += run(sm_tests, sm_test_count);
    printf("%d checks, %d failing checks, %d failing cases\n", test_checks, test_failures, failed);
    return failed == 0 ? 0 : 1;
}
