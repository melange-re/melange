{ ocamlVersion ? "4_12" }:
let
  overlays =
    builtins.fetchTarball
      https://github.com/anmonteiro/nix-overlays/archive/fe9462a.tar.gz;

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
          src = builtins.fetchurl {
            url = https://github.com/anmonteiro/ocaml/archive/72babec0e1796ce322464afc8ef2a0d7125d60cb.tar.gz;
            sha256 = "1yp0ifwhsaf3zkqj2nnvbcj0dfmrvbifkiwybh2xda6y7ca84z5j";
          };
          preBuild = ''
            make clean
          '';
          buildFlags = [ "-j64" "world.opt" ];
        });
      });
    })
  ];
}
