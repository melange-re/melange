{
  description = "Melange Nix Flake";

  inputs = {
    nix-filter.url = "github:numtide/nix-filter";
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
    melange-compiler-libs = {
      # this changes rarely, and it's better than having to rely on nix's poor
      # support for submodules
      url = "github:melange-re/melange-compiler-libs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-filter, melange-compiler-libs }:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend (self: super: {
            ocamlPackages = super.ocaml-ng.ocamlPackages_5_3;
          });
        in
        f pkgs);
    in
    {
      overlays.default = import ./nix/overlay.nix {
        nix-filter = nix-filter.lib;
        melange-compiler-libs-vendor-dir = melange-compiler-libs;
      };

      packages = forAllSystems (pkgs:
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
        }
      );

      devShells = forAllSystems (pkgs:
        let
          melange-shell = opts:
            pkgs.callPackage ./nix/shell.nix ({
              packages = self.packages.${pkgs.system};
            } // opts);

        in
        {
          default = melange-shell { };
          release = melange-shell {
            release-mode = true;
          };
        }
      );

      checks = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend (self: super: {
            ocamlPackages = super.ocaml-ng.ocamlPackages_5_3;
          });
        in
        {
          melange-check = pkgs.callPackage ./nix/ci/test.nix {
            packages = self.packages.${pkgs.system};
          };
        }
      );
    };
}
