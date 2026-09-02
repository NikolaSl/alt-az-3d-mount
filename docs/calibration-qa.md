# Calibration coupon CAD QA

The three physical-validation coupons were generated and checked before publication.

QA procedure: full OpenSCAD CGAL render with hard warnings, STL watertight check, connected-component check, isometric/top/bottom/front/right views and center X/Y sections.

| Entry point | OpenSCAD | Watertight | Connected printable components | Bounds |
|---|---|---|---:|---|
| `src/calibration/mechanical_fit_coupon.scad` | `Simple: yes` | yes | 1 | 118 × 76 × 10 mm |
| `src/calibration/fastener_fit_coupon.scad` | `Simple: yes` | yes | 1 | 118 × 82 × 8 mm |
| `src/calibration/byj48_fit_coupon.scad` | `Simple: yes` | yes | 1 | 112 × 50 × 12 mm |

Visual inspection confirmed:

- bearing pockets remain inside one coherent plate and have push-out openings;
- shaft and fastener test holes are open through the intended plate thickness;
- nut pockets are blind from the top as intended;
- the BYJ motor pattern is separated from the three raised Double-D test sockets;
- all three Double-D bosses are structurally connected to the base coupon;
- asymmetric orientation-key holes make the documented left-to-right test order unambiguous.

Generated PNG/STL QA artifacts are not committed by policy. Re-run the repository QA tooling after any coupon geometry change.
