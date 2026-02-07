{
  stdenv,
  ocamlPackages,
  nodePackages,
  jq,
  lib,
  git,
  tree,
  makeWrapper,
  nodejs,
  melange-compiler-libs-vendor-dir,
  doCheck ? true,
}:

with ocamlPackages;

buildDunePackage {
  pname = "melange";
  version = "dev";
  duneVersion = "3";

  src =
    let
      fs = lib.fileset;
    in
    fs.toSource {
      root = ./..;
      fileset = fs.unions [
        ../belt
        ../bin
        ../dune-project
        ../dune
        ../jscomp
        ../melange.opam
        ../ppx
        ../test
        ../vendor
      ];
    };

  postPatch = ''
    rm -rf vendor/melange-compiler-libs
    mkdir -p ./vendor
    cp -r ${melange-compiler-libs-vendor-dir} ./vendor/melange-compiler-libs
  '';

  postInstall = ''
    wrapProgram "$out/bin/melc" \
      --set MELANGELIB "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/js/melange"
  '';

  doCheck =
    doCheck
    &&
      # for some reason `-Wtrigraphs` was enabled in nixpkgs recently for
      # x86_64-darwin?
      !(stdenv.isDarwin && stdenv.isx86_64);

  checkPhase = ''
    dune build @melange-runtime-tests --profile=release --display=short
    mocha "jscomp/test/dist/**/*_test.*js"
  '';

  nativeCheckInputs = [
    tree
    nodejs
    reason
    jq
    merlin
    nodePackages.mocha
  ];
  checkInputs = [
    alcotest
    reason-react-ppx
  ];
  DUNE_CACHE = "disabled";

  nativeBuildInputs = [
    menhir
    cppo
    git
    makeWrapper
  ];
  propagatedBuildInputs = [
    dune-build-info
    cmdliner
    ppxlib
    menhirLib
  ];
  meta.mainProgram = "melc";
}
