/* Parameter/boot/update application: BootUpdateManager machine over the image service and the
 * parameter tables; parameter table CRCs are published to the data store task. */
#include "apps/apps.h"

static void pbu_e1(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; sys->app.segments_received++; image_receive_segment(&sys->images, (uint32_t)ev->arg[1], (uint32_t)ev->arg[0]); /* message order: length, offset */ }
static void pbu_e2(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; sys->app.upload_verified = true; image_verify(&sys->images); }
static void pbu_e3(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; sys->app.active_slot = ARGENT_IMAGE_SLOT_BACKUP; image_activate(&sys->images); }
static void pbu_e4(sm_instance_t *sm, const sm_event_t *ev) { argent_system_t *sys = sm->ctx; (void)ev; sys->app.active_slot = ARGENT_IMAGE_SLOT_PRIMARY; image_rollback(&sys->images); }
static void pbu_entry_boot_rom(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.boots++; }
static void pbu_entry_safe_image(sm_instance_t *sm, int16_t s) { argent_system_t *sys = sm->ctx; (void)s; sys->app.active_slot = ARGENT_IMAGE_SLOT_SAFE; sys->app.fallbacks++; }

static void pbu_task(void *ctx, uint32_t minor_frame) { (void)ctx; (void)minor_frame; }
static void boot_update_task(void *ctx, uint32_t minor_frame) { (void)ctx; (void)minor_frame; }
static void table_task(void *ctx, uint32_t minor_frame)
{
    argent_system_t *sys = ctx;
    if (minor_frame == 0) for (uint16_t t = 0; t < ARGENT_PARAMETER_TABLE_COUNT; t++) (void)parameter_table_crc(&sys->params, t);
}

void app_pbu_init(argent_system_t *sys)
{
    sm_instance_t *sm = &sys->sm[SM_BOOT_UPDATE_MANAGER];
    sm_register_effect(sm, "BOOT_UPDATE_MANAGER_E1", pbu_e1);
    sm_register_effect(sm, "BOOT_UPDATE_MANAGER_E2", pbu_e2);
    sm_register_effect(sm, "BOOT_UPDATE_MANAGER_E3", pbu_e3);
    sm_register_effect(sm, "BOOT_UPDATE_MANAGER_E4", pbu_e4);
    sm_register_entry(sm, "TethysFlightBehaviour::BootUpdateManager::bootRom", pbu_entry_boot_rom);
    sm_register_entry(sm, "TethysFlightBehaviour::BootUpdateManager::safeImage", pbu_entry_safe_image);
    exec_bind_task(&sys->exec, "parameterBootUpdateTask", pbu_task, sys);
    exec_bind_task(&sys->exec, "bootUpdateTask", boot_update_task, sys);
    exec_bind_task(&sys->exec, "tableTask", table_task, sys);
}
