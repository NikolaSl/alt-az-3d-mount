# Visual QA loop

Every mechanical design iteration is validated before it is merged.

The minimum QA loop is:

1. Export the OpenSCAD entry point to STL with full CGAL render and `--hardwarnings`.
2. Require OpenSCAD `Simple: yes` and a watertight mesh.
3. Render isometric, top, bottom, front and right-side views.
4. Produce center X/Y cross-sections from the exported STL.
5. Inspect the resulting contact sheet for unintended geometry, inaccessible fasteners,
   collisions, thin walls and wrong orientation.
6. For assemblies, additionally render with covers removed so gear/shaft clearances are visible.

Run for an individual part from the repository root:

```bash
python3 tools/visual_qa.py src/parts/az_turntable.scad
```

Outputs are written under `build/qa/<part>/` and include the STL, PNG views,
cross-sections, `qa.json`, and `contact-sheet.png`.

The script needs OpenSCAD, Xvfb, Python 3, Pillow, matplotlib and trimesh.
Generated QA artifacts are intentionally not committed; the OpenSCAD source remains the
authoritative design and the browser validator independently recompiles it to STL.
