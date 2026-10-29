/* Image, boot and update service: the three image slots of the model's ImageSlot enumeration,
 * segment reception into a staging slot, verification, activation and rollback. */
#ifndef ARGENT_SVC_IMAGE_H
#define ARGENT_SVC_IMAGE_H
#include <stdbool.h>
#include <stdint.h>
#include "exec/argent_time.h"
#include "hal/hal.h"

typedef struct {
    uint8_t active_slot;             /* slot booted from */
    uint8_t staging_slot;            /* slot receiving segments */
    uint8_t previous_slot;           /* rollback target */
    uint32_t segments_received;
    uint64_t octets_received;
    uint32_t verify_passes, verify_failures;
    uint32_t activations, rollbacks;
    uint32_t boot_count;
    uint32_t expected_checksum;      /* announced by the uplinked image header (or computed) */
} image_service_t;

void image_init(image_service_t *svc);
bool image_receive_segment(image_service_t *svc, uint32_t offset, uint32_t length);
/* Verifies the staging slot; without an announced checksum the stored sum is accepted as the reference. */
bool image_verify(image_service_t *svc);
bool image_activate(image_service_t *svc);
bool image_rollback(image_service_t *svc);
const char *image_slot_name(uint8_t slot);

#endif
