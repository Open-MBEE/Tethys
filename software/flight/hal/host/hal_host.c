/* Host-only file: the POSIX clock is the host measurement, never flight time. */
#define _POSIX_C_SOURCE 199309L
#include "hal/hal.h"
#include <string.h>
#include <time.h>
#include "argent_interfaces.h"

static argent_us_t sim_now;
static uint16_t riu_regs[ARGENT_REGISTER_MAP_COUNT][256];
static bool link_available = true;
static hal_uplink_t uplink[HAL_UPLINK_DEPTH];
static uint32_t uplink_head, uplink_count;
static uint64_t downlink_octets;
static hal_image_slot_t image_slots[HAL_IMAGE_SLOTS];
static uint32_t image_sum[HAL_IMAGE_SLOTS];
static argent_us_t watchdog_last_kick;

void hal_init(void)
{
    sim_now = 0;
    memset(riu_regs, 0, sizeof riu_regs);
    link_available = true;
    uplink_head = uplink_count = 0;
    downlink_octets = 0;
    memset(image_slots, 0, sizeof image_slots);
    memset(image_sum, 0, sizeof image_sum);
    watchdog_last_kick = 0;
}

argent_us_t hal_timer_now(void) { return sim_now; }
void hal_timer_advance(argent_us_t delta) { sim_now += delta; }

uint64_t hal_host_nanoseconds(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000000000u + (uint64_t)ts.tv_nsec;
}

static const argent_register_t *find_register(uint8_t map, uint16_t address)
{
    const argent_register_map_t *m;
    if (map >= ARGENT_REGISTER_MAP_COUNT) return NULL;
    m = &argent_register_maps[map];
    if (address >= m->address_limit) return NULL;
    for (uint16_t i = 0; i < m->register_count; i++) {
        const argent_register_t *r = &argent_registers[m->first_register + i];
        if (r->address == address) return r;
    }
    return NULL;
}

bool hal_riu_read(uint8_t map, uint16_t address, uint16_t *value)
{
    const argent_register_t *r = find_register(map, address);
    if (r == NULL || r->access == ARGENT_REGISTER_ACCESS_WRITE_ONLY) return false;
    *value = riu_regs[map][address];
    return true;
}

bool hal_riu_write(uint8_t map, uint16_t address, uint16_t value)
{
    const argent_register_t *r = find_register(map, address);
    if (r == NULL || r->access == ARGENT_REGISTER_ACCESS_READ_ONLY) return false;
    riu_regs[map][address] = value;
    return true;
}

bool hal_link_available(void) { return link_available; }
void hal_link_set_available(bool available) { link_available = available; }

bool hal_link_uplink_push(const hal_uplink_t *item)
{
    if (uplink_count >= HAL_UPLINK_DEPTH) return false;
    uplink[(uplink_head + uplink_count) % HAL_UPLINK_DEPTH] = *item;
    uplink_count++;
    return true;
}

bool hal_link_uplink_pop(hal_uplink_t *item)
{
    if (uplink_count == 0 || !link_available) return false;
    *item = uplink[uplink_head];
    uplink_head = (uplink_head + 1) % HAL_UPLINK_DEPTH;
    uplink_count--;
    return true;
}

void hal_link_downlink(uint32_t octets) { if (link_available) downlink_octets += octets; }
uint64_t hal_link_downlink_octets(void) { return downlink_octets; }

bool hal_image_write(uint8_t slot, uint32_t offset, const uint8_t *data, uint32_t length)
{
    /* The store keeps a ledger and a 16-bit sum of the content, not the bytes themselves. */
    if (slot >= HAL_IMAGE_SLOTS || offset > HAL_IMAGE_SLOT_BYTES || length > HAL_IMAGE_SLOT_BYTES - offset) return false;
    if (data != NULL) { for (uint32_t i = 0; i < length; i++) image_sum[slot] = (image_sum[slot] + data[i]) & 0xffffu; }
    else image_sum[slot] = (uint32_t)((image_sum[slot] + (uint64_t)(0x5au + slot) * length) & 0xffffu);
    if (offset + length > image_slots[slot].length) image_slots[slot].length = offset + length;
    image_slots[slot].checksum = image_sum[slot];
    image_slots[slot].valid = 0;
    return true;
}

bool hal_image_verify(uint8_t slot, uint32_t expected_checksum)
{
    if (slot >= HAL_IMAGE_SLOTS || image_slots[slot].length == 0) return false;
    image_slots[slot].valid = image_sum[slot] == expected_checksum ? 1 : 0;
    return image_slots[slot].valid != 0;
}

const hal_image_slot_t *hal_image_slot(uint8_t slot) { return slot < HAL_IMAGE_SLOTS ? &image_slots[slot] : NULL; }

void hal_image_mark(uint8_t slot, uint32_t length, uint32_t checksum, bool valid)
{
    if (slot >= HAL_IMAGE_SLOTS) return;
    image_slots[slot].length = length;
    image_slots[slot].checksum = checksum;
    image_sum[slot] = checksum;
    image_slots[slot].valid = valid ? 1 : 0;
}

void hal_watchdog_kick(argent_us_t now) { watchdog_last_kick = now; }
bool hal_watchdog_expired(argent_us_t now, argent_us_t period) { return now > watchdog_last_kick && now - watchdog_last_kick > period; }
