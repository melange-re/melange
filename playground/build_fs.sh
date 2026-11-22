#!/usr/bin/env bash
set -euo pipefail

# The package dependency puts the complete Melange installation on OCAMLPATH.
melange_lib=$(ocamlfind query melange)

# Unlike build-fs, --ofs links the runtime helpers needed by binary strings.
runtime_dir=$(mktemp -d)
trap 'rm -rf "$runtime_dir"' EXIT

find \
  "$melange_lib/__private__/melange_mini_stdlib/melange" \
  "$melange_lib/js/melange" \
  "$melange_lib/belt/melange" \
  "$melange_lib/melange" \
  "$melange_lib/dom/melange" \
  \( -name '*.cmi' -o -name '*.cmj' \) -print0 |
  LC_ALL=C sort -z |
  xargs -0 printf -- '--file=%s\0' |
  xargs -0 js_of_ocaml build-runtime -o "$runtime_dir/runtime.js" --ofs "$1"
