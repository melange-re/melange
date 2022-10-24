{ dream2nix
, lib
, mkShell
, nodejs-16_x
, packages
, python3
, stdenv
, system
, yarn
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
    python3
    nodejs-16_x
    (yarn.override { nodejs = nodejs-16_x; })
  ]
  ++ (with ocamlPackages; [
    merlin
    utop
    ounit2
    ocamlformat
    ocaml-lsp
  ])
  ++ lib.optionals release-mode [ cacert curl ocamlPackages.dune-release git ];
  shellHook = ''
    PATH=$PWD/bin:$PATH
    ln -sfn _build/install/default/bin ./bin
  '';
}
