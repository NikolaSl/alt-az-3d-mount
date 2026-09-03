// Internal solid-pair QA for the sliding payload screw/knob assembly.
// This diagnostic exists because bodies that share the same ALT transform can
// still collide with one another; external moving-vs-fixed motion QA alone
// cannot detect such internal interference.

include <../config.scad>
use <../lib/payload_fastener.scad>
use <../parts/payload_clamp_lower.scad>
use <../parts/payload_clamp_upper.scad>

CHECK_MODE = is_undef(CHECK_MODE) ? 20 : CHECK_MODE;
PAYLOAD_SCREW_Y = is_undef(PAYLOAD_SCREW_Y) ? PAYLOAD_SLOT_CENTER_Y : PAYLOAD_SCREW_Y;

module alt_shaft_body() {
    translate([-ALT_SHAFT_L / 2, 0, 0])
        rotate([0, 90, 0])
            cylinder(d = AXIS_SHAFT_D, h = ALT_SHAFT_L, $fn = 64);
}

module payload_clamp_bodies() {
    for (x = [-PAYLOAD_CLAMP_X, PAYLOAD_CLAMP_X]) {
        translate([x, 0, -PAYLOAD_CLAMP_LOWER_H]) payload_clamp_lower();
        translate([x, 0, 0]) payload_clamp_upper();
    }
}

module forbidden_adjustment_obstructions() {
    alt_shaft_body();
    payload_clamp_bodies();
}

assert(PAYLOAD_SCREW_Y >= PAYLOAD_SLIDER_MIN_Y - EPS &&
       PAYLOAD_SCREW_Y <= PAYLOAD_SLIDER_MAX_Y + EPS,
       "PAYLOAD_SCREW_Y is outside the balancing slot centerline travel");

if (CHECK_MODE == 10)
    payload_fastener_body(y = 0);
else if (CHECK_MODE == 11)
    alt_shaft_body();
else if (CHECK_MODE == 12)
    payload_clamp_bodies();
else if (CHECK_MODE == 20)
    intersection() {
        payload_fastener_body(y = PAYLOAD_SCREW_Y);
        forbidden_adjustment_obstructions();
    }
else
    assert(false, "Unknown CHECK_MODE in payload_adjustment_collision_check.scad");
