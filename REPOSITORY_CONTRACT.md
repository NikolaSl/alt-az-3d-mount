# Repository Contract — persistent memory, mechanical integrity and mobile review

This file is a **mandatory process contract** for this project. The repository is the persistent engineering memory; chat history is disposable working context.

## 1. Repository-first continuity

No decision required to continue engineering work may exist only in chat. Before a logical design step is accepted, commit enough information that a completely fresh human/AI session can reconstruct the design and continue safely.

The repository must preserve, as applicable:

- machine requirements and load cases;
- complete planned part decomposition;
- interface contracts and stable IDs;
- physical solid-body relationship classifications;
- physical constraint/DOF and support/load-path contracts;
- shared parameters, datums, fits and derived dimensions;
- dependency/build order and part status;
- current partial/full assembly;
- OpenSCAD source for parts, hardware envelopes and assemblies;
- visual/geometric/mechanical-integrity/motion QA procedures and accepted evidence;
- unresolved HOLD/VERIFY items and reasons;
- live printable list, purchased/fabricated BOM, tools and consumables;
- physical calibration/fit state;
- exact assembly/service sequence;
- browser/mobile review mechanism and performance rules.

## 2. Fresh-chat bootstrap

Read repository state before making geometry decisions. Recommended order:

1. `REPOSITORY_CONTRACT.md`
2. `DESIGN_PROTOCOL.md`
3. `MECHANICAL_INTEGRITY_PROTOCOL.md`
4. `MOTION_QA_PROTOCOL.md`
5. `BROWSER_REVIEW_PROTOCOL.md`
6. `PROJECT_STATE.md`
7. `README.md`
8. `PARTS.md`
9. `INTERFACES.md`
10. `ASSEMBLY.md`
11. `CALIBRATION.md`
12. `src/config.scad`
13. current QA result documents/scripts
14. relevant current assemblies and exact neighboring part sources.

Do not infer current design state from old chat snippets when the repository can answer it.

## 3. Mechanical-integrity invariant

The default physical rule is:

> If an explicit interface does not classify a pair as an intended fit/contact/passage/embedded/bonded/kinematic relationship, two physical solids may not occupy the same volume.

This applies to printed parts **and** purchased hardware: shafts, bearings, screw heads/shanks, nuts, washers, motors, payload envelopes and any body capable of interference.

Bodies that share the same operational transform are not exempt. Internal collisions inside a moving subassembly must be checked explicitly rather than hidden by unioning the bodies into one collision mesh.

See `MECHANICAL_INTEGRITY_PROTOCOL.md`.

## 4. Real trajectory / DOF invariant

A CAD `rotate()` or `translate()` is not a physical mechanism. A free rigid body begins with six rigid-body DOFs. For every installed body/subassembly, the design must identify bearings, shafts, guides, slots, hinges, rails, linkages, locators, fasteners, retention/end stops or equivalent real geometry that removes unwanted DOFs and leaves only the intended movement.

The repository must preserve the associated support/load path. Underconstraint and impossible overconstraint are both design failures.

## 5. Complete state-space rule

Mechanical QA includes:

```text
operational DOFs
× adjustment DOFs
× relevant discrete configurations
× relevant assembly/service states
```

For this mount that includes at least AZ, ALT and the payload balancing slider. Endpoints are mandatory. If exhaustive Cartesian coverage is impractical, a documented conservative/symmetry/swept-volume proof is required; silent omission is not acceptable.

## 6. Atomic part acceptance

A new or materially changed printable/mechanical part is **not DONE merely because a `.scad` file exists**.

Acceptance is the complete transaction:

```text
part source
+ shared parameters / interface contracts
+ solid-body relationship classification
+ physical support / constraint / load-path definition
+ per-part geometric/visual/section QA
+ neighboring/context + hardware-envelope QA
+ partial/full assembly integration
+ pairwise mechanical-integrity checks
+ full affected operational/adjustment state-space QA
+ PARTS / INTERFACES / constraint status update
+ ASSEMBLY / live BOM update
+ PROJECT_STATE / HOLD update
+ browser publication / human reviewability
= accepted design step
```

If one required item is missing, the part remains provisional or `NEEDS_REVALIDATION`.

## 7. Browser publication is part of integration

Human review must work from an ordinary modern phone/tablet browser. The reusable rules are in `BROWSER_REVIEW_PROTOCOL.md`.

For this project GitHub Pages must:

- snapshot exact `src/` from the deployed commit;
- build renderable-entry manifest and recursive dependency closures;
- record/verify SHA-256 source hashes;
- expose exact source-at-commit links;
- run pinned modern OpenSCAD WebAssembly + Manifold in a **background Web Worker**, never the UI thread;
- show elapsed time and honest indeterminate progress during opaque geometry solving;
- provide diagnostics and Cancel;
- display generated binary STL with Three.js;
- keep parts, useful subsystems, full assemblies and QA review entry points browser-renderable.

The repository source is authoritative; browser STL is derived review evidence.

## 8. Live assembly/BOM rule

`ASSEMBLY.md` is a live engineering product, not end-of-project documentation. Whenever an accepted part/interface/constraint changes, immediately update affected quantities, purchased/fabricated hardware, fastener lengths, supports/retention roles, tools/consumables, fit tests, mating relationships, assembly order, tool access, motion/adjustment checks and service constraints.

At every checkpoint it must answer: **what must be printed, bought, fabricated and prepared to build the best-known machine now?**

## 9. Assembly sequence is a design constraint

A geometrically valid final arrangement is unacceptable if it cannot actually be assembled, tightened, adjusted or serviced. Context QA must consider intermediate assembly states, fastener insertion, bearing installation, tool reach, trapped parts, disassembly path, temporary loss of support and service movement.

## 10. Controlled backtracking

When a downstream part cannot satisfy its contract:

1. identify the failing interface/solid relation/constraint/motion ID;
2. find the nearest upstream owner;
3. change the smallest upstream scope that resolves it;
4. mark affected descendants `NEEDS_REVALIDATION`;
5. re-run geometric/integrity/state-space QA in dependency order;
6. update assembly/BOM/state before continuing forward.

Backtracking is minimal in scope, complete in validation.

## 11. Human review gates

Stop for explicit human review at least after:

- initial machine decomposition;
- shared interface/constraint/parameter architecture;
- each major subsystem integration;
- large recursive backtracking;
- changes to high-fanout validated interfaces/support chains;
- before expensive/long physical prints;
- before final production assembly.

Expose changed part/section, current assembly, relevant solid/constraint contracts, QA status, BOM/HOLDs and proposed next step.

## 12. Definition of done

A mechanical step is complete only when a future session can:

1. understand why the part exists and what it interfaces with;
2. understand how it is supported/retained and what DOFs remain;
3. regenerate it from source/shared parameters;
4. reproduce relevant geometric, solid-pair and state-space QA;
5. place it in the current assembly;
6. inspect it in the browser without freezing the page;
7. identify required non-printed hardware and fasteners;
8. physically integrate/service it using `ASSEMBLY.md`;
9. know remaining HOLD/VERIFY items and proof limitations;
10. continue the next dependency without recovering chat history.
