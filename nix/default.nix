{ stdenv, ocamlPackages, lib, opaline, gnutar, nix-filter }:

with ocamlPackages;

rec {
  melange = buildDunePackage rec {
    pname = "melange";
    version = "dev";

    src = with nix-filter; filter {
      root = ./..;
      include = [
        "dune-project"
        "dune"
        "dune.mel"
        "melange.opam"
        "melange.opam.template"
        "bsconfig.json"
        "package.json"
        "jscomp"
        "lib"
        "mel_workspace"
        "ppx_rescript_compat"
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

    doCheck = true;
    checkInputs = [ ounit2 ];

    nativeBuildInputs = [ cppo ];
    propagatedBuildInputs = [
      melange-compiler-libs
      reason
      cmdliner
    ];
  };

  mel = buildDunePackage rec {
    pname = "mel";
    version = "dev";

    src = with nix-filter; filter {
      root = ./..;
      include = [
        "dune-project"
        "dune"
        "dune.mel"
        "mel.opam"
        "mel"
        "mel_test"
        "scripts"
        "jscomp/keywords.list"
        "jscomp/main"
        "jscomp/ext"
        "jscomp/bsb_helper"
        "jscomp/stubs"
        "jscomp/common"
        "mel_workspace"
      ];
    };

    nativeBuildInputs = [ cppo ];
    propagatedBuildInputs = [
      melange
      cmdliner
      luv
      base64
    ];

    meta.mainProgram = "mel";
  };
}
