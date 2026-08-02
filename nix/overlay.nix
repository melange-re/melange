{ melange-compiler-libs-vendor-dir }:

final: prev:

{
  ocamlPackages = prev.ocamlPackages.overrideScope (
    oself: osuper:

    {
      melange = prev.callPackage ./. {
        inherit melange-compiler-libs-vendor-dir;
        doCheck = false;
      };
      melange-playground = oself.callPackage ./melange-playground.nix {
        inherit melange-compiler-libs-vendor-dir;
      };
    }
  );
}
