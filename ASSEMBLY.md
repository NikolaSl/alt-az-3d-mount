# Assembly guide and live hardware BOM

This file is the **source of truth for physical mechanical assembly**. When mechanical geometry changes, update the SCAD source, affected QA, this BOM/sequence, `PARTS.md`, `INTERFACES.md` and `PROJECT_STATE.md` together.

> **Current design:** dual-axis Alt-Az mount for tripod or removable tabletop base, two 28BYJ-48 motors, printable 20:1 reducers, two 608ZZ ALT bearings and Ø8×165 mm ALT shaft. Production printing remains gated by physical motor dimensions, printer-fit calibration and functional dry-fit.

## 1. Mechanical/load chain

```text
flat table                          photo tripod
    │                                    │
    ▼                                    │
tabletop_base_adapter                    │
    └──────── 1/4-20 ────────────────────┤
                                         ▼
                                      az_base
                          ┌───────────────┼───────────────┐
                          │               │               │
                    M8 AZ datum      PTFE glides      AZ motor
                          │               │               │
                          └──── az_turntable ◀─ 20:1 reducer
                                      │
                                yoke_base_bridge
                                ┌─────┴─────┐
                                ▼           ▼
                           drive arm    idler arm
                              608ZZ       608ZZ
                                └─────┬─────┘
                                      ▼
                              Ø8×165 ALT shaft
                         ┌────────────┴────────────┐
                         ▼                         ▼
                  split payload clamps       ALT output stack
                         │                         │
                  raised payload plate        20:1 reducer
                         │                         │
            sliding 1/4-20 payload screw    28BYJ-48 ALT
```

Structural intent:

- AZ/ALT motors and gear shafts transmit torque; they are **not** primary payload bearings.
- AZ vertical load flows through turntable/glide support into the base.
- ALT payload load flows through split clamps → Ø8 shaft → two 608ZZ → yoke.
- The payload balancing screw is an adjustment/attachment element, not an ALT-axis support.

## 2. Printable production parts

| Qty | File | Role |
|---:|---|---|
| 1 optional | `src/parts/tabletop_base_adapter.scad` | Removable Ø190 flat-surface base |
| 1 | `src/parts/az_base.scad` | Fixed base, support interface and AZ motor datum |
| 1 | `src/parts/az_gearbox_cover.scad` | AZ reducer enclosure/support context |
| 1 | `src/parts/az_turntable.scad` | Rotating AZ platform |
| 1 | `src/parts/gear_az_motor_12t.scad` | AZ pinion |
| 1 | `src/parts/gear_az_compound_48_12t.scad` | AZ compound gear |
| 1 | `src/parts/gear_az_output_60t.scad` | AZ output gear/hub |
| 1 | `src/parts/yoke_base_bridge.scad` | Yoke bridge |
| 1 | `src/parts/yoke_arm_drive.scad` | Drive arm + 608/ALT gearbox datum |
| 1 | `src/parts/yoke_arm_idler.scad` | Idler arm + 608 datum |
| 2 | `src/parts/payload_clamp_lower.scad` | Lower Ø8 split-clamp halves |
| 2 | `src/parts/payload_clamp_upper.scad` | Upper split-clamp halves **and structural risers** for payload-fastener/shaft clearance |
| 1 | `src/parts/payload_plate.scad` | Universal raised payload platform with balance slot |
| 1 | `src/parts/camera_screw_knob.scad` | Hand knob around metal 1/4-20 payload bolt |
| 1 | `src/parts/shaft_collar_8mm.scad` | Idler-side ALT axial retention |
| 1 | `src/parts/alt_gearbox_plate.scad` | ALT gearbox structural plate |
| 1 | `src/parts/alt_gearbox_guard.scad` | Removable guard + compound-axle upper support |
| 1 | `src/parts/gear_alt_motor_12t.scad` | ALT pinion |
| 1 | `src/parts/gear_alt_compound_48_12t.scad` | ALT compound gear |
| 1 | `src/parts/gear_alt_output_60t.scad` | ALT output gear/clamp hub |
| 1 | `src/parts/alt_output_spacer.scad` | 608-inner-race to output-gear spacer |

Calibration prints, not final machine parts:

```text
src/calibration/mechanical_fit_coupon.scad
src/calibration/fastener_fit_coupon.scad
src/calibration/byj48_fit_coupon.scad
```

Important browser/QA assemblies, not printable parts:

```text
src/assemblies/az_stage.scad
src/assemblies/yoke_stage.scad
src/assemblies/payload_stage.scad
src/assemblies/alt_drive_stage.scad
src/assemblies/full_mount.scad
src/assemblies/tabletop_base_context.scad
src/assemblies/tabletop_full_mount.scad
src/assemblies/payload_adjustment_section.scad
src/assemblies/motion_collision_check.scad
src/assemblies/payload_adjustment_collision_check.scad
```

## 3. Purchased/fabricated mechanical items

| Qty | Item | Role / note |
|---:|---|---|
| 2 | 28BYJ-48, actual 5 V/12 V variants TBD | AZ + ALT drive; measure each real clone |
| 2 | 608ZZ nominal 8×22×7 mm | ALT radial support |
| 1 | smooth steel Ø8×165 mm shaft | ALT axis/load path |
| 1 | M8 nut captive in `az_base` | central AZ datum hardware |
| 1 | M8 stud/bolt ~50 mm initial | central AZ axis; final length after dry-fit |
| 1 | M8 low-profile/Nyloc nut + washer | turntable axial retention |
| 1 | 1/4-20 UNC captive nut | shared tripod/tabletop support interface |
| 1 optional | 1/4-20 bolt ~1/2 in initial | tabletop adapter to base; shortest usable length after dry-fit |
| 4 optional | Ø~18 mm compliant adhesive feet | tabletop support footprint |
| 1 | 1/4-20 bolt 3/4–1 in initial | adjustable payload attachment in knob |
| 3 | small PTFE pads/tape | AZ glide points |
| as needed | plastic-compatible grease/dry PTFE | thin layer on gears only |
| as needed | medium threadlocker | metal-to-metal final threads only |

### AZ fasteners

| Qty | Fastener | Interface |
|---:|---|---|
| 4 | M3×20 + nuts | AZ cover to base |
| 4 | M3×12 + nuts | turntable to AZ 60T hub |
| 1 | M3-class shoulder/plain-shank axle, length TBD | AZ compound gear — `HOLD-AZ-AXLE` |
| 4 | M4×16 + nuts | yoke bridge to turntable |
| 2 | M4×40–45 + Nyloc + washers | yoke-arm transverse locks |
| 2 | M4×8–12 + nuts/washers | AZ motor, actual flange dependent |

### Payload / ALT fasteners

| Qty | Fastener | Interface |
|---:|---|---|
| 4 | **M3×30 initial + 4 M3 nuts** | split clamps + raised payload plate; final length frozen after dry-fit |
| 1 | M3×6 grub screw | idler shaft collar |
| 4 | M3×12 countersunk | ALT gearbox plate to drive arm; heads must remain flush |
| 2 | M4×10–12 + nuts | ALT motor to gearbox plate |
| 1 | M3 shoulder screw ~22 mm + nut | ALT compound axle with plate+guard support |
| 4 | M3×20 + nuts | ALT guard to plate |
| 2 | M3×6 grub screws | ALT output hub to Ø8 shaft |
| 0–2 optional | M3 heat-set inserts | stronger alternative for output-hub threads |

The former M3×25 clamp screws are no longer the target after raising the payload plate. M3×30 is the current initial selection from CAD stack geometry; exact head/nut engagement is frozen only after physical dry-fit.

## 4. Tools and physical calibration

Minimum useful tools:

- digital caliper;
- printer + intended production material/profile;
- M3/M4/M8/1/4-20 appropriate drivers/wrenches;
- file/deburring tools;
- shaft cutting/deburring tool if stock shaft is longer than 165 mm;
- small tap/driver if using tapped M3 pilot holes;
- optional vice/controlled bearing pressing aid.

Before the full production set:

1. measure both 28BYJ-48 motors independently: body, boss, shaft, flat, mounting spacing/holes;
2. measure both 608ZZ and the Ø8 shaft;
3. print all three calibration coupons;
4. record raw results in `CALIBRATION.md` before changing shared parameters;
5. verify bearing seats, shaft fits, nut traps, Double-D pinion and 1/4-20/M8 interfaces;
6. test the ALT output bore/spacer and grub-screw strategy on real hardware.

## 5. Assembly order

### A. Optional tabletop base

1. Install four compliant feet in the adapter recesses.
2. Locate the AZ pedestal in the tabletop locator; it must not require press force.
3. Insert the 1/4-20 bolt from below into the base captive nut.
4. Use the shortest bolt with adequate engagement that cannot reach/interfere with M8 AZ hardware.
5. Confirm bolt head is below the support/feet plane and the base does not rock.

For tripod mode, remove the tabletop adapter and use the same captive 1/4-20 nut directly.

### B. Central AZ support

1. Install the captive M8 nut/stud hardware in `az_base`.
2. Keep final threadlocker off until physical axial stack is established.
3. The M8 axis provides the central datum; PTFE glides/turntable carry vertical load.

### C. AZ motor/reducer

1. Mount the AZ 28BYJ.
2. Fit the 12T Double-D pinion.
3. Install the 48T/12T compound gear on the provisional intermediate axle.
4. Install 60T output gear around the M8 axis.
5. Verify 12↔48 and 12↔60 planes and hand-turn for periodic tight spots.
6. Use only a thin compatible lubricant layer.

`HOLD-AZ-AXLE`: do not freeze the compound axle until the physical two-sided/mechanically sound support is verified.

### D. AZ cover/turntable

1. Install cover with 4×M3.
2. Add PTFE to three glide points.
3. Attach output hub to turntable with 4×M3.
4. Install M8 washer/top retaining nut.
5. Remove gross axial play without clamping the turntable into binding.
6. Hand-rotate full 360°.

### E. Yoke and ALT bearings

1. Attach bridge to turntable with 4×M4.
2. Seat one 608ZZ in each arm.
3. Insert arms into bridge slots and install transverse locks.
4. Verify arm parallelism and bearing coaxiality before forcing the shaft.

### F. ALT shaft, raised payload clamps and balance attachment

1. Pass the smooth Ø8×165 shaft through both 608ZZ bearings.
2. Install the two lower split-clamp halves and two **15 mm upper clamp/riser halves** symmetrically on the shaft.
3. Install the payload plate using 4×M3×30 initial screws; tighten progressively/symmetrically.
4. Install idler-side shaft collar but leave small controlled axial endplay.
5. Insert the 1/4-20 metal bolt into `camera_screw_knob`, then through the payload balance slot.
6. Verify that the knob top clamps the plate underside while the knob/bolt body remains above the ALT shaft.
7. With the payload attachment loosened, slide from `PAYLOAD_SLIDER_MIN_Y` to `PAYLOAD_SLIDER_MAX_Y`; there must be no contact with shaft or split clamps.
8. Tighten the payload attachment and verify the adjustment DOF is removed without plate/knob distortion or payload slip.

The raised plate is deliberate: nominal knob-to-shaft vertical clearance is controlled by `PAYLOAD_KNOB_SHAFT_CLEARANCE`, not accidental geometry.

### G. ALT gearbox plate/motor

1. Install guard captive nuts and compound-axle nut/pocket hardware as designed.
2. Mount ALT 28BYJ behind the plate, shaft outward through the plate.
3. Install ALT 12T pinion.
4. Fix plate to drive arm with four **flush countersunk M3×12** screws; protruding heads can enter the gear envelope.

### H. ALT output stack

From yoke outward:

```text
608 inner race
→ alt_output_spacer
→ 60T output gear/hub
→ shaft clamp via two M3 grub screws
```

Spacer OD must load only the 608 inner race. Do not preload the bearing outer race or let the gear rub plate/guard.

### I. ALT compound/guard

1. Install 48T/12T compound gear at the defined center distances.
2. Install guard.
3. Pass shoulder axle from guard roof through gear to plate-side retention.
4. Tighten the stationary axle without axially pinching the compound gear.
5. Install 4×M3 guard screws.
6. Verify free rotation and service/removal path.

### J. ALT output clamp and mesh

1. Establish spacer/output axial location without bearing preload.
2. Hand-turn both gear stages and verify no tight spots.
3. Complete M3 output-hub thread/insert strategy only after physical test coupon.
4. Install two grub screws, preferably at least one onto a small shaft flat.
5. Verify guard can remain installed while required service screws are accessible.

## 6. Balancing

1. Power off/release drive as appropriate before balancing.
2. Loosen the 1/4-20 payload attachment only enough to permit slot movement.
3. Move through the complete allowed slot range to place payload CG close to ALT axis.
4. Target residual CG offset approximately ≤10–15 mm for heavy payload when practical.
5. Re-tighten and confirm no residual slider motion/slip.
6. If slot travel is insufficient, reposition the payload adapter using the M4 pattern or add an intentional counterweight; do not extend the documented slider range without re-QA.

## 7. Mechanical-integrity / DOF checks before power

Follow `MECHANICAL_INTEGRITY_PROTOCOL.md`, `INTERFACES.md` constraint IDs and `MOTION_QA_PROTOCOL.md`.

- [ ] `K-001` AZ: M8 datum + turntable/glides + axial retention leave only intended AZ rotation; motor/gears do not carry vertical payload load.
- [ ] `K-002` ALT: two separated 608ZZ constrain the Ø8 shaft radially/coaxially; collar/output stack controls axial travel without binding.
- [ ] `K-003` payload adjustment: while loosened, slot/screw permits only intended balance translation to the documented limits; tightened state removes that DOF.
- [ ] All fastener heads/nuts/washers and real bolt/shaft envelopes are clear of forbidden solid volumes.
- [ ] Payload fastener moves through its full balance range without shaft/clamp contact.
- [ ] AZ makes a full physical 360° rotation with no binding/wobble.
- [ ] ALT moves physically through -20°..+90° with no collision/binding.
- [ ] ALT output spacer touches only drive-side 608 inner race.
- [ ] ALT compound axle is supported at plate + guard roof.
- [ ] Motor bodies do not contact structural arms.
- [ ] Real cables/connectors stay outside gear/swept volumes and have adequate service loops.
- [ ] Tabletop base does not rock and is physically stable with worst actual payload CG/ALT state.
- [ ] Payload remains secure when adjustment screw is tightened.

Powered load progression:

```text
no load → ~250 g → ~500 g → gradually toward project maximum <1 kg
```

At each step perform slow complete-range movement before increasing speed.

## 8. QA acceptance rule

A mechanical change is accepted only when all applicable items pass:

1. printable part full render/mesh QA (`Simple: yes`, watertight, expected components);
2. ISO + six orthographic views and useful critical sections;
3. realistic neighbor/hardware context;
4. solid-body relationship classification and forbidden-overlap checks;
5. support/constraint/load-path review;
6. assembly/tool/service feasibility;
7. complete affected operational + adjustment state-space QA, including endpoints and coupled states;
8. `PARTS.md`, `INTERFACES.md`, this BOM/sequence and `PROJECT_STATE.md` synchronized.

Current accepted automated evidence, sample counts and minimum clearances belong in `docs/motion-qa-results.md`; do not duplicate them here as a second numerical source of truth.

## 9. Remaining physical gates

### `HOLD-MOTOR-DIMS`
Measure actual 28BYJ-48 clones before production print.

### `HOLD-PRINT-FITS`
Calibrate printer/material bearing, shaft, fastener, nut and Double-D fits via coupons.

### `HOLD-AZ-AXLE`
Freeze a mechanically sound supported AZ compound axle only after physical fit.

### `VERIFY-ALT-DRIVE`
Verify motor pinion, shoulder axle, Ø8 output bore/spacer and grub-screw clamp physically.

### `VERIFY-PAYLOAD-ADJUSTMENT`
Verify complete slot travel, real 1/4-20 bolt/knob clearance, clamp preload and no payload slip with the intended payload.

### `VERIFY-TABLETOP-STABILITY`
Verify real payload CG, all-foot contact and overturn margin; CAD footprint alone is not proof.

### `VERIFY-CABLE-MOTION`
Future asymmetric cables/connectors/electronics invalidate the current symmetry-based AZ proof until modeled/conservatively enveloped and full state-space QA is repeated.
