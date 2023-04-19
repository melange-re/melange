{ nix-filter, melange-compiler-libs }:

final: prev:

{
  ocamlPackages = (prev.ocamlPackages.overrideScope' (oself: osuper:
    {
      dune_3 = osuper.dune_3.overrideAttrs (_: {
        src = prev.fetchFromGitHub {
          owner = "ocaml";
          repo = "dune";
          rev = "4c18a4cd6121de6bb20b76236d6fb54c17e1b3a9";
          hash = "sha256-ov0gqi+WqEOGrS0Q8TS9Pqf9T0W/Sg7Hm5CyKDJluS8=";
        };
      });
    })).overrideScope' (oself: osuper:
    {
      melange-compiler-libs = (melange-compiler-libs.overlays.default final prev).ocamlPackages.melange-compiler-libs;
    } // (prev.callPackage ./. { inherit nix-filter; }));
}
