# Project State — session resume checkpoint

This file is the short bootstrap index for resuming the project from a fresh chat or device. It does **not** replace the source, `PARTS.md`, `INTERFACES.md`, `ASSEMBLY.md`, QA documents or the design protocol.

## Current phase

**Core mechanical CAD is complete for both tripod and tabletop modes and the structural two-axis motion QA gate has passed; physical fit calibration and functional dry-fit are now the production-print gate.**

The current architecture is an Alt-Az mount for a balanced payload below 1 kg using two 28BYJ-48 stepper motors and an additional printable 20:1 reducer on each axis.

## Current trusted virtual assemblies

Primary tripod-mode full assembly:

```text
src/assemblies/full_mount.scad
```

Primary flat-surface full assembly:

```text
src/assemblies/tabletop_full_mount.scad
```

Important subsystem/context entry points:

```text
src/assemblies/az_stage.scad
src/assemblies/yoke_stage.scad
src/assemblies/payload_stage.scad
src/assemblies/alt_drive_stage.scad
src/assemblies/tabletop_base_context.scad
```

The full assemblies support both `AZ_ANGLE` and `ALT_ANGLE` for configuration-space inspection.

The accepted structural motion-QA checkpoint is documented in `docs/motion-qa-results.md`: ALT was collision/distance tested from `-20°` through `+90°` every `1°` (111 poses), AZ assembly compilation was tested from `0°` through `360°` every `10°`, and 32 coupled AZ/ALT configurations plus 10 representative renders passed. The smallest sampled payload-to-upper-structure clearance is **6.0 mm at ALT -20°**.

## Completed CAD/process subsystems

- Removable Ø190 mm tabletop base with shallow pedestal locator, recessed shared 1/4-20 attachment and four rubber-foot recesses.
- AZ base and shared tripod/tabletop interface.
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
- Full two-axis virtual assemblies for tripod and tabletop modes.
- Repeatable per-part and assembly visual QA tooling.
- Generic mandatory motion-QA protocol in `MOTION_QA_PROTOCOL.md`.
- Automated OpenSCAD + trimesh/python-fcl motion QA in `tools/motion_qa.py` and `.github/workflows/motion-qa.yml`.
- Dense structural motion QA PASS recorded in `docs/motion-qa-results.md`.
- GitHub Pages browser validator using OpenSCAD WebAssembly + Three.js.
- Live mechanical assembly guide and hardware BOM in `ASSEMBLY.md`.
- Formal part decomposition and status ledger in `PARTS.md`.
- Stable mechanical interface contracts and invalidation map in `INTERFACES.md`.
- Repository-first continuity/mobile workflow contract.
- Physical calibration procedure in `CALIBRATION.md`.
- Three browser-renderable calibration coupons for bearings/shaft, fasteners/nut traps and the 28BYJ-48 mount/Double-D shaft.
- Full CGAL/mesh/visual QA of all three calibration coupons documented in `docs/calibration-qa.md`.
- Full CGAL/mesh/visual QA of `P-TABLETOP-BASE`: `Simple: yes`, watertight, one connected component, 190×190×8 mm; context render against the actual `az_base` was also inspected.

## Current source-of-truth documents

Read in this order when resuming work:

1. `REPOSITORY_CONTRACT.md`
2. `DESIGN_PROTOCOL.md`
3. `MOTION_QA_PROTOCOL.md`
4. this file
5. `README.md`
6. `PARTS.md` — elementary decomposition, stable part IDs, dependency/status ledger
7. `INTERFACES.md` — stable interface IDs, contracts and change-propagation rules
8. `ASSEMBLY.md` — current printable quantities, purchased BOM and physical assembly sequence
9. `CALIBRATION.md` — measurement worksheet and physical fit procedure
10. `src/config.scad` — shared numeric parameters and datums
11. `docs/visual-qa.md`
12. `docs/motion-sweep-plan.md`
13. `docs/motion-qa-results.md`
14. `docs/alt-drive-qa.md`
15. `docs/calibration-qa.md`
16. current relevant assembly and neighboring part sources

When changing geometry, use the stable part IDs from `PARTS.md` and interface IDs from `INTERFACES.md` in reasoning/commit notes where practical.

## Current HOLD / VERIFY items

### HOLD-MOTOR-DIMS

Measure the actual two 28BYJ-48 units before production print. Clone dimensions must not be assumed final.

Affected interface family: `I-003`, `I-004`, `I-020`, `I-021` and downstream gearbox context.

The dedicated `src/calibration/byj48_fit_coupon.scad` is ready to test both the mounting pattern and three Double-D clearances.

### HOLD-PRINT-FITS

Calibrate printer/material-dependent `FIT` / `PRESS_FIT`, screw clearances, captive nuts and bearing pockets before the complete print set.

Ready-to-print coupons:

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

### VERIFY-TABLETOP-STABILITY

The Ø190 tabletop base is CAD-integrated through `I-028`, but stability depends on the actual payload CG, rubber feet and surface. Verify real overturn margin before unattended use at the project maximum load.

### VERIFY-FUTURE-ASYMMETRIC-MOTION-OBSTRUCTIONS

The current AZ structural collision proof relies on rotational symmetry of the lower mechanical envelope and common rigid AZ rotation of the upper structure. Asymmetric future objects — especially cables, connectors, electronics carriers or hard stops — must be added to the motion collision model and must trigger re-run of `MOTION_QA_PROTOCOL.md`.

## Physical validation before production print

At minimum:

- measure both motors with calipers and fill `CALIBRATION.md`;
- measure actual 608ZZ bearings and Ø8 shaft;
- print the three calibration coupons using the intended production material/profile;
- select verified 608, shaft, M3/M4 and captive-nut fits;
- select the verified Double-D shaft clearance;
- feed results into `src/config.scad` only through the interface/invalidation procedure;
- print/dry-fit the tabletop shared 1/4-20 interface if tabletop mode will be used;
- print/dry-fit the AZ compound axle support and ALT output stack;
- dry-fit the complete mechanical assembly before threadlocker/final fastener-length freeze;
- verify balance and tabletop stability with the real payload;
- re-run structural/motion QA after any changed physical-fit parameter that affects geometry or motion clearance.

After a physical result changes a shared parameter, use `INTERFACES.md` to identify what is invalidated, mark affected entries in `PARTS.md`, re-run QA, then update `ASSEMBLY.md` and this checkpoint.

## Browser/mobile review path

GitHub Pages deploys the current `src/` OpenSCAD tree and generates a render manifest automatically on source/site changes. In a normal browser, including phone/tablet, the user can select a printable part, assembly or calibration coupon, run OpenSCAD WebAssembly locally, inspect the STL interactively and open the exact repository source used.

For flat-surface review select:

```text
assemblies/tabletop_full_mount.scad
```

For the exact base interface select:

```text
assemblies/tabletop_base_context.scad
```

The mobile page links directly to current project state, parts ledger, interface map, assembly/BOM, calibration procedure, repository contract and design protocol.

## What remains to finish the mechanical product

The design is no longer blocked by missing major CAD parts or by unresolved structural motion collisions. The remaining work is primarily physical verification and production hardening:

1. physical measurements and calibration coupons;
2. propagation of measured values through shared parameters and affected interfaces;
3. physical AZ axle and ALT drive-stack fit tests;
4. complete dry-fit and real motion/balance tests;
5. tabletop stability test if that mode is used;
6. re-QA after any measured-parameter changes;
7. freeze BOM/fastener lengths and generate the final production print set.

Optional follow-on scope, not required for a mechanically complete mount:

- cable routing/strain relief;
- ULN2003/controller/electronics carrier;
- firmware/controller work;
- dedicated phone/optic adapter beyond the universal 1/4-20 payload interface.

## Next recommended engineering sequence

```text
measure real hardware
→ print the 3 calibration coupons
→ report measurements + chosen fits
→ update config + mark invalidated interfaces/parts
→ re-QA affected dependency chain, including motion QA where envelopes changed
→ print functional AZ/ALT interface parts
→ dry-fit full mount
→ balance + real motion + tabletop stability tests
→ freeze production BOM/print set
```

Until the physical results arrive, additional geometry should be treated as optional accessory development rather than as a blocker for the core mount.

## Continuity invariant

A future chat must be able to continue this project from the repository alone. If a new engineering decision is made in chat and would be needed after restarting the conversation, commit that decision before considering the step complete.
