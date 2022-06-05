# Melange

A _mixture_ of tooling combined to produce JS from OCaml / Reason.

This project is a fork of the
[ReScript compiler](https://github.com/rescript-lang/rescript-compiler/) with
a focus on compatibility with the wider OCaml ecosystem. A small write-up with
more details on the motivation behind this project can be found in this
[blog post](https://anmonteiro.com/2021/03/on-ocaml-and-the-js-platform/).

- [Melange](#melange)
  - [Installation](#installation)
    - [Esy](#esy)
    - [Nix](#nix)
    - [Editor support](#editor-support)
      - [VSCode](#vscode)
    - [A note on OCaml versions](#a-note-on-ocaml-versions)
  - [FAQ](#faq)
    - [How does this project relate to other tools?](#how-does-this-project-relate-to-other-tools)
    - [Can I use ReScript syntax?](#can-i-use-rescript-syntax)
    - [Where has the `refmt` flag gone?](#where-has-the-refmt-flag-gone)
  - [Contributing](#contributing)
  - [Acknowledgments](#acknowledgments)
  - [Licensing](#licensing)

## Installation

This project is currently unreleased. There are, however, a few ways to try it
out.

### [Esy](https://esy.sh)

The easiest way to get started is to
clone the [basic template](https://github.com/melange-re/melange-basic-template)
and run `esy` in the project root. To install [Esy](https://esy.sh), `npm
install -g esy` should cover most workflows. If you have NodeJS / `npm`
available, `npx esy` is even shorter.

### [Nix](https://nixos.org/learn.html)

Melange has good support for Nix:

- `nix run github:melange-re/melange -- build` runs melange.
- `nix shell github:melange-re/melange -c $SHELL` enters a shell with `mel` and
  `melc` in `$PATH`. Try out `mel --help`, for example.
  for available options.
- Adding `github:melange-re/melange` as a
  [flake](https://nixos.wiki/wiki/Flakes) input exports melange as the default
  package

Please reach out on the [ReasonML Discord](https://discord.gg/reasonml) if you
can't figure it out!

### Editor support

Until Melange has first-class support in Dune, `ocaml-lsp` support relies on
having Melange generate a `.merlin` file to provide the language server with
information about your project.

To enable editor support via `ocaml-lsp`, add the following to your `esy.json`:

```json
// esy.json
{
  "devDependencies": {
    "@opam/ocaml-lsp-server": "ocaml/ocaml-lsp:ocaml-lsp-server.opam#c275140",
    "@opam/dot-merlin-reader": "4.2"
  }
}
```

Then use the `--fallback-read-dot-merlin` flag when running `ocaml-lsp`.

#### VSCode

If using the [VSCode OCaml
Platform](https://github.com/ocamllabs/vscode-ocaml-platform) extension, use the
`Custom` sandbox option and provide the flag to `ocaml-lsp` via the command
template:

```json
// .vscode/settings.json
{
  "ocaml.sandbox": {
    "kind": "custom",
    "template": "esy $prog $args --fallback-read-dot-merlin"
  }
}
```

### A note on OCaml versions

The current Melange distribution works on OCaml 4.14 and OCaml 5.00+trunk. If
you need to use Melange with OCaml 4.12 (the only formerly supported version),
you can consume the [0.1.0 tag](https://github.com/melange-re/melange/releases/tag/0.1.0)
for this repo (make sure to similarly use the [`4.12.0+mel` tag](https://github.com/melange-re/melange-compiler-libs/releases/tag/4.12.0%2Bmel)
for [`melange-compiler-libs`](https://github.com/melange-re/melange-compiler-libs)).

## FAQ

### How does this project relate to other tools?

| Name                                   | Purpose                                                        | Dependencies                                                  | Notes                                                                                                                        |
| -------------------------------------- | -------------------------------------------------------------- | ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| [Esy](https://esy.sh)                  | Package manager                                                | Installed with NPM                                            | Obtaining dependencies (e.g. `dune` or `reason`)                                                                             |
| [Dune](https://dune.build/)            | Build tool                                                     | Installed with `esy`                                          | Well-known OCaml build tool; supports custom rules that can be composed to build _anything_                                  |
| [Reason](https://reasonml.github.io/)  | Syntax                                                         | Installed with `esy`                                          | a library that implements an alternative syntax to OCaml                                                                     |
| [Melange](https://melange.re)          | Compiler that emits JavaScript                                 | Esy (to install), Dune (to build), Reason (used as a library) | Supports OCaml, Reason and ReScript syntaxes; derived from ReScript, focused on compatibility with the wider OCaml ecosystem |
| [ReScript](https://rescript-lang.org/) | The brand around a syntax and a compiler that emits JavaScript | None                                                          | Distributed via NPM as prebuilt binaries; previously called BuckleScript                                                     |

### Can I use ReScript syntax?

Yes! ReScript syntax is supported, but beware that it's stuck on an ancient
OCaml version (4.06, released in 2018), and it won't have as many features as
the OCaml or Reason syntaxes
(e.g. [`letop` binding operators](https://github.com/ocaml/ocaml/pull/1947),
[generalized module open expressions](https://github.com/ocaml/ocaml/pull/2147),
or [local substitutions in signatures](https://github.com/ocaml/ocaml/pull/2122)).

### Where has the `refmt` flag gone?

Upstream [removed the `refmt`](https://github.com/rescript-lang/rescript-compiler/pull/4998/commits/be9b1add647859d595dc2e2cbd5552ca246d1df9)
flag, which used to allow configuring the path to a custom Reason binary. This
was a welcome change for this repo too, so we cherry-picked it. The rationale:
this project uses [Reason](https://github.com/reasonml/reason) as a library,
so you can simply depend on the Reason version that you'd like in the usual way,
via your preferred package manager.

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
