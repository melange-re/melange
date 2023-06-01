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
          menhirLib = osuper.menhirLib_20230415;
          menhirSdk = osuper.menhirSdk_20230415;
          menhir = osuper.menhir_20230415;
          reactjs-jsx-ppx = osuper.reactjs-jsx-ppx.overrideAttrs (_: {
            postPatch = ''
              rm -rf test/dune
            '';
            src = super.fetchFromGitHub {
              owner = "reasonml";
              repo = "reason-react";
              rev = "f5a4a64bd7cd10e8477a563a77222ec8c85b873a";
              hash = "sha256-HadgHdfUlbx/+8yZKLaj1tSMo0Uuu2xalwsGxrhBZ0E=";
            };
            patches = [ ];
            doCheck = false;
          });
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
    packages.rescript-syntax
    reactjs-jsx-ppx
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
