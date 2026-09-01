include <../config.scad>
use <../parts/az_base.scad>
use <../parts/az_gearbox_cover.scad>
use <../parts/az_turntable.scad>
use <../lib/reducer20.scad>

module az_stage(show_cover = true, show_turntable = true, exploded = 0) {
    color("silver") az_base();

    // All reducer Z coordinates are relative to the top of the base plate.
    translate([0, 0, AZ_BASE_PLATE_H]) {
        az_reducer_visual(exploded = exploded);
        if (show_cover)
            color([0.70, 0.82, 0.92, 0.55]) az_gearbox_cover();
        if (show_turntable)
            translate([0, 0, AZ_COVER_H + AZ_GLIDE_GAP + exploded])
                color([0.75, 0.75, 0.78, 0.75]) az_turntable();
    }
}

az_stage();
