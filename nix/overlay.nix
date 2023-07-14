{ nix-filter, melange-compiler-libs-vendor-dir }:

final: prev:

{
  ocamlPackages = prev.ocamlPackages.overrideScope' (oself: osuper:

    with oself;

    {
      melange = prev.callPackage ./. {
        inherit nix-filter melange-compiler-libs-vendor-dir;
      };
      rescript-syntax = prev.lib.callPackageWith oself ./rescript-syntax.nix {
        inherit nix-filter;
      };
      melange-playground = prev.lib.callPackageWith oself ./melange-playground.nix {
        inherit nix-filter melange-compiler-libs-vendor-dir;
        inherit (prev) nodejs;
      };
    }
  );
}
