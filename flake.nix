{
  description = "Melange Nix Flake";

  inputs = {
    nix-filter.url = "github:numtide/nix-filter";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:anmonteiro/nix-overlays";
    nixpkgs.inputs.flake-utils.follows = "flake-utils";
    melange-compiler-libs.url = "github:melange-re/melange-compiler-libs";
    melange-compiler-libs.inputs.nixpkgs.follows = "nixpkgs";
    melange-compiler-libs.inputs.flake-utils.follows = "flake-utils";

    dream2nix.url = "github:nix-community/dream2nix";
    dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, dream2nix, nix-filter, melange-compiler-libs }:
    {
      overlays.default = import ./nix/overlay.nix {
        nix-filter = nix-filter.lib;
        inherit melange-compiler-libs;
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}".appendOverlays [
          melange-compiler-libs.overlays.default
          (self: super: {
            ocamlPackages = super.ocaml-ng.ocamlPackages_4_14.overrideScope' (oself: osuper:
              {
                dune_3 = osuper.dune_3.overrideAttrs (_: {
                  src = super.fetchFromGitHub {
                    owner = "anmonteiro";
                    repo = "dune";
                    rev = "31bb87e0e2273e3e21f5a941e92cfa6df8c78301";
                    sha256 = "sha256-YMtCeUG0lbBV2QY/D38efrLs7du7lBnc4cTqtKSTIFA=";
                  };

                });
              });
          })
        ];
      in

      rec {
        packages = pkgs.callPackage ./nix { nix-filter = nix-filter.lib; } // {
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
