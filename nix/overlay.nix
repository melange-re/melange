{ nix-filter }:

final: prev:

{
  ocamlPackages = (prev.ocamlPackages.overrideScope' (oself: osuper:
    {
      dune_3 = osuper.dune_3.overrideAttrs (_: {
        src = prev.fetchFromGitHub {
          owner = "ocaml";
          repo = "dune";
          rev = "417bce1ce63b605d10d02542a9b7c5be982726d0";
          hash = "sha256-7w0dbOZB5wcPZdHmjlbfr3xePzkrjaOPdcB3Is9qNwI=";
        };
      });
    })).overrideScope' (oself: osuper:
    prev.callPackage ./. { inherit nix-filter; });
}
