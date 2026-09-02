include <../config.scad>
use <util.scad>
use <hardware.scad>
use <gears.scad>

module alt_outline_2d(delta = 0) {
    offset(delta = delta)
        hull() {
            translate(ALT_OUTPUT_CENTER) circle(r = ALT_OUTLINE_R_OUTPUT);
            translate(ALT_INTERMEDIATE) circle(r = ALT_OUTLINE_R_INTERMEDIATE);
            translate(ALT_MOTOR) circle(r = ALT_OUTLINE_R_MOTOR);
        }
}

module alt_double_d_cutout(d = BYJ_SHAFT_D + 0.18,
                           flats = BYJ_SHAFT_FLAT + 0.18,
                           h = 10) {
    intersection() {
        cylinder(d = d, h = h);
        translate([-d, -flats / 2, 0]) cube([2 * d, flats, h]);
    }
}

module alt_motor_pinion_12t() {
    difference() {
        spur_gear(teeth = GEAR_Z1,
                  module_size = GEAR_MODULE,
                  thickness = GEAR_FACE,
                  pressure_angle = GEAR_PRESSURE_ANGLE,
                  clearance = GEAR_CLEARANCE,
                  backlash = GEAR_BACKLASH,
                  hub_d = ALT_MOTOR_PINION_HUB_D,
                  hub_h = GEAR_FACE);
        translate([0, 0, -EPS])
            alt_double_d_cutout(h = GEAR_FACE + 2 * EPS);
    }
}

module alt_compound_48_12t() {
    difference() {
        union() {
            spur_gear(teeth = GEAR_Z2,
                      module_size = GEAR_MODULE,
                      thickness = GEAR_FACE,
                      pressure_angle = GEAR_PRESSURE_ANGLE,
                      clearance = GEAR_CLEARANCE,
                      backlash = GEAR_BACKLASH,
                      hub_d = ALT_COMPOUND_HUB_D,
                      hub_h = GEAR_STACK_H);
            translate([0, 0, GEAR_FACE + GEAR_GAP])
                spur_gear(teeth = GEAR_Z3,
                          module_size = GEAR_MODULE,
                          thickness = GEAR_FACE,
                          pressure_angle = GEAR_PRESSURE_ANGLE,
                          clearance = GEAR_CLEARANCE,
                          backlash = GEAR_BACKLASH);
        }
        translate([0, 0, -EPS])
            cylinder(d = ALT_INTERMEDIATE_BORE_D,
                     h = GEAR_STACK_H + 2 * EPS);
    }
}

module alt_output_60t() {
    difference() {
        spur_gear(teeth = GEAR_Z4,
                  module_size = GEAR_MODULE,
                  thickness = GEAR_FACE,
                  pressure_angle = GEAR_PRESSURE_ANGLE,
                  clearance = GEAR_CLEARANCE,
                  backlash = GEAR_BACKLASH,
                  hub_d = ALT_OUTPUT_HUB_D,
                  hub_h = ALT_OUTPUT_HUB_H);
        translate([0, 0, -EPS])
            cylinder(d = ALT_OUTPUT_BORE_D,
                     h = ALT_OUTPUT_HUB_H + 2 * EPS);

        // Two radial M3 pilot holes are above the tooth plane and above the
        // gearbox roof once assembled. Tap M3 after printing; optional brass
        // inserts can be substituted after a fit test.
        for (a = [0, 90])
            rotate([0, 0, a])
                translate([ALT_OUTPUT_BORE_D / 2 - EPS, 0, ALT_OUTPUT_SET_Z])
                    rotate([0, 90, 0])
                        cylinder(d = ALT_OUTPUT_SET_PILOT_D,
                                 h = ALT_OUTPUT_HUB_D / 2 -
                                     ALT_OUTPUT_BORE_D / 2 + 2 * EPS);
    }
}

module alt_output_spacer() {
    difference() {
        cylinder(d = ALT_OUTPUT_SPACER_D, h = ALT_OUTPUT_SPACER_H);
        translate([0, 0, -EPS])
            cylinder(d = ALT_OUTPUT_BORE_D,
                     h = ALT_OUTPUT_SPACER_H + 2 * EPS);
    }
}

module alt_reducer_visual(exploded = 0) {
    assert(abs(CD_STAGE1 - (GEAR_Z1 + GEAR_Z2) * GEAR_MODULE / 2) < 0.001);
    assert(abs(CD_STAGE2 - (GEAR_Z3 + GEAR_Z4) * GEAR_MODULE / 2) < 0.001);
    assert(abs(GEAR_RATIO - 20) < 0.001,
           "ALT reducer ratio must remain 20:1");
    assert(ALT_GEAR_TOP_CLEARANCE >= 2.0,
           "ALT guard roof clearance is too small");
    assert(ALT_OUTPUT_HUB_D + 2 * FIT < ALT_GUARD_CENTER_CLEAR_D,
           "ALT output hub does not clear guard roof opening");

    translate([ALT_MOTOR[0], ALT_MOTOR[1], ALT_GEAR_Z0])
        color("orange") alt_motor_pinion_12t();
    translate([ALT_INTERMEDIATE[0], ALT_INTERMEDIATE[1], ALT_GEAR_Z0])
        color("khaki") alt_compound_48_12t();
    translate([ALT_OUTPUT_CENTER[0], ALT_OUTPUT_CENTER[1],
               ALT_UPPER_GEAR_Z + exploded])
        color("lightsteelblue") alt_output_60t();
    translate([0, 0, 0.1]) color("silver") alt_output_spacer();
}
