{ dream2nix
, lib
, mkShell
, nodejs_latest
, packages
, system
, yarn
, cacert
, curl
, ocamlPackages
, git
, python3
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
    PATH=$PWD/_build/install/default/bin:$PATH
  '';
}
