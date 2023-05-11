

  $ cat > foo.ml <<EOF
  > type a = {
  >   recursiveA: a Js.Null.t [@bs.optional];
  >   usingB: b Js.Null.t [@bs.optional];
  > } [@@bs.deriving abstract]
  > and b = {
  >   usingA: a Js.Null.t [@bs.optional];
  >   constraint_: bool Js.Null.t [@bs.as "constraint"] [@bs.optional];
  > } [@@bs.deriving abstract]
  > EOF

  $ melc foo.ml
  File "foo.ml", line 4, characters 5-16:
  4 | } [@@bs.deriving abstract]
           ^^^^^^^^^^^
  Error (warning 101 [unused-bs-attributes]): Unused attribute: bs.deriving
  This means such annotation is not annotated properly.
  for example, some annotations is only meaningful in externals
  
  File "foo.ml", lines 1-4, characters 0-26:
  1 | type a = {
  2 |   recursiveA: a Js.Null.t [@bs.optional];
  3 |   usingB: b Js.Null.t [@bs.optional];
  4 | } [@@bs.deriving abstract]
  Warning 34 [unused-type-declaration]: unused type a.
  [2]

To address the warning, one just needs the `[@@bs.deriving abstract]` attribute
in the last type definition.

  $ cat > foo.ml <<EOF
  > type a = {
  >   recursiveA: a Js.Null.t [@bs.optional];
  >   usingB: b Js.Null.t [@bs.optional];
  > }
  > and b = {
  >   usingA: a Js.Null.t [@bs.optional];
  >   constraint_: bool Js.Null.t [@bs.as "constraint"] [@bs.optional];
  > } [@@bs.deriving abstract]
  > EOF


