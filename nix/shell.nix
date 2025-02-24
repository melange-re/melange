{ lib
, mkShell
, nodejs
, packages
, system
, yarn
, cacert
, curl
, ocamlPackages
, git
, python3
, nodePackages
, release-mode ? false
}:

let
  derivations = lib.filterAttrs (_: value: lib.isDerivation value) packages;
in

mkShell {
  inputsFrom = lib.attrValues derivations;
  nativeBuildInputs = with ocamlPackages; [
    ocamlformat
    utop
    ocaml-lsp
    merlin
    python3
    nodejs
    yarn
    nodePackages.mocha
    js_of_ocaml-compiler
  ] ++ lib.optionals release-mode ([
    cacert
    curl
    ocamlPackages.dune-release
    ocamlPackages.odoc
    git
  ]);
  shellHook = ''
    PATH=$PWD/_build/install/default/bin:$PATH
  '';
}
