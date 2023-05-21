Demonstrate error when `[@@deriving abstract]` appears multiple times in
recursive type declarations

  $ . ./setup.sh
  $ cat > foo.ml <<EOF
  > type a = {
  >   recursiveA: a Js.Null.t [@bs.optional];
  >   usingB: b Js.Null.t [@bs.optional];
  > } [@@deriving abstract]
  > and b = {
  >   usingA: a Js.Null.t [@bs.optional];
  >   constraint_: bool Js.Null.t [@bs.as "constraint"] [@bs.optional];
  > } [@@deriving abstract]
  > EOF

  $ melc -ppx melppx foo.ml
  File "foo.ml", lines 1-4, characters 0-23:
  1 | type a = {
  2 |   recursiveA: a Js.Null.t [@bs.optional];
  3 |   usingB: b Js.Null.t [@bs.optional];
  4 | } [@@deriving abstract]
  Error: Multiple definition of the type name a_abstract.
         Names must be unique in a given structure or signature.
  [2]

To address it, include only a single `[@@deriving abstract]` in the entire type
declaration.

  $ cat > foo.ml <<EOF
  > type a = {
  >   recursiveA: a  [@bs.optional];
  >   usingB: b  [@bs.optional];
  > }
  > and b = {
  >   usingA: a  [@bs.optional];
  >   constraint_: bool  [@bs.as "constraint"] [@bs.optional];
  > } [@@deriving abstract]
  > EOF

  $ melc -ppx melppx -bs-no-version-header foo.ml
  /* This output is empty. Its source's type definitions, externals and/or unused code got optimized away. */

