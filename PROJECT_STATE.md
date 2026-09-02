# Project State — session resume checkpoint

This file is the short bootstrap index for resuming the project from a fresh chat or device. It does **not** replace the source, `PARTS.md`, `INTERFACES.md`, `ASSEMBLY.md`, QA documents or the design protocol.

## Current phase

**Dual-axis CAD prototype complete; physical fit calibration is now the main production-print gate.**

The current architecture is an Alt-Az mount for a balanced payload below 1 kg using two 28BYJ-48 stepper motors and an additional printable 20:1 reducer on each axis.

## Current trusted virtual assembly

Primary full assembly entry point:

```text
src/assemblies/full_mount.scad
```

Important subsystem entry points:

```text
src/assemblies/az_stage.scad
src/assemblies/yoke_stage.scad
src/assemblies/payload_stage.scad
src/assemblies/alt_drive_stage.scad
```

The full mount supports `ALT_ANGLE` for motion inspection. Existing documented visual QA sampled at least `-20°`, `0°`, `45°` and `90°`.

## Completed CAD/process subsystems

- AZ base and tripod interface.
- AZ printable 20:1 reducer.
- AZ rotating turntable.
- Yoke base bridge and two arms.
- Two 608ZZ ALT bearing supports.
- Ø8 mm ALT shaft architecture.
- Split payload shaft clamps.
- Payload plate and 1/4-20 payload screw knob.
- ALT gearbox mounting plate.
- ALT printable 20:1 reducer.
- ALT output spacer/hub coupling.
- ALT gearbox guard.
- Full two-axis virtual assembly.
- Repeatable per-part and assembly visual QA tooling.
- GitHub Pages browser validator using OpenSCAD WebAssembly + Three.js.
- Live mechanical assembly guide and hardware BOM in `ASSEMBLY.md`.
- Formal part decomposition and status ledger in `PARTS.md`.
- Stable mechanical interface contracts and invalidation map in `INTERFACES.md`.
- Repository-first continuity/mobile workflow contract.
- Physical calibration procedure in `CALIBRATION.md`.
- Three browser-renderable calibration coupons for bearings/shaft, fasteners/nut traps and the 28BYJ-48 mount/Double-D shaft.
- Full CGAL/mesh/visual QA of all three calibration coupons documented in `docs/calibration-qa.md`.

## Current source-of-truth documents

Read in this order when resuming work:

1. `REPOSITORY_CONTRACT.md`
2. `DESIGN_PROTOCOL.md`
3. this file
4. `README.md`
5. `PARTS.md` — elementary decomposition, stable part IDs, dependency/status ledger
6. `INTERFACES.md` — stable interface IDs, contracts and change-propagation rules
7. `ASSEMBLY.md` — current printable quantities, purchased BOM and physical assembly sequence
8. `CALIBRATION.md` — measurement worksheet and physical fit procedure
9. `src/config.scad` — shared numeric parameters and datums
10. `docs/visual-qa.md`
11. `docs/alt-drive-qa.md`
12. `docs/calibration-qa.md`
13. current relevant assembly and neighboring part sources

When changing geometry, use the stable part IDs from `PARTS.md` and interface IDs from `INTERFACES.md` in reasoning/commit notes where practical. This makes recursive backtracking and revalidation traceable across chats.

## Current HOLD / VERIFY items

### HOLD-MOTOR-DIMS

Measure the actual two 28BYJ-48 units before production print. Clone dimensions must not be assumed final.

Affected interface family: `I-003`, `I-004`, `I-020`, `I-021` and downstream gearbox context.

The dedicated `src/calibration/byj48_fit_coupon.scad` is ready to test both the mounting pattern and three Double-D clearances.

### HOLD-PRINT-FITS

Calibrate printer/material-dependent `FIT` / `PRESS_FIT`, screw clearances, captive nuts and bearing pockets before the complete print set.

The ready-to-print coupons are:

```text
src/calibration/mechanical_fit_coupon.scad
src/calibration/fastener_fit_coupon.scad
src/calibration/byj48_fit_coupon.scad
```

Record raw results in `CALIBRATION.md` before changing shared parameters.

### HOLD-AZ-AXLE

Freeze the AZ compound-gear intermediate axle only after physical fit validation. The CAD already provides upper/lower support intent; the real shoulder/plain-shank axle and final length still need dry-fit confirmation.

Primary contract: `I-006`.

### VERIFY-ALT-DRIVE

Physically verify motor shaft / Double-D pinion, M3 shoulder axle, Ø8 output bore/spacer and grub-screw clamp before freezing dimensions.

Primary contracts: `I-021`, `I-023`, `I-025`.

## Physical validation before production print

At minimum:

- measure both motors with calipers and fill `CALIBRATION.md`;
- measure actual 608ZZ bearings and Ø8 shaft;
- print the three calibration coupons using the intended production material/profile;
- select verified 608, shaft, M3/M4 and captive-nut fits;
- select the verified Double-D shaft clearance;
- feed results into `src/config.scad` only through the interface/invalidation procedure;
- print/dry-fit the AZ compound axle support and ALT output stack;
- dry-fit the complete mechanical assembly before threadlocker/final fastener-length freeze.

After a physical result changes a shared parameter, use `INTERFACES.md` to identify what is invalidated, mark affected entries in `PARTS.md`, re-run QA, then update `ASSEMBLY.md` and this checkpoint.

## Browser/mobile review path

GitHub Pages deploys the current `src/` OpenSCAD tree and generates a render manifest automatically on source/site changes. In a normal browser, including phone/tablet, the user can select a printable part, assembly or calibration coupon, run OpenSCAD WebAssembly locally, inspect the STL interactively and open the exact repository source used.

The mobile page links directly to current project state, parts ledger, interface map, assembly/BOM, calibration procedure, repository contract and design protocol.

## Remaining CAD work not blocked by measurements

The core two-axis mechanism is modeled. The main remaining geometry that can be completed without measured motor fits is packaging/accessory work, especially:

1. a stable removable tabletop adapter/base for the original flat-surface use case;
2. optional cable routing/strain relief once controller placement is decided;
3. optional electronics/ULN2003/controller carrier if electronics are kept in the mechanical project;
4. final print-orientation/production-set organization after physical fits are frozen.

The tabletop adapter is the next recommended non-blocked mechanical part because the original requirement included operation on a normal flat surface and the current `az_base` is primarily optimized for a 1/4-20 tripod interface.

## Next recommended engineering sequence

Two tracks can proceed in parallel:

```text
PHYSICAL TRACK
measure hardware
→ print calibration coupons
→ report fit results
→ update config/interface states
→ re-QA affected chain
→ functional dry-fit
→ production print freeze

CAD TRACK
P-TABLETOP-BASE
→ per-part QA
→ integrate with full mount
→ assembly/stability review
→ update PARTS / INTERFACES / ASSEMBLY / BOM / browser site
```

The next CAD part should therefore be the removable tabletop base unless the user explicitly prioritizes electronics or another accessory.

## Continuity invariant

A future chat must be able to continue this project from the repository alone. If a new engineering decision is made in chat and would be needed after restarting the conversation, commit that decision before considering the step complete.
