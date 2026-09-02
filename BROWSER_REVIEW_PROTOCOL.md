# Browser Review Protocol — responsive mobile CAD inspection

This document is intentionally **project-agnostic**. It defines the browser/mobile review contract for parameterized mechanical CAD repositories where the human operator may review complex assemblies from a phone or tablet.

The browser is a review surface, not the design source of truth. Source CAD, parameters, interfaces, BOM and QA state remain in the repository.

## 1. Browser rendering is the standard review path

The normal review path is to regenerate the selected CAD entry point directly in the browser from the exact deployed repository source.

For OpenSCAD projects:

```text
repository source snapshot
        ↓
dependency closure for selected entry
        ↓
OpenSCAD WebAssembly Web Worker
        ↓
binary STL
        ↓
Three.js interactive viewer
```

Do not require CI-prebuilt STL previews merely because an assembly is large. If the current browser/WebAssembly implementation renders the project fast enough for practical use, keep a single browser-render path and avoid duplicate rendering infrastructure.

A CI-prebuilt preview is an optional exception only when measured browser performance on the target devices becomes unacceptable again.

## 2. Responsiveness is a hard requirement

A CAD operation must never run synchronously on the browser UI thread.

```text
main UI thread
    ├─ controls / navigation / status
    ├─ documentation/source display
    ├─ Three.js viewer
    └─ Web Worker
          └─ CAD engine / expensive render
```

The worker may consume CPU for seconds or minutes, but the user must still be able to scroll, inspect documentation, see elapsed time and cancel the render without triggering the browser's "page not responding" warning because of a blocked JavaScript main thread.

If the CAD runtime cannot be moved off the main thread, it is not acceptable for routine mobile review of expensive assemblies.

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

## 5. Renderer choice and version pinning

Use a modern CAD engine build and pin it explicitly in CI.

For OpenSCAD, prefer the modern Manifold backend for browser rendering where supported. Keep the exact WebAssembly build/version in the publication workflow or manifest so a future session can reproduce the rendering environment.

Changing the CAD engine version is an engineering/toolchain change and should be validated before being treated as routine infrastructure.

## 6. Source integrity

Published browser source must correspond to the repository commit advertised by the page.

Required checks:

- snapshot source from the checked-out commit during deployment;
- store SHA-256 for each source file in the manifest;
- verify downloaded source bytes before mounting them in the browser worker;
- version browser assets by commit to avoid stale caches;
- expose a direct source-at-this-commit link.

The STL displayed by the browser is derived data generated from that verified source snapshot. It does not become a separate source of truth.

## 7. Cancellation and worker lifecycle

A CAD worker is disposable.

Recommended lifecycle:

```text
user requests render
→ create worker
→ worker initializes CAD runtime
→ verify/mount dependency closure
→ render
→ transfer binary STL result
→ terminate worker
```

On Cancel, selection change, navigation away, crash or error, terminate the worker. Do not leave expensive orphan render jobs accumulating in the browser.

A fresh worker per render also avoids hidden CAD runtime state leaking between invocations.

## 8. When a prebuilt preview is justified

Do **not** maintain prebuilt previews by default.

Introduce a CI-prebuilt preview only after measured evidence shows that one or more important review entry points are impractically slow on the intended phone/tablet hardware even with:

- background Web Worker execution;
- modern pinned OpenSCAD WebAssembly;
- Manifold backend;
- dependency-closure loading;
- binary STL output.

If such an exception is introduced, document the measured reason and keep the browser worker render available as the reproducible source-derived path.

If later browser performance improves, remove the prebuild exception rather than keeping duplicate infrastructure indefinitely.

## 9. Human review semantics

The normal displayed geometry is a **browser WASM render** regenerated locally from the deployed source snapshot.

Formal CAD acceptance still follows the project's QA protocol. A fast interactive render is a human-review aid, not proof of manifoldness, fit, collision freedom, torque capability or physical correctness.

## 10. Mobile acceptance gate

A browser-review implementation is acceptable only if, on a normal phone/tablet:

- ordinary parts and useful assemblies render in a practical amount of time;
- rendering does not block the page UI;
- elapsed time visibly advances during long geometry work;
- Cancel responds while geometry work is running;
- source/documentation remains usable during the worker render;
- adding unrelated CAD files does not force those files into every render;
- the full assembly can be regenerated from exact repository source;
- no duplicate CI-render path is maintained unless measured performance requires it.

This browser-worker-first model is the default review pattern for future parametric mechanical projects.