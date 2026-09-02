include <../config.scad>
use <full_mount.scad>
use <../parts/tabletop_base_adapter.scad>

ALT_ANGLE = is_undef(ALT_ANGLE) ? 0 : ALT_ANGLE;

module tabletop_full_mount(altitude_angle = ALT_ANGLE,
                           show_alt_guard = true) {
    full_mount(altitude_angle = altitude_angle,
               show_alt_guard = show_alt_guard);

    translate([0, 0,
               -AZ_PEDESTAL_H - TABLETOP_BASE_T + TABLETOP_LOCATOR_DEPTH])
        color([0.82, 0.68, 0.42, 0.90]) tabletop_base_adapter();
}

tabletop_full_mount();
