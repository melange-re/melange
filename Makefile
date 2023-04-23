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
	opam exec -- dune runtest -p melange,reactjs-jsx-ppx

.PHONY: opam-create-switch
opam-create-switch: ## Create opam switch
	opam switch create . 4.14.1 -y --no-install

.PHONY: opam-install-test
opam-install-test: ## Install test dependencies
	opam pin -y add dune.dev https://github.com/ocaml/dune.git#4c18a4cd6121de6bb20b76236d6fb54c17e1b3a9
	opam pin -y add melange-compiler-libs.dev https://github.com/melange-re/melange-compiler-libs.git#575ac4c24b296ea897821f9aaee1146ff258c704
	opam pin add reactjs-jsx-ppx.dev . --with-test -y
	opam pin add melange.dev . --with-test -y
	opam pin add rescript-syntax.dev . --with-test -y

.PHONY: opam-install-dev
opam-install-dev: opam-install-test ## Install development dependencies
	cd ocaml-tree && npm install
	opam install -y ocaml-lsp-server

.PHONY: opam-init
opam-init: opam-create-switch opam-install-test ## Configure everything to develop this repository in local
