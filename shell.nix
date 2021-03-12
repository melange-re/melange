let
  pkgs = import ./nix/sources.nix { };
  inherit (pkgs) stdenv lib;
in
with pkgs;

mkShell {
  buildInputs = [
    nodejs-14_x
    pkgs.git
  ] ++ (with ocamlPackages; [
    merlin
    cppo
    dune
    reason
    findlib
    ocaml
  ]);
}
