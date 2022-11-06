{ dream2nix
, lib
, mkShell
, nodejs_latest
, packages
, stdenv
, system
, yarn
, tree
, cacert
, curl
, ocamlPackages
, writeScriptBin
, git
, h2spec
, release-mode ? false
}:

let
  derivations = lib.filterAttrs (_: value: lib.isDerivation value) packages;
  outputs = dream2nix.makeFlakeOutputs {
    systems = [ system ];
    config.projectRoot = ../jscomp/build_tests/monorepo;
    source = ../jscomp/build_tests/monorepo;
  };

  npmPackages = lib.trace "${builtins.toJSON( ( outputs))}" outputs.packages."${system}".monorepo;

in

mkShell {
  inputsFrom = lib.attrValues derivations;
  buildInputs = [
    nodejs_latest
    yarn
  ]
  ++ (with ocamlPackages; [
    merlin
    reason
    utop
    ocamlformat
    ocaml-lsp
  ])
  ++ lib.optionals release-mode [ cacert curl ocamlPackages.dune-release git ];
  shellHook = ''
    PATH=$PWD/bin:$PATH
    ln -sfn _build/install/default/bin ./bin
  '';
}
