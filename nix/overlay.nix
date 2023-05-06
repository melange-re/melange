{ nix-filter, melange-compiler-libs }:

final: prev:

{
  ocamlPackages = (prev.ocamlPackages.overrideScope' (oself: osuper:
    {
      dune_3 = osuper.dune_3.overrideAttrs (_: {
        src = prev.fetchFromGitHub {
          owner = "ocaml";
          repo = "dune";
          rev = "a08e0f7f8a857b348267b30b10b9297ef881bb4d";
          hash = "sha256-MK6hCjbNFIbE/sTR2xuVzrMqtdOIp52QKVuqfmjmwoY=";
        };
      });
    })).overrideScope' (oself: osuper:
    {
      melange-compiler-libs = (melange-compiler-libs.overlays.default final prev).ocamlPackages.melange-compiler-libs;
    } // (prev.callPackage ./. { inherit nix-filter; }));
}
