#!/usr/bin/env python3
"""Summarize hyperfine results and Melange action-trace phases."""

from __future__ import annotations

import argparse
from collections import defaultdict
import json
from pathlib import Path


def load_measurements(root: Path) -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []
    for path in sorted(root.glob("cases/*/*/j*/*/hyperfine.json")):
        topology, systems, jobs, scenario = path.parts[-5:-1]
        payload = json.loads(path.read_text(encoding="utf-8"))
        for result in payload["results"]:
            mode = result.get("parameters", {}).get("mode")
            rows.append(
                {
                    "topology": topology,
                    "module_systems": systems,
                    "jobs": int(jobs[1:]),
                    "scenario": scenario,
                    "mode": mode,
                    "mean_seconds": result["mean"],
                    "stddev_seconds": result["stddev"],
                    "median_seconds": result["median"],
                }
            )
    return rows


def load_traces(
    root: Path,
) -> tuple[list[dict[str, object]], list[dict[str, object]]]:
    rows: list[dict[str, object]] = []
    artifacts: list[dict[str, object]] = []
    for path in sorted(root.glob("cases/*/*/j*/*/trace-*.json")):
        topology, systems, jobs, scenario = path.parts[-5:-1]
        mode = path.stem.removeprefix("trace-")
        totals: dict[tuple[str, str, str], list[float]] = defaultdict(list)
        payload = json.loads(path.read_text(encoding="utf-8"))
        events = payload if isinstance(payload, list) else payload.get("traceEvents", [])
        action_stages = {
            event.get("args", {}).get("digest"): event["name"]
            for event in events
            if event.get("cat") == "melange.artifact"
            and event.get("args", {}).get("digest")
        }
        for event in events:
            category = event.get("cat", "")
            if category.startswith("melange.") and event.get("ph") == "X":
                stage = action_stages.get(
                    event.get("args", {}).get("digest"), "unknown"
                )
                totals[(category, event["name"], stage)].append(
                    float(event.get("dur", 0))
                )
            if category == "melange.artifact" and "bytes" in event.get("args", {}):
                artifacts.append(
                    {
                        "topology": topology,
                        "module_systems": systems,
                        "jobs": int(jobs[1:]),
                        "scenario": scenario,
                        "mode": mode,
                        "artifact": event["name"],
                        "module": event.get("args", {}).get("module"),
                        "bytes": int(event["args"]["bytes"]),
                    }
                )
        for (category, name, stage), durations in sorted(totals.items()):
            rows.append(
                {
                    "topology": topology,
                    "module_systems": systems,
                    "jobs": int(jobs[1:]),
                    "scenario": scenario,
                    "mode": mode,
                    "category": category,
                    "phase": name,
                    "action_stage": stage,
                    "count": len(durations),
                    "total_microseconds": sum(durations),
                }
            )
    return rows, artifacts


def comparisons(measurements: list[dict[str, object]]) -> list[dict[str, object]]:
    grouped: dict[tuple[object, ...], dict[str, dict[str, object]]] = defaultdict(dict)
    for row in measurements:
        key = (
            row["topology"],
            row["module_systems"],
            row["jobs"],
            row["scenario"],
        )
        grouped[key][str(row["mode"])] = row

    result = []
    for key, modes in sorted(grouped.items()):
        if set(modes) != {"eager", "delayed"}:
            continue
        eager = float(modes["eager"]["median_seconds"])
        delayed = float(modes["delayed"]["median_seconds"])
        result.append(
            {
                "topology": key[0],
                "module_systems": key[1],
                "jobs": key[2],
                "scenario": key[3],
                "eager_median_seconds": eager,
                "delayed_median_seconds": delayed,
                "delayed_vs_eager_percent": ((delayed / eager) - 1.0) * 100.0,
            }
        )
    return result


def markdown(rows: list[dict[str, object]]) -> str:
    lines = [
        "| topology | systems | jobs | scenario | eager (s) | delayed (s) | delta |",
        "|---|---:|---:|---|---:|---:|---:|",
    ]
    for row in rows:
        lines.append(
            "| {topology} | {module_systems} | {jobs} | {scenario} | "
            "{eager_median_seconds:.3f} | {delayed_median_seconds:.3f} | "
            "{delayed_vs_eager_percent:+.1f}% |".format(**row)
        )
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    args = parser.parse_args()
    measurements = load_measurements(args.root)
    comparison_rows = comparisons(measurements)
    trace_phases, artifacts = load_traces(args.root)
    summary = {
        "measurements": measurements,
        "comparisons": comparison_rows,
        "trace_phases": trace_phases,
        "artifacts": artifacts,
    }
    (args.root / "summary.json").write_text(
        json.dumps(summary, indent=2) + "\n", encoding="utf-8"
    )
    (args.root / "summary.md").write_text(markdown(comparison_rows), encoding="utf-8")
    print(markdown(comparison_rows), end="")


if __name__ == "__main__":
    main()
