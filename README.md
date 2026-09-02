# AltAz 28BYJ-48 OpenSCAD Mount

Параметрична, 3D-печатаема **алт-азимутална монтировка** за телефон, малка камера или компактна оптика. И двете оси използват 28BYJ-48 и допълнителен печатаем **20:1** редуктор (`12T → 48T/12T → 60T`). Проектната цел е добре балансиран товар под 1 kg.

> **Статус: core mechanical CAD + structural two-axis motion QA PASS.** Tripod и tabletop assemblies са завършени на CAD ниво. Production print остава блокиран от реалните motor dimensions, printer fit calibration и физически fit/dry-fit tests. Виж `PROJECT_STATE.md`, `docs/motion-qa-results.md` и `ASSEMBLY.md`.

## Resume / mobile-review entry points

Този repository е постоянната инженерна памет на проекта; историята на чата не е source of truth. При нов чат или ново устройство започни от:

1. [`REPOSITORY_CONTRACT.md`](REPOSITORY_CONTRACT.md) — задължителното правило за continuity, integration, browser review и live BOM/assembly;
2. [`DESIGN_PROTOCOL.md`](DESIGN_PROTOCOL.md) — общият алгоритъм за параметрично проектиране, QA и controlled backtracking;
3. [`MOTION_QA_PROTOCOL.md`](MOTION_QA_PROTOCOL.md) — задължителният full-range QA protocol за механизми с движещи се части;
4. [`BROWSER_REVIEW_PROTOCOL.md`](BROWSER_REVIEW_PROTOCOL.md) — reusable mobile/browser CAD review architecture: prebuilt assembly previews + non-blocking worker re-render;
5. [`PROJECT_STATE.md`](PROJECT_STATE.md) — кратък текущ checkpoint за възстановяване на работата;
6. [`PARTS.md`](PARTS.md) — пълна декомпозиция, stable part IDs, dependency/status ledger;
7. [`INTERFACES.md`](INTERFACES.md) — stable interface IDs, механични contracts и invalidation map;
8. [`ASSEMBLY.md`](ASSEMBLY.md) — текущ printable list, non-printed BOM и пълна последователност за физическо сглобяване;
9. [`CALIBRATION.md`](CALIBRATION.md) — измервания и physical-fit процедура;
10. [`docs/motion-qa-results.md`](docs/motion-qa-results.md) — последният приет motion-QA checkpoint;
11. [`src/config.scad`](src/config.scad) — общите размери, fits, hardware envelopes и datums.

GitHub Pages browser validator е mobile-first review surface. Скъпите assembly модели се prebuild-ват в GitHub Actions от точния deployed commit и се зареждат като готов STL за бърз преглед. При нужда **Re-render in browser** изпълнява независим OpenSCAD WebAssembly compile в background Web Worker с Manifold backend; страницата остава responsive, показва phase + elapsed time + diagnostics и има Cancel. Manifest-ът монтира само recursive dependency closure на избрания SCAD, така че добавянето на несвързани файлове не забавя всеки render.

## Основна конструкция

- AZ: 28BYJ-48 + 20:1 reducer + 120 mm turntable.
- ALT: два 608ZZ лагера, гладък Ø8×165 mm вал, 28BYJ-48 + 20:1 reducer от външната страна на drive arm.
- Лагерите носят payload-а; motor shafts предават само въртящ момент.
- Плъзгащ 1/4-20 UNC payload screw за балансиране.
- 1/4-20 UNC tripod interface в основата.
- Optional removable Ø190 mm tabletop base.
- Removable gearbox guards и отделни serviceable gears.

## Кинематика

За всяка ос:

```text
12T → 48T = 4:1
12T → 60T = 5:1
external reduction = 20:1
```

При условни `4096` half-steps на изходен оборот на 28BYJ-48:

```text
81920 nominal half-steps / axis revolution
0.0043945° / half-step
15.82 arcsec / half-step
```

Това е **command resolution, не механична точност**. Реалната грешка ще се определя от backlash, elastic compliance, internal 28BYJ gearing и print tolerances.

## QA pipeline

Всяка механична итерация следва:

```text
SCAD
  → full CGAL STL render
  → Simple: yes + watertight + expected connected components
  → standard orthographic/isometric views
  → adaptive X/Y/Z and critical-interface sections
  → neighboring-part context QA
  → assembly QA
  → full-range motion/collision QA when motion envelopes are affected
  → PARTS/INTERFACES/ASSEMBLY/PROJECT_STATE update as affected
```

`tools/visual_qa.py` автоматизира individual-part QA. `tools/motion_qa.py` извършва автоматизиран sampled collision/distance sweep с OpenSCAD diagnostic meshes + `trimesh/python-fcl`.

`src/assemblies/full_mount.scad` и `src/assemblies/tabletop_full_mount.scad` приемат и двете оси:

```bash
openscad -D AZ_ANGLE=135 -D ALT_ANGLE=45 \
  src/assemblies/tabletop_full_mount.scad
```

### Приет structural motion-QA checkpoint

Последният приет checkpoint е описан в `docs/motion-qa-results.md`:

```text
ALT: -20° .. +90° every 1° = 111 poses
collisions: 0
minimum payload → upper structure: 6.0 mm @ -20°
minimum payload → conservative lower envelope: 43.0 mm @ +90°
0.5 mm expanded lower envelope: 42.5 mm remaining

AZ actual assembly: 0° .. 360° every 10° = 37 poses
coupled AZ/ALT grid: 32 configurations
representative rendered poses: 10
result: PASS
```

Текущият AZ structural collision proof използва rotational symmetry на lower mechanical envelope. Бъдещи асиметрични cables/connectors/electronics/hard stops инвалидира този proof и изискват нов motion sweep.

## Структура

```text
REPOSITORY_CONTRACT.md          persistent-memory / mobile workflow contract
DESIGN_PROTOCOL.md              reusable parametric mechanical design method
MOTION_QA_PROTOCOL.md           reusable full-range moving-mechanism QA method
BROWSER_REVIEW_PROTOCOL.md      reusable responsive browser/mobile CAD review method
PROJECT_STATE.md                fresh-chat resume checkpoint
PARTS.md                        decomposition + dependency/status ledger
INTERFACES.md                   interface contracts + invalidation map
ASSEMBLY.md                     live printable list, hardware BOM, assembly sequence
CALIBRATION.md                  measurement and physical-fit worksheet
src/config.scad                 shared parameters and datums
src/lib/                        gears и reusable mechanical modules
src/parts/                      elementary printable parts
src/assemblies/                 subsystem, full-mount and QA diagnostic assemblies
src/calibration/                calibration coupons
tools/visual_qa.py              headless mechanical visual QA
tools/motion_qa.py              sampled mesh collision/distance motion QA
tools/build_browser_manifest.py dependency-aware browser source manifest
tools/prebuild_browser_previews.py CI preview builder for expensive assemblies
docs/visual-qa.md               visual QA policy
docs/motion-sweep-plan.md       project-specific movement coverage plan
docs/motion-qa-results.md       accepted motion-QA checkpoint evidence
site/openscad-worker.js         non-blocking browser OpenSCAD renderer
site/                           mobile browser viewer and exact source snapshot
```

## Важни непечатни части

- 2× 28BYJ-48
- 2× 608ZZ (8×22×7 mm)
- Ø8×165 mm smooth steel shaft за ALT
- M3/M4 fasteners, M8 AZ stud, 1/4-20 tripod/payload hardware
- PTFE glide pads за AZ
- optional rubber feet + 1/4-20 bolt for tabletop base

Точните количества, началните screw lengths и редът на сглобяване са в **`ASSEMBLY.md`**. Stable part IDs и текущият status са в **`PARTS.md`**; размерните/механичните contracts между тях са в **`INTERFACES.md`**.

## Преди production print

Не печатай целия комплект наведнъж преди:

1. измерване на конкретните 28BYJ-48;
2. 608 / Ø8 shaft fit coupon;
3. Double-D pinion test;
4. captive-nut / M3 / M4 calibration;
5. физически ALT output-hub/grub-screw test;
6. окончателно решение/потвърждение за двустранната AZ compound axle support;
7. physical full-range motion/balance test;
8. tabletop stability test при използване на tabletop mode.

След всяка физическа промяна използвай invalidation map-а в `INTERFACES.md`, за да определиш кои part IDs и motion contracts трябва да бъдат маркирани `NEEDS_REVALIDATION` и QA-нати отново.

## Лиценз

Хардуерният дизайн и OpenSCAD файловете са под CERN-OHL-S-2.0, съгласно `LICENSE`.
