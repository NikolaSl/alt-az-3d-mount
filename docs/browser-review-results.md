# Browser review performance checkpoint

This document records a human-observed browser/mobile validation result and the resulting rendering policy for the current GitHub Pages CAD review architecture.

## Observation

After moving OpenSCAD WebAssembly rendering to a background Web Worker, switching to the pinned OpenSCAD 2025.03.25 WebAssembly build with the Manifold backend, and mounting only the recursive dependency closure for the selected SCAD entry point, ordinary parts and useful assemblies render on the user's mobile browser in seconds rather than minutes.

The user confirmed that even models which were not previously served as CI-prebuilt STL previews now render fast enough for routine mobile use.

The previous behavior — repeated "page not responding" prompts during synchronous main-thread OpenSCAD execution — is no longer the normal rendering path.

## Accepted rendering policy

The project now uses **browser WebAssembly rendering for all normal CAD review entry points**, including the full assemblies.

CI-prebuilt STL previews are no longer part of the standard browser architecture.

Current rendering path:

```text
select SCAD entry
→ resolve manifest dependency closure
→ start fresh background Web Worker
→ load pinned OpenSCAD WebAssembly
→ verify/mount required source files
→ render with Manifold
→ transfer binary STL
→ display with Three.js
```

The UI keeps phase information, elapsed time, live diagnostics and Cancel functionality for renders that take longer than usual.

## Why prebuilt previews were removed

Keeping two normal rendering paths created unnecessary infrastructure and deployment cost once local browser rendering became sufficiently fast.

Removing the prebuilt path provides:

- one reproducible source-derived rendering path;
- simpler GitHub Pages deployment;
- no native OpenSCAD installation during Pages publication;
- no assembly STL cache generation step;
- no stale distinction between "published" and "browser" geometry;
- less CI time and fewer derived artifacts;
- identical review semantics for elementary parts, subassemblies and full assemblies.

## Conditions for revisiting the decision

A CI-prebuilt preview may be reintroduced only if measured browser performance on the intended phone/tablet hardware becomes impractical again for a specific important entry point.

Before doing that, first verify that the regression is not caused by:

- accidentally mounting the entire repository instead of the dependency closure;
- falling back to the UI thread;
- losing the Manifold backend;
- changing to a slower WebAssembly build;
- excessive tessellation or unnecessary model detail;
- a new pathological CAD operation.

Any future prebuild should be treated as an explicitly documented performance exception, not the default architecture.

## Current conclusion

The browser-worker rendering architecture is suitable for the intended phone/tablet workflow at the current project scale and is the accepted default for this and future parametric mechanical projects.