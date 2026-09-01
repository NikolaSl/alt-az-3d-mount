include <../config.scad>
use <../lib/util.scad>
use <../lib/hardware.scad>

module az_turntable() {
    difference() {
        cylinder(d = AZ_TURNTABLE_D, h = AZ_TURNTABLE_H);

        // M8 azimuth axis passes through the centre. The top recess leaves room
        // for a washer and low-profile/Nyloc nut while keeping the top usable.
        translate([0, 0, -EPS])
            cylinder(d = M8_CLEARANCE_D, h = AZ_TURNTABLE_H + 2 * EPS);
        translate([0, 0, AZ_TURNTABLE_H - AZ_AXIS_NUT_RECESS_H])
            cylinder(d = AZ_AXIS_NUT_RECESS_D,
                     h = AZ_AXIS_NUT_RECESS_H + EPS);

        // Underside locator for the future 60-tooth output gear/hub.
        translate([0, 0, -EPS])
            cylinder(d = AZ_OUTPUT_LOCATOR_D + FIT,
                     h = AZ_OUTPUT_LOCATOR_DEPTH + EPS);

        // Four M3 screws connect the turntable to the output gear/hub.
        four_at_radius(r = AZ_OUTPUT_BOLT_R, phase = 45) {
            translate([0, 0, -EPS])
                cylinder(d = M3_CLEARANCE_D, h = AZ_TURNTABLE_H + 2 * EPS);
            translate([0, 0, AZ_TURNTABLE_H - 2.2])
                cylinder(d = 6.4, h = 2.2 + EPS);
        }

        // Four M4 mounting points for the two yoke feet. Captive nuts load
        // from the underside, so the future yoke can be removed from above.
        for (x = [-AZ_YOKE_MOUNT_X, AZ_YOKE_MOUNT_X])
            for (y = [-AZ_YOKE_MOUNT_Y, AZ_YOKE_MOUNT_Y]) {
                translate([x, y, -EPS])
                    cylinder(d = M4_CLEARANCE_D,
                             h = AZ_TURNTABLE_H + 2 * EPS);
                translate([x, y, -EPS])
                    m4_nut_pocket(h = AZ_YOKE_NUT_DEPTH + EPS);
            }
    }
}

az_turntable();
