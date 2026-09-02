// Diagnostic boolean assembly for automated motion QA.
// Exporting this file should produce EMPTY geometry when the selected moving
// payload envelope does not collide with the selected fixed obstruction set.

include <../config.scad>
use <az_stage.scad>
use <yoke_stage.scad>
use <alt_drive_stage.scad>
use <../parts/tabletop_base_adapter.scad>
use <../parts/payload_clamp_lower.scad>
use <../parts/payload_clamp_upper.scad>
use <../parts/payload_plate.scad>
use <../parts/camera_screw_knob.scad>

AZ_ANGLE = is_undef(AZ_ANGLE) ? 0 : AZ_ANGLE;
ALT_ANGLE = is_undef(ALT_ANGLE) ? 0 : ALT_ANGLE;
CHECK_MODE = is_undef(CHECK_MODE) ? 0 : CHECK_MODE; // 0=upper, 1=lower
WITH_TABLETOP = is_undef(WITH_TABLETOP) ? false : WITH_TABLETOP;
CLEARANCE_MARGIN = is_undef(CLEARANCE_MARGIN) ? 0 : CLEARANCE_MARGIN;

YOKE_STAGE_Z_QA = AZ_BASE_PLATE_H + AZ_COVER_H + AZ_GLIDE_GAP + AZ_TURNTABLE_H;
SLOT_FLOOR_QA = YOKE_BRIDGE_H - YOKE_SLOT_DEPTH;
ALT_AXIS_Z_QA = YOKE_STAGE_Z_QA + SLOT_FLOOR_QA + YOKE_AXIS_Z;

module alt_drive_to_world_qa(axis_z) {
    multmatrix([
        [0, 0, -1, -(YOKE_INNER_W / 2 + YOKE_ARM_T)],
        [1, 0,  0, 0],
        [0, 1,  0, axis_z],
        [0, 0,  0, 1]
    ]) children();
}

// Excludes the steel ALT shaft because shaft/bearing engagement is intentional.
module payload_collision_body_local() {
    for (x = [-PAYLOAD_CLAMP_X, PAYLOAD_CLAMP_X]) {
        translate([x, 0, -PAYLOAD_CLAMP_HALF_H]) payload_clamp_lower();
        translate([x, 0, 0]) payload_clamp_upper();
    }
    translate([0, 0, PAYLOAD_CLAMP_HALF_H]) payload_plate();
    translate([0, 8, 0]) camera_screw_knob();
}

module payload_collision_body_local_with_margin() {
    if (CLEARANCE_MARGIN > 0)
        minkowski() {
            payload_collision_body_local();
            sphere(r = CLEARANCE_MARGIN, $fn = 12);
        }
    else
        payload_collision_body_local();
}

module moving_payload_world() {
    rotate([0, 0, AZ_ANGLE])
        translate([0, 0, ALT_AXIS_Z_QA])
            rotate([ALT_ANGLE, 0, 0])
                payload_collision_body_local_with_margin();
}

module fixed_upper_obstructions() {
    rotate([0, 0, AZ_ANGLE]) {
        translate([0, 0, YOKE_STAGE_Z_QA]) yoke_stage();
        alt_drive_to_world_qa(ALT_AXIS_Z_QA)
            alt_drive_stage(show_guard = true,
                            show_arm = false,
                            show_motor = true,
                            show_shaft = false);
    }
}

module fixed_lower_obstructions() {
    az_stage();
    if (WITH_TABLETOP)
        translate([0, 0,
                   -AZ_PEDESTAL_H - TABLETOP_BASE_T + TABLETOP_LOCATOR_DEPTH])
            tabletop_base_adapter();
}

if (CHECK_MODE == 0)
    intersection() {
        moving_payload_world();
        fixed_upper_obstructions();
    }
else if (CHECK_MODE == 1)
    intersection() {
        moving_payload_world();
        fixed_lower_obstructions();
    }
else
    assert(false, "Unknown CHECK_MODE; expected 0 (upper) or 1 (lower)");
