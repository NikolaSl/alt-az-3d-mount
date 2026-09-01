include <../config.scad>
use <../lib/util.scad>

module camera_screw_knob() {
    difference() {
        union() {
            cylinder(d = 28.0, h = 8.0, $fn = 64);
            for (a = [0 : 30 : 330])
                rotate([0, 0, a]) translate([14.0, 0, 4.0])
                    cube([2.4, 4.0, 8.0], center = true);
        }
        translate([0, 0, -EPS])
            cylinder(d = TRIPOD_CLEARANCE_D, h = 8.0 + 2 * EPS);
        // Captures a normal metal 1/4-20 hex bolt; verify the exact bolt head.
        translate([0, 0, -EPS])
            hex_prism(af = 11.4, h = 4.6, rotation = 30);
    }
}

camera_screw_knob();
