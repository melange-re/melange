let
  pkgs = import ../sources.nix { };
  inherit (pkgs) stdenv nodejs-14_x yarn lib;
  melange = import ./.. { inherit pkgs; };

in

stdenv.mkDerivation rec {
  name = "melange-tests";
  inherit (melange) src nativeBuildInputs propagatedBuildInputs;

  inputString = builtins.unsafeDiscardStringContext melange.outPath;

  # https://blog.eigenvalue.net/nix-rerunning-fixed-output-derivations/
  outputHashMode = "flat";
  outputHashAlgo = "sha256";
  outputHash = builtins.hashString "sha256" inputString;
  installPhase = ''
    echo -n $inputString > $out
  '';

  phases = [ "unpackPhase" "checkPhase" "installPhase" ];
  doCheck = true;

  checkInputs = [ ounit2 ];

  buildInputs = melange.buildInputs ++ [
    yarn
    nodejs-14_x
    melange
  ];

  checkPhase = ''
    # https://github.com/yarnpkg/yarn/issues/2629#issuecomment-685088015
    yarn install --frozen-lockfile --check-files --cache-folder .ycache && rm -rf .ycache

    # `--release` to avoid promotion
    dune build --release --display=short -j $NIX_BUILD_CORES @jscomp/test/all
    node ./node_modules/.bin/mocha "_build/default/jscomp/test/**/*_test.js"

    dune runtest -p ${melange.name} -j $NIX_BUILD_CORES --display=short
  '';
}
