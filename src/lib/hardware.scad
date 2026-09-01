include <../config.scad>
use <util.scad>

module byj_mount_holes(h = 10, rotation = 0, shaft_clearance_d = 10.2,
                       mount_hole_d = BYJ_MOUNT_HOLE_D + FIT) {
    rotate([0, 0, rotation]) {
        cylinder(d = shaft_clearance_d, h = h, center = true);
        for (x = [-BYJ_MOUNT_SPACING / 2, BYJ_MOUNT_SPACING / 2])
            translate([x, -BYJ_SHAFT_TO_HOLE_LINE, 0])
                cylinder(d = mount_hole_d, h = h, center = true);
    }
}

module bearing_608_seat(depth = BEARING_608_W, entry_chamfer = 0.6,
                        diameter = BEARING_608_OD + PRESS_FIT) {
    cylinder(d = diameter, h = depth + EPS);
    if (entry_chamfer > 0)
        translate([0, 0, depth - entry_chamfer])
            cylinder(d1 = diameter, d2 = diameter + 2 * entry_chamfer,
                     h = entry_chamfer + EPS);
}

module tripod_nut_pocket(h = TRIPOD_NUT_H + FIT, af = TRIPOD_NUT_AF + FIT) {
    hex_prism(af = af, h = h, rotation = 30);
}

module m3_nut_pocket(h = 2.6 + FIT, af = 5.5 + FIT) {
    hex_prism(af = af, h = h, rotation = 30);
}

module m4_nut_pocket(h = 3.2 + FIT, af = 7.0 + FIT) {
    hex_prism(af = af, h = h, rotation = 30);
}

module m8_nut_pocket(h = 6.8 + FIT, af = 13.0 + FIT) {
    hex_prism(af = af, h = h, rotation = 30);
}
