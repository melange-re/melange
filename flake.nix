{
  description = "Melange Nix Flake";

  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
    melange-compiler-libs = {
      # this changes rarely, and it's better than having to rely on nix's poor
      # support for submodules
      url = "github:melange-re/melange-compiler-libs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, melange-compiler-libs }:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend (self: super: {
            ocamlPackages = super.ocaml-ng.ocamlPackages_5_3.overrideScope (oself: osuper: {
              js_of_ocaml-compiler = osuper.js_of_ocaml-compiler.overrideAttrs (_: {
                src = super.fetchFromGitHub {
                  owner = "ocsigen";
                  repo = "js_of_ocaml";
                  rev = "c76316cb4f07fc0b1ffc46805fd350d4be77e0dc";
                  hash = "sha256-9aYCYQ+wt5INgm54COeUcbAAqUfpWruLh1TyRDy0Fp0=";
                };
              });
              sedlex = osuper.sedlex.overrideAttrs (_: {
                src = super.fetchFromGitHub {
                  owner = "ocaml-community";
                  repo = "sedlex";
                  rev = "4dbaf572ed52281140be924a2c16fa4f287d88f0";
                  hash = "sha256-pRZ/GRTpBIa8ZcKdmCo1pmAHR3tJrIfNqU4IreEhO7g=";
                };
              });
              ppxlib = osuper.ppxlib.overrideAttrs (_: {
                src = builtins.fetchurl {
                  url = "https://github.com/ocaml-ppx/ppxlib/releases/download/0.36.0/ppxlib-0.36.0.tbz";
                  sha256 = "0d54j19vi1khzmw0ffngs8xzjjq07n20q49h85hhhcf52k71pfjs";
                };
              });
              reason = osuper.reason.overrideAttrs (_: {
                src = super.fetchFromGitHub {
                  owner = "reasonml";
                  repo = "reason";
                  rev = "0b2f1aa14f5722a07a63bedb608c381d218f24cf";
                  hash = "sha256-rtFEhEdNwHgRFAk9S7xx9MKvn9/gtTrIcVZp6d45Fxk=";
                };
                patches = [ ];
                doCheck = false;
              });
              reason-react-ppx = osuper.reason-react-ppx.overrideAttrs (_: {
                src = super.fetchFromGitHub {
                  owner = "reasonml";
                  repo = "reason-react";
                  rev = "c97615d62311f32c2dbb1e5d159c06e147ca7545";
                  hash = "sha256-dZZyjc+G2erukLXsICExaKwWqs6eqGLrkHTouoe8k40=";
                };
              });
              pp = osuper.pp.overrideAttrs (o: {
                doCheck = false;
              });
            });
          });
        in
        f pkgs);
    in
    {
      overlays.default = import ./nix/overlay.nix {
        melange-compiler-libs-vendor-dir = melange-compiler-libs;
      };

      packages = forAllSystems (pkgs:
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

      checks = forAllSystems (pkgs: {
        melange-check = pkgs.callPackage ./nix/test.nix {
          packages = self.packages.${pkgs.system};
        };
      });
    };
}
