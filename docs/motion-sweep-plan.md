# Alt-Az full-state mechanical QA sweep plan

This is the project-specific application of [`MOTION_QA_PROTOCOL.md`](../MOTION_QA_PROTOCOL.md) and [`MECHANICAL_INTEGRITY_PROTOCOL.md`](../MECHANICAL_INTEGRITY_PROTOCOL.md).

The mount must not be accepted from a few static poses alone. QA covers operational axes, adjustment travel, relevant coupled states, internal solid-pair interference and the physical constraint chains that enforce the intended degrees of freedom.

## State/constraint summary

```text
M-AZ               operational rotation     0° .. 360° continuous
M-ALT              operational rotation    -20° .. +90°
M-PAYLOAD-SLIDE    balance adjustment       PAYLOAD_SLIDER_MIN_Y .. PAYLOAD_SLIDER_MAX_Y
```

Constraint IDs are defined in `INTERFACES.md`. In particular:

- AZ rotation must be physically constrained to one rotational DOF by the central axis + supported turntable/glide system;
- ALT rotation must be physically constrained by the Ø8 shaft + two separated 608 bearings + axial retention;
- payload balancing travel exists only while the 1/4-20 clamp is loosened; the screw shank/slot constrains the adjustment path and tightening removes the translation.

## M-ALT — altitude axis

Current range:

```text
-20° .. +90°
```

Mandatory review poses:

```text
-20°  lower end limit
0°    reference
45°   representative intermediate
90°   upper end limit
```

Automated structural sweep:

- 1° sampling across the complete range for the accepted checkpoint;
- refine finer than 1° if a future change creates a clearance transition comparable to one sample's local motion;
- test payload structural body against yoke/ALT gearbox and conservative lower structure;
- inspect bearing/shaft/output-stack coherence and physical retention separately from pure collision distance.

## M-PAYLOAD-SLIDE — balancing adjustment

The payload screw center can move through the usable centerline travel of the 48 mm slot:

```text
PAYLOAD_SLIDER_MIN_Y .. PAYLOAD_SLIDER_MAX_Y
```

The usable center travel is derived from slot length minus screw-clearance diameter; the screw center is not allowed to move beyond the end-circle centers.

### Internal solid-pair sweep

`tools/payload_adjustment_qa.py` sweeps the complete adjustment travel at 0.5 mm intervals including both endpoints.

Forbidden/clearance checks include:

- `P-CAMERA-KNOB` + actual 1/4-20 bolt envelope ↔ `H-ALT-SHAFT`;
- payload fastener envelope ↔ both split clamp bodies.

Intentional relationships explicitly excluded from forbidden-overlap testing:

- bolt shank through payload-plate slot (`FASTENER_PASSAGE`);
- knob top clamping against plate underside (`INTENDED_CONTACT` when tightened);
- ALT shaft inside split-clamp bores (`KINEMATIC/MATING_CONTACT`).

### Operational × adjustment grid

The adjustable fastener also receives the ALT transform. Therefore `tools/motion_qa.py` checks the complete sampled Cartesian grid:

```text
ALT = -20° .. +90° every 1°
PAYLOAD_SCREW_Y = complete slot travel every 0.5 mm
```

against the upper fixed structure, lower conservative envelope and clearance-expanded lower envelope.

This prevents a default balance position from hiding a collision at another legal adjustment.

## M-AZ — azimuth axis

Intended mechanical range:

```text
0° .. 360° continuous, including 360° → 0° wrap
```

Automated/compile sweep:

- 10° over the complete revolution;
- explicitly include 0°/360° wrap;
- use finer sampling if non-axisymmetric fixed geometry/cabling is introduced.

The current rigid collision proof uses rotational symmetry: yoke, payload and ALT gearbox/fastener rotate together, while the conservative lower obstruction is rotationally symmetric. Future fixed cables, connectors, hard stops or electronics invalidate that proof until modeled and re-QA'd.

## Coupled AZ × ALT configurations

Independent sweeps are necessary but not sufficient.

Mandatory current compile/review set:

```text
AZ = 0°, 45°, 90°, 135°, 180°, 225°, 270°, 315°
ALT = -20°, 0°, 45°, 90°
```

This yields 32 coupled AZ/ALT configurations.

Additionally, the actual full assembly must compile at both payload-slider endpoints for critical ALT states. If a future adjustment can extend outside the conservative payload envelope, include it in the larger Cartesian grid rather than only endpoint samples.

## Solid-body exclusion rule

At every relevant state, no physical solid may intersect another unless the body-pair relation is explicitly classified as an intended fit/contact/passage/embedded relationship in `INTERFACES.md`.

Do not union all members of a moving subassembly and assume that proves self-clearance. Internal same-transform collisions are a separate QA layer.

Where an exact purchased body is not modeled, use a conservative hardware envelope including screw heads, nuts, washers, shafts and protrusions that can cause interference.

## Physical constraint / DOF checks

The state sweep is not sufficient by itself. Review that each trajectory is mechanically realizable:

### AZ

- central axis defines radial datum;
- PTFE/glide support carries vertical load;
- retaining hardware controls axial play without binding;
- drive train transmits torque but is not the primary structural bearing.

### ALT

- two separated 608 bearings define/coaxially support the Ø8 shaft;
- output side + idler collar provide axial retention with controlled endplay;
- payload clamps transmit payload torque to the shaft;
- gearbox output transmits torque without using the motor shaft as payload support.

### Payload balance adjustment

- when loosened, slot/screw geometry constrains adjustment primarily along slot Y;
- screw/knob/payload remain captured through the plate;
- slot ends bound usable translation;
- when tightened, clamp preload removes adjustment translation and resists payload rotation/slip;
- real payload threaded interface and clamp preload remain physical dry-fit/load gates.

## Tabletop-specific checks

For `A-TABLETOP-FULL`, every critical ALT/adjustment state must remain clear of the tabletop support envelope.

Rigid CAD collision checks do not establish overturn stability. Physical tabletop verification still requires actual payload mass/CG, worst ALT orientation, all feet contacting, no rocking and acceptable overturn margin.

## Evidence package

Retain/regenerate at least:

- lower and upper ALT limits;
- neutral/reference pose;
- payload slider minimum and maximum at critical ALT poses;
- closest-clearance states reported by FCL;
- representative coupled AZ/ALT poses;
- guard-off view of ALT drive when useful;
- section/cutaway through shaft + payload knob/bolt adjustment;
- machine-readable list of sampled operational/adjustment states and pass/fail results;
- documented constraint/DOF register and any physical verification still pending.

## Acceptance rule

`A-FULL` / `A-TABLETOP-FULL` may be marked mechanically motion-QA-passed only after:

1. full M-ALT sweep is complete;
2. full M-AZ sweep is complete or a documented conservative symmetry proof applies;
3. coupled AZ/ALT critical grid is complete;
4. full M-PAYLOAD-SLIDE internal sweep is complete;
5. payload fastener ALT×slider external state grid is complete;
6. no forbidden rigid-body conflict is present;
7. all required clearances remain satisfied;
8. physical constraint chains/retention are coherent throughout the states;
9. non-CAD constraints such as cable behavior, stiffness/strength and tabletop stability remain explicit pending gates where applicable.
