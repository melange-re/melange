{ ocamlVersion ? "4_06" }:

let
  overlays =
    builtins.fetchTarball
      https://github.com/anmonteiro/nix-overlays/archive/5eab7d8.tar.gz;

in

  import "${overlays}/sources.nix" {
    overlays = [
      (import overlays)
      (self: super: {
        ocamlPackages = super.ocaml-ng."ocamlPackages_${ocamlVersion}".overrideScope'
            (super.callPackage "${overlays}/ocaml" {});
      })
    ];
  }
