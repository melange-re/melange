# ~~BuckleScript~~

OCaml -> JS compiler.

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
    "bs-platform": "anmonteiro/bucklescript#HASH_HERE", <- or grab the latest commit in this repo
    "ocaml": "anmonteiro/ocaml#75f22c8"
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

3. Reach out on the [ReasonML Discord](https://discord.gg/reasonml) if you
   can't figure it out!

## FAQ

- Can I use ReScript syntax?

Yes! ReScript syntax is supported, but beware that it's stuck on an ancient
OCaml version (4.06, released in 2018), and it won't have as many features as
the OCaml or Reason syntaxes
(e.g. [`letop` binding operators](https://github.com/ocaml/ocaml/pull/1947),
[generalized module open expressions](https://github.com/ocaml/ocaml/pull/2147),
or [local substitutions in signatures](https://github.com/ocaml/ocaml/pull/2122)).

- Where has the `refmt` flag gone?

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

## [Roadmap](https://github.com/rescript-lang/rescript-compiler/wiki)

## Licensing

See [COPYING](./COPYING) and [COPYING.LESSER](./COPYING.LESSER)

The [`ocaml`](ocaml) directory contains the official [OCaml](https://ocaml.org) compiler (version 4.06.1).
Refer to its copyright and license notices for information about its licensing.

The `vendor/ninja.tar.gz` contains the vendored [ninja](https://github.com/ninja-build/ninja).
Refer to its copyright and license notices for information about its licensing.

See [Credits](./Credits.md) for more details.
