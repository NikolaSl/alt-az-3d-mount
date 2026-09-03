# AltAz 28BYJ-48 OpenSCAD Mount

Параметрична, 3D-печатаема **алт-азимутална монтировка** за телефон, малка камера или компактна оптика. И двете оси използват 28BYJ-48 и печатаем допълнителен **20:1** редуктор (`12T → 48T/12T → 60T`). Проектната цел е добре балансиран товар под 1 kg.

> **Статус: core mechanical CAD + corrected payload attachment + full modeled state-space QA PASS.** Tripod/tabletop mount structure е CAD-интегрирана. Production print остава блокиран от реалните hardware dimensions, printer fit calibration, physical dry-fit/load verification и конкретния payload/cable envelope.

## Resume / mobile-review entry points

Repository-то е постоянната инженерна памет; chat history не е source of truth. При нов чат чети:

1. [`REPOSITORY_CONTRACT.md`](REPOSITORY_CONTRACT.md)
2. [`DESIGN_PROTOCOL.md`](DESIGN_PROTOCOL.md)
3. [`MECHANICAL_INTEGRITY_PROTOCOL.md`](MECHANICAL_INTEGRITY_PROTOCOL.md) — solid-body relations, supports, fasteners, real DOF/constraint chains, load paths;
4. [`MOTION_QA_PROTOCOL.md`](MOTION_QA_PROTOCOL.md) — operational + adjustment/configuration state-space QA;
5. [`BROWSER_REVIEW_PROTOCOL.md`](BROWSER_REVIEW_PROTOCOL.md)
6. [`PROJECT_STATE.md`](PROJECT_STATE.md)
7. [`PARTS.md`](PARTS.md)
8. [`INTERFACES.md`](INTERFACES.md) — `I-*`, `R-*`, `K-*`, `M-*` contracts;
9. [`ASSEMBLY.md`](ASSEMBLY.md)
10. [`CALIBRATION.md`](CALIBRATION.md)
11. [`docs/motion-qa-results.md`](docs/motion-qa-results.md)
12. [`src/config.scad`](src/config.scad).

## Основна конструкция

- AZ: 28BYJ-48 + 20:1 reducer + 120 mm turntable.
- ALT: 2×608ZZ, smooth Ø8×165 mm steel shaft, external 28BYJ-48 + 20:1 reducer.
- Bearings/support surfaces carry payload; motor/gear shafts transmit torque only.
- Raised payload plate on split shaft clamps.
- Sliding 1/4-20 payload screw for **manual balancing**.
- 1/4-20 tripod interface.
- Optional removable Ø190 mm tabletop base.
- Removable gearbox guards/serviceable gears.

## Important payload correction

Browser review found that the original hand knob intersected the horizontal ALT shaft. The corrected geometry raises the plate using the upper split-clamp halves as 15 mm structural risers, preserving the full balance slot:

```text
ALT shaft top Z          4 mm
knob bottom Z            7 mm
plate underside Z       15 mm
knob→shaft design gap    3 mm
```

QA now models the printed knob **and the actual metal 1/4-20 bolt envelope**, so hidden same-transform interference cannot be dismissed by combining the whole payload stage into one collision body.

## Mechanical integrity rules

The project now uses the same reusable rules transferred to `ai-openscad-template`:

```text
unclassified physical solid overlap = forbidden
intentional contact / fit / passage = explicit contract
same-transform internal bodies still need collision QA
all relevant operational + adjustment/configuration states are checked
claimed motion requires a real physical constraint chain
supports / retention / fasteners / load paths are part of QA
manual/operator constraints must be explicit, not assumed away
```

A CAD `rotate()`/`translate()` does not make a real body follow that trajectory. `INTERFACES.md` records how actual shafts, bearings, guides, retaining features and fasteners remove unwanted rigid-body DOFs.

Current principal constraints:

- `K-001`: AZ via M8 central datum + turntable/PTFE support + axial retention;
- `K-002`: ALT via Ø8 shaft + two separated 608ZZ + axial retention;
- `K-003`: payload balance is a **manual setup state** — the slot constrains the screw-center coordinate, while one loose screw still permits payload yaw; operator controls it until tightening locks the final pose.

If self-guided/repeatable payload translation is ever required, add a second locator/anti-rotation guide/rail and re-QA it as a real mechanism DOF.

## Current accepted QA checkpoint

See [`docs/motion-qa-results.md`](docs/motion-qa-results.md).

Motion/state-space workflow run `33772135101`: **PASS**.

```text
ALT structural sweep
  -20° .. +90° every 1° = 111 states
  minimum payload→upper = 6.0 mm
  minimum payload→lower = 43.0 mm
  0.5 mm expanded lower remains 42.5 mm clear

payload screw-center manual adjustment
  -12.600 .. +28.600 mm every 0.500 mm = 84 states
  fastener→ALT shaft min = 3.000 mm (required 3.000)
  fastener→split clamps min = 2.800 mm (required 2.000)

coupled adjustable-fastener grid
  111 ALT × 84 slider = 9,324 states per obstruction
  3 obstruction envelopes = 27,972 collision queries
  forbidden collisions = 0

AZ actual assembly
  0° .. 360° every 10° = 37 compile poses
  coupled AZ/ALT = 32 configurations
  slider endpoint critical full-assembly checks = 6
  review renders = 14
```

Payload visual/geometric regression run `33772448736`: **PASS**. Changed elementary parts are `Simple: yes`, watertight, single-component, with seven standard views + X/Y/Z sections. A browser-reviewable Y-Z cut through the shaft/fastener is available as:

```text
src/assemblies/payload_adjustment_section.scad
```

## QA scope

The automated state-space PASS proves the modeled **mount structure + payload attachment hardware**. It does **not** prove an arbitrary phone/camera/optic, adapter or cable envelope.

Before a specific payload is approved for unattended full-range motion:

```text
model conservative payload + adapter + cable envelope
OR
restrict and physically verify the allowed movement range
```

Future asymmetric fixed cables/connectors/electronics/hard stops invalidate the current AZ symmetry proof until modeled/re-QA'd.

## QA pipeline

```text
requirements + load cases
→ complete part decomposition
→ interface + solid-relationship graph
→ constraint/DOF + support/load-path register
→ shared parameters/datums
→ elementary part
→ full mesh/visual/section QA
→ realistic hardware + neighboring context
→ pairwise solid collision/clearance QA
→ assembly/support/fastener/service QA
→ complete affected operational × adjustment state-space QA
→ controlled invalidation/backtracking if needed
→ PARTS / INTERFACES / ASSEMBLY / PROJECT_STATE sync
→ human mobile review
```

Tools:

- `tools/visual_qa.py` — full part mesh/visual/section QA;
- `tools/motion_qa.py` — structural ALT + coupled AZ/ALT + ALT×payload-screw state-space collision QA;
- `tools/payload_adjustment_qa.py` — internal fastener↔shaft/clamp minimum-distance sweep;
- `.github/workflows/visual-qa.yml` and `motion-qa.yml` — reproducible CI evidence.

## Browser/mobile review

All normal CAD visualization is rendered directly in the browser:

```text
exact deployed SCAD
→ recursive dependency closure
→ SHA-256 verification
→ background Web Worker
→ pinned OpenSCAD 2025.03.25 WASM + Manifold
→ binary STL
→ Three.js
```

Heavy CAD never runs on the UI thread. The page stays responsive, shows phase/elapsed time/diagnostics and supports Cancel. There is no normal CI-prebuilt STL path; it would be reintroduced only as a measured performance exception.

## Кинематика

За всяка ос:

```text
12T → 48T = 4:1
12T → 60T = 5:1
external reduction = 20:1
```

При nominal 4096 half-steps на 28BYJ output revolution:

```text
81920 nominal half-steps / axis revolution
0.0043945° / half-step
15.82 arcsec / half-step
```

Това е command resolution, не механична точност; backlash/compliance/print tolerance/internal gearing определят реалната грешка.

## Структура

```text
REPOSITORY_CONTRACT.md          persistent engineering-memory contract
DESIGN_PROTOCOL.md              dependency-first parametric design method
MECHANICAL_INTEGRITY_PROTOCOL.md solid/support/constraint/load-path method
MOTION_QA_PROTOCOL.md           complete state-space motion/adjustment QA
BROWSER_REVIEW_PROTOCOL.md      responsive mobile source-render architecture
PROJECT_STATE.md                fresh-session checkpoint
PARTS.md                        decomposition/status ledger
INTERFACES.md                   interface / relation / constraint / state contracts
ASSEMBLY.md                     live BOM + physical sequence
CALIBRATION.md                  physical measurement/fit worksheet
src/config.scad                 shared parameters/datums
src/lib/                        reusable mechanical/hardware envelopes
src/parts/                      elementary printable parts
src/assemblies/                 subsystems/full mount/diagnostic review entries
src/calibration/                fit coupons
tools/visual_qa.py              headless visual/geometric QA
tools/motion_qa.py              multi-state FCL QA
tools/payload_adjustment_qa.py  internal adjustment solid-pair QA
tools/build_browser_manifest.py dependency-aware browser manifest
docs/motion-sweep-plan.md       project-specific state-space proof plan
docs/motion-qa-results.md       accepted QA evidence
site/openscad-worker.js         non-blocking browser renderer
site/                           mobile viewer
```

## Преди production print

Не печатай целия комплект наведнъж преди:

1. измерване на двата реални 28BYJ-48;
2. 608/Ø8 fit coupon;
3. Double-D pinion test;
4. captive-nut/M3/M4 calibration;
5. physical ALT output-hub/spacer/grub-screw test;
6. final AZ compound axle support dry-fit;
7. physical 1/4-20 payload adjustment/no-slip test;
8. actual payload + adapter + cable envelope verification;
9. full physical motion/balance test;
10. tabletop stability test.

След физическа промяна използвай invalidation map-а в `INTERFACES.md` и повтори целия засегнат state-space sweep, не само едно положение.

## Лиценз

Hardware design/OpenSCAD sources са под CERN-OHL-S-2.0, съгласно `LICENSE`.
