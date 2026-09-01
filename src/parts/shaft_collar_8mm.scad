include <../config.scad>

module shaft_collar_8mm() {
    collar_d = 17.0;
    collar_h = 10.0;
    bore_d = AXIS_SHAFT_D + 0.18;
    pilot_d = 2.7; // drill/tap M3 after printing
    pilot_z = 6.5;
    pilot_len = collar_d / 2 - bore_d / 2 + 2 * EPS;

    difference() {
        cylinder(d = collar_d, h = collar_h);
        translate([0, 0, -EPS])
            cylinder(d = bore_d, h = collar_h + 2 * EPS);

        // Blind radial M3 pilot runs only from the OD to the shaft bore.
        // An M3 grub screw presses directly on the steel shaft.
        translate([bore_d / 2 - EPS, 0, pilot_z])
            rotate([0, 90, 0])
                cylinder(d = pilot_d, h = pilot_len);
    }
}

shaft_collar_8mm();
