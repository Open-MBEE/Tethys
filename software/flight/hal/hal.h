/* Hardware abstraction layer of the Argent Flight Executive. The only implementation is the host
 * simulation in hal/host (RIU registers per the register maps, AABP-1 frame transport, MLS-2 link,
 * timer, image store). Flight code never touches the host below this interface. */
#ifndef ARGENT_HAL_H
#define ARGENT_HAL_H
#include <stdbool.h>
#include <stdint.h>
#include "exec/argent_time.h"

#define HAL_UPLINK_DEPTH 64u
#define HAL_UPLINK_ARGS 4u
#define HAL_UPLINK_TEXT 64u
#define HAL_IMAGE_SLOTS 3u
#define HAL_IMAGE_SLOT_BYTES (12u * 1024u * 1024u)

typedef struct {
    char kind;                       /* 'c' dictionary command, 'i' application-command item */
    char name[HAL_UPLINK_TEXT];
    double arg[HAL_UPLINK_ARGS];
    uint8_t arg_count;
    char text[HAL_UPLINK_TEXT];
    uint8_t two_step_execute;        /* second step of a hazardous command */
} hal_uplink_t;

typedef struct {
    uint32_t length;
    uint32_t checksum;               /* 16-bit checksum of the stored image, zero when empty */
    uint8_t valid;
} hal_image_slot_t;

void hal_init(void);
/* Simulated time (microseconds); advanced only by the executive. */
argent_us_t hal_timer_now(void);
void hal_timer_advance(argent_us_t delta);
/* Host-measured time for WCET-versus-host reporting only; never used for scheduling. */
uint64_t hal_host_nanoseconds(void);
/* RIU registers: map index and address from argent_registers[]; false on an illegal access. */
bool hal_riu_read(uint8_t map, uint16_t address, uint16_t *value);
bool hal_riu_write(uint8_t map, uint16_t address, uint16_t value);
/* MLS-2 link: availability and the uplink queue the host fills from the stimulus. */
bool hal_link_available(void);
void hal_link_set_available(bool available);
bool hal_link_uplink_push(const hal_uplink_t *item);
bool hal_link_uplink_pop(hal_uplink_t *item);
void hal_link_downlink(uint32_t octets);
uint64_t hal_link_downlink_octets(void);
/* Image store: three slots (primary, backup, safe) of the model's ImageSlot enumeration. */
bool hal_image_write(uint8_t slot, uint32_t offset, const uint8_t *data, uint32_t length);
bool hal_image_verify(uint8_t slot, uint32_t expected_checksum);
const hal_image_slot_t *hal_image_slot(uint8_t slot);
void hal_image_mark(uint8_t slot, uint32_t length, uint32_t checksum, bool valid);
/* Watchdog of the board support package: kicked every minor frame; expires when not kicked. */
void hal_watchdog_kick(argent_us_t now);
bool hal_watchdog_expired(argent_us_t now, argent_us_t period);

#endif
