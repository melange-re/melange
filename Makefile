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

.PHONY: opam-create-switch
opam-create-switch: ## Create opam switch
	opam switch create . -y --deps-only --with-test

.PHONY: opam-install
opam-install: ## Install development dependencies
	cd ocaml-tree && npm install
	opam install -y ocaml-lsp-server

.PHONY: opam-init
opam-init: opam-create-switch opam-install ## Configure everything to develop this repository in local
