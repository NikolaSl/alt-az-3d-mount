// Batch motion collision diagnostic. A successful sweep exports EMPTY geometry.
// MODE 0: ALT sweep against fixed upper structure.
// MODE 1: ALT sweep against conservative lower/tabletop envelope.
// MODE 2: critical ALT poses against lower envelope expanded by MARGIN.

include <../config.scad>
use <motion_collision_check.scad>

MODE = is_undef(MODE) ? 0 : MODE;
MARGIN = is_undef(MARGIN) ? 0.5 : MARGIN;
ALT_MIN = -20;
ALT_MAX = 90;
ALT_STEP = 5;

module spaced(index) {
    // Translation separates any detected collision volumes so the exported STL
    // remains easy to inspect. Empty intersections contribute no geometry.
    translate([index * 240, 0, 0]) children();
}

if (MODE == 0) {
    for (alt = [ALT_MIN : ALT_STEP : ALT_MAX])
        spaced((alt - ALT_MIN) / ALT_STEP)
            collision_upper(az = 0, alt = alt);
} else if (MODE == 1) {
    for (alt = [ALT_MIN : ALT_STEP : ALT_MAX])
        spaced((alt - ALT_MIN) / ALT_STEP)
            collision_lower(az = 0, alt = alt, tabletop = true, margin = 0);
} else if (MODE == 2) {
    critical = [-20, 0, 45, 90];
    for (i = [0 : len(critical) - 1])
        spaced(i)
            collision_lower(az = 0, alt = critical[i], tabletop = true, margin = MARGIN);
} else {
    assert(false, "Unknown MODE for motion_collision_sweep.scad");
}
