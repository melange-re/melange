{
  description = "Melange Nix Flake";

  inputs = {
    nix-filter.url = "github:numtide/nix-filter";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:anmonteiro/nix-overlays";
    nixpkgs.inputs.flake-utils.follows = "flake-utils";

    dream2nix.url = "github:nix-community/dream2nix";
    dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, dream2nix, nix-filter }:

    {
      fromPkgs =
        pkgs: pkgs.callPackage ./nix { nix-filter = nix-filter.lib; };
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}".extend (self: super: {
          ocamlPackages = super.ocaml-ng.ocamlPackages_4_14.overrideScope' (oself: osuper: {
            dune_3 = osuper.dune_3.overrideAttrs (_: {
              src = builtins.fetchurl {
                url = https://github.com/ocaml/dune/archive/779fc36.tar.gz;
                sha256 = "075nm4yc6g6k5xqszh6sxkcxrg17n7vad5kqc16m0ndwc9r9k9kj";
              };
            });
          });
        });
      in

      rec {
        packages = self.fromPkgs pkgs // {
          default = packages.melange;
        };

        devShells = {
          default = pkgs.callPackage ./nix/shell.nix {
            dream2nix = dream2nix.lib2;
            inherit packages;
          };
          release = pkgs.callPackage ./nix/shell.nix {
            dream2nix = dream2nix.lib2;
            release-mode = true;
            inherit packages;
          };
        };
      }));
}
