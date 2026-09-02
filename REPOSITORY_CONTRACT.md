# Repository Contract — persistent memory, mobile review, and build continuity

This file is a **mandatory process contract** for this project and a reusable pattern for future parametric mechanical-design repositories.

The repository is the persistent engineering memory. Chat history is disposable working context.

## 1. Repository-first continuity

No decision required to continue the engineering work may exist only in chat.

Before a logical design step is considered complete, all information needed to resume it in a completely new chat must be committed to the repository.

The repository must preserve, as applicable:

- machine requirements and constraints;
- complete planned part decomposition;
- interface contracts and dependency/build order;
- shared parameters, datums, fits and derived dimensions;
- part/project status;
- OpenSCAD source for parts and assemblies;
- visual/geometric/motion QA tooling, policy and accepted checkpoints;
- unresolved HOLD/VERIFY items and reasons;
- live printable-part list and non-printed BOM;
- tools, consumables and physical fit tests;
- physical assembly order;
- browser/mobile review mechanism and performance rules.

A chat may discuss alternatives, but once a decision affects future work it must be written into the repository.

## 2. Fresh-chat bootstrap

Read the repository before making new geometry decisions.

Recommended order:

1. `REPOSITORY_CONTRACT.md`
2. `DESIGN_PROTOCOL.md`
3. `MOTION_QA_PROTOCOL.md`
4. `BROWSER_REVIEW_PROTOCOL.md`
5. `PROJECT_STATE.md`
6. `README.md`
7. `PARTS.md`
8. `INTERFACES.md`
9. `ASSEMBLY.md`
10. `CALIBRATION.md` where present
11. `src/config.scad`
12. current QA result documents/scripts
13. relevant assemblies
14. exact neighboring part sources for the next task

Do not infer current design state from chat snippets when the repository can answer it.

## 3. Atomic part acceptance

A new or materially changed printable part is **not DONE merely because a `.scad` file exists**.

Acceptance is the complete transaction:

```text
part source
+ shared parameters/interfaces
+ per-part QA
+ neighboring/context QA
+ partial/full assembly integration
+ full-range motion QA when relevant
+ ASSEMBLY/BOM update
+ PARTS/INTERFACES status update
+ PROJECT_STATE/HOLD update
+ browser publication/reviewability
= accepted design step
```

If one required item is missing, the part remains provisional.

For moving mechanisms, a few attractive static poses are not a substitute for full-range motion QA.

## 4. Browser publication is part of integration

Human review must work from an ordinary modern phone/tablet browser. The reusable technical rules are in `BROWSER_REVIEW_PROTOCOL.md`.

For this project, GitHub Pages must:

- snapshot `src/` from the deployed commit;
- build a manifest of renderable SCAD entry points;
- record SHA-256 source hashes;
- record recursive `include`/`use` dependency closures;
- expose exact source-at-commit links;
- run OpenSCAD WebAssembly in a **background Web Worker**, never on the UI thread;
- use the pinned modern OpenSCAD build and Manifold backend;
- stream phase/diagnostic information where available;
- show elapsed time and honest indeterminate progress during opaque geometry solving;
- allow Cancel by terminating the worker;
- display generated binary STL with Three.js;
- link project state, assembly/BOM, calibration and QA documents.

The normal review path is a single source-derived browser path:

```text
repository commit
→ Pages source snapshot + dependency manifest
→ phone/browser Web Worker
→ verified required source files only
→ OpenSCAD WebAssembly + Manifold
→ binary STL
→ Three.js review
```

**CI-prebuilt STL previews are not part of the normal architecture.** They may be introduced only as a documented performance exception if measured browser rendering becomes impractical again on intended devices.

Every printable part and useful subsystem/full assembly must have an appropriate published OpenSCAD entry point.

### Browser integration gate

After a major part/subsystem integration:

1. ensure a manifest-published SCAD entry exists;
2. ensure Pages deployment succeeds;
3. load the exact deployed source snapshot;
4. render the part/assembly in the browser worker;
5. confirm the UI remains responsive;
6. confirm elapsed-time/progress UI and Cancel operate;
7. inspect orbit/zoom on a phone-sized viewport when practical;
8. use that visualization as a human review gate before expensive printing.

A design that cannot be reviewed through the browser surface is not fully integrated.

## 5. Mobile-first operating model

```text
voice/chat on phone or tablet
        ↓
AI reads/modifies GitHub repository
        ↓
repository preserves engineering state
        ↓
GitHub Actions executes QA and publishes source/runtime
        ↓
mobile browser regenerates selected CAD in Web Worker
        ↓
human inspects generated model + QA/project state
        ↓
feedback returns through chat
```

No desktop CAD application is required for routine review. A desktop remains useful for slicing, printer operation and optional local development.

## 6. `ASSEMBLY.md` is a live build product

`ASSEMBLY.md` evolves with the CAD, not at the end.

For every relevant part/subassembly it should preserve:

- printable source and quantity;
- purchased/fabricated items;
- fasteners, inserts, shafts, bearings, washers and nuts;
- provisional versus frozen dimensions;
- required tools/consumables;
- mating parts and interface;
- orientation/insertion direction;
- assembly order;
- tool/fastener access constraints;
- lubrication/threadlocker/adhesive notes;
- required fit/calibration tests;
- motion/free-play checks;
- service/disassembly constraints.

The guide describes how to physically build the **best-known machine at the current checkpoint**.

## 7. Live BOM

The BOM must always answer: “What must I print, buy, fabricate and prepare to build everything currently designed?”

Keep separate categories for:

- printable parts;
- purchased mechanical components;
- fasteners/hardware;
- electronics when in scope;
- raw stock;
- consumables;
- special tools;
- optional items;
- provisional items awaiting verification.

Remove obsolete hardware after redesigns.

## 8. Assembly sequence is a design constraint

A geometrically valid part is not acceptable if the intended build sequence makes it impossible to assemble, service or move correctly.

Reject designs where, for example:

- a screw cannot be inserted/reached;
- a bearing cannot be installed;
- parts require impossible mutual insertion;
- a tool cannot access a fastener;
- a component becomes trapped too early;
- a service part requires destructive disassembly;
- a moving part collides outside its neutral pose.

Context QA must include intermediate assembly states and the complete motion space.

## 9. `PROJECT_STATE.md`

This is the short resume checkpoint and must be updated at meaningful milestones/backtracking events.

It must state at least:

- current project phase;
- trusted/full assemblies;
- completed subsystems;
- accepted motion-QA checkpoint;
- browser-review architecture when relevant;
- provisional/HOLD/BLOCKED interfaces;
- next recommended engineering step.

It is an index, not a replacement for source/BOM/interfaces/QA evidence.

## 10. Human review checkpoints

At major boundaries make the current state easy to inspect before proceeding deeper into the dependency graph.

Expose:

- current assembly/subassembly;
- changed part;
- useful sections/cutaways/context QA;
- motion-QA summary when relevant;
- changed parameters/interfaces;
- `PROJECT_STATE.md`;
- `ASSEMBLY.md` and BOM;
- unresolved HOLD/VERIFY items;
- proposed next step.

Human review may approve, reject, redirect or request backtracking. Preserve that decision in the repository.

## 11. Definition of done

Another fresh session must be able to:

1. understand why the part exists and its interfaces;
2. regenerate geometry from source/common parameters;
3. reproduce relevant visual/geometric QA;
4. reproduce relevant motion QA;
5. place it in the current assembly;
6. render/review it in the mobile browser without freezing the UI;
7. identify required non-printed items;
8. follow the physical assembly procedure;
9. know remaining risks/HOLD items;
10. continue without recovering lost chat context.

## 12. Browser scalability invariant

Growing the repository must not slow every browser render merely because unrelated files were added.

Preserve these invariants unless a demonstrably better architecture replaces them:

```text
CAD computation off UI thread
+ recursive dependency-closure mounting
+ modern pinned WASM renderer
+ Manifold backend where supported
+ binary STL transfer
+ honest phase/elapsed progress
+ cancellation
+ exact-commit source integrity
+ browser rendering as the normal path
```

If browser review becomes slow or unresponsive, treat that as an integration regression first. Only add CI-prebuilt geometry after measured evidence shows the optimized browser-worker path is still impractical.