#!/usr/bin/env python3
"""Automated sampled two-axis motion QA for the Alt-Az mount.

Dense ALT collision poses are batched into a few OpenSCAD CGAL runs. If a batch
contains collision geometry, the script automatically falls back to per-pose
checks to locate the failing angles. AZ clearance is covered by the current
rotational-symmetry proof; actual assemblies are still compiled across the AZ
and coupled AZ/ALT grids and representative poses are rendered for human review.
"""

from __future__ import annotations

import argparse
import json
import re
import struct
import subprocess
from pathlib import Path


def run(cmd: list[str], cwd: Path, timeout: int = 180) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, text=True, check=False,
                          timeout=timeout)


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


def classify_empty_stl(p: subprocess.CompletedProcess[str], out: Path) -> tuple[str, int, str]:
    log = p.stdout
    fatal = any(token in log for token in ("ERROR:", "Parser error", "Can't parse file"))
    triangles = stl_triangle_count(out)
    empty_reported = "Current top level object is empty" in log
    if fatal:
        status = "ERROR"
    elif triangles > 0:
        status = "COLLISION"
    elif p.returncode == 0 or empty_reported:
        status = "CLEAR"
    else:
        status = "ERROR"
    return status, triangles, "\n".join(log.strip().splitlines()[-14:])


def batch_collision(root: Path, outdir: Path, *, mode: int, margin: float, label: str) -> dict:
    src = root / "src/assemblies/motion_collision_sweep.scad"
    out = outdir / f"batch-{label}.stl"
    out.unlink(missing_ok=True)
    cmd = ["openscad", "--render", "-D", f"MODE={mode}",
           "-D", f"MARGIN={margin}", "-o", str(out), str(src)]
    try:
        p = run(cmd, root, timeout=300)
        status, triangles, log_tail = classify_empty_stl(p, out)
        returncode = p.returncode
    except subprocess.TimeoutExpired:
        status, triangles, returncode = "TIMEOUT", 0, -1
        log_tail = "OpenSCAD batch collision sweep exceeded 300 seconds"
    if status != "COLLISION":
        out.unlink(missing_ok=True)
    return {"status": status, "mode": mode, "margin_mm": margin,
            "triangles": triangles, "returncode": returncode,
            "file": str(out.relative_to(root)) if out.exists() else None,
            "log_tail": log_tail}


def single_collision(root: Path, outdir: Path, *, alt: float, mode: int,
                     margin: float, label: str) -> dict:
    src = root / "src/assemblies/motion_collision_check.scad"
    out = outdir / f"collision-{label}.stl"
    out.unlink(missing_ok=True)
    cmd = ["openscad", "--render", "-D", "AZ_ANGLE=0",
           "-D", f"ALT_ANGLE={alt}", "-D", f"CHECK_MODE={mode}",
           "-D", "WITH_TABLETOP=true", "-D", f"CLEARANCE_MARGIN={margin}",
           "-o", str(out), str(src)]
    try:
        p = run(cmd, root, timeout=120)
        status, triangles, log_tail = classify_empty_stl(p, out)
        returncode = p.returncode
    except subprocess.TimeoutExpired:
        status, triangles, returncode = "TIMEOUT", 0, -1
        log_tail = "OpenSCAD single collision check exceeded 120 seconds"
    if status != "COLLISION":
        out.unlink(missing_ok=True)
    return {"status": status, "alt_deg": alt, "mode": mode,
            "margin_mm": margin, "triangles": triangles,
            "returncode": returncode, "log_tail": log_tail}


def compile_scad(root: Path, outdir: Path, *, src: Path, defines: list[str], label: str) -> dict:
    out = outdir / f"compile-{label}.csg"
    out.unlink(missing_ok=True)
    cmd = ["openscad"]
    for definition in defines:
        cmd += ["-D", definition]
    cmd += ["-o", str(out), str(src)]
    try:
        p = run(cmd, root, timeout=120)
        log = p.stdout
        fatal = p.returncode != 0 or any(
            token in log for token in ("ERROR:", "Parser error", "Can't parse file", "Assertion")
        )
        status = "OK" if ((not fatal) and out.exists() and out.stat().st_size > 0) else "ERROR"
        log_tail = "\n".join(log.strip().splitlines()[-12:])
    except subprocess.TimeoutExpired:
        status, log_tail = "TIMEOUT", "OpenSCAD CSG compile exceeded 120 seconds"
    out.unlink(missing_ok=True)
    return {"status": status, "log_tail": log_tail}


def compile_pose(root: Path, outdir: Path, *, az: float, alt: float, label: str) -> dict:
    result = compile_scad(
        root, outdir, src=root / "src/assemblies/tabletop_full_mount.scad",
        defines=[f"AZ_ANGLE={az}", f"ALT_ANGLE={alt}"], label=label)
    return {**result, "az_deg": az, "alt_deg": alt}


def render_pose(root: Path, outdir: Path, *, az: float, alt: float, name: str) -> dict:
    src = root / "src/assemblies/tabletop_full_mount.scad"
    out = outdir / f"pose-{name}.png"
    cmd = ["xvfb-run", "-a", "openscad", "--preview=throwntogether",
           "--projection=o", "--autocenter", "--viewall", "--imgsize=900,700",
           "--camera=240,-260,190,0,0,80", "--view=edges",
           "-D", f"AZ_ANGLE={az}", "-D", f"ALT_ANGLE={alt}",
           "-o", str(out), str(src)]
    try:
        p = run(cmd, root, timeout=120)
        status = "OK" if (p.returncode == 0 and out.exists() and out.stat().st_size > 0) else "ERROR"
        log_tail = "\n".join(p.stdout.strip().splitlines()[-10:])
    except subprocess.TimeoutExpired:
        status, log_tail = "TIMEOUT", "OpenSCAD preview exceeded 120 seconds"
    return {"name": name, "az_deg": az, "alt_deg": alt, "status": status,
            "file": str(out.relative_to(root)) if out.exists() else None,
            "log_tail": log_tail}


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
            "Upper obstruction geometry rotates rigidly with AZ. Lower collision geometry "
            "is a conservative rotationally symmetric envelope, so ALT collision clearance "
            "proved at AZ=0 applies to the full current AZ range."
        ),
        "batch_collision_checks": [], "localized_failures": [],
        "analytic_clearance": None, "pose_compile_checks": [], "review_poses": [],
    }
    failures: list[dict] = []

    # A. Three CGAL batches: upper ALT sweep, lower ALT sweep, expanded lower margin.
    batches = [
        (0, 0.0, "upper-alt-sweep"),
        (1, 0.0, "lower-alt-sweep"),
        (2, args.clearance_margin, "lower-critical-margin"),
    ]
    for mode, margin, label in batches:
        result = batch_collision(root, outdir, mode=mode, margin=margin, label=label)
        report["batch_collision_checks"].append(result)
        if result["status"] != "CLEAR":
            failures.append(result)
            # Localize geometric collision batches, but do not explode time on infrastructure errors.
            if result["status"] == "COLLISION":
                alts = inclusive_range(-20, 90, 5) if mode in (0, 1) else [-20, 0, 45, 90]
                single_mode = mode if mode in (0, 1) else 1
                for alt in alts:
                    local = single_collision(
                        root, outdir, alt=alt, mode=single_mode,
                        margin=margin if mode == 2 else 0.0,
                        label=f"locate-{label}-alt{alt:+04d}")
                    if local["status"] != "CLEAR":
                        report["localized_failures"].append(local)

    # B. Invariant 0.5 mm side/bridge assertions.
    analytic = compile_scad(
        root, outdir, src=root / "src/assemblies/motion_clearance_asserts.scad",
        defines=[f"QA_MARGIN={args.clearance_margin}"], label="analytic-clearance")
    report["analytic_clearance"] = analytic
    if analytic["status"] != "OK":
        failures.append(analytic)

    # C. Full AZ sweep and coupled configuration grid compile the real assembly.
    az_values = inclusive_range(0, 360, 10)
    for az in az_values:
        result = compile_pose(root, outdir, az=az, alt=0, label=f"az-{az:03d}-alt000")
        report["pose_compile_checks"].append(result)
        if result["status"] != "OK": failures.append(result)

    coupled_az = [0, 45, 90, 135, 180, 225, 270, 315]
    coupled_alt = [-20, 0, 45, 90]
    for az in coupled_az:
        for alt in coupled_alt:
            result = compile_pose(root, outdir, az=az, alt=alt,
                                  label=f"grid-az{az:03d}-alt{alt:+04d}")
            report["pose_compile_checks"].append(result)
            if result["status"] != "OK": failures.append(result)

    # D. Representative actual renders for human review.
    poses = [(0,-20),(0,0),(0,45),(0,90),(90,-20),(90,90),
             (180,-20),(180,90),(270,-20),(270,90)]
    for az, alt in poses:
        result = render_pose(root, outdir, az=az, alt=alt,
                             name=f"tabletop-az{az:03d}-alt{alt:+04d}")
        report["review_poses"].append(result)
        if result["status"] != "OK": failures.append(result)

    summary = {
        "alt_collision_sample_count_per_exact_batch": len(inclusive_range(-20, 90, 5)),
        "alt_collision_step_deg": 5,
        "az_compile_sample_count": len(az_values),
        "az_compile_step_deg": 10,
        "coupled_grid_configurations": len(coupled_az) * len(coupled_alt),
        "clearance_margin_mm": args.clearance_margin,
        "batch_collision_runs": len(report["batch_collision_checks"]),
        "pose_compile_checks": len(report["pose_compile_checks"]),
        "review_poses": len(report["review_poses"]),
        "failures": len(failures), "result": "PASS" if not failures else "FAIL",
    }
    report["summary"] = summary
    (outdir / "motion-qa.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    md = ["# Motion QA run", "", f"Result: **{summary['result']}**", "", "## Coverage", "",
          "- ALT exact collision samples: -20°..90° every 5°, batched separately against upper and conservative lower/tabletop obstructions.",
          f"- Lower critical safety-margin check: {summary['clearance_margin_mm']} mm expanded envelope at -20°/0°/45°/90°.",
          "- Invariant side/bridge clearances: executable OpenSCAD assertions.",
          "- AZ assembly compile sweep: 0°..360° every 10°, including wrap endpoint.",
          f"- Coupled AZ/ALT grid: {summary['coupled_grid_configurations']} configurations.",
          f"- Human-review PNGs: {summary['review_poses']}.", "", "## Symmetry basis", "",
          report["symmetry_basis"], ""]
    if failures:
        md += ["## Failures", ""] + [f"- `{item}`" for item in failures]
    else:
        md += ["No sampled collision or configured safety-clearance violation was detected.", "",
               "Physical cable routing, backlash, compliance, printer fit, torque and tabletop overturn stability remain separate verification gates."]
    (outdir / "SUMMARY.md").write_text("\n".join(md) + "\n", encoding="utf-8")
    print(json.dumps(summary, indent=2))
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
