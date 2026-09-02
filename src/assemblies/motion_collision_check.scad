// Diagnostic boolean assembly for automated motion QA.
// Exporting this file should produce EMPTY geometry when the selected moving
// payload envelope does not collide with the selected fixed obstruction set.
//
// The diagnostic uses conservative external obstruction envelopes rather than
// internal gear tooth geometry. The lower AZ/tabletop envelope is deliberately
// rotationally symmetric and at least as large as the real exterior solids, so
// clearance proven against it at one AZ angle applies to the full 0..360° sweep.

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

module payload_collision_body_local_with_margin() {
    if (CLEARANCE_MARGIN > 0)
        minkowski() {
            payload_collision_body_local();
            sphere(r = CLEARANCE_MARGIN, $fn = 10);
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

module alt_external_obstruction_local() {
    alt_gearbox_plate();
    translate([0, 0, ALT_PLATE_T]) alt_gearbox_guard();

    // Conservative motor body/boss envelope behind the plate. Internal gears
    // are enclosed by the guard and are therefore not needed as collision solids.
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

module conservative_lower_obstructions() {
    // Full solid envelopes intentionally fill openings and cable cut-outs.
    // A payload that clears these solids clears the actual lower assembly.
    cylinder(d = AZ_BASE_D, h = AZ_BASE_PLATE_H);
    translate([0, 0, -AZ_PEDESTAL_H])
        cylinder(d = AZ_PEDESTAL_D, h = AZ_PEDESTAL_H);
    translate([0, 0, AZ_BASE_PLATE_H])
        cylinder(d = AZ_BASE_D, h = AZ_COVER_H + AZ_GLIDE_GAP);
    translate([0, 0, AZ_BASE_PLATE_H + AZ_COVER_H + AZ_GLIDE_GAP])
        cylinder(d = AZ_TURNTABLE_D, h = AZ_TURNTABLE_H);

    if (WITH_TABLETOP)
        translate([0, 0,
                   -AZ_PEDESTAL_H - TABLETOP_BASE_T + TABLETOP_LOCATOR_DEPTH])
            cylinder(d = TABLETOP_BASE_D, h = TABLETOP_BASE_T);
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
