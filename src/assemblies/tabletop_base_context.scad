include <../config.scad>
use <../parts/az_base.scad>
use <../parts/tabletop_base_adapter.scad>

module tabletop_base_context() {
    color([0.72, 0.75, 0.80, 1.0]) az_base();

    // Adapter top rises TABLETOP_LOCATOR_DEPTH around the lower pedestal;
    // the locator pocket floor coincides with the pedestal bottom at Z=-24.
    translate([0, 0,
               -AZ_PEDESTAL_H - TABLETOP_BASE_T + TABLETOP_LOCATOR_DEPTH])
        color([0.82, 0.68, 0.42, 0.90]) tabletop_base_adapter();
}

tabletop_base_context();
