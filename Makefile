
nix-%:
	nix develop '.?submodules=1#' --command $*
vim:
	$(MAKE) nix-n$@

dev:
	dune build @install

.PHONY: vim shell dev
