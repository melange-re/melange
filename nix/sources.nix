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
              url = https://github.com/melange-re/melange-compiler-libs/archive/eefcbe8882.tar.gz;
              sha256 = "18w7w7kgpky0662g9q7bsdw06rnddpynmlsp6n7cfdccw37y7sxd";
            };
            useDune2 = true;
            propagatedBuildInputs = with oself; [ menhir ];
          };
        });
    })
  ];
}
