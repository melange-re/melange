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
    rev = "f39c5b3c9524688c7bf982016aa01030077135fe";
    hash = "sha256-LvjxC2RD8yKr0+fSCtY//btbU56JjHK7i9jSP1kmpIM=";
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
        "dune-project"
        "dune"
        "melange.opam"
        "jscomp"
        "lib"
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
        --set MELANGELIB "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/runtime/melange:$OCAMLFIND_DESTDIR/melange/belt/melange"
    '';

    doCheck = true;
    nativeCheckInputs = [
      tree
      nodejs
      reason
    ];
    checkInputs = [ ounit2 ];

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
