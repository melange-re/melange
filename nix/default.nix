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
    repo = "melange";
    rev = "7c71a868e0f8d465972ab4523e2b2bec9544461c";
    hash = "sha256-Q2etr2OJCR+DnQxOhqfE0B04xkf9y4BqCd20yAk97sI=";
    fetchSubmodules = true;
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
      ];
      exclude = [ "jscomp/test" ];
    };
    postPatch = ''
      cp -r ${vendored}/vendor ./vendor
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
    checkInputs = [ ounit2 reactjs-jsx-ppx ];

    nativeBuildInputs = [ menhir cppo git ];
    buildInputs = [ makeWrapper ];
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

    propagatedBuildInputs = [ ppxlib melange ];

    meta.mainProgram = "rescript-syntax";
  };

  reactjs-jsx-ppx = buildDunePackage {
    pname = "reactjs-jsx-ppx";
    version = "dev";
    duneVersion = "3";

    src = with nix-filter; filter {
      root = ./..;
      include = [
        "dune-project"
        "reactjs-jsx-ppx.opam"
        "reactjs-jsx-ppx"
      ];
    };
    propagatedBuildInputs = [ ppxlib ];
  };
}
