#!/usr/bin/env python3
"""Automated sampled motion/collision QA for the Alt-Az mount.

The script intentionally separates:
- dense sampled collision sweeps (exact geometry),
- smaller safety-clearance sweeps (moving payload inflated by a margin), and
- human-review PNG poses.

An exported collision intersection must be empty. Any non-empty STL is a failure.
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
    # Binary STL: 80-byte header + uint32 triangle count.
    if len(data) >= 84:
        n = struct.unpack("<I", data[80:84])[0]
        if 84 + 50 * n == len(data):
            return int(n)
    # ASCII STL fallback.
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
        "openscad",
        "--render",
        "-D", f"AZ_ANGLE={az}",
        "-D", f"ALT_ANGLE={alt}",
        "-D", f"CHECK_MODE={mode}",
        "-D", f"WITH_TABLETOP={'true' if tabletop else 'false'}",
        "-D", f"CLEARANCE_MARGIN={margin}",
        "-o", str(out),
        str(src),
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
        "mode": "upper" if mode == 0 else "lower",
        "tabletop": tabletop,
        "clearance_margin_mm": margin,
        "triangles": triangles,
        "returncode": p.returncode,
        "log_tail": "\n".join(log.strip().splitlines()[-14:]),
    }


def render_pose(root: Path, outdir: Path, *, az: float, alt: float, tabletop: bool, name: str) -> dict:
    src = root / (
        "src/assemblies/tabletop_full_mount.scad"
        if tabletop
        else "src/assemblies/full_mount.scad"
    )
    out = outdir / f"pose-{name}.png"
    cmd = [
        "xvfb-run", "-a", "openscad",
        "--preview=throwntogether",
        "--projection=o",
        "--autocenter",
        "--viewall",
        "--imgsize=900,700",
        "--camera=240,-260,190,0,0,80",
        "--view=edges",
        "-D", f"AZ_ANGLE={az}",
        "-D", f"ALT_ANGLE={alt}",
        "-o", str(out),
        str(src),
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


def frange_int(start: int, stop: int, step: int) -> list[int]:
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
        "exact_collision_checks": [],
        "clearance_checks": [],
        "review_poses": [],
    }

    failures: list[dict] = []

    def check(bucket: str, **kwargs) -> None:
        result = collision_check(root, outdir, **kwargs)
        report[bucket].append(result)
        if result["status"] != "CLEAR":
            failures.append(result)

    # 1) Independent ALT sweep: complete intended range at 5-degree resolution.
    alt_values = frange_int(-20, 90, 5)
    for alt in alt_values:
        for mode in (0, 1):
            check(
                "exact_collision_checks",
                az=0,
                alt=alt,
                mode=mode,
                tabletop=True,
                margin=0.0,
                label=f"alt-{alt:+04d}-m{mode}",
            )

    # 2) Independent AZ sweep: full wrap at 10-degree resolution, including 360.
    az_values = frange_int(0, 360, 10)
    for az in az_values:
        check(
            "exact_collision_checks",
            az=az,
            alt=0,
            mode=1,
            tabletop=True,
            margin=0.0,
            label=f"az-{az:03d}-lower",
        )

    # 3) Coupled configuration grid from the project motion plan.
    coupled_az = [0, 45, 90, 135, 180, 225, 270, 315]
    coupled_alt = [-20, 0, 45, 90]
    for az in coupled_az:
        for alt in coupled_alt:
            for mode in (0, 1):
                check(
                    "exact_collision_checks",
                    az=az,
                    alt=alt,
                    mode=mode,
                    tabletop=True,
                    margin=0.0,
                    label=f"grid-az{az:03d}-alt{alt:+04d}-m{mode}",
                )

    # 4) Safety-clearance check: inflate moving payload by the selected margin.
    # Use endpoints, neutral and a middle pose across four AZ quadrants.
    clearance_az = [0, 90, 180, 270]
    clearance_alt = [-20, 0, 45, 90]
    for az in clearance_az:
        for alt in clearance_alt:
            for mode in (0, 1):
                check(
                    "clearance_checks",
                    az=az,
                    alt=alt,
                    mode=mode,
                    tabletop=True,
                    margin=args.clearance_margin,
                    label=f"margin-az{az:03d}-alt{alt:+04d}-m{mode}",
                )

    # 5) Human-review poses. Browser rendering remains the primary interactive
    # review path; these static images make the CI artifact independently useful.
    poses = [
        (0, -20), (0, 0), (0, 45), (0, 90),
        (90, -20), (90, 90),
        (180, -20), (180, 90),
        (270, -20), (270, 90),
    ]
    for az, alt in poses:
        pose = render_pose(
            root,
            outdir,
            az=az,
            alt=alt,
            tabletop=True,
            name=f"tabletop-az{az:03d}-alt{alt:+04d}",
        )
        report["review_poses"].append(pose)
        if pose["status"] != "OK":
            failures.append(pose)

    report["summary"] = {
        "alt_sweep_deg": [min(alt_values), max(alt_values), 5],
        "az_sweep_deg": [min(az_values), max(az_values), 10],
        "coupled_grid_configurations": len(coupled_az) * len(coupled_alt),
        "clearance_margin_mm": args.clearance_margin,
        "exact_checks": len(report["exact_collision_checks"]),
        "clearance_checks": len(report["clearance_checks"]),
        "review_poses": len(report["review_poses"]),
        "failures": len(failures),
        "result": "PASS" if not failures else "FAIL",
    }

    (outdir / "motion-qa.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    summary = report["summary"]
    md = [
        "# Motion QA run",
        "",
        f"Result: **{summary['result']}**",
        "",
        f"- ALT exact sweep: {summary['alt_sweep_deg'][0]}°..{summary['alt_sweep_deg'][1]}° every {summary['alt_sweep_deg'][2]}°",
        f"- AZ exact sweep: {summary['az_sweep_deg'][0]}°..{summary['az_sweep_deg'][1]}° every {summary['az_sweep_deg'][2]}° (including wrap endpoint)",
        f"- Coupled grid: {summary['coupled_grid_configurations']} configurations",
        f"- Safety-clearance sample margin: {summary['clearance_margin_mm']} mm",
        f"- Exact collision checks: {summary['exact_checks']}",
        f"- Clearance checks: {summary['clearance_checks']}",
        f"- Static review poses: {summary['review_poses']}",
        f"- Failures: {summary['failures']}",
        "",
    ]
    if failures:
        md.append("## Failures")
        md.append("")
        for item in failures:
            md.append(f"- `{item}`")
    else:
        md.extend([
            "No sampled collision or 0.5 mm safety-clearance violation was detected by the diagnostic geometry.",
            "Physical fit, cable routing, backlash, compliance and stability remain separate verification gates.",
        ])
    (outdir / "SUMMARY.md").write_text("\n".join(md) + "\n", encoding="utf-8")

    print(json.dumps(summary, indent=2))
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
