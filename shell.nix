let
  pkgs = import ./nix/sources.nix { };
  melange = import ./nix { inherit pkgs; };
  inherit (pkgs) stdenv lib;
in
with pkgs;

mkShell {
  inputsFrom = [ melange ];
  buildInputs = [
    nodejs-14_x
    yarn
  ] ++ (with ocamlPackages; [ merlin utop ounit2 ]);
}
