{ nix-filter, melange-compiler-libs }:

final: prev:

{
  ocamlPackages = prev.ocamlPackages.overrideScope' (oself: osuper:
    (melange-compiler-libs.overlays.default final prev).ocamlPackages //
    (prev.callPackage ./. { inherit nix-filter; }));
}
