include <../config.scad>
use <../lib/util.scad>

module payload_clamp_upper() {
    difference() {
        rounded_plate(size = [SHAFT_CLAMP_W, SHAFT_CLAMP_L],
                      r = 3, h = PAYLOAD_CLAMP_UPPER_H);

        // Lower semicircle of the shaft bore; the extra material above the bore
        // is also the structural riser that keeps the payload screw knob clear
        // of the horizontal ALT shaft through the full balancing-slot travel.
        rotate([0, 90, 0])
            cylinder(d = AXIS_SHAFT_D + 0.14,
                     h = SHAFT_CLAMP_W + 2 * EPS, center = true);

        for (y = [-PAYLOAD_CLAMP_BOLT_Y, PAYLOAD_CLAMP_BOLT_Y])
            translate([0, y, -EPS])
                cylinder(d = M3_CLEARANCE_D,
                         h = PAYLOAD_CLAMP_UPPER_H + 2 * EPS);
    }
}

payload_clamp_upper();
