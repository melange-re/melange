
nix-%:
	nix develop '.?submodules=1#' --command $*
vim:
	$(MAKE) nix-n$@

generate-dune-files:
	node scripts/ninja.js

dev:
	dune build @install

.PHONY: vim shell dev
