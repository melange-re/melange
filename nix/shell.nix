{ lib
, mkShell
, nodejs
, packages
, system
, yarn
, cacert
, curl
, ocaml-ng
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
  inputsFrom = [ packages.melange ];
  nativeBuildInputs = with ocamlPackages; [
    ocamlformat
    utop
    # ocaml-lsp
    merlin
    python3
    nodejs
    yarn
    nodePackages.mocha
    # js_of_ocaml-compiler
  ] ++ lib.optionals release-mode ([
    cacert
    curl
    ocaml-ng.ocamlPackages_5_4.dune-release
    # ocamlPackages.odoc
    git
  ]);
  shellHook = ''
    PATH=$PWD/_build/install/default/bin:$PATH
  '';
}
