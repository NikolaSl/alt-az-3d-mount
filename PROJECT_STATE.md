# Project State — fresh-session checkpoint

This is the concise resume index for the current machine. It does **not** replace source, `PARTS.md`, `INTERFACES.md`, `ASSEMBLY.md`, QA evidence or protocols.

## Current phase

**Core tripod/tabletop mount CAD is integrated; corrected payload attachment and full modeled mechanical state-space QA pass. Production printing is gated by physical hardware/fit/load verification.**

Architecture: balanced payload target below 1 kg, two 28BYJ-48 motors, printable 20:1 reducer on each axis, 120 mm AZ turntable, two 608ZZ ALT bearings, smooth Ø8×165 mm ALT shaft, sliding 1/4-20 manual balance attachment, tripod interface and removable Ø190 tabletop base.

## Important correction completed

Human browser review found that the original `camera_screw_knob` intersected the horizontal ALT shaft. This was a real CAD defect and exposed a QA gap: the old moving-payload collision union omitted the shaft because shaft/clamp/bearing contact is intentional, so internal bodies sharing the same ALT transform could overlap without being detected.

The accepted correction:

```text
upper payload clamp/riser height = 15 mm
payload plate underside Z        = 15 mm
knob bottom Z                    = 7 mm
ALT shaft top Z                  = 4 mm
designed knob→shaft gap          = 3 mm
complete balance slot preserved
```

The physical QA fastener now includes both printed knob and real metal 1/4-20 bolt head/shank envelope.

## Trusted full assemblies and review entries

```text
src/assemblies/full_mount.scad
src/assemblies/tabletop_full_mount.scad
src/assemblies/payload_stage.scad
src/assemblies/payload_adjustment_section.scad
src/assemblies/payload_adjustment_collision_check.scad
src/assemblies/motion_collision_check.scad
```

`full_mount.scad` and `tabletop_full_mount.scad` expose `AZ_ANGLE`, `ALT_ANGLE` and `PAYLOAD_SCREW_Y`.

## Accepted current QA checkpoint

Source/evidence: `docs/motion-qa-results.md`.

### Motion/state-space workflow

```text
tested commit: 81738de19ba399e1249ad35a8eb541aa1ca3f9e1
workflow run: 33772135101
artifact id: 9900281278
result: PASS
```

Key results:

```text
ALT structural range: -20° .. +90° every 1° = 111 states
payload structure→upper minimum: 6.0 mm @ -20°
payload structure→lower minimum: 43.0 mm @ +90°
0.5 mm expanded lower envelope: 42.5 mm remaining

payload screw-center range: -12.600 .. +28.600 mm
step: 0.500 mm = 84 states
physical fastener→ALT shaft minimum: 3.000 mm (required 3.000)
physical fastener→split clamps minimum: 2.800 mm (required 2.000)

ALT×slider states per external obstruction: 9,324
external obstruction envelopes: 3
fastener collision queries: 27,972
forbidden modeled collisions: 0

AZ compile sweep: 0° .. 360° every 10° = 37
coupled AZ/ALT grid: 32
actual full assembly slider-endpoint critical compile checks: 6
human-review renders: 14
```

### Payload geometric/visual regression

Workflow run `33772448736`: **PASS**.

```text
upper clamp/riser  18 × 30 × 15 mm  Simple yes / watertight / 1 component
lower clamp        18 × 30 × 8 mm   Simple yes / watertight / 1 component
payload plate      80 × 112 × 6 mm  Simple yes / watertight / 1 component
knob               30.4 × 30.4 × 8 mm Simple yes / watertight / 1 component
```

All changed elementary parts have seven standard views + X/Y/Z sections; payload context and Y-Z adjustment section preview QA also passed.

## Mechanical-integrity methodology now active

The repository now treats these as mandatory engineering contracts:

- `MECHANICAL_INTEGRITY_PROTOCOL.md` — physical solid relationships, supports, fasteners, constraint/DOF chains, load paths, under/overconstraint and manual/external constraints;
- `MOTION_QA_PROTOCOL.md` — full operational + adjustment/configuration state-space coverage;
- `INTERFACES.md` — stable `I-*`, `R-*`, `K-*` and `M-*` contracts.

Default rule: two physical solids may not overlap unless an explicit relationship permits a fit/contact/passage/embedded condition. Bodies sharing the same operational transform still require internal collision checks.

A CAD transform is not a mechanism. Principal current constraint chains:

```text
K-001 AZ: M8 central datum + turntable/PTFE support + axial retention
K-002 ALT: Ø8 shaft + two separated 608ZZ + axial retention
K-003 payload balance: slot constrains screw-center coordinate while loose;
                       operator controls payload yaw during manual setup;
                       tightened state must remove translation/yaw/slip
```

The current balance slot is therefore **manual adjustment**, not a self-guided one-DOF carriage. Repeatable/autonomous balance translation would require an anti-rotation guide/second locator/rail.

## QA scope limitation that must remain visible

Current automated PASS covers the **mount structure + payload attachment hardware**. It does not prove every arbitrary external phone/camera/optic, adapter or cable envelope.

Before a concrete payload is approved for unattended full-range operation:

```text
model conservative payload + adapter + cable envelope
OR
restrict and physically verify its allowed motion range
```

Future asymmetric fixed cables/connectors/electronics/hard stops also invalidate the current AZ rotational-symmetry collision proof until modeled/re-QA'd.

## Browser/mobile review architecture

Normal visualization is browser-only:

```text
SCAD entry
→ recursive dependency closure
→ exact deployed source + SHA-256 verification
→ background Web Worker
→ pinned OpenSCAD 2025.03.25 WASM + Manifold
→ binary STL
→ Three.js
```

No normal CI-prebuilt STL preview path is maintained. UI remains responsive, elapsed time/progress/diagnostics remain live and Cancel terminates the worker.

The mobile site exposes project state, interfaces/constraints, assembly/BOM, calibration, Mechanical Integrity, Motion QA and design/browser protocols.

## Fresh-session bootstrap

Read before changing geometry:

1. `REPOSITORY_CONTRACT.md`
2. `DESIGN_PROTOCOL.md`
3. `MECHANICAL_INTEGRITY_PROTOCOL.md`
4. `MOTION_QA_PROTOCOL.md`
5. `BROWSER_REVIEW_PROTOCOL.md`
6. this file
7. `README.md`
8. `PARTS.md`
9. `INTERFACES.md`
10. `ASSEMBLY.md`
11. `CALIBRATION.md`
12. `src/config.scad`
13. `docs/visual-qa.md`
14. `docs/motion-sweep-plan.md`
15. `docs/motion-qa-results.md`
16. current relevant assembly/part sources.

## Current HOLD / VERIFY gates

### `HOLD-MOTOR-DIMS`
Measure both actual 28BYJ-48 clones before production print.

### `HOLD-PRINT-FITS`
Print the three calibration coupons and record raw results in `CALIBRATION.md` before changing shared fits.

### `HOLD-AZ-AXLE`
Freeze a mechanically sound AZ compound axle/support only after physical dry-fit (`I-006`, `K-004`).

### `VERIFY-ALT-DRIVE`
Physically verify Double-D pinion, ALT shoulder axle, Ø8 output bore/spacer, grub-screw clamp and axial endplay.

### `VERIFY-PAYLOAD-ADJUSTMENT`
Verify actual 1/4-20 bolt/knob fit, full screw-center travel, final clamp preload, and no payload translation/yaw/slip after tightening. Loose balancing remains operator-constrained.

### `VERIFY-PAYLOAD-ENVELOPE`
Model/verify the actual phone/camera/optic + adapter + cables before claiming unrestricted unattended full-range operation.

### `VERIFY-TABLETOP-STABILITY`
Test actual payload CG, compliant feet/surface contact and overturn margin.

### `VERIFY-CABLE-MOTION`
When real cables/connectors/electronics are introduced, add their envelopes and re-run affected state-space QA.

## Next engineering sequence

```text
measure real motors / bearings / shaft / payload hardware
→ print 3 calibration coupons
→ record measurements and selected fits
→ update shared parameters via invalidation map
→ re-QA affected parts/state space
→ print functional interface parts
→ complete physical dry-fit
→ verify payload clamp/no-slip + real payload envelope
→ verify full physical motion and tabletop stability
→ freeze final fastener lengths / BOM / production print set
```

## Continuity invariant

Anything required by a future fresh session must be committed before an engineering step is considered complete.
