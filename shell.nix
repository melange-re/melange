{ pkgs }:

let
  melange = pkgs.callPackage ./nix { };
  inherit (pkgs) stdenv lib;
in
with pkgs;

mkShell {
  inputsFrom = [ melange ];
  buildInputs = [
    nodejs_latest
    yarn
  ] ++ (with ocamlPackages; [ merlin utop ounit2 ]);
}
