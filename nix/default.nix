{ stdenv, ocamlPackages, lib, opaline, gnutar, nix-filter }:

with ocamlPackages;

buildDunePackage rec {
  pname = "melange";
  version = "dev";

  src = with nix-filter; filter {
    root = ./..;
    include = [
      "dune-project"
      "dune"
      "dune.mel"
      "melange.opam"
      "melange.opam.template"
      "bsconfig.json"
      "package.json"
      "jscomp"
      "lib"
      "ppx_rescript_compat"
      "scripts"
    ];
    exclude = [ "jscomp/test" ];
  };

  buildPhase = ''
    runHook preBuild
    dune build -p ${pname} -j $NIX_BUILD_CORES --display=short
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    dune install --prefix $out ${pname}
    runHook postInstall
  '';

  doCheck = true;
  checkInputs = [ ounit2 ];

  nativeBuildInputs = [ gnutar cppo ];
  propagatedBuildInputs = [
    melange-compiler-libs
    reason
    cmdliner
    luv
    base64
  ];

  meta.mainProgram = "mel";
}
