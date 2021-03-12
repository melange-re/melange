{ ocamlVersion ? "4_12" }:
let
  overlays =
    /Users/anmonteiro/projects/nix-overlays;
  # builtins.fetchTarball
  # https://github.com/anmonteiro/nix-overlays/archive/c584ee4.tar.gz;

in
import "${overlays}/sources.nix" {
  overlays = [
    (import overlays)
    (self: super: {
      ocamlPackages = super.ocaml-ng."ocamlPackages_${ocamlVersion}".overrideScope' (oself: osuper: {
        ocaml = (osuper.ocaml.override { useX11 = false; ncurses = null; }).overrideAttrs (o: {
          preConfigure = ''
            configureFlagsArray+=(--disable-debugger)
          '';
          src = self.lib.gitignoreSource ../../ocaml;
          preBuild = ''
            make clean
          '';
          buildFlags = [ "-j64" "world.opt" ];
        });
      });
    })
  ];
}
