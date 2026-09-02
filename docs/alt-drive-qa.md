# ALT drive CAD / visual QA report

This report records the design checks for the first complete motorized altitude drive.

## Architecture checked

- 28BYJ-48 mounted behind `alt_gearbox_plate`.
- Stage 1: 12T motor pinion → 48T compound gear (`4:1`).
- Stage 2: 12T compound pinion → 60T shaft gear (`5:1`).
- Total external reduction: `20:1`.
- Compound gear runs on a stationary M3 shoulder/plain-shank axle supported by both gearbox plate and guard roof.
- 60T output gear is clamped to the Ø8 ALT shaft; a Ø12 spacer transfers axial positioning only through the 608 inner race.
- Output hub protrudes through the guard roof so its two M3 clamp screws remain serviceable.

## Full part QA

The following printable entry points were exported using full CGAL render with hard warnings enabled. Each result reported `Simple: yes`, was watertight, and contained one connected printable component.

| Part | Bounding box, mm |
|---|---|
| `alt_gearbox_plate` | 103 × 91 × 3.2 |
| `alt_gearbox_guard` | 103 × 91 × 17 |
| `gear_alt_motor_12t` | 14 × 14 × 5 |
| `gear_alt_compound_48_12t` | 50 × 50 × 11 |
| `gear_alt_output_60t` | 62 × 62 × 15 |
| `alt_output_spacer` | 12 × 12 × 10.05 |

Visual checks used isometric, top, bottom, front and right views plus center X/Y sections.

## Assembly QA

The ALT subsystem was inspected with:

- actual drive-side yoke arm envelope;
- 608 / Ø8 shaft axis;
- motor body envelope behind the plate;
- plate, all three gears, spacer and transparent guard.

The combined yoke + payload + ALT drive was rendered at payload angles:

- `-20°`
- `0°`
- `45°`
- `90°`

No collision was observed between the payload plate, yoke arms and fixed ALT gearbox in those positions.

## Defects found by visual QA and corrected

### Detached guard/plate lug

The first iteration placed the lower motor-side guard screw lug tangent to the main outline. CGAL still produced a valid object, but mesh component inspection showed two disconnected printable components. The screw location was moved inward to overlap the main body. Final plate and guard both have exactly one connected component.

### Yoke screw-head / lower gear clearance

One yoke mounting screw lies close to the 48T lower gear envelope. The plate therefore uses a real conical countersink for the four M3 yoke screws; their heads must finish flush with the plate.

### Output-hub service access

The initial radial set-screw height would have placed the screw center inside the guard roof plane. The hub was extended to 15 mm and set-screw pilots moved above the roof so they remain accessible after guard installation.

### ALT shaft length

The original ~150 mm shaft did not provide enough drive-side projection for the final spacer + output gear + clamp hub stack. `ALT_SHAFT_L` is now 165 mm.

## Still requires physical verification

CAD/visual QA cannot validate printed friction, material creep or the exact dimensions of clone motors. Before production print verify:

- actual 28BYJ-48 shaft/flange dimensions;
- Double-D pinion fit;
- M3 shoulder axle fit and free compound-gear rotation;
- Ø8.20 output bore and Ø12 spacer on the real shaft;
- tapped M3 output-hub pilots or optional insert geometry;
- gear backlash after printing in the selected material and orientation.
