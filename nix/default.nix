{ stdenv
, ocamlPackages
, lib
, git
, tree
, makeWrapper
, nix-filter
, nodejs
}:

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
        "bsconfig.json"
        "package.json"
        "jscomp"
        "lib"
        "test"
        "scripts"
        "vendor"
      ];
      exclude = [ "jscomp/test" ];
    };

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
        "vendor"
        "jscomp"
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
