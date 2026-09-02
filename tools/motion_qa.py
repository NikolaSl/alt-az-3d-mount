#!/usr/bin/env python3
"""Automated sampled two-axis motion QA for the Alt-Az mount.

Strategy:
1. Collision-test the complete ALT range against both fixed upper structure and a
   conservative rotationally symmetric lower envelope.
2. Prove a small safety margin at critical ALT positions by inflating the moving
   payload geometry.
3. Compile the full 0..360 AZ sweep and the coupled AZ/ALT grid so every sampled
   configuration exercises the real assembly source and executable assertions.
4. Render representative poses for human review.

The lower collision envelope intentionally fills holes/cut-outs and is rotationally
symmetric. Therefore an ALT clearance result against it is valid for every AZ angle
of the present mechanical design. Future asymmetric attachments/cables must extend
this diagnostic instead of relying on that symmetry proof.
"""

from __future__ import annotations

import argparse
import json
import re
import struct
import subprocess
from pathlib import Path


def run(cmd: list[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        check=False,
    )


def stl_triangle_count(path: Path) -> int:
    if not path.exists() or path.stat().st_size == 0:
        return 0
    data = path.read_bytes()
    if len(data) >= 84:
        n = struct.unpack("<I", data[80:84])[0]
        if 84 + 50 * n == len(data):
            return int(n)
    text = data.decode("utf-8", errors="ignore")
    return len(re.findall(r"^\s*facet\s+normal\b", text, flags=re.MULTILINE))


def collision_check(
    root: Path,
    outdir: Path,
    *,
    az: float,
    alt: float,
    mode: int,
    tabletop: bool,
    margin: float,
    label: str,
) -> dict:
    src = root / "src/assemblies/motion_collision_check.scad"
    out = outdir / f"collision-{label}.stl"
    out.unlink(missing_ok=True)
    cmd = [
        "openscad", "--render",
        "-D", f"AZ_ANGLE={az}",
        "-D", f"ALT_ANGLE={alt}",
        "-D", f"CHECK_MODE={mode}",
        "-D", f"WITH_TABLETOP={'true' if tabletop else 'false'}",
        "-D", f"CLEARANCE_MARGIN={margin}",
        "-o", str(out), str(src),
    ]
    p = run(cmd, root)
    log = p.stdout
    fatal = any(token in log for token in ("ERROR:", "Parser error", "Can't parse file"))
    triangles = stl_triangle_count(out)
    collision = triangles > 0
    empty_reported = "Current top level object is empty" in log

    if fatal:
        status = "ERROR"
    elif collision:
        status = "COLLISION"
    elif p.returncode == 0 or empty_reported:
        status = "CLEAR"
    else:
        status = "ERROR"

    if not collision:
        out.unlink(missing_ok=True)

    return {
        "status": status,
        "az_deg": az,
        "alt_deg": alt,
        "mode": "upper" if mode == 0 else "lower-conservative-envelope",
        "tabletop": tabletop,
        "clearance_margin_mm": margin,
        "triangles": triangles,
        "returncode": p.returncode,
        "log_tail": "\n".join(log.strip().splitlines()[-12:]),
    }


def compile_pose(root: Path, outdir: Path, *, az: float, alt: float, tabletop: bool, label: str) -> dict:
    src = root / (
        "src/assemblies/tabletop_full_mount.scad" if tabletop
        else "src/assemblies/full_mount.scad"
    )
    out = outdir / f"compile-{label}.csg"
    out.unlink(missing_ok=True)
    cmd = [
        "openscad",
        "-D", f"AZ_ANGLE={az}",
        "-D", f"ALT_ANGLE={alt}",
        "-o", str(out), str(src),
    ]
    p = run(cmd, root)
    log = p.stdout
    fatal = p.returncode != 0 or any(
        token in log for token in ("ERROR:", "Parser error", "Can't parse file", "Assertion")
    )
    ok = (not fatal) and out.exists() and out.stat().st_size > 0
    out.unlink(missing_ok=True)
    return {
        "status": "OK" if ok else "ERROR",
        "az_deg": az,
        "alt_deg": alt,
        "tabletop": tabletop,
        "log_tail": "\n".join(log.strip().splitlines()[-10:]),
    }


def render_pose(root: Path, outdir: Path, *, az: float, alt: float, tabletop: bool, name: str) -> dict:
    src = root / (
        "src/assemblies/tabletop_full_mount.scad" if tabletop
        else "src/assemblies/full_mount.scad"
    )
    out = outdir / f"pose-{name}.png"
    cmd = [
        "xvfb-run", "-a", "openscad",
        "--preview=throwntogether", "--projection=o",
        "--autocenter", "--viewall", "--imgsize=900,700",
        "--camera=240,-260,190,0,0,80", "--view=edges",
        "-D", f"AZ_ANGLE={az}",
        "-D", f"ALT_ANGLE={alt}",
        "-o", str(out), str(src),
    ]
    p = run(cmd, root)
    ok = p.returncode == 0 and out.exists() and out.stat().st_size > 0
    return {
        "name": name,
        "az_deg": az,
        "alt_deg": alt,
        "tabletop": tabletop,
        "status": "OK" if ok else "ERROR",
        "file": str(out.relative_to(root)) if out.exists() else None,
        "log_tail": "\n".join(p.stdout.strip().splitlines()[-10:]),
    }


def inclusive_range(start: int, stop: int, step: int) -> list[int]:
    values = list(range(start, stop + 1, step))
    if values[-1] != stop:
        values.append(stop)
    return values


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", default="build/motion-qa")
    parser.add_argument("--clearance-margin", type=float, default=0.5)
    args = parser.parse_args()

    root = Path.cwd().resolve()
    outdir = (root / args.out).resolve()
    outdir.mkdir(parents=True, exist_ok=True)

    report: dict = {
        "protocol": "MOTION_QA_PROTOCOL.md",
        "plan": "docs/motion-sweep-plan.md",
        "symmetry_basis": (
            "Upper collision geometry rotates rigidly with AZ. Lower diagnostic is a "
            "conservative rotationally symmetric envelope, so ALT collision clearance "
            "proved at AZ=0 applies to the full current AZ range."
        ),
        "collision_checks": [],
        "clearance_checks": [],
        "pose_compile_checks": [],
        "review_poses": [],
    }
    failures: list[dict] = []

    def add(bucket: str, result: dict, expected: str) -> None:
        report[bucket].append(result)
        if result["status"] != expected:
            failures.append(result)

    # A. ALT exact collision sweep across the complete intended range.
    alt_values = inclusive_range(-20, 90, 5)
    for alt in alt_values:
        for mode in (0, 1):
            result = collision_check(
                root, outdir, az=0, alt=alt, mode=mode,
                tabletop=True, margin=0.0,
                label=f"alt-{alt:+04d}-m{mode}",
            )
            add("collision_checks", result, "CLEAR")

    # B. Safety-clearance proof at limits, reference and intermediate pose.
    critical_alt = [-20, 0, 45, 90]
    for alt in critical_alt:
        for mode in (0, 1):
            result = collision_check(
                root, outdir, az=0, alt=alt, mode=mode,
                tabletop=True, margin=args.clearance_margin,
                label=f"margin-alt{alt:+04d}-m{mode}",
            )
            add("clearance_checks", result, "CLEAR")

    # C. Full AZ sampled sweep. CSG compile is intentionally used here because
    # collision clearance is already proven by the rotational-envelope argument.
    az_values = inclusive_range(0, 360, 10)
    for az in az_values:
        result = compile_pose(
            root, outdir, az=az, alt=0, tabletop=True,
            label=f"az-{az:03d}-alt000",
        )
        add("pose_compile_checks", result, "OK")

    # D. Coupled configuration-space grid from the project plan.
    coupled_az = [0, 45, 90, 135, 180, 225, 270, 315]
    coupled_alt = [-20, 0, 45, 90]
    for az in coupled_az:
        for alt in coupled_alt:
            result = compile_pose(
                root, outdir, az=az, alt=alt, tabletop=True,
                label=f"grid-az{az:03d}-alt{alt:+04d}",
            )
            add("pose_compile_checks", result, "OK")

    # E. Static evidence for human review.
    poses = [
        (0, -20), (0, 0), (0, 45), (0, 90),
        (90, -20), (90, 90),
        (180, -20), (180, 90),
        (270, -20), (270, 90),
    ]
    for az, alt in poses:
        result = render_pose(
            root, outdir, az=az, alt=alt, tabletop=True,
            name=f"tabletop-az{az:03d}-alt{alt:+04d}",
        )
        add("review_poses", result, "OK")

    summary = {
        "alt_collision_sweep_deg": [-20, 90, 5],
        "az_compile_sweep_deg": [0, 360, 10],
        "coupled_grid_configurations": len(coupled_az) * len(coupled_alt),
        "clearance_margin_mm": args.clearance_margin,
        "collision_checks": len(report["collision_checks"]),
        "clearance_checks": len(report["clearance_checks"]),
        "pose_compile_checks": len(report["pose_compile_checks"]),
        "review_poses": len(report["review_poses"]),
        "failures": len(failures),
        "result": "PASS" if not failures else "FAIL",
    }
    report["summary"] = summary

    (outdir / "motion-qa.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    md = [
        "# Motion QA run", "", f"Result: **{summary['result']}**", "",
        "## Coverage", "",
        "- ALT collision sweep: -20°..90° every 5°, against upper structure and conservative lower/tabletop envelope.",
        "- AZ pose sweep: 0°..360° every 10°, including wrap endpoint.",
        f"- Coupled AZ/ALT grid: {summary['coupled_grid_configurations']} configurations.",
        f"- Critical-pose safety clearance: {summary['clearance_margin_mm']} mm moving-envelope inflation.",
        f"- Collision booleans: {summary['collision_checks']}.",
        f"- Safety-clearance booleans: {summary['clearance_checks']}.",
        f"- Assembly pose compile checks: {summary['pose_compile_checks']}.",
        f"- Human-review PNGs: {summary['review_poses']}.",
        "",
        "## Symmetry basis", "",
        report["symmetry_basis"], "",
    ]
    if failures:
        md += ["## Failures", ""] + [f"- `{item}`" for item in failures]
    else:
        md += [
            "No sampled collision or configured safety-clearance violation was detected.",
            "",
            "This does not replace physical checks for cable routing, backlash, compliance, printer fit, torque or tabletop overturn stability.",
        ]
    (outdir / "SUMMARY.md").write_text("\n".join(md) + "\n", encoding="utf-8")

    print(json.dumps(summary, indent=2))
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
