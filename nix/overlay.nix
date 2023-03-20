{ nix-filter, melange-compiler-libs }:

final: prev:

{
  ocamlPackages = (prev.ocamlPackages.overrideScope' (oself: osuper:
    {
      dune_3 = osuper.dune_3.overrideAttrs (_: {
        src = prev.fetchFromGitHub {
          owner = "ocaml";
          repo = "dune";
          rev = "d2580fda2b1cc30b18f0fff437ddfd0d956cc90b";
          hash = "sha256-MXQURDuqN4TRsFcfKyQCbd5IaZON543JeHgK7Aeph9U=";
        };
      });
    })).overrideScope' (oself: osuper:
    {
      melange-compiler-libs = (melange-compiler-libs.overlays.default final prev).ocamlPackages.melange-compiler-libs;
    } // (prev.callPackage ./. { inherit nix-filter; }));
}
