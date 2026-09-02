# Repository Contract — persistent memory, mobile review, and build continuity

This file is a **mandatory process contract** for this project and a reusable pattern for future parametric mechanical-design repositories.

The repository is the persistent engineering memory. Chat history is disposable working context.

## 1. Repository-first continuity rule

No decision that is required to continue the engineering work may exist only in chat.

Before a logical design step is considered complete, all information needed to resume it in a completely new chat must be committed to the repository. A new AI/human session should be able to reconstruct the project without access to previous conversation history.

The repository must contain, as applicable:

- machine requirements and constraints;
- full planned part decomposition;
- interaction/interface contracts;
- shared parametric configuration and derived dimensions;
- dependency/build order;
- part status and current project checkpoint;
- OpenSCAD source for parts and assemblies;
- repeatable visual/geometric/motion QA tooling, policies and accepted QA checkpoints;
- unresolved assumptions, HOLD/VERIFY items and reasons;
- design decisions that affect downstream geometry;
- live printable-part list;
- live non-printed BOM;
- required tools/consumables and physical fit tests;
- exact assembly order to the best-known current machine;
- browser-review/publishing mechanism.

A chat may discuss alternatives, but once an alternative becomes a design decision or affects future work it must be written into the repository.

## 2. Fresh-chat bootstrap contract

When work starts in a new chat/session, read the repository before making new geometry decisions.

Recommended bootstrap order:

1. `REPOSITORY_CONTRACT.md` — how the project must be maintained.
2. `DESIGN_PROTOCOL.md` — generic parametric mechanical-design algorithm.
3. `MOTION_QA_PROTOCOL.md` — mandatory full-range QA rules for mechanisms with moving parts.
4. `PROJECT_STATE.md` — current checkpoint, trusted geometry, blockers and next steps.
5. `README.md` — project purpose and high-level architecture.
6. `PARTS.md` — decomposition, stable IDs, dependency/status ledger.
7. `INTERFACES.md` — interface and motion contracts, invalidation map.
8. `ASSEMBLY.md` — current printable parts, BOM and physical assembly sequence.
9. `CALIBRATION.md` where present — physical measurement/fit state.
10. `src/config.scad` — current shared parameter system and datums.
11. QA documents/scripts under `docs/` and `tools/`, including the latest accepted result checkpoint such as `docs/motion-qa-results.md`.
12. Relevant current partial/full assemblies under `src/assemblies/`.
13. The exact neighboring part sources involved in the next task.

If `REQUIREMENTS.md` or machine-readable state files are introduced later, they become part of this bootstrap set.

Do not infer the current design state from chat snippets when the repository can answer it.

## 3. Atomic part-acceptance transaction

A new or materially changed printable part is **not DONE merely because a `.scad` file exists**.

The logical transaction for accepting a part is:

```text
part source
  + shared parameters/interfaces
  + per-part QA
  + neighboring/context QA
  + current partial/full assembly integration
  + full-range motion QA where the motion envelope is affected
  + ASSEMBLY.md update
  + printable-parts/BOM update
  + PARTS/INTERFACES motion-status/invalidation update
  + project-state / HOLD / decision update
  + browser publication/reviewability
  = accepted design step
```

These items should normally land together in the same coherent commit or in a short, explicitly linked commit sequence. If one is missing, the part remains provisional.

For a mechanism with moving parts, four attractive static poses are not a substitute for motion QA. Endpoints, intermediate states, critical clearances, and relevant coupled-axis configurations are part of the acceptance transaction as defined in `MOTION_QA_PROTOCOL.md`.

## 4. Browser publication is part of integration

Human review must be possible from an ordinary modern browser, including a phone or tablet.

For this repository, GitHub Pages is the mobile human-in-the-loop review surface. The current site:

- snapshots the repository `src/` tree on deployment;
- builds a manifest of renderable SCAD entry points;
- verifies source hashes;
- loads OpenSCAD WebAssembly in the browser;
- renders the selected SCAD to STL locally in the browser;
- displays the generated STL with an interactive Three.js viewer;
- exposes the exact source/commit used for the render;
- links the persistent project state, assembly/BOM, calibration and QA-result documents.

Every new printable part and useful subsystem/full assembly must therefore have an appropriate OpenSCAD entry point under the published source tree so that it is selectable and renderable from the browser.

### Browser-integration gate

After a major part/subsystem integration:

1. ensure the SCAD entry point is under `src/parts/`, `src/assemblies/` or another manifest-published path;
2. ensure the Pages workflow is triggered by the commit;
3. ensure the published page can load the new source snapshot;
4. render the new part/assembly in-browser;
5. check orbit/zoom interaction on a phone-sized viewport when practical;
6. use the published visualization as a human review gate before committing to expensive physical printing.

A design that exists only as local/generated files but cannot be reviewed through the project browser surface is not fully integrated.

## 5. Mobile-first operating model

The intended operating model is deliberately lightweight:

```text
Chat/voice on phone or tablet
        ↓
AI reads and modifies GitHub repository
        ↓
repository preserves all engineering state
        ↓
GitHub Actions executes QA and publishes current OpenSCAD sources
        ↓
ordinary mobile browser runs OpenSCAD WebAssembly
        ↓
human inspects part/subsystem/full assembly + QA state
        ↓
feedback returns through chat
```

No desktop CAD application is required for routine review. A desktop remains useful for local development, slicing and physical printer control, but the engineering conversation, repository state and browser validation must remain usable over the Internet from a normal mobile device.

## 6. `ASSEMBLY.md` is a live build product, not end-of-project documentation

`ASSEMBLY.md` must evolve together with the CAD from the first accepted part onward.

Whenever a new part is accepted or an interface changes, update all affected assembly information immediately.

For every relevant part/subassembly, `ASSEMBLY.md` should preserve:

- printed filename/module and required quantity;
- purchased/fabricated non-printed components;
- fasteners, inserts, shafts, bearings, washers and nuts;
- provisional versus frozen hardware dimensions;
- required tools and consumables where non-obvious;
- mating parts and interface description;
- orientation and insertion direction when important;
- order of assembly;
- fastener access/tool access constraints;
- lubrication/threadlocker/adhesive notes where applicable;
- fit/calibration coupon or physical verification required before final assembly;
- motion/free-play checks after the step;
- full-range physical motion checks for moving mechanisms;
- later disassembly/service constraints when relevant.

The guide must describe how to physically build the **best-known machine at the current design checkpoint**, not only the eventual final concept.

## 7. Live BOM rule

The BOM is part of design state. It must always answer: “What would I have to print, buy, fabricate and prepare if I wanted to build everything that is currently designed?”

Keep at least these categories distinct:

- printable parts;
- purchased mechanical components;
- fasteners/hardware;
- electronics, when they enter scope;
- raw stock to cut/fabricate;
- consumables;
- required/special tools;
- optional components;
- provisional components awaiting physical verification.

Quantities must be updated when part count or assembly topology changes. Do not leave obsolete hardware in the active BOM after a redesign.

## 8. Assembly sequence is also a design constraint

The physical build sequence must influence CAD decisions.

A geometrically valid part is not acceptable if, in the intended sequence:

- a screw cannot be inserted or reached;
- a bearing cannot be pressed into place;
- two parts require impossible mutual insertion;
- a tool cannot reach the fastener;
- a component becomes trapped before a required later component is installed;
- a service part cannot be removed without destructive disassembly when serviceability is required;
- a moving part is only collision-free in its neutral pose but fails elsewhere in its intended range.

During context QA, reason not only about the final assembled geometry but also about the intermediate assembly states described by `ASSEMBLY.md` and the complete motion space described by `MOTION_QA_PROTOCOL.md`.

## 9. Current-state file

`PROJECT_STATE.md` is the short session-resume document. It should be updated at meaningful checkpoints and after significant backtracking.

It should state at minimum:

- current project phase;
- current trusted/full assembly entry point;
- major completed subsystems;
- current accepted motion-QA checkpoint where moving mechanisms exist;
- provisional or physically unverified interfaces;
- HOLD/BLOCKED items;
- next recommended design or validation step;
- documents that changed with the latest checkpoint.

It is not a replacement for the source, BOM, interfaces or assembly guide. It is an index into them.

## 10. Human review checkpoints

At major boundaries, stop and make the current state easy for a human to inspect from the browser before moving deeper into the dependency graph.

A review checkpoint should make available:

- current full or subsystem assembly;
- the newly changed part;
- useful cutaway/section/context views from QA;
- motion-QA summary and representative poses when motion is involved;
- key changed parameters/interfaces;
- current `PROJECT_STATE.md`;
- current `ASSEMBLY.md` and BOM;
- unresolved HOLD/VERIFY items;
- proposed next step.

Human intervention may approve, reject, redirect or request backtracking. The repository must preserve the resulting decision.

## 11. Definition of done for a mechanical design step

A step is complete only when another session can:

1. clone/read the repository;
2. understand why the part exists and what it interfaces with;
3. regenerate its geometry from source and common parameters;
4. reproduce the relevant visual/geometric QA;
5. reproduce the relevant full-range motion QA when moving geometry is involved;
6. place it in the current assembly;
7. see it in the browser-published project;
8. identify what non-printed items are required;
9. follow `ASSEMBLY.md` to physically integrate it and test its intended motion;
10. know remaining risks/HOLD items;
11. continue the next dependency without recovering lost context from chat.

This rule is intentionally stricter than “the CAD compiles”. It is what makes the project durable across chats, devices and contributors.
