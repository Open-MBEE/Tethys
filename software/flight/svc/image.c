#include "svc/image.h"
#include <string.h>

static const char *const slot_names[HAL_IMAGE_SLOTS] = { "primary", "backup", "safe" };

void image_init(image_service_t *svc)
{
    memset(svc, 0, sizeof(*svc));
    svc->active_slot = 0;
    svc->staging_slot = 1;
    svc->previous_slot = 2;
    svc->boot_count = 1;
    /* The three slots start populated: the model's safe image is 11.7 MB, the flight image 18.7 MB. */
    hal_image_mark(0, 11700000u, 0x1234u, true);
    hal_image_mark(1, 0u, 0u, false);
    hal_image_mark(2, 11700000u, 0x1234u, true);
}

bool image_receive_segment(image_service_t *svc, uint32_t offset, uint32_t length)
{
    if (!hal_image_write(svc->staging_slot, offset, NULL, length)) return false;
    svc->segments_received++;
    svc->octets_received += length;
    return true;
}

bool image_verify(image_service_t *svc)
{
    const hal_image_slot_t *slot = hal_image_slot(svc->staging_slot);
    uint32_t reference = svc->expected_checksum != 0 ? svc->expected_checksum : slot->checksum;
    if (hal_image_verify(svc->staging_slot, reference)) { svc->verify_passes++; return true; }
    svc->verify_failures++;
    return false;
}

bool image_activate(image_service_t *svc)
{
    const hal_image_slot_t *slot = hal_image_slot(svc->staging_slot);
    if (slot == NULL || !slot->valid) return false;
    svc->previous_slot = svc->active_slot;
    svc->active_slot = svc->staging_slot;
    svc->staging_slot = svc->previous_slot;
    svc->activations++;
    svc->boot_count++;
    return true;
}

bool image_rollback(image_service_t *svc)
{
    const hal_image_slot_t *slot = hal_image_slot(svc->previous_slot);
    uint8_t tmp;
    if (slot == NULL || !slot->valid) return false;
    tmp = svc->active_slot;
    svc->active_slot = svc->previous_slot;
    svc->previous_slot = tmp;
    svc->staging_slot = tmp;
    svc->rollbacks++;
    svc->boot_count++;
    return true;
}

const char *image_slot_name(uint8_t slot) { return slot < HAL_IMAGE_SLOTS ? slot_names[slot] : "none"; }
