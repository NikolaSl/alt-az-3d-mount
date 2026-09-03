include <../config.scad>
use <full_mount.scad>
use <../parts/tabletop_base_adapter.scad>

AZ_ANGLE = is_undef(AZ_ANGLE) ? 0 : AZ_ANGLE;
ALT_ANGLE = is_undef(ALT_ANGLE) ? 0 : ALT_ANGLE;
PAYLOAD_SCREW_Y = is_undef(PAYLOAD_SCREW_Y) ? PAYLOAD_SLOT_CENTER_Y : PAYLOAD_SCREW_Y;

module tabletop_full_mount(altitude_angle = ALT_ANGLE,
                           azimuth_angle = AZ_ANGLE,
                           payload_screw_y = PAYLOAD_SCREW_Y,
                           show_alt_guard = true) {
    full_mount(altitude_angle = altitude_angle,
               azimuth_angle = azimuth_angle,
               payload_screw_y = payload_screw_y,
               show_alt_guard = show_alt_guard);

    translate([0, 0,
               -AZ_PEDESTAL_H - TABLETOP_BASE_T + TABLETOP_LOCATOR_DEPTH])
        color([0.82, 0.68, 0.42, 0.90]) tabletop_base_adapter();
}

tabletop_full_mount();
