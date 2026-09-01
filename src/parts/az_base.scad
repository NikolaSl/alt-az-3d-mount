include <../config.scad>
use <../lib/util.scad>
use <../lib/hardware.scad>

module az_base() {
    difference() {
        union() {
            cylinder(d = AZ_BASE_D, h = AZ_BASE_PLATE_H);

            // Central tripod riser keeps the hanging azimuth motor above the tripod head.
            translate([0, 0, -AZ_PEDESTAL_H])
                cylinder(d = AZ_PEDESTAL_D, h = AZ_PEDESTAL_H);

            four_at_radius(r = AZ_COVER_BOLT_R, phase = 45)
                cylinder(d = 9.0, h = AZ_BASE_PLATE_H + 2.0);
        }

        // M8 azimuth stud and captive nut pocket.
        translate([0, 0, -9.2]) m8_nut_pocket(h = 7.2);
        translate([0, -7.2, -9.2]) cube([AZ_PEDESTAL_D / 2 + 2, 14.4, 7.2]);
        translate([0, 0, -9.2]) cylinder(d = M8_CLEARANCE_D, h = AZ_BASE_PLATE_H + 9.4);

        // Standard 1/4-20 tripod captive nut, loaded from the side.
        translate([0, 0, -20.2]) tripod_nut_pocket(h = TRIPOD_NUT_H + 0.4);
        translate([-AZ_PEDESTAL_D / 2 - 2, -6.2, -20.2])
            cube([AZ_PEDESTAL_D / 2 + 2, 12.4, TRIPOD_NUT_H + 0.4]);
        translate([0, 0, -AZ_PEDESTAL_H - EPS])
            cylinder(d = TRIPOD_CLEARANCE_D, h = AZ_PEDESTAL_H - 13.8);

        // 28BYJ-48 motor: installed from below.
        translate([REDUCER_MOTOR[0], REDUCER_MOTOR[1], AZ_BASE_PLATE_H / 2])
            byj_mount_holes(h = AZ_BASE_PLATE_H + 2,
                            rotation = REDUCER_MOTOR_ROT,
                            shaft_clearance_d = BYJ_BOSS_D + 1.0);

        // Intermediate reduction axle.
        translate([REDUCER_INTERMEDIATE[0], REDUCER_INTERMEDIATE[1], -EPS])
            cylinder(d = INTERMEDIATE_AXLE_D + 0.15, h = AZ_BASE_PLATE_H + 2 * EPS);
        translate([REDUCER_INTERMEDIATE[0], REDUCER_INTERMEDIATE[1], -EPS])
            m3_nut_pocket(h = 2.7 + FIT);

        four_at_radius(r = AZ_COVER_BOLT_R, phase = 45) {
            translate([0, 0, -EPS])
                cylinder(d = M3_CLEARANCE_D, h = AZ_BASE_PLATE_H + 2.5);
            translate([0, 0, -EPS]) m3_nut_pocket(h = 2.8 + FIT);
        }

        translate([50, 38, -EPS])
            slot_3d(length = 18, d = 6, h = AZ_BASE_PLATE_H + 2 * EPS);
    }
}

az_base();
