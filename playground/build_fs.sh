#!/usr/bin/env bash
set -euo pipefail

# The package dependency puts the complete Melange installation on OCAMLPATH.
melange_lib=$(ocamlfind query melange)
output="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"

# Unlike build-fs, --ofs links the runtime helpers needed by binary strings.
runtime_dir=$(mktemp -d)
trap 'rm -rf "$runtime_dir"' EXIT

case "$(ocamlc -config-var os_type)" in
  Win32*)
    output=$(cygpath -m "$output")
    runtime_dir=$(cygpath -m "$runtime_dir")
    ;;
esac

# --file uses ':' to separate the source and virtual paths. Relative sources
# avoid interpreting a Windows drive letter as that separator. Passing whole
# directories also avoids splitting the command at Windows' argument limit.
cd "$melange_lib"
MSYS2_ARG_CONV_EXCL='--file=' js_of_ocaml build-runtime \
  -o "$runtime_dir/runtime.js" --ofs "$output" \
  --file=__private__/melange_mini_stdlib/melange=cmi,cmj:/static \
  --file=js/melange=cmi,cmj:/static \
  --file=belt/melange=cmi,cmj:/static \
  --file=melange=cmi,cmj:/static \
  --file=dom/melange=cmi,cmj:/static
