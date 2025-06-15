{
  description = "Melange Nix Flake";

  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
    melange-compiler-libs = {
      # this changes rarely, and it's better than having to rely on nix's poor
      # support for submodules
      url = "github:melange-re/melange-compiler-libs/5.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, melange-compiler-libs }:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend (self: super: {
            ocamlPackages = super.ocaml-ng.ocamlPackages_5_4.overrideScope (oself: osuper: {
              js_of_ocaml-compiler = osuper.js_of_ocaml-compiler.overrideAttrs (_: {
                src = super.fetchFromGitHub {
                  owner = "ocsigen";
                  repo = "js_of_ocaml";
                  rev = "ae754850c7c79ebed2349d24347967a1e3233a4f";
                  hash = "sha256-gV5H/ghjT5ot9p1WAx+Tlecq+/h8fNcu9cPGkgm7iYw=";
                };

              });
              ppxlib = osuper.ppxlib.overrideAttrs (_: {
                src = super.fetchFromGitHub {
                  owner = "ocaml-ppx";
                  repo = "ppxlib";
                  rev = "757f6c284b1fe748d5027eef3bbef924b6bbd7ce";
                  hash = "sha256-6pJGlRknukWH0wr6GhMiQRs43dwx1EkvuW/05ZcEyh0=";
                };
              });
              reason = osuper.reason.overrideAttrs (_: {
                src = super.fetchFromGitHub {
                  owner = "reasonml";
                  repo = "reason";
                  rev = "ead03610ff880ef52d98ca918d2976dbc46a1c22";
                  hash = "sha256-gH0DLG52Y/mzT7ZysEZNVV3jMk53ocTrD93GYU2ORj8=";
                };
                patches = [ ];
                doCheck = false;
              });
              reason-react-ppx = osuper.reason-react-ppx.overrideAttrs (_: {
                src = super.fetchFromGitHub {
                  owner = "reasonml";
                  repo = "reason-react";
                  rev = "6610b1a979e7c6336c996d519c195032c8a6637e";
                  hash = "sha256-zVl8hoFtjBres5TvFVP03OFxoxDyXMpkWnHVRevC3fg=";
                };
              });
              sedlex = osuper.sedlex.overrideAttrs (o: {
                doCheck = false;
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
