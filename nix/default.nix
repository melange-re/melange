{ stdenv
, ocamlPackages
, jq
, lib
, git
, tree
, makeWrapper
, nodejs
, melange-compiler-libs-vendor-dir
, doCheck ? true
}:

with ocamlPackages;

buildDunePackage {
  pname = "melange";
  version = "dev";
  duneVersion = "3";

  src =
    let fs = lib.fileset; in
    fs.toSource {
      root = ./..;
      fileset = fs.unions [
        ../belt
        ../bin
        ../dune-project
        ../dune
        (fs.difference ../jscomp ../jscomp/test)
        ../melange.opam
        ../ppx
        ../scripts
        ../test
        ../vendor
      ];
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

  doCheck = doCheck &&
    # for some reason `-Wtrigraphs` was enabled in nixpkgs recently for
    # x86_64-darwin?
    !(stdenv.isDarwin && stdenv.isx86_64);
  nativeCheckInputs = [ tree nodejs reason jq merlin ];
  checkInputs = [ ounit2 ];
  DUNE_CACHE = "disabled";

  nativeBuildInputs = [ menhir cppo git makeWrapper ];
  propagatedBuildInputs = [
    dune-build-info
    cmdliner
    ppxlib
    menhirLib
  ];
  meta.mainProgram = "melc";
}
