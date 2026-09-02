include <../config.scad>
use <../lib/util.scad>

// Printer/material calibration coupon for the two most important cylindrical
// interfaces in the mount: 608ZZ bearing seats and the Ø8 ALT shaft.
// Print flat, no supports. Positions are documented in CALIBRATION.md.

COUPON_W = 118;
COUPON_H = 76;
COUPON_T = 10;
BEARING_POCKET_DEPTH = 7.3;
BEARING_TEST_D = [21.90, 22.00, 22.10, 22.20];
SHAFT_TEST_D = [7.90, 8.00, 8.10, 8.20, 8.30];

module mechanical_fit_coupon() {
    difference() {
        rounded_plate([COUPON_W, COUPON_H], r = 5, h = COUPON_T);

        // 608ZZ blind seats. A 10 mm push-out bore through the remaining floor
        // makes the bearing removable without destroying the coupon.
        for (i = [0 : len(BEARING_TEST_D) - 1]) {
            x = -42 + i * 28;
            translate([x, 21, COUPON_T - BEARING_POCKET_DEPTH])
                cylinder(d = BEARING_TEST_D[i], h = BEARING_POCKET_DEPTH + EPS);
            translate([x, 21, -EPS])
                cylinder(d = 10, h = COUPON_T + 2 * EPS);
        }

        // Ø8 shaft through-bores. The five sizes bracket the nominal shaft.
        for (i = [0 : len(SHAFT_TEST_D) - 1]) {
            x = -40 + i * 20;
            translate([x, -18, -EPS])
                cylinder(d = SHAFT_TEST_D[i], h = COUPON_T + 2 * EPS);
        }

        // Orientation key: one asymmetric corner hole identifies the left edge.
        translate([-53, -31, -EPS])
            cylinder(d = 4, h = COUPON_T + 2 * EPS);
    }
}

mechanical_fit_coupon();
