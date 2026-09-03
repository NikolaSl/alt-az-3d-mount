include <../config.scad>
use <../lib/util.scad>

module camera_screw_knob() {
    difference() {
        union() {
            cylinder(d = CAMERA_KNOB_D, h = CAMERA_KNOB_H, $fn = 64);
            for (a = [0 : 30 : 330])
                rotate([0, 0, a]) translate([CAMERA_KNOB_D / 2, 0, CAMERA_KNOB_H / 2])
                    cube([CAMERA_KNOB_RIB_RADIAL_T, 4.0, CAMERA_KNOB_H], center = true);
        }
        translate([0, 0, -EPS])
            cylinder(d = TRIPOD_CLEARANCE_D, h = CAMERA_KNOB_H + 2 * EPS);
        // Captures a normal metal 1/4-20 hex bolt; verify the exact bolt head.
        translate([0, 0, -EPS])
            hex_prism(af = CAMERA_BOLT_HEAD_AF,
                      h = CAMERA_BOLT_HEAD_H + EPS,
                      rotation = 30);
    }
}

camera_screw_knob();
