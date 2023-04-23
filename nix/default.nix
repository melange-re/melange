{ stdenv
, ocamlPackages
, lib
, tree
, makeWrapper
, nix-filter
, nodejs
}:

rec {
  melange = ocamlPackages.buildDunePackage rec {
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
      ];
      exclude = [ "jscomp/test" ];
    };

    buildPhase = ''
      runHook preBuild
      dune build -p ${pname} -j $NIX_BUILD_CORES --display=short
      runHook postBuild
    '';

    postInstall = ''
      wrapProgram "$out/bin/melc" \
        --set MELANGELIB "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/runtime/melange:$OCAMLFIND_DESTDIR/melange/belt/melange"
    '';

    doCheck = true;
    nativeCheckInputs = [
      tree
      nodejs
      ocamlPackages.reason
    ];
    checkInputs = with ocamlPackages; [ ounit2 reactjs-jsx-ppx ];

    nativeBuildInputs = with ocamlPackages; [ cppo ];
    buildInputs = [ makeWrapper ];
    propagatedBuildInputs = with ocamlPackages; [
      base64
      melange-compiler-libs
      cmdliner
      ppxlib
    ];
    meta.mainProgram = "melc";
  };

  rescript-syntax = ocamlPackages.buildDunePackage rec {
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

    propagatedBuildInputs = with ocamlPackages; [
      ppxlib
      melange
    ];

    meta.mainProgram = "rescript-syntax";
  };

  reactjs-jsx-ppx = ocamlPackages.buildDunePackage rec {
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
    propagatedBuildInputs = with ocamlPackages; [ ppxlib ];
  };
}
