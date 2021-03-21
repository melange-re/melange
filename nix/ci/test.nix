let
  pkgs = import ../sources.nix { };
  inherit (pkgs) stdenv nodejs-14_x yarn lib;
  thisPackage = import ./.. { inherit pkgs; };

in

stdenv.mkDerivation rec {
  name = "bucklescript-tests";
  inherit (thisPackage) nativeBuildInputs propagatedBuildInputs;

  src = lib.filterGitSource {
    src = ./../..;
    dirs = [ "jscomp" "scripts" "lib" ];
    files = [
      "dune-project"
      "dune"
      "dune-workspace"
      "bucklescript.opam"
      "bsconfig.json"
      "package.json"
    ];
  };

  inputString = builtins.unsafeDiscardStringContext thisPackage.outPath;

  # https://blog.eigenvalue.net/nix-rerunning-fixed-output-derivations/
  outputHashMode = "flat";
  outputHashAlgo = "sha256";
  outputHash = builtins.hashString "sha256" inputString;
  installPhase = ''
    echo -n $inputString > $out
  '';

  phases = [ "unpackPhase" "checkPhase" "installPhase" ];
  doCheck = true;

  buildInputs = thisPackage.buildInputs ++ [
    yarn
    nodejs-14_x
    thisPackage
  ];

  checkPhase = ''
    dune runtest -p ${thisPackage.name} -j $NIX_BUILD_CORES --display=short

    # https://github.com/yarnpkg/yarn/issues/2629#issuecomment-685088015
    yarn install --frozen-lockfile --check-files --cache-folder .ycache && rm -rf .ycache

    # `--release` to avoid promotion
    dune build --release --display=short -j $NIX_BUILD_CORES @jscomp/test/all

    node ./node_modules/.bin/mocha "_build/default/jscomp/test/**/*_test.js"
  '';
}
