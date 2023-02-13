{ stdenv, ocamlPackages, lib, tree, nix-filter, nodejs, doCheck ? true }:

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
        "dune.mel"
        "melange.opam"
        "bsconfig.json"
        "package.json"
        "jscomp"
        "lib"
        "meldep"
        "test"
        "mel_workspace"
        "reactjs_jsx_ppx"
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
      mkdir -p $out/lib/melange
      cp -r $out/lib/ocaml/${ocamlPackages.ocaml.version}/site-lib/melange/__MELANGE_RUNTIME__ \
            $out/lib/melange/__MELANGE_RUNTIME__
    '';

    inherit doCheck;
    nativeCheckInputs = [ tree nodejs ocamlPackages.reason ];
    checkInputs = with ocamlPackages; [ ounit2 ];

    nativeBuildInputs = with ocamlPackages; [ cppo ];
    propagatedBuildInputs = with ocamlPackages; [
      base64
      melange-compiler-libs
      cmdliner
    ];
    meta.mainProgram = "melc";
  };

  mel = ocamlPackages.buildDunePackage rec {
    pname = "mel";
    version = "dev";
    duneVersion = "3";

    src = with nix-filter; filter {
      root = ./..;
      include = [
        "dune-project"
        "dune"
        "dune.mel"
        "mel.opam"
        "mel"
        "mel_test"
        "meldep"
        "package.json"
        "scripts"
        "jscomp/dune"
        "jscomp/build_version.ml"
        "jscomp/keywords.list"
        "jscomp/main"
        "jscomp/ext"
        "jscomp/stubs"
        "jscomp/common"
        "jscomp/frontend"
        "reactjs_jsx_ppx"
        "jscomp/napkin"
        "jscomp/js_parser"
        "jscomp/outcome_printer"
        "mel_workspace"
      ];
    };

    nativeBuildInputs = with ocamlPackages; [ cppo ];
    propagatedBuildInputs = with ocamlPackages; [
      cmdliner
      luv
      ocaml-migrate-parsetree-2
      melange
    ];

    meta.mainProgram = "mel";
  };
}
