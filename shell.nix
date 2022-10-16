{ pkgs, dream2nix, system, nodejs_latest, melange }:


let


  outputs = dream2nix.makeFlakeOutputs {
    systems = [ system ];
    config.projectRoot = ./jscomp/build_tests/monorepo;
    source = ./jscomp/build_tests/monorepo;
  };

  npmPackages = lib.trace "${builtins.toJSON( ( outputs))}" outputs.packages."${system}".monorepo;
  inherit (pkgs) stdenv lib;

  pnpm = pkgs.writeScriptBin "pnpm" ''
    #!${pkgs.runtimeShell}
    ${pkgs.nodejs}/bin/node \
      ${pkgs.nodePackages_latest.pnpm}/lib/node_modules/pnpm/bin/pnpm.cjs \
      "$@"
  '';

in

with pkgs;

mkShell {
  inputsFrom = [ melange ];
  buildInputs = [
    pnpm
    python3
    nodejs-16_x
    (yarn.override { nodejs = nodejs-16_x; })
  ] ++ (with ocamlPackages; [
    merlin
    utop
    ounit2
    ocamlformat
    ocaml-lsp
  ]);

  shellHook = ''
    PATH=$PWD/bin:$PATH
    ln -sfn _build/install/default/bin ./bin
  '';
}
