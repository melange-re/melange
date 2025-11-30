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

## Releasing Melange

Releasing Melange involves a few steps across different package managers and
GitHub repos:

- Melange releases across a few OCaml versions to the OPAM repository. To
  release to OPAM:
    1. cut release branches e.g. v5-414, v5-51, v5-52, v5-53
        - These branches also serve as long-term release maintenance branches
          if new patch releases need to be cut.
    2. for each new branch, check out the corresponding
       `vendor/melange-compiler-libs` branch in the submodule (e.g. 4.14, 5.1,
       5.2)
    3. [use dune-release](https://gist.github.com/anmonteiro/abd9275456888740758aa9f772d1992a)
       to release the Melange package, adding `-p melange` and
       `--include-submodules` in the relevant commands
- Since the resolution of
  [melange-re/melange#620](https://github.com/melange-re/melange/issues/620),
  Melange releases also include publishing the Melange runtime / stdlib to NPM
  in their compiled form. This makes it easier to use Melange and `(emit_stdlib
  false)` with a well-known, already compiled runtime, speeding up builds in a
  lot of cases. To release the Melange compiled runtime / stdlib to NPM:
    1. set the `MELANGE_RUNTIME_VERSION` variable in `./runtime-export/dune`
    2. run `dune build @runtime`, preferably in the tagged release branch.
    3. `cd` into each of the newly created
       `node_modules/{melange.js,melange,melange.belt}` and run `npm publish`,
       in this order.
- Finally, follow the release process documented in
  [melange-re/melange-re.github.io](https://github.com/melange-re/melange-re.github.io/)
  to publish the Melange website for the new version at https://melange.re.

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

Since
[melange-re/melange#1665](https://github.com/melange-re/melange/pull/1665),
this is now done periodically and automatically. The
[workflow](https://github.com/melange-re/melange/actions/workflows/auto-update-reserved.yml) may also be triggered manually.

## Upgrading the Flow JS parser

Melange vendors a copy of Facebook's Flow parser. It's used, among other
things, to parse the JS code under `%mel.raw` extension points. From time to
time we want to upgrade the Flow parser to get the newer features added to
JavaScript.

Follow these steps to upgrade the vendored Flow parser within Melange:

1. Clone the [Flow repository](https://github.com/facebook/flow) and build the
   parser with `dune b -p flow_parser`

2. Copy the `.ml{,i}` sources to `jscomp/js_parser`:

```shell
$ cp \
    ${FLOW_SRC}/src/parser/*.ml{,i} \
    ${FLOW_SRC}/src/hack_forked/utils/collections/third-party/flow_{set,map}.ml \
    ${FLOW_SRC}/src/third-party/sedlex/flow_sedlexing.ml{,i} \
    ${MELANGE_SRC}/jscomp/js_parser
```

3. Write a small program to get the expanded AST back to source code
  - this way we don't need to depend on the sedlex PPX in Melange. We'll be
    copying the expanded sources from the dune build folder

For `.ml` files:

```ocaml
(* (executable (name x) (libraries compiler-libs.common)) *)
let () =
  let ast = Pparse.read_ast Structure Sys.argv.(1) in
  Format.printf "%a" Pprintast.structure ast
```

For `.mli` files:

```ocaml
(* (executable (name x) (libraries compiler-libs.common)) *)
let () =
  let ast = Pparse.read_ast Signature Sys.argv.(1) in
  Format.printf "%a" Pprintast.signature ast
```

4. Run this small program on the following modules: `Flow_lexer`,
   `Parse_error`, `Enum_common` and `Token`:

```shell
# Example for `Flow_lexer`

dune exec ./pp_ast.exe -- flow/_build/default/src/parser/flow_lexer.pp.ml > jscomp/js_parser/flow_lexer.ml
dune exec ./pp_ast.exe -- flow/_build/default/src/parser/flow_lexer.pp.mli > jscomp/js_parser/flow_lexer.mli
```

5. Prune unnecessary modules (e.g. look at `${FLOW_SRC}/src/parser/dune` and
   remove the modules that aren't part of the flow_parser library, etc). A good
   rule of thumb is to prune most new files after staging them in Git. If they
   aren't used in any other modules, most likely Melange won't either.

## A whirlwind tour to the compiler codebase

### Folder structure:

- `bin` contains all binaries shipped in a Melange distribution.
- `docs` contains the old [BuckleScript
  manual](https://melange.re/melange/Manual.html) which we host to consult
  (rarely).
- `jscomp` is where the compiler implementation and some tests live:
    - `common` defines the `melange_ffi` private library, housing code shared
      by both the Melange core library and `melange.ppx`.
    - `core` defines the `core` Melange library, containing the bulk of the
      compiler backend implementation.
    - `melstd` contains the sources for the `ext` private library. This is a
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
- `playground` contains the Melange in-browser playground code
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

