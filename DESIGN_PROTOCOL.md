# Parametric Mechanical Design Protocol

This protocol is project-agnostic. It is the default workflow for complex parametric mechanical devices.

## Core principle

Never generate a complex machine as one opaque model. First decompose it into elementary parts, define their interactions and physical constraints, establish one shared parameter system, then generate and validate parts incrementally in dependency order. Every new part is designed in the context of the whole machine and the already validated neighbors. If the next part cannot be made compatible, backtrack to the nearest upstream blocking decision, correct it, invalidate affected descendants and re-run QA.

A desired CAD animation is not enough: the physical design must contain bearings, shafts, guides, rails, slots, hinges, linkages, fasteners or other constraint elements that make the intended motion the only available motion. See `MECHANICAL_INTEGRITY_PROTOCOL.md`.

## A. Plan the machine before detailed geometry

### A1. Requirements

Record intended function, loads/moments, motion and adjustment ranges, size/weight limits, mounting interfaces, fixed purchased hardware, material/manufacturing assumptions, serviceability, backlash/fit requirements, cable paths, safety constraints and tool access.

Also identify important load cases and where reaction loads are expected to flow into the structure.

### A2. Complete part decomposition

Create the initial complete list of elementary parts **before designing them in detail**. For each part record:

- stable ID and responsibility;
- printed / purchased / fabricated;
- what it supports or drives;
- neighbors and important interfaces;
- intended rigid-body DOFs;
- what physically constrains the unwanted DOFs;
- dependencies;
- current status.

### A3. Interaction and solid-relationship graph before geometry

For every neighboring or potentially interfering pair define the interface semantically, e.g. fixed with 4×M3, Ø8 shaft through two 608 bearings, gear mesh 4:1, removable cover with ≥1 mm clearance, tool access from +Y, cable must avoid swept volume.

Classify relevant physical body pairs using `MECHANICAL_INTEGRITY_PROTOCOL.md`: `FORBIDDEN_OVERLAP`, `CLEARANCE`, `INTENDED_CONTACT`, `MATING_FIT`, `KINEMATIC_CONTACT`, `FASTENER_PASSAGE`, `CAPTURED/EMBEDDED`, or `BONDED/UNION`.

Store contracts in `INTERFACES.md` with stable IDs. Unclassified physical overlap is not accepted by default.

### A4. Constraint / DOF register

For each major installed body or moving subassembly record:

- intended DOF count/type;
- physical constraint chain;
- retention/end limits;
- load/reaction path;
- fasteners/supports;
- physical verification still required.

A free rigid body starts with six DOFs. The design must account for how all unintended translations/rotations are removed without impossible overconstraint.

## B. Shared parameter architecture

Create `src/config.scad` before detailed part generation. Shared dimensions must have one owner and must not be copied as unrelated magic numbers.

Typical parameter families include machine/payload envelope, purchased hardware, bearings/shafts/motors, walls/ribs, printer fits, sliding/rotating clearances, fastener envelopes, axis/interface datums, operational/adjustment limits, retention/end stops and service/tool clearances.

Prefer derived values over duplication. When a clearance is functionally required, derive dependent geometry from that target where practical rather than relying on accidental spacing.

## C. Dependency/build order

Model in dependency order, not visual/alphabetical order. Start with reference geometry and high-fanout datums, then move outward.

Typical order:

```text
reference/base
→ support/load paths
→ axes/bearing/guide constraints
→ moving platforms
→ structural supports
→ drive interfaces
→ motor/gear mounts
→ retention/end stops
→ covers/guards
→ cable management
→ accessories
```

Before part N, identify global parameters, validated neighbors, required interfaces, solid relationships, constraint/load path, swept volumes to avoid and later dependents.

## D. One elementary part at a time

Design context is always:

```text
requirements
+ complete part plan
+ interface / solid-relationship graph
+ constraint / DOF register
+ shared parameters
+ validated neighboring geometry
+ known future interfaces
```

Rules:

1. Use common parameters/datums.
2. Render validated neighbors or simplified envelopes in context.
3. Encode important invariants with `assert()` where practical.
4. Consider manufacturability, print orientation, assembly order and tool access.
5. Include real fastener heads/nuts/shafts/bearings or conservative envelopes where they can interfere.
6. Do not casually redefine a validated upstream interface.
7. Do not model a desired trajectory unless real geometry constrains the body to that trajectory.
8. Check support spacing/load paths so motors/gears/thin walls do not unintentionally carry structural loads.

## E. Per-part QA

A part becomes a trusted dependency only after:

- full render/export;
- mesh validity/manifold/watertight checks;
- all standard orthographic/isometric views;
- X/Y/Z and critical offset sections;
- neighboring-part context;
- fastener/assembly/service checks;
- solid-pair collision/clearance checks;
- support/constraint/load-path review;
- motion/adjustment checks where relevant.

For moving/adjustable geometry, follow `MOTION_QA_PROTOCOL.md`. Bodies that share the same operational transform still require internal interference checks.

## F. Integration gate

After a part passes individual QA:

1. add it to the best-known partial/full assembly;
2. inspect touched interfaces and newly relevant solid pairs;
3. verify support/constraint state and load path;
4. verify fastener insertion, head/nut/tool envelopes and retention;
5. run relevant clearance/assertion checks;
6. run motion/adjustment state-space QA if any envelope/range/constraint changed;
7. update status ledger, interfaces, constraint register, assembly/BOM and project state;
8. only then allow downstream geometry to depend on it.

## G. Controlled recursive backtracking

When the next part has no clean solution:

1. name the blocking interface/constraint/body-pair relation;
2. identify its nearest upstream owner;
3. change the smallest upstream decision that resolves the problem;
4. mark every affected dependent part/interface/constraint `NEEDS_REVALIDATION`;
5. re-QA the changed owner;
6. propagate QA outward in dependency order;
7. repeat complete affected motion/adjustment sweeps;
8. resume forward design only after the partial assembly is coherent.

Backtracking is **minimal in scope, complete in validation**.

## H. Human-in-the-loop

Automation must remain inspectable. Human review is mandatory at major subsystem boundaries, before expensive prints, after major backtracking and before changing a high-fanout interface/constraint.

## I. Physical feedback loop

CAD cannot prove printer fit, material stiffness, torque, backlash, preload, bearing alignment under tolerance or assembly feel. Identify physical coupons/prototypes for fits, bearings/shafts, nut traps/inserts, couplers/gears, snap fits, friction surfaces and loaded structures. Record raw measurements in `CALIBRATION.md`, then modify shared parameters and invalidate/re-QA affected dependencies.

## Suggested part state machine

```text
PLANNED
→ INTERFACES_DEFINED
→ CONSTRAINTS_DEFINED
→ READY_TO_MODEL
→ MODELED
→ PART_QA_PASS
→ INTEGRATED_CAD
→ ASSEMBLY_QA_PASS
→ TRUSTED_DEPENDENCY
→ PHYSICAL_VERIFY
→ FROZEN
```

Exceptional states: `BLOCKED`, `NEEDS_BACKTRACK`, `NEEDS_REVALIDATION`, `HUMAN_REVIEW`, `PHYSICAL_FIT_TEST_REQUIRED`.

## Compact algorithm

```text
1 Specify machine and load cases.
2 Decompose entire machine without detailed geometry.
3 Define interface + solid-relationship graph.
4 Define constraint/DOF + load-path register.
5 Create shared parameter architecture.
6 Determine dependency order.
7 Select next ready elementary part.
8 Design from global parameters + validated neighbors + real constraints.
9 Run geometric/visual/section/context/solid-pair/constraint/motion QA.
10 If local QA fails, revise same part and repeat.
11 If interfaces/constraints cannot be satisfied, backtrack to nearest blocking owner.
12 Invalidate and re-QA affected descendants and complete state-space sweeps.
13 Integrate accepted part into current assembly and update BOM/state/contracts.
14 Stop for human review at major gates.
15 Repeat until machine is coherent.
16 Run physical fit/load/motion tests and feed results back into parameters.
17 Freeze production geometry/BOM only after required physical verification.
```
