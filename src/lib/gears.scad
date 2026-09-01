// Small self-contained involute spur-gear generator.
// It intentionally covers only external straight gears needed by this project.
include <../config.scad>
use <util.scad>

function involute_phi_deg(r, rb) =
    r <= rb ? 0 :
    let(t = sqrt((r / rb) * (r / rb) - 1))
        t * 180 / PI - atan(t);

function gear_pitch_r(z, m) = z * m / 2;
function gear_base_r(z, m, pressure_angle) = gear_pitch_r(z, m) * cos(pressure_angle);
function gear_outer_r(z, m) = gear_pitch_r(z, m) + m;
function gear_root_r(z, m, clearance) = max(m * 0.75, gear_pitch_r(z, m) - m - clearance);

function gear_flank_angle(r, z, m, pressure_angle, backlash) =
    let(rp = gear_pitch_r(z, m),
        rb = gear_base_r(z, m, pressure_angle),
        half_tooth_nominal = 90 / z,
        backlash_angle = backlash / (2 * rp) * 180 / PI,
        half_tooth = half_tooth_nominal - backlash_angle,
        phi_p = involute_phi_deg(rp, rb))
    half_tooth + phi_p - involute_phi_deg(r, rb);

function gear_tooth_points(z, m, pressure_angle = 20, clearance = 0.25,
                           backlash = 0.1, samples = 8, tip_samples = 3) =
    let(rp = gear_pitch_r(z, m),
        rb = gear_base_r(z, m, pressure_angle),
        ra = gear_outer_r(z, m),
        rf = gear_root_r(z, m, clearance),
        rs = max(rb, rf),
        radii = [for (i = [0 : samples]) rs + (ra - rs) * i / samples],
        lower = [for (r = radii) polar(r, -gear_flank_angle(r, z, m, pressure_angle, backlash))],
        tip_a = gear_flank_angle(ra, z, m, pressure_angle, backlash),
        tip = [for (i = [1 : tip_samples]) polar(ra, -tip_a + 2 * tip_a * i / (tip_samples + 1))],
        upper = [for (i = [len(radii) - 1 : -1 : 0])
                    polar(radii[i], gear_flank_angle(radii[i], z, m, pressure_angle, backlash))],
        root_a = min(0.72 * 180 / z,
                     gear_flank_angle(rs, z, m, pressure_angle, backlash) + 1.2))
    concat([polar(rf, -root_a)], lower, tip, upper, [polar(rf, root_a)]);

module involute_gear_2d(teeth = 20, module_size = 1, pressure_angle = 20,
                        clearance = 0.25, backlash = 0.1) {
    rf = gear_root_r(teeth, module_size, clearance);
    union() {
        circle(r = rf);
        for (i = [0 : teeth - 1])
            rotate([0, 0, i * 360 / teeth])
                polygon(points = gear_tooth_points(teeth, module_size,
                                                   pressure_angle, clearance,
                                                   backlash));
    }
}

module spur_gear(teeth = 20, module_size = 1, thickness = 5,
                 pressure_angle = 20, clearance = 0.25, backlash = 0.1,
                 bore_d = 0, hub_d = 0, hub_h = 0,
                 bolt_circle_d = 0, bolt_count = 0, bolt_d = 3.3,
                 center = false) {
    z0 = center ? -thickness / 2 : 0;
    difference() {
        translate([0, 0, z0])
            union() {
                linear_extrude(height = thickness)
                    involute_gear_2d(teeth = teeth, module_size = module_size,
                                     pressure_angle = pressure_angle,
                                     clearance = clearance, backlash = backlash);
                if (hub_d > 0 && hub_h > 0)
                    cylinder(d = hub_d, h = hub_h);
            }
        if (bore_d > 0)
            translate([0, 0, z0 - EPS])
                cylinder(d = bore_d, h = max(thickness, hub_h) + 2 * EPS);
        if (bolt_count > 0 && bolt_circle_d > 0)
            for (a = [0 : 360 / bolt_count : 360 - 360 / bolt_count])
                rotate([0, 0, a]) translate([bolt_circle_d / 2, 0, z0 - EPS])
                    cylinder(d = bolt_d, h = max(thickness, hub_h) + 2 * EPS);
    }
}
