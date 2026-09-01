include <../config.scad>
use <../lib/util.scad>

module az_gearbox_cover() {
    cable_angle = atan2(38, 50);

    difference() {
        union() {
            // Thin outer shell with an open bottom and a stiff top plate.
            difference() {
                cylinder(d = AZ_BASE_D, h = AZ_COVER_H);
                translate([0, 0, -EPS])
                    cylinder(d = AZ_BASE_D - 2 * AZ_COVER_WALL,
                             h = AZ_COVER_H - AZ_COVER_TOP_T + EPS);
            }

            // Four columns transfer screw preload directly to the base bosses.
            four_at_radius(r = AZ_COVER_BOLT_R, phase = 45)
                cylinder(d = 10.0, h = AZ_COVER_H);

            // Three small axial support pads. PTFE tape can be added on top.
            for (a = [30, 150, 270])
                rotate([0, 0, a]) translate([AZ_GLIDE_RADIUS, 0, AZ_COVER_H])
                    cylinder(d = AZ_GLIDE_D, h = AZ_GLIDE_GAP);
        }

        // Passage for the future output gear/hub around the M8 axis.
        translate([0, 0, -EPS])
            cylinder(d = AZ_OUTPUT_PASSAGE_D,
                     h = AZ_COVER_H + AZ_GLIDE_GAP + 2 * EPS);

        // Cover screws: M3 through holes with recessed heads, below the turntable.
        four_at_radius(r = AZ_COVER_BOLT_R, phase = 45) {
            translate([0, 0, -EPS])
                cylinder(d = M3_CLEARANCE_D, h = AZ_COVER_H + 2 * EPS);
            translate([0, 0, AZ_COVER_H - 2.2])
                cylinder(d = 6.4, h = 2.2 + AZ_GLIDE_GAP + EPS);
        }

        // Cable exit aligned with the slot already present in az_base.scad.
        rotate([0, 0, cable_angle])
            translate([AZ_BASE_D / 2 - 5.0, -5.0, -EPS])
                cube([12.0, 10.0, 8.0 + EPS]);
    }
}

az_gearbox_cover();
