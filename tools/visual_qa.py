#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path

import matplotlib.pyplot as plt
import trimesh
from PIL import Image, ImageDraw

VIEWS = {
    "iso": "220,-220,170,0,0,0",
    "top": "0,0,300,0,0,0",
    "bottom": "0,0,-300,0,0,0",
    "front": "0,-300,40,0,0,0",
    "right": "300,0,40,0,0,0",
}


def run(cmd: list[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        check=False,
    )


def render_png(src: Path, out: Path, camera: str, cwd: Path) -> str:
    cmd = [
        "xvfb-run",
        "-a",
        "openscad",
        "--preview=throwntogether",
        "--projection=o",
        "--autocenter",
        "--viewall",
        "--imgsize=900,700",
        f"--camera={camera}",
        "--view=edges",
        "-o",
        str(out),
        str(src),
    ]
    p = run(cmd, cwd)
    if p.returncode != 0 or not out.exists():
        raise RuntimeError(f"PNG preview failed: {' '.join(cmd)}\n{p.stdout}")
    return p.stdout


def stl_check(src: Path, out: Path, cwd: Path) -> dict:
    p = run(
        ["openscad", "--render", "--hardwarnings", "-o", str(out), str(src)],
        cwd,
    )
    text = p.stdout
    simple = bool(re.search(r"Simple:\s+yes", text))
    stats = {}
    for key in ("Vertices", "Edges", "Facets", "Volumes"):
        match = re.search(rf"{key}:\s+(\d+)", text)
        if match:
            stats[key.lower()] = int(match.group(1))

    if p.returncode != 0 or not out.exists() or not simple:
        raise RuntimeError(f"STL/CGAL validation failed for {src}\n{text}")

    mesh = trimesh.load_mesh(out, force="mesh")
    stats["watertight"] = bool(mesh.is_watertight)
    stats["bounds_mm"] = [float(x) for x in mesh.extents]
    if not mesh.is_watertight:
        raise RuntimeError(f"Mesh is not watertight: {out}")

    return {"simple": simple, **stats, "log": text}


def section_plot(stl: Path, axis: str, out: Path) -> None:
    mesh = trimesh.load_mesh(stl, force="mesh")
    center = mesh.bounding_box.centroid

    if axis == "x":
        normal = [1, 0, 0]
        origin = [center[0], 0, 0]
        xlabel, ylabel = "Y (mm)", "Z (mm)"
    elif axis == "y":
        normal = [0, 1, 0]
        origin = [0, center[1], 0]
        xlabel, ylabel = "X (mm)", "Z (mm)"
    else:
        raise ValueError(axis)

    section = mesh.section(plane_origin=origin, plane_normal=normal)
    fig, ax = plt.subplots(figsize=(6, 5), dpi=150)
    if section is None:
        ax.text(
            0.5,
            0.5,
            "No intersection",
            ha="center",
            va="center",
            transform=ax.transAxes,
        )
    else:
        planar, _ = section.to_2D()
        for entity in planar.discrete:
            ax.plot(entity[:, 0], entity[:, 1], linewidth=1.3)

    ax.set_aspect("equal", adjustable="box")
    ax.grid(True, linewidth=0.35)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_title(f"Center section {axis.upper()}=0")
    fig.tight_layout()
    fig.savefig(out)
    plt.close(fig)


def contact_sheet(images: list[tuple[str, Path]], out: Path) -> None:
    thumbs = []
    for label, path in images:
        image = Image.open(path).convert("RGB")
        image.thumbnail((440, 340))
        canvas = Image.new("RGB", (460, 390), "white")
        x = (460 - image.width) // 2
        y = 30 + (340 - image.height) // 2
        canvas.paste(image, (x, y))
        ImageDraw.Draw(canvas).text((12, 8), label, fill="black")
        thumbs.append(canvas)

    cols = 3
    rows = (len(thumbs) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * 460, rows * 390), "white")
    for index, image in enumerate(thumbs):
        sheet.paste(image, ((index % cols) * 460, (index // cols) * 390))
    sheet.save(out)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("scad")
    parser.add_argument("--name")
    parser.add_argument("--out", default="build/qa")
    args = parser.parse_args()

    src = Path(args.scad).resolve()
    root = Path.cwd().resolve()
    name = args.name or src.stem
    outdir = root / args.out / name
    outdir.mkdir(parents=True, exist_ok=True)

    stl = outdir / f"{name}.stl"
    stats = stl_check(src, stl, root)
    rendered = []

    for view, camera in VIEWS.items():
        path = outdir / f"{view}.png"
        render_png(src, path, camera, root)
        rendered.append((view, path))

    for axis in ("x", "y"):
        path = outdir / f"section-{axis}.png"
        section_plot(stl, axis, path)
        rendered.append((f"section {axis}", path))

    contact_sheet(rendered, outdir / "contact-sheet.png")

    report = {key: value for key, value in stats.items() if key != "log"}
    report["source"] = str(src.relative_to(root))
    (outdir / "qa.json").write_text(json.dumps(report, indent=2) + "\n")

    print(json.dumps(report, indent=2))
    print(outdir / "contact-sheet.png")


if __name__ == "__main__":
    main()
