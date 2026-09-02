# Two-axis motion QA results

This document records the accepted CAD motion-validation checkpoint for the current core mechanical mount.

## Tested source

- Repository: `NikolaSl/alt-az-3d-mount`
- Tested commit: `4d3d772e65116ac5072a4187624929237a1252e4`
- GitHub Actions workflow: `Mechanical motion QA`
- Workflow run: `33616866312`
- Result: **PASS**
- Evidence artifact: `motion-qa-4d3d772e65116ac5072a4187624929237a1252e4` (artifact id `9841379214`)

The run used OpenSCAD to regenerate diagnostic meshes and the actual assembly sources, then Python `trimesh` + `python-fcl` for dense collision/distance sampling.

## ALT motion sweep

The payload collision body was tested over the full intended altitude range:

```text
-20° .. +90°
step = 1°
111 sampled ALT positions
```

Two obstruction sets were checked:

1. the fixed upper structure: yoke and external ALT gearbox/motor envelope;
2. a deliberately conservative lower envelope containing the AZ base, pedestal, cover, turntable and tabletop base.

Results:

```text
payload → upper structure
minimum distance = 6.000 mm
worst sampled pose = ALT -20°
collisions = 0

payload → conservative lower envelope
minimum distance = 43.000 mm
worst sampled pose = ALT +90°
collisions = 0
```

A second conservative lower envelope was enlarged by `0.50 mm` as a safety-clearance check. It also remained clear:

```text
expanded lower envelope margin = 0.50 mm
minimum remaining distance = 42.500 mm
worst sampled pose = ALT +90°
collisions = 0
```

The invariant side/bridge clearances are also checked independently by executable OpenSCAD assertions in `src/assemblies/motion_clearance_asserts.scad`.

## AZ motion sweep

The full assembly is parameterized by both `AZ_ANGLE` and `ALT_ANGLE`.

Actual assembly compilation was checked across:

```text
AZ = 0° .. 360°
step = 10°
37 samples including the 360° → 0° wrap endpoint
```

All 37 assembly poses compiled successfully.

For the current mechanical geometry, collision distance is invariant under AZ rotation for a specific ALT pose because:

- the payload, yoke and fixed ALT gearbox all undergo the same rigid AZ rotation;
- the lower collision model is intentionally a rotationally symmetric solid superset of the actual AZ base/cover/turntable/tabletop exterior.

Therefore the dense 1° ALT collision sweep establishes mechanical structural clearance for every AZ angle of the current design, while the explicit 10° AZ sweep additionally checks that the real parameterized assembly remains valid throughout the full wrap.

**This symmetry argument becomes invalid as soon as an asymmetric fixed obstruction is introduced.** Cable routing, connectors, electronics, hard stops or other future attachments must be added to the collision model and the full coupled motion QA must be re-run.

## Coupled configuration-space checks

In addition to the dense ALT sweep and AZ sweep, the actual assembly was compiled at:

```text
AZ = 0, 45, 90, 135, 180, 225, 270, 315°
ALT = -20, 0, 45, 90°
```

Total coupled configurations: **32**. All passed.

## Human/visual review

Ten representative tabletop full-mount poses were rendered as independent PNG evidence:

```text
AZ 0°   × ALT -20°, 0°, 45°, 90°
AZ 90°  × ALT -20°, 90°
AZ 180° × ALT -20°, 90°
AZ 270° × ALT -20°, 90°
```

The generated views were inspected after the automated run. No unexpected inversion, detached subassembly, obvious structural intersection or incorrect AZ/ALT transform was observed. The payload stage follows ALT while the complete upper structure follows AZ as intended.

## What this PASS proves

For the tested CAD source and modeled structural envelopes:

- no payload/upper-structure collision was found from ALT `-20°` through `+90°` at 1° increments;
- no payload/lower-structure collision was found over the same range;
- the configured 0.50 mm expanded lower-envelope test remains clear;
- the smallest sampled structural clearance is 6.0 mm, at the lower ALT limit;
- the full AZ range compiles cleanly including wrap;
- the coupled sampled AZ/ALT grid compiles cleanly;
- representative rendered poses are visually coherent.

## What this PASS does not prove

The following remain physical or future-integration gates:

- real cable routing and strain relief;
- backlash and elastic compliance;
- actual motor/reducer torque and skipped-step behavior;
- printer/material-dependent fits;
- real bearing/shaft alignment;
- physical hard-stop behavior, if introduced;
- real tabletop overturn stability;
- payload balance with the actual phone/optic;
- unmodeled accessories/electronics.

Any geometry or shared-parameter change that affects the motion envelope invalidates this checkpoint according to `INTERFACES.md` and `MOTION_QA_PROTOCOL.md`.
