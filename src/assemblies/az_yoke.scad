include <../config.scad>
use <az_stage.scad>
use <yoke_stage.scad>

module az_yoke() {
    az_stage();
    translate([0, 0,
               AZ_BASE_PLATE_H + AZ_COVER_H + AZ_GLIDE_GAP + AZ_TURNTABLE_H])
        yoke_stage();
}

az_yoke();
