{
  description = "Melange Nix Flake";

  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
    melange-compiler-libs = {
      # this changes rarely, and it's better than having to rely on nix's poor
      # support for submodules
      url = "github:melange-re/melange-compiler-libs/4.14";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, melange-compiler-libs }:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend (self: super: {
            ocamlPackages = super.ocaml-ng.ocamlPackages_4_14.overrideScope (oself: osuper: {
              ppxlib = osuper.ppxlib.overrideAttrs (_: {
                src = builtins.fetchurl
                  {
                    url = "https://github.com/ocaml-ppx/ppxlib/releases/download/0.37.0/ppxlib-0.37.0.tbz";
                    sha256 = "1cxhbnw6s59gfwrrqp0nx5diskiglz0349239b43pk6fwwvkh8if";
                  };
              });
              pp = osuper.pp.overrideAttrs (_: {
                doCheck = false;
              });
              reason-react-ppx = osuper.reason-react-ppx.overrideAttrs (_: {
                src = super.fetchFromGitHub {
                  owner = "reasonml";
                  repo = "reason-react";
                  rev = "8454c63ee56afc7e7dce439eaff395aba0577d68";
                  hash = "sha256-8Wkk6Aav1zk9me1UGz8D3z3bDdIc/MDt9E4YNS6zK1U=";
                };
              });
              reason = osuper.reason.overrideAttrs (_: {
                src = builtins.fetchurl {
                  url = "https://github.com/reasonml/reason/releases/download/3.17.0/reason-3.17.0.tbz";
                  sha256 = "1sx5z269sry2xbca3d9sw7mh9ag773k02r9cgrz5n8gxx6f83j42";
                };
                patches = [ ];
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
