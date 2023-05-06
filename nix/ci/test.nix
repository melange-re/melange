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
              rev = "a08e0f7f8a857b348267b30b10b9297ef881bb4d";
              hash = "sha256-MK6hCjbNFIbE/sTR2xuVzrMqtdOIp52QKVuqfmjmwoY=";
            };
          });

          melange-compiler-libs = osuper.melange-compiler-libs.overrideAttrs (_: {
            src = super.fetchFromGitHub {
              owner = "melange-re";
              repo = "melange-compiler-libs";
              rev = "575ac4c24b296ea897821f9aaee1146ff258c704";
              hash = "sha256-icjQmfRUpo2nexX4XseQLPMhyffIxCftd0LHFW+LOwM=";
            };
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
  dontDetectOcamlConflicts = true;

  nativeBuildInputs = with ocamlPackages; [ ocaml findlib dune ];
  buildInputs = [
    nodePackages.mocha
    packages.melange
    packages.reactjs-jsx-ppx
    packages.rescript-syntax
    ocamlPackages.reason
    tree
    nodejs
    yarn
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
