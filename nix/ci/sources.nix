{ ocamlVersion }:

let
  lock = builtins.fromJSON (builtins.readFile ./../../flake.lock);
  findFlakeSrc = { name, allRefs ? false }: fetchGit {
    url = with lock.nodes.${name}.locked;"https://github.com/${owner}/${repo}";
    inherit (lock.nodes.${name}.locked) rev;
    inherit allRefs;
  };

  src = findFlakeSrc { name = "nixpkgs"; };
  nix-filter-src = findFlakeSrc { name = "nix-filter"; };
  melange-compiler-libs-src = findFlakeSrc {
    name = "melange-compiler-libs";
    allRefs = true;
  };
  nix-filter = import "${nix-filter-src}";

  pkgs = import src {
    extraOverlays = [
      (self: super: {
        ocamlPackages = super.ocaml-ng."ocamlPackages_${ocamlVersion}";
      })
    ];
  };
  packages = rec {
    melange = pkgs.callPackage ./.. {
      inherit nix-filter;
      melange-compiler-libs-vendor-dir = melange-compiler-libs-src;
    };
  };
in
{ inherit pkgs packages; }
