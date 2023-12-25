# Melange

### Melange compiles OCaml / Reason to JavaScript

Powered by the versatile OCaml type system, with best-in-class type inference,
Melange produces robust JavaScript code.

+ [Melange](#melange)
  * [Installation](#installation)
    - [OPAM](#opam)
    - [Nix](#nix)
    - [OCaml version compatibility](#ocaml-version-compatibility)
  * [Editor integration](#editor-integration)
  * [Community](#community)
  * [FAQ](#faq)
    - [How does this project relate to other tools?](#how-does-this-project-relate-to-other-tools)
  * [Contributing](#contributing)
  * [Acknowledgments](#acknowledgments)
  * [Licensing](#licensing)

Sponsored by:

<div style="display: inline;">
  <a href="https://ahrefs.com">
    <img src="./docs/images/ahrefs-logo.png" height="50px">
  </a>
  <a href="https://ocaml-sf.org/">
    <img src="./docs/images/ocsf_logo.svg" height="50px">
  </a>
  <a href="https://www.instapainting.com">
    <img src="./docs/images/instapainting-logo.png" height="30px">
  </a>
</div>

## Installation

Check [melange.re](https://melange.re/) to get started.

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

### [Nix](https://nixos.org/learn.html)

Melange has good support for Nix:

- `github:melange-re/melange` can be added as a
  [flake](https://nixos.wiki/wiki/Flakes) input
- the melange flake provides a `melange.overlays.default` overlay that adds
  melange to `pkgs.ocamlPackages.melange`
- the `melc` binary can be run with `nix run github:melange-re/melange`, e.g.
  `nix run github:melange-re/melange/2.0.0 -- --help`

### OCaml version compatibility

- Melange v2.0 works on OCaml 5.1 only.
- Melange v1.0 can build projects with OCaml >= 4.13 (including OCaml 5.x).
  - Editor integration only works on OCaml 4.14, because Melange emits [`.cmt`
    artifacts](https://ocaml.org/p/ocaml-base-compiler/4.14.1/doc/Cmt_format/index.html)
    targeting the OCaml 4.14 binary format.

### Editor integration

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

This project is forked from an earlier version of the [ReScript
compiler](https://github.com/rescript-lang/rescript-compiler/), focused on a
deeper integration with the OCaml ecosystem. Such integration makes it easy to
share code between backend and frontend using e.g. Dune's virtual libraries.

Melange 1.0 includes a ReScript compatibility layer to maintain compatibility
with ReScript syntax - preserving access to ReScript's package ecosystem. Both
ReScript and Melange have diverged significantly since then, and this
compatibility layer was removed in Melange 2.0.

A small write-up with more details on the motivation behind this project can be
found in the announcement [blog
post](https://anmonteiro.com/2021/03/on-ocaml-and-the-js-platform/). Additional
write-ups exist at [anmonteiro.substack.com](https://anmonteiro.substack.com/)

Below is a quick comparison between Melange and other tools:


| Name                                   | Purpose                                                        | Dependencies                       | Notes                                                                               |
| -------------------------------------- | -------------------------------------------------------------- | ---------------------------------- | ----------------------------------------------------------------------------------- |
| [OPAM](https://opam.ocaml.org)         | Package manager                                                | None                               | Obtaining dependencies such as `dune` or `reason` |
| [Dune](https://dune.build/)            | Build tool                                                     | Installed with e.g. `opam`         | Composable build tool for OCaml; supports composing custom rules to build any project |
| [Reason](https://reasonml.github.io/)  | Syntax                                                         | Installed with e.g. `opam`         | Alternative syntax to OCaml |
| [Melange](https://melange.re)          | Compiler that emits Script                                     | OPAM (to install), Dune (to build) | Supports OCaml and Reason; derived from ReScript, focused on deeper integration with OCaml |
| [ReScript](https://rescript-lang.org/) | The brand around a syntax and a compiler that emits JavaScript | None                               | Distributed via NPM as prebuilt binaries; previously called BuckleScript |

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
