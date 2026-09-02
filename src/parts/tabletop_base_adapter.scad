include <../config.scad>

// Removable flat-surface adapter. The Alt-Az mount remains tripod-compatible;
// this plate attaches through the same 1/4-20 captive nut in az_base.

module tabletop_base_adapter() {
    difference() {
        cylinder(d = TABLETOP_BASE_D, h = TABLETOP_BASE_T);

        // Shallow top locator for the Ø48 pedestal on az_base.
        translate([0, 0, TABLETOP_BASE_T - TABLETOP_LOCATOR_DEPTH])
            cylinder(d = TABLETOP_LOCATOR_D,
                     h = TABLETOP_LOCATOR_DEPTH + EPS);

        // 1/4-20 attachment screw passes up into the captive nut in az_base.
        translate([0, 0, -EPS])
            cylinder(d = TABLETOP_CENTER_CLEAR_D,
                     h = TABLETOP_BASE_T + 2 * EPS);

        // Recess the screw head so no metal protrudes below the adapter.
        translate([0, 0, -EPS])
            cylinder(d = TABLETOP_BOLT_HEAD_D,
                     h = TABLETOP_BOLT_HEAD_RECESS_H + EPS);

        // Four shallow recesses for adhesive rubber feet. Rubber compliance
        // avoids rocking while giving a wide square support polygon.
        for (a = [45, 135, 225, 315])
            rotate([0, 0, a])
                translate([TABLETOP_FOOT_R, 0, -EPS])
                    cylinder(d = TABLETOP_FOOT_D,
                             h = TABLETOP_FOOT_RECESS_H + EPS);
    }
}

tabletop_base_adapter();
