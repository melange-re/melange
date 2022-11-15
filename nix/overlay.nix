nix-filter:

final: prev:

{
  ocamlPackages = prev.ocamlPackages.overrideScope' (oself: osuper:
    prev.callPackage ./. {
      inherit nix-filter;
      doCheck = false;
    });
}
