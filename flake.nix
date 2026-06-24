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
                    cppo = osuper.cppo.overrideAttrs (_: {
                      doCheck = false;
                    });
                    ocaml-lsp = osuper.ocaml-lsp.overrideAttrs (_: {
                      postPatch = ''
                        substituteInPlace \
                          ocaml-lsp-server/src/merlin_config.ml \
                          submodules/lev/lev-fiber/src/lev_fiber.ml \
                          ocaml-lsp-server/src/dune.ml \
                          ocaml-lsp-server/src/ocamlformat_rpc.ml \
                          ocaml-lsp-server/src/ocamlformat.ml \
                          --replace-fail "Pid.of_int" "Pid.of_int_exn"
                      '';

                    });
                    jsonrpc = osuper.jsonrpc.overrideAttrs (_: {
                      postPatch = ''
                        substituteInPlace submodules/lev/lev-fiber/src/lev_fiber.ml --replace-fail "Pid.of_int" "Pid.of_int_exn"
                      '';

                    });
                    dune_3 = osuper.dune_3.overrideAttrs (_: {
                      src = super.fetchFromGitHub {
                        owner = "ocaml";
                        repo = "dune";
                        rev = "eb7b1a206ef4ce35638612c9bb3f28c210ee3c3d";
                        hash = "sha256-bZz1fp3j5C0U3yuabdpUBObLB4KdtYbKUhbE6URM4lk=";
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
