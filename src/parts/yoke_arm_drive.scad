include <../config.scad>
use <../lib/util.scad>
use <../lib/hardware.scad>

module yoke_arm_profile_2d(boss_d = YOKE_DRIVE_BOSS_D) {
    union() {
        // 28 mm tenon fits the bridge slot; its shoulder emerges above the bridge.
        translate([0, 9]) rounded_rect_2d(size = [YOKE_TENON_LEN, 18], r = 3);
        hull() {
            translate([0, 12]) circle(r = YOKE_ARM_W / 2);
            translate([0, YOKE_AXIS_Z]) circle(r = YOKE_ARM_W / 2);
        }
        translate([0, YOKE_AXIS_Z]) circle(d = boss_d);
    }
}

module yoke_arm_drive() {
    difference() {
        linear_extrude(height = YOKE_ARM_T)
            yoke_arm_profile_2d(boss_d = YOKE_DRIVE_BOSS_D);

        // 608 bearing loads from the outside. A thin inner lip retains it.
        translate([0, YOKE_AXIS_Z, -EPS])
            cylinder(d = BEARING_608_OD + PRESS_FIT,
                     h = YOKE_BEARING_POCKET_DEPTH + EPS);
        translate([0, YOKE_AXIS_Z, -EPS])
            cylinder(d = AXIS_CLEARANCE_D, h = YOKE_ARM_T + 2 * EPS);

        // Four M3 mounting points for the future altitude gearbox inner plate.
        translate([0, YOKE_AXIS_Z, -EPS])
            four_at_radius(r = YOKE_GEARBOX_BOLT_R, phase = 45) {
                cylinder(d = M3_CLEARANCE_D, h = YOKE_ARM_T + 2 * EPS);
                translate([0, 0, YOKE_ARM_T - 2.8])
                    m3_nut_pocket(h = 2.8 + EPS);
            }

        // Transverse M4 bridge lock bolt through the inserted tenon.
        translate([0, YOKE_LOCK_LOCAL_Y, YOKE_ARM_T / 2])
            rotate([0, 90, 0])
                cylinder(d = M4_CLEARANCE_D,
                         h = YOKE_TENON_LEN + 2 * EPS, center = true);
    }
}

yoke_arm_drive();
