#!/usr/bin/env python3
"""Generate a deterministic Melange/Dune benchmark project."""

from __future__ import annotations

import argparse
from pathlib import Path
import shutil


def module_name(index: int) -> str:
    return f"Unit_{index:04d}"


def filename(index: int) -> str:
    return f"unit_{index:04d}.ml"


def sum_expression(terms: list[str]) -> str:
    while len(terms) > 1:
        terms = [
            "(" + " + ".join(terms[index : index + 16]) + ")"
            for index in range(0, len(terms), 16)
        ]
    return terms[0]


def source_for(index: int, topology: str, optimizer_width: int) -> str:
    if index == 0:
        dependency = "1"
    elif topology in {"chain", "optimizer"}:
        dependency = f"{module_name(index - 1)}.value + 1"
    elif topology == "wide":
        dependency = str(index + 1)
    elif topology == "diamond":
        left = module_name(index - 1)
        right = module_name(index // 2)
        dependency = f"{left}.value + {right}.value + 1"
    else:
        raise ValueError(f"unknown topology: {topology}")

    if topology != "optimizer":
        return f"let value = {dependency}\n"

    helpers = "\n".join(
        f"let helper_{helper} x = x + {helper + 1}"
        for helper in range(optimizer_width)
    )
    pipeline = " |> ".join(
        f"helper_{helper}" for helper in range(optimizer_width)
    )
    return (
        f"{helpers}\n"
        "let dead_branch x = if x = 0 then x + 1000 else x\n"
        f"let value = {dependency} |> {pipeline} |> dead_branch\n"
    )


def main_source(modules: int, topology: str) -> str:
    if topology == "wide":
        terms = [f"{module_name(index)}.value" for index in range(modules)]
        expression = sum_expression(terms)
    else:
        expression = f"{module_name(modules - 1)}.value"
    return f"let result = {expression}\n"


def generate(args: argparse.Namespace) -> None:
    root = args.root.resolve()
    if root in {Path(root.anchor), Path.home(), Path.cwd()}:
        raise SystemExit(f"refusing unsafe project root: {root}")
    marker = root / ".melange-delay-js-benchmark"
    if root.exists():
        if not marker.is_file():
            raise SystemExit(f"refusing to replace unmarked directory: {root}")
        shutil.rmtree(root)
    root.mkdir(parents=True)
    marker.write_text("generated benchmark project\n", encoding="utf-8")

    flag = {
        "eager": "--mel-eager-js-optimizations",
        "delayed": "--mel-delay-js-optimizations",
    }[args.mode]
    trace_flag = " --mel-action-trace" if args.action_trace else ""
    module_systems = {
        "single": "(module_systems (commonjs js))",
        "dual": "(module_systems (commonjs cjs) (esm mjs))",
    }[args.module_systems]

    (root / "dune-project").write_text(
        "(lang dune 3.24)\n(using melange 1.0)\n", encoding="utf-8"
    )
    (root / "dune").write_text(
        "(melange.emit\n"
        " (target output)\n"
        " (emit_stdlib false)\n"
        f" {module_systems}\n"
        f" (compile_flags :standard {flag}{trace_flag} --mel-cross-module-opt))\n",
        encoding="utf-8",
    )

    for index in range(args.modules):
        source = source_for(index, args.topology, args.optimizer_width)
        (root / filename(index)).write_text(source, encoding="utf-8")
    (root / "main.ml").write_text(
        main_source(args.modules, args.topology), encoding="utf-8"
    )

    leaf = root / filename(0)
    baseline = leaf.read_text(encoding="utf-8")
    (root / f"{filename(0)}.baseline").write_text(baseline, encoding="utf-8")
    (root / f"{filename(0)}.changed").write_text(
        baseline + "let benchmark_edit = 1\n", encoding="utf-8"
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--modules", type=int, default=200)
    parser.add_argument(
        "--topology", choices=("chain", "wide", "diamond", "optimizer"), required=True
    )
    parser.add_argument("--mode", choices=("eager", "delayed"), required=True)
    parser.add_argument("--module-systems", choices=("single", "dual"), required=True)
    parser.add_argument("--optimizer-width", type=int, default=64)
    parser.add_argument("--action-trace", action="store_true")
    args = parser.parse_args()
    if args.modules < 2:
        parser.error("--modules must be at least 2")
    if args.optimizer_width < 1:
        parser.error("--optimizer-width must be at least 1")
    return args


if __name__ == "__main__":
    generate(parse_args())
