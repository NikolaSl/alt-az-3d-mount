# Motion QA Protocol for Parametric Mechanical Designs

This document is intentionally **project-agnostic**. It defines the mandatory QA procedure for any parametric mechanical design containing moving or adjustable parts. Use it together with `DESIGN_PROTOCOL.md` and `MECHANICAL_INTEGRITY_PROTOCOL.md`.

## Core rule

A mechanism is not motion-QA-passed because it looks correct in one neutral pose or a few screenshots.

> Every mechanically relevant state variable must be validated over its complete intended range/state set, including both limits, intermediate configurations, known worst cases and relevant coupled combinations.

This includes not only motorized operational axes but also balancing slots, telescopic adjustments, movable clamps, removable configurations and service motions that can change solid-body relationships.

A continuous configuration space contains infinitely many states, so practical QA combines exact limit checks, adaptive sampled sweeps, pairwise collision/distance checks, swept-volume reasoning, symmetry/analytic proofs where justified, and explicit assertions.

## 1. Define motion and adjustment contracts before testing

For every operational or adjustment degree of freedom record:

- stable motion/state ID;
- moving body/assembly;
- fixed/reference bodies;
- **physical constraint chain that actually enforces the trajectory**;
- axis/path datum;
- minimum and maximum allowed position or discrete state set;
- periodic/wrap behavior, if any;
- normal operating range versus hard/physical limit;
- required minimum clearances;
- collision-sensitive interfaces;
- cable/hose/flexible-element constraints;
- whether the variable is operational, adjustment, configuration or service;
- coupling with other state variables;
- retention/end-stop behavior.

A CAD `translate()` or `rotate()` is not a physical motion constraint. The corresponding bearing, shaft, hinge, guide, rail, slot, linkage, flexure or other constraint must be identified as required by `MECHANICAL_INTEGRITY_PROTOCOL.md`.

Motion limits and axis datums belong to shared parameters/interface contracts, not duplicated QA constants.

## 2. Complete configuration space

The QA state space is the combination of all mechanically relevant state variables:

```text
operational DOFs
× adjustment DOFs
× discrete configurations
× relevant service/assembly states
```

Examples of adjustment/configuration variables that must not be ignored:

- payload screw moving through a balancing slot;
- telescopic length;
- counterweight position;
- movable clamp position;
- focus travel;
- belt/chain tensioner position;
- guard installed/removed when removal changes support or clearance;
- alternate adapter/payload geometry.

If exhaustive Cartesian sampling is too costly, use documented critical combinations, conservative envelopes, adaptive refinement and swept-volume proofs. Never silently assume an adjustment remains safe because it shares the same operational transform as another body.

## 3. Mandatory states

Every state variable must explicitly inspect at least:

```text
minimum limit
maximum limit
neutral/reference position
all known kinematic transition points
all known worst-case collision positions
all closest-clearance/tangent positions
all hard-stop/retention states
all maximum cable bend/twist/extension states
```

Endpoints are mandatory.

## 4. Sample the complete range, not only named poses

Named poses are human-review checkpoints, not a substitute for a sweep.

For each one-dimensional variable, run an automated/repeatable sweep from minimum to maximum using a resolution small enough that a narrow conflict cannot plausibly hide between samples.

Sampling is adaptive:

- coarse where geometry varies slowly and clearances are large;
- denser near small clearances, contacts, singularities, over-center states or complex geometry;
- refine around any collision/clearance boundary until understood;
- reduce step if local movement per sample is large relative to required clearance.

Typical starting points such as 2–5° rotational or 0.5–2 mm linear are engineering conveniences, not universal pass limits.

## 5. Pairwise solid collision and clearance checks

At each sampled configuration instantiate the relevant physical solid bodies/envelopes and apply the relationship classification from `MECHANICAL_INTEGRITY_PROTOCOL.md`.

Check:

- every `FORBIDDEN_OVERLAP` pair for collision;
- every `CLEARANCE` pair for required minimum distance;
- intended contact/fit/fastener-passage pairs for their allowed relationship;
- moving ↔ fixed collisions;
- moving ↔ moving collisions;
- **internal collisions among bodies sharing the same motion transform**;
- self-intersection of linkages/subassemblies;
- fastener/head/nut/washer clearance;
- bearing/shaft axial and radial coherence;
- gear/belt/chain alignment;
- cover/guard clearance;
- tool/service clearance where movement is needed for service;
- cable/hose bend radius, twist and extension;
- connector strain and cable-entry clearance;
- hard-stop engagement and overtravel margin;
- payload/counterweight envelope clearance;
- gravity-sensitive interference or support loss;
- every interface-specific invariant.

Do not hide internal collisions by unioning all bodies of a moving subassembly into one collision mesh. Intentional contacts must be explicitly excluded/classified; all other physical solid overlap is forbidden.

Encode critical invariants as executable assertions where practical.

## 6. Constraint coherence at every state

Collision-free geometry is necessary but not sufficient. At every relevant state verify that the physical guide/support chain still leaves only the intended DOF(s):

- bearings remain seated and coaxial;
- shafts remain radially/axially retained as designed;
- sliders remain captured by their guide/slot/rail;
- hinges/pivots remain supported on the intended axis;
- fasteners/locators prevent unintended rotation/translation;
- end stops/retainers actually bound the documented travel;
- no service/configuration state removes a support that the motion model still assumes exists.

Underconstraint and overconstraint are both failures; see `MECHANICAL_INTEGRITY_PROTOCOL.md`.

## 7. Swept-volume QA

When geometry permits, supplement sampling with the swept volume occupied by each moving/adjusting solid over its allowed range. No non-contact body may intrude into the clearance-expanded swept volume.

This is especially valuable for rotating arms, payload plates, knobs/handles, counterweights, covers near gears, linkages, robotic joints, cable carriers and folding structures.

Sampling and swept-volume analysis complement each other.

## 8. Multiple variables / coupled states

Testing each axis independently is insufficient. At minimum check:

- corners of allowed configuration space;
- each axis/adjustment at both limits while other variables are at representative/critical states;
- normal coupled trajectories;
- known worst-case combinations;
- singular/near-singular configurations;
- periodic wrap transitions;
- adjustment extremes combined with operational motion when geometry can interact.

If exhaustive Cartesian sampling is prohibitively expensive, document the proof strategy and what is not exhaustive.

## 9. Visual evidence

For human review retain/regenerate:

- both end limits;
- reference state;
- representative intermediate states;
- closest-clearance states;
- adjustment extremes;
- any refined failure boundary;
- cutaway/transparent views where motion is hidden;
- section views through critical moving interfaces;
- configuration combinations that are not visually obvious.

A contact sheet or browser-selectable set of poses/states should allow review without desktop CAD.

## 10. Pass criteria

A mechanism may be marked `MOTION_QA_PASS` only when:

1. operational and adjustment/configuration contracts are defined;
2. the physical constraint chain for each intended DOF is defined;
3. all endpoints are checked;
4. complete affected ranges are swept with justified resolution;
5. critical coupled combinations are checked;
6. no forbidden solid intersection exists at the chosen proof level;
7. required clearances remain satisfied;
8. internal same-transform solid pairs have not been omitted;
9. flexible elements remain valid where present;
10. hard stops/retention/overtravel are understood;
11. supports/guides remain mechanically coherent throughout the states;
12. limitations of the proof are explicit;
13. evidence/procedure are reproducible from repository-controlled source/tools.

## 11. Failure and backtracking

If any state fails:

1. record the failing motion/state ID and configuration;
2. identify the interface/constraint/parameter that owns the conflict;
3. backtrack to the nearest upstream decision that can resolve it;
4. mark affected parts/interfaces/constraint contracts `NEEDS_REVALIDATION`;
5. revise geometry/parameters/support strategy;
6. repeat per-part QA for changed parts;
7. repeat the **complete affected state-space sweep**, not only the failing pose;
8. repeat downstream assembly/constraint QA.

A local fix is not accepted if it creates a conflict elsewhere.

## 12. Invalidation rule

Any change that can alter a solid envelope, axis/path, support/constraint chain, motion/adjustment limit, neighboring clearance, payload envelope, cable path, fastener envelope, retention/end-stop, or assembly/service state invalidates the relevant motion checkpoint.

## Compact rule

```text
DEFINE REAL PHYSICAL DOFs + CONSTRAINT CHAINS
        ↓
DEFINE ALL OPERATIONAL / ADJUSTMENT / CONFIGURATION STATES
        ↓
CLASSIFY SOLID-BODY RELATIONSHIPS
        ↓
CHECK END LIMITS
        ↓
SWEEP COMPLETE RANGES
        ↓
PAIRWISE COLLISION + CLEARANCE CHECKS
        ↓
REFINE CRITICAL REGIONS / SWEPT VOLUMES
        ↓
CHECK COUPLED STATE SPACE
        ↓
VERIFY SUPPORT / RETENTION COHERENCE
        ↓
HUMAN REVIEW OF CRITICAL STATES
        ↓
PASS
```

The intent is to prove that the physical mechanism remains geometrically and mechanically coherent throughout every allowed usable and adjustment state, not merely that the CAD can be animated along a desired path.
