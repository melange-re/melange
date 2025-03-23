{ pkgs, packages }:

let
  inputString =
    builtins.substring
      11 32
      (builtins.unsafeDiscardStringContext packages.melange.outPath);
  inherit (pkgs) stdenv nodejs yarn git lib nodePackages ocamlPackages tree;
in

with ocamlPackages;

stdenv.mkDerivation {
  name = "melange-tests-${inputString}";

  src = ../jscomp/test;

  phases = [ "unpackPhase" "checkPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/lib
    cp -r dist dist-es6 $out/lib
  '';

  doCheck = true;
  nativeBuildInputs = [
    ocaml
    findlib
    dune
    git
    nodePackages.mocha
    reason
    tree
    nodejs
    yarn
  ];
  buildInputs = [
    packages.melange
    reason-react-ppx
    js_of_ocaml-compiler
  ];

  checkPhase = ''
    cat > dune-project <<EOF
    (lang dune 3.8)
    (using melange 0.1)
    EOF
    dune build @melange-runtime-tests --display=short

    mocha "_build/default/dist/**/*_test.js"
  '';
}
