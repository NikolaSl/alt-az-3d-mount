# Tabletop base CAD QA

Part: `P-TABLETOP-BASE`  
Source: `src/parts/tabletop_base_adapter.scad`  
Interface: `I-028`

## Individual part QA

The part was validated with the repository visual-QA procedure before integration.

```text
OpenSCAD full CGAL: Simple: yes
watertight STL: yes
connected printable components: 1
bounds: 190 × 190 × 8 mm
```

The standard isometric/top/bottom/front/right views and center X/Y sections were inspected.

Observed geometry:

- top has a centered Ø49 mm, 1.5 mm deep locator for the Ø48 `az_base` pedestal;
- the central 1/4-20 clearance passes through the plate;
- the underside has a Ø16 mm × 5 mm bolt-head recess;
- four Ø18 mm × 1.2 mm rubber-foot recesses are arranged on an 82 mm radius;
- all recesses remain within one coherent/watertight printable disk.

## Context QA against `P-AZ-BASE`

`src/assemblies/tabletop_base_context.scad` was rendered with the actual `az_base` geometry, not only an abstract envelope.

The placement intentionally makes the locator pocket floor coincide with the pedestal bottom:

```text
adapter Z = -AZ_PEDESTAL_H - TABLETOP_BASE_T + TABLETOP_LOCATOR_DEPTH
```

This leaves the surrounding adapter top 1.5 mm above the pedestal bottom, forming the shallow lateral locator while preserving the existing central 1/4-20 screw path.

No existing AZ geometry was changed to add tabletop mode; the adapter is removable and the original tripod interface remains available.

## Physical verification still required

CAD QA cannot establish real stability. Before accepting `I-028` as physically verified:

- confirm the actual 1/4-20 bolt head fits the recess;
- choose the shortest bolt with adequate engagement that does not approach the internal M8 AZ hardware;
- confirm the four rubber feet contact the real surface without rocking;
- load the real payload and test overturn margin at the worst intended ALT orientation;
- confirm the pedestal locator is free-sliding/locating rather than a damaging press fit.
