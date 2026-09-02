# AltAz 28BYJ-48 OpenSCAD Mount

Параметрична, 3D-печатаема **алт-азимутална монтировка** за телефон, малка камера или компактна оптика. И двете оси използват 28BYJ-48 и допълнителен печатаем **20:1** редуктор (`12T → 48T/12T → 60T`). Проектната цел е добре балансиран товар под 1 kg.

> **Статус: двуосен CAD прототип.** AZ, yoke, payload и моторизиран ALT drive вече имат отделни printable parts и virtual assemblies. Production print остава блокиран от реалните motor dimensions, printer fit calibration и физически fit tests. Виж `ASSEMBLY.md`.

## Resume / mobile-review entry points

Този repository е постоянната инженерна памет на проекта; историята на чата не е source of truth. При нов чат или ново устройство започни от:

1. [`REPOSITORY_CONTRACT.md`](REPOSITORY_CONTRACT.md) — задължителното правило за continuity, integration, browser review и live BOM/assembly;
2. [`DESIGN_PROTOCOL.md`](DESIGN_PROTOCOL.md) — общият алгоритъм за параметрично проектиране, QA и controlled backtracking;
3. [`PROJECT_STATE.md`](PROJECT_STATE.md) — кратък текущ checkpoint за възстановяване на работата;
4. [`ASSEMBLY.md`](ASSEMBLY.md) — текущ printable list, non-printed BOM и пълна последователност за физическо сглобяване.

GitHub Pages browser validator публикува `src/` и позволява OpenSCAD WebAssembly render + интерактивен STL review от обикновен телефон/таблет. Browser publication е част от integration gate за нови части и subsystem assemblies.

## Основна конструкция

- AZ: 28BYJ-48 + 20:1 reducer + 120 mm turntable.
- ALT: два 608ZZ лагера, гладък Ø8×165 mm вал, 28BYJ-48 + 20:1 reducer от външната страна на drive arm.
- Лагерите носят payload-а; motor shafts предават само въртящ момент.
- Плъзгащ 1/4-20 UNC payload screw за балансиране.
- 1/4-20 UNC tripod interface в основата.
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

## Visual QA

Всяка механична итерация следва:

```text
SCAD
  → full CGAL STL render
  → Simple: yes + watertight + one connected printable component
  → ISO/top/bottom/front/right renders
  → sections where useful
  → assembly/collision QA
  → ASSEMBLY.md update
```

`tools/visual_qa.py` автоматизира individual-part QA. `src/assemblies/full_mount.scad` е текущият пълен виртуален assembly и поддържа command-line `ALT_ANGLE`, например:

```bash
openscad -D ALT_ANGLE=45 src/assemblies/full_mount.scad
```

ALT assembly е визуално проверен при `-20°`, `0°`, `45°` и `90°`.

## Структура

```text
src/config.scad                 общи параметри
src/lib/                        gears и reusable mechanical modules
src/parts/                      отделни printable parts
src/assemblies/                 subsystem и full-mount assemblies
tools/visual_qa.py              headless mechanical visual QA
ASSEMBLY.md                     hardware BOM + exact assembly sequence
docs/visual-qa.md               QA policy
```

## Важни непечатни части

- 2× 28BYJ-48
- 2× 608ZZ (8×22×7 mm)
- Ø8×165 mm smooth steel shaft за ALT
- M3/M4 fasteners, M8 AZ stud, 1/4-20 tripod/payload hardware
- PTFE glide pads за AZ

Точните количества, началните screw lengths и редът на сглобяване са в **`ASSEMBLY.md`** — той е механичният source of truth.

## Преди production print

Не печатай целия комплект наведнъж преди:

1. измерване на конкретните 28BYJ-48;
2. 608 / Ø8 shaft fit coupon;
3. Double-D pinion test;
4. captive-nut / M3 / M4 calibration;
5. физически ALT output-hub/grub-screw test;
6. окончателно решение за двустранната AZ compound axle support.

## Лиценз

Хардуерният дизайн и OpenSCAD файловете са под CERN-OHL-S-2.0, съгласно `LICENSE`.
