SHELL := $(shell echo $$SHELL)

nix-%:
	nix develop -L .# --command $*

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
	env IGNORECONSTRAINTS="melange,mel"
	opam pin add dune https://github.com/ocaml/dune.git#0d44bbfdb2a68907a464aeb2dabe95388dac5712 -y
	opam pin add melange-compiler-libs --dev-repo -y
	opam install luv reason -y
	opam pin add melange . --with-test -y
	opam pin add mel . --with-test -y

.PHONY: opam-init
opam-init: opam-create-switch opam-install ## Configure everything to develop this repository in local
