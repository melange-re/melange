{ release-mode ? false }:

let
  pkgs = import ./nix/sources.nix {};
  inherit (pkgs) stdenv lib;

in
  with pkgs;
  mkShell {
    buildInputs = (with ocamlPackages; [
      merlin
      python3
      gnutar
      camlp4
      re2c
      nodejs-14_x
      pkgs.git
      cppo
      pkgs.ocaml-ng.ocamlPackages_4_11.dune
    ]);

    shellHook = ''
      PATH="$PATH:$PWD/native/4.06.1/bin"
    '';
  }


