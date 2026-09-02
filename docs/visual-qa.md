# Visual QA loop

Every mechanical design iteration is validated before it is merged.

For an individual printable part the minimum QA loop is:

1. Export the OpenSCAD entry point to STL with full CGAL render and `--hardwarnings`.
2. Require OpenSCAD `Simple: yes` and a watertight mesh.
3. Render isometric, top, bottom, front and right-side views.
4. Produce center X/Y cross-sections from the exported STL.
5. Inspect the resulting contact sheet for unintended geometry, inaccessible fasteners,
   collisions, thin walls and wrong orientation.
6. Iterate and repeat the checks after every geometry change.

Run full QA for an individual part from the repository root:

```bash
python3 tools/visual_qa.py src/parts/az_turntable.scad
```

Large assemblies can make a full CGAL union unnecessarily expensive. Their printable
components must pass full QA individually; the assembly then gets a standard multi-angle
visual pass with:

```bash
python3 tools/visual_qa.py src/assemblies/az_yoke_payload.scad --preview-only
```

Assembly QA is supplemented by executable OpenSCAD `assert()` clearance checks and, for
moving mechanisms, views with covers removed so shaft/gear relationships remain visible.

## Mandatory motion QA for moving mechanisms

Any assembly containing one or more moving degrees of freedom must also follow
[`MOTION_QA_PROTOCOL.md`](../MOTION_QA_PROTOCOL.md).

A few named poses are not sufficient. The QA gate must cover the **complete allowed motion
range** with a repeatable sampled sweep, while explicitly checking both end limits, neutral
or reference pose, known worst-case configurations, closest-clearance positions and any
coupled multi-axis combinations that can create a conflict.

For every sampled configuration inspect or programmatically verify, as applicable:

- moving-to-fixed and moving-to-moving collisions;
- required minimum clearance;
- payload/counterweight swept envelope;
- gear, shaft and bearing relationships;
- guard/cover clearance;
- cable/hose bend, twist and extension;
- hard-stop/overtravel behavior;
- interface-specific invariants.

Sampling must be adaptive: use a finer step near small clearances or complicated geometry.
Where practical, swept-volume analysis should supplement pose sampling so a narrow
intermediate conflict is not missed between two samples.

If a geometry, axis, motion limit, payload envelope or neighboring clearance changes, the
relevant motion QA is invalidated and the **whole affected sweep must be repeated**, not
only the pose where the earlier problem was found.

Outputs are written under `build/qa/<part>/` and include the STL and sections in full mode,
PNG views in both modes, `qa.json`, and `contact-sheet.png`.

The script needs OpenSCAD, Xvfb, Python 3, Pillow, matplotlib and trimesh.
Generated QA artifacts are intentionally not committed; the OpenSCAD source remains the
authoritative design and the browser validator independently recompiles it to STL.
