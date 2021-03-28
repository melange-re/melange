# Melange

A _mixture_ of tooling combined to produce JS from OCaml / Reason.

This project is a fork of the
[ReScript compiler](https://github.com/rescript-lang/rescript-compiler/) with
a focus on compatibility with the wider OCaml ecosystem. A small write-up with
more details on the motivation behind this project can be found in this
[blog post](https://anmonteiro.com/2021/03/on-ocaml-and-the-js-platform/).

## Installation

This project is currently unreleased. Currently, the most straightforward way
to use it is via [Esy](https://esy.sh).

1. Make sure you have Esy installed (`npm install -g esy` should cover most
   workflows)
2. Use an `esy.json` file like the following:

```json
{
  "dependencies": {
    "bs-platform": "*"
  },
  "resolutions": {
    "bs-platform": "melange-re/melange#HASH_HERE", <- or grab the latest commit in this repo
    "ocaml": "melange-re/ocaml#75f22c8"
  },
  "esy": {
    "buildsInSource": "unsafe",
    "build": [
      "ln -sfn #{bs-platform.install} node_modules/bs-platform"
    ]
  },
  "installConfig": {
    "pnp": false
  }
}
```

3. Run `npm install` (or `yarn`) followed by just `esy` and after they finish installing and building, you should be able to use `bsb` commands via esy `esy bsb -make-world`

4. Reach out on the [ReasonML Discord](https://discord.gg/reasonml) if you
   can't figure it out!

## FAQ

### How does this project relate to other tools?

| Name  | Purpose  | Dependencies  |  Notes |
|---|---|---|---|
| [Esy](https://esy.sh)  | Package manager |  Installed with NPM |  Obtaining dependencies (e.g. `dune` or `reason`)  |
| [Dune](https://dune.build/)  | Build tool  | Installed with `esy` | Well-known OCaml build tool; supports custom rules that can be composed to build _anything_ |
|  [Reason](https://reasonml.github.io/) | Syntax  |  Installed with `esy` | a library that implements an alternative syntax to OCaml  |
|  [Melange](https://melange.re) | Compiler that emits JavaScript  |  Esy (to install), Dune (to build), Reason (used as a library) |  Supports OCaml, Reason and ReScript syntaxes; derived from ReScript, focused on compatibility with the wider OCaml ecosystem |
|  [ReScript](https://rescript-lang.org/) | The brand around a syntax and a compiler that emits JavaScript  | None | Distributed via NPM as prebuilt binaries; previously called BuckleScript |

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

See [Credits.md](./Credits.md).

## Licensing

See [COPYING](./COPYING) and [COPYING.LESSER](./COPYING.LESSER)

See [Credits](./Credits.md) for more details.
