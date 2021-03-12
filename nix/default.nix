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

  # doCheck = true;
  # checkPhase = ''
  # runHook preCheck
  # dune runtest -p ${name} --display=short
  # runHook postCheck
  # '';

  installPhase = ''
    runHook preInstall
    ${opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR

    cp package.json bsconfig.json $out
    cp -r ./_build/default/lib/es6 ./_build/default/lib/js $out/lib

    mkdir -p $out/lib/ocaml

    cd $out/lib/ocaml
    pax -rz -v -s '!^runtime/!!' -s '!^others/!!' -s '!^stdlib-412/stdlib_modules/!!' -s '!^stdlib-412/!!'  < $out/share/bucklescript/libocaml.tar.gz


    # tar -C $out/lib/ocaml -xzf $out/share/bucklescript/libocaml.tar.gz --strip-components=1

    runHook postInstall
  '';

  src = lib.filterGitSource {
    src = ./..;
    dirs = [ "jscomp" "syntax" "scripts" ];
    files = [
      "dune"
      "dune-project"
      "dune-workspace"
      "bucklescript.opam"
      "bsconfig.json"
      "package.json"
    ];
  };

  nativeBuildInputs = [
    pkgs.gnutar
    pkgs.ocaml-ng.ocamlPackages_4_11.dune_2
    pkgs.ocamlPackages.ocaml
    findlib
  ];

  buildInputs = [ cppo ];

  propagatedBuildInputs = [ reason ];
}
