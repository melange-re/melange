{ stdenv
, ocamlPackages
, fetchFromGitHub
, lib
, git
, tree
, makeWrapper
, nix-filter
, nodejs
}:


let

  # this changes rarely, and it's better than having to rely on nix's poor
  # support for submodules
  vendored = fetchFromGitHub {
    owner = "melange-re";
    repo = "melange-compiler-libs";
    rev = "73aa521a7d37f32885a870f4c77a482ead309ad3";
    hash = "sha256-P+HhbuBJBWSPVe5cUEZQxkwjYcrCw8g+pOhd2u2YTHM=";
  };

in

with ocamlPackages;

rec {
  melange = buildDunePackage {
    pname = "melange";
    version = "dev";
    duneVersion = "3";

    src = with nix-filter; filter {
      root = ./..;
      include = [
        "bin"
        "dune-project"
        "dune"
        "jscomp"
        "lib"
        "melange.opam"
        "ppx"
        "test"
        "scripts"
        "vendor"
      ];
      exclude = [ "jscomp/test" ];
    };
    postPatch = ''
      rm -rf vendor/melange-compiler-libs
      mkdir -p ./vendor
      cp -r ${vendored} ./vendor/melange-compiler-libs
    '';

    postInstall = ''
      wrapProgram "$out/bin/melc" \
        --set MELANGELIB "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/js/melange:$OCAMLFIND_DESTDIR/melange/belt/melange:$OCAMLFIND_DESTDIR/melange/dom/melange"
    '';

    doCheck = true;
    nativeCheckInputs = [
      tree
      nodejs
      reason
    ];
    checkInputs = [ ounit2 reactjs-jsx-ppx ];

    nativeBuildInputs = [ menhir cppo git makeWrapper ];
    propagatedBuildInputs = [
      dune-build-info
      base64
      cmdliner
      ppxlib
      menhirLib
    ];
    meta.mainProgram = "melc";
  };

  rescript-syntax = buildDunePackage {
    pname = "rescript-syntax";
    version = "dev";
    duneVersion = "3";

    src = with nix-filter; filter {
      root = ./..;
      include = [
        "dune-project"
        "rescript-syntax.opam"
        "rescript-syntax"
      ];
    };

    doCheck = true;
    propagatedBuildInputs = [ ppxlib melange ];

    meta.mainProgram = "rescript-syntax";
  };
}
