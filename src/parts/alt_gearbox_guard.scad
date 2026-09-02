include <../config.scad>
use <../lib/util.scad>
use <../lib/alt_reducer20.scad>

module alt_gearbox_guard() {
    difference() {
        union() {
            // Perimeter wall around both reduction stages.
            linear_extrude(height = ALT_GUARD_H)
                difference() {
                    union() {
                        alt_outline_2d();
                        for (p = ALT_GUARD_SCREW_POS)
                            translate(p) circle(d = ALT_GUARD_SCREW_BOSS_D);
                    }
                    alt_outline_2d(delta = -ALT_GUARD_WALL);
                }

            // Stiff roof and four integrated screw lugs.
            translate([0, 0, ALT_GUARD_H - ALT_GUARD_TOP_T])
                linear_extrude(height = ALT_GUARD_TOP_T)
                    union() {
                        alt_outline_2d();
                        for (p = ALT_GUARD_SCREW_POS)
                            translate(p) circle(d = ALT_GUARD_SCREW_BOSS_D);
                    }

            // Short upper journal for the compound-gear shoulder axle.
            translate([ALT_INTERMEDIATE[0], ALT_INTERMEDIATE[1],
                       ALT_GUARD_H - ALT_GUARD_BOSS_H])
                cylinder(d = 10.0, h = ALT_GUARD_BOSS_H);
        }

        // The output hub protrudes above the roof. This exposes the two radial
        // M3 set-screw pilots while leaving the 60T gear protected below.
        translate([0, 0, ALT_GUARD_H - ALT_GUARD_TOP_T - EPS])
            cylinder(d = ALT_GUARD_CENTER_CLEAR_D,
                     h = ALT_GUARD_TOP_T + 2 * EPS);

        // Upper close-fit support for the stationary M3 compound axle.
        translate([ALT_INTERMEDIATE[0], ALT_INTERMEDIATE[1],
                   ALT_GUARD_H - ALT_GUARD_BOSS_H - EPS])
            cylinder(d = INTERMEDIATE_AXLE_D + 0.12,
                     h = ALT_GUARD_BOSS_H + ALT_GUARD_TOP_T + 2 * EPS);

        for (p = ALT_GUARD_SCREW_POS)
            translate([p[0], p[1], -EPS])
                cylinder(d = M3_CLEARANCE_D,
                         h = ALT_GUARD_H + 2 * EPS);
    }
}

alt_gearbox_guard();
