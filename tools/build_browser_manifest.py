#!/usr/bin/env python3
"""Build GitHub Pages SCAD manifest with static include/use dependency closures."""

from __future__ import annotations

import argparse
import hashlib
import json
import posixpath
import re
from pathlib import Path

INCLUDE_RE = re.compile(r"(?m)^\s*(?:include|use)\s*<([^>]+)>")
ENTRY_PREFIXES = ("parts/", "assemblies/", "adapters/", "calibration/")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--src", default="src")
    parser.add_argument("--output", default="site/scad-manifest.json")
    parser.add_argument("--repository", required=True)
    parser.add_argument("--commit", required=True)
    args = parser.parse_args()

    root = Path(args.src)
    paths = sorted(path.relative_to(root).as_posix() for path in root.rglob("*.scad"))
    if not paths:
        raise SystemExit("no SCAD sources found")

    path_set = set(paths)
    files: list[dict[str, str]] = []
    direct: dict[str, list[str]] = {}
    unresolved: dict[str, list[str]] = {}

    for rel in paths:
        path = root / rel
        data = path.read_bytes()
        files.append({"path": rel, "sha256": hashlib.sha256(data).hexdigest()})
        text = data.decode("utf-8")
        deps: list[str] = []
        missing: list[str] = []
        for token in INCLUDE_RE.findall(text):
            candidate = posixpath.normpath(posixpath.join(posixpath.dirname(rel), token))
            root_candidate = posixpath.normpath(token)
            if candidate in path_set:
                deps.append(candidate)
            elif root_candidate in path_set:
                deps.append(root_candidate)
            else:
                missing.append(token)
        direct[rel] = sorted(set(deps))
        if missing:
            unresolved[rel] = sorted(set(missing))

    def closure(rel: str) -> list[str]:
        seen: set[str] = set()
        stack = [rel]
        external = False
        while stack:
            current = stack.pop()
            if current in seen:
                continue
            seen.add(current)
            external = external or current in unresolved
            stack.extend(direct.get(current, []))
        # Preserve legacy safety if an external include cannot be statically resolved.
        return sorted(path_set if external else seen)

    entries = []
    for rel in paths:
        if rel.startswith(ENTRY_PREFIXES):
            entries.append({
                "path": rel,
                "label": f"{Path(rel).stem.replace('_', ' ')} — {rel}",
                "dependencies": closure(rel),
            })
    if not entries:
        entries = [{"path": rel, "label": rel, "dependencies": closure(rel)} for rel in paths]

    manifest = {
        "repository": args.repository,
        "commit": args.commit,
        "renderer": {
            "browser": "OpenSCAD 2025.03.25 wasm24456 + Manifold",
            "worker": True,
        },
        "files": files,
        "entries": entries,
    }

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

    if unresolved:
        print("Unresolved external includes; affected entries fall back to mounting all sources:")
        for rel, missing in sorted(unresolved.items()):
            print(f"  {rel}: {', '.join(missing)}")
    else:
        print("All include/use dependencies resolved inside repository snapshot.")

    sizes = [len(entry["dependencies"]) for entry in entries]
    print(
        f"manifest: {len(files)} files, {len(entries)} entries; "
        f"dependency closure min={min(sizes)}, max={max(sizes)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
