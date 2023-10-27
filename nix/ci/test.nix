{ ocamlVersion }:

let
  lock = builtins.fromJSON (builtins.readFile ./../../flake.lock);
  findFlakeSrc = { name, allRefs ? false }: fetchGit {
    url = with lock.nodes.${name}.locked;"https://github.com/${owner}/${repo}";
    inherit (lock.nodes.${name}.locked) rev;
    inherit allRefs;
  };

  src = findFlakeSrc { name = "nixpkgs"; };
  nix-filter-src = findFlakeSrc { name = "nix-filter"; };
  melange-compiler-libs-src = findFlakeSrc {
    name = "melange-compiler-libs";
  };
  nix-filter = import "${nix-filter-src}";

  pkgs = import src {
    extraOverlays = [
      (self: super: {
        ocamlPackages = super.ocaml-ng."ocamlPackages_${ocamlVersion}".overrideScope'
          (oself: osuper: {
            reason = osuper.reason.overrideAttrs (_: {
              src = super.fetchFromGitHub {
                owner = "reasonml";
                repo = "reason";
                rev = "366fefa23f39a437a07097f050fbb53d9767c6c9";
                hash = "sha256-bTaqD3hhD83QnGfgBvuUeb/I796isXfAseEGyyeQOVA=";
              };
            });

            sedlex = osuper.sedlex.overrideAttrs (_: {
              # depends on ppx_expect, which is not available for 4.13
              doCheck = false;
            });
          });
      })
    ];
  };
  inherit (pkgs) stdenv nodejs yarn git lib nodePackages ocamlPackages tree;
  packages = rec {
    melange = pkgs.callPackage ./.. {
      inherit nix-filter;
      melange-compiler-libs-vendor-dir = melange-compiler-libs-src;
    };
  };
  inputString =
    builtins.substring
      11 32
      (builtins.unsafeDiscardStringContext packages.melange.outPath);
in

with ocamlPackages;

stdenv.mkDerivation {
  name = "melange-tests-${inputString}";

  src = ../../jscomp/test;

  phases = [ "unpackPhase" "checkPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/lib
    cp -r dist dist-es6 $out/lib
  '';

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
    reason-react-ppx
    js_of_ocaml-compiler
  ];

  checkPhase = ''
    cat > dune-project <<EOF
    (lang dune 3.8)
    (using melange 0.1)
    EOF
    dune build @melange-runtime-tests --display=short

    mocha "_build/default/dist/**/*_test.js"
  '';
}
