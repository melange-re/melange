{ ocamlVersion ? "4_12" }:
let
  overlays =
    builtins.fetchTarball
      https://github.com/anmonteiro/nix-overlays/archive/dec2cdc.tar.gz;

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
            url = https://github.com/anmonteiro/ocaml/archive/75f22c872451c66a4c4aadc43abee55697268a57.tar.gz;
            sha256 = "1j3ydjpd7wrwl55mgcc30wrvj2vmppas067c90wkqnmy8wmv5isi";
          };
          buildFlags = [ "-j64" "world.opt" ];
        });
      });
    })
  ];
}
