#!/usr/bin/env bash

case "$(ocamlc -config-var os_type)" in
  Win32*) melange_path_sep=';' ;;
  *) melange_path_sep=':' ;;
esac

export MELANGELIB="$INSIDE_DUNE/jscomp/stdlib/.stdlib.objs/melange${melange_path_sep}$INSIDE_DUNE/jscomp/runtime/.js.objs/melange"
