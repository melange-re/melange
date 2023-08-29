USER_SHELL = $(shell echo $$SHELL)

nix-%:
	nix develop -L '.?submodules=1#' --command $*

.PHONY: release-shell
release-shell:
	nix develop '.?submodules=1#release' --command $(USER_SHELL)

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
	opam exec -- dune runtest -p melange

.PHONY: opam-create-switch
opam-create-switch: ## Create opam switch
	opam switch create . 4.14.1 -y --no-install

.PHONY: opam-install-test
opam-install-test: ## Install test dependencies
	opam pin add reason.dev -y git+https://github.com/reasonml/reason.git
	opam pin add reason-react-ppx.dev -y git+https://github.com/reasonml/reason-react.git#anmonteiro/mel-attrs
	opam pin add melange.dev . --with-test -y
	opam pin add melange-playground.dev . --with-test -y

.PHONY: opam-install-dev
opam-install-dev: opam-install-test ## Install development dependencies
	cd ocaml-tree && npm install
	opam install -y ocaml-lsp-server

.PHONY: opam-init
opam-init: opam-create-switch opam-install-test ## Configure everything to develop this repository in local

.PHONY: playground
playground:
	opam exec -- dune build --profile=release bin/jsoo_main.bc.js

.PHONY: playground-dev
playground-dev:
	opam exec -- dune build --profile=dev bin/jsoo_main.bc.js

.PHONY: playground-dev-test
playground-dev-test:
	opam exec -- dune build --profile=dev @@test/blackbox-tests/melange-playground/playground

.PHONY: playground-test
playground-test:
	opam exec -- dune build --profile=release @@test/blackbox-tests/melange-playground/playground
