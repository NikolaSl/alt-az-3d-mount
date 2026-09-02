# Parametric Mechanical Design Protocol

This document is intentionally **project-agnostic**. It defines the workflow to use for complex parametric 3D mechanical devices, independent of the concrete machine, CAD backend, motors, bearings, or payload. It should be copied into future mechanical-design repositories and treated as a process contract for both human and AI contributors.

The core idea is simple:

> Never generate a complex machine as one opaque model. First decompose it into elementary printable/mechanical parts, define how those parts interact, establish one shared parameter system, then generate and validate the parts incrementally in dependency order. Every new part is designed in the context of the whole machine and the already validated neighboring parts. If the next part cannot be made compatible, backtrack to the nearest upstream blocking decision, correct it, propagate the change, and re-run QA on everything affected.

## 1. Persistent project state

At every point in the project, the repository must preserve enough state that work can resume without relying on chat history or human memory.

Required state:

1. **Machine specification** — purpose, loads, motion ranges, physical constraints, materials, manufacturing process, fasteners, external interfaces and safety constraints.
2. **Part decomposition** — complete planned list of elementary parts, before detailed geometry is created.
3. **Interaction/interface graph** — which parts touch, constrain, drive, support, fasten to, rotate around, slide against or otherwise depend on which other parts.
4. **Shared parameter block** — global dimensions, hardware dimensions, fits, clearances, tolerances, motion envelopes and derived values used by multiple parts.
5. **Dependency/build order** — a directed acyclic graph where possible, defining which parts must exist before another part can be designed correctly.
6. **Part status ledger** — planned / interface-defined / modeled / QA-passed / integrated / blocked / requires-human-review.
7. **Current assembly model** — the best-known machine assembled from all validated parts available so far.
8. **QA rules and tools** — repeatable commands/scripts that regenerate the visual and geometric checks.

The OpenSCAD source and shared parameters are the design source of truth. Rendered PNG/STL QA artifacts are derived evidence, not the authoritative geometry.

## 2. Phase A — machine planning without detailed part design

Before creating detailed geometry:

### A1. Define the machine envelope and requirements

Record at least:

- intended function;
- maximum loads and moments;
- required axes and motion ranges;
- overall size/weight limits;
- mounting interfaces;
- hardware that is fixed in advance;
- printing/material assumptions;
- serviceability requirements;
- acceptable backlash, clearance and fit assumptions;
- cable/fastener/tool access constraints.

### A2. Decompose the machine into elementary parts

Create the full initial part list **without designing the individual parts yet**.

Each item should have:

- name and responsibility;
- whether it is printed, purchased or fabricated;
- what it supports or drives;
- neighboring parts;
- important interfaces;
- expected degrees of freedom.

The goal is not to predict every final detail. The goal is to have a complete enough machine plan that local part design is never done blindly.

### A3. Define interactions before geometry

For every neighboring pair, describe the interface semantically before modeling it.

Examples:

- fixed by four M3 screws;
- Ø8 shaft passes through two 608 bearings;
- gear A drives gear B at 4:1;
- payload plate rotates about ALT axis;
- cover must clear the gear envelope by at least 1.0 mm;
- removable part needs screwdriver access from the outside;
- cable must cross a joint without entering the swept volume.

This creates the **interaction graph** of the machine.

## 3. Phase B — shared parameter architecture

Create one common parametric block before detailed part generation.

Shared values should not be copied as unrelated magic numbers into individual parts.

Typical groups:

```text
machine envelope
payload/load assumptions
standard hardware dimensions
bearing/shaft dimensions
motor dimensions
gear parameters
wall/rib thicknesses
printer fit allowances
sliding/rotating clearances
fastener holes and captive-nut dimensions
axis locations
interface datums
motion limits
service/tool clearances
```

Prefer derived parameters over duplicated values. For example:

```text
ALT_AXIS_Z = BASE_H + AZ_STAGE_H + YOKE_AXIS_OFFSET
YOKE_OUTER_W = YOKE_INNER_W + 2 * YOKE_ARM_T
BEARING_SEAT_D = BEARING_OD + BEARING_FIT_DELTA
```

### Parameter ownership

Every dimension shared by two or more parts should have one clear owner:

- global parameter;
- hardware model parameter; or
- interface parameter.

A part may derive local geometry from that value, but should not independently redefine the same interface dimension.

## 4. Phase C — determine the generation order

Do not simply model parts in visual or alphabetical order. Build them in **dependency order**.

Start with parts that establish datums and interfaces used by many later parts, then proceed outward.

Typical order:

```text
reference/base geometry
→ primary axes/bearing supports
→ moving platforms
→ structural supports
→ drive interfaces
→ motor/gear mounts
→ covers/guards
→ cable management
→ optional accessories
```

Before starting part N, identify:

- the global parameters it depends on;
- already validated neighboring parts;
- interfaces it must satisfy;
- swept/motion volumes it must avoid;
- later parts that will depend on it.

## 5. Phase D — incremental part design

Design **one elementary part at a time**.

A new part is never designed in isolation. Its design context consists of:

```text
machine specification
+ complete part plan
+ interaction graph
+ shared parameters
+ already validated neighboring geometry
+ known future interfaces
```

During part design:

1. Import/use the shared parameters.
2. Use neighboring validated parts or simplified interface envelopes as context.
3. Position geometry from shared datums, not ad-hoc visual alignment.
4. Encode important clearances and invariants as `assert()` checks where practical.
5. Keep manufacturability, assembly order and tool access visible in the model.
6. Avoid changing an already validated interface casually; such a change is a dependency change and must trigger backtracking/revalidation.

## 6. Per-part QA loop

Every elementary part passes QA before it becomes a trusted dependency for the next part.

### Q1. Compile/render QA

For OpenSCAD:

- full CGAL render for individual printable parts;
- hard warnings enabled;
- no unexpected warnings/errors;
- exported STL is valid;
- `Simple: yes` where applicable;
- watertight/manifold mesh;
- expected connected-component count.

### Q2. Standard visual inspection set

Generate at minimum:

- isometric view;
- top;
- bottom;
- front;
- back;
- left;
- right.

Do not rely on one attractive isometric screenshot.

### Q3. Section inspection

Generate useful cuts through the part:

- center X section;
- center Y section;
- center Z section when meaningful;
- offset X/Y/Z sections through critical interfaces;
- isometric cutaway where internal geometry is difficult to understand orthographically;
- local detail views for bearing seats, nut traps, screw channels, shafts, gears, clips and thin walls.

The section set is **adaptive**: the standard center cuts are the minimum, not the maximum.

### Q4. Context QA

Render the new part together with every directly interacting already validated neighbor.

Inspect:

- collisions;
- unintended gaps;
- correct alignment of axes and holes;
- bearing/shaft engagement;
- gear mesh and axial alignment;
- fastener length/path;
- assembly feasibility;
- screwdriver/wrench access;
- removal/service path;
- minimum wall thickness around holes and pockets;
- expected contact surfaces;
- cable path where relevant.

### Q5. Motion QA

For moving interfaces, sample multiple meaningful states, not only the neutral pose.

At minimum consider:

```text
minimum limit
neutral/reference position
one or more intermediate positions
maximum limit
known worst-case collision positions
```

Covers should also be inspected removed/transparent when they hide drive relationships.

### Q6. QA evidence

A repeatable QA tool should output a contact sheet and machine-readable report containing the generated views, sections and geometric checks. QA artifacts may be disposable, but the command/script that regenerates them must be version controlled.

## 7. Integration gate after every accepted part

Once a part passes individual QA:

1. add it to the current assembly;
2. render the current partial machine;
3. check all interfaces touched by the new part;
4. run relevant collision/clearance assertions;
5. update the part status ledger;
6. only then allow downstream parts to depend on it.

This means the project always has a coherent **best-known partial machine**, not a directory of unrelated finished-looking parts.

## 8. Controlled recursive backtracking

Failure to design the next part is not a reason to force geometry around a bad earlier decision.

When no clean solution exists:

1. identify the blocking constraint;
2. trace which upstream part/interface/parameter owns it;
3. find the **nearest upstream design decision** that can be changed without unnecessarily invalidating the whole machine;
4. mark all dependent downstream parts as needing revalidation;
5. modify the upstream design or shared parameter;
6. re-run that part's QA;
7. re-run QA for affected descendants in dependency order;
8. resume forward design only after the partial assembly is coherent again.

Conceptually:

```text
PLAN
  ↓
PARAMETERS / INTERFACES
  ↓
PART A → QA → integrate
  ↓
PART B → QA → integrate
  ↓
PART C ── blocked ──┐
  ↑                 │
  └─ revise B/A/interface
       → QA affected chain
       → continue forward
```

Backtracking should be **minimal but complete**: change the smallest upstream scope that resolves the problem, but revalidate every dependency affected by that change.

## 9. Human review gates

Automation must never make the design opaque to the human operator.

A human-review checkpoint is recommended:

- after initial decomposition;
- after the global parameter/interface architecture is established;
- after every major subsystem becomes coherent;
- before changing a validated upstream interface with many dependents;
- after a large recursive backtrack;
- before committing to a long/expensive print;
- before the final production assembly.

At each checkpoint provide a compact review package:

- current assembly render;
- exploded or cutaway view where useful;
- key dimensions and parameters;
- current part/status table;
- unresolved assumptions;
- known risks;
- proposed next part or next subsystem.

The human must be able to stop, inspect, redirect or override the next design step.

## 10. Suggested part state machine

```text
PLANNED
  ↓
INTERFACES_DEFINED
  ↓
READY_TO_MODEL
  ↓
MODELED
  ↓
PART_QA_PASS
  ↓
INTEGRATED
  ↓
ASSEMBLY_QA_PASS
  ↓
TRUSTED_DEPENDENCY
```

Exceptional states:

```text
BLOCKED
NEEDS_BACKTRACK
NEEDS_REVALIDATION
HUMAN_REVIEW
PHYSICAL_FIT_TEST_REQUIRED
```

A part in `MODELED` is not yet a valid dependency. Downstream modeling should use only geometry whose relevant interface is QA-passed, unless the dependency is explicitly marked provisional.

## 11. Physical-world validation

Visual/geometric QA cannot prove printer fit, material stiffness, motor torque, backlash or assembly feel.

Before a full production print, identify interfaces that need physical coupons or prototypes, for example:

- shaft/bearing fits;
- press fits;
- captive nuts/inserts;
- motor shaft couplers;
- printed gears;
- screw clearances;
- snap fits;
- friction surfaces;
- structural flex under load.

Feed measured results back into the shared parameter block, then regenerate/re-QA affected parts.

## 12. Repository pattern for future projects

A useful generic structure is:

```text
README.md
DESIGN_PROTOCOL.md              this process
REQUIREMENTS.md                 machine requirements and constraints
PARTS.md                        decomposition + status ledger
INTERFACES.md                   interaction graph / interface contracts
ASSEMBLY.md                     BOM + assembly sequence
src/
  config.scad                   common parameters
  lib/                          reusable primitives
  parts/                        elementary printable parts
  assemblies/                   partial/full assemblies
  envelopes/                    purchased-part and motion envelopes
tools/
  visual_qa.py                  repeatable QA automation
build/qa/                       generated, normally ignored
docs/                           subsystem notes and decisions
```

For larger projects, `PARTS.md` can become structured JSON/YAML so tooling can automatically determine dependency order and invalidation after backtracking.

## 13. Compact algorithm

```text
1. Specify machine.
2. Decompose whole machine into elementary parts; do not detail them yet.
3. Describe interactions/interfaces.
4. Create shared parameter architecture.
5. Build dependency order.
6. Select next ready elementary part.
7. Design it using global parameters + validated neighbors + future interface constraints.
8. Compile and run geometric/visual/section/context/motion QA.
9. If QA fails: revise same part and repeat.
10. If the part cannot satisfy its interfaces cleanly:
      backtrack to nearest blocking upstream decision,
      modify it,
      invalidate affected descendants,
      re-QA them in dependency order.
11. If QA passes: integrate into current assembly and run assembly QA.
12. At major gates, stop for human review.
13. Repeat 6–12 until the complete machine is coherent.
14. Run physical fit tests, feed measurements into parameters, and regenerate as needed.
15. Only then produce the full production print/build.
```

## 14. Design principle

The quality of this workflow does not come from expecting a CAD generator to understand the whole machine correctly in one attempt. It comes from maintaining a persistent global plan while reducing each modeling step to a small, inspectable problem with explicit neighboring constraints and a strong feedback loop.

The combination is:

**global planning + shared parameters + local incremental generation + visual/geometric QA + continuous assembly integration + controlled backtracking + human review.**
