# Visual / geometric / context QA loop

Every mechanical design iteration is validated before it is accepted. Use this with [`MECHANICAL_INTEGRITY_PROTOCOL.md`](../MECHANICAL_INTEGRITY_PROTOCOL.md) and [`MOTION_QA_PROTOCOL.md`](../MOTION_QA_PROTOCOL.md).

## Individual printable part

Minimum loop:

1. Export the SCAD entry point with full render + hard warnings.
2. Require simple/manifold geometry where reported, watertight mesh and expected connected-component count.
3. Check plausible bounding box/orientation.
4. Render ISO, top, bottom, front, back, left and right views.
5. Produce X/Y/Z center sections.
6. Add critical offset sections through hidden bearing seats, shaft bores, fastener stacks, nut traps, thin walls and interfaces.
7. Repeat after geometry changes.

Run from repository root:

```bash
python3 tools/visual_qa.py src/parts/az_turntable.scad
```

## Neighbor/context QA includes real physical solids

A printable part is not validated in isolation from hardware that can occupy space. Context QA must include directly interacting neighbors and realistic/conservative envelopes for relevant purchased/fabricated bodies:

```text
shafts
bearings
screw heads + shanks
nuts / washers / inserts
motors
payload attachment hardware
connectors / cable exits
other bodies that can interfere
```

Check forbidden overlaps, required clearances, intended fits/contacts/passages, axis/hole alignment, fastener insertion/thread engagement, tool access, assembly order, removal/service path and material around holes/pockets.

A hole center is not a complete fastener model if its head, nut, washer or protruding shank can hit something.

## Support / constraint / load-path review

Visual/context QA must make the real mechanism explainable, not merely animated.

For each installed body/subassembly identify:

- what supports gravity/radial/axial load;
- what reacts drive torque;
- what removes each unintended translation/rotation;
- what retains the body axially/laterally;
- what bounds travel;
- whether support spacing is plausible for the expected moment;
- whether a motor shaft, gear axle or thin printed wall is accidentally carrying structural load;
- whether redundant constraints require impossible alignment.

Use sections/cutaways/exploded context where necessary. A CAD `rotate()` or `translate()` does not prove the real body is constrained to that path.

## Assembly QA and internal interference

Large assemblies can use preview-only rendering when their individual printable parts already passed full mesh QA:

```bash
python3 tools/visual_qa.py src/assemblies/payload_stage.scad --preview-only
```

Preview-only does **not** replace physical interaction QA.

Bodies sharing the same assembly/motion transform can still intersect one another. Therefore:

- do not rely on one monolithic moving-body union to prove internal clearance;
- classify intentional fit/contact/passage relationships explicitly;
- otherwise treat physical overlap as forbidden;
- generate a critical section through a hidden suspected pair.

The payload knob/ALT-shaft defect is the reference example: both belonged to the rotating payload stage, so ordinary moving-vs-fixed QA missed their internal overlap. `payload_adjustment_section.scad` and the dedicated FCL sweep now cover that relationship.

## Moving / adjustable / configuration states

A few named poses are insufficient. QA must cover the complete mechanically relevant state space with justified sampling/proofs:

```text
operational DOFs
× adjustment coordinates / DOFs
× relevant discrete configurations
× relevant setup/service states
```

For each state verify as applicable:

- moving↔fixed and moving↔moving collision;
- **same-transform internal** collision;
- required minimum clearance;
- fastener/hardware envelopes;
- payload/counterweight swept envelope;
- gear/shaft/bearing relationships;
- guard/cover clearance;
- cable/hose bend/twist/extension;
- hard-stop/retention behavior;
- constraint-chain coherence.

Endpoints are mandatory. Refine sampling near small clearances or transitions. Swept-volume/conservative-envelope reasoning should supplement sampling where useful.

Manual setup coordinates must not masquerade as self-guided DOFs. For the current payload slot, QA sweeps the physically constrained screw-center coordinate while operator-controlled loose payload yaw is explicitly outside the claim.

When any solid envelope, axis, support chain, state range, payload envelope, fastener envelope or neighboring clearance changes, invalidate and repeat the **complete affected QA scope**, not only the earlier failing pose.

## Current tooling/evidence

- `tools/visual_qa.py` → STL/mesh stats, seven views, X/Y/Z sections, contact sheet, `qa.json`;
- `tools/motion_qa.py` → structural + coupled state-space FCL QA;
- `tools/payload_adjustment_qa.py` → internal fastener↔shaft/clamp minimum-distance sweep;
- `.github/workflows/visual-qa.yml` → reproducible full payload part regression + context/section preview;
- `.github/workflows/motion-qa.yml` → reproducible state-space QA.

Generated evidence lives under `build/`/Actions artifacts and is derived data. Repository SCAD, shared parameters, interface/constraint contracts and committed QA procedures remain authoritative.
