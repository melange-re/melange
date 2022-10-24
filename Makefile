SHELL := $(shell echo $$SHELL)

nix-%:
	nix develop '.?submodules=1#' --command $*

release-shell:
	nix develop '.?submodules=1#release' --command $(SHELL)
vim:
	$(MAKE) nix-n$@

generate-dune-files:
	node scripts/ninja.js

dev:
	dune build @install

.PHONY: vim shell dev
