include <../config.scad>
use <../parts/payload_clamp_lower.scad>
use <../parts/payload_clamp_upper.scad>
use <../parts/payload_plate.scad>
use <../parts/camera_screw_knob.scad>

module payload_stage() {
    assert(PAYLOAD_PLATE[0] + 2.0 <= YOKE_INNER_W,
           "Payload plate needs at least 1 mm clearance per yoke side");
    assert(PAYLOAD_CLAMP_X + SHAFT_CLAMP_W / 2 < PAYLOAD_PLATE[0] / 2,
           "Shaft clamps overhang payload plate");
    assert(2 * (PAYLOAD_CLAMP_X - SHAFT_CLAMP_W / 2) > 31.0,
           "Central camera knob has insufficient clearance between shaft clamps");
    assert(ALT_SHAFT_L >= YOKE_OUTER_W + 20.0,
           "Altitude shaft is too short for arm bearings and external retention/drive");

    // Local altitude shaft is the X axis through Z=0.
    color("silver")
        translate([-ALT_SHAFT_L / 2, 0, 0])
            rotate([0, 90, 0])
                cylinder(d = AXIS_SHAFT_D, h = ALT_SHAFT_L);

    for (x = [-PAYLOAD_CLAMP_X, PAYLOAD_CLAMP_X]) {
        color("darkseagreen")
            translate([x, 0, -PAYLOAD_CLAMP_HALF_H])
                payload_clamp_lower();
        color("palegreen")
            translate([x, 0, 0])
                payload_clamp_upper();
    }

    color("seagreen")
        translate([0, 0, PAYLOAD_CLAMP_HALF_H])
            payload_plate();

    color("black")
        translate([0, 8, 0]) camera_screw_knob();
}

payload_stage();
