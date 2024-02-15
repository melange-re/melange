{ stdenv
, ocamlPackages
, jq
, lib
, git
, tree
, makeWrapper
, nix-filter
, nodejs
, melange-compiler-libs-vendor-dir
, doCheck ? true
}:

with ocamlPackages;

buildDunePackage {
  pname = "melange";
  version = "dev";
  duneVersion = "3";

  src = with nix-filter; filter {
    root = ./..;
    include = [
      "bin"
      "dune-project"
      "dune"
      "jscomp"
      "lib"
      "melange.opam"
      "ppx"
      "test"
      "scripts"
      "vendor"
    ];
    exclude = [ "jscomp/test" ];
  };
  postPatch = ''
    rm -rf vendor/melange-compiler-libs
    mkdir -p ./vendor
    cp -r ${melange-compiler-libs-vendor-dir} ./vendor/melange-compiler-libs
  '';

  postInstall = ''
    wrapProgram "$out/bin/melc" \
      --set MELANGELIB "$OCAMLFIND_DESTDIR/melange/melange:$OCAMLFIND_DESTDIR/melange/js/melange"
  '';

  inherit doCheck;
  nativeCheckInputs = [ tree nodejs reason jq merlin ];
  checkInputs = [ ounit2 ];

  nativeBuildInputs = [ menhir cppo git makeWrapper ];
  propagatedBuildInputs = [
    dune-build-info
    cmdliner
    ppxlib
    menhirLib
    pp
  ];
  meta.mainProgram = "melc";
}
