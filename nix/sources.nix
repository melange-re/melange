{ ocamlVersion ? "4_06" }:
let
  overlays =
    /Users/anmonteiro/projects/nix-overlays;
  # builtins.fetchTarball
  # https://github.com/anmonteiro/nix-overlays/archive/707a215.tar.gz;

in
import "${overlays}/sources.nix" {
  overlays = [
    (import overlays)
    (self: super: {
      ocamlPackages = super.ocaml-ng."ocamlPackages_${ocamlVersion}".overrideScope' (oself: osuper: {
        ocaml = (osuper.ocaml.override { useX11 = false; ncurses = null; }).overrideAttrs (o: {
          preConfigure = ''
            configureFlagsArray+=(-no-ocamlbuild  -no-curses -no-graph -no-debugger)
          '';
          src = ../ocaml;
          preBuild = ''
            make clean
          '';
          buildFlags = [ "-j16" "world.opt" ];
        });
      });
    })
  ];
}
