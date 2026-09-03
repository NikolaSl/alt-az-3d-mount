#!/usr/bin/env python3
"""Dense internal solid-pair QA for the payload balancing adjustment.

The payload screw/knob and the ALT shaft/clamps share the same operational ALT
transform, so ordinary moving-vs-fixed motion QA cannot reveal collisions among
them. This tool treats the balancing slot as an adjustment-state DOF and sweeps
the complete allowed screw-center travel against every forbidden internal solid.
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


def run(cmd: list[str], cwd: Path, timeout: int = 300) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, text=True, check=False,
                          timeout=timeout)


def scalar(text: str, name: str) -> float:
    match = re.search(rf"^\s*{re.escape(name)}\s*=\s*(-?[0-9]+(?:\.[0-9]+)?)\s*;",
                      text, flags=re.MULTILINE)
    if not match:
        raise RuntimeError(f"Cannot read numeric scalar {name} from src/config.scad")
    return float(match.group(1))


def values_inclusive(start: float, stop: float, step: float) -> list[float]:
    if step <= 0 or stop < start:
        raise ValueError("step must be positive and min <= max")
    values, value = [], start
    eps = abs(step) * 1e-9 + 1e-9
    while value <= stop + eps:
        values.append(round(value, 10))
        value += step
    if not math.isclose(values[-1], stop, rel_tol=0, abs_tol=eps):
        values.append(stop)
    return values


def export_mesh(root: Path, outdir: Path, mode: int, name: str) -> tuple[trimesh.Trimesh, dict]:
    src = root / "src/assemblies/payload_adjustment_collision_check.scad"
    out = outdir / f"{name}.stl"
    proc = run(["openscad", "--render", "--hardwarnings",
                "-D", f"CHECK_MODE={mode}", "-o", str(out), str(src)], root)
    if proc.returncode != 0 or not out.exists() or out.stat().st_size == 0:
        raise RuntimeError(f"Cannot export {name}:\n{proc.stdout}")
    mesh = trimesh.load_mesh(out, force="mesh", process=False)
    if not isinstance(mesh, trimesh.Trimesh) or len(mesh.faces) == 0:
        raise RuntimeError(f"Invalid/empty mesh for {name}")
    return mesh, {
        "file": str(out.relative_to(root)),
        "vertices": int(len(mesh.vertices)),
        "faces": int(len(mesh.faces)),
        "watertight": bool(mesh.is_watertight),
        "bounds_mm": [float(x) for x in mesh.extents],
    }


def sweep(moving: trimesh.Trimesh, fixed: trimesh.Trimesh, values: list[float],
          required_clearance: float, name: str) -> dict:
    manager = CollisionManager()
    manager.add_object(name, fixed)
    samples, failures = [], []
    min_distance, min_at = math.inf, None
    tolerance = 1e-6
    for y in values:
        transform = translation_matrix(np.array([0.0, y, 0.0]))
        collision = bool(manager.in_collision_single(moving, transform=transform))
        distance = float(manager.min_distance_single(moving, transform=transform))
        clear = (not collision) and distance + tolerance >= required_clearance
        samples.append({
            "payload_screw_y_mm": y,
            "collision": collision,
            "distance_mm": distance,
            "required_clearance_mm": required_clearance,
            "clearance_ok": clear,
        })
        if not clear:
            failures.append(y)
        if distance < min_distance:
            min_distance, min_at = distance, y
    return {
        "name": name,
        "status": "CLEAR" if not failures else "FAIL",
        "sample_count": len(samples),
        "minimum_distance_mm": min_distance,
        "minimum_distance_at_y_mm": min_at,
        "required_clearance_mm": required_clearance,
        "failure_y_mm": failures,
        "samples": samples,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--step", type=float, default=0.5)
    parser.add_argument("--out", default="build/motion-qa/payload-adjustment")
    args = parser.parse_args()

    root = Path.cwd().resolve()
    outdir = (root / args.out).resolve()
    outdir.mkdir(parents=True, exist_ok=True)
    config = (root / "src/config.scad").read_text(encoding="utf-8")

    slot_length = scalar(config, "PAYLOAD_SLOT_L")
    slot_diameter = scalar(config, "TRIPOD_CLEARANCE_D")
    center_y = scalar(config, "PAYLOAD_SLOT_CENTER_Y")
    travel = slot_length - slot_diameter
    min_y = center_y - travel / 2
    max_y = center_y + travel / 2
    values = values_inclusive(min_y, max_y, args.step)

    moving, moving_meta = export_mesh(root, outdir, 10, "payload-fastener")
    shaft, shaft_meta = export_mesh(root, outdir, 11, "alt-shaft")
    clamps, clamps_meta = export_mesh(root, outdir, 12, "payload-clamps")

    shaft_check = sweep(moving, shaft, values,
                        scalar(config, "PAYLOAD_KNOB_SHAFT_CLEARANCE"),
                        "fastener-vs-alt-shaft")
    clamp_check = sweep(moving, clamps, values,
                        scalar(config, "PAYLOAD_ADJUSTMENT_MIN_CLEARANCE"),
                        "fastener-vs-payload-clamps")

    checks = [shaft_check, clamp_check]
    failures = [check for check in checks if check["status"] != "CLEAR"]
    report = {
        "protocol": "MECHANICAL_INTEGRITY_PROTOCOL.md + MOTION_QA_PROTOCOL.md",
        "adjustment_contract": "M-PAYLOAD-SLIDE / K-003 / I-029",
        "range_mm": [min_y, max_y],
        "step_mm": args.step,
        "sample_count": len(values),
        "intentional_contacts_excluded": [
            "1/4-20 screw through payload-plate slot",
            "knob top clamping against payload-plate underside",
            "ALT shaft inside its split-clamp bores",
        ],
        "meshes": {
            "moving_fastener": moving_meta,
            "shaft": shaft_meta,
            "clamps": clamps_meta,
        },
        "checks": checks,
        "result": "PASS" if not failures else "FAIL",
    }
    (outdir / "payload-adjustment-qa.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Payload adjustment solid-pair QA", "",
        f"Result: **{report['result']}**", "",
        f"- Screw-center balancing travel: {min_y:.3f} .. {max_y:.3f} mm.",
        f"- Sweep interval: {args.step:.3f} mm; {len(values)} sampled states including endpoints.",
    ]
    for check in checks:
        lines.append(
            f"- `{check['name']}`: {check['status']}; minimum distance "
            f"{check['minimum_distance_mm']:.3f} mm at Y={check['minimum_distance_at_y_mm']:.3f} mm; "
            f"required {check['required_clearance_mm']:.3f} mm."
        )
    lines += ["", "Intentional mating/contact pairs are explicitly excluded; all other tested solid overlap is forbidden."]
    (outdir / "SUMMARY.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"result": report["result"], "samples": len(values),
                      "failures": len(failures)}, indent=2))
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
