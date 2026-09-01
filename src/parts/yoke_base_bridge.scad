include <../config.scad>
use <../lib/util.scad>

module yoke_base_bridge() {
    slot_floor = YOKE_BRIDGE_H - YOKE_SLOT_DEPTH;
    lock_z = slot_floor + YOKE_LOCK_LOCAL_Y;

    difference() {
        rounded_plate(size = [YOKE_BRIDGE_X, YOKE_BRIDGE_Y],
                      r = 5.0, h = YOKE_BRIDGE_H);

        // Four vertical M4 screws attach the bridge to the turntable.
        for (x = [-AZ_YOKE_MOUNT_X, AZ_YOKE_MOUNT_X])
            for (y = [-AZ_YOKE_MOUNT_Y, AZ_YOKE_MOUNT_Y]) {
                translate([x, y, -EPS])
                    cylinder(d = M4_CLEARANCE_D, h = YOKE_BRIDGE_H + 2 * EPS);
                translate([x, y, YOKE_BRIDGE_H - 3.2])
                    cylinder(d = 8.2, h = 3.2 + EPS);
            }

        // The two flat-printed yoke arms drop into close-fitting vertical slots.
        for (x = [-YOKE_ARM_CENTER_X, YOKE_ARM_CENTER_X])
            translate([x, 0, slot_floor + YOKE_SLOT_DEPTH / 2 + EPS])
                cube([YOKE_ARM_T + YOKE_SLOT_CLEARANCE,
                      YOKE_TENON_LEN + YOKE_SLOT_CLEARANCE,
                      YOKE_SLOT_DEPTH + 2 * EPS], center = true);

        // One transverse M4 bolt per arm locks the tenon inside the slot.
        for (x = [-YOKE_ARM_CENTER_X, YOKE_ARM_CENTER_X])
            translate([x, 0, lock_z])
                rotate([90, 0, 0])
                    cylinder(d = M4_CLEARANCE_D,
                             h = YOKE_BRIDGE_Y + 2 * EPS, center = true);
    }
}

yoke_base_bridge();
