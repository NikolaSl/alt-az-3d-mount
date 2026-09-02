# Project State — session resume checkpoint

This file is the short bootstrap index for resuming the project from a fresh chat or device. It does **not** replace the source, `PARTS.md`, `INTERFACES.md`, `ASSEMBLY.md`, QA documents or the design protocol.

## Current phase

**Dual-axis CAD prototype complete enough for browser review; physical fit validation still pending before production printing.**

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

## Current source-of-truth documents

Read in this order when resuming work:

1. `REPOSITORY_CONTRACT.md`
2. `DESIGN_PROTOCOL.md`
3. this file
4. `README.md`
5. `PARTS.md` — elementary decomposition, stable part IDs, dependency/status ledger
6. `INTERFACES.md` — stable interface IDs, contracts and change-propagation rules
7. `ASSEMBLY.md` — current printable quantities, purchased BOM and physical assembly sequence
8. `src/config.scad` — shared numeric parameters and datums
9. `docs/visual-qa.md`
10. `docs/alt-drive-qa.md`
11. current relevant assembly and neighboring part sources

When changing geometry, use the stable part IDs from `PARTS.md` and interface IDs from `INTERFACES.md` in reasoning/commit notes where practical. This makes recursive backtracking and revalidation traceable across chats.

## Current HOLD / VERIFY items

### HOLD-MOTOR-DIMS

Measure the actual two 28BYJ-48 units before production print. Clone dimensions must not be assumed final.

Affected interface family: `I-003`, `I-004`, `I-020`, `I-021` and downstream gearbox context.

### HOLD-PRINT-FITS

Calibrate printer/material-dependent `FIT` / `PRESS_FIT`, screw clearances, captive nuts and bearing pockets before the complete print set.

This can invalidate multiple printed-to-hardware interfaces; use the invalidation map in `INTERFACES.md` rather than changing local holes independently.

### HOLD-AZ-AXLE

Freeze the AZ compound-gear intermediate axle only after physical fit validation. The design intent is a properly supported smooth/shoulder axle, not a long unsupported cantilever screw.

Primary contract: `I-006`.

### VERIFY-ALT-DRIVE

Physically verify motor shaft / Double-D pinion, M3 shoulder axle, Ø8 output bore/spacer and grub-screw clamp before freezing dimensions.

Primary contracts: `I-021`, `I-023`, `I-025`.

## Physical validation before production print

At minimum:

- measure both motors with calipers;
- measure actual 608ZZ bearings and Ø8 shaft;
- print fit coupons for bearing, shaft, M3/M4 and captive-nut dimensions;
- test 1/4-20 and M8 captive interfaces;
- test motor Double-D pinion fit;
- test ALT output hub/spacer and grub-screw strategy;
- dry-fit assembly before applying threadlocker or committing to all final hardware lengths.

After a physical result changes a shared parameter, use `INTERFACES.md` to identify what is invalidated, mark affected entries in `PARTS.md`, re-run QA, then update `ASSEMBLY.md` and this checkpoint.

See `ASSEMBLY.md` for the complete current sequence and BOM.

## Browser/mobile review path

GitHub Pages deploys the current `src/` OpenSCAD tree and generates a render manifest automatically on source/site changes. In a normal browser, including phone/tablet, the user can select a printable part or assembly, run OpenSCAD WebAssembly locally, inspect the STL interactively and open the exact repository source used.

The mobile page also links directly to current project state, parts ledger, interface map, assembly/BOM, repository contract and design protocol so a human reviewer can inspect both geometry and engineering state without a desktop CAD session.

For every new major part or subsystem, browser publication/review is part of the integration gate defined in `REPOSITORY_CONTRACT.md`.

## Next recommended engineering step

Do **not** extend geometry blindly before the physical interface assumptions are known.

Recommended next sequence:

1. measure the actual 28BYJ-48 motors and purchased bearings/shaft;
2. map each measured change to interface IDs in `INTERFACES.md`;
3. feed approved measurements into `src/config.scad`;
4. mark affected part IDs `NEEDS_REVALIDATION` in `PARTS.md`;
5. generate small physical fit coupons for uncertain interfaces;
6. re-run affected part QA and full assembly QA in dependency order;
7. update `ASSEMBLY.md`, BOM and this file with frozen/changed dimensions;
8. only then proceed toward the production print set or further accessories/electronics.

If the user explicitly wants continued conceptual/CAD development before hardware measurement, mark new dependent interfaces provisional and preserve that status in `PARTS.md` / `INTERFACES.md`.

## Continuity invariant

A future chat must be able to continue this project from the repository alone. If a new engineering decision is made in chat and would be needed after restarting the conversation, commit that decision before considering the step complete.
