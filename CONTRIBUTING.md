# Contributing

Thanks for your interest! Below we describe Melange's development setup for a few different package managers. If something isn't working, or you'd like to add another workflow, please let us know by filing an issue.


## Installation

Melange can be set up with [#nix](Nix) or [#esy](Esy). Instructions for both are detailed below.

### Nix

**Prerequisites**:
- Obtaining the [Nix](https://nixos.org/) package manager
- Installing [Nix flakes](https://nixos.wiki/wiki/Flakes)


The best way to get started is to get a `nix` shell running:

```sh
# Opens a shell with the necessary environment.
make nix-zsh
```

Once you're in the shell, you have access to `dune`, `node`, `yarn`, and all the other executables you need to get down to business.

You can also use `make nix-*` to execute arbitrary commands in the nix environment.

```sh
make nix-nvim # Runs nvim in the nix environment
make nix-vscode # Opens vscode in the nix environment
make nix-fish # Opens fish shell
# etc.
```

### Esy

In order to develop using [Esy](https://esy.sh/), you need to install it first. The usual way for doing that is to run `npm install -g esy`. Then run:

1. `esy install` to get all the project's dependencies
2. `esy build` to build the project.

## Developing

Before you try building with `dune`, be sure to install the local `ocaml-tree` project:

```sh
cd ocaml-tree && npm install
```

Here are some common commands you may find useful:

- `dune build` builds the whole project
- `dune runtest` runs the native tests
- `dune exec jscomp/main/melc.exe` is useful to run the development version of `bsc`

If you're on an esy environment, prefix the command with the `esy` command.

## Submitting a Pull Request

When you are almost ready to open a PR, it's a good idea to run the full CI test suite locally to make sure everything works. First, open a new non-`nix` shell or exit your current `nix` shell by using the `exit` command or `ctrl+d`. Then, run the following command:

```sh
# Runs the full CI test suite
nix-build nix/ci/test.nix
```

If that all passes, then congratulations! You are well on your way to becoming a contributor 🎉
