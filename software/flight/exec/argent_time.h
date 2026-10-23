/* Simulated time of the Argent Flight Executive: integer microseconds since the mission epoch.
 * No flight code reads a wall clock; the host HAL advances this clock frame by frame. */
#ifndef ARGENT_TIME_H
#define ARGENT_TIME_H
#include <stdint.h>

typedef uint64_t argent_us_t;

#define ARGENT_US_PER_S ((argent_us_t)1000000u)
#define ARGENT_MINOR_FRAME_US ((argent_us_t)125000u)
#define ARGENT_MINOR_FRAMES 8u
#define ARGENT_MAJOR_FRAME_US (ARGENT_MINOR_FRAME_US * ARGENT_MINOR_FRAMES)

static inline argent_us_t argent_s_to_us(double seconds)
{
    /* Initialisation-time conversion of table values; the scheduling path works in integers. */
    return (argent_us_t)(seconds * 1000000.0 + 0.5);
}

#endif
