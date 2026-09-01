include <../config.scad>
use <util.scad>
use <hardware.scad>
use <gears.scad>

// Printable 20:1 two-stage reducer used on the azimuth axis.
// Stage 1: 12T motor pinion -> 48T compound gear = 4:1.
// Stage 2: 12T compound pinion -> 60T output gear = 5:1.

module double_d_cutout(d = BYJ_SHAFT_D + 0.18,
                       flats = BYJ_SHAFT_FLAT + 0.18,
                       h = 10) {
    intersection() {
        cylinder(d = d, h = h);
        translate([-d, -flats / 2, 0]) cube([2 * d, flats, h]);
    }
}

module az_motor_pinion_12t() {
    difference() {
        spur_gear(teeth = GEAR_Z1,
                  module_size = GEAR_MODULE,
                  thickness = GEAR_FACE,
                  pressure_angle = GEAR_PRESSURE_ANGLE,
                  clearance = GEAR_CLEARANCE,
                  backlash = GEAR_BACKLASH,
                  hub_d = AZ_MOTOR_PINION_HUB_D,
                  hub_h = AZ_MOTOR_PINION_HUB_H);

        translate([0, 0, -EPS])
            double_d_cutout(h = AZ_MOTOR_PINION_HUB_H + 2 * EPS);
    }
}

module az_compound_48_12t() {
    difference() {
        union() {
            spur_gear(teeth = GEAR_Z2,
                      module_size = GEAR_MODULE,
                      thickness = GEAR_FACE,
                      pressure_angle = GEAR_PRESSURE_ANGLE,
                      clearance = GEAR_CLEARANCE,
                      backlash = GEAR_BACKLASH,
                      hub_d = AZ_COMPOUND_HUB_D,
                      hub_h = GEAR_STACK_H);

            translate([0, 0, GEAR_FACE + GEAR_GAP])
                spur_gear(teeth = GEAR_Z3,
                          module_size = GEAR_MODULE,
                          thickness = GEAR_FACE,
                          pressure_angle = GEAR_PRESSURE_ANGLE,
                          clearance = GEAR_CLEARANCE,
                          backlash = GEAR_BACKLASH);
        }

        // M3 shoulder/plain-shank screw is the axle. It is supported by both
        // the base and the gearbox cover, rather than cantilevering from plastic.
        translate([0, 0, -EPS])
            cylinder(d = AZ_INTERMEDIATE_BORE_D,
                     h = GEAR_STACK_H + 2 * EPS);
    }
}

module az_output_60t() {
    difference() {
        spur_gear(teeth = GEAR_Z4,
                  module_size = GEAR_MODULE,
                  thickness = GEAR_FACE,
                  pressure_angle = GEAR_PRESSURE_ANGLE,
                  clearance = GEAR_CLEARANCE,
                  backlash = GEAR_BACKLASH,
                  bore_d = M8_CLEARANCE_D,
                  hub_d = AZ_OUTPUT_HUB_D,
                  hub_h = AZ_OUTPUT_HUB_H);

        // Four M3 screws come down through the turntable. Captive nuts are
        // loaded from the underside of the output gear hub.
        four_at_radius(r = AZ_OUTPUT_BOLT_R, phase = 45) {
            translate([0, 0, -EPS])
                cylinder(d = M3_CLEARANCE_D,
                         h = AZ_OUTPUT_HUB_H + 2 * EPS);
            translate([0, 0, -EPS])
                m3_nut_pocket(h = AZ_OUTPUT_NUT_DEPTH + EPS);
        }
    }
}

module az_reducer_visual(exploded = 0) {
    // Sanity checks are intentionally executable during every render/export.
    assert(abs(CD_STAGE1 - (GEAR_Z1 + GEAR_Z2) * GEAR_MODULE / 2) < 0.001);
    assert(abs(CD_STAGE2 - (GEAR_Z3 + GEAR_Z4) * GEAR_MODULE / 2) < 0.001);
    assert(AZ_GEAR_TOP_CLEARANCE >= 0.8,
           "Upper gear layer has insufficient clearance to cover roof");
    assert(AZ_OUTPUT_HUB_D + 2 * FIT < AZ_OUTPUT_PASSAGE_D,
           "Output hub does not clear gearbox cover passage");
    assert(AZ_OUTPUT_HUB_D < AZ_OUTPUT_LOCATOR_D,
           "Output hub does not fit turntable locator");

    translate([REDUCER_MOTOR[0], REDUCER_MOTOR[1], AZ_GEAR_Z0])
        color("orange") az_motor_pinion_12t();

    translate([REDUCER_INTERMEDIATE[0], REDUCER_INTERMEDIATE[1], AZ_GEAR_Z0])
        color("khaki") az_compound_48_12t();

    translate([REDUCER_OUTPUT[0], REDUCER_OUTPUT[1], AZ_UPPER_GEAR_Z + exploded])
        color("lightsteelblue") az_output_60t();
}
