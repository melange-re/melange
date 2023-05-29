# Melange

### Melange compiles OCaml / Reason to JavaScript

Powered by the versatile OCaml type system, with best-in-class type inference,
Melange produces robust JavaScript code.

+ [Melange](#melange)
  * [Installation](#installation)
    - [OPAM](#opam)
    - [Esy](#esy)
    - [Nix](#nix)
    - [OCaml version compatibility](#ocaml-version-compatibility)
  * [Editor integration](#editor-integration)
  * [Community](#community)
  * [FAQ](#faq)
    - [How does this project relate to other tools?](#how-does-this-project-relate-to-other-tools)
    - [Can I use ReScript syntax?](#can-i-use-rescript-syntax)
  * [Contributing](#contributing)
  * [Acknowledgments](#acknowledgments)
  * [Licensing](#licensing)

Sponsored by:

<img src="./docs/images/ahrefs-logo.png" height="50px">

## Installation

### [OPAM](https://opam.ocaml.org/)

Melange is released to OPAM. Install it with:

```shell
$ opam install melange
```

#### Template

[melange-re/melange-opam-template](https://github.com/melange-re/melange-opam-template)
provides a GitHub
[template repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)
that can be used as a project starter.

### [Esy](https://esy.sh)

Get Esy on NPM:

- `npm install -g esy` installs Esy globally
- if `npm` is installed, `npx esy` can be used to run Esy locally

An [Esy project starter](https://github.com/melange-re/melange-basic-template)
also exists.

After cloning the template, run `esy` in the project root.

### [Nix](https://nixos.org/learn.html)

Melange has good support for Nix:

- `github:melange-re/melange` can be added as a
  [flake](https://nixos.wiki/wiki/Flakes) input
- the melange flake provides a `melange.overlays.default` overlay that adds
  melange to `pkgs.ocamlPackages.melange`
- the `melc` binary can be run with `nix run github:melange-re/melange`, e.g.
  `nix run github:melange-re/melange -- --help`

### OCaml version compatibility

The current Melange distribution targets OCaml 4.14. There's an
[old version of Melange based on OCaml 4.12](https://github.com/melange-re/melange/releases/tag/0.1.0)
that requires
[version `4.12.0+mel`](https://github.com/melange-re/melange-compiler-libs/releases/tag/4.12.0%2Bmel)
of [`melange-compiler-libs`](https://github.com/melange-re/melange-compiler-libs).

## Editor integration

Melange has first class support in Dune.
[`ocaml-lsp`](https://github.com/ocaml/ocaml-lsp) or
[Merlin](https://github.com/ocaml/merlin) works as usual. In VSCode, the
[VSCode OCaml Platform](https://github.com/ocamllabs/vscode-ocaml-platform)
extension is recommended.

## Community

- There's a [`#melange` channel](https://discord.gg/mArvFMQKnK) in the
  [ReasonML Discord](https://discord.gg/reasonml)

## FAQ

### How does this project relate to other tools?

This project is forked from the
[ReScript compiler](https://github.com/rescript-lang/rescript-compiler/),
focused on a deeper integration with the OCaml ecosystem. This allows sharing
code between backend and frontend using Dune's virtual libraries.

Melange also introduces a ReScript compatibility layer to maintain compatibility
with ReScript syntax - preserving access to ReScript's package ecosystem.

A small write-up with more details on the motivation behind this project can be
found in the announcement
[blog post](https://anmonteiro.com/2021/03/on-ocaml-and-the-js-platform/).

Below is a quick comparison between Melange and other tools:


| Name                                   | Purpose                                                        | Dependencies                                                  | Notes                                                                                                                        |
| -------------------------------------- | -------------------------------------------------------------- | ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| [Esy](https://esy.sh)                  | Package manager                                                | Installed with NPM                                            | Obtaining dependencies such as `dune` or `reason` |
| [OPAM](https://opam.ocaml.org)         | Package manager                                                | None                                                          | Obtaining dependencies such as `dune` or `reason` |
| [Dune](https://dune.build/)            | Build tool                                                     | Installed with e.g. `esy` or `opam`                           | Composable build tool for OCaml; supports composing custom rules to build any project |
| [Reason](https://reasonml.github.io/)  | Syntax                                                         | Installed with e.g. `esy` or `opam`                           | Alternative syntax to OCaml |
| [Melange](https://melange.re)          | Compiler that emits Script                                     | Esy / OPAM (to install), Dune (to build) | Supports OCaml, Reason and ReScript syntax; derived from ReScript, focused on deeper integration with OCaml |
| [ReScript](https://rescript-lang.org/) | The brand around a syntax and a compiler that emits JavaScript | None                                                          | Distributed via NPM as prebuilt binaries; previously called BuckleScript |

### Can I use ReScript syntax?

Yes! ReScript syntax is supported, but ReScript won't have as many features as
the OCaml or Reason syntaxes due to ReScript being built on top of an old OCaml
version (4.06 - released in 2018).
(e.g. [`letop` binding operators](https://github.com/ocaml/ocaml/pull/1947),
[generalized module open expressions](https://github.com/ocaml/ocaml/pull/2147),
or [local substitutions in signatures](https://github.com/ocaml/ocaml/pull/2122)).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Acknowledgments

* Thanks to the [ReScript](https://github.com/rescript-lang/rescript-compiler)
  project, its author and maintainer [@bobzhang](https://github.com/bobzhang),
  and its many
  [contributors](https://github.com/rescript-lang/rescript-compiler/graphs/contributors).
  Melange is a fork of ReScript, and continues to incorporate patches to
  ReScript on a regular basis.
* Thanks to the [OCaml](https://ocaml.org) team, obviously, without such a
  beautiful yet practical language, this project would not exist.
* Thanks to [Bloomberg](https://www.techatbloomberg.com) and
  [Facebook](https://github.com/facebook/). The ReScript project began at
  Bloomberg and was published in 2016; without the support of Bloomberg, it
  would not have happened. ReScript was funded by Facebook since July 2017.

See also [Credits.md](./Credits.md) concerning some individual components of
Melange.

## Licensing

See [COPYING](./COPYING) and [COPYING.LESSER](./COPYING.LESSER)

See [Credits](./Credits.md) for more details.
