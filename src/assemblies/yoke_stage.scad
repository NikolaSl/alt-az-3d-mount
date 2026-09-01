include <../config.scad>
use <../parts/yoke_base_bridge.scad>
use <../parts/yoke_arm_drive.scad>
use <../parts/yoke_arm_idler.scad>

module left_arm_to_world(base_z = 0) {
    // local X -> world Y; local Y -> world Z; local Z -> world +X.
    multmatrix([
        [0, 0, 1, -(YOKE_INNER_W / 2 + YOKE_ARM_T)],
        [1, 0, 0, 0],
        [0, 1, 0, base_z],
        [0, 0, 0, 1]
    ]) children();
}

module right_arm_to_world(base_z = 0) {
    // Mirrored so local Z=0 is the outside face on the right arm as well.
    multmatrix([
        [0, 0,-1,  (YOKE_INNER_W / 2 + YOKE_ARM_T)],
        [1, 0, 0, 0],
        [0, 1, 0, base_z],
        [0, 0, 0, 1]
    ]) children();
}

module yoke_stage() {
    slot_floor = YOKE_BRIDGE_H - YOKE_SLOT_DEPTH;

    color("slateblue") yoke_base_bridge();
    color("cornflowerblue")
        left_arm_to_world(slot_floor) yoke_arm_drive();
    color("cornflowerblue")
        right_arm_to_world(slot_floor) yoke_arm_idler();
}

yoke_stage();
