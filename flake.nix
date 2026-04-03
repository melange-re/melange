{
  description = "Melange Nix Flake";

  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
    melange-compiler-libs = {
      # this changes rarely, and it's better than having to rely on nix's poor
      # support for submodules
      url = "github:melange-re/melange-compiler-libs/5.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      melange-compiler-libs,
    }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system}.extend (
              self: super: {
                ocamlPackages = super.ocaml-ng.ocamlPackages_5_4.overrideScope (
                  oself: osuper: {
                    dune_3 = osuper.dune_3.overrideAttrs (_: {
                      src = super.fetchFromGitHub {
                        owner = "ocaml";
                        repo = "dune";
                        rev = "2da3f7adfcc93c82b52578d29cc7616823207c84";
                        hash = "sha256-3uitSVvt3Kkz6wUDls9l179wds55UCuTUStjG7Cxc7Y=";
                      };
                    });
                  }
                );
              }
            );
          in
          f pkgs
        );
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt);
      overlays.default = import ./nix/overlay.nix {
        melange-compiler-libs-vendor-dir = melange-compiler-libs;
      };

      packages = forAllSystems (
        pkgs:
        let
          melange = pkgs.callPackage ./nix {
            melange-compiler-libs-vendor-dir = melange-compiler-libs;
          };
        in
        {
          inherit melange;
          default = melange;
          melange-playground = pkgs.ocamlPackages.callPackage ./nix/melange-playground.nix {
            inherit melange;
            melange-compiler-libs-vendor-dir = melange-compiler-libs;
          };
        }
      );

      devShells = forAllSystems (
        pkgs:
        let
          melange-shell =
            opts:
            pkgs.callPackage ./nix/shell.nix (
              {
                packages = self.packages.${pkgs.stdenv.hostPlatform.system};
              }
              // opts
            );

        in
        {
          default = melange-shell { };
          release = melange-shell {
            release-mode = true;
          };
        }
      );
    };
}
