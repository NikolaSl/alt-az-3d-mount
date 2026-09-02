# Parts decomposition and status ledger

This file is the **system decomposition source of truth** for the current machine. It answers two questions at any point in the project:

1. What elementary parts/subsystems make up the machine?
2. What is the engineering status of each of them?

`ASSEMBLY.md` remains the source of truth for quantities, purchased hardware and physical assembly sequence. `INTERFACES.md` owns the contracts between parts. `src/config.scad` owns shared dimensions and datums.

## Status vocabulary

- `PLANNED` — required by the machine plan, geometry not yet accepted.
- `INTERFACES_DEFINED` — neighboring contracts exist, detailed geometry may still be missing.
- `MODELED` — source exists but is not yet a trusted dependency.
- `PART_QA_PASS` — individual geometric/visual QA passed.
- `INTEGRATED_CAD` — integrated into the current assembly and accepted as a CAD dependency.
- `PHYSICAL_VERIFY` — CAD is usable, but one or more real-world fits/dimensions remain provisional.
- `FROZEN` — relevant real-world interfaces have been physically verified and should not change without explicit backtracking.
- `BLOCKED` / `NEEDS_REVALIDATION` — normal exceptional states defined by `DESIGN_PROTOCOL.md`.

A part may carry two status dimensions, e.g. `INTEGRATED_CAD / PHYSICAL_VERIFY`.

## Printed elementary parts

| ID | Qty | Source | Responsibility | Direct dependencies | Current status |
|---|---:|---|---|---|---|
| `P-AZ-BASE` | 1 | `src/parts/az_base.scad` | Fixed base, tripod interface, AZ motor support, central AZ datum | `src/config.scad`, `H-AZ-MOTOR`, `H-AZ-AXIS` | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-AZ-COVER` | 1 | `src/parts/az_gearbox_cover.scad` | AZ reducer enclosure and upper support context | `P-AZ-BASE`, AZ gear envelope | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-AZ-TURNTABLE` | 1 | `src/parts/az_turntable.scad` | Rotating AZ platform carrying the yoke | `P-AZ-OUTPUT`, `H-AZ-AXIS`, glide interface | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-AZ-PINION` | 1 | `src/parts/gear_az_motor_12t.scad` | 12T AZ motor pinion | `H-AZ-MOTOR`, gear parameters | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-AZ-COMPOUND` | 1 | `src/parts/gear_az_compound_48_12t.scad` | 48T/12T compound gear | `P-AZ-PINION`, `H-AZ-COMPOUND-AXLE`, gear parameters | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-AZ-OUTPUT` | 1 | `src/parts/gear_az_output_60t.scad` | 60T AZ output gear/hub | `P-AZ-COMPOUND`, `H-AZ-AXIS`, `P-AZ-TURNTABLE` | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-YOKE-BRIDGE` | 1 | `src/parts/yoke_base_bridge.scad` | Structural bridge between AZ stage and both yoke arms | `P-AZ-TURNTABLE`, yoke datums | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-YOKE-DRIVE` | 1 | `src/parts/yoke_arm_drive.scad` | Drive-side ALT arm, bearing support and gearbox datum | `P-YOKE-BRIDGE`, `H-608-DRIVE`, ALT gearbox interface | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-YOKE-IDLER` | 1 | `src/parts/yoke_arm_idler.scad` | Idler-side ALT arm and bearing support | `P-YOKE-BRIDGE`, `H-608-IDLER` | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-PAYLOAD-CLAMP-L` | 2 | `src/parts/payload_clamp_lower.scad` | Lower halves of ALT shaft clamps | `H-ALT-SHAFT`, payload clamp parameters | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-PAYLOAD-CLAMP-U` | 2 | `src/parts/payload_clamp_upper.scad` | Upper halves of ALT shaft clamps | `H-ALT-SHAFT`, `P-PAYLOAD-PLATE` | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-PAYLOAD-PLATE` | 1 | `src/parts/payload_plate.scad` | Universal payload/phone/camera mounting plate | clamp pair, 1/4-20 payload interface | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-CAMERA-KNOB` | 1 | `src/parts/camera_screw_knob.scad` | Hand knob around metal 1/4-20 payload bolt | `H-PAYLOAD-SCREW` | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-SHAFT-COLLAR` | 1 | `src/parts/shaft_collar_8mm.scad` | Idler-side ALT shaft axial retention | `H-ALT-SHAFT`, M3 grub screw | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-ALT-PLATE` | 1 | `src/parts/alt_gearbox_plate.scad` | Structural ALT gearbox plate and motor/axle datums | `P-YOKE-DRIVE`, `H-ALT-MOTOR`, ALT gear envelope | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-ALT-GUARD` | 1 | `src/parts/alt_gearbox_guard.scad` | Removable ALT guard and upper compound-axle support | `P-ALT-PLATE`, ALT gear envelope | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-ALT-PINION` | 1 | `src/parts/gear_alt_motor_12t.scad` | 12T ALT motor pinion | `H-ALT-MOTOR`, gear parameters | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-ALT-COMPOUND` | 1 | `src/parts/gear_alt_compound_48_12t.scad` | 48T/12T ALT compound gear | `P-ALT-PINION`, `H-ALT-COMPOUND-AXLE`, gear parameters | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-ALT-OUTPUT` | 1 | `src/parts/gear_alt_output_60t.scad` | 60T ALT output gear and clamp hub | `P-ALT-COMPOUND`, `H-ALT-SHAFT`, `P-ALT-SPACER` | `INTEGRATED_CAD / PHYSICAL_VERIFY` |
| `P-ALT-SPACER` | 1 | `src/parts/alt_output_spacer.scad` | Transfers ALT output stack reaction to the 608 inner race | `H-ALT-SHAFT`, `H-608-DRIVE`, `P-ALT-OUTPUT` | `INTEGRATED_CAD / PHYSICAL_VERIFY` |

## Non-printed functional elements

Exact fastener counts and lengths live in `ASSEMBLY.md`; this table tracks only non-printed elements whose geometry/behavior participates directly in the dependency graph.

| ID | Qty | Element | Responsibility | Current status |
|---|---:|---|---|---|
| `H-AZ-MOTOR` | 1 | 28BYJ-48 stepper | Drives AZ reducer | `PHYSICAL_VERIFY` — actual clone dimensions required |
| `H-ALT-MOTOR` | 1 | 28BYJ-48 stepper | Drives ALT reducer | `PHYSICAL_VERIFY` — actual clone dimensions required |
| `H-608-DRIVE` | 1 | 608ZZ, nominal 8×22×7 mm | Drive-side ALT radial support | `PHYSICAL_VERIFY` |
| `H-608-IDLER` | 1 | 608ZZ, nominal 8×22×7 mm | Idler-side ALT radial support | `PHYSICAL_VERIFY` |
| `H-ALT-SHAFT` | 1 | Smooth steel Ø8×165 mm | ALT axis and torque path | `PHYSICAL_VERIFY` |
| `H-AZ-AXIS` | 1 | M8 stud/bolt + retaining hardware | Central AZ axis | `PHYSICAL_VERIFY` |
| `H-AZ-COMPOUND-AXLE` | 1 | Smooth/shoulder M3-class axle, final length TBD | AZ compound gear axle | `BLOCKED_BY_PHYSICAL_VERIFY` (`HOLD-AZ-AXLE`) |
| `H-ALT-COMPOUND-AXLE` | 1 | M3 shoulder screw/axle | ALT compound gear stationary axle | `PHYSICAL_VERIFY` |
| `H-TRIPOD-NUT` | 1 | 1/4-20 UNC captive nut | Tripod attachment | `PHYSICAL_VERIFY` |
| `H-PAYLOAD-SCREW` | 1 | 1/4-20 UNC bolt | Payload attachment | `PHYSICAL_VERIFY` |
| `H-AZ-GLIDES` | 3 | PTFE pads/tape | Low-friction AZ support | `PHYSICAL_VERIFY` |

## Virtual assemblies

Virtual assemblies are not printable parts. They are integration checkpoints and human-review entry points.

| ID | Entry point | Contains | Status |
|---|---|---|---|
| `A-AZ` | `src/assemblies/az_stage.scad` | AZ base, reducer, cover, turntable | `INTEGRATED_CAD` |
| `A-YOKE` | `src/assemblies/yoke_stage.scad` | AZ-supported yoke structure and ALT bearing datums | `INTEGRATED_CAD` |
| `A-PAYLOAD` | `src/assemblies/payload_stage.scad` | Yoke + shaft + clamps + payload plate | `INTEGRATED_CAD` |
| `A-ALT-DRIVE` | `src/assemblies/alt_drive_stage.scad` | Drive arm + ALT motor/reducer/output stack | `INTEGRATED_CAD` |
| `A-FULL` | `src/assemblies/full_mount.scad` | Best-known complete dual-axis machine | `INTEGRATED_CAD / PHYSICAL_VERIFY` |

## Dependency order

The current top-level dependency graph is:

```text
shared config + purchased envelopes
        │
        ├─> AZ base + AZ reducer ─> AZ turntable
        │                              │
        │                              v
        │                         yoke bridge
        │                        /           \
        │                 drive arm       idler arm
        │                     │               │
        │                  608ZZ           608ZZ
        │                     \              /
        │                      \            /
        │                       ALT shaft
        │                      /         \
        │             payload clamps     ALT output stack
        │                  │                  │
        │             payload plate      ALT reducer
        │                  \                  /
        └───────────────────> full mount <───┘
```

A downstream part must not silently redefine an upstream interface dimension. Shared dimensions belong in `src/config.scad`; interaction semantics belong in `INTERFACES.md`.

## Invalidation rule

When a part, hardware envelope or shared parameter changes:

1. find the affected interface IDs in `INTERFACES.md`;
2. mark every directly dependent part here `NEEDS_REVALIDATION`;
3. propagate through the dependency graph only as far as affected interfaces require;
4. re-run per-part/context/assembly QA in dependency order;
5. update `ASSEMBLY.md`, BOM and `PROJECT_STATE.md` before the change is considered integrated.

## Current blockers shared with `PROJECT_STATE.md`

- `HOLD-MOTOR-DIMS` — real 28BYJ-48 dimensions are not frozen.
- `HOLD-PRINT-FITS` — printer/material fits are not calibrated.
- `HOLD-AZ-AXLE` — AZ compound axle needs physical validation/final support decision.
- `VERIFY-ALT-DRIVE` — ALT shaft/pinion/shoulder-axle/output-clamp stack needs physical fit verification.

No new part depending on one of these uncertain interfaces should be marked `FROZEN` until the corresponding physical test is complete.
