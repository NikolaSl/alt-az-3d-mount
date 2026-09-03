# Full-state mechanical QA results

This document records the accepted CAD/state-space validation checkpoint for the current **mount structure and payload attachment hardware**.

## Why this checkpoint supersedes the old one

Human review of `tabletop_full_mount.scad` exposed a real internal interference: the printed payload screw knob occupied the same volume as the horizontal Ø8 ALT shaft. The earlier structural motion test did not catch it because shaft/clamp/bearing engagement was intentionally omitted from a monolithic moving-payload obstruction and the knob moved under the same ALT transform.

The correction therefore changed both geometry and methodology:

- raise the payload plate from the ALT shaft using the upper split-clamp halves as structural risers;
- preserve the complete balancing-slot travel instead of shortening it;
- model the printed knob **plus the real metal 1/4-20 bolt envelope** as a distinct physical body;
- check internal same-transform body pairs explicitly;
- treat the balancing slot as a mechanically relevant manual setup coordinate;
- couple that screw-center coordinate with the complete ALT range;
- distinguish a CAD state parameter from a physically self-guided DOF.

The old checkpoint at commit `4d3d772e...` is retained in Git history but is superseded by the evidence below.

## Tested source and workflows

### Full motion/state-space QA

- Repository: `NikolaSl/alt-az-3d-mount`
- Tested commit: `81738de19ba399e1249ad35a8eb541aa1ca3f9e1`
- Workflow: `Mechanical motion QA`
- Workflow run: `33772135101` / run #40
- Result: **PASS**
- Evidence artifact: `motion-qa-81738de19ba399e1249ad35a8eb541aa1ca3f9e1`
- Artifact id: `9900281278`

The run uses OpenSCAD to regenerate diagnostic bodies and actual assembly poses, then `trimesh` + `python-fcl` for dense collision/distance evaluation.

### Payload visual/geometric regression

- Workflow: `Visual geometric QA`
- Workflow run: `33772448736`
- Result: **PASS**

Full geometric QA passed for the four changed elementary payload parts:

```text
payload_clamp_upper.scad   Simple yes, watertight, 1 component, 18 × 30 × 15 mm
payload_clamp_lower.scad   Simple yes, watertight, 1 component, 18 × 30 × 8 mm
payload_plate.scad         Simple yes, watertight, 1 component, 80 × 112 × 6 mm
camera_screw_knob.scad     Simple yes, watertight, 1 component, 30.4 × 30.4 × 8 mm
```

Each full part QA also generated the seven standard views plus X/Y/Z center sections. `payload_stage.scad` and `payload_adjustment_section.scad` passed context/section preview QA.

## Corrected payload attachment geometry

The accepted CAD geometry now uses:

```text
ALT shaft diameter                   8.0 mm
shaft top above ALT axis             4.0 mm
upper clamp / plate riser height    15.0 mm
payload plate underside Z           15.0 mm
knob height                           8.0 mm
knob bottom Z                         7.0 mm
designed knob → shaft clearance      3.0 mm
```

The upper split-clamp half is therefore also the structural riser. The complete original balancing-slot travel remains available.

The physical fastener QA envelope includes both the printed knob and a conservative metal 1/4-20 bolt head/shank envelope; the test is not based on the plastic knob alone.

## Internal payload adjustment solid-pair QA

`tools/payload_adjustment_qa.py` sweeps the complete slot-constrained **screw-center** travel:

```text
PAYLOAD_SCREW_Y = -12.600 .. +28.600 mm
step = 0.500 mm
84 states including both endpoints
```

Results:

```text
physical payload fastener → ALT shaft
minimum distance = 3.000 mm
worst sampled Y = -12.600 mm
required = 3.000 mm
collisions = 0
status = CLEAR

physical payload fastener → split clamp bodies
minimum distance = 2.800 mm
worst sampled Y = -12.600 mm
required = 2.000 mm
collisions = 0
status = CLEAR
```

Intentional relations are explicitly excluded from forbidden-overlap testing:

- bolt shank through payload plate slot: `FASTENER_PASSAGE`;
- knob top against plate underside in the tightened state: `INTENDED_CONTACT`;
- ALT shaft inside split-clamp bores: intentional mating/kinematic contact.

All other tested fastener↔shaft/clamp overlap is forbidden.

## ALT structural sweep

The revised payload structural body was tested over the full intended altitude range:

```text
ALT = -20° .. +90°
step = 1°
111 states
```

Results remain:

```text
payload structure → fixed upper structure
minimum distance = 6.000 mm
worst sampled pose = ALT -20°
collisions = 0

payload structure → conservative lower envelope
minimum distance = 43.000 mm
worst sampled pose = ALT +90°
collisions = 0

payload structure → lower envelope expanded by 0.50 mm
minimum remaining distance = 42.500 mm
worst sampled pose = ALT +90°
collisions = 0
```

Executable analytic assertions independently check invariant side/bridge and payload-fastener clearances.

## Coupled ALT × payload-adjustment grid

The physical payload fastener is checked independently of the structural payload body over the complete sampled Cartesian state space:

```text
ALT samples = 111
screw-center samples = 84
states per obstruction = 111 × 84 = 9,324
```

It is tested against three obstruction envelopes:

1. fixed upper structure;
2. conservative lower structure;
3. lower structure expanded by 0.50 mm.

Total dense collision queries for this layer:

```text
9,324 × 3 = 27,972
```

No forbidden fastener collision was found.

The expanded-lower test converts the required 0.50 mm lower safety margin into a collision-exclusion problem, while the dedicated internal adjustment sweep proves the 3.0 mm shaft and 2.0 mm clamp requirements with actual minimum-distance queries.

## AZ and coupled operational configurations

Actual assembly compilation checks:

```text
AZ = 0° .. 360° every 10°
37 positions including the 360° → 0° wrap endpoint

AZ = 0,45,90,135,180,225,270,315°
ALT = -20,0,45,90°
32 coupled AZ/ALT configurations
```

The actual full assembly also compiled successfully at **both payload screw-center endpoints** for ALT `-20°`, `0°` and `+90°`.

Human-review evidence contains 14 rendered poses: the prior representative AZ/ALT set plus both slider endpoints at critical ALT limits.

Current AZ collision reasoning remains valid because the modeled upper bodies share the same rigid AZ transform and the lower diagnostic obstruction is a rotationally symmetric conservative superset. Any future asymmetric fixed body such as cable routing, connector, electronics carrier or hard stop invalidates that symmetry proof until modeled/re-QA'd.

## Constraint / DOF interpretation

This checkpoint deliberately does not pretend that every CAD parameter is a self-guided mechanism DOF.

### AZ

`K-001`: central M8 datum + turntable/PTFE support + axial retention constrain the upper stage to the intended AZ rotation. The drive transmits torque; it is not the structural bearing.

### ALT

`K-002`: the Ø8 shaft is supported by two separated/coaxial 608ZZ bearings, with output-side/idler retention controlling axial travel. This constrains the payload shaft to the intended ALT rotation.

### Payload balancing

`K-003` / `M-PAYLOAD-SLIDE` is a **manual setup state**. The slot physically constrains the 1/4-20 screw center to the longitudinal path and bounds that coordinate, but a payload held by one loose screw can still yaw about it. The operator/adapter supplies that missing orientation constraint during balancing. The final tightened state must remove screw-center translation and payload yaw/slip.

Therefore the automated sweep proves the screw/knob/bolt clearance throughout its slot-constrained coordinate, not that an arbitrary loose external payload is a self-guided one-DOF carriage. If repeatable/autonomous linear adjustment is ever required, add a second locator/slot, keyed carriage, rail or other anti-rotation guide and revalidate.

## What this PASS proves

For the modeled mount structure and payload attachment hardware:

- the previously observed knob↔ALT-shaft collision is removed;
- the real fastener envelope remains ≥3.0 mm from the shaft over the complete screw-center travel;
- it remains ≥2.8 mm from the split clamps, exceeding the 2.0 mm requirement;
- no modeled payload-structure collision is found over ALT -20°..+90° at 1° resolution;
- the 0.50 mm expanded lower envelope remains clear;
- no adjustable-fastener collision is found in 27,972 ALT×slider obstruction queries;
- the full AZ wrap and 32 coupled AZ/ALT configurations compile successfully;
- both balance-travel endpoints compile in the actual full assembly at critical ALT states;
- changed elementary payload parts pass full mesh/visual QA;
- the mount's principal AZ/ALT support/constraint chains are explicitly documented rather than inferred from CAD transforms.

## Scope and remaining physical gates

This is a **mount-structure + payload attachment hardware** CAD/state-space PASS. It does not prove every arbitrary phone/camera/optic envelope.

Before a specific payload is approved for unattended full-range operation, model a conservative payload + adapter + cable envelope or restrict and physically verify its allowed motion range.

Still pending physically:

- actual 28BYJ-48 dimensions;
- printer/material-dependent fits;
- 608/Ø8 shaft physical coaxiality and endplay;
- final AZ compound-axle support (`HOLD-AZ-AXLE`);
- ALT output/pinion/shoulder-axle/grub-screw stack;
- real 1/4-20 payload screw/knob dry-fit and final clamp preload/no-slip behavior;
- actual payload envelope, CG, adapter and cables;
- backlash, compliance, torque and skipped-step behavior;
- tabletop overturn stability;
- future asymmetric electronics/cables/hard stops.

Any change to an affected solid envelope, constraint chain, state range, fastener envelope or physical-support assumption invalidates the corresponding checkpoint according to `INTERFACES.md`, `MECHANICAL_INTEGRITY_PROTOCOL.md` and `MOTION_QA_PROTOCOL.md`.
