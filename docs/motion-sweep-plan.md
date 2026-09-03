# Alt-Az full-state mechanical QA sweep plan

This is the project-specific application of [`MOTION_QA_PROTOCOL.md`](../MOTION_QA_PROTOCOL.md) and [`MECHANICAL_INTEGRITY_PROTOCOL.md`](../MECHANICAL_INTEGRITY_PROTOCOL.md).

The mount must not be accepted from a few static poses alone. QA covers operational axes, adjustment coordinates, relevant coupled states, internal solid-pair interference and the physical constraint chains that enforce claimed degrees of freedom.

## State/constraint summary

```text
M-AZ               operational rotation       0° .. 360° continuous
M-ALT              operational rotation      -20° .. +90°
M-PAYLOAD-SLIDE    manual screw-center state  PAYLOAD_SLIDER_MIN_Y .. PAYLOAD_SLIDER_MAX_Y
```

Constraint IDs are defined in `INTERFACES.md`. In particular:

- AZ rotation is physically constrained to one rotational DOF by the central axis + supported turntable/glide system;
- ALT rotation is physically constrained by the Ø8 shaft + two separated 608 bearings + axial retention;
- payload balancing is a manual setup state: the 1/4-20 shank/slot constrains the **screw center** to the slot path, but a payload held by only that loose screw may still yaw; the operator supplies that missing orientation constraint during setup, and tightening must lock the final pose.

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

## M-PAYLOAD-SLIDE — manual balancing coordinate

The payload screw center can move through the usable centerline travel of the 48 mm slot:

```text
PAYLOAD_SLIDER_MIN_Y .. PAYLOAD_SLIDER_MAX_Y
```

The usable center travel is derived from slot length minus screw-clearance diameter; the screw center is not allowed to move beyond the end-circle centers.

`M-PAYLOAD-SLIDE` deliberately models the **slot-constrained screw-center coordinate**, not a claim that the complete loose payload has a unique one-dimensional trajectory. A single screw does not prevent payload yaw while loosened. During manual balancing the operator holds/aligns the payload; if future requirements need self-guided/repeatable translation, an anti-rotation guide/second locator must be designed and QA'd.

### Internal solid-pair sweep

`tools/payload_adjustment_qa.py` sweeps the complete screw-center travel at 0.5 mm intervals including both endpoints.

Forbidden/clearance checks include:

- `P-CAMERA-KNOB` + actual 1/4-20 bolt envelope ↔ `H-ALT-SHAFT`;
- payload fastener envelope ↔ both split clamp bodies.

Intentional relationships explicitly excluded from forbidden-overlap testing:

- bolt shank through payload-plate slot (`FASTENER_PASSAGE`);
- knob top clamping against plate underside (`INTENDED_CONTACT` when tightened);
- ALT shaft inside split-clamp bores (`KINEMATIC/MATING_CONTACT`).

The loose external payload's yaw envelope is not proven by this fastener-only sweep; it is a payload-specific/manual setup consideration and must be modeled conservatively if the attached payload can approach the yoke/gearbox during balancing.

### Operational × adjustment grid

The adjustable fastener also receives the ALT transform. Therefore `tools/motion_qa.py` checks the complete sampled Cartesian grid:

```text
ALT = -20° .. +90° every 1°
PAYLOAD_SCREW_Y = complete screw-center travel every 0.5 mm
```

against the upper fixed structure, lower conservative envelope and clearance-expanded lower envelope.

This prevents a default balance position from hiding a fastener collision at another legal screw-center position.

## M-AZ — azimuth axis

Intended mechanical range:

```text
0° .. 360° continuous, including 360° → 0° wrap
```

Automated/compile sweep:

- 10° over the complete revolution;
- explicitly include 0°/360° wrap;
- use finer sampling if non-axisymmetric fixed geometry/cabling is introduced.

The current rigid collision proof uses rotational symmetry: yoke, mount payload structure and ALT gearbox/fastener rotate together, while the conservative lower obstruction is rotationally symmetric. Future fixed cables, connectors, hard stops or electronics invalidate that proof until modeled and re-QA'd.

## Coupled AZ × ALT configurations

Independent sweeps are necessary but not sufficient.

Mandatory current compile/review set:

```text
AZ = 0°, 45°, 90°, 135°, 180°, 225°, 270°, 315°
ALT = -20°, 0°, 45°, 90°
```

This yields 32 coupled AZ/ALT configurations.

Additionally, the actual full assembly must compile at both payload screw-center endpoints for critical ALT states. If a future adjustment/payload can extend outside the conservative mount envelope, include it in the larger Cartesian grid rather than only endpoint samples.

## Solid-body exclusion rule

At every relevant state, no physical solid may intersect another unless the body-pair relation is explicitly classified as an intended fit/contact/passage/embedded relationship in `INTERFACES.md`.

Do not union all members of a moving subassembly and assume that proves self-clearance. Internal same-transform collisions are a separate QA layer.

Where an exact purchased body is not modeled, use a conservative hardware envelope including screw heads, nuts, washers, shafts and protrusions that can cause interference.

The eventual real phone/camera/optics is also a solid body. The current mount-structure QA does not prove clearance for every arbitrary external payload. Before a specific payload configuration is accepted for unattended full-range operation, model its conservative envelope (including adapter/cables) or restrict/physically verify the allowed motion range.

## Physical constraint / DOF checks

The state sweep is not sufficient by itself. Review that each claimed trajectory is mechanically realizable:

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

### Payload balance setup

- while loose, the slot/screw constrains the **screw center** transversely and bounds its Y travel;
- the complete payload is not self-guided against yaw by a single screw; the operator/fixture role is explicit;
- screw/knob remain captured through the plate;
- slot end-circle centers bound the modeled screw-center coordinate;
- when tightened, clamp preload must remove screw-center translation and payload yaw/slip;
- real payload threaded interface and clamp preload remain physical dry-fit/load gates;
- a future requirement for repeatable/self-guided translation requires an anti-rotation guide and new `K-*` constraint contract.

## Tabletop-specific checks

For `A-TABLETOP-FULL`, every critical mount ALT/adjustment state must remain clear of the tabletop support envelope.

Rigid CAD collision checks do not establish overturn stability. Physical tabletop verification still requires actual payload mass/CG, worst ALT orientation, all feet contacting, no rocking and acceptable overturn margin.

## Evidence package

Retain/regenerate at least:

- lower and upper ALT limits;
- neutral/reference pose;
- payload screw-center minimum and maximum at critical ALT poses;
- closest-clearance states reported by FCL;
- representative coupled AZ/ALT poses;
- guard-off view of ALT drive when useful;
- section/cutaway through shaft + payload knob/bolt adjustment;
- machine-readable list of sampled operational/adjustment states and pass/fail results;
- documented constraint/DOF register and any operator/external constraints;
- explicit scope note for the actual payload envelope/cables if they are not modeled.

## Acceptance rule

`A-FULL` / `A-TABLETOP-FULL` may be marked **mount-structure** mechanically motion-QA-passed only after:

1. full M-ALT sweep is complete;
2. full M-AZ sweep is complete or a documented conservative symmetry proof applies;
3. coupled AZ/ALT critical grid is complete;
4. full M-PAYLOAD-SLIDE internal fastener sweep is complete;
5. payload fastener ALT×slider external state grid is complete;
6. no forbidden modeled rigid-body conflict is present;
7. all required modeled clearances remain satisfied;
8. physical constraint chains/retention are coherent throughout claimed operational states;
9. manual setup states do not masquerade as self-guided mechanisms;
10. non-CAD constraints such as actual payload envelope/cables, stiffness/strength and tabletop stability remain explicit pending gates where applicable.
