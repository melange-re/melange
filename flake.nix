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
            ocamlPackages = super.ocaml-ng.ocamlPackages_5_4.overrideScope (oself: osuper: {
              js_of_ocaml-compiler = osuper.js_of_ocaml-compiler.overrideAttrs (_: {
                src = builtins.fetchurl {
                  url = "https://github.com/ocsigen/js_of_ocaml/releases/download/6.1.0/js_of_ocaml-6.1.0.tbz";
                  sha256 = "09qm8y42q1x8hd0vrka9dcn7q0qp98lzqqr5gjvimqzxhb1hqcrw";
                };
              });

              reason = osuper.reason.overrideAttrs (o: {
                src = super.fetchFromGitHub {
                  owner = "reasonml";
                  repo = "reason";
                  rev = "dfb960412cbcd6b1770b1a7c215db1c8c877c2a6";
                  hash = "sha256-ShbJnc2/KEfEuPYbfRGSgbm4knrsk3fzrrjlQZrGS5s=";
                };
                propagatedBuildInputs = o.propagatedBuildInputs ++ [ oself.cmdliner ];
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
