let
  pkgs = import ../sources.nix { };
  inherit (pkgs) stdenv nodejs-14_x yarn;
  thisPackage = import ./.. { inherit pkgs; };

in

stdenv.mkDerivation rec {
  name = "bucklescript-tests";

  inputString = builtins.unsafeDiscardStringContext thisPackage.outPath;

  # https://blog.eigenvalue.net/nix-rerunning-fixed-output-derivations/
  outputHashMode = "flat";
  outputHashAlgo = "sha256";
  outputHash = builtins.hashString "sha256" inputString;
  installPhase = ''
    echo -n $inputString > $out
  '';

  dontBuild = true;
  doCheck = true;

  inherit (thisPackage) src nativeBuildInputs propagatedBuildInputs;

  buildInputs = thisPackage.buildInputs ++ [
    yarn
    nodejs-14_x
    thisPackage
  ];

  checkPhase = ''
    shopt -s dotglob

    # https://github.com/yarnpkg/yarn/issues/2629#issuecomment-685088015
    yarn install --frozen-lockfile --check-files --cache-folder .ycache && rm -rf .ycache

    dune runtest -p ${thisPackage.name}

    # `--release` to avoid promotion
    dune build --release @jscomp/test/all

    node ./node_modules/.bin/mocha "_build/default/jscomp/test/**/*_test.js"
  '';
}
