# Mechanical Integrity Protocol — solids, supports, constraints and real DOFs

This protocol is project-agnostic. It complements `DESIGN_PROTOCOL.md`, `VISUAL_QA_PROTOCOL.md` / `docs/visual-qa.md`, and `MOTION_QA_PROTOCOL.md`.

Its purpose is to prevent two classes of CAD errors that ordinary assembly rendering can miss:

1. two physical solid bodies occupying the same volume in some allowed state;
2. a CAD transform describing a desired trajectory even though the real mechanism has no supports/guides that physically constrain the body to that trajectory.

## 1. Solid-body exclusion invariant

Every physical solid body in the machine must be represented in the mechanical interaction model, including printed parts, purchased hardware, shafts, bearings, screw heads/shanks, nuts, washers, payload envelopes and other bodies that can create interference.

For every relevant body pair, classify the relationship as exactly one of:

- `FORBIDDEN_OVERLAP` — no common volume is allowed;
- `CLEARANCE` — no common volume and a specified minimum distance is required;
- `INTENDED_CONTACT` — touching is expected but penetration is not;
- `MATING_FIT` — controlled interference/clearance is intentionally defined by a fit contract;
- `KINEMATIC_CONTACT` — bearing, gear, cam, roller, guide or similar controlled contact;
- `FASTENER_PASSAGE` — screw/shaft/pin intentionally passes through a hole/slot;
- `CAPTURED/EMBEDDED` — one element intentionally occupies a designed pocket/recess;
- `BONDED/UNION` — bodies are intentionally treated as one structural body after assembly.

An unclassified body pair is not implicitly safe.

**Default rule:** if no explicit contract permits contact/overlap, physical solids must not intersect.

## 2. Check internal interference, not only moving-vs-fixed groups

Bodies that move together under the same operational transform can still collide with one another. Therefore motion QA must not stop at `moving assembly ↔ fixed assembly` checks.

Examples:

- a hand knob attached to a rotating payload can intersect the shaft that rotates with it;
- screw heads inside one moving carriage can hit neighboring carriage parts;
- two links in the same moving subassembly can self-intersect;
- an adjustment slider can be valid at its default position but collide elsewhere in its allowed travel.

For each accepted assembly state, QA must cover:

```text
all forbidden solid-pair intersections
+ all required clearances
+ all intended contact/fit exceptions explicitly classified
```

Intentional contacts must be excluded deliberately, never accidentally hidden by combining everything into one collision mesh.

## 3. Configuration space includes more than operational axes

The complete QA state space is the Cartesian product of all mechanically relevant state variables, not only motorized/continuous operating axes.

Classify state variables as:

- **operational DOF** — normal mechanism motion;
- **adjustment DOF** — balancing slots, telescopic settings, movable clamps, focus travel, tensioners;
- **configuration state** — removable guard installed/removed, alternate adapter, payload variant;
- **assembly/service DOF** — motion needed during insertion, removal, calibration or maintenance;
- **compliance/backlash state** — where physically meaningful and large enough to affect clearance.

Every variable gets a documented allowed range or discrete state set. Endpoints are mandatory. If exhaustive Cartesian sampling is too expensive, use justified critical combinations, adaptive refinement, conservative envelopes and/or swept-volume proofs and record the limitation.

## 4. A CAD trajectory is not a mechanism

A real rigid body in free space has six rigid-body degrees of freedom: three translations and three rotations.

For every installed body/subassembly, account for how physical geometry and attachments remove the unwanted DOFs.

A motion contract is incomplete unless it identifies the **constraint chain** that physically leaves only the intended DOF(s).

Examples:

```text
intended: 1 rotational DOF
constraints: shaft + two separated radial bearings + axial retention
remaining free DOF: rotation about shaft axis only
```

```text
intended: 1 linear DOF
constraints: rail/slot geometry constrains transverse translation and rotation
retention: carriage capture prevents lift-off
end limits: physical stops bound travel
remaining free DOF: translation along rail only
```

```text
intended: 0 DOF after tightening
constraints: locating faces/pins define position
fasteners: clamp the mating faces and resist separation
anti-rotation: geometry/fastener pattern resists torque
```

Do not accept a model that merely applies `translate()` or `rotate()` along a desired path without a realizable bearing, hinge, guide, rail, slot, linkage, flexure or other physical constraint that enforces that path.

## 5. Constraint / DOF register

For every major body or kinematic subassembly record a stable constraint ID and at least:

- body/subassembly;
- intended DOF count and type;
- axis/trajectory datum;
- constraint elements that remove each unwanted DOF;
- axial/radial/lateral retention;
- end stops or travel bounds;
- anti-rotation / anti-translation features;
- preload where required;
- load/reaction path into the structure;
- relevant fasteners;
- assembly state in which the constraint becomes active;
- physical verification still required.

A useful table is:

| Constraint ID | Body | Intended DOF | Physical constraint chain | Retention / limits | Load path | Status |
|---|---|---|---|---|---|---|

## 6. Underconstraint and overconstraint QA

Check both failure modes.

### Underconstraint

A body must not have unintended free translation/rotation that the design assumes away. Typical symptoms:

- one bearing used where two spaced supports are required;
- shaft can slide axially because no collar/shoulder exists;
- a motor/gearbox can rotate around a single fastener;
- a slider has nothing preventing lift-off or yaw;
- a payload is held only by friction where a positive locating feature is required.

### Overconstraint

Multiple constraints must not fight each other because of realistic manufacturing tolerances. Typical symptoms:

- two rigid bearing seats define incompatible axes;
- redundant guide rails require impossible perfect parallelism;
- axial clamping preloads a radial bearing unintentionally;
- a rigid four-point mount rocks because mating surfaces are not coplanar.

Where alignment depends on real tolerance, identify the physical adjustment/flexibility or calibration step.

## 7. Support and load-path requirement

Every structural element must have an understandable path for the loads it carries.

For each important load case identify:

```text
payload / gravity / drive torque / external force
→ local attachment
→ bearing / guide / fastener / structural member
→ parent structure
→ base / support
```

Check:

- radial and axial support;
- bending moment and support spacing;
- torque reaction / anti-rotation;
- fastener shear/tension/clamp role;
- bearing inner/outer-race load path;
- whether motors/gears are carrying structural load unintentionally;
- whether thin printed walls are being used as unsupported cantilever bearings/axles;
- whether removal of a service cover accidentally removes a required structural support.

CAD collision-free geometry does not prove sufficient stiffness or strength; uncertain load-bearing interfaces remain physical-analysis/test gates.

## 8. Fastener integrity requirement

Every fastened interface must specify enough information to prove that it can physically locate and retain the parts:

- fastener count and pattern;
- screw/pin diameter and intended load role;
- nut, thread, insert or tapped material;
- head/nut/washer envelope;
- thread engagement / usable length target;
- anti-rotation of captive nuts or single-bolt joints;
- insertion direction;
- tool access;
- tightening sequence/preload where relevant;
- clearance from moving bodies over all relevant states;
- disassembly/service path.

A fastener shown only as a hole center is not a complete mechanical interface.

## 9. State-space collision algorithm

For every relevant configuration state:

1. instantiate all physical solid bodies/envelopes;
2. apply the state transforms;
3. evaluate every `FORBIDDEN_OVERLAP` pair;
4. evaluate every `CLEARANCE` pair against its required minimum;
5. verify intended-contact/fit pairs remain in their allowed relationship;
6. verify the constraint chain remains assembled/coherent;
7. verify end-stop/retention conditions at limits;
8. refine sampling around minimum-clearance or transition states;
9. retain machine-readable evidence plus critical human-review poses.

Where possible, use pairwise collision meshes rather than one monolithic union so internal collisions cannot disappear inside a combined mesh.

## 10. Pass criteria

An assembly may be considered mechanically coherent only when:

1. every installed body has a defined support/constraint state;
2. intended DOFs are physically realizable and all unintended rigid-body DOFs are constrained;
3. all travel limits/retention mechanisms are defined;
4. relevant solid-body relationships are classified;
5. no forbidden solid intersection exists anywhere in the allowed operational/adjustment/configuration state space at the chosen proof resolution;
6. all specified minimum clearances are met;
7. load/reaction paths are understood;
8. fasteners/supports can be assembled, tightened, accessed and serviced;
9. tolerance-sensitive support/fit assumptions are explicitly pending physical verification where CAD cannot prove them;
10. the proof can be reproduced from repository-controlled source and QA tools.

## 11. Invalidation

Changing any of the following invalidates the affected mechanical-integrity checkpoint:

- solid envelope;
- mating/clearance classification;
- support location;
- bearing/guide/shaft datum;
- fastener pattern or hardware envelope;
- travel/adjustment range;
- retention or end-stop geometry;
- load path;
- assembly/service sequence;
- a parameter that changes any of the above.

Revalidate the smallest correct dependency scope, but re-run the complete affected state-space sweep rather than only the previously failing state.

## Compact invariant

```text
NO UNCLASSIFIED SOLID INTERSECTION
+
EVERY BODY HAS A REAL SUPPORT / LOAD PATH
+
INTENDED MOTION = ONLY DOF LEFT BY PHYSICAL CONSTRAINTS
+
FULL OPERATIONAL + ADJUSTMENT + CONFIGURATION STATE SPACE IS CHECKED
```
