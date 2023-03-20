{
  description = "Melange Nix Flake";

  inputs = {
    nix-filter.url = "github:numtide/nix-filter";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs = {
      url = "github:nix-ocaml/nix-overlays";
      inputs.flake-utils.follows = "flake-utils";
    };
    melange-compiler-libs = {
      url = "github:melange-re/melange-compiler-libs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter, melange-compiler-libs }:
    {
      overlays.default = import ./nix/overlay.nix {
        nix-filter = nix-filter.lib;
        inherit melange-compiler-libs;
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}".appendOverlays [
          (self: super: {
            ocamlPackages = super.ocaml-ng.ocamlPackages_4_14.overrideScope' (oself: osuper:
              {
                dune_3 = osuper.dune_3.overrideAttrs (_: {
                  src = super.fetchFromGitHub {
                    owner = "ocaml";
                    repo = "dune";
                    rev = "d2580fda2b1cc30b18f0fff437ddfd0d956cc90b";
                    hash = "sha256-MXQURDuqN4TRsFcfKyQCbd5IaZON543JeHgK7Aeph9U=";
                  };
                });
              });
          })
          melange-compiler-libs.overlays.default
        ];
      in

      rec {
        packages = pkgs.callPackage ./nix { nix-filter = nix-filter.lib; } // {
          default = packages.melange;
        };

        devShells = {
          default = pkgs.callPackage ./nix/shell.nix {
            # dream2nix = dream2nix.lib2;
            inherit packages;
          };
          release = pkgs.callPackage ./nix/shell.nix {
            release-mode = true;
            inherit packages;
          };
        };
      }));
}
