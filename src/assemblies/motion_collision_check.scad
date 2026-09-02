// Diagnostic boolean assembly for automated motion QA.
// Exporting this file should produce EMPTY geometry when the moving payload
// does not collide with the selected fixed obstruction set.
//
// The lower diagnostic is a conservative rotationally symmetric envelope.
// CLEARANCE_MARGIN expands that lower envelope analytically, avoiding expensive
// 3D Minkowski operations during dense sweeps.

include <../config.scad>
use <yoke_stage.scad>
use <../parts/alt_gearbox_plate.scad>
use <../parts/alt_gearbox_guard.scad>
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

module moving_payload_world() {
    rotate([0, 0, AZ_ANGLE])
        translate([0, 0, ALT_AXIS_Z_QA])
            rotate([ALT_ANGLE, 0, 0])
                payload_collision_body_local();
}

module alt_external_obstruction_local() {
    alt_gearbox_plate();
    translate([0, 0, ALT_PLATE_T]) alt_gearbox_guard();

    translate([ALT_MOTOR[0], ALT_MOTOR[1], 0])
        rotate([0, 0, ALT_MOTOR_ROT]) {
            translate([BYJ_BODY_CENTER_FROM_SHAFT[0],
                       BYJ_BODY_CENTER_FROM_SHAFT[1],
                       -BYJ_BODY_H])
                cylinder(d = BYJ_BODY_D, h = BYJ_BODY_H);
            translate([0, 0, -BYJ_FLANGE_T])
                cylinder(d = BYJ_BOSS_D,
                         h = BYJ_BOSS_H + BYJ_FLANGE_T);
        }
}

module fixed_upper_obstructions() {
    rotate([0, 0, AZ_ANGLE]) {
        translate([0, 0, YOKE_STAGE_Z_QA]) yoke_stage();
        alt_drive_to_world_qa(ALT_AXIS_Z_QA) alt_external_obstruction_local();
    }
}

module expanded_cylinder(d, h, z0, margin) {
    translate([0, 0, z0 - margin])
        cylinder(d = d + 2 * margin, h = h + 2 * margin);
}

module conservative_lower_obstructions() {
    m = max(0, CLEARANCE_MARGIN);

    // Full solid envelopes intentionally fill openings and cable cut-outs.
    expanded_cylinder(AZ_BASE_D, AZ_BASE_PLATE_H, 0, m);
    expanded_cylinder(AZ_PEDESTAL_D, AZ_PEDESTAL_H, -AZ_PEDESTAL_H, m);
    expanded_cylinder(AZ_BASE_D, AZ_COVER_H + AZ_GLIDE_GAP,
                      AZ_BASE_PLATE_H, m);
    expanded_cylinder(AZ_TURNTABLE_D, AZ_TURNTABLE_H,
                      AZ_BASE_PLATE_H + AZ_COVER_H + AZ_GLIDE_GAP, m);

    if (WITH_TABLETOP)
        expanded_cylinder(
            TABLETOP_BASE_D, TABLETOP_BASE_T,
            -AZ_PEDESTAL_H - TABLETOP_BASE_T + TABLETOP_LOCATOR_DEPTH,
            m);
}

if (CHECK_MODE == 0)
    intersection() {
        moving_payload_world();
        fixed_upper_obstructions();
    }
else if (CHECK_MODE == 1)
    intersection() {
        moving_payload_world();
        conservative_lower_obstructions();
    }
else
    assert(false, "Unknown CHECK_MODE; expected 0 (upper) or 1 (lower)");
