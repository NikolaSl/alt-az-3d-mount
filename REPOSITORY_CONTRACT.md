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
- browser-review/publishing mechanism and its performance/responsiveness rules.

A chat may discuss alternatives, but once an alternative becomes a design decision or affects future work it must be written into the repository.

## 2. Fresh-chat bootstrap contract

When work starts in a new chat/session, read the repository before making new geometry decisions.

Recommended bootstrap order:

1. `REPOSITORY_CONTRACT.md` — how the project must be maintained.
2. `DESIGN_PROTOCOL.md` — generic parametric mechanical-design algorithm.
3. `MOTION_QA_PROTOCOL.md` — mandatory full-range QA rules for mechanisms with moving parts.
4. `BROWSER_REVIEW_PROTOCOL.md` — responsive mobile CAD review/publication rules.
5. `PROJECT_STATE.md` — current checkpoint, trusted geometry, blockers and next steps.
6. `README.md` — project purpose and high-level architecture.
7. `PARTS.md` — decomposition, stable IDs, dependency/status ledger.
8. `INTERFACES.md` — interface and motion contracts, invalidation map.
9. `ASSEMBLY.md` — current printable parts, BOM and physical assembly sequence.
10. `CALIBRATION.md` where present — physical measurement/fit state.
11. `src/config.scad` — current shared parameter system and datums.
12. QA documents/scripts under `docs/` and `tools/`, including the latest accepted result checkpoint such as `docs/motion-qa-results.md`.
13. Relevant current partial/full assemblies under `src/assemblies/`.
14. The exact neighboring part sources involved in the next task.

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

Human review must be possible from an ordinary modern browser, including a phone or tablet. The reusable technical rules live in `BROWSER_REVIEW_PROTOCOL.md`.

For this repository, GitHub Pages is the mobile human-in-the-loop review surface. It must:

- snapshot the repository `src/` tree from the deployed commit;
- build a manifest of renderable SCAD entry points;
- preserve source hashes and expose the exact source/commit;
- display a selected model interactively with Three.js;
- publish fast derived STL previews for expensive review assemblies;
- retain an explicit independent **Re-render in browser** path from exact source;
- execute expensive browser CAD work in a Web Worker, never synchronously on the UI thread;
- show phase + elapsed time + diagnostics and allow cancellation during long renders;
- mount only the selected entry's recursive dependency closure where it can be resolved safely;
- link the persistent project state, assembly/BOM, calibration and QA-result documents.

The normal human-review path for an expensive assembly is therefore:

```text
repository commit
→ GitHub Actions builds preview STL
→ Pages publishes source snapshot + preview
→ phone loads STL immediately
→ human rotates/zooms/reviews
```

The independent validation/debug path is:

```text
Re-render in browser
→ background Web Worker
→ exact deployed source dependency closure
→ OpenSCAD WebAssembly
→ generated STL
→ Three.js viewer
```

A trustworthy numeric progress percentage must not be fabricated when the CAD engine does not expose one. During opaque geometry computation an indeterminate progress bar plus elapsed time and live activity is the correct UI.

Every new printable part and useful subsystem/full assembly must have an appropriate OpenSCAD entry point under the published source tree. Expensive subsystem/full assemblies should be added to the CI-prebuilt preview set when measured render cost justifies it; elementary parts should normally remain on-demand worker renders so publication time does not scale unnecessarily with part count.

### Browser-integration gate

After a major part/subsystem integration:

1. ensure the SCAD entry point is under `src/parts/`, `src/assemblies/` or another manifest-published path;
2. ensure the Pages workflow is triggered by the commit;
3. ensure the published page can load the new source snapshot;
4. ensure any expensive checkpoint assembly has a published CI preview;
5. render/review the part or assembly in the browser;
6. for an independent browser compile, confirm the page stays responsive and Cancel works while the worker renders;
7. check orbit/zoom interaction on a phone-sized viewport when practical;
8. use the published visualization as a human review gate before committing to expensive physical printing.

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
GitHub Actions executes QA + builds expensive review previews
        ↓
GitHub Pages publishes source snapshot + derived previews
        ↓
ordinary mobile browser loads preview immediately
        ↓
optional independent CAD re-render runs in background worker
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
- current browser-review/rendering architecture if it affects the mobile workflow;
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
7. see it in the browser-published project without requiring an unresponsive multi-minute UI-thread compile;
8. independently re-render it in-browser when desired without freezing the review page;
9. identify what non-printed items are required;
10. follow `ASSEMBLY.md` to physically integrate it and test its intended motion;
11. know remaining risks/HOLD items;
12. continue the next dependency without recovering lost context from chat.

This rule is intentionally stricter than “the CAD compiles”. It is what makes the project durable across chats, devices and contributors.

## 12. Browser scalability invariant

Growing the repository must not make every browser render slower merely because unrelated files were added.

Therefore future browser-review implementations should preserve these invariants unless there is a demonstrably better architecture:

```text
expensive CAD computation off UI thread
+ dependency-closure source mounting
+ CI-published preview for expensive assemblies
+ on-demand worker rendering for ordinary parts
+ honest phase/elapsed progress
+ cancellation
+ exact-commit source integrity
```

If the browser review becomes unresponsive as the project grows, that is an integration regression and should be fixed before the browser surface is treated as a valid human-review gate.
