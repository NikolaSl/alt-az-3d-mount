# Mechanical interface contracts

This file is the **interaction/interface source of truth** for the current machine. A part describes its own geometry; this document describes the contract at the boundary between parts.

Stable interface IDs are used so that a geometry change can be traced to the exact downstream parts and QA that must be repeated.

`src/config.scad` owns numeric shared parameters. `PARTS.md` owns part identity/status. `ASSEMBLY.md` owns the physical build sequence and hardware quantities.

## Contract rules

1. Interface IDs are stable and must not be silently reused for a different meaning.
2. A dimension shared by two or more parts must have one owner in `src/config.scad` or a purchased-hardware envelope.
3. A downstream part may derive local geometry from an interface but must not independently redefine it.
4. Changing a contract invalidates every dependent part listed for that interface until QA is repeated.
5. `CAD_VALIDATED` means geometric/context QA is acceptable. It does **not** imply physical fit is proven.
6. Any interface involving actual printer fit, motor clone dimensions, bearing fit, shaft fit or purchased fasteners remains `PHYSICAL_PENDING` until measured/tested.
7. A geometry/interface change that affects a motion envelope invalidates the corresponding `M-*` contract and requires `MOTION_QA_PROTOCOL.md` to be re-run.

## Interface register

| ID | Side A | Side B | Contract | Primary parameter owner | CAD status | Physical status |
|---|---|---|---|---|---|---|
| `I-001` | tripod / support | `P-AZ-BASE` | 1/4-20 UNC captive support interface; base restrains nut rotation and accepts screw entry from below | `TRIPOD_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-002` | `P-AZ-BASE` | `H-AZ-AXIS` / `P-AZ-TURNTABLE` | M8 central AZ axis; turntable rotates about common Z datum; axial clamp removes play without binding | `M8_CLEARANCE_D`, AZ datums | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-003` | `H-AZ-MOTOR` | `P-AZ-BASE` | 28BYJ-48 mounting envelope and shaft datum fixed in AZ base | `BYJ_*`, `REDUCER_MOTOR*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-004` | `H-AZ-MOTOR` | `P-AZ-PINION` | 12T pinion fits actual 28BYJ-48 Double-D shaft; torque transmitted without slip | `BYJ_SHAFT_*`, `AZ_MOTOR_PINION_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-005` | `P-AZ-PINION` | `P-AZ-COMPOUND` | 12T→48T involute mesh, 4:1, common gear plane and designed backlash | `GEAR_*`, `CD_STAGE1` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-006` | `P-AZ-COMPOUND` | `P-AZ-BASE` / `P-AZ-COVER` / `H-AZ-COMPOUND-AXLE` | Compound gear rotates on a properly supported smooth/shoulder axle; no long unsupported cantilever screw | `INTERMEDIATE_AXLE_D`, AZ reducer datums | `CAD_PROVISIONAL` | `HOLD-AZ-AXLE` |
| `I-007` | `P-AZ-COMPOUND` | `P-AZ-OUTPUT` | 12T→60T involute mesh, 5:1, correct axial gear plane | `GEAR_*`, `CD_STAGE2` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-008` | `P-AZ-OUTPUT` | `P-AZ-TURNTABLE` | Output hub locates and drives turntable through 4×M3 mounting pattern; no unintended axial preload | `AZ_OUTPUT_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-009` | `P-AZ-BASE` / cover | `P-AZ-TURNTABLE` | Three PTFE glide points support rotating stage; clearance avoids cover rubbing while limiting wobble | `AZ_GLIDE_*`, `AZ_COVER_CLEARANCE` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-010` | `P-AZ-TURNTABLE` | `P-YOKE-BRIDGE` | Fixed 4×M4 bridge mount centered on AZ rotating stage | `AZ_YOKE_MOUNT_*`, `YOKE_BRIDGE_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-011` | `P-YOKE-BRIDGE` | `P-YOKE-DRIVE` | Drive arm tenon/slot + transverse lock; arm datum establishes one side of ALT axis | `YOKE_*`, `YOKE_SLOT_CLEARANCE` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-012` | `P-YOKE-BRIDGE` | `P-YOKE-IDLER` | Idler arm tenon/slot + transverse lock; must remain parallel/coaxial with drive arm | `YOKE_*`, `YOKE_SLOT_CLEARANCE` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-013` | `P-YOKE-DRIVE` | `H-608-DRIVE` | 608ZZ pocket supports drive-side ALT axis; bearing seats fully and remains accessible for assembly | `BEARING_608_*`, `YOKE_BEARING_POCKET_DEPTH`, fit values | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-014` | `P-YOKE-IDLER` | `H-608-IDLER` | 608ZZ pocket supports idler-side ALT axis; coaxial with `I-013` | `BEARING_608_*`, `YOKE_BEARING_POCKET_DEPTH`, fit values | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-015` | both 608ZZ | `H-ALT-SHAFT` | Smooth Ø8 shaft passes both bearing inner races without forced misalignment; free rotation with controlled axial play | `AXIS_SHAFT_D`, `ALT_SHAFT_L` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-016` | `H-ALT-SHAFT` | payload clamp pairs | Split clamps grip shaft and transmit payload torque without requiring destructive press-fit | `AXIS_SHAFT_D`, `SHAFT_CLAMP_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-017` | payload clamps | `P-PAYLOAD-PLATE` | Two clamp stations mount plate symmetrically and keep payload plate referenced to ALT shaft | `PAYLOAD_CLAMP_*`, `PAYLOAD_PLATE_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-018` | `P-PAYLOAD-PLATE` | `H-PAYLOAD-SCREW` / payload | Sliding 1/4-20 UNC attachment slot provides balancing travel while retaining adequate plate material | `PAYLOAD_SLOT_*`, `TRIPOD_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-019` | `P-YOKE-DRIVE` | `P-ALT-PLATE` | ALT gearbox plate fixes outside drive arm; central opening clears bearing face; countersunk heads clear gear envelope | `YOKE_GEARBOX_*`, `ALT_PLATE_*`, `ALT_YOKE_HEAD_RECESS_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-020` | `H-ALT-MOTOR` | `P-ALT-PLATE` | 28BYJ-48 motor mounts behind plate with shaft through plate on reducer datum | `BYJ_*`, `ALT_MOTOR*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-021` | `H-ALT-MOTOR` | `P-ALT-PINION` | 12T pinion fits actual ALT motor Double-D shaft | `BYJ_SHAFT_*`, `ALT_MOTOR_PINION_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-022` | `P-ALT-PINION` | `P-ALT-COMPOUND` | 12T→48T involute mesh, 4:1, correct center distance and gear plane | `GEAR_*`, `CD_STAGE1`, ALT gear Z datums | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-023` | `P-ALT-COMPOUND` | `P-ALT-PLATE` / `P-ALT-GUARD` / `H-ALT-COMPOUND-AXLE` | Compound gear rotates on stationary shoulder axle supported at both plate and guard roof; free axial rotation | `ALT_INTERMEDIATE_BORE_D`, `ALT_GUARD_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-024` | `P-ALT-COMPOUND` | `P-ALT-OUTPUT` | 12T→60T involute mesh, 5:1, correct center distance and axial plane | `GEAR_*`, `CD_STAGE2`, ALT gear Z datums | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-025` | `P-ALT-OUTPUT` / `P-ALT-SPACER` | `H-ALT-SHAFT` / `H-608-DRIVE` | Spacer bears only on 608 inner race; output hub clamps shaft with two M3 grub screws; no bearing preload/rubbing | `ALT_OUTPUT_*`, `ALT_OUTPUT_SPACER_*`, `AXIS_SHAFT_D` | `CAD_VALIDATED` | `VERIFY-ALT-DRIVE` |
| `I-026` | `P-ALT-GUARD` | `P-ALT-PLATE` | Removable 4×M3 guard encloses gears, clears stack, supports compound axle, and preserves service access | `ALT_GUARD_*` | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-027` | `P-SHAFT-COLLAR` | `H-ALT-SHAFT` | Idler-side collar limits axial travel while leaving small endplay; M3 grub screw locks collar | shaft/collar local geometry | `CAD_VALIDATED` | `PHYSICAL_PENDING` |
| `I-028` | `P-TABLETOP-BASE` / `H-TABLETOP-BOLT` / `H-TABLETOP-FEET` | `P-AZ-BASE` / flat support surface | Ø48 pedestal enters Ø49×1.5 locator; recessed 1/4-20 bolt clamps into shared captive nut; bolt must not intrude into M8 AZ hardware; compliant feet establish a wide non-slip support footprint | `TABLETOP_*`, `TRIPOD_*`, `AZ_PEDESTAL_*` | `CAD_VALIDATED` | `VERIFY-TABLETOP-STABILITY` |

## Critical contract details

### `I-002` — AZ rotation support

Required invariants:

- AZ axis is common to base, output gear and turntable.
- Retaining hardware removes gross axial play but must not clamp the rotating stage into binding.
- PTFE glide points carry the stage load; motor/reducer shafts are not intended to carry the machine weight.
- 360° hand rotation must be possible before powered tests.

### `I-006` — AZ compound axle

This remains the most explicit unresolved structural interface.

The final physical solution must provide two-sided or otherwise mechanically sound support for the compound axle. A long screw cantilevered from only one thin printed wall is not accepted as the frozen design.

Changing this interface invalidates at minimum:

```text
P-AZ-BASE
P-AZ-COVER
P-AZ-COMPOUND
A-AZ
A-YOKE
A-PAYLOAD
A-FULL
A-TABLETOP-FULL
M-AZ
M-ALT
```

### `I-015` — ALT bearing/shaft chain

The two 608 bearings and Ø8 shaft form one interface chain, not three unrelated fits. Physical validation must verify:

- each bearing seat;
- actual shaft diameter;
- coaxiality after yoke assembly;
- free shaft rotation through both bearings;
- acceptable axial endplay after collar/output stack installation.

If arm spacing or bearing datum changes, payload and ALT gearbox context QA and `M-ALT` must be repeated.

### `I-019` — drive arm to ALT gearbox

The four plate screws are also part of the gear-clearance problem. Countersunk screw heads must remain flush because the lower 48T gear passes close to one mounting location.

This interface therefore couples structure, service access and the reducer swept envelope.

### `I-025` — ALT output stack

Required stack order from yoke outward:

```text
608 inner race
→ P-ALT-SPACER
→ P-ALT-OUTPUT 60T gear/hub
→ grub-screw clamp to H-ALT-SHAFT
```

The spacer OD must not load the bearing outer race. The output gear must not rub plate or guard. The hub must transmit torque without imposing axial preload on the bearing.

### `I-028` — removable tabletop support

Required invariants:

- `P-TABLETOP-BASE` remains removable so `P-AZ-BASE` can still mount directly on a tripod.
- The locator provides lateral registration; the 1/4-20 bolt supplies clamp preload.
- The initial bolt recommendation is about 1/2 in under-head length, but the final length is selected by dry-fit; a longer bolt must not reach the M8 AZ-axis hardware inside the pedestal.
- The Ø190 printed disk and four compliant feet provide a support footprint, but CAD geometry alone does not prove overturn stability for every 1 kg payload/ALT angle.
- Physical stability is verified with the actual payload CG before unattended use.

Changing `AZ_PEDESTAL_D`, `TRIPOD_*` or any `TABLETOP_*` geometry invalidates `P-TABLETOP-BASE`, `A-TABLETOP-CONTEXT`, `A-TABLETOP-FULL` and relevant motion QA.

## Motion contracts

| Motion ID | Moving assembly | Fixed/reference assembly | Required range | Accepted CAD motion QA | Status |
|---|---|---|---|---|---|
| `M-AZ` | everything above `P-AZ-TURNTABLE` | `P-AZ-BASE` / tabletop envelope | nominal 360° continuous azimuth | actual assembly compiled at 0°..360° every 10° including wrap; 32 coupled AZ/ALT configurations; structural collision clearance is AZ-invariant for the current symmetric lower envelope/common rigid upper rotation | `MOTION_QA_PASS` |
| `M-ALT` | shaft + payload stage + ALT output shaft-coupled elements | yoke arms / fixed ALT gearbox / lower structure | `-20° .. +90°` | FCL collision/distance sweep every 1° = 111 poses; zero collisions; min payload→upper = 6.0 mm at -20°; min payload→conservative lower = 43.0 mm at +90°; expanded lower envelope by 0.5 mm remains 42.5 mm clear | `MOTION_QA_PASS` |

Accepted checkpoint: `docs/motion-qa-results.md`, tested commit `4d3d772e65116ac5072a4187624929237a1252e4`.

The current AZ collision proof depends on two explicit invariants:

1. payload, yoke and ALT gearbox undergo the same rigid AZ rotation;
2. the lower diagnostic obstruction is a rotationally symmetric solid superset of the actual lower mechanical exterior.

Any future cable management, connectors, electronics, hard stops or other asymmetric fixed geometry must be added as explicit motion constraints and invalidates this symmetry-based `M-AZ` clearance proof until QA is re-run.

## Parameter-to-interface invalidation map

This is the first machine-readable-by-convention propagation layer. When one parameter family changes, inspect/revalidate at least the listed interfaces.

| Parameter family | Interfaces / motion contracts to invalidate/recheck |
|---|---|
| `BYJ_*` | `I-003`, `I-004`, `I-020`, `I-021`; AZ/ALT gearbox context; `M-ALT` if external motor envelope changes |
| `GEAR_*`, `CD_STAGE*` | `I-005`–`I-008`, `I-022`–`I-026`; motion QA if gearbox exterior/motion envelope changes |
| `FIT`, `PRESS_FIT`, `ELEPHANT_FOOT` | all printed-to-hardware fits, especially `I-001`, `I-013`–`I-016`, `I-018`, `I-021`, `I-025`, `I-027`, `I-028`; motion QA if resulting geometry changes |
| `BEARING_608_*`, `AXIS_SHAFT_D`, `ALT_SHAFT_L` | `I-013`–`I-017`, `I-025`, `I-027`, `M-ALT` |
| `AZ_*` | `I-002`–`I-010`; `AZ_PEDESTAL_*` also invalidates `I-028`; `M-AZ`/`M-ALT` where lower or axis geometry changes |
| `YOKE_*` | `I-010`–`I-019`, `M-ALT`, payload/gearbox collision QA |
| `PAYLOAD_*`, `SHAFT_CLAMP_*` | `I-016`–`I-018`, `M-ALT` and coupled motion QA |
| `ALT_*` | `I-019`–`I-026`, `M-ALT` and coupled motion QA |
| `TRIPOD_*` | `I-001`, `I-018`, `I-028`; motion QA only if external envelope changes |
| `TABLETOP_*` | `I-028`, `A-TABLETOP-CONTEXT`, `A-TABLETOP-FULL`, lower-envelope motion QA |

## Backtracking procedure using interface IDs

When a new part cannot be made compatible:

1. name the failing interface ID rather than describing the problem only informally;
2. identify the parameter/part that owns the blocking constraint;
3. revise the nearest upstream owner;
4. mark the dependent interfaces, parts and any affected `M-*` contracts `NEEDS_REVALIDATION`;
5. run QA outward from that point in dependency order, including motion QA where the motion envelope changed;
6. update `PARTS.md`, `ASSEMBLY.md`, `docs/motion-qa-results.md` when applicable, and `PROJECT_STATE.md` with the result.

This prevents global redesign when a local upstream correction is sufficient, while still ensuring no affected dependency remains silently stale.
