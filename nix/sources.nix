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
              url = https://github.com/melange-re/melange-compiler-libs/archive/3c3348c.tar.gz;
              sha256 = "0kc2cgz2nnabs80y1k65jlasvgzcm5zkgrdfzh5kfphcqmzxdc4f";
            };
            useDune2 = true;
            propagatedBuildInputs = with oself; [ menhir ];
          };
        });
    })
  ];
}
