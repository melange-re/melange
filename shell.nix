let
  pkgs = import ./nix/sources.nix { };
  inherit (pkgs) stdenv lib;
in
with pkgs;

mkShell {
  buildInputs = [
    nodejs-14_x
    yarn
    python3
    pkgs.git
  ] ++ (with ocamlPackages; [
    merlin
    cppo
    dune
    dune-action-plugin
    reason
    findlib
    ocaml
    utop
    cmdliner
  ]);
}
