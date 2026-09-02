#!/usr/bin/env python3
"""Prebuild expensive browser-review STL assemblies using native OpenSCAD."""

from __future__ import annotations

import argparse
import json
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

SKIP_NAMES = {
    "motion_collision_check.scad",
    "motion_clearance_asserts.scad",
    "motion_collision_batch.scad",
    "motion_mesh_export.scad",
}
REQUIRED = {
    "assemblies/full_mount.scad",
    "assemblies/tabletop_full_mount.scad",
}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", default="site/scad-manifest.json")
    parser.add_argument("--src", default="src")
    parser.add_argument("--output", default="site/prebuilt")
    parser.add_argument("--workers", type=int, default=2)
    parser.add_argument("--timeout", type=int, default=240)
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    src_root = Path(args.src)
    out_root = Path(args.output)
    out_root.mkdir(parents=True, exist_ok=True)

    def build(entry: dict) -> tuple[str, str | None, str | None]:
        rel = entry["path"]
        # Only assemblies are worth prebuilding. Parts/calibration coupons render
        # quickly in the Web Worker and should not make Pages deployment scale with
        # the number of elementary parts.
        if not rel.startswith("assemblies/"):
            return rel, None, "on-demand worker render"
        if Path(rel).name in SKIP_NAMES:
            return rel, None, "diagnostic entry skipped"

        src = src_root / rel
        out_rel = Path(rel).with_suffix(".stl").as_posix()
        out = out_root / out_rel
        out.parent.mkdir(parents=True, exist_ok=True)
        command = ["xvfb-run", "-a", "openscad", "-o", str(out), str(src)]
        try:
            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                timeout=args.timeout,
                check=False,
            )
        except subprocess.TimeoutExpired:
            return rel, None, f"native preview timed out after {args.timeout} s"

        if result.returncode != 0 or not out.exists() or out.stat().st_size < 100:
            if out.exists():
                out.unlink()
            tail = (result.stderr or result.stdout or "render failed")[-800:].replace("\n", " ")
            return rel, None, tail
        return rel, out_rel, None

    entries = data["entries"]
    results: dict[str, tuple[str | None, str | None]] = {}
    with ThreadPoolExecutor(max_workers=max(1, args.workers)) as pool:
        futures = {pool.submit(build, entry): entry for entry in entries}
        for future in as_completed(futures):
            rel, prebuilt, error = future.result()
            results[rel] = (prebuilt, error)
            if prebuilt:
                print(f"PREBUILT {rel} -> {prebuilt}")
            elif rel.startswith("assemblies/"):
                print(f"NO PREBUILD {rel}: {error}")

    for entry in entries:
        prebuilt, error = results[entry["path"]]
        if prebuilt:
            entry["prebuilt"] = prebuilt
        elif error and entry["path"].startswith("assemblies/"):
            entry["prebuilt_error"] = error

    missing = [
        path for path in REQUIRED
        if not next((entry.get("prebuilt") for entry in entries if entry["path"] == path), None)
    ]
    if missing:
        raise SystemExit(f"critical published previews failed: {missing}")

    manifest_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    count = sum(1 for entry in entries if entry.get("prebuilt"))
    print(f"published assembly STL previews: {count}/{len(entries)} entries")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
