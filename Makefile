USER_SHELL = $(shell echo $$SHELL)

nix-%:
	nix develop -L .# --command $*

.PHONY: release-shell
release-shell:
	nix develop .#release --command $(USER_SHELL)

.PHONY: vim
vim:
	$(MAKE) nix-n$@

.PHONY: generate-dune-files
generate-dune-files:
	node scripts/ninja.js

.PHONY: dev
dev:
	dune build @install

.PHONY: test
test:
	opam exec -- dune build @runtest -p melange

.PHONY: opam-create-switch
opam-create-switch: ## Create opam switch
	opam switch create . -y --deps-only --with-test

.PHONY: opam-install-test
opam-install-test: ## Install test dependencies
	cd ocaml-tree && npm install
	opam pin -y add dune https://github.com/ocaml/dune.git#21914b91f66a94e2cae33b9b19ea1521b6104d8a
	opam pin -y add melange-compiler-libs https://github.com/melange-re/melange-compiler-libs.git#48ff923f2c25136de8ab96678f623f54cdac438c
	opam pin add melange . --with-test -y
	opam pin add mel . --with-test -y

.PHONY: opam-install-dev
opam-install-dev: opam-install-test ## Install development dependencies
	opam install -y ocaml-lsp-server

.PHONY: opam-init
opam-init: opam-create-switch opam-install ## Configure everything to develop this repository in local
