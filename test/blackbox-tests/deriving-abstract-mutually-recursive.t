Demonstrate it is possible to use `[@@deriving abstract]` multiple times in
recursive type declarations ( though multiple, shadowing bindings will be
generated )

  $ . ./setup.sh
  $ cat > foo.ml <<EOF
  > type a = {
  >   recursiveA: a Js.Null.t option [@mel.optional];
  >   usingB: b Js.Null.t option [@mel.optional];
  > } [@@deriving abstract]
  > and b = {
  >   usingA: a Js.Null.t option [@mel.optional];
  >   constraint_: bool Js.Null.t option [@mel.as "constraint"] [@mel.optional];
  > } [@@deriving abstract]
  > EOF

  $ melc -ppx melppx -bs-no-version-header foo.ml
  /* This output is empty. Its source's type definitions, externals and/or unused code got optimized away. */

