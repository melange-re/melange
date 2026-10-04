#!/usr/bin/env bash
set -euo pipefail

# The package dependency puts the complete Melange installation on OCAMLPATH.
melange_lib=$(ocamlfind query melange)

find \
  "$melange_lib/__private__/melange_mini_stdlib/melange" \
  "$melange_lib/js/melange" \
  "$melange_lib/belt/melange" \
  "$melange_lib/melange" \
  "$melange_lib/dom/melange" \
  \( -name '*.cmi' -o -name '*.cmj' \) -print0 |
  LC_ALL=C sort -z |
  xargs -0 js_of_ocaml build-fs -o "$1"
