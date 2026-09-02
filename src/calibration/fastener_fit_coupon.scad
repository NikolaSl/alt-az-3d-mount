include <../config.scad>
use <../lib/util.scad>

// Fastener/nut-trap calibration. Print flat, no supports.
// Exact left-to-right test sizes are documented in CALIBRATION.md.

COUPON_W = 118;
COUPON_H = 82;
COUPON_T = 8;
M3_TEST_D = [3.10, 3.20, 3.30, 3.40];
M4_TEST_D = [4.20, 4.30, 4.40, 4.50];
M3_AF_TEST = [5.50, 5.65, 5.80];
M4_AF_TEST = [7.00, 7.15, 7.30];

module hex_pocket(af, depth) {
    hex_prism(af = af, h = depth + EPS, rotation = 30);
}

module fastener_fit_coupon() {
    difference() {
        rounded_plate([COUPON_W, COUPON_H], r = 5, h = COUPON_T);

        for (i = [0 : len(M3_TEST_D) - 1])
            translate([-42 + i * 28, 28, -EPS])
                cylinder(d = M3_TEST_D[i], h = COUPON_T + 2 * EPS);

        for (i = [0 : len(M4_TEST_D) - 1])
            translate([-42 + i * 28, 7, -EPS])
                cylinder(d = M4_TEST_D[i], h = COUPON_T + 2 * EPS);

        for (i = [0 : len(M3_AF_TEST) - 1])
            translate([-42 + i * 18, -20, COUPON_T - 3.2])
                hex_pocket(M3_AF_TEST[i], 3.2);

        for (i = [0 : len(M4_AF_TEST) - 1])
            translate([8 + i * 20, -20, COUPON_T - 4.0])
                hex_pocket(M4_AF_TEST[i], 4.0);

        translate([-32, -35, COUPON_T - (TRIPOD_NUT_H + 0.4)])
            hex_pocket(TRIPOD_NUT_AF + FIT, TRIPOD_NUT_H + 0.4);
        translate([32, -35, COUPON_T - 7.2])
            hex_pocket(13.0 + FIT, 7.2);

        translate([-53, 35, -EPS])
            cylinder(d = 4, h = COUPON_T + 2 * EPS);
    }
}

fastener_fit_coupon();
