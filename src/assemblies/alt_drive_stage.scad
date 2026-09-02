include <../config.scad>
use <../parts/yoke_arm_drive.scad>
use <../parts/alt_gearbox_plate.scad>
use <../parts/alt_gearbox_guard.scad>
use <../lib/alt_reducer20.scad>

module byj_visual() {
    // Motor front face is Z=0; body extends behind the mounting plate.
    color([0.45, 0.45, 0.48, 0.75])
        translate([BYJ_BODY_CENTER_FROM_SHAFT[0],
                   BYJ_BODY_CENTER_FROM_SHAFT[1],
                   -BYJ_BODY_H])
            cylinder(d = BYJ_BODY_D, h = BYJ_BODY_H);
    color([0.70, 0.70, 0.72, 0.9])
        translate([0, 0, -BYJ_FLANGE_T])
            cylinder(d = BYJ_BOSS_D,
                     h = BYJ_BOSS_H + BYJ_FLANGE_T);
    color("silver") cylinder(d = BYJ_SHAFT_D, h = BYJ_SHAFT_L);
}

module alt_drive_stage(show_guard = true,
                       show_arm = true,
                       show_motor = true,
                       show_shaft = true,
                       exploded = 0) {
    // The output shaft/bearing axis is local Z. In this standalone view +Z is
    // outboard, so the yoke arm and motor body are shown behind Z=0.
    assert(ALT_OUTPUT_SPACER_D <= 12.5,
           "Spacer must bear on the 608 inner ring, not the outer race");
    assert(ALT_SHAFT_L / 2 - YOKE_OUTER_W / 2 > ALT_OUTPUT_HUB_H +
           ALT_UPPER_GEAR_Z - GEAR_FACE - 1,
           "ALT shaft has insufficient drive-side projection");

    if (show_arm)
        color([0.25, 0.45, 0.85, 0.35])
            mirror([0, 0, 1])
                translate([0, -YOKE_AXIS_Z, 0]) yoke_arm_drive();

    color("goldenrod") alt_gearbox_plate();
    alt_reducer_visual(exploded = exploded);

    if (show_motor)
        translate([ALT_MOTOR[0], ALT_MOTOR[1], 0])
            rotate([0, 0, ALT_MOTOR_ROT]) byj_visual();

    if (show_guard)
        translate([0, 0, ALT_PLATE_T + exploded])
            color([0.55, 0.75, 0.90, 0.35]) alt_gearbox_guard();

    if (show_shaft)
        color("silver")
            translate([0, 0, -YOKE_ARM_T - 2])
                cylinder(d = AXIS_SHAFT_D,
                         h = ALT_OUTPUT_HUB_H + ALT_UPPER_GEAR_Z +
                             YOKE_ARM_T + 8);
}

alt_drive_stage();
