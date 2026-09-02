# Assembly guide and hardware BOM

Този файл е **source of truth за механичното сглобяване**. При промяна на механичен детайл трябва да се актуализират едновременно SCAD моделът, visual/assembly QA и съответната секция тук.

> **Статус:** CAD прототип с завършена двуосна кинематична верига и отделен широк tabletop adapter. AZ и ALT използват 28BYJ-48 + печатаем 20:1 редуктор. Преди production print остават физическите fit tests, реалните размери на конкретните мотори и окончателното физическо потвърждение на AZ/ALT drive interfaces.

## 1. Механична верига

```text
flat table                    photo tripod
    │                              │
    ▼                              │
tabletop_base_adapter              │
    └──── 1/4-20 attachment ───────┤
                                   ▼
                                az_base
                         ├─ captive 1/4-20 nut
                         ├─ M8 central AZ axis
                         └─ 28BYJ-48 AZ motor
                                   │
                                   ▼
                    AZ 20:1: 12T → 48T/12T → 60T
                                   │
                                   ▼
                    az_gearbox_cover → az_turntable
                                   │
                                   ▼
                            yoke_base_bridge
                               ┌────┴────┐
                               ▼         ▼
                            yoke_arm   yoke_arm
                              drive       idler
                               │  608ZZ   │  608ZZ
                               └────┬─────┘
                                    ▼
                              Ø8 × 165 mm ALT shaft
                                    │
                     ┌──────────────┴──────────────┐
                     ▼                             ▼
           payload split clamps          ALT output stack
                     │                             │
                 payload_plate            20:1 ALT reducer
                     │                             │
            1/4-20 payload screw             28BYJ-48 ALT
```

## 2. Печатни детайли

| Кол. | Файл | Роля |
|---:|---|---|
| 1 optional | `src/parts/tabletop_base_adapter.scad` | Широка Ø190 mm основа за маса/равна повърхност; сваля се при tripod use |
| 1 | `src/parts/az_base.scad` | Неподвижна основа, tripod/tabletop interface и AZ мотор |
| 1 | `src/parts/az_gearbox_cover.scad` | Корпус на AZ редуктора |
| 1 | `src/parts/az_turntable.scad` | Въртяща AZ платформа |
| 1 | `src/parts/gear_az_motor_12t.scad` | AZ motor pinion |
| 1 | `src/parts/gear_az_compound_48_12t.scad` | AZ compound gear |
| 1 | `src/parts/gear_az_output_60t.scad` | AZ output gear/hub |
| 1 | `src/parts/yoke_base_bridge.scad` | Основа на вилката |
| 1 | `src/parts/yoke_arm_drive.scad` | Drive-side рамо с 608 и ALT gearbox mounting pattern |
| 1 | `src/parts/yoke_arm_idler.scad` | Idler рамо с 608 |
| 2 | `src/parts/payload_clamp_lower.scad` | Долни половини на Ø8 shaft clamps |
| 2 | `src/parts/payload_clamp_upper.scad` | Горни половини на Ø8 shaft clamps |
| 1 | `src/parts/payload_plate.scad` | Универсална товарна платформа |
| 1 | `src/parts/camera_screw_knob.scad` | Ръкохватка за метален 1/4-20 болт |
| 1 | `src/parts/shaft_collar_8mm.scad` | Idler-side аксиално фиксиране на ALT вала |
| 1 | `src/parts/alt_gearbox_plate.scad` | Структурна ALT gearbox плоча |
| 1 | `src/parts/alt_gearbox_guard.scad` | Сваляем ALT guard + горна опора на compound axle |
| 1 | `src/parts/gear_alt_motor_12t.scad` | ALT motor pinion |
| 1 | `src/parts/gear_alt_compound_48_12t.scad` | ALT 48T/12T compound gear |
| 1 | `src/parts/gear_alt_output_60t.scad` | ALT 60T output gear с clamp hub |
| 1 | `src/parts/alt_output_spacer.scad` | Spacer от 608 inner race до ALT output gear |

Калибрационните купони не са част от крайния продукт, но се печатат преди production set:

- `src/calibration/mechanical_fit_coupon.scad`
- `src/calibration/fastener_fit_coupon.scad`
- `src/calibration/byj48_fit_coupon.scad`

Виртуалните assembly файлове не се печатат. Основните са:

- `src/assemblies/az_stage.scad`
- `src/assemblies/yoke_stage.scad`
- `src/assemblies/payload_stage.scad`
- `src/assemblies/alt_drive_stage.scad`
- `src/assemblies/full_mount.scad`
- `src/assemblies/tabletop_base_context.scad`
- `src/assemblies/tabletop_full_mount.scad`

## 3. Непечатни компоненти

### Основни механични компоненти

| Кол. | Компонент | Бележка |
|---:|---|---|
| 2 | 28BYJ-48, 5 V или 12 V | Един за AZ и един за ALT; измери реалните клонинги |
| 2 | 608ZZ, 8×22×7 mm | По един във всяко рамо |
| 1 | Гладък стоманен вал Ø8 × **165 mm** | ALT ос; може да се отреже от по-дълъг прът |
| 1 | M8 гайка | Captive в `az_base` |
| 1 | M8 шпилка/болт ~50 mm | Централна AZ ос; final length след dry-fit |
| 1 | M8 low-profile/Nyloc гайка + шайба | Горна фиксация на turntable |
| 1 | 1/4-20 UNC гайка | Captive tripod/tabletop гайка в `az_base` |
| 1 optional | 1/4-20 UNC bolt ~1/2" | Tabletop adapter към `az_base`; exact head/length се потвърждават с dry-fit |
| 4 optional | Ø~18 mm adhesive rubber feet/pads | В recess-ите отдолу на tabletop adapter |
| 1 | 1/4-20 UNC болт 3/4"–1" | Payload screw в `camera_screw_knob` |
| 3 | Малки PTFE лепенки/лента | Върху AZ glide pads |
| 1 | Пластмасово-съвместима грес / dry PTFE | Само тънък слой върху зъбите |
| 1 | Medium threadlocker | Само върху metal-to-metal резби |

### AZ крепеж

| Кол. | Крепеж | Къде |
|---:|---|---|
| 4 | M3×20 + M3 гайки | `az_gearbox_cover` към `az_base` |
| 4 | M3×12 + M3 гайки | `az_turntable` към AZ 60T hub |
| 1 | M3 shoulder/plain-shank axle, length TBD | AZ compound gear; виж `HOLD-AZ-AXLE` |
| 4 | M4×16 + M4 гайки | `yoke_base_bridge` към turntable |
| 2 | M4×40–45 + Nyloc + шайби | Заключване на yoke arms в bridge |
| 2 | M4×8–12 + гайки/шайби | AZ 28BYJ-48; според конкретния фланец |

### Payload / ALT крепеж

| Кол. | Крепеж | Къде |
|---:|---|---|
| 4 | M3×25 + 4 M3 гайки | Двете split clamps + payload plate |
| 1 | M3×6 grub screw | `shaft_collar_8mm`; pilot се пробива/метчи M3 |
| 4 | **M3×12 countersunk** | `alt_gearbox_plate` към captive M3 nuts в `yoke_arm_drive` |
| 2 | M4×10–12 + 2 M4 гайки | ALT 28BYJ-48 към gearbox plate |
| 1 | M3 shoulder screw ~22 mm + 1 M3 гайка | ALT compound axle; plate + guard дават две опори |
| 4 | M3×20 + 4 M3 гайки | ALT guard към gearbox plate |
| 2 | M3×6 grub screws | ALT output hub към Ø8 shaft |
| 0–2 | M3 heat-set inserts, optional | По-здрав вариант вместо tapped plastic за output hub |

Дължините са начални. При първия физически dry-fit се коригират с една стандартна дължина нагоре/надолу, ако конкретните глави/гайки го изискват.

## 4. Задължителни fit tests преди голям печат

Подробният worksheet и точните позиции/размери са в `CALIBRATION.md`.

1. Измери с шублер двата 28BYJ-48 поотделно: body, boss, shaft, flat, mount spacing и hole diameter.
2. Измери реалните 608 и Ø8 вала.
3. Принтирай `src/calibration/mechanical_fit_coupon.scad` за 608 и Ø8 shaft fits.
4. Принтирай `src/calibration/fastener_fit_coupon.scad` за M3/M4 holes, nut traps, 1/4-20 и M8 pockets.
5. Принтирай `src/calibration/byj48_fit_coupon.scad` за motor mount pattern и Double-D shaft clearance.
6. Запиши raw results в `CALIBRATION.md` преди промени в `src/config.scad`.
7. Провери Ø8.20 bore на ALT output gear и spacer върху реалния вал след избора от coupon-а.
8. Провери M3 pilot/tap в малък пробен детайл преди да метчиш output hub-а.
9. Почисти elephant-foot и support остатъци от mating surfaces.

## 5. Сглобяване — base / tabletop / AZ

### A0. Tabletop adapter — optional flat-surface mode

Пропусни тази секция при директен монтаж на фотографски статив.

1. Постави 4 adhesive rubber feet Ø~18 mm в долните recess-и на `tabletop_base_adapter`.
2. Постави `az_base` pedestal-а в плиткия Ø49 mm locator отгоре на adapter-а. Locator-ът е 1.5 mm дълбок и не трябва да изисква натиск.
3. Прекарай 1/4-20 bolt отдолу през централния отвор на tabletop adapter-а и го завий в captive 1/4-20 nut в `az_base`.
4. Главата на болта трябва да остане изцяло под нивото на долната повърхност/крачетата; текущият counterbore е Ø16×5 mm.
5. Началната препоръка е приблизително 1/2" under-head length. Използвай най-късия болт, който получава достатъчно thread engagement и **не** навлиза към M8 AZ hardware в pedestal-а.
6. Стегни само колкото да няма странично приплъзване между adapter-а и pedestal locator-а.
7. Провери на равна повърхност, че основата не се клати и че Ø190 support footprint остава изцяло в контакт чрез rubber pads.

Browser/context QA entry points:

```text
src/assemblies/tabletop_base_context.scad
src/assemblies/tabletop_full_mount.scad
```

### A. Tripod / shared 1/4-20 interface

1. Вкарай 1/4-20 metal nut през страничния канал на `az_base`.
2. Провери с 1/4-20 screw, че гайката не се върти.
3. За tripod mode махни tabletop adapter-а и завий tripod screw директно в същата captive nut.

### B. Централна AZ ос

1. Зареди captive M8 гайката.
2. Завий M8 shaft/stud вертикално през `az_base`.
3. Настрой височината при dry-fit; threadlocker чак след окончателното сглобяване.

### C. AZ мотор и 20:1 reducer

1. Монтирай AZ 28BYJ-48 отдолу.
2. Постави 12T Double-D pinion.
3. Постави 48T/12T compound gear на междинната ос.
4. Постави 60T output gear около M8 оста.
5. Провери двете gear planes: 12↔48 и 12↔60.
6. Завърти motor shaft на ръка няколко оборота и търси binding/periodic tight spots.
7. Сложи минимално количество lubricant.

### D. AZ cover и turntable

1. Закрепи `az_gearbox_cover` с 4×M3.
2. Добави PTFE върху трите glide pads.
3. Свържи AZ 60T hub към `az_turntable` с 4×M3.
4. Постави M8 washer + top nut.
5. Стегни само до отстраняване на axial play; turntable трябва да се върти свободно.

## 6. Сглобяване — yoke и payload

### E. Yoke

1. `yoke_base_bridge` към turntable с 4×M4.
2. Press-fit по един 608ZZ от външната страна на двете рамена.
3. Вкарай drive и idler arm в bridge slots.
4. Заключи всеки arm с M4 transverse bolt + Nyloc.
5. Провери коаксиалността на двата 608 преди да вкарваш shaft-а насила.

### F. ALT shaft и payload

1. Прекарай гладкия Ø8×165 mm вал през двата 608.
2. Монтирай двете split clamps симетрично върху вала.
3. Постави `payload_plate` и затегни 4×M3 постепенно.
4. Постави idler-side `shaft_collar_8mm`, но остави малък axial endplay.
5. Постави 1/4-20 bolt в `camera_screw_knob` и през longitudinal slot-а на payload plate.

## 7. Сглобяване — ALT 20:1 drive

ALT gearbox е фиксиран към **външната страна на `yoke_arm_drive`**. Gear ratio е:

```text
12T motor → 48T = 4:1
12T compound → 60T = 5:1
общо = 20:1
```

### G. Подготовка на ALT gearbox plate

1. В back-side pockets на `alt_gearbox_plate` постави 4×M3 гайки за guard screws.
2. Постави още една M3 гайка в pocket-а на compound axle.
3. Монтирай втория 28BYJ-48 **зад** plate-а; shaft-ът трябва да сочи през plate-а навън.
4. Закрепи мотора с 2×M4 и гайки. Гайките от gear side са далеч от gear envelopes.
5. Постави `gear_alt_motor_12t` върху Double-D shaft-а. Motor shaft има достатъчна дължина за 5 mm gear face след 3.2 mm plate.

### H. Plate към drive arm

1. Увери се, че 608 е напълно seated.
2. Централният Ø24 opening на plate-а трябва да оставя bearing face-а свободен.
3. Постави plate-а върху външната страна на `yoke_arm_drive`.
4. Използвай 4× **M3 countersunk** screws към captive nuts в arm-а.
5. Главите трябва да са flush. Това е важно: lower 48T gear минава близо до един от тези screw positions.

### I. Output shaft stack

1. Върху drive-side края на Ø8 shaft постави `alt_output_spacer`.
2. Spacer OD е 12 mm и трябва да опира **само в inner race на 608**.
3. Постави `gear_alt_output_60t` след spacer-а.
4. Засега не стягай двата radial set screws.
5. Проверка: при 165 mm вал има достатъчно drive-side projection за spacer + 60T gear + 15 mm clamp hub.

### J. Compound gear и guard

1. Постави `gear_alt_compound_48_12t` на неговия center distance спрямо output gear и motor pinion.
2. Постави `alt_gearbox_guard` върху plate-а.
3. Прекарай M3 shoulder screw от guard roof през горния journal и през compound gear до captive M3 nut в plate-а.
4. Стегни stationary axle-а, без да притискаш compound gear аксиално. Gear-ът трябва да се върти свободно върху гладката част на shoulder screw.
5. Закрепи guard-а с 4×M3×20.
6. Guard roof оставя минимум 2 mm axial clearance над gear stack-а.

### K. ALT output clamp и gear mesh

1. Притисни 60T gear леко към spacer-а, без preload върху 608.
2. Проверявай едновременно mesh-а 12→48 и 12→60 чрез бавно въртене на motor shaft-а.
3. Когато gear planes са правилни, метчи двата radial pilot holes M3 (или постави подходящи inserts след test coupon).
4. Постави 2×M3×6 grub screws. Поне единият е добре да стъпва върху малък flat на Ø8 shaft-а.
5. Grub-screw centers са над gearbox roof-а, така че остават достъпни след поставяне на guard-а.
6. Завърти механизма ръчно през поне няколко output degrees и провери за tight spots.

## 8. Балансиране

1. Преди powered ALT test изключи мотора и провери свободното движение.
2. Плъзни 1/4-20 payload screw по slot-а така, че CG да е възможно най-близо до ALT shaft.
3. Цел: residual CG offset приблизително ≤10–15 mm при тежък payload.
4. Ако slot travel не стига, премести phone/optic adapter чрез M4 pattern или добави малка противотежест.

## 9. Механични тестове преди захранване

- [ ] Tabletop mode: adapter-ът не се клати, bolt head не опира в масата и pedestal locator няма страничен луфт извън проектния clearance.
- [ ] Tabletop mode: с payload в най-неблагоприятната използвана ALT позиция няма тенденция към преобръщане; не приемай CAD footprint-а като доказателство за stability с неизвестен реален CG.
- [ ] AZ прави 360° без binding.
- [ ] AZ turntable няма забележим radial wobble.
- [ ] Yoke bridge не се движи спрямо turntable.
- [ ] Двете yoke arms са успоредни.
- [ ] Ø8 ALT shaft се върти свободно през двата 608.
- [ ] Spacer контактува само с drive-side 608 inner ring.
- [ ] ALT 60T output gear няма axial rubbing в plate/guard.
- [ ] ALT compound gear има две опори на stationary axle-а: plate + guard roof.
- [ ] ALT motor body не докосва yoke arm.
- [ ] Payload plate не докосва arms/gearbox при -20°, 0°, 45° и 90°.
- [ ] Всички кабели са извън gear paths.
- [ ] Payload е балансиран.

Powered tests: без товар → ~250 g → ~500 g → постепенно към проектния максимум под 1 kg.

## 10. QA правило

Всеки mechanical commit е готов само ако:

1. всеки нов printable SCAD се export-ва с full CGAL;
2. OpenSCAD дава `Simple: yes`;
3. STL е watertight и има един connected printable component;
4. има ISO/top/bottom/front/right visual QA + сечения, когато са смислени;
5. assembly QA проверява колизии с вече съществуващите части;
6. `full_mount.scad`/relevant full assembly се проверява поне при ALT = -20°, 0°, 45°, 90° за motion-sensitive changes;
7. този `ASSEMBLY.md` е актуализиран.

Последният ALT CAD QA премина за plate, guard, 12T, 48T/12T, 60T и spacer: `Simple: yes`, watertight, един connected component на детайл. Assembly QA при -20°/0°/45°/90° не показа колизия между payload plate, yoke и ALT gearbox.

Tabletop adapter CAD QA: `src/parts/tabletop_base_adapter.scad` мина full CGAL с `Simple: yes`, watertight STL и един connected printable component; bounds 190×190×8 mm. Context render с реалния `az_base` потвърди позиционирането на pedestal-а в locator-а и отделния bolt path. Пълният `tabletop_full_mount.scad` е публикуван за browser human review.

Calibration coupon QA е описан в `docs/calibration-qa.md`.

## 11. Оставащи HOLD / VERIFY точки

### HOLD-AZ-AXLE

AZ compound axle трябва да се замрази след физически fit test като двустранно поддържана гладка/shoulder ос. Не използвай дълъг свободно конзолен винт.

### VERIFY-ALT-DRIVE

ALT drive е завършен в CAD и visual QA, но трябва физически fit test на: motor shaft, Double-D pinion, M3 shoulder axle, Ø8 output bore/spacer и grub-screw clamp. След него размерите се замразяват.

### HOLD-MOTOR-DIMS

Въведи реалните размери на конкретните 28BYJ-48 преди production print. Използвай `CALIBRATION.md` и `src/calibration/byj48_fit_coupon.scad`.

### HOLD-PRINT-FITS

`FIT` и `PRESS_FIT` се калибрират за конкретния printer/material/orientation чрез трите `src/calibration/*_coupon.scad` преди целия комплект.

### VERIFY-TABLETOP-STABILITY

Ø190 tabletop footprint е CAD решение за flat-surface mode, не доказателство за устойчивост при произволен 1 kg товар. След physical assembly провери реалния CG, rubber-foot contact и overturn margin с конкретния payload преди unattended use.
