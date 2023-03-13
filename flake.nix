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
                    rev = "c7a0049e24e6d802a46f7ed34abf42bc525bf89d";
                    hash = "sha256-6TF0wYbRhoqoEdZRrT06Zu8l9gNUtJhCUoVunJQdiVo=";
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
