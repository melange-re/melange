let
  pkgs = import ./nix/sources.nix { };
  inherit (pkgs) stdenv lib;
in
with pkgs;

mkShell {
  buildInputs = [
    python3
    gnutar
    nodejs-14_x
    pkgs.git
  ] ++ (with ocamlPackages; [
    merlin
    cppo
    dune_2
    reason
    findlib
    ocaml
  ]);
}
