{ ocamlVersion ? "4_12" }:
let
  overlays =
    builtins.fetchTarball
      https://github.com/anmonteiro/nix-overlays/archive/4af1080c.tar.gz;

in
import "${overlays}/sources.nix" {
  overlays = [
    (import overlays)
    (self: super: {
      ocamlPackages = super.ocaml-ng."ocamlPackages_${ocamlVersion}".overrideScope'
        (oself: osuper: {
          tree-sitter = oself.buildDunePackage {
            pname = "tree-sitter";
            version = "NA";
            dontConfigure = true;
            src = builtins.fetchurl {
              url = https://github.com/returntocorp/ocaml-tree-sitter/archive/bee63d6c4ac7b6d24539f9f2c8cf5ba57ecce91d.tar.gz;
              sha256 = "1mkv2zlcqhncfngc24kjc6rj7a80mj3rb07s0fp7abmddrrkdwxw";
            };
            buildPhase = ''
              dune build -p tree-sitter
            '';
            buildInputs = [ self.tree-sitter ];
            propagatedBuildInputs = with oself; [ atdgen cmdliner ppx_sexp_conv ppx_deriving sexplib tsort ansiterminal ];
          };
        });
    })
  ];
}
