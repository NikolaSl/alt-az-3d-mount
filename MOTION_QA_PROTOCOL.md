# Motion QA Protocol for Parametric Mechanical Designs

This document is intentionally **project-agnostic**. It defines the mandatory QA procedure for any parametric mechanical design containing moving parts. It is meant to be reused in future CAD/OpenSCAD projects together with `DESIGN_PROTOCOL.md`.

## Core rule

A mechanism with moving parts is not motion-QA-passed because it looks correct in one neutral pose or in a few attractive screenshots.

> Every degree of freedom must be validated over its complete intended motion envelope, including both end limits, intermediate configurations, known worst-case configurations and coupled positions with other moving axes.

Because a continuous motion contains infinitely many configurations, practical QA combines exact limit checks, adaptive sampled sweeps, swept-volume reasoning and explicit collision/clearance assertions.

## 1. Define a motion contract before testing

For every degree of freedom record:

- motion ID;
- moving assembly;
- fixed/reference assembly;
- axis/datum;
- minimum allowed position;
- maximum allowed position;
- periodic/wrap behavior, if any;
- normal operating range versus hard/physical limit;
- required minimum clearances;
- known collision-sensitive interfaces;
- cable, hose, belt, wire or flexible-element constraints;
- whether motion is independent or coupled with other axes.

Examples:

```text
M-ALT
rotational
axis = payload shaft
range = -20° .. +90°
minimum structural clearance = 1.5 mm
critical neighbors = yoke arms, gearbox, cover
```

```text
M-SLIDE-X
linear
range = 0 .. 120 mm
minimum structural clearance = 1.0 mm
critical neighbors = frame, cable chain, end-stop bracket
```

Motion limits and axis datums should be owned by shared parameters/interface contracts, not copied as unrelated constants into QA scripts.

## 2. Mandatory configurations

Every motion QA must explicitly inspect at least:

```text
minimum limit
maximum limit
neutral/reference position
all known kinematic transition points
all known worst-case collision positions
all positions where a moving part becomes tangent/closest to a neighbor
all positions where cables/hoses reach maximum bend, twist or extension
```

End points are mandatory. They must never be omitted simply because the mechanism is expected to operate mostly near its center position.

## 3. Sample the complete range, not only named poses

Named poses are human-review checkpoints, not a substitute for a sweep.

For each one-dimensional motion, run an automated or repeatable sweep from minimum to maximum using an interval small enough that a narrow collision cannot plausibly occur between samples.

The interval is adaptive:

- coarse sampling is acceptable where clearances are large and geometry changes slowly;
- use denser sampling near close clearances, contact transitions, over-center positions, singularities or complicated geometry;
- if a collision boundary is detected, refine the interval around it until the transition is understood;
- if the mechanism has a very small clearance relative to the local motion per step, reduce the step size.

A useful initial engineering default for ordinary rotational mechanisms is often 2–5° and for ordinary linear mechanisms 0.5–2 mm, but these are **not universal acceptance limits**. The required resolution is determined by geometry and minimum clearance.

## 4. Collision and clearance checks at every sampled state

At each sampled configuration check, where applicable:

- moving part ↔ fixed structure collision;
- moving part ↔ other moving part collision;
- self-intersection of the moving assembly;
- required minimum clearance;
- fastener/head/nut/washer clearance;
- bearing/shaft axial and radial relationship;
- gear/belt/chain alignment;
- cover/guard clearance;
- tool/service clearance when movement is required for service;
- cable/hose bend radius, twist and extension;
- connector strain and cable-entry clearance;
- hard-stop engagement and overtravel margin;
- payload envelope clearance;
- counterweight clearance;
- gravity-sensitive interference or support loss;
- any interface-specific invariant defined in the project.

If the CAD backend permits it, encode critical invariants as executable assertions rather than relying only on screenshots.

## 5. Swept-volume QA

When geometry permits, also reason about the complete **swept volume** of each moving body.

The swept volume is the union/envelope occupied by the body over the allowed motion range. No fixed component that is not intended to contact the moving part may intrude into that envelope, after applying the required safety clearance.

Swept-volume analysis is especially valuable for:

- rotating arms;
- payload plates;
- covers near gears;
- counterweights;
- linkages;
- robotic joints;
- cable carriers;
- folding structures.

Sampling and swept-volume analysis complement each other: sampling gives inspectable configurations, while the swept envelope reduces the chance of missing a narrow intermediate conflict.

## 6. Multiple degrees of freedom

For mechanisms with two or more moving axes, testing every axis independently is insufficient.

At minimum check:

- all corners of the allowed configuration space;
- each axis at both limits while the other axes are at representative/critical positions;
- coupled trajectories used during normal operation;
- known worst-case combinations;
- singular/near-singular configurations where applicable.

For two rotational axes this may conceptually mean checking combinations such as:

```text
AZ min / ALT min
AZ min / ALT max
AZ max / ALT min
AZ max / ALT max
+ representative intermediate combinations
+ actual operating trajectories
```

For periodic axes such as continuous 360° azimuth, sample the full revolution and include the wrap transition.

If exhaustive Cartesian sampling would be prohibitively expensive, use adaptive sampling, critical configuration sets and swept-volume checks, and document what was not exhaustively tested.

## 7. Visual evidence

For human review, retain or regenerate evidence from:

- both end limits;
- neutral/reference position;
- representative intermediate positions;
- closest-clearance positions;
- any configuration that triggered refinement during automated sweep;
- cutaway/transparent-cover views when internal motion is hidden;
- section views through critical moving interfaces when useful.

A contact sheet or browser-selectable set of motion poses should make it possible to review the mechanism without opening the desktop CAD tool.

## 8. Pass criteria

A moving mechanism may be marked `MOTION_QA_PASS` only when:

1. its motion contract is defined;
2. both end limits were checked;
3. the full allowed range was swept with a justified sampling strategy;
4. critical multi-axis combinations were checked where relevant;
5. no unintended collision was found;
6. required clearances remain satisfied throughout the motion envelope;
7. cables/flexible elements remain valid throughout the range, if present;
8. hard stops and overtravel behavior are understood where relevant;
9. moving interfaces remain mechanically coherent throughout the range;
10. the evidence and procedure are repeatable from repository-controlled source/tools.

## 9. Failure and backtracking

If any sampled or critical position fails:

1. record the failing motion ID and configuration;
2. identify the interface/parameter that owns the conflict;
3. backtrack to the nearest upstream design decision that can resolve it;
4. mark affected parts/interfaces `NEEDS_REVALIDATION`;
5. revise geometry/parameters;
6. repeat per-part QA for changed parts;
7. repeat the complete motion sweep, not only the previously failing pose;
8. repeat downstream assembly QA affected by the change.

A local fix is not accepted if it creates a new conflict elsewhere in the allowed motion range.

## 10. Invalidation rule

Any geometry or parameter change that can alter a moving body's shape, axis, limit, neighboring clearance, payload envelope, cable path or support relationship invalidates the relevant motion QA.

The motion sweep must be re-run after such a change before the assembly returns to trusted status.

## Compact rule

```text
DEFINE MOTION CONTRACT
        ↓
CHECK BOTH END LIMITS
        ↓
SWEEP COMPLETE RANGE
        ↓
REFINE NEAR CRITICAL CLEARANCES
        ↓
CHECK SWEPT VOLUME / COLLISIONS
        ↓
CHECK COUPLED MULTI-AXIS STATES
        ↓
HUMAN REVIEW OF CRITICAL POSES
        ↓
PASS
```

The intent is to prove that a mechanism remains geometrically and mechanically coherent **throughout its usable motion**, not merely at the pose in which it was designed.
