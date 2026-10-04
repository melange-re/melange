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
              _: super: {
                ocamlPackages = super.ocaml-ng.ocamlPackages_5_6.overrideScope (
                  _: super: {
                    js_of_ocaml-compiler = super.js_of_ocaml-compiler.overrideAttrs (old: {
                      # ocsigen/js_of_ocaml#2488: consume OCaml 5.6 bytecode hints.
                      patches = (old.patches or [ ]) ++ [
                        (pkgs.fetchpatch {
                          name = "js_of_ocaml-bytecode-hints.patch";
                          url = "https://github.com/ocsigen/js_of_ocaml/compare/b169c0f0b677744d0fa044ac6e1a19f75889ef0a...6d2301902e8919e3a7f5cb81ab579ed2f3b116da.diff";
                          hash = "sha256-5KEh2OuGgHvoolkVHhLyT44pqt/dtCOXcexMeIn/Jic=";
                        })
                      ];
                      postPatch = (old.postPatch or "") + ''
                        # Adapt the PR to OCaml's final hint constructor name.
                        substituteInPlace compiler/lib/ocaml_compiler.ml \
                          --replace-fail "Hint_int_array -> Some Hint_int_array" \
                            "Hint_immediate_result -> Some Hint_int_array"
                      '';
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
