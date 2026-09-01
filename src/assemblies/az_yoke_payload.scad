include <../config.scad>
use <az_yoke.scad>
use <payload_stage.scad>

module az_yoke_payload() {
    az_yoke();

    // World altitude-axis height:
    // AZ stack + yoke bridge slot floor + arm-local axis height.
    altitude_axis_z = AZ_BASE_PLATE_H + AZ_COVER_H + AZ_GLIDE_GAP +
                      AZ_TURNTABLE_H +
                      (YOKE_BRIDGE_H - YOKE_SLOT_DEPTH) + YOKE_AXIS_Z;

    translate([0, 0, altitude_axis_z])
        payload_stage();
}

az_yoke_payload();
