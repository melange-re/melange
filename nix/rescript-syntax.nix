{ buildDunePackage
, melange
, nix-filter
, ppxlib
}:


buildDunePackage {
  pname = "rescript-syntax";
  version = "dev";
  duneVersion = "3";

  src = with nix-filter; filter {
    root = ./..;
    include = [
      "dune-project"
      "rescript-syntax.opam"
      "rescript-syntax"
      "test/blackbox-tests/rescript-syntax"
    ];
  };

  doCheck = true;
  nativeBuildInputs = [ melange ];
  propagatedBuildInputs = [ ppxlib melange ];

  meta.mainProgram = "rescript-syntax";
}
