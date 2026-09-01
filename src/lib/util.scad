include <../config.scad>

function v2_add(a, b) = [a[0] + b[0], a[1] + b[1]];
function v2_sub(a, b) = [a[0] - b[0], a[1] - b[1]];
function v2_scale(a, s) = [a[0] * s, a[1] * s];
function rot2(p, a) = [p[0] * cos(a) - p[1] * sin(a), p[0] * sin(a) + p[1] * cos(a)];
function polar(r, a) = [r * cos(a), r * sin(a)];
function clamp(x, lo, hi) = min(max(x, lo), hi);

module rounded_rect_2d(size = [10, 10], r = 2, center = true) {
    sx = size[0]; sy = size[1]; rr = min(r, min(sx, sy) / 2);
    translate(center ? [0, 0] : [sx / 2, sy / 2])
        offset(r = rr) square([sx - 2 * rr, sy - 2 * rr], center = true);
}

module rounded_plate(size = [10, 10], r = 2, h = 2, center = false) {
    linear_extrude(height = h, center = center)
        rounded_rect_2d(size = size, r = r, center = true);
}

module slot_2d(length = 20, d = 4) {
    hull() {
        translate([-(length - d) / 2, 0]) circle(d = d);
        translate([(length - d) / 2, 0]) circle(d = d);
    }
}

module slot_3d(length = 20, d = 4, h = 5, center = false) {
    linear_extrude(height = h, center = center) slot_2d(length = length, d = d);
}

module hex_prism(af = 10, h = 5, center = false, rotation = 30) {
    rotate([0, 0, rotation]) cylinder(r = af / sqrt(3), h = h, center = center, $fn = 6);
}

module four_at_radius(r = 10, phase = 45) {
    for (a = [phase : 90 : phase + 270])
        rotate([0, 0, a]) translate([r, 0]) children();
}
