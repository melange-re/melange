#!/usr/bin/env bash

# Escape the separators used by BUILD_PATH_PREFIX_MAP, including drive letters.
add_build_path_prefix_map() {
  local target source
  target=$(printf '%s' "$1" | sed 's/%/%#/g; s/:/%./g; s/=/%+/g')
  source=$(printf '%s' "$2" | sed 's/%/%#/g; s/:/%./g; s/=/%+/g')
  export BUILD_PATH_PREFIX_MAP="$target=$source${BUILD_PATH_PREFIX_MAP:+:$BUILD_PATH_PREFIX_MAP}"
}

# Accept both plain paths and paths escaped in JSON or Node's array output.
normalize_paths() {
  sed 's|\\\\|/|g; s|\\|/|g'
}

case "$(ocamlc -config-var os_type)" in
  Win32*)
    melange_path_sep=';'
    melange_sandbox=copy
    export MSYS2_ENV_CONV_EXCL="${MSYS2_ENV_CONV_EXCL:+$MSYS2_ENV_CONV_EXCL;}BUILD_PATH_PREFIX_MAP"
    add_build_path_prefix_map '$TESTCASE_ROOT' "$(cygpath -m "$PWD")"
    ;;
  *)
    melange_path_sep=':'
    melange_sandbox=symlink
    ;;
esac

export MELANGELIB="$INSIDE_DUNE/jscomp/stdlib/.stdlib.objs/melange${melange_path_sep}$INSIDE_DUNE/jscomp/runtime/.js.objs/melange"
