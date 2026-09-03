include <../config.scad>
use <../lib/util.scad>

module payload_plate() {
    difference() {
        rounded_plate(size = [PAYLOAD_PLATE[0], PAYLOAD_PLATE[1]],
                      r = 5.0, h = PAYLOAD_PLATE[2]);

        // Sliding 1/4-20 payload screw: move the payload CG over the altitude axis.
        translate([0, PAYLOAD_SLOT_CENTER_Y, -EPS])
            rotate([0, 0, 90])
                slot_3d(length = PAYLOAD_SLOT_L,
                        d = PAYLOAD_SLOT_D,
                        h = PAYLOAD_PLATE[2] + 2 * EPS);

        // Two shaft-clamp pairs underneath the plate.
        for (x = [-PAYLOAD_CLAMP_X, PAYLOAD_CLAMP_X],
             y = [-PAYLOAD_CLAMP_BOLT_Y, PAYLOAD_CLAMP_BOLT_Y]) {
            translate([x, y, -EPS])
                cylinder(d = M3_CLEARANCE_D, h = PAYLOAD_PLATE[2] + 2 * EPS);
            // Recess M3 socket/button heads so the payload sees a flat top.
            translate([x, y, PAYLOAD_PLATE[2] - 2.2])
                cylinder(d = 6.4, h = 2.2 + EPS);
        }

        // Optional side/riser attachment pattern for phone clamps or optics.
        for (x = [-31, 31], y = [-38, 38])
            translate([x, y, -EPS])
                cylinder(d = M4_CLEARANCE_D, h = PAYLOAD_PLATE[2] + 2 * EPS);

        // Shallow underside pockets reduce mass but retain a continuous top skin.
        for (x = [-24, 24], y = [-31, 31])
            translate([x, y, -EPS])
                rounded_plate(size = [24, 30], r = 3, h = 2.2);
    }
}

payload_plate();
