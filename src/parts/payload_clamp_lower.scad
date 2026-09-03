include <../config.scad>
use <../lib/util.scad>
use <../lib/hardware.scad>

module payload_clamp_lower() {
    difference() {
        rounded_plate(size = [SHAFT_CLAMP_W, SHAFT_CLAMP_L],
                      r = 3, h = PAYLOAD_CLAMP_LOWER_H);

        // Upper semicircle of the 8 mm shaft bore; split face is the top face.
        translate([0, 0, PAYLOAD_CLAMP_LOWER_H])
            rotate([0, 90, 0])
                cylinder(d = AXIS_SHAFT_D + 0.14,
                         h = SHAFT_CLAMP_W + 2 * EPS, center = true);

        for (y = [-PAYLOAD_CLAMP_BOLT_Y, PAYLOAD_CLAMP_BOLT_Y]) {
            translate([0, y, -EPS])
                cylinder(d = M3_CLEARANCE_D,
                         h = PAYLOAD_CLAMP_LOWER_H + 2 * EPS);
            translate([0, y, -EPS])
                m3_nut_pocket(h = 2.8 + FIT);
        }
    }
}

payload_clamp_lower();
