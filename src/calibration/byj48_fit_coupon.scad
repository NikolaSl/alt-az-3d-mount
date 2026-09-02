include <../config.scad>
use <../lib/util.scad>
use <../lib/hardware.scad>

// 28BYJ-48 mount + Double-D shaft-fit coupon.
// The left side validates the actual motor flange/boss; the three bosses on
// the right test progressively looser Double-D sockets without printing gears.

COUPON_W = 112;
COUPON_H = 50;
COUPON_T = 4;
SHAFT_TEST_EXTRA = [0.10, 0.18, 0.26];
SOCKET_BOSS_D = 12;
SOCKET_H = 8;
MOTOR_CENTER = [-28, 8];

module double_d_cutout(d, flats, h) {
    intersection() {
        cylinder(d = d, h = h);
        translate([-d, -flats / 2, 0]) cube([2 * d, flats, h]);
    }
}

module byj48_fit_coupon() {
    difference() {
        union() {
            rounded_plate([COUPON_W, COUPON_H], r = 5, h = COUPON_T);
            for (i = [0 : len(SHAFT_TEST_EXTRA) - 1])
                translate([8 + i * 20, 5, COUPON_T - 0.2])
                    cylinder(d = SOCKET_BOSS_D, h = SOCKET_H + 0.2);
        }

        translate([MOTOR_CENTER[0], MOTOR_CENTER[1], COUPON_T / 2])
            byj_mount_holes(h = COUPON_T + 2,
                            rotation = 0,
                            shaft_clearance_d = BYJ_BOSS_D + 0.4,
                            mount_hole_d = BYJ_MOUNT_HOLE_D + FIT);

        // Three blind Double-D sockets: +0.10, +0.18 and +0.26 mm.
        for (i = [0 : len(SHAFT_TEST_EXTRA) - 1]) {
            e = SHAFT_TEST_EXTRA[i];
            translate([8 + i * 20, 5, COUPON_T + 1.0])
                double_d_cutout(d = BYJ_SHAFT_D + e,
                                flats = BYJ_SHAFT_FLAT + e,
                                h = SOCKET_H + EPS);
        }

        translate([-50, -20, -EPS])
            cylinder(d = 4, h = COUPON_T + 2 * EPS);
    }
}

byj48_fit_coupon();
