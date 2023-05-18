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
              rev = "417bce1ce63b605d10d02542a9b7c5be982726d0";
              hash = "sha256-7w0dbOZB5wcPZdHmjlbfr3xePzkrjaOPdcB3Is9qNwI=";
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
    git
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
