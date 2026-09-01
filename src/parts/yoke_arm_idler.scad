include <../config.scad>
use <../lib/util.scad>

module yoke_arm_profile_2d() {
    union() {
        translate([0, 9]) rounded_rect_2d(size = [YOKE_TENON_LEN, 18], r = 3);
        hull() {
            translate([0, 12]) circle(r = YOKE_ARM_W / 2);
            translate([0, YOKE_AXIS_Z]) circle(r = YOKE_ARM_W / 2);
        }
        translate([0, YOKE_AXIS_Z]) circle(d = YOKE_IDLER_BOSS_D);
    }
}

module yoke_arm_idler() {
    difference() {
        linear_extrude(height = YOKE_ARM_T) yoke_arm_profile_2d();

        translate([0, YOKE_AXIS_Z, -EPS])
            cylinder(d = BEARING_608_OD + PRESS_FIT,
                     h = YOKE_BEARING_POCKET_DEPTH + EPS);
        translate([0, YOKE_AXIS_Z, -EPS])
            cylinder(d = AXIS_CLEARANCE_D, h = YOKE_ARM_T + 2 * EPS);

        translate([0, YOKE_LOCK_LOCAL_Y, YOKE_ARM_T / 2])
            rotate([0, 90, 0])
                cylinder(d = M4_CLEARANCE_D,
                         h = YOKE_TENON_LEN + 2 * EPS, center = true);
    }
}

yoke_arm_idler();
