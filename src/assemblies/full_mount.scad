include <../config.scad>
use <az_yoke.scad>
use <payload_stage.scad>
use <alt_drive_stage.scad>

ALT_ANGLE = is_undef(ALT_ANGLE) ? 0 : ALT_ANGLE;

module alt_drive_to_world(axis_z) {
    // ALT-drive local X -> world Y, local Y -> world Z,
    // local +Z -> world -X (outboard of the drive-side yoke arm).
    multmatrix([
        [0, 0, -1, -(YOKE_INNER_W / 2 + YOKE_ARM_T)],
        [1, 0,  0, 0],
        [0, 1,  0, axis_z],
        [0, 0,  0, 1]
    ]) children();
}

module full_mount(altitude_angle = ALT_ANGLE,
                  show_alt_guard = true) {
    az_yoke();

    yoke_stage_z = AZ_BASE_PLATE_H + AZ_COVER_H + AZ_GLIDE_GAP +
                   AZ_TURNTABLE_H;
    slot_floor = YOKE_BRIDGE_H - YOKE_SLOT_DEPTH;
    altitude_axis_z = yoke_stage_z + slot_floor + YOKE_AXIS_Z;

    // Payload/clamps rotate around the X-axis together with the steel ALT shaft.
    translate([0, 0, altitude_axis_z])
        rotate([altitude_angle, 0, 0]) payload_stage();

    // The gearbox is fixed to the outside face of yoke_arm_drive.
    alt_drive_to_world(altitude_axis_z)
        alt_drive_stage(show_guard = show_alt_guard,
                        show_arm = false,
                        show_motor = true,
                        show_shaft = false);
}

full_mount();
