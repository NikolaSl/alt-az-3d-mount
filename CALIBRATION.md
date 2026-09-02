# Physical calibration and measurement gate

This file turns the remaining `PHYSICAL_VERIFY` items into a repeatable procedure. The production print set must not be frozen from nominal dimensions alone.

## 1. Purpose

The CAD is already coherent, but several interfaces depend on the actual printer/material and on the exact 28BYJ-48 clones, bearings, shaft and hardware in hand. The calibration kit is intentionally small so these uncertainties can be resolved before printing the complete mount.

Current browser-renderable calibration entry points:

- `src/calibration/mechanical_fit_coupon.scad`
- `src/calibration/fastener_fit_coupon.scad`
- `src/calibration/byj48_fit_coupon.scad`

All three passed full OpenSCAD CGAL QA before being committed: `Simple: yes`, watertight STL and one connected printable component.

## 2. Printer/material record

Record the exact setup used for the coupons and later production parts.

| Field | Value |
|---|---|
| Printer | TBD |
| Material | TBD |
| Material brand/batch | TBD |
| Nozzle | TBD |
| Layer height | TBD |
| Perimeters/walls | TBD |
| Top/bottom layers | TBD |
| Infill | TBD |
| Slicer/profile | TBD |
| XY/hole compensation | TBD |
| Date | TBD |

If the production material/profile changes materially, repeat the affected fit tests.

## 3. Measure the purchased hardware first

Use calipers and record both motors separately. Do not average them until we know the spread.

### 28BYJ-48 motor A — AZ

| Measurement | Current nominal | Measured |
|---|---:|---:|
| Body diameter | 28.0 mm | TBD |
| Body height | 19.0 mm | TBD |
| Front boss diameter | 9.0 mm | TBD |
| Front boss height | 2.5 mm | TBD |
| Shaft major diameter | 5.0 mm | TBD |
| Shaft across flats | 3.0 mm | TBD |
| Usable shaft length | 10.0 mm | TBD |
| Mount-hole center spacing | 35.0 mm | TBD |
| Mount-hole diameter | 4.0 mm | TBD |
| Shaft center to mount-hole line | 8.0 mm | TBD |

### 28BYJ-48 motor B — ALT

| Measurement | Current nominal | Measured |
|---|---:|---:|
| Body diameter | 28.0 mm | TBD |
| Body height | 19.0 mm | TBD |
| Front boss diameter | 9.0 mm | TBD |
| Front boss height | 2.5 mm | TBD |
| Shaft major diameter | 5.0 mm | TBD |
| Shaft across flats | 3.0 mm | TBD |
| Usable shaft length | 10.0 mm | TBD |
| Mount-hole center spacing | 35.0 mm | TBD |
| Mount-hole diameter | 4.0 mm | TBD |
| Shaft center to mount-hole line | 8.0 mm | TBD |

### Bearings and ALT shaft

| Item | Current nominal | Measured |
|---|---:|---:|
| Drive 608ZZ OD | 22.0 mm | TBD |
| Drive 608ZZ ID | 8.0 mm | TBD |
| Drive 608ZZ width | 7.0 mm | TBD |
| Idler 608ZZ OD | 22.0 mm | TBD |
| Idler 608ZZ ID | 8.0 mm | TBD |
| Idler 608ZZ width | 7.0 mm | TBD |
| ALT shaft diameter | 8.0 mm | TBD |
| ALT shaft actual length | 165.0 mm target | TBD |

Also measure/verify the actual M3/M4 nuts, 1/4-20 nut/bolt and M8 hardware if they differ visibly from the assumed standard hardware.

## 4. `mechanical_fit_coupon.scad`

Print flat with the orientation-key hole at the lower-left corner when viewed from above.

### 608ZZ row — top row, left to right

```text
21.90   22.00   22.10   22.20 mm
```

Each is a 7.3 mm deep blind seat with a 10 mm push-out hole underneath. Test with the actual bearings.

Desired result for the yoke bearing seat: a controlled push/press fit that seats fully without cracking or severe force, but does not fall out under its own weight.

Record:

| Diameter | Drive bearing result | Idler bearing result |
|---:|---|---|
| 21.90 | TBD | TBD |
| 22.00 | TBD | TBD |
| 22.10 | TBD | TBD |
| 22.20 | TBD | TBD |

### Ø8 shaft row — lower row, left to right

```text
7.90   8.00   8.10   8.20   8.30 mm
```

Desired result depends on interface:

- bearing/shaft chain: shaft itself runs in the metal 608 inner race;
- printed output/spacer/clamp interfaces should slide onto the shaft without uncontrolled wobble;
- do not choose a destructive press fit for serviceable shaft parts.

| Diameter | Fit result |
|---:|---|
| 7.90 | TBD |
| 8.00 | TBD |
| 8.10 | TBD |
| 8.20 | TBD |
| 8.30 | TBD |

## 5. `fastener_fit_coupon.scad`

Print flat. The small orientation hole is at the upper-left corner when viewed from above.

### M3 clearance row — top, left to right

```text
3.10   3.20   3.30   3.40 mm
```

### M4 clearance row — middle, left to right

```text
4.20   4.30   4.40   4.50 mm
```

Choose the smallest hole that gives the intended assembly clearance without requiring drill cleanup for routine parts.

### M3 nut pockets — lower-left, left to right

Across-flats test sizes:

```text
5.50   5.65   5.80 mm
```

### M4 nut pockets — lower-right, left to right

```text
7.00   7.15   7.30 mm
```

The two large lower pockets are the current 1/4-20 tripod-nut pocket and M8 captive-nut reference pocket. Verify that the real nuts seat fully, cannot rotate under normal tightening, and can still be inserted without damaging the print.

Record the selected values here:

| Interface | Selected/test result |
|---|---|
| M3 clearance | TBD |
| M4 clearance | TBD |
| M3 nut AF | TBD |
| M4 nut AF | TBD |
| 1/4-20 captive nut | TBD |
| M8 captive nut | TBD |

## 6. `byj48_fit_coupon.scad`

The left side is a direct motor mounting pattern using the current shared `BYJ_*` values. Place each real motor against it and verify:

- front boss enters the center opening;
- both mounting holes line up without forcing the motor sideways;
- the motor flange sits flat;
- the pattern works for both AZ and ALT motors.

The three raised bosses on the right contain blind Double-D sockets. From left to right the socket oversize is:

```text
+0.10   +0.18   +0.26 mm
```

relative to both the current nominal major diameter and flat spacing.

Record:

| Test | AZ motor | ALT motor |
|---|---|---|
| Mount pattern | TBD | TBD |
| Boss clearance | TBD | TBD |
| +0.10 Double-D | TBD | TBD |
| +0.18 Double-D | TBD | TBD |
| +0.26 Double-D | TBD | TBD |

Select the tightest socket that can be seated/removal-tested without splitting the printed boss and that does not exhibit visible rotational play.

## 7. How results feed back into CAD

Do not patch individual parts with ad-hoc local diameters. Once the measurements/tests are known:

1. record the raw results in this file;
2. map each change through `INTERFACES.md`;
3. update the owning values in `src/config.scad`;
4. mark affected part IDs in `PARTS.md` as `NEEDS_REVALIDATION`;
5. regenerate affected parts in dependency order;
6. run per-part QA, context QA and full assembly/motion QA;
7. update `ASSEMBLY.md`, BOM and `PROJECT_STATE.md`;
8. only then promote the corresponding physical interface from `PHYSICAL_PENDING` to verified/frozen.

Likely interface families:

- motor dimensions / shaft: `I-003`, `I-004`, `I-020`, `I-021`;
- 608 and Ø8 shaft chain: `I-013`–`I-017`, `I-025`, `I-027`;
- tripod/payload hardware: `I-001`, `I-018`;
- printer fits/fasteners: all relevant printed-to-hardware interfaces.

## 8. Remaining special physical test after coupons

The generic coupons do not replace the final functional dry-fit of:

- AZ compound axle/support (`I-006` / `HOLD-AZ-AXLE`);
- ALT compound shoulder axle (`I-023`);
- ALT output spacer + 60T hub + two grub screws (`I-025`);
- complete yoke coaxiality and free rotation through both 608 bearings;
- complete AZ hand rotation without binding;
- payload/arm/gearbox clearance through the required ALT range.

The coupons reduce uncertainty before those functional prototypes are printed.
