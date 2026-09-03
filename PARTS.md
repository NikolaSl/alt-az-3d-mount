# Parts decomposition and status ledger

This file is the **system decomposition/status source of truth**. `ASSEMBLY.md` owns quantities/hardware/physical sequence, `INTERFACES.md` owns interface/solid/constraint contracts, and `src/config.scad` owns shared dimensions/datums.

## Status vocabulary

- `PLANNED`
- `INTERFACES_DEFINED`
- `CONSTRAINTS_DEFINED`
- `MODELED`
- `PART_QA_PASS`
- `INTEGRATED_CAD`
- `MOTION_QA_PASS`
- `STATE_SPACE_QA_PASS`
- `PHYSICAL_VERIFY`
- `FROZEN`
- exceptional: `BLOCKED`, `NEEDS_REVALIDATION`, `HUMAN_REVIEW`.

A part/assembly may carry multiple dimensions, e.g. `INTEGRATED_CAD / MOTION_QA_PASS / PHYSICAL_VERIFY`.

## Printed elementary parts

| ID | Qty | Source | Responsibility | Direct dependencies | Current status |
|---|---:|---|---|---|---|
| `P-TABLETOP-BASE` | 1 optional | `src/parts/tabletop_base_adapter.scad` | removable Ø190 flat-surface base | AZ base, tabletop bolt/feet | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-AZ-BASE` | 1 | `src/parts/az_base.scad` | fixed base, support interface, AZ motor/axis datum | motor, M8 axis | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-AZ-COVER` | 1 | `src/parts/az_gearbox_cover.scad` | AZ reducer enclosure/support context | AZ base/reducer | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-AZ-TURNTABLE` | 1 | `src/parts/az_turntable.scad` | rotating AZ platform | AZ output, central axis, glide interface | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-AZ-PINION` | 1 | `src/parts/gear_az_motor_12t.scad` | AZ motor 12T pinion | AZ motor, gear params | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-AZ-COMPOUND` | 1 | `src/parts/gear_az_compound_48_12t.scad` | AZ 48T/12T compound | pinion, intermediate axle | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-AZ-OUTPUT` | 1 | `src/parts/gear_az_output_60t.scad` | AZ 60T output/hub | compound, central axis, turntable | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-YOKE-BRIDGE` | 1 | `src/parts/yoke_base_bridge.scad` | structural bridge | turntable, yoke datums | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-YOKE-DRIVE` | 1 | `src/parts/yoke_arm_drive.scad` | drive arm, bearing and ALT gearbox datum | bridge, drive 608 | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-YOKE-IDLER` | 1 | `src/parts/yoke_arm_idler.scad` | idler arm/bearing datum | bridge, idler 608 | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-PAYLOAD-CLAMP-L` | 2 | `src/parts/payload_clamp_lower.scad` | lower Ø8 split-clamp halves | ALT shaft | `PART_QA_PASS / INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-PAYLOAD-CLAMP-U` | 2 | `src/parts/payload_clamp_upper.scad` | upper split-clamp halves + **15 mm structural risers** that lift payload plate above fastener/shaft interference | ALT shaft, payload plate | `PART_QA_PASS / INTEGRATED_CAD / STATE_SPACE_QA_PASS / PHYSICAL_VERIFY` |
| `P-PAYLOAD-PLATE` | 1 | `src/parts/payload_plate.scad` | raised universal payload platform with 48 mm balance slot | clamp pair, payload screw | `PART_QA_PASS / INTEGRATED_CAD / STATE_SPACE_QA_PASS / PHYSICAL_VERIFY` |
| `P-CAMERA-KNOB` | 1 | `src/parts/camera_screw_knob.scad` | printed hand knob around real 1/4-20 payload bolt | payload screw | `PART_QA_PASS / INTEGRATED_CAD / STATE_SPACE_QA_PASS / PHYSICAL_VERIFY` |
| `P-SHAFT-COLLAR` | 1 | `src/parts/shaft_collar_8mm.scad` | idler-side ALT axial retention | ALT shaft | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-ALT-PLATE` | 1 | `src/parts/alt_gearbox_plate.scad` | ALT gearbox structural plate | drive arm, ALT motor | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-ALT-GUARD` | 1 | `src/parts/alt_gearbox_guard.scad` | removable guard + compound axle upper support | ALT plate/reducer | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-ALT-PINION` | 1 | `src/parts/gear_alt_motor_12t.scad` | ALT 12T pinion | ALT motor | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-ALT-COMPOUND` | 1 | `src/parts/gear_alt_compound_48_12t.scad` | ALT 48T/12T compound | pinion, shoulder axle | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-ALT-OUTPUT` | 1 | `src/parts/gear_alt_output_60t.scad` | ALT 60T output/clamp hub | compound, shaft, spacer | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-ALT-SPACER` | 1 | `src/parts/alt_output_spacer.scad` | transfers ALT output stack reaction to drive 608 inner race only | shaft, drive 608, output | `INTEGRATED_CAD / PHYSICAL_VERIFY` |

### Accepted payload regression dimensions

Workflow `Visual geometric QA` run `33772448736`: **PASS**.

```text
P-PAYLOAD-CLAMP-U   18 × 30 × 15 mm, Simple yes, watertight, 1 component
P-PAYLOAD-CLAMP-L   18 × 30 × 8 mm,  Simple yes, watertight, 1 component
P-PAYLOAD-PLATE     80 × 112 × 6 mm, Simple yes, watertight, 1 component
P-CAMERA-KNOB       30.4 × 30.4 × 8 mm, Simple yes, watertight, 1 component
```

All received seven standard views + X/Y/Z center sections; payload context and adjustment-section preview QA also passed.

## Validation prints

| ID | Source | Purpose | Status |
|---|---|---|---|
| `V-MECH-FIT` | `src/calibration/mechanical_fit_coupon.scad` | 608/Ø8 fit selection | `PART_QA_PASS / PHYSICAL_TEST_PENDING` |
| `V-FASTENER-FIT` | `src/calibration/fastener_fit_coupon.scad` | M3/M4/nut/1/4-20/M8 fits | `PART_QA_PASS / PHYSICAL_TEST_PENDING` |
| `V-BYJ-FIT` | `src/calibration/byj48_fit_coupon.scad` | motor pattern/Double-D clearance | `PART_QA_PASS / PHYSICAL_TEST_PENDING` |

## Non-printed functional elements

| ID | Qty | Element | Responsibility | Current status |
|---|---:|---|---|---|
| `H-TABLETOP-BOLT` | 1 optional | 1/4-20 bolt | tabletop adapter clamp | `PHYSICAL_VERIFY` |
| `H-TABLETOP-FEET` | 4 optional | compliant feet | non-slip tabletop support | `PHYSICAL_VERIFY` |
| `H-AZ-MOTOR` | 1 | 28BYJ-48 | AZ torque source | `PHYSICAL_VERIFY` |
| `H-ALT-MOTOR` | 1 | 28BYJ-48 | ALT torque source | `PHYSICAL_VERIFY` |
| `H-608-DRIVE` | 1 | 608ZZ | drive-side ALT radial support | `PHYSICAL_VERIFY` |
| `H-608-IDLER` | 1 | 608ZZ | idler-side ALT radial support | `PHYSICAL_VERIFY` |
| `H-ALT-SHAFT` | 1 | smooth Ø8×165 mm steel shaft | ALT axis/load path | `PHYSICAL_VERIFY` |
| `H-AZ-AXIS` | 1 | M8 stud/bolt + retention | central AZ datum/retention | `PHYSICAL_VERIFY` |
| `H-AZ-COMPOUND-AXLE` | 1 | M3-class supported smooth/shoulder axle | AZ compound rotation | `BLOCKED_BY_PHYSICAL_VERIFY / HOLD-AZ-AXLE` |
| `H-ALT-COMPOUND-AXLE` | 1 | M3 shoulder axle | ALT compound rotation | `PHYSICAL_VERIFY` |
| `H-TRIPOD-NUT` | 1 | 1/4-20 captive nut | tripod/tabletop interface | `PHYSICAL_VERIFY` |
| `H-PAYLOAD-SCREW` | 1 | real 1/4-20 bolt | adjustable payload attachment; its head/shank envelope participates in QA | `STATE_SPACE_QA_PASS / PHYSICAL_VERIFY` |
| `H-AZ-GLIDES` | 3 | PTFE pads/tape | AZ vertical sliding support | `PHYSICAL_VERIFY` |

Exact fastener counts/initial lengths are in `ASSEMBLY.md`.

## Virtual assemblies / QA entry points

| ID | Entry point | Purpose | Status |
|---|---|---|---|
| `A-TABLETOP-CONTEXT` | `src/assemblies/tabletop_base_context.scad` | tabletop/base interface | `INTEGRATED_CAD` |
| `A-AZ` | `src/assemblies/az_stage.scad` | AZ subsystem | `INTEGRATED_CAD` |
| `A-YOKE` | `src/assemblies/yoke_stage.scad` | yoke + ALT support datums | `INTEGRATED_CAD` |
| `A-PAYLOAD` | `src/assemblies/payload_stage.scad` | shaft/clamps/raised plate/adjustable fastener | `INTEGRATED_CAD / STATE_SPACE_QA_PASS / PHYSICAL_VERIFY` |
| `A-PAYLOAD-SECTION` | `src/assemblies/payload_adjustment_section.scad` | browser-reviewable Y-Z section through shaft/fastener/plate | `QA_REVIEW_ENTRY` |
| `A-PAYLOAD-COLLISION-QA` | `src/assemblies/payload_adjustment_collision_check.scad` | independent internal fastener↔shaft/clamp bodies | `STATE_SPACE_QA_PASS` |
| `A-ALT-DRIVE` | `src/assemblies/alt_drive_stage.scad` | ALT motor/reducer/output stack | `INTEGRATED_CAD` |
| `A-FULL` | `src/assemblies/full_mount.scad` | complete tripod-mode mount | `INTEGRATED_CAD / MOTION_QA_PASS / STATE_SPACE_QA_PASS / PHYSICAL_VERIFY` |
| `A-TABLETOP-FULL` | `src/assemblies/tabletop_full_mount.scad` | complete tabletop-mode mount | `INTEGRATED_CAD / MOTION_QA_PASS / STATE_SPACE_QA_PASS / PHYSICAL_VERIFY` |

Accepted current state-space evidence is in `docs/motion-qa-results.md`: structural ALT sweep 111 states; payload screw-center sweep 84 states; 9,324 ALT×slider states per external obstruction, 27,972 fastener collision queries total; zero forbidden modeled collisions.

## Dependency order

```text
shared parameters + purchased envelopes
        │
        ├─> AZ base/reducer → AZ turntable → yoke bridge → yoke arms
        │                                              │
        │                                         two 608ZZ
        │                                              │
        │                                           ALT shaft
        │                                          /         \
        │                     payload split clamps          ALT output stack
        │                             │                            │
        │                    raised payload plate             ALT reducer
        │                             │                            │
        │                  adjustable 1/4-20 fastener             │
        │                             \                            /
        └──────────────────────────────> full mount <─────────────┘
```

Optional tabletop base attaches below AZ base.

## Current QA interpretation

The automated pass covers the **mount structure and payload attachment hardware**, not every arbitrary external phone/camera/optic. `M-PAYLOAD-SLIDE` is a manual setup coordinate: the slot constrains the screw center, but a loose single-screw payload can yaw and is operator-constrained during balancing. Tightening must remove translation/yaw/slip physically.

Before approving a specific payload for unattended full-range motion, model its conservative payload/adapter/cable envelope or restrict and physically verify the usable range.

## Current HOLD / VERIFY items

- `HOLD-MOTOR-DIMS` — measure both actual 28BYJ-48 units.
- `HOLD-PRINT-FITS` — run the three physical fit coupons.
- `HOLD-AZ-AXLE` — freeze mechanically sound AZ compound axle support only after dry-fit.
- `VERIFY-ALT-DRIVE` — pinion, shoulder axle, output bore/spacer, grub-screw stack.
- `VERIFY-PAYLOAD-ADJUSTMENT` — real 1/4-20 dry-fit, complete screw-center travel, final clamp preload and no payload yaw/slip after tightening.
- `VERIFY-PAYLOAD-ENVELOPE` — actual phone/camera/optic + adapter + cables are not yet a universal collision envelope.
- `VERIFY-TABLETOP-STABILITY` — actual payload CG, feet/surface and overturn margin.
- `VERIFY-CABLE-MOTION` — future asymmetric fixed/moving cable/electronics geometry invalidates current symmetry assumptions until modeled/re-QA'd.

No physical-dependent part becomes `FROZEN` until its corresponding verification is complete.
