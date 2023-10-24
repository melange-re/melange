# Contributing

Thanks for your interest! Below we describe Melange development setup for a few different package managers. If something isn't working, or you'd like to add another workflow, please let us know by filing an issue.

## Installation

Melange can be set up with [Nix](#Nix) or [opam](#opam). Instructions for each of them are detailed below.

### Nix

**Prerequisites**:
- Install the [Nix](https://nixos.org/) package manager
- Enable [Nix Flakes](https://nixos.wiki/wiki/Flakes)

The best way to get started is to get a `nix` shell running:

```sh
# Runs a shell in the nix environment.
$ make nix-zsh
```

Once you're in the shell, you have access to `dune`, `node`, `yarn`, and all the other executables you need to get down to business.

- You can also use `make nix-*` to execute arbitrary commands in the nix environment. e.g. If you need a text editor running with the nix environment you can do

```sh
make nix-nvim # Runs nvim in the nix environment
make nix-code # Opens VSCode in the nix environment
make nix-fish # Runs fish shell in the nix environment
# etc.
```

### OPAM

**Prerequisites**:
- Install the [opam](https://opam.ocaml.org/) package manager
- Install `tree` command line tool (`brew install tree` for macOS or `apt install tree` for Linux)

After cloning the repository, make sure to initialize git submodules, so that
`melange-compiler-libs` is updated:

```sh
$ git submodule update --init --recursive --remote
```

To set up a development environment using [opam](https://opam.ocaml.org/), run `make opam-init` to set up an opam [local switch](https://opam.ocaml.org/blog/opam-local-switches/) and download the required dependencies.

Install the dependencies in `melange.opam` without building and installing melange itself by running:

    $ opam install ./melange.opam --deps-only


If you plan to work on improving documentation, you will need to install `odoc`: `opam install odoc`.

## Developing

Here are some common commands you may find useful:

- `dune build` builds the whole project
- `dune runtest` runs the native tests
- `dune exec jscomp/main/melc.exe` is useful to run the development version of `melc`

### Updating the `vendor/melange-compiler-libs` submodule:

1. Make your change in
   [`vendor/melange-compiler-libs`](./vendor/melange-compiler-libs)
2. Commit to your fork of the [`melange-compiler-libs`
   repo](https://github.com/melange-re/melange-compiler-libs) and get a PR
   through
3. Commit the updated branch to the submodule in this repository
4. To make it build in CI, change the `melange-compiler-libs` input URL in
   [flake.nix](https://github.com/melange-re/melange/blob/9597451da4c83fd6ba937e4592941b7cb18b45e8/flake.nix#L14)
   (if necessary, e.g. to point to an unmerged branch), then run `nix flake
   update` and commit the modified `flake.lock`

## Submitting a Pull Request

When you are almost ready to open a PR, it's a good idea to run the full CI test suite locally to make sure everything works. First, open a new non-`nix` shell or exit your current `nix` shell by using the `exit` command or `CTRL+D`. Then, run the following command:

```sh
# Runs the full CI test suite
$ nix-build nix/ci/test.nix
```

If that all passes, then congratulations! You are well on your way to becoming a contributor 🎉

To submit a Pull Request, follow [this guide](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork) on creating one from a fork.

## Update JS Reserved Keywords Map

The compiler sources include a list of reserved JS keywords in
`jscomp/ext/js_reserved_map.ml` which includes all identifiers in global scope
(`window` / `globalThis`). This list should be updated from time to time for
newer browser versions.

To update it, run:

```sh
npm install puppeteer
node scripts/build_reserved.js
```

## A whirlwind tour to the compiler codebase

### Folder structure:

- `bin` contains all binaries shipped in a Melange distribution.
- `docs` contains the old [BuckleScript
  manual](https://melange.re/melange/Manual.html) which we host to consult
  (rarely).
- `jscomp` is where the compiler implementation and some tests live:
    - `common` defines the Melange `common` private library, housing code
      shared by both the Melange binary and the `melange.ppx` library.
    - `core` defines the `core` Melange library, containing the bulk of the
      compiler backend implementation.
    - `ext` contains the sources for the `ext` private library. This is a
      standard library extension with additional functions and data structures
      used throughout the Melange code.
    - `js_parser` is a vendored copy of the [Flow
      parser](https://github.com/facebook/flow/tree/main/src/parser), used in
      Melange to classify `%mel.raw` JavaScript code.
    - `runtime` is the Melange runtime. It has:
        - the `melange.js` library.
        - the `Caml_*` modules, implementing the low-level OCaml primitives.
          While these are technically part of the `melange.js` library, they:
            1. aren't exposed in the `Js.*` module.
            2. are only ever accessed from JS: Melange internals don't address
               any of these modules directly, and you shouldn't either.
            3. are still exposed e.g. as `Js__Caml_array` because of Dune
               namespacing implementation details.
    - `stdlib` is the Melange stdlib, included in the final distribution.
      - Depends on the runtime
    - `others` contains the sources for the additional opt-in libraries
      distributed with Melange: `melange.belt`, `melange.dom` and
      `melange.node`.
    - `test` has both:
        - the sources for the Melange runtime tests that are executed on every
          CI run
        - a snapshot of their compilation to JavaScript (in
          [`jscomp/test/dist`](https://github.com/melange-re/melange/tree/main/jscomp/test/dist)
          and
          [`jscomp/test/dist-es6`](https://github.com/melange-re/melange/tree/main/jscomp/test/dist-es6))
            - **NOTE**: these snapshots are currently built manually. To do so,
              comment the only line in
              [`jscomp/dune`](https://github.com/melange-re/melange/blob/main/jscomp/dune)
              and run `dune build`.
- `ocaml-tree` has a code generation tool that produces files such as
  [`core/js_record_fold.ml`](https://github.com/melange-re/melange/blob/main/jscomp/core/js_record_fold.ml),
  automating some repetitive traversal tasks of the Melange JavaScript
  intermediate representation.
- `ppx` has the code for `melange.ppx`, for example:
    - all the `%mel.*` extensions and `@deriving` derivers are declared in
      [`ppx/melange_ppx.ml`](https://github.com/melange-re/melange/blob/main/ppx/melange_ppx.ml).
    - the Melange FFI (Foreign Function Interface) `external`s and attributes
      are interpreted in the PPX.
    - the Melange PPX isn't just a traditional syntax transformation: some
      attributes and functions generated by the PPX get interpreted later
      during Melange compilation. This [piece of
      code](https://github.com/melange-re/melange/blob/1167ca745c7ddc2b950559e53d2ebe43585f3850/jscomp/core/lam_convert.ml#L526-L544)
      shows an example of that.

- `rfcs` has the Melange RFC template and the RFCs to Melange that have been
  accepted to the project.
- `test` is where the Melange unit tests and the blackbox
  [cram](https://dune.readthedocs.io/en/stable/tests.html#cram-tests) tests are
  located.
- `vendor` includes the
  [`melange-compiler-libs`](https://github.com/melange-re/melange-compiler-libs)
  Git submodule.

