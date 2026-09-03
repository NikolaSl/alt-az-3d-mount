include <../config.scad>
use <../parts/payload_clamp_lower.scad>
use <../parts/payload_clamp_upper.scad>
use <../parts/payload_plate.scad>
use <../parts/camera_screw_knob.scad>

PAYLOAD_SCREW_Y = is_undef(PAYLOAD_SCREW_Y) ? PAYLOAD_SLOT_CENTER_Y : PAYLOAD_SCREW_Y;

module payload_stage(payload_screw_y = PAYLOAD_SCREW_Y) {
    knob_to_shaft_vertical_gap = PAYLOAD_KNOB_Z - AXIS_SHAFT_D / 2;
    knob_to_clamp_side_gap = (PAYLOAD_CLAMP_X - SHAFT_CLAMP_W / 2) - CAMERA_KNOB_ENVELOPE_D / 2;

    assert(PAYLOAD_PLATE[0] + 2.0 <= YOKE_INNER_W,
           "Payload plate needs at least 1 mm clearance per yoke side");
    assert(PAYLOAD_CLAMP_X + SHAFT_CLAMP_W / 2 < PAYLOAD_PLATE[0] / 2,
           "Shaft clamps overhang payload plate");
    assert(knob_to_clamp_side_gap >= PAYLOAD_ADJUSTMENT_MIN_CLEARANCE,
           str("Payload knob envelope has only ", knob_to_clamp_side_gap,
               " mm side clearance to shaft clamps"));
    assert(knob_to_shaft_vertical_gap >= PAYLOAD_KNOB_SHAFT_CLEARANCE,
           str("Payload knob is only ", knob_to_shaft_vertical_gap,
               " mm above ALT shaft; required ", PAYLOAD_KNOB_SHAFT_CLEARANCE, " mm"));
    assert(payload_screw_y >= PAYLOAD_SLIDER_MIN_Y - EPS &&
           payload_screw_y <= PAYLOAD_SLIDER_MAX_Y + EPS,
           str("PAYLOAD_SCREW_Y=", payload_screw_y,
               " is outside balancing range ", PAYLOAD_SLIDER_MIN_Y,
               "..", PAYLOAD_SLIDER_MAX_Y));
    assert(ALT_SHAFT_L >= YOKE_OUTER_W + 20.0,
           "Altitude shaft is too short for arm bearings and external retention/drive");

    // Local altitude shaft is the X axis through Z=0.
    color("silver")
        translate([-ALT_SHAFT_L / 2, 0, 0])
            rotate([0, 90, 0])
                cylinder(d = AXIS_SHAFT_D, h = ALT_SHAFT_L);

    for (x = [-PAYLOAD_CLAMP_X, PAYLOAD_CLAMP_X]) {
        color("darkseagreen")
            translate([x, 0, -PAYLOAD_CLAMP_LOWER_H])
                payload_clamp_lower();
        color("palegreen")
            translate([x, 0, 0])
                payload_clamp_upper();
    }

    color("seagreen")
        translate([0, 0, PAYLOAD_PLATE_Z])
            payload_plate();

    // Knob top sits against the underside of the raised plate. The balancing
    // position is a real adjustment state and is QA-swept over the complete slot.
    color("black")
        translate([0, payload_screw_y, PAYLOAD_KNOB_Z]) camera_screw_knob();
}

payload_stage();
