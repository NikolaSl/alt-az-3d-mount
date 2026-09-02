# Browser review performance checkpoint

This document records a human-observed browser/mobile validation result for the current GitHub Pages CAD review architecture.

## Observation

After moving OpenSCAD WebAssembly rendering to a background Web Worker, switching the browser renderer to the pinned OpenSCAD 2025.03.25 WebAssembly build with the Manifold backend, and mounting only the recursive dependency closure for the selected SCAD entry point, ordinary non-prebuilt models render on the user's mobile browser in seconds rather than minutes.

The user also confirmed that the browser remains responsive enough for routine review. The previous behavior — repeated "page not responding" prompts during synchronous main-thread OpenSCAD execution — is no longer the normal rendering path.

## Current policy confirmed by this observation

- Keep prebuilt CI STL previews for the genuinely expensive full-machine assemblies, especially `assemblies/full_mount.scad` and `assemblies/tabletop_full_mount.scad`.
- Keep ordinary elementary parts, calibration coupons and reasonably sized subsystem entries as on-demand browser Web Worker renders.
- Do not prebuild every new part merely because it exists; measured render cost, not part count, should decide whether an entry joins the prebuilt set.
- Preserve dependency-closure loading so adding unrelated SCAD files does not slow every browser render.
- Preserve the worker/Cancel/elapsed-time architecture even when a model currently renders in only a few seconds, because model complexity may grow later.

## Interpretation

The main performance gain is not attributed to a single change in isolation. The accepted architecture combines:

1. no heavy CAD execution on the UI thread;
2. a modern OpenSCAD WebAssembly build;
3. Manifold backend for browser re-rendering;
4. dependency-aware source mounting;
5. CI-prebuilt STL previews only for measured high-cost assemblies.

This checkpoint validates that the browser-review design is suitable for the intended phone/tablet workflow at the current project scale.
