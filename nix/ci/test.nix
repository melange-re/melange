let
  lock = builtins.fromJSON (builtins.readFile ./../../flake.lock);
  src = fetchGit {
    url = with lock.nodes.nixpkgs.locked;"https://github.com/${owner}/${repo}";
    inherit (lock.nodes.nixpkgs.locked) rev;
    # inherit (lock.nodes.nixpkgs.original) ref;
  };
  pkgs = import src {
    extraOverlays = [
      (self: super: {
        ocamlPackages = super.ocaml-ng.ocamlPackages_4_14;
      })
    ];
  };
  inherit (pkgs) stdenv nodejs-14_x yarn git lib ocamlPackages;
  melange = pkgs.callPackage ./.. { };
  inputString = builtins.substring 11 32 (builtins.unsafeDiscardStringContext melange.outPath);
in

stdenv.mkDerivation {
  name = "melange-tests-${inputString}";
  inherit (melange) nativeBuildInputs propagatedBuildInputs;

  src = ../..;

  # https://blog.eigenvalue.net/nix-rerunning-fixed-output-derivations/
  # the dream of running fixed-output-derivations is dead -- somehow after
  # Nix 2.4 it results in `error: unexpected end-of-file`.
  # Example: https://github.com/melange-re/melange/runs/4132970590

  outputHashMode = "flat";
  outputHashAlgo = "sha256";
  outputHash = builtins.hashString "sha256" "melange";
  installPhase = ''
    echo -n melange > $out
  '';

  phases = [ "unpackPhase" "checkPhase" "installPhase" ];

  checkInputs = with ocamlPackages; [ ounit2 ];
  doCheck = true;

  buildInputs = melange.buildInputs ++ [
    git
    yarn
    nodejs-14_x
    melange
  ];

  checkPhase = ''
    # https://github.com/yarnpkg/yarn/issues/2629#issuecomment-685088015
    yarn install --frozen-lockfile --check-files --cache-folder .ycache && rm -rf .ycache

    # `--release` to avoid promotion
    rm -rf _build && dune build --release --display=short -j $NIX_BUILD_CORES @jscomp/test/all

    # check that running `node scripts/ninja.js config` produces an empty diff.
    # dune build jscomp/main/js_main.exe
    node scripts/ninja.js config

    git diff --exit-code

    node ./node_modules/.bin/mocha "_build/default/jscomp/test/**/*_test.js"

    dune runtest -p ${melange.name} -j $NIX_BUILD_CORES --display=short
  '';
}
