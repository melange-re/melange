{ pkgs ? import ./sources.nix { } }:
let
  inherit (pkgs) stdenv ocamlPackages lib opaline;
in
with ocamlPackages;

stdenv.mkDerivation rec {
  name = "bucklescript";
  version = "9.0.0-dev";

  dontConfigure = true;
  buildPhase = ''
    runHook preBuild
    dune build -p ${name} -j $NIX_BUILD_CORES --display=short
    runHook postBuild
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    dune runtest -p ${name} --display=short
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    ${opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR

    cp package.json bsconfig.json $out
    cp -r ./_build/default/lib/es6 ./_build/default/lib/js $out/lib

    mkdir -p $out/lib/ocaml
    cd $out/lib/ocaml

    tar xvf $OCAMLFIND_DESTDIR/bucklescript/libocaml.tar.gz
    mv others/* .
    mv runtime/* .
    mv stdlib-412/stdlib_modules/* .
    mv stdlib-412/* .
    rm -rf others runtime stdlib-412

    runHook postInstall
  '';

  src = lib.filterGitSource {
    src = ./..;
    dirs = [ "jscomp" "scripts" ];
    files = [
      "dune-project"
      "dune"
      "dune-workspace"
      "bucklescript.opam"
      "bsconfig.json"
      "package.json"
    ];
  };

  nativeBuildInputs = with ocamlPackages; [
    pkgs.gnutar
    dune
    dune-action-plugin
    ocaml
    findlib
  ];

  buildInputs = [ cppo ];

  propagatedBuildInputs = [ reason ];
}
