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

    installPhase = ''
      runHook preInstall
      dune install --prefix $out ${pname}
      runHook postInstall
    '';

    inherit doCheck;
    checkInputs = with ocamlPackages; [ ounit2 tree nodejs reason ];

    nativeBuildInputs = with ocamlPackages; [ cppo ];
    propagatedBuildInputs = with ocamlPackages; [
      melange-compiler-libs
      cmdliner
      meldep
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
      meldep
    ];

    meta.mainProgram = "mel";
  };

  meldep = ocamlPackages.buildDunePackage rec {
    pname = "meldep";
    version = "dev";
    duneVersion = "3";

    src = with nix-filter; filter {
      root = ./..;
      include = [
        "dune-project"
        "dune"
        "dune.mel"
        "meldep.opam"
        "meldep"
        "mel_workspace"
        "jscomp/ext"
        "jscomp/stubs"
        "jscomp/keywords.list"
        "scripts"
      ];
    };

    nativeBuildInputs = with ocamlPackages; [ cppo ];
    propagatedBuildInputs = with ocamlPackages; [
      base64
      cmdliner
      melange-compiler-libs
    ];

    meta.mainProgram = "meldep";
  };

}
