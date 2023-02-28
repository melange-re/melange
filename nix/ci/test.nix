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
        ocamlPackages = super.ocaml-ng.ocamlPackages_4_14.overrideScope' (oself: osuper: {
          dune_3 = osuper.dune_3.overrideAttrs (_: {
            src = super.fetchFromGitHub {
              owner = "ocaml";
              repo = "dune";
              rev = "5de6e9f0946727f3cab329f9442273c0bfcca3cf";
              sha256 = "sha256-W5Q4VNi9OjidRTwQkuilm1MVyQqo7WuaTIQsTTLjpSQ=";
            };

          });
          melange-compiler-libs = osuper.melange-compiler-libs.overrideAttrs (_: {
            src = super.fetchFromGitHub {
              owner = "melange-re";
              repo = "melange-compiler-libs";
              rev = "545e007bd9168b5297d6d953a55d77123639f328";
              sha256 = "sha256-3AmDdqdK1NyQRs1PK/4FeTBWEeostxiFD9I7vEItpgY=";
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

  nativeBuildInputs = with ocamlPackages; [ ocaml findlib dune ];
  buildInputs = [
    nodePackages.mocha
    packages.melange
    packages.mel
    ocamlPackages.reason
    tree
    nodejs
    yarn
  ];

  checkPhase = ''
    cat > dune-project <<EOF
    (lang dune 3.7)
    (using melange 0.1)
    (using directory-targets 0.1)
    EOF
    dune build @melange-runtime-tests --display=short

    mocha "_build/default/dist/*_test.js"

    mkdir node_modules
    dune clean
    ln -sfn ${packages.melange}/lib/melange/__MELANGE_RUNTIME__ node_modules/melange
    rm -rf ./dune
    mel build -- --display=short
    mocha "./*_test.js"
  '';
}
