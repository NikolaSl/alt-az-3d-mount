// Fast analytic safety-margin checks for geometry whose clearance is invariant
// under ALT/AZ rotation. Dense boolean motion checks live in
// motion_collision_check.scad; these assertions complement them.

include <../config.scad>

QA_MARGIN = is_undef(QA_MARGIN) ? 0.5 : QA_MARGIN;

payload_side_gap = (YOKE_INNER_W - PAYLOAD_PLATE[0]) / 2;
clamp_outer_x = PAYLOAD_CLAMP_X + SHAFT_CLAMP_W / 2;
clamp_side_gap = YOKE_INNER_W / 2 - clamp_outer_x;

// Conservative radial reach of the rectangular payload plate around the ALT axis.
payload_plate_radial_reach = sqrt(
    pow(PAYLOAD_PLATE[1] / 2, 2) +
    pow(PAYLOAD_CLAMP_HALF_H + PAYLOAD_PLATE[2], 2));
bridge_top_below_axis = (YOKE_BRIDGE_H - YOKE_SLOT_DEPTH + YOKE_AXIS_Z) - YOKE_BRIDGE_H;
bridge_radial_gap = bridge_top_below_axis - payload_plate_radial_reach;

assert(payload_side_gap >= QA_MARGIN,
       str("Payload plate side gap ", payload_side_gap,
           " mm is below QA margin ", QA_MARGIN, " mm"));
assert(clamp_side_gap >= QA_MARGIN,
       str("Payload clamp side gap ", clamp_side_gap,
           " mm is below QA margin ", QA_MARGIN, " mm"));
assert(bridge_radial_gap >= QA_MARGIN,
       str("Conservative bridge radial gap ", bridge_radial_gap,
           " mm is below QA margin ", QA_MARGIN, " mm"));

echo(str("MOTION_QA payload_side_gap_mm=", payload_side_gap));
echo(str("MOTION_QA clamp_side_gap_mm=", clamp_side_gap));
echo(str("MOTION_QA bridge_radial_gap_mm=", bridge_radial_gap));

// Non-empty diagnostic output so command-line CSG export has a success artifact.
cube([1, 1, 1]);
