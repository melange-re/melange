{ pkgs ? import ./sources.nix {} }:

let
  inherit (pkgs) stdenv ocamlPackages lib opaline;
in

with ocamlPackages;

stdenv.mkDerivation rec {
  name = "bucklescript";
  useDune2 = true;
  version = "8.2.0-dev";

  postPatch = ''
    cp ${./patches/0005-ninja-lexer.patch} ./ninja.patch

    sed -i 's:./configure.py --bootstrap:python3 ./configure.py --bootstrap:' ./scripts/install.js
    mkdir -p ./linux
  '';

  buildPhase = ''
    runHook preBuild
    node scripts/install.js

    dune build -p ${name} -j $NIX_BUILD_CORES --display=short
    runHook postBuild
  '';

  # checkPhase = ''
    # runHook preCheck
    # dune runtest -p ${name} ''${enableParallelBuilding:+-j $NIX_BUILD_CORES} --display=short
    # runHook postCheck
  # '';

  installPhase = ''
    runHook preInstall
    ${opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR

    mv ./linux/ninja.exe $out/bin
    cp package.json bsconfig.json $out
    cp -r ./_build/default/lib/es6 ./_build/default/lib/js $out/lib

    mkdir -p $out/lib/ocaml
    tar -C $out/lib/ocaml -xzf $out/share/bucklescript/libocaml.tar.gz --strip-components=1

    runHook postInstall
  '';

  src = lib.filterGitSource ({
    src = ./..;
    dirs = [ "jscomp" "syntax" "scripts" ];
    files = [
      "dune"
      "dune-project"
      "dune-workspace"
      "bucklescript.opam"
      "bsconfig.json"
      "package.json"];
  });

  nativeBuildInputs = [
    pkgs.gnutar
    pkgs.nodejs-14_x
    pkgs.ocaml-ng.ocamlPackages_4_11.dune_2
    ocaml
    findlib
  ];

  buildInputs = [
    cppo
  ];

  propagatedBuildInputs = [
    reason
    camlp4
  ];
}


