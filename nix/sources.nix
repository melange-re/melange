{ ocamlVersion ? "4_12" }:
let
  overlays =
    builtins.fetchTarball
      https://github.com/anmonteiro/nix-overlays/archive/7148ca8.tar.gz;

in
import "${overlays}/sources.nix" {
  overlays = [
    (import overlays)
    (self: super: {
      ocamlPackages = super.ocaml-ng."ocamlPackages_${ocamlVersion}".overrideScope'
        (oself: osuper: {
          melange-compiler-libs = oself.buildDunePackage {
            pname = "melange-compiler-libs";
            version = "0.0.0";
            nativeBuildInputs = [ self.git ];
            src = builtins.fetchurl {
              url = https://github.com/melange-re/melange-compiler-libs/archive/94eaf4762c563d99830f16f7802bead5fe6b126e.tar.gz;
              sha256 = "0gcja46bjbg9dikfqa4id6hjx89a080h3igblalibj4b7bbf9lh0";
            };
            useDune2 = true;
            propagatedBuildInputs = with oself; [ menhir ];
          };
        });
    })
  ];
}
