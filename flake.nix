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
      # this changes rarely, and it's better than having to rely on nix's poor
      # support for submodules
      url = "github:melange-re/melange-compiler-libs/anmonteiro/mel-as-variants";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter, melange-compiler-libs }:
    {
      overlays.default = import ./nix/overlay.nix {
        nix-filter = nix-filter.lib;
        melange-compiler-libs-vendor-dir = melange-compiler-libs;
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}".extend (self: super: {
          ocamlPackages = super.ocaml-ng.ocamlPackages_5_2;
        });

        packages =
          let
            melange = pkgs.callPackage ./nix {
              nix-filter = nix-filter.lib;
              melange-compiler-libs-vendor-dir = melange-compiler-libs;
            };
          in
          {
            inherit melange;
            default = melange;
            melange-playground = pkgs.ocamlPackages.callPackage ./nix/melange-playground.nix {
              inherit melange;
              nix-filter = nix-filter.lib;
              melange-compiler-libs-vendor-dir = melange-compiler-libs;
            };
          };
        melange-shell = opts:
          pkgs.callPackage ./nix/shell.nix ({ inherit packages; } // opts);
      in
      {
        inherit packages;
        devShells = {
          default = melange-shell { };
          release = melange-shell {
            release-mode = true;
          };
        };
      }));
}
