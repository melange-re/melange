{ ocamlVersion ? "4_06" }:

let
  overlays = /home/anmonteiro/projects/nix-overlays;
  # overlays =
    # builtins.fetchTarball
      # https://github.com/anmonteiro/nix-overlays/archive/cc29edc.tar.gz;

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
