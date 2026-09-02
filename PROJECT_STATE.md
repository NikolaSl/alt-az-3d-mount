# Project State — session resume checkpoint

This file is the short bootstrap index for resuming the project from a fresh chat or device. It does **not** replace the source, `PARTS.md`, `INTERFACES.md`, `ASSEMBLY.md`, QA documents or the design protocols.

## Current phase

**Core mechanical CAD is complete for tripod and tabletop modes, structural two-axis motion QA has passed, and browser/mobile CAD review is working responsively. Physical fit calibration and functional dry-fit are now the production-print gate.**

The current architecture is an Alt-Az mount for a balanced payload below 1 kg using two 28BYJ-48 stepper motors and an additional printable 20:1 reducer on each axis.

## Trusted full assemblies

```text
src/assemblies/full_mount.scad
src/assemblies/tabletop_full_mount.scad
```

Useful subsystem/context entry points:

```text
src/assemblies/az_stage.scad
src/assemblies/yoke_stage.scad
src/assemblies/payload_stage.scad
src/assemblies/alt_drive_stage.scad
src/assemblies/tabletop_base_context.scad
```

The full assemblies support both `AZ_ANGLE` and `ALT_ANGLE` for configuration-space inspection.

## Accepted motion-QA checkpoint

See `docs/motion-qa-results.md`.

Current accepted structural result:

```text
ALT: -20° .. +90° every 1° = 111 sampled poses
collisions: 0
minimum payload → upper structure: 6.0 mm @ -20°
minimum payload → conservative lower envelope: 43.0 mm @ +90°
0.5 mm expanded lower envelope: 42.5 mm remaining

AZ assembly: 0° .. 360° every 10° = 37 poses
coupled AZ/ALT grid: 32 configurations
representative rendered poses: 10
result: PASS
```

Any future asymmetric fixed obstruction such as cable routing, connectors, electronics carriers or hard stops invalidates the present rotational-symmetry argument and requires motion QA again.

## Browser/mobile review architecture

The generic rule is in `BROWSER_REVIEW_PROTOCOL.md`; the measured project result is in `docs/browser-review-results.md`.

**Accepted current policy: all normal CAD visualization is rendered directly in the browser. CI-prebuilt STL previews are not used.**

Rendering path:

```text
select SCAD entry
→ manifest dependency closure
→ fresh background Web Worker
→ pinned OpenSCAD 2025.03.25 WebAssembly
→ SHA-256 verify required source files
→ Manifold render
→ binary STL transfer
→ Three.js interactive display
```

Important properties:

- heavy OpenSCAD work never runs on the UI thread;
- unrelated repository SCAD files are not mounted for each render;
- the page remains responsive during rendering;
- elapsed time and render phase remain visible;
- the geometry phase uses an honest indeterminate progress indicator;
- the render can be cancelled by terminating the worker;
- user testing confirmed that ordinary non-cached models and useful assemblies now render in seconds on the mobile browser;
- a CI-prebuilt preview should be reintroduced only as a measured performance exception if browser performance becomes impractical again.

Current browser implementation:

```text
site/app.js
site/openscad-worker.js
tools/build_browser_manifest.py
.github/workflows/pages.yml
```

GitHub Pages deployment only snapshots source, builds the dependency-aware manifest, vendors the pinned WebAssembly/Three.js runtime, validates the site and publishes it. It no longer installs native OpenSCAD or generates preview STL caches.

## Completed mechanical/process subsystems

- removable Ø190 mm tabletop base;
- AZ base and shared tripod/tabletop 1/4-20 interface;
- AZ printable 20:1 reducer and rotating turntable;
- yoke bridge and two arms;
- two 608ZZ ALT bearing supports;
- Ø8 mm ALT shaft architecture;
- split payload shaft clamps and payload plate;
- motorized ALT 20:1 reducer, output stack and guard;
- complete tripod and tabletop virtual assemblies;
- per-part geometric/visual QA tooling;
- generic full-range `MOTION_QA_PROTOCOL.md`;
- automated structural motion QA using OpenSCAD diagnostic meshes + `trimesh/python-fcl`;
- responsive browser review protocol and Web Worker renderer;
- formal `PARTS.md` decomposition/status ledger;
- formal `INTERFACES.md` contracts/invalidation map;
- live `ASSEMBLY.md` and BOM;
- `CALIBRATION.md` plus three physical-fit coupons;
- repository-first continuity rules so a new chat can resume entirely from GitHub.

## Bootstrap order for a new chat

Read in this order before changing geometry:

1. `REPOSITORY_CONTRACT.md`
2. `DESIGN_PROTOCOL.md`
3. `MOTION_QA_PROTOCOL.md`
4. `BROWSER_REVIEW_PROTOCOL.md`
5. this file
6. `README.md`
7. `PARTS.md`
8. `INTERFACES.md`
9. `ASSEMBLY.md`
10. `CALIBRATION.md`
11. `src/config.scad`
12. `docs/visual-qa.md`
13. `docs/motion-sweep-plan.md`
14. `docs/motion-qa-results.md`
15. `docs/alt-drive-qa.md`
16. `docs/calibration-qa.md`
17. `docs/browser-review-results.md`
18. the current relevant assembly and neighboring part sources

When changing geometry, use the stable part IDs from `PARTS.md` and interface IDs from `INTERFACES.md` in reasoning/commit notes where practical.

## Current HOLD / VERIFY items

### HOLD-MOTOR-DIMS

Measure the actual two 28BYJ-48 units before production print. Clone dimensions must not be assumed final.

Affected interface family: `I-003`, `I-004`, `I-020`, `I-021` and downstream gearbox context.

### HOLD-PRINT-FITS

Calibrate printer/material-dependent fits before the complete print set.

Ready-to-print coupons:

```text
src/calibration/mechanical_fit_coupon.scad
src/calibration/fastener_fit_coupon.scad
src/calibration/byj48_fit_coupon.scad
```

Record raw results in `CALIBRATION.md` before changing shared parameters.

### HOLD-AZ-AXLE

Freeze the AZ compound-gear intermediate axle only after physical fit validation. Primary contract: `I-006`.

### VERIFY-ALT-DRIVE

Physically verify motor shaft / Double-D pinion, M3 shoulder axle, Ø8 output bore/spacer and grub-screw clamp. Primary contracts: `I-021`, `I-023`, `I-025`.

### VERIFY-TABLETOP-STABILITY

The Ø190 tabletop base is CAD-integrated through `I-028`, but real stability depends on payload CG, rubber feet and surface.

## Physical validation before production print

At minimum:

- measure both 28BYJ-48 motors with calipers;
- measure the actual 608ZZ bearings and Ø8 shaft;
- print the three calibration coupons using the intended production material/profile;
- select verified bearing, shaft, screw and captive-nut fits;
- select the verified Double-D shaft clearance;
- update `src/config.scad` only through the interface/invalidation procedure;
- re-QA affected parts and assemblies after changed measurements;
- re-run motion QA if a changed parameter affects the motion envelope;
- dry-fit the AZ compound axle support and ALT output stack;
- dry-fit the complete mount;
- verify balance and tabletop stability with the actual payload;
- freeze final fastener lengths and BOM only after physical validation.

## Next recommended engineering sequence

```text
measure real hardware
→ print 3 calibration coupons
→ record measurements/fits
→ update shared parameters
→ invalidate/re-QA affected interfaces and parts
→ print functional AZ/ALT interface parts
→ full dry-fit
→ real motion/balance/tabletop tests
→ freeze production BOM and print set
```

Until physical measurements arrive, additional CAD geometry is optional accessory development rather than a blocker for the core mount.

## Continuity invariant

A future chat must be able to continue this project from the repository alone. Any design/process decision needed later must be committed before the step is considered complete.