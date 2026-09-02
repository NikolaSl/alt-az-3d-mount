# Browser Review Protocol — responsive mobile CAD inspection

This document is intentionally **project-agnostic**. It defines the browser/mobile review contract for parameterized mechanical CAD repositories where the human operator may review complex assemblies from a phone or tablet.

The browser is a review surface, not the design source of truth. Source CAD, parameters, interfaces, BOM and QA state remain in the repository.

## 1. Responsiveness is a hard requirement

A long CAD operation must never run synchronously on the browser UI thread.

For WebAssembly/OpenSCAD or another CPU-heavy geometry engine:

```text
main UI thread
    ├─ controls / navigation / status
    ├─ Three.js or other lightweight viewer
    └─ Web Worker
          └─ CAD engine / expensive render
```

The worker may consume CPU for minutes, but the user must still be able to scroll, inspect documentation, see elapsed time and cancel the render without triggering the browser's "page not responding" warning because of a blocked JavaScript main thread.

If the CAD runtime cannot be moved off the main thread, it is not acceptable for routine mobile review of expensive assemblies.

## 2. Two render paths

Use two complementary paths rather than forcing every phone to recompute every assembly.

### A. Published preview — default human-review path

GitHub Actions/CI builds an STL or another compact review mesh from the exact repository commit and publishes it together with the site.

Selecting an expensive assembly should normally load this derived preview immediately.

Properties:

- generated from version-controlled CAD source;
- tied to the same commit as the source snapshot;
- fast to download and display;
- suitable for orbit/zoom and human review;
- **not** a replacement for the source CAD or formal QA evidence.

### B. Independent browser re-render — validation/debug path

The page also offers an explicit **Re-render in browser** operation.

This operation:

- starts a fresh CAD Web Worker;
- mounts only required source dependencies when possible;
- recompiles the selected entry point locally;
- returns a generated STL to the UI thread;
- may be slower than the published preview but must not freeze the page;
- can be cancelled by terminating the worker.

This preserves the useful property that a phone can independently regenerate the CAD while avoiding that cost for every routine inspection.

## 3. Honest progress reporting

Do not invent a percentage when the CAD backend does not expose one.

The minimum progress UI for a long render is:

```text
phase
elapsed time
current activity/detail
indeterminate progress indicator during opaque geometry computation
live/streamed console messages when available
Cancel button
```

Useful phases are typically:

```text
starting
→ loading runtime
→ loading/verifying source dependencies
→ CAD render
→ reading/exporting output
→ preparing interactive viewer
→ done
```

Known finite work, such as loading N source files, may use a real percentage. An opaque CGAL/Manifold solve should use an indeterminate bar unless the backend provides trustworthy progress callbacks.

The user should never have to infer from a frozen screen whether work is still happening.

## 4. Dependency-closure loading

Adding unrelated files to a repository must not linearly increase the setup time of every browser render.

At publication time, statically resolve the `include` / `use` dependency graph where possible and record a dependency closure for each renderable entry point.

For entry `E`:

```text
E
+ direct includes/uses
+ their recursive dependencies
= files mounted for E
```

Do not mount every SCAD file merely because it exists in the repository.

If an external/dynamic include cannot be resolved safely, fall back to the complete source snapshot for that entry rather than silently omitting a dependency.

## 5. Bound CI cost as the project grows

Prebuilding every elementary part on every Pages deployment merely moves the scalability problem from the phone to CI.

Default policy:

- prebuild expensive **assemblies/subassemblies** that are important human-review checkpoints;
- render ordinary elementary parts and calibration coupons on demand in the browser worker;
- add another entry to the prebuilt set only after measured render cost justifies it.

Thus adding many small parts does not make every deployment arbitrarily slow, while the expensive full-machine views stay fast on mobile.

## 6. Renderer choice and version pinning

Use a modern CAD engine build and pin it explicitly in CI.

For OpenSCAD, prefer the modern Manifold backend for browser re-renders where supported. Keep the exact WebAssembly build/version in the publication workflow or manifest so a future session can reproduce the rendering environment.

Changing the CAD engine version is an engineering/toolchain change and should be validated before being treated as routine infrastructure.

## 7. Source integrity

Published browser source must correspond to the repository commit advertised by the page.

Recommended checks:

- snapshot source from the checked-out commit during deployment;
- store SHA-256 for each source file in the manifest;
- verify downloaded source bytes before mounting them in the browser worker;
- version browser assets by commit to avoid stale caches;
- expose a direct source-at-this-commit link.

A published preview STL should also be generated during the same CI build, not copied manually from an unknown local state.

## 8. Cancellation and worker lifecycle

A CAD worker is disposable.

Recommended lifecycle:

```text
user requests render
→ create worker
→ worker initializes CAD runtime
→ worker renders
→ worker transfers result
→ terminate worker
```

On Cancel, selection change, navigation away, crash or error, terminate the worker. Do not leave expensive orphan render jobs accumulating in the browser.

A fresh worker per expensive render also avoids hidden state leaking between OpenSCAD invocations.

## 9. Human review semantics

The UI should make clear which geometry is being viewed:

- **published CI render** — derived preview generated from the exact deployed commit;
- **browser WASM render** — locally regenerated result from the deployed source snapshot.

Both are useful. Neither changes the repository source.

Formal CAD acceptance still follows the project's QA protocol. A quickly loaded preview is a human-review aid, not proof of manifoldness, fit, collision freedom or physical correctness.

## 10. Mobile acceptance gate

A browser-review implementation is acceptable only if, on a normal phone/tablet:

- selecting a prebuilt full assembly does not require a multi-minute local CAD compile;
- starting an independent compile does not block the page UI;
- elapsed time visibly advances during long geometry work;
- Cancel responds while geometry work is running;
- source/documentation remains usable during the worker render;
- adding unrelated CAD files does not force those files into every render;
- the full assembly can still be regenerated from exact repository source when requested.

This is the default browser-review pattern for future parametric mechanical projects unless a project has a clearly better implementation.
