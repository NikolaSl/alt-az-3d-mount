#!/usr/bin/env python3
"""Prebuild a bounded set of high-cost browser-review STL assemblies."""

from __future__ import annotations

import argparse
import json
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

# Keep this list intentionally small and measured-cost driven. The background
# Web Worker renders ordinary parts/subassemblies without freezing the page.
# Add another entry here only when its real mobile render cost justifies a CI cache.
PREBUILD = {
    "assemblies/full_mount.scad",
    "assemblies/tabletop_full_mount.scad",
}
REQUIRED = set(PREBUILD)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", default="site/scad-manifest.json")
    parser.add_argument("--src", default="src")
    parser.add_argument("--output", default="site/prebuilt")
    parser.add_argument("--workers", type=int, default=2)
    parser.add_argument("--timeout", type=int, default=300)
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    src_root = Path(args.src)
    out_root = Path(args.output)
    out_root.mkdir(parents=True, exist_ok=True)

    entries_by_path = {entry["path"]: entry for entry in data["entries"]}
    unknown = PREBUILD - entries_by_path.keys()
    if unknown:
        raise SystemExit(f"prebuild entry does not exist in manifest: {sorted(unknown)}")

    def build(rel: str) -> tuple[str, str | None, str | None]:
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

    results: dict[str, tuple[str | None, str | None]] = {}
    with ThreadPoolExecutor(max_workers=max(1, min(args.workers, len(PREBUILD)))) as pool:
        futures = {pool.submit(build, rel): rel for rel in sorted(PREBUILD)}
        for future in as_completed(futures):
            rel, prebuilt, error = future.result()
            results[rel] = (prebuilt, error)
            if prebuilt:
                print(f"PREBUILT {rel} -> {prebuilt}")
            else:
                print(f"NO PREBUILD {rel}: {error}")

    for rel in PREBUILD:
        entry = entries_by_path[rel]
        prebuilt, error = results[rel]
        if prebuilt:
            entry["prebuilt"] = prebuilt
        elif error:
            entry["prebuilt_error"] = error

    missing = [
        path for path in REQUIRED
        if not entries_by_path[path].get("prebuilt")
    ]
    if missing:
        raise SystemExit(f"critical published previews failed: {missing}")

    manifest_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"published high-cost assembly STL previews: {len(PREBUILD)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
