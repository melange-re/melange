{ ocamlVersion }:

let
  lock = builtins.fromJSON (builtins.readFile ./../../flake.lock);
  src = fetchGit {
    url = with lock.nodes.nixpkgs.locked;"https://github.com/${owner}/${repo}";
    inherit (lock.nodes.nixpkgs.locked) rev;
    # inherit (lock.nodes.nixpkgs.original) ref;
  };
  nix-filter-src = fetchGit {
    url = with lock.nodes.nix-filter.locked; "https://github.com/${owner}/${repo}";
    inherit (lock.nodes.nix-filter.locked) rev;
    # inherit (lock.nodes.nixpkgs.original) ref;
    allRefs = true;
  };
  nix-filter = import "${nix-filter-src}";

  pkgs = import src {
    extraOverlays = [
      (self: super: {
        ocamlPackages = super.ocaml-ng."ocamlPackages_${ocamlVersion}".overrideScope' (oself: osuper: {
          dune_3 = osuper.dune_3.overrideAttrs (_: {
            src = super.fetchFromGitHub {
              owner = "ocaml";
              repo = "dune";
              rev = "239e6aca68aaa27bc429425b4aab32f4a9ee9bcd";
              hash = "sha256-aQbk1YqC62BocL6SNopfJsf8LpxMTvw4KlobPrJJECk=";
            };
          });

          melange-compiler-libs = osuper.melange-compiler-libs.overrideAttrs (_: {
            src = super.fetchFromGitHub {
              owner = "melange-re";
              repo = "melange-compiler-libs";
              rev = "17a06ec6c8a5da27adeb76496ff7fab6c58091f5";
              hash = "sha256-EZ8JAeJQMfZQJr9CPwdWVnaa8bHdnr+FiiVbC1hG7oM=";
            };
          });

          menhirLib = osuper.menhirLib_20230415;
          menhirSdk = osuper.menhirSdk_20230415;
          menhir = osuper.menhir_20230415;
        });
      })
    ];
  };
  inherit (pkgs) stdenv nodejs yarn git lib nodePackages ocamlPackages tree;
  packages = pkgs.callPackage ./.. { inherit nix-filter; };
  inputString =
    builtins.substring
      11 32
      (builtins.unsafeDiscardStringContext packages.melange.outPath);
in

with ocamlPackages;

stdenv.mkDerivation {
  name = "melange-tests-${inputString}";

  src = ../../jscomp/test;

  # https://blog.eigenvalue.net/nix-rerunning-fixed-output-derivations/
  # the dream of running fixed-output-derivations is dead -- somehow after
  # Nix 2.4 it results in `error: unexpected end-of-file`.
  # Example: https://github.com/melange-re/melange/runs/4132970590
  outputHashMode = "flat";
  outputHashAlgo = "sha256";
  outputHash = builtins.hashString "sha256" "melange";
  installPhase = ''
    echo -n melange > $out
  '';

  phases = [ "unpackPhase" "checkPhase" "installPhase" ];

  doCheck = true;
  nativeBuildInputs = [
    ocaml
    findlib
    dune
    nodePackages.mocha
    ocamlPackages.reason
    tree
    nodejs
    yarn
  ];
  buildInputs = [
    packages.melange
    packages.reactjs-jsx-ppx
    packages.rescript-syntax
  ];

  checkPhase = ''
    cat > dune-project <<EOF
    (lang dune 3.8)
    (using melange 0.1)
    EOF
    dune build @melange-runtime-tests --display=short

    mocha "_build/default/dist/*_test.js"
  '';
}
