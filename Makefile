
nix-%:
	nix develop '.?submodules=1#' --impure --command $*
vim:
	$(MAKE) nix-n$@

dev:
	dune build @install

.PHONY: vim shell dev
