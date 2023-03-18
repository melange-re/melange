{ nix-filter, melange-compiler-libs }:

final: prev:

{
  ocamlPackages = (prev.ocamlPackages.overrideScope' (oself: osuper:
    {
      dune_3 = osuper.dune_3.overrideAttrs (_: {
        src = prev.fetchFromGitHub {
          owner = "ocaml";
          repo = "dune";
          rev = "649031728346482a83441c26c0bbe06ecd89cce2";
          hash = "sha256-IbvAumstRp7JE+UQDArrwYWyZtbe8q8bZo05eVzA/MU=";
        };
      });
    })).overrideScope' (oself: osuper:
    {
      melange-compiler-libs = (melange-compiler-libs.overlays.default final prev).ocamlPackages.melange-compiler-libs;
    } // (prev.callPackage ./. { inherit nix-filter; }));
}
