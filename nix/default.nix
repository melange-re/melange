{ pkgs ? import ./sources.nix { } }:
let
  inherit (pkgs) stdenv ocamlPackages lib opaline;
in
with ocamlPackages;

stdenv.mkDerivation rec {
  name = "melange";
  version = "9.0.0-dev";

  buildPhase = ''
    runHook preBuild
    dune build -p ${name} -j $NIX_BUILD_CORES --display=short
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    ${opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR

    cp package.json bsconfig.json $out
    cp -r ./_build/default/lib/es6 ./_build/default/lib/js $out/lib

    mkdir -p $out/lib/melange
    cd $out/lib/melange

    tar xvf $OCAMLFIND_DESTDIR/melange/libocaml.tar.gz
    mv others/* .
    mv runtime/* .
    mv stdlib-412/stdlib_modules/* .
    mv stdlib-412/* .
    rm -rf others runtime stdlib-412

    runHook postInstall
  '';

  src = lib.filterGitSource {
    src = ./..;
    dirs = [ "jscomp" "lib" "scripts" ];
    files = [
      "dune-project"
      "dune"
      "dune-workspace"
      "melange.opam"
      "melange.opam.template"
      "bsconfig.json"
      "package.json"
    ];
  };

  nativeBuildInputs = with ocamlPackages; [
    pkgs.gnutar
    dune
    ocaml
    findlib
    cppo
  ];

  propagatedBuildInputs = [
    dune-action-plugin
    melange-compiler-libs
    reason
    cmdliner
  ];
}
