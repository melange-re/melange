{ ocamlVersion }:

let
  src = import ./sources.nix { inherit ocamlVersion; };
  inherit (src) pkgs packages;
in
packages.melange
