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
                ocamlPackages = super.ocaml-ng.ocamlPackages_5_5.overrideScope (
                  oself: osuper: {
                    dune_3 = osuper.dune_3.overrideAttrs (_: {
                      # https://github.com/ocaml/dune/pull/14018
                      src = super.fetchFromGitHub {
                        owner = "ocaml";
                        repo = "dune";
                        rev = "9e80abbfb0b2ae09ff5b5412d419f3828992d13c";
                        hash = "sha256-2ijxaxykiHga+cuOQJ+FtzDCw1b1xGoYPBUPQl/ujBc=";
                    js_of_ocaml-compiler = osuper.js_of_ocaml-compiler.overrideAttrs (_: {
                      src = super.fetchFromGitHub {
                        owner = "ocsigen";
                        repo = "js_of_ocaml";
                        rev = "d5383e1361ad109463d2b59afaf65a032c1b8f79";
                        hash = "sha256-Gd1bdp/dXmM/UJRGypYN10RbIjE76D5wkJhF2NPeIPs=";
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
