// Physical envelope of the adjustable payload attachment hardware.

include <../config.scad>
use <util.scad>
use <../parts/camera_screw_knob.scad>

module payload_bolt_envelope() {
    // Metal 1/4-20 bolt head fills the knob's captive hex pocket.
    hex_prism(af = CAMERA_BOLT_HEAD_AF,
              h = CAMERA_BOLT_HEAD_H,
              rotation = 30);

    // Threaded shank starts above the head and continues through knob + plate.
    // Extra height above the plate is conservative for collision QA.
    translate([0, 0, CAMERA_BOLT_HEAD_H])
        cylinder(d = TRIPOD_THREAD_D,
                 h = CAMERA_KNOB_H - CAMERA_BOLT_HEAD_H + PAYLOAD_PLATE[2] + 8.0,
                 $fn = 48);
}

module payload_fastener_body(y = 0) {
    translate([0, y, PAYLOAD_KNOB_Z]) {
        camera_screw_knob();
        payload_bolt_envelope();
    }
}
