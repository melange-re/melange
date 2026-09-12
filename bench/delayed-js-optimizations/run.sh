#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)
repo_root=$(cd "$script_dir/../.." && pwd)

runs=5
warmup=1
modules=200
optimizer_width=64
output=""
topologies=chain,wide,diamond,optimizer
module_systems=single,dual
jobs=1,auto
scenarios=cold,incremental,cmj-cold,cmj-incremental

usage() {
  echo "usage: $0 --output DIR [--runs N] [--warmup N] [--modules N]"
  echo "          [--optimizer-width N]"
  echo "          [--topologies LIST] [--module-systems LIST] [--jobs LIST]"
  echo "          [--scenarios LIST]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) output=$2; shift 2 ;;
    --runs) runs=$2; shift 2 ;;
    --warmup) warmup=$2; shift 2 ;;
    --modules) modules=$2; shift 2 ;;
    --optimizer-width) optimizer_width=$2; shift 2 ;;
    --topologies) topologies=$2; shift 2 ;;
    --module-systems) module_systems=$2; shift 2 ;;
    --jobs) jobs=$2; shift 2 ;;
    --scenarios) scenarios=$2; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$output" ]]; then
  echo "--output is required so benchmark artifacts have an explicit destination" >&2
  exit 2
fi

case "$output" in
  /|"$repo_root")
    echo "refusing unsafe output directory: $output" >&2
    exit 2
    ;;
  *"'"*)
    echo "output directory cannot contain a single quote: $output" >&2
    exit 2
    ;;
esac

if [[ "$(uname -s)" == Darwin ]]; then
  auto_jobs=$(sysctl -n hw.logicalcpu)
else
  auto_jobs=$(getconf _NPROCESSORS_ONLN)
fi

output=$(mkdir -p "$output" && cd "$output" && pwd)

(cd "$repo_root" && \
  dune build --display=quiet --sandbox=none --only-packages melange @install)
export PATH="$repo_root/_build/install/default/bin:$PATH"
export OCAMLPATH="$repo_root/_build/install/default/lib${OCAMLPATH:+:$OCAMLPATH}"

IFS=, read -r -a topology_values <<< "$topologies"
IFS=, read -r -a system_values <<< "$module_systems"
IFS=, read -r -a job_values <<< "$jobs"
IFS=, read -r -a scenario_values <<< "$scenarios"

for topology in "${topology_values[@]}"; do
  for systems in "${system_values[@]}"; do
    for job_value in "${job_values[@]}"; do
      if [[ "$job_value" == auto ]]; then
        job_count=$auto_jobs
      else
        job_count=$job_value
      fi
      for scenario in "${scenario_values[@]}"; do
        case_dir="$output/cases/$topology/$systems/j$job_count/$scenario"
        mkdir -p "$case_dir"

        for mode in eager delayed; do
          python3 "$script_dir/generate.py" \
            --root "$case_dir/$mode" \
            --modules "$modules" \
            --topology "$topology" \
            --mode "$mode" \
            --optimizer-width "$optimizer_width" \
            --module-systems "$systems"
        done

        if [[ "$scenario" == cmj-* ]]; then
          build_target=.output.mobjs/melange/melange__Main.cmj
        else
          build_target=@melange
        fi

        if [[ "$scenario" == cold || "$scenario" == cmj-cold ]]; then
          prepare="dune clean --root '$case_dir/{mode}'"
        elif [[ "$scenario" == incremental || "$scenario" == cmj-incremental ]]; then
          prepare="cp '$case_dir/{mode}/unit_0000.ml.baseline' '$case_dir/{mode}/unit_0000.ml'; dune clean --root '$case_dir/{mode}'; dune build --root '$case_dir/{mode}' --cache=disabled -j '$job_count' '$build_target' >/dev/null; cp '$case_dir/{mode}/unit_0000.ml.changed' '$case_dir/{mode}/unit_0000.ml'"
        else
          echo "unknown scenario: $scenario" >&2
          exit 2
        fi
        command="dune build --root '$case_dir/{mode}' --cache=disabled -j '$job_count' '$build_target'"

        hyperfine \
          --runs "$runs" \
          --warmup "$warmup" \
          --parameter-list mode eager,delayed \
          --prepare "$prepare" \
          --export-json "$case_dir/hyperfine.json" \
          "$command"

        for mode in eager delayed; do
          trace_root="$case_dir/trace-$mode-project"
          python3 "$script_dir/generate.py" \
            --root "$trace_root" \
            --modules "$modules" \
            --topology "$topology" \
            --mode "$mode" \
            --optimizer-width "$optimizer_width" \
            --module-systems "$systems" \
            --action-trace
          if [[ "$scenario" == incremental || "$scenario" == cmj-incremental ]]; then
            dune build --display=quiet --root "$trace_root" --cache=disabled \
              -j "$job_count" "$build_target"
            cp "$trace_root/unit_0000.ml.changed" "$trace_root/unit_0000.ml"
          fi
          dune build --display=quiet --root "$trace_root" --cache=disabled \
            -j "$job_count" --trace-file="$case_dir/trace-$mode.csexp" \
            "$build_target"
          dune trace cat --trace-file="$case_dir/trace-$mode.csexp" \
            --chrome-trace > "$case_dir/trace-$mode.json"
        done
      done
    done
  done
done

python3 "$script_dir/summarize.py" "$output"
echo "Raw measurements, traces, and summaries: $output"
