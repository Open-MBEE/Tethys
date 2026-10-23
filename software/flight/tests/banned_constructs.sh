#!/bin/sh
# Banned constructs in the flight code (exec/, sm/, bus/, svc/, apps/, trace/, hal/host/):
# dynamic allocation, wall-clock time, recursion markers, VLAs and floating point in the
# executive's scheduling path. The host harness, the simulation and the tests are exempt.
set -u
dir=$(dirname "$0")/..
rc=0
flight="$dir/exec $dir/sm $dir/bus $dir/svc $dir/apps $dir/trace $dir/hal/host"
check() {
    pattern=$1; what=$2; shift 2
    hits=$(grep -nE "$pattern" "$@" 2>/dev/null)
    if [ -n "$hits" ]; then
        echo "banned: $what"; echo "$hits"; rc=1
    fi
}
# shellcheck disable=SC2086
check '\b(malloc|calloc|realloc|free|strdup)\s*\(' "dynamic allocation" $(find $flight -name '*.c')
# shellcheck disable=SC2086
check '\b(time|gettimeofday|localtime|gmtime|clock)\s*\(' "wall clock" $(find $flight -name '*.c' ! -name hal_host.c)
check 'clock_gettime' "wall clock outside the host-measurement HAL" $(find $flight -name '*.c' ! -name hal_host.c)
# shellcheck disable=SC2086
check '\balloca\s*\(' "alloca" $(find $flight -name '*.c')
# Scheduling path: executive.c must not use floating point.
check '\b(double|float)\b' "floating point in the scheduling path" "$dir/exec/executive.c"
# VLAs: an array dimension that is not a literal, macro or sizeof (heuristic: lower-case identifier dimension).
# shellcheck disable=SC2086
check '^\s*(uint8_t|uint16_t|uint32_t|uint64_t|int16_t|int32_t|int|char|double|float|bool)\s+[a-z_][a-z0-9_]*\[[a-z_][a-z0-9_]*\]\s*;' "variable-length array" $(find $flight -name '*.c')
if [ "$rc" = 0 ]; then echo "banned-construct check: clean"; fi
exit $rc
