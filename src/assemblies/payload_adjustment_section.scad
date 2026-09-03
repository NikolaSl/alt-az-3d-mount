// Browser-reviewable Y-Z section through the ALT shaft and adjustable payload
// attachment. This is derived QA geometry, not a printable part.

include <../config.scad>
use <../lib/payload_fastener.scad>
use <../parts/payload_clamp_lower.scad>
use <../parts/payload_clamp_upper.scad>
use <../parts/payload_plate.scad>

PAYLOAD_SCREW_Y = is_undef(PAYLOAD_SCREW_Y) ? PAYLOAD_SLOT_CENTER_Y : PAYLOAD_SCREW_Y;
SECTION_T = is_undef(SECTION_T) ? 0.8 : SECTION_T;

module payload_adjustment_context() {
    color("silver")
        translate([-ALT_SHAFT_L / 2, 0, 0])
            rotate([0, 90, 0])
                cylinder(d = AXIS_SHAFT_D, h = ALT_SHAFT_L, $fn = 64);

    for (x = [-PAYLOAD_CLAMP_X, PAYLOAD_CLAMP_X]) {
        color("darkseagreen")
            translate([x, 0, -PAYLOAD_CLAMP_LOWER_H]) payload_clamp_lower();
        color("palegreen")
            translate([x, 0, 0]) payload_clamp_upper();
    }

    color("seagreen")
        translate([0, 0, PAYLOAD_PLATE_Z]) payload_plate();

    color("black") payload_fastener_body(y = PAYLOAD_SCREW_Y);
}

assert(PAYLOAD_SCREW_Y >= PAYLOAD_SLIDER_MIN_Y - EPS &&
       PAYLOAD_SCREW_Y <= PAYLOAD_SLIDER_MAX_Y + EPS,
       "PAYLOAD_SCREW_Y is outside balancing travel");

// Thin slice around X=0 gives a true Y-Z section through shaft, plate and
// payload fastener. At slider endpoints the knob may be away from Y=0 but stays
// visible because the section plane is normal to X, not to Y.
intersection() {
    payload_adjustment_context();
    translate([-SECTION_T / 2, -PAYLOAD_PLATE[1], -40])
        cube([SECTION_T, 2 * PAYLOAD_PLATE[1], 100]);
}
