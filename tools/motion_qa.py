#!/usr/bin/env python3
"""Fast mesh-based multi-state motion QA for the Alt-Az mount.

OpenSCAD exports reusable diagnostic solids once. Python-FCL then evaluates the
full ALT range and payload balancing adjustment without repeatedly invoking CAD
booleans.

The dense ALT×slider grids are collision-exclusion grids. They intentionally use
FCL collision queries at every state rather than an expensive distance solve at
every state. Required positive margins are proven either by a clearance-expanded
obstruction or by the dedicated internal payload-adjustment QA.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import subprocess
from pathlib import Path

import numpy as np
import trimesh
from trimesh.collision import CollisionManager
from trimesh.transformations import translation_matrix


def run(cmd: list[str], cwd: Path, timeout: int = 180) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, text=True, check=False,
                          timeout=timeout)


def config_scalar(text: str, name: str) -> float:
    match = re.search(rf"^\s*{re.escape(name)}\s*=\s*(-?[0-9]+(?:\.[0-9]+)?)\s*;",
                      text, flags=re.MULTILINE)
    if not match:
        raise RuntimeError(f"Cannot read scalar {name} from src/config.scad")
    return float(match.group(1))


def values_inclusive(start: float, stop: float, step: float) -> list[float]:
    if step <= 0 or stop < start:
        raise ValueError("range requires min <= max and positive step")
    values, value = [], start
    eps = abs(step) * 1e-9 + 1e-9
    while value <= stop + eps:
        values.append(round(value, 10))
        value += step
    if not math.isclose(values[-1], stop, rel_tol=0, abs_tol=eps):
        values.append(stop)
    return values


def export_diag_mesh(root: Path, outdir: Path, *, mode: int, name: str,
                     tabletop: bool = True, margin: float = 0.0) -> tuple[trimesh.Trimesh, dict]:
    src = root / "src/assemblies/motion_collision_check.scad"
    out = outdir / f"{name}.stl"
    cmd = ["openscad", "--render", "--hardwarnings",
           "-D", f"CHECK_MODE={mode}",
           "-D", f"WITH_TABLETOP={'true' if tabletop else 'false'}",
           "-D", f"CLEARANCE_MARGIN={margin}",
           "-o", str(out), str(src)]
    p = run(cmd, root, timeout=300)
    if p.returncode != 0 or not out.exists() or out.stat().st_size == 0:
        raise RuntimeError(f"Diagnostic mesh export failed for {name}:\n{p.stdout}")
    mesh = trimesh.load_mesh(out, force="mesh", process=False)
    if not isinstance(mesh, trimesh.Trimesh) or len(mesh.faces) == 0:
        raise RuntimeError(f"Diagnostic mesh {name} is empty or invalid")
    return mesh, {
        "file": str(out.relative_to(root)),
        "vertices": int(len(mesh.vertices)),
        "faces": int(len(mesh.faces)),
        "watertight": bool(mesh.is_watertight),
        "bounds_mm": [float(x) for x in mesh.extents],
        "openscad_log_tail": "\n".join(p.stdout.strip().splitlines()[-12:]),
    }


def payload_transform(alt_deg: float, axis_z: float) -> np.ndarray:
    a = math.radians(alt_deg)
    c, s = math.cos(a), math.sin(a)
    matrix = np.eye(4)
    matrix[:3, :3] = np.array([[1, 0, 0], [0, c, -s], [0, s, c]], dtype=float)
    matrix[:3, 3] = [0.0, 0.0, axis_z]
    return matrix


def fastener_transform(alt_deg: float, axis_z: float, slider_y: float) -> np.ndarray:
    # Local balance translation is applied before the payload's ALT transform.
    return payload_transform(alt_deg, axis_z) @ translation_matrix([0.0, slider_y, 0.0])


def collision_sweep(payload: trimesh.Trimesh, fixed: trimesh.Trimesh,
                    *, axis_z: float, alt_values: list[float], name: str) -> dict:
    """Structural sweep also computes minimum distance because it has only 111 states."""
    manager = CollisionManager()
    manager.add_object(name, fixed)
    samples, collisions = [], []
    min_distance, min_pose = math.inf, None
    for alt in alt_values:
        transform = payload_transform(alt, axis_z)
        hit = bool(manager.in_collision_single(payload, transform=transform))
        distance = float(manager.min_distance_single(payload, transform=transform))
        samples.append({"alt_deg": alt, "collision": hit, "distance_mm": distance})
        if hit:
            collisions.append(alt)
        if distance < min_distance:
            min_distance, min_pose = distance, alt
    return {
        "name": name,
        "sample_count": len(samples),
        "alt_min_deg": min(alt_values),
        "alt_max_deg": max(alt_values),
        "step_deg": alt_values[1] - alt_values[0] if len(alt_values) > 1 else None,
        "collision_angles_deg": collisions,
        "minimum_distance_mm": min_distance,
        "minimum_distance_alt_deg": min_pose,
        "status": "CLEAR" if not collisions else "COLLISION",
        "samples": samples,
    }


def fastener_collision_grid(fastener: trimesh.Trimesh, fixed: trimesh.Trimesh,
                            *, axis_z: float, alt_values: list[float],
                            slider_values: list[float], name: str) -> dict:
    """Exhaustively sample collision state without redundant min-distance queries.

    A positive safety margin is represented by checking against an expanded
    obstruction mesh. This keeps full state coverage fast enough for routine CI.
    """
    manager = CollisionManager()
    manager.add_object(name, fixed)
    failures = []
    checked = 0
    for slider_y in slider_values:
        for alt in alt_values:
            checked += 1
            transform = fastener_transform(alt, axis_z, slider_y)
            hit = bool(manager.in_collision_single(fastener, transform=transform))
            if hit:
                failures.append({"alt_deg": alt, "payload_screw_y_mm": slider_y})
    return {
        "name": name,
        "status": "CLEAR" if not failures else "COLLISION",
        "sample_count": checked,
        "alt_samples": len(alt_values),
        "slider_samples": len(slider_values),
        "failures": failures,
    }


def compile_pose(root: Path, outdir: Path, *, az: float, alt: float, label: str,
                 payload_y: float | None = None) -> dict:
    src = root / "src/assemblies/tabletop_full_mount.scad"
    out = outdir / f"compile-{label}.csg"
    cmd = ["openscad", "-D", f"AZ_ANGLE={az}", "-D", f"ALT_ANGLE={alt}"]
    if payload_y is not None:
        cmd += ["-D", f"PAYLOAD_SCREW_Y={payload_y}"]
    cmd += ["-o", str(out), str(src)]
    p = run(cmd, root, timeout=120)
    fatal = p.returncode != 0 or any(
        token in p.stdout for token in ("ERROR:", "Parser error", "Can't parse file", "Assertion")
    )
    ok = (not fatal) and out.exists() and out.stat().st_size > 0
    out.unlink(missing_ok=True)
    return {"az_deg": az, "alt_deg": alt, "payload_screw_y_mm": payload_y,
            "status": "OK" if ok else "ERROR",
            "log_tail": "\n".join(p.stdout.strip().splitlines()[-10:])}


def render_pose(root: Path, outdir: Path, *, az: float, alt: float, name: str,
                payload_y: float | None = None) -> dict:
    src = root / "src/assemblies/tabletop_full_mount.scad"
    out = outdir / f"pose-{name}.png"
    cmd = ["xvfb-run", "-a", "openscad", "--preview=throwntogether",
           "--projection=o", "--autocenter", "--viewall", "--imgsize=900,700",
           "--camera=240,-260,190,0,0,80", "--view=edges",
           "-D", f"AZ_ANGLE={az}", "-D", f"ALT_ANGLE={alt}"]
    if payload_y is not None:
        cmd += ["-D", f"PAYLOAD_SCREW_Y={payload_y}"]
    cmd += ["-o", str(out), str(src)]
    p = run(cmd, root, timeout=120)
    ok = p.returncode == 0 and out.exists() and out.stat().st_size > 0
    return {"name": name, "az_deg": az, "alt_deg": alt,
            "payload_screw_y_mm": payload_y,
            "status": "OK" if ok else "ERROR",
            "file": str(out.relative_to(root)) if out.exists() else None,
            "log_tail": "\n".join(p.stdout.strip().splitlines()[-10:])}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", default="build/motion-qa")
    parser.add_argument("--clearance-margin", type=float, default=0.5)
    parser.add_argument("--alt-step", type=float, default=1.0)
    parser.add_argument("--slider-step", type=float, default=0.5)
    args = parser.parse_args()

    root = Path.cwd().resolve()
    outdir = (root / args.out).resolve()
    outdir.mkdir(parents=True, exist_ok=True)

    config = (root / "src/config.scad").read_text(encoding="utf-8")
    yoke_stage_z = (config_scalar(config, "AZ_BASE_PLATE_H") +
                    config_scalar(config, "AZ_COVER_H") +
                    config_scalar(config, "AZ_GLIDE_GAP") +
                    config_scalar(config, "AZ_TURNTABLE_H"))
    slot_floor = config_scalar(config, "YOKE_BRIDGE_H") - config_scalar(config, "YOKE_SLOT_DEPTH")
    axis_z = yoke_stage_z + slot_floor + config_scalar(config, "YOKE_AXIS_Z")

    slot_length = config_scalar(config, "PAYLOAD_SLOT_L")
    slot_diameter = config_scalar(config, "TRIPOD_CLEARANCE_D")
    slot_center = config_scalar(config, "PAYLOAD_SLOT_CENTER_Y")
    slider_travel = slot_length - slot_diameter
    slider_min = slot_center - slider_travel / 2
    slider_max = slot_center + slider_travel / 2

    payload, payload_meta = export_diag_mesh(root, outdir, mode=10, name="payload-structural-body")
    fastener, fastener_meta = export_diag_mesh(root, outdir, mode=13, name="payload-adjustable-fastener")
    upper, upper_meta = export_diag_mesh(root, outdir, mode=11, name="upper-obstructions")
    lower, lower_meta = export_diag_mesh(root, outdir, mode=12, name="lower-conservative",
                                         tabletop=True, margin=0.0)
    lower_margin, lower_margin_meta = export_diag_mesh(
        root, outdir, mode=12, name="lower-conservative-margin",
        tabletop=True, margin=args.clearance_margin)

    alt_values = values_inclusive(-20.0, 90.0, args.alt_step)
    slider_values = values_inclusive(slider_min, slider_max, args.slider_step)

    upper_sweep = collision_sweep(payload, upper, axis_z=axis_z,
                                  alt_values=alt_values, name="upper")
    lower_sweep = collision_sweep(payload, lower, axis_z=axis_z,
                                  alt_values=alt_values, name="lower")
    lower_margin_sweep = collision_sweep(payload, lower_margin, axis_z=axis_z,
                                         alt_values=alt_values,
                                         name=f"lower-expanded-{args.clearance_margin}mm")

    # Full ALT × payload-adjustment Cartesian grid for the adjustable fastener.
    fastener_upper_grid = fastener_collision_grid(
        fastener, upper, axis_z=axis_z, alt_values=alt_values,
        slider_values=slider_values, name="fastener-vs-upper")
    fastener_lower_grid = fastener_collision_grid(
        fastener, lower, axis_z=axis_z, alt_values=alt_values,
        slider_values=slider_values, name="fastener-vs-lower")
    # Clearance is proven by collision-testing the already expanded lower body.
    fastener_lower_margin_grid = fastener_collision_grid(
        fastener, lower_margin, axis_z=axis_z, alt_values=alt_values,
        slider_values=slider_values, name="fastener-vs-expanded-lower")

    analytic_out = outdir / "analytic-clearance.csg"
    analytic = run(["openscad", "-D", f"QA_MARGIN={args.clearance_margin}",
                    "-o", str(analytic_out),
                    str(root / "src/assemblies/motion_clearance_asserts.scad")], root)
    analytic_ok = analytic.returncode == 0 and analytic_out.exists() and not any(
        token in analytic.stdout for token in ("ERROR:", "Assertion", "Parser error"))
    analytic_out.unlink(missing_ok=True)

    # Actual-assembly AZ/coupled compilation guards against transform/wiring mistakes.
    pose_checks = []
    for az in range(0, 361, 10):
        pose_checks.append(compile_pose(root, outdir, az=az, alt=0,
                                        label=f"az-{az:03d}-alt000"))
    for az in [0,45,90,135,180,225,270,315]:
        for alt in [-20,0,45,90]:
            pose_checks.append(compile_pose(root, outdir, az=az, alt=alt,
                                            label=f"grid-az{az:03d}-alt{alt:+04d}"))

    for payload_y, y_label in [(slider_min, "min"), (slider_max, "max")]:
        for alt in [-20, 0, 90]:
            pose_checks.append(compile_pose(
                root, outdir, az=0, alt=alt,
                payload_y=payload_y,
                label=f"slider-{y_label}-alt{alt:+04d}"))

    review_poses = []
    for az, alt in [(0,-20),(0,0),(0,45),(0,90),(90,-20),(90,90),
                    (180,-20),(180,90),(270,-20),(270,90)]:
        review_poses.append(render_pose(root, outdir, az=az, alt=alt,
                                        name=f"tabletop-az{az:03d}-alt{alt:+04d}"))
    for payload_y, y_label in [(slider_min, "min"), (slider_max, "max")]:
        review_poses.append(render_pose(root, outdir, az=0, alt=-20,
                                        payload_y=payload_y,
                                        name=f"slider-{y_label}-alt-020"))
        review_poses.append(render_pose(root, outdir, az=0, alt=90,
                                        payload_y=payload_y,
                                        name=f"slider-{y_label}-alt+090"))

    failures = []
    for sweep in (upper_sweep, lower_sweep, lower_margin_sweep,
                  fastener_upper_grid, fastener_lower_grid, fastener_lower_margin_grid):
        if sweep["status"] != "CLEAR":
            failures.append(sweep)
    if not analytic_ok:
        failures.append({"analytic_clearance": "ERROR", "log": analytic.stdout[-2000:]})
    failures += [x for x in pose_checks if x["status"] != "OK"]
    failures += [x for x in review_poses if x["status"] != "OK"]

    report = {
        "protocols": ["MOTION_QA_PROTOCOL.md", "MECHANICAL_INTEGRITY_PROTOCOL.md"],
        "plan": "docs/motion-sweep-plan.md",
        "axis_z_mm": axis_z,
        "slider_range_mm": [slider_min, slider_max],
        "symmetry_basis": (
            "Upper structure, payload and payload fastener undergo the same rigid AZ rotation. "
            "The lower diagnostic mesh is a conservative rotationally symmetric superset of the "
            "actual lower exterior. Therefore current rigid collision relationships do not depend on AZ."
        ),
        "diagnostic_meshes": {
            "payload_structural": payload_meta,
            "payload_fastener": fastener_meta,
            "upper": upper_meta,
            "lower": lower_meta,
            "lower_margin": lower_margin_meta,
        },
        "upper_sweep": upper_sweep,
        "lower_sweep": lower_sweep,
        "lower_margin_sweep": lower_margin_sweep,
        "fastener_upper_grid": fastener_upper_grid,
        "fastener_lower_grid": fastener_lower_grid,
        "fastener_lower_margin_grid": fastener_lower_margin_grid,
        "analytic_clearance": {
            "status": "OK" if analytic_ok else "ERROR",
            "log_tail": "\n".join(analytic.stdout.strip().splitlines()[-12:]),
        },
        "pose_compile_checks": pose_checks,
        "review_poses": review_poses,
    }
    summary = {
        "result": "PASS" if not failures else "FAIL",
        "alt_step_deg": args.alt_step,
        "alt_samples": len(alt_values),
        "slider_step_mm": args.slider_step,
        "slider_samples": len(slider_values),
        "fastener_alt_slider_states_per_obstruction": len(alt_values) * len(slider_values),
        "fastener_external_grid_obstructions": 3,
        "upper_min_distance_mm": upper_sweep["minimum_distance_mm"],
        "upper_min_distance_alt_deg": upper_sweep["minimum_distance_alt_deg"],
        "lower_min_distance_mm": lower_sweep["minimum_distance_mm"],
        "lower_min_distance_alt_deg": lower_sweep["minimum_distance_alt_deg"],
        "expanded_lower_min_distance_mm": lower_margin_sweep["minimum_distance_mm"],
        "expanded_lower_min_distance_alt_deg": lower_margin_sweep["minimum_distance_alt_deg"],
        "clearance_margin_mm": args.clearance_margin,
        "az_compile_samples": 37,
        "coupled_grid_configurations": 32,
        "additional_slider_endpoint_compile_checks": 6,
        "review_poses": len(review_poses),
        "failures": len(failures),
    }
    report["summary"] = summary
    (outdir / "motion-qa.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    grid_states = len(alt_values) * len(slider_values)
    md = ["# Motion QA run", "", f"Result: **{summary['result']}**", "",
          f"- ALT structural sweep: -20°..90° every {args.alt_step:g}° ({len(alt_values)} samples).",
          f"- Payload balancing range: {slider_min:.3f}..{slider_max:.3f} mm every {args.slider_step:.3f} mm ({len(slider_values)} samples).",
          f"- Adjustable fastener grid: {grid_states} ALT×slider states against each of 3 obstruction envelopes ({grid_states * 3} collision queries).",
          f"- Minimum payload structural body→upper distance: {summary['upper_min_distance_mm']:.3f} mm at ALT {summary['upper_min_distance_alt_deg']}°.",
          f"- Minimum payload→lower conservative-envelope distance: {summary['lower_min_distance_mm']:.3f} mm at ALT {summary['lower_min_distance_alt_deg']}°.",
          f"- Expanded lower-envelope ({args.clearance_margin:.2f} mm) minimum structural distance: {summary['expanded_lower_min_distance_mm']:.3f} mm at ALT {summary['expanded_lower_min_distance_alt_deg']}°.",
          "- AZ compile sweep: 0°..360° every 10°, including wrap endpoint.",
          "- Coupled grid: 8 AZ positions × 4 ALT positions = 32 configurations.",
          "- Actual full assembly also compiles at both payload-slider endpoints for ALT -20°, 0°, 90°.",
          f"- Human-review renders: {len(review_poses)}.", "",
          "## AZ symmetry basis", "", report["symmetry_basis"], ""]
    if failures:
        md += ["## Failures", "", f"Failure count: {len(failures)}. See motion-qa.json for details."]
    else:
        md += ["No forbidden rigid-body collision was found in the sampled operational/adjustment state space.", "",
               "Internal payload fastener↔shaft/clamp exclusion and its positive clearances are additionally checked by tools/payload_adjustment_qa.py.", "",
               "Physical cable routing, backlash, compliance, printer fit, torque and tabletop overturn stability remain separate verification gates."]
    (outdir / "SUMMARY.md").write_text("\n".join(md) + "\n", encoding="utf-8")
    print(json.dumps(summary, indent=2))
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
