let
  lock = builtins.fromJSON (builtins.readFile ./../../flake.lock);
  src = fetchGit {
    url = with lock.nodes.nixpkgs.locked;"https://github.com/${owner}/${repo}";
    inherit (lock.nodes.nixpkgs.locked) rev;
    # inherit (lock.nodes.nixpkgs.original) ref;
  };
  nix-filter-src = fetchGit {
    url = with lock.nodes.nix-filter.locked; "https://github.com/${owner}/${repo}";
    inherit (lock.nodes.nix-filter.locked) rev;
    # inherit (lock.nodes.nixpkgs.original) ref;
    allRefs = true;
  };
  nix-filter = import "${nix-filter-src}";

  pkgs = import src {
    extraOverlays = [
      (self: super: { ocamlPackages = super.ocaml-ng.ocamlPackages_4_14; })
    ];
  };
  inherit (pkgs) stdenv nodejs yarn git lib ocamlPackages;
  packages = pkgs.callPackage ./.. { inherit nix-filter; };
  inputString =
    builtins.substring
      11 32
      (builtins.unsafeDiscardStringContext packages.melange.outPath);
in

stdenv.mkDerivation {
  name = "melange-tests-${inputString}";

  src = ../../jscomp/test;

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

  doCheck = true;

  nativeBuildInputs = with ocamlPackages; [ ocaml findlib dune ];
  buildInputs = [ yarn nodejs packages.melange packages.mel ];

  NIX_NODE_MODULES_POSTINSTALL = ''
    ln -sfn ${packages.melange}/lib/melange/runtime node_modules/melange
  '';

  checkPhase = ''
    # https://github.com/yarnpkg/yarn/issues/2629#issuecomment-685088015
    yarn install --frozen-lockfile --check-files --cache-folder .ycache && rm -rf .ycache
    mel build -- --display=short

    node ./node_modules/.bin/mocha "./*_test.js"
  '';
}
