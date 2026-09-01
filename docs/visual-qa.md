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

Outputs are written under `build/qa/<part>/` and include the STL and sections in full mode,
PNG views in both modes, `qa.json`, and `contact-sheet.png`.

The script needs OpenSCAD, Xvfb, Python 3, Pillow, matplotlib and trimesh.
Generated QA artifacts are intentionally not committed; the OpenSCAD source remains the
authoritative design and the browser validator independently recompiles it to STL.
