# Mechanical interface, solid-body and constraint contracts

This file is the **interaction/interface source of truth** for the current machine. A part owns local geometry; this document owns contracts between parts, relevant physical solid-body relationships, and the constraint chains that make intended motions physically realizable.

Stable IDs are used for interfaces (`I-*`), constraints (`K-*`) and motion/adjustment states (`M-*`). `src/config.scad` owns numeric shared parameters. `PARTS.md` owns part identity/status. `ASSEMBLY.md` owns physical build sequence and hardware quantities.

## Contract rules

1. IDs are stable and must not be silently reused for a different meaning.
2. A dimension shared by two or more parts has one owner in `src/config.scad` or a purchased-hardware envelope.
3. Downstream parts derive from contracts; they do not independently redefine them.
4. Changing a contract invalidates every dependent part/QA checkpoint until revalidated.
5. `CAD_VALIDATED` does not imply physical fit/strength validation.
6. Printer fits, motor clone dimensions, bearings, shafts and purchased fasteners remain `PHYSICAL_PENDING` until measured/tested.
7. If no explicit relationship permits contact/fit/passage/embedding, physical solids default to **forbidden overlap**.
8. Bodies sharing the same operational transform still require internal interference checks.
9. A CAD `rotate()`/`translate()` is not a mechanism: each intended DOF requires a physical constraint chain that removes the unwanted DOFs.

## Interface register

| ID | Side A | Side B | Contract | Primary parameter owner | CAD status | Physical status |
|---|---|---|---|---|---|---|
| `I-001` | tripod / support | `P-AZ-BASE` | 1/4-20 UNC captive support interface; base restrains nut rotation and accepts screw entry from below | `TRIPOD_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-002` | `P-AZ-BASE` | `H-AZ-AXIS` / `P-AZ-TURNTABLE` | M8 central AZ axis; turntable rotates about common Z datum; axial retention removes gross play without binding | `M8_CLEARANCE_D`, AZ datums | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-003` | `H-AZ-MOTOR` | `P-AZ-BASE` | 28BYJ-48 mounting envelope and shaft datum fixed in AZ base | `BYJ_*`, `REDUCER_MOTOR*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-004` | `H-AZ-MOTOR` | `P-AZ-PINION` | 12T pinion fits actual 28BYJ-48 Double-D shaft and transmits torque without slip | `BYJ_SHAFT_*`, `AZ_MOTOR_PINION_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-005` | `P-AZ-PINION` | `P-AZ-COMPOUND` | 12T→48T involute mesh, 4:1, common gear plane and designed backlash | `GEAR_*`, `CD_STAGE1` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-006` | `P-AZ-COMPOUND` | `P-AZ-BASE` / `P-AZ-COVER` / `H-AZ-COMPOUND-AXLE` | Compound gear rotates on mechanically sound smooth/shoulder axle support; no long unsupported cantilever screw | `INTERMEDIATE_AXLE_D`, AZ reducer datums | `CAD_PROVISIONAL` | `HOLD-AZ-AXLE` |
| `I-007` | `P-AZ-COMPOUND` | `P-AZ-OUTPUT` | 12T→60T involute mesh, 5:1, correct axial gear plane | `GEAR_*`, `CD_STAGE2` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-008` | `P-AZ-OUTPUT` | `P-AZ-TURNTABLE` | Output hub locates/drives turntable through 4×M3 pattern; no unintended axial preload | `AZ_OUTPUT_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-009` | `P-AZ-BASE` / cover | `P-AZ-TURNTABLE` | Three PTFE glide points carry rotating-stage load; cover clearance avoids rubbing while limiting wobble | `AZ_GLIDE_*`, `AZ_COVER_CLEARANCE` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-010` | `P-AZ-TURNTABLE` | `P-YOKE-BRIDGE` | Fixed 4×M4 bridge mount centered on AZ stage | `AZ_YOKE_MOUNT_*`, `YOKE_BRIDGE_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-011` | `P-YOKE-BRIDGE` | `P-YOKE-DRIVE` | Drive arm tenon/slot + transverse lock; arm datum establishes one side of ALT axis | `YOKE_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-012` | `P-YOKE-BRIDGE` | `P-YOKE-IDLER` | Idler arm tenon/slot + lock; remains parallel/coaxial with drive arm | `YOKE_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-013` | `P-YOKE-DRIVE` | `H-608-DRIVE` | 608ZZ pocket supports drive-side ALT axis; bearing seats fully and remains serviceable | `BEARING_608_*`, `YOKE_BEARING_POCKET_DEPTH` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-014` | `P-YOKE-IDLER` | `H-608-IDLER` | 608ZZ pocket supports idler-side ALT axis and is coaxial with `I-013` | `BEARING_608_*`, `YOKE_BEARING_POCKET_DEPTH` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-015` | both 608ZZ | `H-ALT-SHAFT` | Smooth Ø8 shaft passes both inner races; free rotation with controlled axial play | `AXIS_SHAFT_D`, `ALT_SHAFT_L` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-016` | `H-ALT-SHAFT` | payload clamp pairs | Split clamps grip shaft and transmit payload torque without destructive press-fit | `AXIS_SHAFT_D`, `SHAFT_CLAMP_*`, `PAYLOAD_CLAMP_*` | `CAD_REVISED` | `PHYSICAL_PENDING` |
| `I-017` | payload clamps | `P-PAYLOAD-PLATE` | Two clamp stations mount plate symmetrically; upper clamp halves also provide the structural riser required for payload-fastener/shaft clearance | `PAYLOAD_CLAMP_*`, `PAYLOAD_PLATE_*` | `CAD_REVISED` | `PHYSICAL_PENDING` |
| `I-018` | `P-PAYLOAD-PLATE` | `H-PAYLOAD-SCREW` / payload | Sliding 1/4-20 attachment provides balancing travel while retaining adequate plate material | `PAYLOAD_SLOT_*`, `TRIPOD_*` | `CAD_REVISED` | `PHYSICAL_PENDING` |
| `I-019` | `P-YOKE-DRIVE` | `P-ALT-PLATE` | ALT gearbox plate fixes outside drive arm; central opening clears bearing; countersunk heads clear gear envelope | `YOKE_GEARBOX_*`, `ALT_PLATE_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-020` | `H-ALT-MOTOR` | `P-ALT-PLATE` | 28BYJ motor mounts behind plate with shaft through plate on reducer datum | `BYJ_*`, `ALT_MOTOR*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-021` | `H-ALT-MOTOR` | `P-ALT-PINION` | 12T pinion fits actual ALT motor Double-D shaft | `BYJ_SHAFT_*`, `ALT_MOTOR_PINION_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-022` | `P-ALT-PINION` | `P-ALT-COMPOUND` | 12T→48T mesh, 4:1, correct center distance and plane | `GEAR_*`, `CD_STAGE1` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-023` | `P-ALT-COMPOUND` | `P-ALT-PLATE` / `P-ALT-GUARD` / `H-ALT-COMPOUND-AXLE` | Compound gear rotates on stationary shoulder axle supported at plate and guard roof | `ALT_INTERMEDIATE_BORE_D`, `ALT_GUARD_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-024` | `P-ALT-COMPOUND` | `P-ALT-OUTPUT` | 12T→60T mesh, 5:1, correct center distance and axial plane | `GEAR_*`, `CD_STAGE2` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-025` | `P-ALT-OUTPUT` / `P-ALT-SPACER` | `H-ALT-SHAFT` / `H-608-DRIVE` | Spacer loads only 608 inner race; output hub clamps shaft with two M3 grub screws; no bearing preload/rub | `ALT_OUTPUT_*`, `AXIS_SHAFT_D` | `CAD_VALIDATED` | `VERIFY-ALT-DRIVE` |
| `I-026` | `P-ALT-GUARD` | `P-ALT-PLATE` | Removable 4×M3 guard clears gears, supports compound axle and preserves service access | `ALT_GUARD_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-027` | `P-SHAFT-COLLAR` | `H-ALT-SHAFT` | Idler-side collar limits axial travel with small endplay; M3 grub screw locks collar | shaft/collar geometry | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-028` | `P-TABLETOP-BASE` / bolt / feet | `P-AZ-BASE` / support surface | Removable locator + 1/4-20 clamp; bolt avoids M8 hardware; feet establish wide support footprint | `TABLETOP_*`, `TRIPOD_*` | `CAD_VALIDATED` | `VERIFY-TABLETOP-STABILITY` |
| `I-029` | `P-CAMERA-KNOB` + `H-PAYLOAD-SCREW` | `H-ALT-SHAFT` + payload clamps | Adjustable fastener must remain outside shaft/clamp forbidden volumes through the complete balance travel; ≥3 mm to shaft and ≥2 mm to clamp bodies; bolt-through-slot and knob-to-plate contact are explicit intentional relations | `CAMERA_KNOB_*`, `PAYLOAD_*`, `AXIS_SHAFT_D` | `QA_IN_PROGRESS` | `PHYSICAL_PENDING` |

## Critical interface details

### `I-002` — AZ support

AZ axis is common to base/output/turntable. PTFE glide points carry stage load; retaining hardware controls axial play without binding; motor/reducer shafts are not structural bearings.

### `I-006` — AZ compound axle

Final solution must provide two-sided or otherwise mechanically sound support. Changing it invalidates `P-AZ-BASE`, `P-AZ-COVER`, `P-AZ-COMPOUND`, all upper assemblies and relevant motion/constraint QA.

### `I-015` — ALT bearing/shaft chain

The two 608 bearings and Ø8 shaft form one support chain. Physical verification must cover bearing seats, shaft diameter, coaxiality, free rotation and axial endplay after collar/output installation.

### `I-025` — ALT output stack

Required outward order:

```text
608 inner race → P-ALT-SPACER → P-ALT-OUTPUT → shaft clamp/grub screws
```

Spacer must not load outer race; output must not rub plate/guard or impose axial bearing preload.

### `I-029` — payload adjustment internal clearance

The prior geometry placed the knob in the ALT shaft volume. The corrected architecture raises the plate using the upper clamp halves while preserving the complete balancing slot. The fastener is modeled as the printed knob **plus the real metal bolt envelope**, and is checked independently from the payload structural mesh so same-transform internal collisions cannot be hidden.

Intentional relations:

- bolt shank through plate slot: `FASTENER_PASSAGE`;
- knob top against plate underside when tightened: `INTENDED_CONTACT`;
- shaft in split clamp bores: `MATING/KINEMATIC_CONTACT`.

All other knob/bolt ↔ shaft/clamp overlap is forbidden.

## Constraint / DOF register

| Constraint ID | Body/subassembly | Intended DOF | Physical constraint chain | Retention / limits | Load/reaction path | Status |
|---|---|---|---|---|---|---|
| `K-001` | AZ rotating upper stage | 1 rotation about Z | M8 central axis establishes radial datum; turntable/PTFE glide system supports vertical load; hub drives stage | upper M8 retaining hardware controls axial play; nominal continuous 360° | payload → yoke → turntable → glide/base → support; reducer supplies torque only | `CAD_DEFINED / PHYSICAL_PENDING` |
| `K-002` | ALT shaft + payload | 1 rotation about X | Ø8 shaft through two separated coaxial 608ZZ bearings | output-side stack + idler collar control axial travel/endplay | payload → shaft clamps → shaft → 608 inner races → yoke arms → AZ stage | `CAD_DEFINED / PHYSICAL_PENDING` |
| `K-003` | payload balance adjustment | 1 temporary translation along slot Y while loosened; 0 DOF when tightened | 1/4-20 screw shank through longitudinal plate slot constrains lateral path; plate/knob capture Z | slot end-circle centers bound usable travel; tightening screw clamps payload and removes translation | payload → screw/clamp preload → plate → shaft clamps → ALT shaft | `CAD_REVISED / QA_IN_PROGRESS / PHYSICAL_PENDING` |
| `K-004` | AZ compound gear | 1 rotation about intermediate axle | smooth/shoulder axle with adequate support, intended two-sided/final support | axial retention TBD by physical decision | gear mesh forces → axle supports → AZ base/cover | `HOLD-AZ-AXLE` |
| `K-005` | ALT compound gear | 1 rotation about intermediate axle | shoulder axle supported by gearbox plate and guard roof | shoulder/nut establish axial retention with free rotation | mesh force → axle → plate/guard → yoke arm | `CAD_DEFINED / PHYSICAL_PENDING` |

## Motion / adjustment contracts

| Motion ID | State class | Moving body/assembly | Reference bodies | Required range | Physical constraint | Current status |
|---|---|---|---|---|---|---|
| `M-AZ` | operational | everything above turntable | AZ base/tabletop envelope | 0°..360° continuous including wrap | `K-001` | `NEEDS_REVALIDATION` after payload envelope change |
| `M-ALT` | operational | shaft + payload + shaft-coupled output | yoke / fixed ALT gearbox / lower structure | -20°..+90° | `K-002` | `NEEDS_REVALIDATION` after raised payload geometry |
| `M-PAYLOAD-SLIDE` | adjustment | payload fastener/payload attachment position | ALT shaft, clamps, plate, upper/lower structure | `PAYLOAD_SLIDER_MIN_Y .. PAYLOAD_SLIDER_MAX_Y` | `K-003` | `QA_IN_PROGRESS` |

The current QA plan is `docs/motion-sweep-plan.md`. Accepted old evidence in `docs/motion-qa-results.md` is superseded for the changed payload envelope until the new full-state run passes.

## Parameter-to-contract invalidation map

| Parameter family | Minimum contracts to recheck |
|---|---|
| `BYJ_*` | `I-003`, `I-004`, `I-020`, `I-021`; gearbox context; affected motion if motor envelope changes |
| `GEAR_*`, `CD_STAGE*` | `I-005`–`I-008`, `I-022`–`I-026`; drive constraints and motion if exterior changes |
| `FIT`, `PRESS_FIT`, `ELEPHANT_FOOT` | all printed/hardware fits, especially `I-001`, `I-013`–`I-018`, `I-021`, `I-025`, `I-027`–`I-029` |
| `BEARING_608_*`, `AXIS_SHAFT_D`, `ALT_SHAFT_L` | `I-013`–`I-017`, `I-025`, `I-027`, `I-029`, `K-002`, `M-ALT`, `M-PAYLOAD-SLIDE` |
| `AZ_*` | `I-002`–`I-010`, `K-001`, `M-AZ`; pedestal also `I-028`; lower-envelope impacts `M-ALT` |
| `YOKE_*` | `I-010`–`I-019`, `K-002`, `M-ALT` |
| `PAYLOAD_*`, `SHAFT_CLAMP_*`, `CAMERA_KNOB_*` | `I-016`–`I-018`, `I-029`, `K-003`, `M-ALT`, `M-PAYLOAD-SLIDE`, coupled state QA |
| `ALT_*` | `I-019`–`I-026`, `K-002`, `K-005`, `M-ALT` |
| `TRIPOD_*` | `I-001`, `I-018`, `I-028`, `I-029` where payload screw envelope changes |
| `TABLETOP_*` | `I-028`, tabletop assemblies, lower-envelope motion QA |

## Backtracking procedure

When a conflict occurs:

1. name the failing interface/relation/constraint/motion ID;
2. identify its nearest owning part/parameter;
3. revise that owner rather than forcing downstream geometry;
4. mark affected contracts/parts `NEEDS_REVALIDATION`;
5. rerun geometric, solid-pair, constraint and full affected state-space QA in dependency order;
6. update `PARTS.md`, `ASSEMBLY.md`, QA results and `PROJECT_STATE.md` before returning to trusted status.
