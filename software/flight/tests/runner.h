/* A small self-contained unit-test runner: each test_*.c registers its cases in a table. */
#ifndef ARGENT_TEST_RUNNER_H
#define ARGENT_TEST_RUNNER_H
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

typedef struct { const char *name; const char *requirement; void (*fn)(void); } test_case_t;

extern int test_failures;
extern int test_checks;
#define CHECK(cond) do { test_checks++; if (!(cond)) { test_failures++; \
    printf("  FAIL %s:%d: %s\n", __FILE__, __LINE__, #cond); } } while (0)
#define CHECK_EQ_STR(a, b) do { test_checks++; if (strcmp((a), (b)) != 0) { test_failures++; \
    printf("  FAIL %s:%d: \"%s\" != \"%s\"\n", __FILE__, __LINE__, (a), (b)); } } while (0)

#endif
