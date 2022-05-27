{ pkgs }:

let
  melange = pkgs.callPackage ./nix { };
  inherit (pkgs) stdenv lib;
in
with pkgs;

mkShell {
  inputsFrom = [ melange ];
  buildInputs = [
    python3
    nodejs-16_x
    yarn
  ] ++ (with ocamlPackages; [
    merlin
    utop
    ounit2
    ocamlformat
  ]);
}
