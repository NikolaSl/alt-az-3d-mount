include <../config.scad>
use <../lib/util.scad>
use <../lib/hardware.scad>
use <../lib/alt_reducer20.scad>

module alt_gearbox_plate() {
    difference() {
        linear_extrude(height = ALT_PLATE_T)
            union() {
                alt_outline_2d();
                for (p = ALT_GUARD_SCREW_POS)
                    translate(p) circle(d = ALT_GUARD_SCREW_BOSS_D);
            }

        // Expose the complete outer face of the 608 bearing and ALT shaft.
        translate([0, 0, -EPS])
            cylinder(d = ALT_PLATE_OUTPUT_CLEAR_D,
                     h = ALT_PLATE_T + 2 * EPS);

        // Four countersunk M3 screws enter the captive nuts already present
        // in yoke_arm_drive. Flush heads are required because the 48T gear
        // passes close to one of these screw positions.
        four_at_radius(r = YOKE_GEARBOX_BOLT_R, phase = 45) {
            translate([0, 0, -EPS])
                cylinder(d = M3_CLEARANCE_D,
                         h = ALT_PLATE_T + 2 * EPS);
            translate([0, 0, ALT_PLATE_T - ALT_YOKE_HEAD_RECESS_H])
                cylinder(d1 = M3_CLEARANCE_D,
                         d2 = ALT_YOKE_HEAD_RECESS_D,
                         h = ALT_YOKE_HEAD_RECESS_H + EPS);
        }

        // The 28BYJ-48 body stays behind the plate, while the 10 mm output
        // shaft points through the plate and carries the 12T pinion.
        translate([ALT_MOTOR[0], ALT_MOTOR[1], ALT_PLATE_T / 2])
            byj_mount_holes(h = ALT_PLATE_T + 2,
                            rotation = ALT_MOTOR_ROT,
                            shaft_clearance_d = BYJ_BOSS_D + 1.0);

        // The stationary M3 shoulder screw for the compound gear threads into
        // a captive M3 nut on the back side of this plate. The guard roof is
        // the second support of that axle.
        translate([ALT_INTERMEDIATE[0], ALT_INTERMEDIATE[1], -EPS])
            cylinder(d = M3_CLEARANCE_D,
                     h = ALT_PLATE_T + 2 * EPS);
        translate([ALT_INTERMEDIATE[0], ALT_INTERMEDIATE[1], -EPS])
            m3_nut_pocket(h = ALT_GUARD_NUT_DEPTH + EPS);

        // Captive nuts for the removable protective guard.
        for (p = ALT_GUARD_SCREW_POS) {
            translate([p[0], p[1], -EPS])
                cylinder(d = M3_CLEARANCE_D,
                         h = ALT_PLATE_T + 2 * EPS);
            translate([p[0], p[1], -EPS])
                m3_nut_pocket(h = ALT_GUARD_NUT_DEPTH + EPS);
        }
    }
}

alt_gearbox_plate();
