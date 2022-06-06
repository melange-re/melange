{ pkgs }:

let
  melange = pkgs.callPackage ./nix { };
  inherit (pkgs) stdenv lib;

  pnpm = pkgs.writeScriptBin "pnpm" ''
    #!${pkgs.runtimeShell}
    ${pkgs.nodejs_latest}/bin/node \
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
    yarn
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
