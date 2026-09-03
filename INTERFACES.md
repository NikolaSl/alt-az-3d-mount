# Mechanical interface, solid-body and constraint contracts

This file is the **interaction/interface source of truth** for the current machine. A part owns local geometry; this document owns contracts between parts, relevant physical solid-body relationships, and the constraint chains that make intended motions physically realizable.

Stable IDs are used for interfaces (`I-*`), physical relationships (`R-*`), constraints (`K-*`) and motion/adjustment states (`M-*`). `src/config.scad` owns numeric shared parameters. `PARTS.md` owns part identity/status. `ASSEMBLY.md` owns physical build sequence and hardware quantities.

## Contract rules

1. IDs are stable and must not be silently reused for a different meaning.
2. A dimension shared by two or more parts has one owner in `src/config.scad` or a purchased-hardware envelope.
3. Downstream parts derive from contracts; they do not independently redefine them.
4. Changing a contract invalidates every dependent part/QA checkpoint until revalidated.
5. `CAD_VALIDATED` does not imply physical fit/strength validation.
6. Printer fits, motor clone dimensions, bearings, shafts and purchased fasteners remain `PHYSICAL_PENDING` until measured/tested.
7. If no explicit relationship permits contact/fit/passage/embedding, physical solids default to **forbidden overlap**.
8. Bodies sharing the same operational transform still require internal interference checks.
9. A CAD `rotate()`/`translate()` is not a mechanism: each intended autonomous/repeatable DOF requires a physical constraint chain that removes the unwanted DOFs.
10. Manual/operator-constrained setup states must say so explicitly; they are not counted as self-guided mechanism DOFs.

## Interface register

| ID | Side A | Side B | Contract | Primary parameter owner | CAD status | Physical status |
|---|---|---|---|---|---|---|
| `I-001` | tripod / support | `P-AZ-BASE` | 1/4-20 UNC captive support interface; base restrains nut rotation and accepts screw entry from below | `TRIPOD_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-002` | `P-AZ-BASE` | `H-AZ-AXIS` / `P-AZ-TURNTABLE` | M8 central AZ axis; turntable rotates about common Z datum; axial retention removes gross play without binding | `M8_CLEARANCE_D`, AZ datums | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-003` | `H-AZ-MOTOR` | `P-AZ-BASE` | 28BYJ-48 mounting envelope and shaft datum fixed in AZ base | `BYJ_*`, `REDUCER_MOTOR*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-004` | `H-AZ-MOTOR` | `P-AZ-PINION` | 12T pinion fits actual Double-D shaft and transmits torque without slip | `BYJ_SHAFT_*`, `AZ_MOTOR_PINION_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-005` | `P-AZ-PINION` | `P-AZ-COMPOUND` | 12T→48T involute mesh, 4:1, common plane/backlash | `GEAR_*`, `CD_STAGE1` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-006` | `P-AZ-COMPOUND` | base / cover / `H-AZ-COMPOUND-AXLE` | compound gear rotates on mechanically sound supported smooth/shoulder axle; no long unsupported cantilever screw | `INTERMEDIATE_AXLE_D`, AZ reducer datums | `CAD_PROVISIONAL` | `HOLD-AZ-AXLE` |
| `I-007` | `P-AZ-COMPOUND` | `P-AZ-OUTPUT` | 12T→60T involute mesh, 5:1, correct axial plane | `GEAR_*`, `CD_STAGE2` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-008` | `P-AZ-OUTPUT` | `P-AZ-TURNTABLE` | output hub locates/drives turntable through 4×M3; no unintended axial preload | `AZ_OUTPUT_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-009` | base / cover | `P-AZ-TURNTABLE` | three PTFE glide points carry rotating-stage load; cover clearance avoids rub/bind | `AZ_GLIDE_*`, `AZ_COVER_CLEARANCE` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-010` | `P-AZ-TURNTABLE` | `P-YOKE-BRIDGE` | fixed 4×M4 bridge mount centered on AZ stage | `AZ_YOKE_MOUNT_*`, `YOKE_BRIDGE_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-011` | bridge | drive arm | drive-arm tenon/slot + transverse lock defines one side of ALT support | `YOKE_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-012` | bridge | idler arm | idler-arm tenon/slot + lock remains parallel/coaxial with drive arm | `YOKE_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-013` | drive arm | `H-608-DRIVE` | 608ZZ pocket supports drive-side ALT axis and remains serviceable | `BEARING_608_*`, `YOKE_BEARING_POCKET_DEPTH` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-014` | idler arm | `H-608-IDLER` | 608ZZ pocket supports idler side and is coaxial with `I-013` | `BEARING_608_*`, `YOKE_BEARING_POCKET_DEPTH` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-015` | both 608ZZ | `H-ALT-SHAFT` | smooth Ø8 shaft passes both inner races; free rotation with controlled axial play | `AXIS_SHAFT_D`, `ALT_SHAFT_L` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-016` | `H-ALT-SHAFT` | payload clamp pairs | split clamps grip shaft and transmit payload torque | `AXIS_SHAFT_D`, `SHAFT_CLAMP_*`, `PAYLOAD_CLAMP_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-017` | payload clamps | `P-PAYLOAD-PLATE` | two clamp stations mount plate symmetrically; upper halves are also 15 mm structural risers giving fastener/shaft clearance | `PAYLOAD_CLAMP_*`, `PAYLOAD_PLATE_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-018` | payload plate | payload screw / payload | sliding 1/4-20 attachment provides balance travel; slot constrains screw-center path but one loose screw does not prevent payload yaw | `PAYLOAD_SLOT_*`, `TRIPOD_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-019` | drive arm | ALT gearbox plate | four flush screws fix gearbox plate; central opening clears bearing and screw heads clear gear envelope | `YOKE_GEARBOX_*`, `ALT_PLATE_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-020` | ALT motor | ALT plate | 28BYJ mounts behind plate on reducer datum | `BYJ_*`, `ALT_MOTOR*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-021` | ALT motor | ALT pinion | 12T pinion fits actual Double-D shaft | `BYJ_SHAFT_*`, `ALT_MOTOR_PINION_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-022` | ALT pinion | ALT compound | 12T→48T mesh, 4:1 | `GEAR_*`, `CD_STAGE1` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-023` | ALT compound | plate / guard / shoulder axle | compound gear rotates on stationary axle supported at plate and guard roof | `ALT_INTERMEDIATE_BORE_D`, `ALT_GUARD_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-024` | ALT compound | ALT output | 12T→60T mesh, 5:1 | `GEAR_*`, `CD_STAGE2` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-025` | ALT output / spacer | ALT shaft / drive 608 | spacer loads only inner race; hub clamps shaft with two M3 grub screws; no preload/rub | `ALT_OUTPUT_*`, `AXIS_SHAFT_D` | `CAD_VALIDATED` | `VERIFY-ALT-DRIVE` |
| `I-026` | ALT guard | ALT plate | removable 4×M3 guard clears gears, supports compound axle and preserves service access | `ALT_GUARD_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-027` | shaft collar | ALT shaft | idler-side collar limits axial travel with small endplay | collar/shaft geometry | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-028` | tabletop base / bolt / feet | AZ base / table | removable locator + 1/4-20 clamp; bolt avoids M8 hardware; feet establish wide support footprint | `TABLETOP_*`, `TRIPOD_*` | `CAD_VALIDATED` | `VERIFY-TABLETOP-STABILITY` |
| `I-029` | `P-CAMERA-KNOB` + real payload bolt envelope | ALT shaft + payload clamps | fastener remains outside shaft/clamp forbidden volumes through complete screw-center travel; ≥3 mm to shaft, ≥2 mm to clamp bodies; intended passage/contact relations explicit | `CAMERA_KNOB_*`, `PAYLOAD_*`, `AXIS_SHAFT_D` | `CAD_VALIDATED / STATE_SPACE_QA_PASS` | `VERIFY-PAYLOAD-ADJUSTMENT` |

## Physical solid relationship register

The register names high-value contact/interference pairs explicitly. Unlisted physical overlap is still forbidden by the default rule and must be added when it becomes relevant to a changed part/state.

| ID | Body A | Body B | Relationship | Requirement / meaning | State scope |
|---|---|---|---|---|---|
| `R-001` | payload fastener body | ALT shaft | `CLEARANCE` | ≥3.0 mm | full `M-PAYLOAD-SLIDE` |
| `R-002` | payload fastener body | split clamp solids | `CLEARANCE` | ≥2.0 mm | full `M-PAYLOAD-SLIDE` |
| `R-003` | 1/4-20 screw shank | payload plate slot | `FASTENER_PASSAGE` | shank passes slot without unintended side interference | balance setup + tightened state |
| `R-004` | knob top | payload plate underside | `INTENDED_CONTACT` | clamp contact when tightened; no penetration | tightened state |
| `R-005` | ALT shaft | split clamp bores | `MATING_FIT` | controlled clamp fit transmits payload torque | assembled/tightened |
| `R-006` | ALT shaft | 608 inner races | `KINEMATIC_CONTACT` | rotational shaft support, no forced misalignment | full `M-ALT` |
| `R-007` | payload structural body | fixed upper yoke/ALT gearbox envelope | `CLEARANCE` | minimum sampled 6.0 mm at accepted checkpoint | `M-ALT` full range |
| `R-008` | payload structural body | lower conservative mount envelope | `CLEARANCE` | lower 0.5 mm expanded envelope remains collision-free | `M-ALT` full range |
| `R-009` | adjustable payload fastener | upper/lower mount obstruction envelopes | `FORBIDDEN_OVERLAP` | zero intersections in full ALT×screw-center grid | coupled `M-ALT × M-PAYLOAD-SLIDE` |
| `R-010` | ALT output spacer | drive 608 inner race | `INTENDED_CONTACT` | reaction only on inner race; outer race contact forbidden | assembled/full ALT |
| `R-011` | AZ turntable support | PTFE glide pads | `KINEMATIC_CONTACT` | sliding support carries vertical load | full `M-AZ` |

## Critical interface details

### `I-002` — AZ support

AZ axis is common to base/output/turntable. PTFE glide points carry stage load; retaining hardware controls axial play without binding; motor/reducer shafts are not structural bearings.

### `I-006` — AZ compound axle

Final solution must provide two-sided or otherwise mechanically sound support. A long screw cantilevered from one thin wall is not a frozen design.

### `I-015` — ALT bearing/shaft chain

The two 608 bearings and Ø8 shaft form one support chain. Physical verification must cover bearing seats, shaft diameter, coaxiality, free rotation and final axial endplay.

### `I-025` — ALT output stack

Required outward order:

```text
608 inner race → P-ALT-SPACER → P-ALT-OUTPUT → shaft clamp/grub screws
```

Spacer must not load outer race; output must not rub plate/guard or impose axial bearing preload.

### `I-029` — payload adjustment internal clearance

The prior geometry placed the knob in the ALT shaft volume. The corrected architecture raises the plate with 15 mm upper clamp/riser halves while preserving the complete balance slot. QA models the printed knob **plus the real metal bolt envelope** independently from the structural payload mesh.

Accepted state-space evidence: `docs/motion-qa-results.md`, run `33772135101`.

```text
screw-center range        -12.600 .. +28.600 mm
sample interval            0.500 mm
samples                     84
fastener → shaft min        3.000 mm (required 3.000)
fastener → clamps min       2.800 mm (required 2.000)
```

The variable `PAYLOAD_SCREW_Y` represents the physically slot-constrained **screw-center coordinate**. It does not claim that the complete loose payload has a unique orientation: one loose screw permits yaw. During balancing, the operator/adapter controls orientation; after tightening, clamp preload must remove translation/yaw/slip. Repeatable/self-guided balance travel would require an additional anti-rotation guide/second locator and new QA.

## Constraint / DOF register

| ID | Body/subassembly | Claimed mechanism state | Physical constraint chain | Retention / limits | Load path / external constraint | Status |
|---|---|---|---|---|---|---|
| `K-001` | AZ rotating upper stage | 1 rotation about Z | M8 central axis radial datum + turntable/PTFE support + output hub torque drive | M8 upper retention controls axial play; nominal continuous 360° | payload→yoke→turntable→glides/base; reducer supplies torque only | `CAD_DEFINED / MOTION_QA_PASS / PHYSICAL_PENDING` |
| `K-002` | ALT shaft + payload | 1 rotation about X | Ø8 shaft through two separated coaxial 608ZZ | output stack + idler collar control axial travel/endplay | payload→clamps→shaft→608 inner races→yoke | `CAD_DEFINED / MOTION_QA_PASS / PHYSICAL_PENDING` |
| `K-003` | payload balance setup | screw-center coordinate translates along slot while loose; complete payload may yaw; target 0 DOF when tightened | 1/4-20 shank + slot constrain screw-center path; knob/plate capture fastener | slot end-circle centers bound screw-center travel; tightening must lock translation/yaw | operator controls loose payload orientation; tightened payload load flows via screw/plate/clamps | `CAD_DEFINED / STATE_SPACE_QA_PASS / MANUAL_SETUP / PHYSICAL_PENDING` |
| `K-004` | AZ compound gear | 1 rotation | smooth/shoulder axle with mechanically adequate support | final axial retention TBD | gear forces→axle support→base/cover | `HOLD-AZ-AXLE` |
| `K-005` | ALT compound gear | 1 rotation | shoulder axle supported by plate + guard roof | shoulder/nut retains without pinching gear | mesh force→axle→plate/guard→yoke | `CAD_DEFINED / PHYSICAL_PENDING` |

## Motion / adjustment contracts

| Motion ID | State class | Moving body / modeled coordinate | Reference bodies | Required range | Constraint | Current status |
|---|---|---|---|---|---|---|
| `M-AZ` | operational | complete upper stage | AZ base/tabletop envelope | 0°..360° continuous incl. wrap | `K-001` | `MOTION_QA_PASS` |
| `M-ALT` | operational | shaft + mount payload structure + shaft-coupled output | yoke / fixed ALT gearbox / lower structure | -20°..+90° | `K-002` | `MOTION_QA_PASS` |
| `M-PAYLOAD-SLIDE` | manual setup coordinate | physical payload fastener screw-center position | shaft, clamps, plate, upper/lower structure | -12.600..+28.600 mm | `K-003` | `STATE_SPACE_QA_PASS / MANUAL_SETUP / PHYSICAL_PENDING` |

Accepted checkpoint: `docs/motion-qa-results.md`, tested commit `81738de19ba399e1249ad35a8eb541aa1ca3f9e1`, workflow run `33772135101`.

The current AZ collision proof depends on two explicit invariants:

1. modeled upper structures undergo the same rigid AZ rotation;
2. the lower diagnostic obstruction is a rotationally symmetric conservative solid superset.

Future asymmetric cables/connectors/electronics/hard stops invalidate that proof until modeled and re-QA'd.

The current PASS also does not cover every arbitrary external phone/camera/optic. A specific payload + adapter + cables must be modeled conservatively or its allowable motion range physically restricted/verified before unattended full-range operation.

## Parameter-to-contract invalidation map

| Parameter family | Minimum contracts to recheck |
|---|---|
| `BYJ_*` | `I-003`, `I-004`, `I-020`, `I-021`; gearbox context; affected motion if motor envelope changes |
| `GEAR_*`, `CD_STAGE*` | `I-005`–`I-008`, `I-022`–`I-026`; `K-004/K-005`; motion if exterior changes |
| `FIT`, `PRESS_FIT`, `ELEPHANT_FOOT` | all printed/hardware fits, especially `I-001`, `I-013`–`I-018`, `I-021`, `I-025`, `I-027`–`I-029` |
| `BEARING_608_*`, `AXIS_SHAFT_D`, `ALT_SHAFT_L` | `I-013`–`I-017`, `I-025`, `I-027`, `I-029`, `R-001`, `R-005/006`, `K-002`, `M-ALT`, `M-PAYLOAD-SLIDE` |
| `AZ_*` | `I-002`–`I-010`, `K-001`, `M-AZ`; pedestal also `I-028`; lower envelope can affect `M-ALT` |
| `YOKE_*` | `I-010`–`I-019`, `R-007`, `K-002`, `M-ALT` |
| `PAYLOAD_*`, `SHAFT_CLAMP_*`, `CAMERA_KNOB_*` | `I-016`–`I-018`, `I-029`, `R-001`–`R-009`, `K-003`, `M-ALT`, `M-PAYLOAD-SLIDE` and coupled state QA |
| `ALT_*` | `I-019`–`I-026`, `K-002`, `K-005`, `M-ALT` |
| `TRIPOD_*` | `I-001`, `I-018`, `I-028`, `I-029` where screw envelope changes |
| `TABLETOP_*` | `I-028`, tabletop assembly/lower-envelope state-space QA |

## Backtracking procedure

When a conflict occurs:

1. name the failing `I-*`, `R-*`, `K-*` or `M-*` contract;
2. identify its nearest owning part/parameter;
3. revise that owner rather than forcing downstream geometry;
4. mark affected contracts/parts `NEEDS_REVALIDATION`;
5. rerun geometric, solid-pair, constraint and complete affected state-space QA in dependency order;
6. update `PARTS.md`, `ASSEMBLY.md`, QA evidence and `PROJECT_STATE.md` before returning to trusted status.
